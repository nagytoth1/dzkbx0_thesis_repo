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

//dpr implements the methods defined in pas + creates its own methods + propagates methods with exportlist
//signatures of private, not exported, implemented methods
//creates Delphi stringlist from given JSON-array
function reduceJSONSourceToElements(var json_source: WideString):TStringList; Forward;
//searches for the key in a JSON-element, returns with a value paired to it
//for example: from input "azonos":10 method is going to return 10
function extractValueFromJSONField(const json_element, key: string):string; Forward;
//splits string by given delimiter character
procedure split(const Delimiter: Char; Input: string; const Strings: TStrings); Forward;
//removes unnecessary characters from JSON-input string, prepares it
procedure removeSpecialChars(var str : WideString); Forward;
//creates dev485 from JSON-format
function convertJSONToDEV485(var json_source: WideString):DEVLIS; Forward;
//checks whether the settings of the devices are correct
function validateExtractedDeviceValues(const actDeviceType:string; const actDeviceSettings: TStringList):byte; Forward;
//decides which type the given device belongs to (LED-arrow, LED-light or Speaker) and calls the corresponding set-method
procedure setDeviceByType(const i: integer; var actDeviceType: string; var actDeviceSettings: string);Forward;
//sets a device of a LED-arrow and LED-light type
function setLEDDevice(i, red, green, blue, direction:integer):byte; Forward;
//sets a device of a Speaker type
function setSpeaker(i, id, volume:byte; length:word):integer; Forward;

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
  result := SLDLL_Open(wndhnd, UZESAJ, @nevlei, @devusb);
end;

function Felmeres(): DWord; stdcall;
begin
  result := SLDLL_Felmeres();
  showmessage(Format('Felmeres eredmenye %d &dev485 = %p &dev485[0] = %p', [result, @dev485, @dev485[0]]));
end;

//sets the pointer of dev485 - called in uzfeld-method
function Listelem(out outputStr: WideString; var eszkozDarabszam: integer): dword; stdcall;
begin
  result := SLDLL_Listelem(@dev485); //itt tuti, hogy ismeri dev485-öt
  drb485 := eszkozDarabszam;
  showmessage(Format('Listelem sikeres, eredmenye %d dev485 = %p &dev485[0] = %p &dev485[1] = %p', [Result, dev485, @dev485[0], @dev485[1]]));
  ConvertDEV485ToJSON(outputStr);
end;

function SetTurnForEachDeviceJSON(var turn : byte; var json_source: WideString):integer; stdcall;
var
	i: integer;
	jsonArrayElements: TStringList;
	json_element1, json_element2: string;
	actDeviceType: string;
	actDeviceSettings: string;
begin
	//decode the JSON of the current turn (type + settings fields)
	jsonArrayElements := reduceJSONSourceToElements(json_source);
	for i := 0 to drb485 - 1 do //for [0;drb485] inclusive
	begin
		json_element1 := jsonArrayElements[i]; //loads the actual device
		json_element2 := jsonArrayElements[i+1]; //loads the actual device
    //I want the first char of string 
		actDeviceType := extractValueFromJSONField(json_element1, 'type'); //gets the type of the device
    actDeviceSettings := extractValueFromJSONField(json_element2, 'settings'); //255|0|0|1
		//if validateExtractedDeviceValues(actDeviceType, actDeviceSettings) <> 0 then continue;
    showmessage(actDeviceSettings);
		devList[i].azonos := dev485[i].azonos;
		setDeviceByType(i, actDeviceType, actDeviceSettings);
  end; //case
  result := SLDLL_SetLista(drb485, devList);
  showmessage(format('setlista = %d', [result]));
end;

function ConvertDEV485ToXML(const outPath:string): byte; stdcall;
var
  XML : IXMLDOCUMENT;
  RootNode : IXMLNODE;
  i : integer;
