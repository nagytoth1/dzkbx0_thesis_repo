library relay;

uses
  SysUtils,
  Classes,
  ExtCtrls,
  Messages,
  Dialogs,
  StrUtils,
  XMLIntf,
  XMLDoc,
  Types,
  converter in '..\converter.pas',
  SLDLL in '..\SLDLL.pas';

function fillDeviceListWithDevices(): Byte; stdcall;
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
  writeln('Dev485 filled  with static actDeviceSettings');
  result := EXIT_SUCCESS;
end;

function convertDeviceListToJSON(out outputStr: WideString): Byte; stdcall;
//TODO: is there a more efficient way of concatenating strings in Delphi? 
//I don't think the '+' is the most efficient in Delphi as it is not in C# as well
//TStringBuilder was introduced in Delphi version 2009, therefore that's not an option in our case
var
  buffer: WideString;
  i: integer;
begin
  if(not Assigned(dev485)) or (length(dev485) = 0) then
  begin
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

//it functions as a source handler (simplifying the source) if we see it as a compiler
procedure RemoveSpecialChars(var str : string); //string is given by as reference
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
function convertJSONToDeviceList(json_source: string):DEVLIS; //returns array dev485
var
  //input looks like this: [{"azonos" : 16388, "tipus" : "L"},{"azonos": 120, "tipus" : "0"}, ... ]
  jsonArrayElements: TStringList;
  json_element: string;
  i : integer;
  k : integer;
  dev485 : DEVLIS;
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
	Split(':', json_element, jsonField);
	//if jsonField fails to be split, result value is going to be ''
	if (jsonField.Count <> 0) and (jsonField[0] = key) then
	 	value := jsonField[1]; //'16388'
	result := value;
end;
function reduceJSONSourceToElements(var json_source: string):TStringList;
var 
	jsonArrayElements: TStringList;
begin
	jsonArrayElements := TStringList.Create();
	
	RemoveSpecialChars(json_source);
  	Split(',', json_source, jsonArrayElements);
	result := jsonArrayElements; //'azonos:16388, tipus:"L" ...'
end;

function convertDeviceListToXML(const outPath:string): byte;
var
  XML : IXMLDOCUMENT;
  RootNode : IXMLNODE;
  i : integer;
begin
  if(not Assigned(dev485)) or (length(dev485) = 0) then
  begin
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

function openDLL(wndhnd:DWord): DWord; stdcall;
var
 nevlei, devusb: pchar;
begin
  result := SLDLL_Open(wndhnd, WM_USER + 0, @nevlei, @devusb);
  showmessage(nevlei);
end;

function detectDevices(): DWord; stdcall;
var 
  res, i : integer;
begin
  res := SLDLL_Felmeres();
  showmessage(Format('Felmeres eredmenye %d', [res]));
  res := SLDLL_Listelem(@dev485); //sets dev485 and drb485 as well
  showmessage(Format('ListElem eredmenye %d', [res]));
  
  if(not Assigned(dev485)) then //if dev485 == null
  begin
	result := DEV485_NULL;
	exit;
  end;

  if (length(dev485) = 0) then //if dev485's length is set to 0
  begin
    result := DEV485_EMPTY;
    exit;
  end;

  i := 0;
  while i < drb485 do
  begin
    writeln(Format('%d', [dev485[i].azonos]));
    inc(i);
  end;

  result := res;
end;

function setTurnForEachDevice(turn : byte; json_source: string):integer;
var
	i: integer;
	devCount: integer;
	jsonArrayElements: TStringList;
	json_element: string;
	actDeviceType: char;
	actDeviceSettings: TStringList;
begin
	//decode the JSON of the current turn (type + settings fields)
	jsonArrayElements := reduceJSONSourceToElements(json_source);
	devCount := jsonArrayElements.Count; //count of array - XMLNodes or JSON-array length
	
	if devCount <> drb485 then //if the array is not the same size as length of devicelist, we can't run the method properly
	begin
		Result := DEVCOUNT_IDENTITY_ERROR;
		exit;
	end;

	for i := 0 to devCount - 1 do
	begin
		json_element := jsonArrayElements[i]; //loads the actual device
    	writeln('json_element ' + json_element);
    //I want the first char of string 
		actDeviceType := extractValueFromJSONField(json_element, 'type')[1]; //gets the type of the device
    actDeviceSettings := TStringList.Create();
		Split('|', extractValueFromJSONField(json_element, 'settings'), actDeviceSettings);

		if validateExtractedDeviceValues(actDeviceType, actDeviceSettings) <> 0 then
		begin 
			continue;
		end;

		devList[i].azonos := dev485[i].azonos;
		setDeviceByType(i, actDeviceType, actDeviceSettings);
  end; //case
  result := SLDLL_SetLista(devCount, devList);
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
procedure setDeviceByType(const i: integer; const actDeviceType: char; const actDeviceSettings: TStringList);
begin
	case(actDeviceType) of
		'L': setLEDDevice( 	//LEDLight
        i,
				strToIntDef(actDeviceSettings[0], 0), 	//red
				strToIntDef(actDeviceSettings[1], 0), 	//green
				strToIntDef(actDeviceSettings[2], 0), 	//blue
				strToIntDef(actDeviceSettings[3], 0)); 	//direction
		'N': setLEDDevice( 	//LEDArrow
        i,
				strToIntDef(actDeviceSettings[0], 0), 	//red
				strToIntDef(actDeviceSettings[1], 0), 	//green
				strToIntDef(actDeviceSettings[2], 0), 	//blue
				strToIntDef(actDeviceSettings[3], 0));	//direction
		'H': setSpeaker( //Speaker
        i,
				strToIntDef(actDeviceSettings[0], 0), 	//volume, e.g: 10
				strToIntDef(actDeviceSettings[1], 0), 	//index from table e.g: 1
				strToIntDef(actDeviceSettings[2], 0)); 	//length
  end;
end;
function setLEDDevice(i, red, green, blue, direction:byte):byte;
begin
	try
		devList[i].lamrgb.rossze := red;
		devList[i].lamrgb.gossze := green;
		devList[i].lamrgb.bossze := blue;
		//devList[i] := direction;
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
		devList[i].hantbp := @H; //array for sound settings - 
		//TODO: do we need array?
		H[0].hangho := length; //100;
		H[0].hangso := id; //1;
		H[0].hanger := volume; //10;
    result := EXIT_SUCCESS;
	except
		showmessage('LEDDevice setting failed.');
		result := DEVSETTING_FAILED;
  end;
end;
{$R *.res}
exports openDLL,
		detectDevices,
		convertDeviceListToJSON,
		fillDeviceListWithDevices,
		convertDeviceListToXML,
    setTurnForEachDevice;
begin
end.