unit settings;
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SLDLL, StdCtrls, Menus, ExtCtrls, Grids, StrUtils, XMLIntf, XMLDoc;

const
  PROGRAMFILENAME = 'program.src';
  UZESAJ = WM_USER + 0;
  c1 = 52845;
  c2 = 22719;
  MAX_DEVICECOUNT = 100;

  //procedure setRound(roundNumber: integer);
  procedure setRounds();
  procedure fillDeviceListWithDevices(dev485 : PDEVLIS);
  function convertJSONToDeviceList(json_source: string):DEVLIS;
  function convertDeviceListToJSON(dev485 : PDEVLIS):string;
  procedure DeviceListToXML(dev485: PDEVLIS; const outPath:string);
var
  teststring: string;
  drb485: integer;
  dev485:DEVLIS;
  lista: LISTBL;
  devList: LISTBL;

  SLprogram: TStringList;
  programElements: TStringList;
  ROUNDNUMBER: integer = 0;
  ELEMENTNUMBER: integer;

  timerIntervall: integer = 1000;
  MyCounter: integer = 0;

procedure Split (const Delimiter: Char; Input: string; const Strings: TStrings) ;

implementation

//Haszn�lata: Split('^', Forr�s, Eredm�ny);
procedure Split (const Delimiter: Char; Input: string; const Strings: TStrings) ;
begin
   Assert(Assigned(Strings));
   Strings.Clear;
   Strings.Delimiter := Delimiter;
   Strings.DelimitedText :=  '"' +
      StringReplace(Input, Delimiter, '"' + Delimiter + '"', [rfReplaceAll]) + '"' ;
end;

procedure setRounds();
var
  //i: integer;
  elemszam: integer;
begin

  lista[0].azonos := dev485[0].azonos;
  lista[0].lamrgb.rossze := 20;
  lista[0].lamrgb.gossze := 0;
  lista[0].lamrgb.bossze := 0;
  //devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  lista[1].azonos := dev485[1].azonos;
  lista[1].lamrgb.rossze := 20;
  lista[1].lamrgb.gossze := 0;
  lista[1].lamrgb.bossze := 0;
  //devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  lista[2].azonos := dev485[2].azonos;
  lista[2].lamrgb.rossze := 20;
  lista[2].lamrgb.gossze := 0;
  lista[2].lamrgb.bossze := 0;
  //devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  lista[3].azonos := dev485[3].azonos;
  lista[3].lamrgb.rossze := 20;
  lista[3].lamrgb.gossze := 0;
  lista[3].lamrgb.bossze := 0;
  //devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  elemszam := 2;

  SLDLL_SetLista(elemszam, lista);
end;

//ez az elj�r�s csak a funkci�k tesztel�s�re szolg�l: statikusan felt�lti a dev485-�t eszk�z�kkel
procedure fillDeviceListWithDevices(dev485 : PDEVLIS); 
begin
  SetLength(dev485^, 3);
  dev485^[0].azonos := 16388;
  dev485^[0].produc := 'Teszt Elek';
  dev485^[0].manufa := 'Valaki Zrt.';
  dev485^[1].azonos := 124;
  dev485^[1].produc := 'Teszt Elek';
  dev485^[1].manufa := 'Valaki Zrt.';
  dev485^[2].azonos := 125;
  dev485^[2].produc := 'Teszt Elek';
  dev485^[2].manufa := 'Valaki Zrt.';
end;

function convertDeviceListToJSON(dev485 : PDEVLIS):string; 
//TODO: konkaten�l�snak van-e hat�konyabb v�ltozata Delphi-ben?
//Delphi 2009-es verzi�t�l vezett�k be a TStringBuilder-t, �gy ezt nem tudom haszn�lni
var
  buffer: string;
  deviceType: string;
  i: integer;
