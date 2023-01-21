library relay;
uses
  relay_h,
  SLDLL,
  Classes,
  XMLIntf,
  XMLDoc,
  Sysutils,
  Types,
  Messages,
  Dialogs;

//a dpr implement�lja a pas-ban meghat�rozott dolgokat + saj�t f�ggv�nyeket implement�l + exportlista

var
  drb485: integer;
  dev485:DEVLIS;
  devList: LISTBL;
  HangBeallitasok: HANGLA;

//priv�t, dpr �ltal kifejtett, de nem export�lt met�dusok fejl�ce/szignat�r�ja
//A megadott JSON-t�mb�t Delphi-stringlist�v� alak�tja
function reduceJSONSourceToElements(var json_source: string):TStringList; Forward;
//megkeresi a kulcsot a JSON_elemben, �s az ahhoz t�rs�tott �rt�kkel t�r vissza
//pl. "azonos":10 -> 10
function extractValueFromJSONField(const json_element, key: string):string; Forward;
//megadott elv�laszt� (delimiter) karakter szerint feldarabolja a sz�veget t�bb r�szre
procedure split(const Delimiter: Char; Input: string; const Strings: TStrings); Forward;
//JSON-bemeneti stringb?l elt�vol�tja a felesleges karaktereket, el�k�sz�ti
procedure removeSpecialChars(var str : string); Forward;
//JSON-form�tumb�l dev485-�t k�sz�t
function convertJSONToDEV485(json_source: string):DEVLIS; Forward;
//ellen�rzi, hogy az eszk�z�k be�ll�t�sa megfelel�en t�rt�nik-e
function validateExtractedDeviceValues(const actDeviceType:string; const actDeviceSettings: TStringList):byte; Forward;
//eld�nti az adott eszk�zr�l, hogy melyik t�pusba (LED-ny�l, LED-l�mpa vagy hangsz�r�) tartozik, ez alapj�n h�vja meg a hozz� megfelel� set-met�dust
procedure setDeviceByType(const i: integer; const actDeviceType: char; const actDeviceSettings: TStringList);Forward;
//be�ll�t egy LED-ny�l �s LED-l�mpa t�pus� eszk�zt
function setLEDDevice(i, red, green, blue, direction:byte):byte; Forward;
//be�ll�t egy hangsz�r� t�pus� eszk�zt
function setSpeaker(i, volume, id, length:byte):integer;Forward;

function fill_devices_list_with_devices(): byte; stdcall;
begin
  if(Assigned(dev485)) or (length(dev485) > 0) then
  begin
    result := DEV485_ALREADY_FILLED;
    exit;
  end;
  SetLength(dev485, 3);
  dev485[0].azonos := $c004;
  dev485[0].produc := 'Teszt Elek';
  dev485[0].manufa := 'Valaki Zrt.';
  dev485[1].azonos := $8004;
  dev485[1].produc := 'Teszt Elek';
  dev485[1].manufa := 'Valaki Zrt.';
  dev485[2].azonos := $4004;
  dev485[2].produc := 'Teszt Elek';
  dev485[2].manufa := 'Valaki Zrt.';
  result := EXIT_SUCCESS;
end;

function Open(wndhnd:DWord): DWord; stdcall;
var
 nevlei, devusb: pchar;
begin
  result := SLDLL_Open(wndhnd, WM_USER+0, @nevlei, @devusb);
end;

function Felmeres(): DWord; stdcall;
begin
  { kell ez?
  //ha az SLDLL_ListElem nem futott m�g le
  if (not Assigned(dev485)) or (drb485 = 0) then
  begin
    result := DEV485_EMPTY; 
    exit;
  end;
  }
  result := SLDLL_Felmeres();
end;

//sets the pointer of dev485 - called in uzfeld-method
function Listelem(): Dword; stdcall;
begin
  result := SLDLL_Listelem(@dev485);
end;

function ConvertDEV485ToXML(const outPath:string): byte; stdcall;
var
  XML : IXMLDOCUMENT;
  RootNode : IXMLNODE;
  i : integer;
begin
  //kell ez? - igen, mert lecsekkoljuk, hogy lefutott-e m�r a SLDLL_Listelem met�dus
  if(not Assigned(dev485)) or (length(dev485) = 0) then
  begin
    result := DEV485_EMPTY;
    exit;
  end;
  XML := NewXMLDocument();
  XML.Encoding := 'utf-8';
  XML.Options := [doNodeAutoIndent];
  RootNode := XML.AddChild('eszkoz');
  i := 0;
  while i < drb485 do //that's the way of iterating through dev485 array (or using the drb485 variable)
  begin
    RootNode.Attributes['azonos'] := dev485[0].azonos; //we don't need the type of the device
    inc(i);
  end;
  XML.SaveToFile(Format('%s\scanned_devices.xml', [outPath]));
  result := EXIT_SUCCESS;
end;

function ConvertDEV485ToJSON(out outputStr: WideString): byte; stdcall;
//TODO: is there a more efficient way of concatenating strings in Delphi? 
//I don't think the '+' is the most efficient in Delphi as it is not in C# as well
//TStringBuilder was introduced in Delphi version 2009, therefore that's not an option in our case
var
  buffer: WideString;
  i: integer;
