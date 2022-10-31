library converter;

uses
  SysUtils, Classes, 
  SLDLL in '..\SLDLL.pas',
  settings in '..\settings.pas',
  StrUtils, XMLIntf, XMLDoc;

const
  MAX_DEVICECOUNT = 100;

procedure fillDeviceListWithDevices(); stdcall;
begin
  SetLength(dev485, 3);
  dev485[0].azonos := 16388;
  dev485[0].produc := 'Teszt Elek';
  dev485[0].manufa := 'Valaki Zrt.';
  dev485[1].azonos := 124;
  dev485[1].produc := 'Teszt Elek';
  dev485[1].manufa := 'Valaki Zrt.';
  dev485[2].azonos := 125;
  dev485[2].produc := 'Teszt Elek';
  dev485[2].manufa := 'Valaki Zrt.';
  writeln('Dev485 filled  with static elements');
end;

procedure convertDeviceListToJSON(out outputStr: WideString); stdcall;
//TODO: is there a more efficient way of concatenating strings in Delphi? 
//I don't think the '+' is the most efficient in Delphi as it is not in C# as well
//TStringBuilder was introduced in Delphi version 2009, therefore that's not an option in our case
var
  buffer: WideString;
  deviceType: string;
  i: integer;
begin
  buffer := '[';  //JSON-array is going to be created
  i:=-1;
  while dev485[i+1].azonos <> 0 do
  begin
    //fields should be queried instead of hard-coded
          //Runtime type information (RTTI) returns field names, this should be inserted into JSON-string -> if struct changes, the JSON-structure changes in response -> that's dangerous as well on C#-side
    //we decided to create static JSON, it always looks like the same, uses the same field tags
    inc(i);
    buffer := buffer + Format('{"azonos":%d,', [dev485[i].azonos]);
    //determining the type of the device
    //when we perform logic operation AND between device's ID and 0xc000 (in binary: 1100 0000 0000 0000) -> we can get the types defined in constants
    //3 types of devices : led light, led arrow and speaker
    case dev485[i].azonos AND $c000 of
      SLLELO: deviceType := 'L'; //if the device is led light
      SLNELO: deviceType := 'N'; //if the device is led arrow
      SLHELO: deviceType := 'H'; //if the device is speaker
    else  deviceType := '0'; // if we can't determine
    end;
    buffer := buffer + Format('"tipus":"%s"},',  [deviceType]);
    writeln(buffer);
  end;
  buffer[length(buffer)] := ']'; 
  //the comma (,) at the type of the last device is unnecessary and makes the JSON-invalid, so rather we just overwrite it with the 'end of array'-character
  writeln(buffer);
  writeln('Array dev485 has been converted to JSON-string successfully!');
  outputStr := buffer;
end;

//it functions as a source handler (simplifying the source) if we see it as a compiler
procedure RemoveSpecialChars(var str : string); //string is given by as reference
  const
    charsToRemove : string = ' "[]{}'; 
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
function convertJSONToDeviceList(json_source: string):DEVLIS; //dev485-öt adja vissza
var
  //input looks like this: [{"azonos" : 16388, "tipus" : "L"},{"azonos": 120, "tipus" : "0"}, ... ]
  jsonArrayElements: TStringList;
  jsonField: TStringList;
  json_element: string;
  i : integer;
  k : integer;
  dev485 : DEVLIS;
begin
  SetLength(dev485, MAX_DEVICECOUNT);
  jsonArrayElements := TStringList.Create();
  jsonField := TStringList.Create();
  RemoveSpecialChars(json_source); //at the beginning we should simplify JSON or else we will have more unnecessary JSON-elements in our jsonArrayElements
  Split(',', json_source, jsonArrayElements);
  k := 0;
  for i := 0 to jsonArrayElements.Count - 1 do
  begin
    json_element := jsonArrayElements[i];
    writeln('json_element ' + json_element);
    if not AnsiContainsText(json_element, 'azonos') then
    begin
      writeln('');
      continue;
    end; 
    //jsonElement looks like now: azonos:16388
    Split(':', json_element, jsonField);
    dev485[k].azonos := StrToInt(jsonField[1]); //dev485[k].azonos gets the value 16388 as an integer
    //these 2 fields are given
    dev485[k].produc := 'Somodi László'; 
    dev485[k].manufa := 'Pluszs Kft.';
	  writeln(Format('%d. eszkoz azonos: %d', [k, dev485[k].azonos]));
	  inc(k);
  end;
  writeln('Array dev485 has been created from JSON-string successfully!');
  result := dev485;
end;

procedure DeviceListToXML(const outPath:string);
var
  XML : IXMLDOCUMENT;
  RootNode : IXMLNODE;
  i : integer;
  devtipus: char;
begin
  XML := NewXMLDocument();
      XML.Encoding := 'utf-8';
      XML.Options := [doNodeAutoIndent];

      RootNode := XML.AddChild('device');
      i := 0;
	    while dev485[i].azonos <> 0 do //that's the way of iterating through dev485 array (or using the drb485 variable)
      begin
        RootNode.Attributes['azonos'] := dev485[0].azonos;
        case(dev485[0].azonos AND $c000) of
                SLLELO: devtipus := 'L'; //led light
                SLNELO: devtipus := 'N';  //led arrow
                SLHELO: devtipus := 'H';   //speaker
        else  devtipus := '0'; // if we can't determine
        end;
        RootNode.Attributes['tipus'] := devtipus;
        inc(i);
      end;
      XML.SaveToFile(Format('%s\scanned_devices.xml', [outPath]));
end;

{$R *.res}

exports fillDeviceListWithDevices, convertDeviceListToJSON;

begin
end.