begin
  buffer := '[';  //JSON-t�mb�t fogunk k�sz�teni
  i:=-1;
  while dev485^[i+1].azonos <> 0 do
  begin
    //mez?neveket j� lenne lek�rdezhet?v� tenni, nem be�getni a k�dba
      //Run-time type information (RTTI) visszaadja a mez?nevet, ezt k�ne besz�rni a JSON-be -> ha v�ltozik a struct, akkor dinamikusan v�ltozni fog a hozz� k�sz�lt JSON is
    //ennek hi�ny�ban statikus JSON-t k�sz�t�nk, ilyen form�tumban fog kin�zni a JSON mindig
    inc(i);
    buffer := buffer + Format('{"azonos":%d,', [dev485^[i].azonos]);
    //eszk�z t�pus�nak eld�nt�se
    //megkapjuk, ha azonos�t�ja valamint 0xc000 (bin�risan: 1100 0000 0000 0000) �rt�k k�z�tt logikai/bitenk�nti AND-m?veletet v�gz�nk
    case dev485^[i].azonos AND $c000 of
      SLLELO: deviceType := 'L'; //ha az eszk�z l�mpa
      SLNELO: deviceType := 'N'; //ha az eszk�z ny�l
      SLHELO: deviceType := 'H'; //ha az eszk�z hangsz�r�
    else  deviceType := '0'; // nem meghat�rozhat� az eszk�z t�pusa
    end;
    buffer := buffer + Format('"tipus":"%s"},',  [deviceType]);
    writeln(buffer);
  end;
  buffer[length(buffer)] := ']'; //a vessz?t �rja fel�l, t�mb�t lez�r 
  writeln(buffer);
  writeln('Array dev485 has been converted to JSON-string successfully!');
  writeln('-------------');
  result := buffer;
end;

procedure RemoveSpecialChars(var str : string); //in-out-os param�terk�nt adom �t a string-et
  const
    InvalidChars : string = ' "[]{}';
  var
    i : integer;
  begin
    for i := 0 to length(InvalidChars) do
    begin
      str := StringReplace(str, InvalidChars[i], '', [rfReplaceAll]);
    end;
end;
//k�rd�s: dev485 param�terben legyen �tadva (referencia szerint)?
function convertJSONToDeviceList(json_source: string):DEVLIS; //dev485-�t adja vissza
var
  //[{"azonos" : 16388, "tipus" : "L"},{"azonos": 120, "tipus" : "0"}, ... ]
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
  RemoveSpecialChars(json_source); //m�r az elej�n le kell tiszt�zni a json-t, k�l�nben t�bb felesleges eleme lesz a split ut�n a jsonArrayElements t�mbnek
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

    //jsonElement-ben �gy n�z ki: azonos:16388
    Split(':', json_element, jsonField);
    dev485[k].azonos := StrToInt(jsonField[1]); //16388 ker�l bele
    dev485[k].produc := 'Somodi L�szl�';
    dev485[k].manufa := 'Pluszs Kft.';
	  writeln(Format('%d. eszkoz azonos: %d', [k, dev485[k].azonos]));
	  inc(k);
  end;
  writeln('Array dev485 has been created from JSON-string successfully!');
  result := dev485;
end;

procedure DeviceListToXML(dev485: PDEVLIS; const outPath:string);
var
  XML : IXMLDOCUMENT;
  RootNode : IXMLNODE;
  i : integer;
begin
  XML := NewXMLDocument();
      XML.Encoding := 'utf-8';
      XML.Options := [doNodeAutoIndent];

      RootNode := XML.AddChild('device');
      i := 0;
	    while dev485^[i].azonos <> 0 do
      begin
        RootNode.Attributes['azonos'] := dev485^[0].azonos;
        case(dev485^[0].azonos AND $c000) of
                SLLELO:
                begin
                  RootNode.Attributes['tipus'] := 'L'; //l�mpa
                end;
                SLNELO:
                begin
                  RootNode.Attributes['tipus'] := 'N';  //ny�l
                end;
                SLHELO:
                begin
                  RootNode.Attributes['tipus'] := 'H';   //hangsz�r�
                end;
          end;
        inc(i);
      end;
      XML.SaveToFile(Format('%s\scanned_devices.xml', [outPath]));
end;

end.