begin
	if(drb485 = 0) or (not Assigned(dev485)) then
	begin
		showmessage(format('Dev485 is empty drb485 = %d  dev485 = %p', [drb485, @dev485]));
		result := DEV485_EMPTY;
		exit;
	end;
    
	XML := NewXMLDocument();
	XML.Encoding := 'utf-8';
	XML.Options := [doNodeAutoIndent];
	RootNode := XML.AddChild('device');
	
	i := 0;
	while dev485[i].azonos <> 0 do //that's the way of iterating through dev485 array (or using the drb485 variable)
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
  if (drb485 = 0) or (not Assigned(dev485)) then
  begin
  	showmessage(format('Dev485 is empty drb485 = %d  dev485 = %p', [drb485, @dev485]));
    outputStr := '[]';
    result := DEV485_EMPTY;
    exit;
  end;
  buffer := '[';  //JSON-array is going to be created
  i:=0;
  while i < drb485 do
  begin
    buffer := buffer + Format('{"azonos":%d},', [dev485[i].azonos]);
    writeln(buffer);
    inc(i);
  end;
  buffer[length(buffer)] := ']'; 
  //the comma (,) at the type of the last device is unnecessary and makes the JSON-invalid, so rather we just overwrite it with the 'end of array'-character
  writeln(buffer);
  writeln('Array dev485 has been converted to JSON-string successfully!');
  outputStr := buffer;
  result := EXIT_SUCCESS;
end;

//it functions as a source handler (simplifying the source) if we see it as a compiler
procedure removeSpecialChars(var str : WideString); //string is given by as reference
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
function convertJSONToDEV485(var json_source: WideString):DEVLIS; //returns array dev485
var
  //input looks like this: [{"azonos" : 16388, "tipus" : "L"},{"azonos": 120, "tipus" : "0"}, ... ]
  jsonArrayElements: TStringList;
  json_element: string;
  i : integer;
  k : integer;
  dev_azonos: SmallInt;
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
    dev_azonos := strToIntDef(json_value, -1);
    if dev_azonos = -1 then
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
	value:string;
	jsonField: TStringList;
begin
	value := '';
	jsonField := TStringList.Create();
	//jsonElement looks like this: azonos:16388
	split(':', json_element, jsonField);
	//if jsonField fails to be split, result value is going to be ''
	if (jsonField.Count <> 0) and (jsonField[0] = key) then
	 	value := jsonField[1]; //'16388'
	result := value;
end;

function reduceJSONSourceToElements(var json_source: WideString):TStringList;
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
	if actDeviceType = '' then
	begin
		writeln('DEVTYPE_UNDEFINED');
		result := DEVTYPE_UNDEFINED;
		exit;
	end;
	if actDeviceSettings.Count < 3 then
	begin
		writeln('DEVSETTINGS_INVALID_FORMAT');
		result := DEVSETTINGS_INVALID_FORMAT;
		exit;
	end;
	result := 0;
end;

procedure setDeviceByType(const i: integer; var actDeviceType: string; var actDeviceSettings: string);
var 
	elements: TStringList;
begin
	elements := TStringList.Create;
	split('|', actDeviceSettings, elements);
	if actDeviceType = 'L' then
	begin
		setLEDDevice( 	//LEDLight
			i,
			strToIntDef(elements[0], 0), 	//red
			strToIntDef(elements[1], 0), 	//green
			strToIntDef(elements[2], 0),  //blue
			2);                           //direction - constantly 2
	exit;
	end;
	if actDeviceType = 'N' then
	begin
		setLEDDevice( 	//LEDArrow
			i,
					strToIntDef(elements[0], 0), 	//red
					strToIntDef(elements[1], 0), 	//green
					strToIntDef(elements[2], 0), 	//blue
					strToIntDef(elements[3], 0));	//direction
		exit;
	end;
	if actDeviceType = 'H' then
	begin
		setSpeaker( //Speaker
			i,
			strToIntDef(elements[0], 0), 	//index from table e.g: 1	
			strToIntDef(elements[1], 0), //volume, e.g: 10
			strToIntDef(elements[2], 0)); //length
	end;  
end;
function setLEDDevice(i, red, green, blue, direction:integer):byte;
begin
	try
	devList[i].vilrgb.rossze := red;
	devList[i].vilrgb.gossze := green;
	devList[i].vilrgb.bossze := blue;
	devList[i].nilmeg := direction;
	result := EXIT_SUCCESS;
	except
		showmessage('LEDDevice setting failed.');
		result := DEVSETTING_FAILED;
	end;
end;

function setSpeaker(i, id, volume:byte; length:word):integer;
begin
	try
    	H[0].hangso := id; //C 261.6256 Hz melyik index?
    	H[0].hanger := volume; //63
		H[0].hangho := length; //300 msec
		showmessage(format('setting speaker to %d %d %d values...', [H[0].hangso, H[0].hanger, H[0].hangho]));
		SLLDLL_Hangkuldes(10, H, dev485[i].azonos);
    	result := EXIT_SUCCESS;
	except
		showmessage('Speaker setting failed.');
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
