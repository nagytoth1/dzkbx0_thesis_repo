unit relay_h;

interface

uses SLDLL, Classes, XMLIntf, XMLDoc, Sysutils, Types, Messages, Dialogs;

//pas serves as a header-file: constants, variables, types, method-declarations
const
  MAX_DEVICECOUNT = 100;
  UZESAJ = WM_USER + 0;
  PRODUCER = 'Somodi László';
  MANUFACTURER = 'Pluszs Kft.';
  RELAY_PATH = 'relay.dll';
  //error codes instead of exceptions - the cause thrown exceptions cannot be detected by C# PInvoke
  DEV485_EMPTY = 254;
  DEV485_ALREADY_FILLED = 253;
  DEVTYPE_UNDEFINED = 250;
  DEVSETTINGS_INVALID_FORMAT = 249;
  DEVSETTING_FAILED = 248;
  DEVSETTING_SPEAKER_FAILED = 247;
  DEVSETTING_ARROW_FAILED = 246;
  DEVSETTING_LIGHT_FAILED = 245;
  EXIT_SUCCESS = 0;
 
var
  drb485: integer;
  dev485:DEVLIS;
  devList: LISTBL;
  H: HANGLA;
  devListSet: boolean;

//exported, public methods, these can be called from C#
// start using DLL
function Open(wndhnd:DWord): word; stdcall; external RELAY_PATH;
// setting dev485 array -> uzfeld-method's alternative in C# is going to call this
function Listelem(var numberOfDevices: byte): word; stdcall; external RELAY_PATH; //uzfeld fogja hï¿½vni
// start of scanning available devices
function Felmeres(): word; stdcall; external RELAY_PATH;
//converting dev485 to JSON-format - JSON-serializing
function ConvertDEV485ToJSON(out outputStr: WideString): byte; stdcall; external RELAY_PATH;
//converting dev485 to XML-format - XML-serializing
function ConvertDEV485ToXML(var outPath:WideString): byte; stdcall; external RELAY_PATH;
//sends an array of statements to ALL devices, this is going to be 1 turn (the passive device during the turn gets 'empty' signal)
function SetTurnForEachDeviceJSON(var json_source: WideString):word; stdcall; external RELAY_PATH;
//fills dev485 with dummy devices
//used only for testing purposes - therefore I used snake_case naming convention to differentiate it
function fill_devices_list_with_devices(): byte; stdcall; external RELAY_PATH;

implementation
end.