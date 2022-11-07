library converter;

uses
  SysUtils, Classes, 
  SLDLL, settings in 'settings.pas', StrUtils, XMLIntf, XMLDoc, Types, Messages;

const
  SLLELO = $4000;  //led light prefix
  SLNELO = $8000;  //led arrow prefix
  SLHELO = $c000;  //speaker prefix
  MAX_DEVICECOUNT = 100;
  PRODUC = 'Somodi László';
  MANUFA = 'Pluszs KFT.';

function fillDeviceListWithDevices() : integer; stdcall;
begin
  if (assigned(dev485)) or (length(dev485) > 0) then
	Result := 400;
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
  writeln('Dev485 filled  with static elements');
end;

procedure convertDeviceListToJSON(out outputStr: WideString); stdcall;
//TODO: is there a more efficient way of concatenating strings in Delphi? 
//I don't think the '+' is the most efficient in Delphi as it is not in C# as well
//TStringBuilder was introduced in Delphi version 2009, therefore that's not an option in our case
var
  buffer: WideString;
  i: integer;
begin
  if not (assigned(dev485)) or (length(dev485) = 0) then
  begin
    outputStr := '[]';
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
function convertJSONToDeviceList(json_source: string):DEVLIS; //dev485-ï¿½t adja vissza
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
    dev485[k].produc := PRODUC; 
    dev485[k].manufa := MANUFA;
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
	if not (assigned(dev485)) or (length(dev485) = 0) then
	begin
		raise Exception.Create('Device list is empty');
	end;
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

//function  SLDLL_Open(wndhnd, msgert: Dword; mianev: PDLLNEV; devata: PDEVSEL): Dword; stdcall; external SLDLL_PATH;
function Open(wndhnd:DWord): DWord; stdcall;
const
 UZESAJ = WM_USER + 0;
var
 nevlei, devusb: pchar;
 Res : DWord;
begin
  Res := SLDLL_Open(wndhnd, UZESAJ, @nevlei, @devusb);
  Result := Res;
end;

{$R *.res}

exports fillDeviceListWithDevices, convertDeviceListToJSON, Open;

begin
end.
