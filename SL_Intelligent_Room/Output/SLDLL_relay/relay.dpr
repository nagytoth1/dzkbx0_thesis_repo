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
  Dialogs,
  Windows;

//dpr implements the methods defined in pas + creates its own methods + propagates methods with exportlist
//signatures of private, not exported, implemented methods

//searches for the key in a JSON-element, returns with a value paired to it
//for example: from input "azonos":10 method is going to return 10
function extractValueFromJSONField(const json_element, key: string):string; Forward;
//splits string by given delimiter character
procedure split(const Delimiter: Char; Input: string; const Strings: TStrings); Forward;
//removes unnecessary characters from JSON-input string, prepares it
procedure removeSpecialChars(var str : WideString); Forward;
//checks whether the settings of the devices are correct
function validateExtractedDeviceValues(const actDeviceType:string; const elements: TStringList):byte; Forward;
//decides which type the given device belongs to (LED-arrow, LED-light or Speaker) and calls the corresponding set-method
function setDeviceByType(const i: byte; var actDeviceType: string; var actDeviceSettings: string): byte; Forward;
//sets a device of a LED-arrow and LED-light type
procedure setLEDDevice(i, red, green, blue, direction: byte); Forward;
//sets a device of a Speaker type
procedure setSpeaker(i: byte; elements:TStringList); overload; Forward;
procedure setSpeaker(i, hangso, hanger:byte; hangho: word); overload; Forward;
//creates a valid JSON-list from deviceIDs of the scanned device 
//implementation comes from 'converter32.dll' written in C
function create_json(device_ids:pinteger;length:integer):pchar; stdcall; external 'converter32.dll'

function fill_devices_list_with_devices(): byte; stdcall;
begin
	if drb485 > 0 then
	begin
		result := DEV485_ALREADY_FILLED; //array is already filled
		exit;
	end;
	drb485 := 3;
	SetLength(dev485, drb485);
	dev485[0].azonos := $c004; //speaker
	dev485[1].azonos := $8004; //arrow
	dev485[2].azonos := $4004; //light
	result := EXIT_SUCCESS;
end;
function Open(wndhnd:DWord): word; stdcall;
var
	nevlei, devusb: pchar;
begin
	result := SLDLL_Open(wndhnd, UZESAJ, @nevlei, @devusb);
end;

function Felmeres(): word; stdcall;
begin
  result := SLDLL_Felmeres();
  devListSet := false;
  writeln(Format('Felmeres eredmenye %d &dev485 = %p &dev485[0] = %p', [result, @dev485, @dev485[0]]));
end;

//sets the pointer of dev485 - called in uzfeld-method
function Listelem(var numberOfDevices: byte): word; stdcall;
begin
	result := SLDLL_Listelem(@dev485);
	drb485 := numberOfDevices;
	devListSet := false;
	writeln(Format('Listelem sikeres, eredmenye %d dev485 = %p &dev485[0] = %p &dev485[1] = %p', [Result, dev485, @dev485[0], @dev485[1]]));
end;

function SetTurnForEachDeviceJSON(var json_source: WideString):word; stdcall;
var
	i, j: byte;
	jsonArrayElements: TStringList;
	json_element1, json_element2: string;
	actDeviceType: string;
	actDeviceSettings: string;
begin
	//decode the JSON of the current turn (type + settings fields)
	jsonArrayElements := TStringList.Create();
	removeSpecialChars(json_source); //prepare JSON by removing unnecessary characters
  	split(',', json_source, jsonArrayElements); //add JSON-entries to a string list 'azonos:16388', ... 
	i := 0; j := 0;
	//when devList is connected with dev485 then this must be called
	while(j < drb485) do
	begin
		json_element1 := jsonArrayElements[i]; //loads the actual device
		json_element2 := jsonArrayElements[i+1]; //loads the actual device
    	//I want the first char of string 
		actDeviceType := extractValueFromJSONField(json_element1, 'type'); //gets the type of the device
    	actDeviceSettings := extractValueFromJSONField(json_element2, 'settings'); //for example: 255|0|0|1
		if devListSet = false then begin
			devList[j].azonos := dev485[j].azonos; //link dev485 to devList using identifiers
			devListSet := true; //it becomes true after the first iteration (first turn)
		end;
		result := setDeviceByType(j, actDeviceType, actDeviceSettings);
		inc(i, 2);
		j := i div 2;
		if result = DEVTYPE_UNDEFINED then begin
			showmessage('Eszkoz tipusa nem meghatarozhato.');
			continue;
		end
		else if result = DEVSETTINGS_INVALID_FORMAT then begin
			showmessage('Eszkoz beallitasai nem megfeleloek.');
			continue;
		end
		else if result = DEVSETTING_ARROW_FAILED then begin
			showmessage('Nyil beallitasi hiba.');
			continue;
		end
		else if result = DEVSETTING_SPEAKER_FAILED then begin
			showmessage('Hangszoro beallitasi hiba.');
			continue;
		end
		else begin
			showmessage('Egyeb hiba.');
			exit;
		end;
  	end; //case
	result := SLDLL_SetLista(drb485, devList);
