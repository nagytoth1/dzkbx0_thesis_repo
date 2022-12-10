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
  PRODUCER = 'Somodi L�szl�';
  MANUFACTURER = 'Pluszs Kft.';
  //error codes instead of exceptions - the cause thrown exceptions cannot be detected by C# PInvoke
  DEV485_NULL = 255;
  DEV485_EMPTY = 254;
  DEV485_ALREADY_FILLED = 253;
  TURNNUM_OUTOFBOUNDS = 252;
  DEVCOUNT_IDENTITY_ERROR = 251;
  DEVTYPE_UNDEFINED = 250;
  DEVSETTINGS_INVALID_FORMAT = 249;
  DEVSETTING_FAILED = 248;
  EXIT_SUCCESS = 0;
var
  drb485: integer;
  dev485:DEVLIS; //where is it set?
  lista: LISTBL; //what is this var for?
  devList: LISTBL; //where is devList set?
  H: HANGLA;
//exported methods
function openDLL(wndhnd:DWord): DWord; stdcall; external CONVERTERDLL_PATH;
function detectDevices(): DWord; stdcall; external CONVERTERDLL_PATH;
function convertDeviceListToJSON(out outputStr: WideString): Byte; stdcall; external CONVERTERDLL_PATH;
function convertDeviceListToXML(const outPath:string): byte; stdcall; external CONVERTERDLL_PATH;
function setTurnForEachDevice(turn : byte):integer; stdcall; external CONVERTERDLL_PATH;
//testing purposes only!
function fillDeviceListWithDevices(): Byte; stdcall; external CONVERTERDLL_PATH;

//private methods
procedure Split (const Delimiter: Char; Input: string; const Strings: TStrings);
procedure RemoveSpecialChars(var str : string); external CONVERTERDLL_PATH;
function convertJSONToDeviceList(json_source: string):DEVLIS; external CONVERTERDLL_PATH; //param: PDEVLIS?
function extractValueFromJSONField(const json_element, key: string):string;   external CONVERTERDLL_PATH;
function reduceJSONSourceToElements(const json_source:string):TStringList;  external CONVERTERDLL_PATH;
function validateExtractedDeviceValues(const actDeviceType:string; const actDeviceSettings: TStringList):byte; external CONVERTERDLL_PATH;
procedure setDeviceByType(const i: integer; const actDeviceType: char; const actDeviceSettings: TStringList); external CONVERTERDLL_PATH;
function setLEDDevice(i, red, green, blue, direction:byte):byte; external CONVERTERDLL_PATH;
function setSpeaker(i, volume, id, length:byte):integer; external CONVERTERDLL_PATH;
 
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
end.