unit relay_h;

interface

uses SLDLL, Classes, XMLIntf, XMLDoc, Sysutils, Types, Messages, Dialogs;

//a pas szolg�l header-f�jlnak: konstansok, t�pusok, met�dus-deklar�ci�k
//function  SLDLL_Open(wndhnd, msgert: Dword; mianev: PDLLNEV; devata: PDEVSEL): Dword; stdcall; external SLDLL_PATH;
const
  MAX_DEVICECOUNT = 100;
  UZESAJ = WM_USER + 0;
  PRODUCER = 'Somodi L�szl�';
  MANUFACTURER = 'Pluszs Kft.';
  RELAY_PATH = 'relayproject.dll';
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

//export�lt met�dusok, ezeket h�vhatjuk C#-b�l majd
// A DLL haszn�latbav�tel�nek ind�t�sa
function Open(wndhnd:DWord): DWord; stdcall; external RELAY_PATH;
// A dev485 t�mb be�ll�t�sa -> uzfeld-met�dus C#-os megfelel?je fogja h�vni
function Listelem(): Dword; stdcall; external RELAY_PATH; //uzfeld fogja h�vni
// Az el�rhet? eszk�z�k felm�r�s�nek ind�t�sa
function Felmeres(): DWord; stdcall; external RELAY_PATH;
//dev485 t�mb �tkonvert�l�sa JSON-form�tumra - JSON-szerializ�l�snak is nevezhetj�k
function ConvertDEV485ToJSON(out outputStr: WideString): byte; stdcall; external RELAY_PATH;
//dev485 t�mb �tkonvert�l�sa XML-form�tumra - XML-szerializ�l�snak is nevezhetj�k
function ConvertDEV485ToXML(const outPath:string): byte; stdcall; external RELAY_PATH;
//kik�ld egy �temet MINDEN eszk�znek (ami nem csin�l semmit, '�res' jelet kap)
function SetTurnForEachDeviceJSON(turn:byte; json_source: string):integer; stdcall; external RELAY_PATH;
//statikus eszk�z�kkel t�lti fel a dev485-t�mb�t
//tesztel�sre haszn�ljuk - megk�l�nb�ztet�s miatt snake_case konvenci�val nevezem el
function fill_devices_list_with_devices(): byte; stdcall; external RELAY_PATH;

implementation
end.