end;

function ConvertDEV485ToXML(var outPath:WideString): byte; stdcall;
var
  xmlDocument : IXMLDOCUMENT;
  rootNode, node : IXMLNODE;
  i : byte;
begin
	if(drb485 = 0) or (not Assigned(dev485)) then
	begin
		result := DEV485_EMPTY;
		exit;
	end;
	xmlDocument := NewXMLDocument();
	xmlDocument.Encoding := 'utf-8';
	xmlDocument.Options := [doNodeAutoIndent];
	rootNode := xmlDocument.AddChild('devices');
	for i := 0 to drb485 - 1 do //that's the way of iterating through dev485 array (or using the drb485 variable)
	begin
		node := rootNode.AddChild('device');
		node.Attributes['azonos'] := dev485[i].azonos; //we don't need the type of the device
	end;
	xmlDocument.SaveToFile(outPath);
	showmessage('saved XML to location: ' + outPath);
	result := EXIT_SUCCESS;
end;

function ConvertDEV485ToJSON_C(out outputStr: WideString): byte; stdcall;
var
    i: integer;
    device_ids: array of integer;
    output: pchar;
    azonos: pinteger;
begin
	SetLength(device_ids, drb485);
	for i := 0 to drb485 - 1 do
	begin
		device_ids[i] := dev485[i].azonos;
	end;
	azonos := @device_ids[0];
	output := create_json(azonos, drb485);
	showmessage(format('JSON-buffer = %s', [output]));
	outputStr := output;
	result := 0;
end;

function ConvertDEV485ToJSON(out outputStr: WideString): byte; stdcall;
//TODO: is there a more efficient way of concatenating strings in Delphi? 
//I don't think the '+' is the most efficient in Delphi as it is not in C# as well
//TStringBuilder was introduced in Delphi version 2009, therefore that's not an option in our case
var
  buffer: WideString;
  i: byte;
begin
  if (drb485 = 0) or (not Assigned(dev485)) then
  begin
  	showmessage(format('Dev485 is empty drb485 = %d  dev485 = %p', [drb485, @dev485]));
    outputStr := '[]';
    result := DEV485_EMPTY;
    exit;
  end;
  buffer := '[';  //JSON-array is going to be created
  i := 0;
  while i < drb485 do
  begin
    buffer := buffer + Format('{"azonos":%d},', [dev485[i].azonos]);
    inc(i);
  end;
  buffer[length(buffer)] := ']'; 
  //the comma (,) at the type of the last device is unnecessary and makes the JSON-invalid, so rather we just overwrite it with the 'end of array'-character
  showmessage(format('JSON-buffer = %s', [buffer]));
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

procedure split(const Delimiter: Char; Input: string; const Strings: TStrings);
begin
   Assert(Assigned(Strings));
   Strings.Clear;
   Strings.Delimiter := Delimiter;
   Strings.DelimitedText :=  '"' +
   StringReplace(Input, Delimiter, '"' + Delimiter + '"', [rfReplaceAll]) + '"' ;
end;

function setDeviceByType(const i: byte; var actDeviceType: string; var actDeviceSettings: string): byte;
var 
	elements: TStringList;