begin
  if(not Assigned(dev485)) or (length(dev485) = 0) then
  begin
    outputStr := '[]';
    result := DEV485_EMPTY;
    exit;
  end;
  buffer := '[';  //JSON-array is going to be created
  i:=-1;
  while dev485[i+1].azonos <> 0 do
  begin
    inc(i);
    buffer := buffer + Format('{"azonos":%d},', [dev485[i].azonos]);
    writeln(buffer);
  end;
  buffer[length(buffer)] := ']'; 
  //the comma (,) at the type of the last device is unnecessary and makes the JSON-invalid, so rather we just overwrite it with the 'end of array'-character
  writeln(buffer);
  writeln('Array dev485 has been converted to JSON-string successfully!');
  outputStr := buffer;
  result := EXIT_SUCCESS;
end;

function SetTurnForEachDeviceJSON(turn : byte; json_source: string):integer; stdcall;
var
	i: integer;
	devCount: integer;
	jsonArrayElements: TStringList;
	json_element: string;
	actDeviceType: char;
	actDeviceSettings: TStringList;
begin
	jsonArrayElements := reduceJSONSourceToElements(json_source);
	devCount := jsonArrayElements.Count; //count of array - XMLNodes or JSON-array length
	
	if devCount <> drb485 then //if the array is not the same size as length of devicelist, we can't run the method properly
	begin
		showmessage(Format('Devcount = %d DRB485 = %d',[devCount, drb485]));
		result := DEVCOUNT_IDENTITY_ERROR;
		exit;
	end;

	for i := 0 to devCount - 1 do
	begin
		json_element := jsonArrayElements[i]; //loads the actual device
    	writeln('json_element ' + json_element);
    	//I want the first char of string 
		actDeviceType := extractValueFromJSONField(json_element, 'type')[1]; //gets the type of the device
    	actDeviceSettings := TStringList.Create();
		split('|', extractValueFromJSONField(json_element, 'settings'), actDeviceSettings);

		if validateExtractedDeviceValues(actDeviceType, actDeviceSettings) <> EXIT_SUCCESS then continue;
		//�sszerendelj�k dev485-�t �s devList-et egym�ssal azonos�t�k alapj�n
		devList[i].azonos := dev485[i].azonos;
		setDeviceByType(i, actDeviceType, actDeviceSettings);
	end; //case
	//result := SLDLL_SetLista(devCount, devList);
  result := EXIT_SUCCESS;
end;

//it functions as a source handler (simplifying the source) if we see it as a compiler
procedure removeSpecialChars(var str : string); //string is given by as reference
const
	charsToRemove = ' "[]{}'+sLineBreak;
var
	i : integer;
begin
    for i := 0 to length(charsToRemove) do
    begin
      	str := StringReplace(str, charsToRemove[i], '', [rfReplaceAll]); //parameters: input string (source)
    end;
end;

//question: should dev485 be rather given in as parameter?
//in C# we don't need this, we will implement it for C#-environment
function convertJSONToDEV485(json_source: string):DEVLIS; //returns array dev485
var
  //input looks like this: [{"azonos" : 16388, "tipus" : "L"},{"azonos": 120, "tipus" : "0"}, ... ]
  jsonArrayElements: TStringList;
  json_element: string;
  i : integer;
  k : integer;
  dev_azonos: word;
  json_value: string;
begin
  SetLength(dev485, MAX_DEVICECOUNT);
  jsonArrayElements := reduceJSONSourceToElements(json_source);
  k := 0; //the index of dev485 gets incremented only if field 'azonos' is found with its value
  for i := 0 to jsonArrayElements.Count - 1 do
  begin
    json_element := jsonArrayElements[i];
    writeln('json_element ' + json_element);
    json_value := extractValueFromJSONField(json_element, 'azonos');
    if json_value = '' then
		continue;
	
	// if the given string does not represent a valid integer (invalid), result is -1
    dev_azonos := strToIntDef(json_value, high(word));
    if dev_azonos = high(word) then
        showmessage(Format('Invalid deviceID %s', [json_value]));
        continue;
    dev485[k].azonos := dev_azonos; //dev485[k].azonos gets the value '16388' as an integer
    //these 2 fields are constants
    dev485[k].produc := PRODUCER; 
    dev485[k].manufa := MANUFACTURER;
	writeln(Format('%d. eszkoz azonos: %d', [k, dev485[k].azonos]));
	inc(k);
  end;
  writeln('Array dev485 has been created from JSON-string successfully!');
  result := dev485;
end;
function extractValueFromJSONField(const json_element, key:string):string;
var 
	jsonPair: TStringList;
begin
  result := '';
	jsonPair := TStringList.Create();
	//jsonElement looks like this: azonos:16388
	split(':', json_element, jsonPair);
	//if jsonPair fails to be split, result value is going to be ''
	if (jsonPair.Count <> 0) and (jsonPair[0] = key) then
	 	result := jsonPair[1]; //'16388'
