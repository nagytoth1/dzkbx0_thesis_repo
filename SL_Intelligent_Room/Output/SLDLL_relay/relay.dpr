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
procedure removeSpecialChars(var outputStr: WideString); Forward;
//creates dev485 from JSON-format
function convertJSONToDEV485(var json_source: WideString):DEVLIS; Forward;
//decides which type the given device belongs to (LED-arrow, LED-light or Speaker) and calls the corresponding set-method
procedure setDeviceByType(const i: integer; actDeviceType: char; var actDeviceSettings: string);Forward;
function validateDeviceType(var i: integer; var actDeviceType: char):byte; Forward;

function fill_devices_list_with_devices(): byte; stdcall;
begin
  if (Assigned(dev485)) or (length(dev485) > 0) then
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

function Felmeres(out outputStr: WideString): DWord; stdcall;
begin
	result := SLDLL_Felmeres();
	ConvertDEV485ToJSON(outputStr); //XML should be put here as well
  	//ConvertDEV485ToXML('.');
end;

//sets the pointer of dev485 AND converts it to JSON (or XML)-format - called in uzfeld-method
function Listelem(var eszkozDarabszam: integer): dword; stdcall;
begin
  result := SLDLL_Listelem(@dev485);
  drb485 := eszkozDarabszam;
end;

function SetTurnForEachDeviceJSON(var turn : byte; var json_source: WideString):integer; stdcall;
var
	i: integer;
	jsonArrayElements: TStringList;
	json_element1, json_element2: string;
	actDeviceType: char;
	actDeviceSettings: string;
begin
	//decode the JSON of the current turn (type + settings fields)
	jsonArrayElements := reduceJSONSourceToElements(json_source);
	i := 0;
	while i < drb485 do
	begin
		json_element1 := jsonArrayElements[i]; //loads the actual device
		json_element2 := jsonArrayElements[i+1]; //loads the actual device
    	//I want the first char of string 
		actDeviceType := extractValueFromJSONField(json_element1, 'type')[1]; //gets the type of the device
		showmessage(format('actDevType = %s', [actDeviceType]));
		result := validateDeviceType(i, actDeviceType); 
		//check whether the type defined in JSON is equals to the type of the current connected device in dev485
		if result <> 0 
			then exit;
    	actDeviceSettings := extractValueFromJSONField(json_element2, 'settings'); //255|0|0|1
		devList[i].azonos := dev485[i].azonos;
		setDeviceByType(i, actDeviceType, actDeviceSettings);
    	inc(i);
	end;
	result := SLDLL_SetLista(drb485, devList);
end;

function validateDeviceType(var i: integer; var actDeviceType: char):byte;
var
	dev485Type: char;
begin
	dev485Type := 'L';
	case dev485[i].azonos and $c000 of
		SLNELO: dev485Type := 'N';
		SLHELO: dev485Type := 'H';
	end;
	showmessage(format('correct type: %s actual type: %s',[dev485Type, actDeviceType]));
	if actDeviceType = dev485Type then result := EXIT_SUCCESS 
	else result := JSON_TYPE_ERROR;
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
	while i < drb485 do //that's the way of iterating through dev485 array (or using the drb485 variable)
	begin
		RootNode.Attributes['azonos'] := dev485[i].azonos; //we don't need the type of the device
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
procedure removeSpecialChars(var outputStr : WideString); //string is given by as reference
  const
    charsToRemove = ' "[]{}'+sLineBreak;
  var
    i : integer;
  begin
  	i := 0;
    while i < length(charsToRemove) do
    begin
      outputStr := StringReplace(outputStr, charsToRemove[i], '', [rfReplaceAll]); //parameters: input string (source)
      inc(i);
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
  SetLength(dev485, drb485);
  jsonArrayElements := reduceJSONSourceToElements(json_source);
  k := 0; //the index of dev485 gets incremented only if field 'azonos' is found with its value
  for i := 0 to jsonArrayElements.Count - 1 do
  begin
    json_element := jsonArrayElements[i];
    writeln('json_element ' + json_element);
    json_value := extractValueFromJSONField(json_element, 'azonos');
    if json_value = '' then continue;
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
	Strings.DelimitedText :=  '"' + StringReplace(Input, Delimiter, '"' + Delimiter + '"', [rfReplaceAll]) + '"' ;
end;

procedure setDeviceByType(const i: integer; actDeviceType: char; var actDeviceSettings: string);
var 
	settingsElements: TStringList;
begin
	settingsElements := TStringList.Create;
	split('|', actDeviceSettings, settingsElements);
	if (settingsElements.Count < 3) or (settingsElements.Count > 4) then
	begin
		showmessage('DEVSETTINGS_INVALID_FORMAT');
		exit;
	end;
	case actDeviceType of 
		'L':
		begin
			devList[i].vilrgb.rossze := strToInt(settingsElements[0]);
			devList[i].vilrgb.gossze := strToInt(settingsElements[1]);
			devList[i].vilrgb.bossze := strToInt(settingsElements[2]);
			devList[i].nilmeg := 2;
		end;
		'N':
		begin
			devList[i].vilrgb.rossze := strToInt(settingsElements[0]);
			devList[i].vilrgb.gossze := strToInt(settingsElements[1]);
			devList[i].vilrgb.bossze := strToInt(settingsElements[2]);
			
			if settingsElements.Count = 4 then devList[i].nilmeg := strToInt(settingsElements[3])
			else devList[i].nilmeg := 2; //default - right arrow
		end;
		'H':
		begin
			devList[i].handrb := 1;
			devList[i].hantbp := @H; //array for speaker sound settings
			H[0].hangho := strToInt(settingsElements[0]); //100;
			H[0].hangso := strToInt(settingsElements[1]); //1;
			H[0].hanger := strToInt(settingsElements[2]); //10;
		end;
		else
			showmessage('DEVTYPE_UNDEFINED')
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
