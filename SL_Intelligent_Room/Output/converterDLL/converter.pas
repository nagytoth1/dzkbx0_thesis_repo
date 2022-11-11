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
  MAX_DEVICECOUNT = 100;
  UZESAJ = WM_USER + 0;
  CONVERTERDLL_PATH = 'relay.dll';
  PRODUCER = 'Somodi László';
  MANUFACTURER = 'Pluszs Kft.';
  //error codes instead of exceptions - the cause thrown exceptions cannot be detected by C# PInvoke
  DEV485_EMPTY = 255;
  DEV485_ALREADY_FILLED = 254;
  TURNNUM_OUTOFBOUNDS = 253;
  DEVCOUNT_IDENTITY_ERROR = 252;
  EXIT_SUCCESS = 0;
var
  drb485: integer;
  dev485:DEVLIS; //where is it set?
  lista: LISTBL; //what is this var for?
  devList: LISTBL; //where is devList set?
//exported methods
function fillDeviceListWithDevices(): Byte; stdcall; external CONVERTERDLL_PATH;
function convertDeviceListToJSON(out outputStr: WideString): Byte; stdcall; external CONVERTERDLL_PATH;
function convertDeviceListToXML(const outPath:string): Byte; external CONVERTERDLL_PATH;
function openDLL(wndhnd:DWord): DWord; stdcall; external CONVERTERDLL_PATH;
function detectDevices(): DWord; stdcall; external CONVERTERDLL_PATH;
function setTurnForEachDevice(turn : byte):integer; stdcall; external CONVERTERDLL_PATH;

//private methods
procedure Split (const Delimiter: Char; Input: string; const Strings: TStrings);
procedure RemoveSpecialChars(var str : string); external CONVERTERDLL_PATH;
function convertJSONToDeviceList(json_source: string):DEVLIS; external CONVERTERDLL_PATH; //param: PDEVLIS?
function extractValueFromJSONField(const json_element: string, const key: string):string;
function reduceJSONSourceToElements(const json_source: string):TStringList;
 
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
