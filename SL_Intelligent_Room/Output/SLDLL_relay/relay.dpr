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
function validateExtractedDeviceValues(const actDeviceType:string; const elements: TStringList):byte; Forward;
//decides which type the given device belongs to (LED-arrow, LED-light or Speaker) and calls the corresponding set-method
function setDeviceByType(const i: byte; var actDeviceType: string; var actDeviceSettings: string): byte; Forward;
//sets a device of a LED-arrow and LED-light type
procedure setLEDDevice(i, red, green, blue, direction: byte); Forward;
//sets a device of a Speaker type
procedure setSpeaker(i: byte; elements:TStringList); overload; Forward;
procedure setSpeaker(i, hangso, hanger:byte; hangho: word); overload; Forward;
procedure printErrors(result: word); Forward;
//gets called in setTurnForeachDevice -> turning each device OFF
procedure SwitchEachDeviceOFF(); Forward;

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

//iterates through the list of devices and turns them Off
procedure SwitchEachDeviceOFF();
var
	deviceType, i: word;
begin
	showmessage(format('ennyi eszkoz van = %d', [drb485]));
	for i := 0 to drb485 - 1 do
	begin
		showmessage(format('%d. eszkoz %d azonositoval kikapcsolasa...', [i, devList[i].azonos]));
		deviceType := devList[i].azonos and $c000; //deciding which type the device is
		if deviceType = SLLELO then //if it is LEDLight
		begin
			showmessage('switching off: L');
			setLEDDevice(i, 0, 0, 0, 2);
			continue;
		end;
		if deviceType = SLNELO then //if it is LEDArrow
		begin
			showmessage('switching off: N');
			setLEDDevice(i, 0, 0, 0, 2);
			continue;
		end;
		if deviceType = SLHELO then //if it is Speaker
		begin
			writeln('switching off: H');
			setSpeaker(i, 0, 0, 0);
		end;
	end; //for
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
	jsonArrayElements := reduceJSONSourceToElements(json_source);
	i := 0; j := 0;
	
	//when devList is connected with dev485 then this must be called
	if(devListSet = true) then //when it is the 2nd, 3rd, ... turn
	begin
		//SwitchEachDeviceOFF();
		//SLDLL_SetLista(drb485, devList);
	end;
	
	while(j < drb485) do
	begin
		json_element1 := jsonArrayElements[i]; //loads the actual device
		json_element2 := jsonArrayElements[i+1]; //loads the actual device
    	//I want the first char of string 
		actDeviceType := extractValueFromJSONField(json_element1, 'type'); //gets the type of the device
    	actDeviceSettings := extractValueFromJSONField(json_element2, 'settings'); //for example: 255|0|0|1
		if devListSet = false then //devList should be linked only once with dev485 elements
		begin
			devList[j].azonos := dev485[j].azonos; //link dev485 to devList using identifiers
		end;
		result := setDeviceByType(j, actDeviceType, actDeviceSettings); //SEHException
		//TODO: is there no such result that leads to end the loop?
		printErrors(result);
		inc(j);
		inc(i, 2);
  end; //case
  devListSet := true; //it becomes true after the first iteration (first turn)
  result := SLDLL_SetLista(drb485, devList);
end;

procedure printErrors(result: word);
begin
	if result = 0 then exit;
	if result = DEVTYPE_UNDEFINED then
		showmessage('Eszkoz tipusa nem meghatarozhato.')
	else if result = DEVSETTINGS_INVALID_FORMAT then 
		showmessage('Eszkoz beallitasai nem megfeleloek.')
	else if result = DEVSETTING_ARROW_FAILED then
		showmessage('Nyil beallitasi hiba.')
	else if result = DEVSETTING_SPEAKER_FAILED then
		showmessage('Hangszoro beallitasi hiba.')
	else
		showmessage('Egyeb hiba.');
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

//question: should dev485 be rather given in as parameter?
//in C# we don't need this, we will implement it for C#-environment
function convertJSONToDEV485(var json_source: WideString):DEVLIS; //returns array dev485
var
  //input looks like this: [{"azonos" : 16388, "tipus" : "L"},{"azonos": 120, "tipus" : "0"}, ... ]
  jsonArrayElements: TStringList;
  json_element, json_value: string;
  i, k, dev_azonos: word;
begin
  SetLength(dev485, MAX_DEVICECOUNT);
  jsonArrayElements := reduceJSONSourceToElements(json_source);
  k := 0; //the index of dev485 gets incremented only if field 'azonos' is found with its value
  for i := 0 to jsonArrayElements.Count - 1 do
  begin
    json_element := jsonArrayElements[i];
    json_value := extractValueFromJSONField(json_element, 'azonos');
    if json_value = '' then
		continue;
	
	// if the given string does not represent a valid int (invalid), result is -1
    dev_azonos := strToIntDef(json_value, high(word));
    if dev_azonos = high(word) then
        writeln(Format('Invalid deviceID %s at device %d', [json_value, i])); //if there is a wrong deviceID in JSON, the loop still continues
        continue;
    dev485[k].azonos := dev_azonos; //dev485[k].azonos gets the value '16388' as an int
    //these 2 fields are constants
    dev485[k].produc := PRODUCER; 
    dev485[k].manufa := MANUFACTURER;
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
        ConvertDEV485ToXML,
        SetTurnForEachDeviceJSON,
		fill_devices_list_with_devices; //testing purposes!
begin
end.
