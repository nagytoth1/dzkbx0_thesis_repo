unit converter;

interface
uses
  SysUtils,
  Classes,
  ExtCtrls,  Messages, 
  Dialogs, StrUtils,
  XMLIntf, XMLDoc, Types,
  SLDLL;
const
//ezek benne vannak SLDLL-ben is
  //SLLELO = $4000;  //led light prefix
  //SLNELO = $8000;  //led arrow prefix
  //SLHELO = $c000;  //speaker prefix
  MAX_DEVICECOUNT = 100;
  UZESAJ = WM_USER + 0;
  CONVERTERDLL_PATH = 'converterdll.dll';
var
  drb485: integer;
  dev485:DEVLIS;
  lista: LISTBL;
  devList: LISTBL;
//exported methods
procedure fillDeviceListWithDevices(); stdcall; external CONVERTERDLL_PATH;
procedure convertDeviceListToJSON(out outputStr: WideString); stdcall; external CONVERTERDLL_PATH;
function Open(wndhnd:DWord): DWord; stdcall; external CONVERTERDLL_PATH;
function DetectDevices(): DWord; stdcall; external CONVERTERDLL_PATH;

procedure Split (const Delimiter: Char; Input: string; const Strings: TStrings);
procedure RemoveSpecialChars(var str : string); external CONVERTERDLL_PATH;
function convertJSONToDeviceList(json_source: string):DEVLIS; external CONVERTERDLL_PATH;
procedure DeviceListToXML(const outPath:string); external CONVERTERDLL_PATH;


implementation
//Használata: Split('^', Forrás, Eredmény);
procedure Split (const Delimiter: Char; Input: string; const Strings: TStrings) ;
begin
   Assert(Assigned(Strings));
   Strings.Clear;
   Strings.Delimiter := Delimiter;
   Strings.DelimitedText :=  '"' +
      StringReplace(Input, Delimiter, '"' + Delimiter + '"', [rfReplaceAll]) + '"' ;
end;
end.