end;

function reduceJSONSourceToElements(var json_source: string):TStringList;
var 
	jsonArrayElements: TStringList;
begin
	jsonArrayElements := TStringList.Create();
	
	removeSpecialChars(json_source);
  	split(',', json_source, jsonArrayElements);
	result := jsonArrayElements; //'azonos:16388, tipus:"L" ...'
end;

procedure split(const Delimiter: Char; Input: string; const Strings: TStrings);
begin
	Assert(Assigned(Strings));
	Strings.Clear;
	Strings.Delimiter := Delimiter;
	Strings.DelimitedText :=  '"' +
	StringReplace(Input, Delimiter, '"' + Delimiter + '"', [rfReplaceAll]) + '"' ;
end;

function validateExtractedDeviceValues(const actDeviceType:string; const actDeviceSettings: TStringList):byte;
begin
  	result := EXIT_SUCCESS;
	if actDeviceType = '' then
	begin
		showmessage('Validation failed, devtype undefined!');
		result := DEVTYPE_UNDEFINED;
	end; 
	if actDeviceSettings.Count < 3 then
	begin
		showmessage(format('actDevSettings wrong count: %d', [actDeviceSettings.Count]));
		result := DEVSETTINGS_INVALID_FORMAT;
	end;
end;

procedure setDeviceByType(const i: integer; const actDeviceType: char; const actDeviceSettings: TStringList);
begin
	case(actDeviceType) of
		'L': {setLEDDevice( 	//LEDLight
        		i,
				strToIntDef(actDeviceSettings[0], 0), 	//red
				strToIntDef(actDeviceSettings[1], 0), 	//green
				strToIntDef(actDeviceSettings[2], 0), 	//blue
				strToIntDef(actDeviceSettings[3], 0)); 	//direction - will be 2 constantly
				}
			showmessage(format('lampa beallitva %d %d %d %d ertekekkel', 
				[strToIntDef(actDeviceSettings[0], 0), 	//red
				strToIntDef(actDeviceSettings[1], 0), 	//green
				strToIntDef(actDeviceSettings[2], 0), 	//blue
				strToIntDef(actDeviceSettings[3], 0)
				])); 	//direction - will be 2 constantly])
		'N': {setLEDDevice( 	//LEDArrow
        		i,
				strToIntDef(actDeviceSettings[0], 0), 	//red
				strToIntDef(actDeviceSettings[1], 0), 	//green
				strToIntDef(actDeviceSettings[2], 0), 	//blue
				strToIntDef(actDeviceSettings[3], 0));	//direction}
			begin
				if(actDeviceSettings.Count < 4) then 
				begin
					showmessage('Nem megfelelo nyil beallitasok!');
					exit; //nem megfelel? be�ll�t�sok	
				end;
					showmessage(format('nyil beallitva %d %d %d %d ertekekkel', 
					[strToIntDef(actDeviceSettings[0], 0), 	//red
					strToIntDef(actDeviceSettings[1], 0), 	//green
					strToIntDef(actDeviceSettings[2], 0), 	//blue
					strToIntDef(actDeviceSettings[3], 0)
					])); 	//direction - will be 2 constantly])	
			end;
		'H':{ setSpeaker( //Speaker
        		i,
				strToIntDef(actDeviceSettings[0], 0), 	//volume, e.g: 10
				strToIntDef(actDeviceSettings[1], 0), 	//index from table e.g: 1
				strToIntDef(actDeviceSettings[2], 0)); 	//length
				}
			showmessage(format('hangszoro beallitva %d %d %d ertekekkel', 
				[strToIntDef(actDeviceSettings[0], 0),
				strToIntDef(actDeviceSettings[1], 0), 
				strToIntDef(actDeviceSettings[2], 0) 	
				])); 	//direction - will be 2 constantly])
  end;
end;

function setLEDDevice(i, red, green, blue, direction:byte):byte;
begin
	try
		devList[i].lamrgb.rossze := red;
		devList[i].lamrgb.gossze := green;
		devList[i].lamrgb.bossze := blue;
		//TODO: devList[i] := direction; - ir�ny?
    	result := EXIT_SUCCESS;
	except
		showmessage('LEDDevice setting failed.');
		result := DEVSETTING_FAILED;
  end;
end;

function setSpeaker(i, volume, id, length:byte):integer;
begin
	try
		devList[i].handrb := 1;
		devList[i].hantbp := @HangBeallitasok; //array for sound settings - 
		//TODO: do we need array?
		HangBeallitasok[0].hangho := length; //100;
		HangBeallitasok[0].hangso := id; //1;
		HangBeallitasok[0].hanger := volume; //10;
    	result := EXIT_SUCCESS;
	except
		showmessage('LEDDevice setting failed.');
		result := DEVSETTING_FAILED;
  end;
end;

{$R *.res}
exports Open,
        Listelem,
        Felmeres,
        ConvertDEV485ToJSON,
        ConvertDEV485ToXML,
        SetTurnForEachDeviceJSON,
        fill_devices_list_with_devices; //testing purposes!
begin
end.