begin
	elements := TStringList.Create;
	writeln(format('setDeviceByType - actDeviceType = %s actDeviceSettings = %s', [actDeviceType, actDeviceSettings]));
	//actDeviceSettings look like this: "255|0|0" -> split by delimiter '|' -> elements
	split('|', actDeviceSettings, elements); 
	result := validateExtractedDeviceValues(actDeviceType, elements);
	//returns an error:  DEVTYPE_UNDEFINED, DEVSETTINGS_INVALID_FORMAT, DEVSETTING_ARROW_FAILED, DEVSETTING_SPEAKER_FAILED
	if result <> EXIT_SUCCESS
		then exit;

	//result = 0 from here on...
	if actDeviceType = 'L' then
	begin
		writeln('setDeviceByType - L');
		setLEDDevice( 	//LEDLight
			i,
			strToIntDef(elements[0], 0), 	//red
			strToIntDef(elements[1], 0), 	//green
			strToIntDef(elements[2], 0), 	//blue
			2);  							//direction: constant 2 when it is a LEDLight device
		exit;
	end;
	if actDeviceType = 'N' then
	begin
		writeln('setDeviceByType - N');
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
		writeln('setDeviceByType - H');
		setSpeaker(i, elements); //actDeviceSettings for speakers: "settings" : "10|1|100|20|2|200"
		exit;
	end;
end;
//validates the settings of given device in case of JSON-format
function validateExtractedDeviceValues(const actDeviceType:string; const elements: TStringList):byte;
begin
	if actDeviceType = '' then
	begin
		showmessage('Eszkoz tipusa nem meghatarozhato');
		result := DEVTYPE_UNDEFINED;
		exit;
	end;
	if elements.Count < 3 then
	begin
		showmessage('Eszkozbeallitasok uresek vagy nem megfelelo formatumuak.');
		result := DEVSETTINGS_INVALID_FORMAT;
		exit;
	end;
	if (actDeviceType = 'N') and (elements.Count <> 4) then
	begin
		showmessage('Nyil beallitasa sikertelen: rossz JSON-formatum.');
		result := DEVSETTING_ARROW_FAILED;
		exit;
	end;
	if (actDeviceType = 'H') and (elements.Count mod 3 <> 0) then
	begin
		showmessage('Hangszoro beallitasa sikertelen: rossz JSON-formatum.'); //when "settings"-field is not appropriate (empty, contains invalid number of elements)
		result := DEVSETTING_SPEAKER_FAILED;
		exit;
	end;
	result := EXIT_SUCCESS;
end;
procedure setLEDDevice(i, red, green, blue, direction:byte); overload;
begin
	try
		devList[i].vilrgb.rossze := red;
		devList[i].vilrgb.gossze := green;
		devList[i].vilrgb.bossze := blue;
		devList[i].nilmeg := direction;
	except
		showmessage('LEDDevice setting failed.');
	end;
end;
procedure setSpeaker(i, hangso, hanger:byte; hangho: word); overload;
begin
	devList[i].handrb := 1;
	devList[i].hantbp := @H;
	H[0].hangso := hangso;
	H[0].hanger := hanger;
	H[0].hangho := hangho;
	writeln(format('setting 1 sound to index = %d volume = %d length = %d values...', [H[0].hangso, H[0].hanger, H[0].hangho]));
	SLLDLL_Hangkuldes(1, H, dev485[i].azonos);
end;
procedure setSpeaker(i: byte; elements: TStringList); overload;
var
	j, k: byte;
begin
	j := 0;
	k := 0;
	while j < elements.Count - 2 do
	begin
		H[k].hangso := strToIntDef(elements[j], 0); //5 index
		H[k].hanger := strToIntDef(elements[j+1], 0); //63 volume
		H[k].hangho := strToIntDef(elements[j+2], 0); //1000 length
		writeln(format('setting %d. sound to index = %d volume = %d length = %d values...', [k, H[k].hangso, H[k].hanger, H[k].hangho]));
		inc(j, 3);
		inc(k);
	end;
	try
		writeln(format('%d db hang kikuldese...', [k]));
		SLLDLL_Hangkuldes(k, H, dev485[i].azonos);
	except
		showmessage('Speaker setting failed.');
  end;
end;

{$R *.res}
exports Open,
        Listelem,
        Felmeres,
        ConvertDEV485ToJSON,
		ConvertDEV485ToJSON_C,
        ConvertDEV485ToXML,
        SetTurnForEachDeviceJSON,
		fill_devices_list_with_devices; //testing purposes!
begin
end.
