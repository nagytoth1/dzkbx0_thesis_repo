library SLDLL;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  Windows, HID_KER_USB;

{$R *.RES}

const
  PRODUCT_ID              = $4c53;                          // A k�v�nt ProductID (SL)
//
// Ezek az egyes elemek azonos�t�i
//
  SLLELO	                = $4000;                          // LED  l�mpa el�tag
  SLNELO                  = $8000;                          // LED ny�il el�tag
  SLHELO                  = $c000;                          // SLH el�tag
//
// Legfeljebb ennyi elemet tud egyszerre kezelni
//
  MAXRES	                = 21;                             // Legfeljebb ennyi elemnek van hely
//
// Az egyes paneloknak sz�l� USB �zenet k�djai
//
  STATER	                =	1;                              // A st�tusz beolvas�sa
  AZOMOD	                =	2;                              // Az azonos�t� be�ll�t�sa
  AZOLEK                  = 3;                              // Az azonos�t�k lek�rdez�se
  AZOTUL                  = 4;                              // Az azonos�t� tulajdons�g lek�rdez�se
  LEDLRG                  = 5;                              // LED l�mpa sz�nbe�ll�t�s
  NYILRG                  = 6;                              // LED ny�l ir�ny �s sz�nbe�ll�t�s
  HANGIN	                = 7;                              // Hang ind�t�s
//
  FEL485	                =	29;                       			// RS485 vonali felm�r�s ind�t�s
//
  SFLASH                  =	30;                             // Flash �r�s adat
  KFLASH                  = 31;                             // Flash �r�s v�lasz
//
// V�laszk�dok
//
  FELMOK                  = 1;                              // A felm�r�s rendben lezajlott
  AZOOKE                  = 2;                              // Az azonos�t� v�lt�s rendben lezajlott
  FIRMUZ                  = 3;                              // F�rmvercsere inform�ci�s k�dja
  FIRMEN                  = 4;                              // F�rmvercsere v�ge, �jraind�t�s elndul
  LEDRGB                  = 5;                              // A LED l�mpa RGB �rt�ke
  NYIRGB                  = 6;                              // A ny�l RGB �s ir�ny �rt�ke
  HANGEL                  = 7;                              // A hangstring �llapota
  STATKV                  = 8;                              // A st�tusz �rt�ke
  LISVAL	                = 9;                              // A t�bl�zat v�g�nek a v�lasza

  USBREM                  = -1;                             // Az USB vez�rl� elt�vol�t�sra ker�lt
  VALTIO                  = -2;                             // Felm�r�s k�zben v�laszv�r�s time-out k�vetkezett be
  FELMHK                  = -3;                             // Felm�r�s v�ge hib�val
  FELMHD                  = -4;                             // Nincs egy darab sem hibak�d (elvben sem lehet ilyen)
  FELMDE                  = -5;                             // A 16 �s 64 bites darabsz�m nem egyforma (elvben sem lehet ilyen)

type
  VERTAR = packed record                                    // Verzi�t�rol� pl. 1.00 17/11/28 form�tumban
    versih: Byte;                                           // A szoftver verzi�j�nak els� tagja           0     1
    versil: Byte;                                           // A szoftver verzi�j�nak m�sodik tagja        1     1
    datume: Byte;                                           // A szoftver verzi� k�sz�t�s�nek �ve          2     1
    datumh: Byte;                                           // A szoftver verzi� k�sz�t�s�nek h�napja      3     1
    datumn: Byte;                                           // A szoftver verzi� k�sz�t�s�nek napja        4     1
  end;                                                      // Az eg�sz hossza                             5

  DEVSEL = packed record                                    // Az elemek azonos�t�s�nak le�r�ja
    azonos: Word;                                           // Az elem azonos�t�ja a bitp�rossal egy�tt    0     2
    idever: VERTAR;                                         // Az elem verzi�le�r�ja                       2     5
    produc: PChar;                                          // Az elem sz�veges le�r�ja                    7     4
    manufa: PChar;                                          // Az elem gy�rt�  le�r�ja                    11     4
  end;                                                      // Az eg�sz hossza                            15
  PDEVSEL = ^DEVSEL;

  DEVLIS = array of DEVSEL;
  PDEVLIS = ^DEVLIS;

  NEVTAR = array [0..(MAX_PATH - 1)] of Char;               // A DLL nev�nek �s hely�nek t�rol�ja

  DLLVER = packed record                                    // A DLL verzi�j�nak lei�r�ja
    versih: Dword;                                          // A DLL verzi�j�nak els� r�sze                0     4
    versil: Dword;                                          // A DLL verzi�j�nak m�sodik r�sze             4     4
    mianev: NEVTAR;                                         // A DLL neve �s helye                         8   MAX_PATH (260)
  end;                                                      // Az eg�sz hossza                            MAX_PATH + 8 = 268

  DLLNEV = array [0..1] of DLLVER;                          // Csak k�t DLL lesz haszn�lva
  PDLLNEV = ^DLLNEV;

  MERESE = packed record                                    // A proci bels� m�r�s�nek �rt�kei
    vddert: Word;                                           // A proci VDD m�rt �rt�ke VREF-el             0     2
    vdddrb: Byte;                                           // A VDD m�r�s darabsz�ma                      2     1
    tmpkul: Word;                                           // A proci h�m�rs�klete                        3     2
    tmpdrb: Byte;                                           // A h�m�rs�kletm�r�s darabsz�ma               5     1
  end;                                                      // Az eg�sz hossza                             6

  HABASZ = packed record                                    // Az RGB �sszetev�k le�r�sa
    rossze: Byte;                                           // Az R �sszetev� �rt�ke                       0     1
    gossze: Byte;                                           // A G �sszetev� �rt�ke                        1     1
    bossze: Byte;                                           // A B �sszetev� �rt�ke                        2     1
  end;                                                      // Az eg�sz hossza                             3

  DEVNUM  = array [0..(MAXRES - 1)] of Word;                // Azonos�t� t�rol�

  HANGLE = packed record                                    // Egy hang le�r�sa
    hangho: Word;                                           // A hang hossza milisec.-ben                  0     2
    hangso: Byte;                                           // A hang sorsz�ma (0..32)                     2     1
    hanger: Byte;                                           // A hang hangereje (0..63)                    3     1
  end;                                                      // Az eg�sz hossza                             4

  HANGLA = array [0..15] of HANGLE;                         // Hangle�r�k t�bl�zata
  PHANGL = ^HANGLA;                                         // A t�bl�zatra mutat� pointer

  LISELE = packed record                                    // Lista szerinti teend�k elemle�r�s
    azonos: Word;                                           // Az elem azonos�t�ja a bitp�rossal egy�tt    0     2
    case Integer of
      1:
      (
        lamrgb: HABASZ;                                     // A LED l�mpa RGB �rt�kei                     2     3
      );
      2:
      (
        nilrgb: HABASZ;                                     // A ny�l RGB �rt�kei                          2     3
        jobrai: BOOL;                                       // A ny�l ir�nya                               5     4
      );
      3:
      (
        handrb: Byte;                                       // A hang darabsz�ma                           2     1
        hantbp: PHANGL;                                     // A t�bl�zatra mutat� pointer                 3     4
      );
  end;                                                      // Az eg�sz hossza                             7

  LISTBL = array [0..99] of LISELE;
  PLISTB = ^LISTBL;

  VIDTAR = array [0..31] of WideChar;

  PUPGPCK = ^UPGPCK;
  UPGPCK = packed record
    packdb: Dword;                                          // A csomagok maximuma                         0     4
    aktdar: Dword;                                          // A csomagok sz�ml�l�ja                       4     4
    devazo: Word;                                           // A 485-�s eszk�z c�me                        8     2
    errcod: Byte;                                           // Az �zenet k�dja                            10     1
  end;                                                      // Az eg�sz hossza                            11

  ELSPUF = array [0..33] of Byte;
  PELSPUF = ^ELSPUF;
  MASPUF = array [0..32] of Byte;
  PMASPUF = ^MASPUF;

  PELVSTA = ^ELVSTA;
  ELVSTA = packed record
    merlam: MERESE;                                         // A proci m�rt �rt�kei                        0     6
    rgbert: HABASZ;                                         // Az aktu�lis sz�n�sszetev�k �rt�ke           6     3
    nyilal: Byte;                                           // A ny�l ir�nya                               9     1
    hanakt: Byte;                                           // A hang �llapota                            10     1
  end;                                                      // Az eg�sz hossza                            11

  pUSB_buf = ^USB_buf;
  USB_buf = packed record
    reportID: Byte;                                         // For HID (not used, always 0)                0     1
    tipus: Byte;                                            // Az �zenet t�pusk�dja                        1     1
    counter: Byte;                                          // Az �zenet sz�ml�l�ja                        2     1
    address: Word;                                          // Az �zenet c�mtartalma                       3     2
    case Integer of
      1:
      (
        pufbel: array [0..63] of Byte;                      // Az �zenet b�jtos t�rol�ban                  5    64
      );
      2:
      (
        statta: ELVSTA;                                     // A st�tusz �llapota                          5    11
        felmnu: Byte;                                       // A felm�r�s �llapotsz�ma                    16     1
        darkby: Byte;                                       // A felm�r�s szerinti 16 bitesek sz�ma       17     1
        darnby: Byte;                                       // A felm�r�s szerinti 64 bitesek sz�ma       18     1
        felmhi: Byte;                                       // A felm�r�s hibak�dja                       19     1
        felmcn: Byte;                                       // A felm�r�s hiba sz�ml�l� �rt�ke            20     1
        felmel: Byte;                                       // A felm�r�s hiba elt�r�ssz�ml�l�ja          21     1
        esuadr: Word;                                       // Az aktu�lis azonos�t�                      22     2
      );
      3:
      (
        gepkou: Word;                                       // A be�ll�tand� g�pk�d                        5     2
      );
      4:
      (
        ledszb: HABASZ;                                     // A sz�n�sszetev�k �rt�kei                    5     3
        lednir: Byte;                                       // Az ir�ny �rt�ke                             8     1
      );
      5:
      (
        hanlis: DEVNUM;                                     // Ez a megtal�lt elemek azonos�t�ja           5    42
      );
      6:
      (
        kulver: VERTAR;                                     // Ez a verzi� v�lasz                          5     5
      );
      7:
      (
        kuluni: VIDTAR;                                     // A karakteres le�r� v�lasz                   5    64
      );
      8:
      (
        hangtb: HANGLA;                                     // A lej�tszand� hanglista                     5    64
      );
      9:
      (
        pufels: ELSPUF;                                     // A k�dfriss�t�s els� puferr�sze               5    34
      );
      10:
      (
        pufmas: MASPUF;                                     // A k�dfriss�t�s m�sodik puferr�sze            5    33
      );
  end;                                                      // Az eg�sz hossza                            69

var
  aktadr: Word;                                               // Az aktu�lis c�m
  drb485: Dword;                                              // Az RS 485 eszk�z�k mennyis�ge
  diruze: Dword;                                              // Direkt �zenet sz�ml�l�
  pwndfu: TFNWndProc = NIL;                                   // A procedurac�m t�rol�ja
  msghnd: THandle;                                            // MSG handle
  msgkod: Dword;                                              // MSG k�d
  devusb: DEVSEL;                                             // Az USB eszk�z le�r�ja
  dllpar: DLLNEV;                                             // A k�t DLL param�terei
  felhnd: THandle;                                            // Felm�r�s Thread handle
  sajpuf: USB_buf;                                            // A saj�t pufferem
  varuze: THandle;                                            // Esem�nyre v�rakoz�s
  locpuf: pUSB_buf;                                           // A vett puffer pointere
  dev485: DEVLIS;                                             // A le�r�k c�me
  upglei: PUPGPCK;                                            // A friss�t�s le�r�ja
  timtar: Uint;                                               // Timer azonos�t�
  belmax: Integer;                                            // A lista darabsz�ma
  belakt: Integer;                                            // A lista aktu�lis �rt�ke
  belpoi: PLISTB;                                             // A lista pointere
  belfut: Boolean;                                            // A lista aktu�lis �llapota


// A DLL haszn�latbav�tel�nek ind�t�sa
function  SLDLL_Open(wndhnd, msgert: Dword; mianev: PDLLNEV; devata: PDEVSEL): Dword; stdcall; Assembler; Forward;
// Az el�rhet� eszk�z�k felm�r�s�nek ind�t�sa
function SLDLL_Felmeres: Dword; Assembler; Forward;
// A t�bl�zat �tad�sa
function SLDLL_Listelem(devata: PDEVLIS): Dword; stdcall; Assembler; Forward;
// Az azonos�t� v�lt�s�nak k�r�se
function SLDLL_AzonositoCsereInditas(amitva, amirev: Word): Dword; stdcall; Assembler; Forward;
// A k�d fel�l�r�s elind�t�sa
function SLLDLL_Upgrade(filnam: PChar; var drbkod: Dword; amitir: Word): Dword; stdcall; Assembler; Forward;
// A LED l�mpa RGB �rt�keinek friss�t�se
function SLLDLL_LEDLampa(rgbert: HABASZ; amital: Word): Dword; stdcall; Assembler; Forward;
// A LED ny�l RGB �rt�keinek �s ir�ny�nak friss�t�se
function SLLDLL_LEDNyil(rgbert: HABASZ; jobrai: BOOL; amital: Word): Dword; stdcall; Assembler; Forward;
// Hangstring lej�tsz�s ind�t�sa
function SLLDLL_Hangkuldes(hangho: Integer;const amitku: HANGLA; amital: Word): Dword; stdcall; Assembler; Forward;
// St�tuszbeolvas�s ind�t�s
function SLDLL_GetStatus(amitke: Word): Dword; stdcall; Assembler; Forward
// St�tuszbeolvas�s ind�t�s
function SLDLL_SetLista(hanydb: Integer; const tblveg:LISTBL): Dword; stdcall; Assembler; Forward
// Az id�z�t� "kettyen�si" rutinja
procedure statim(hwnd: THandle; uMsg: Uint; idEvent: Uint; dwTime: Dword); stdcall; Assembler; Forward;
// A DLL verzi�j�nak lek�rdez�se
function  verdll(var versms, versls: Dword; dllnam: PChar; namlen: Dword): Dword; stdcall; Assembler; Forward;
// A lok�lis window elj�r�sa
function  wndprc(Window: HWND; Message, wParam, lParam: Dword): Dword; stdcall; Assembler; Forward;
// A felm�r�st v�grehajt� Thread
function  feldev(vakvan: Pointer): Dword; stdcall; Assembler; Forward;
// Az azonos�t� v�ltoztat�st v�gz� Thread
function chgazo(parrom: Dword): Dword; stdcall; Assembler; Forward;
// Az unik�dos jellemz� �talak�t�sa norm�l karakterre
procedure jelkit(var erechr: PChar; const mibol: USBTUL); stdcall; Assembler; Forward;
// AL �s AH (mindkett�) BCD-r�l bin�risra alak�t�s
procedure bcdtob(mitala: Word); Assembler; Forward;
// A friss�t�s soron k�vetkez� rekordj�nak ind�t�sa
procedure indpck; stdcall; Assembler; Forward;
// Azonos�t� (AX) vizsg�lata l�tez�sre �s �rv�nyess�gre (CX)
procedure ervazo; Assembler; Forward;
// A megtal�lt elemek rendez�se azonos�t�juk szerint
procedure quicksort(bal, jobb: Integer); stdcall; Assembler; Forward;
// Az eszk�zle�r�ban foglaltak �s a le�r� felszabad�t�s
procedure eszrem; stdcall; Assembler; Forward;
// Bels� v�grehajt�s
function belkoi: Dword; stdcall; Assembler; Forward;

const
  SIZDNE                  = SizeOf(DLLVER);                 // A DLL param�tert�rol� hossza
  SIZAPU                  = SizeOf(DEVSEL);                 // A jellemz� puffer hossza
  SIZUPG                  = SizeOf(UPGPCK);                 // Az upgrade le�r� hossza
  SIZHTB                  = SizeOf(HANGLE);                 // Egy hangelem hossza
  SIZBEL                  = SizeOf(LISELE);                 // Egy listaelem hossza
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A DLL haszn�lat�nak megkezd�se.                                                  //
//                                                                                  //
//  Param�terek:                                                                    //
//                (in)  wndhnd      A haszn�lat esem�nyeinek �zenet�t fogad�        //
//                                  handle (handle of destination window)           //
//                (in)  msgert      A be�rkez� (v�lasz) pufferekr�l t�j�koztat�     //
//                                  �zenet k�dja (message code)                     //
//                (in-out) mianev   A DLL verzi�t�bl�zat c�me                       //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    Sikeresen kapcsol�dott a jelen        //
//                                            l�v� eszk�z�kh�z                      //
//                ERROR_ALREADY_INITIALIZED   A rutin m�r haszn�latba vette         //
//                                            (kor�bban) az eszk�z�ket              //
//                ERROR_FUNCTION_NOT_CALLED   Nincs USB-s eszk�z                    //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  SLDLL_Open(wndhnd, msgert: Dword; mianev: PDLLNEV; devata: PDEVSEL): Dword; stdcall; Assembler;
var
  tullei: USBTUL;
asm
    push  esi                           // Elrontom
    mov   eax,ERROR_ALREADY_INITIALIZED // Hibak�d
    mov   edx,[pwndfu]                  // WNDProc �rt�ke
    or    edx,edx                       // Volt m�r?
    jnz   @elmarv                       // Igen, volt m�r
//
// �tm�solom a h�v�s param�tereit
//
    mov   eax,wndhnd                    // Ez a(z) "wndhnd" param�ter
    mov   edx,msgert                    // Ez a(z) "msgert" param�ter
    mov   [msghnd],eax                  // Ez lesz az �zenet handle
    mov   [msgkod],edx                  // Ez lesz az �zenet k�dja
//
// A window l�ncra felkapcsolom a DLL-t is
//
    push  offset wndprc                 // SetWindowLong 3. param�ter
    push  GWL_WNDPROC                   // SetWindowLong 2. param�ter
    push  eax                           // SetWindowLong 1. param�ter
    call  SetWindowLong                 // WND proc. bel�p�pont k�sz�t�s
    or    eax,eax                       // St�tusz ki�rt�kel�s
    jnz   @getako                       // Sikeresen kialak�tottam
  @hibret:
    call  GetLastError                  // A hibak�ddal t�rek vissza
    jmp   @elmarv                       // Mehet vissza
  @getako:
    mov   [pwndfu],eax                  // WNDProc �j �rt�ke
//
// Elind�tom az �zenetk�ld�st
//
    push  PRODUCT_ID                    // UsbHidOpen 3. param�ter, az USB azonos�t�
    push  [msgkod]                      // UsbHidOpen 2. param�ter, az �zenetsz�m
    push  [msghnd]                      // UsbHidOpen 1. param�ter, az �zenet Window Handle �rt�ke
    call  UsbHidOpen                    // Csatlakozom az eszk�zh�z
    or    eax,eax                       // Sikeres volt?
    jnz   @elmarv                       // Nem siker�lt megnyitni, hibak�ddal visszat�rek
    mov   esi,offset dllpar             // A puffer c�me
    mov   edx,mianev                    // A v�lasz helye
    or    edx,edx                       // NIL a param�ter?
    jz    @akneto                       // Igen, akkor nem t�lt�m ki
    mov   [edx],esi                     // A le�r� c�m�t �tadom
  @akneto:
    lea   eax,[esi + DLLVER.mianev]     // A n�v helye
    lea   edx,[esi + DLLVER.versih]     // A verzi� egyik elem�nek c�me
    lea   ecx,[esi + DLLVER.versil]     // A verzi� m�sik elem�nek c�me
    push  MAX_PATH                      // UsbGetDLLVersion 4. param�ter, pufferm�ret
    push  eax                           // UsbGetDLLVersion 3. param�ter, a puffer c�me
    push  edx                           // UsbGetDLLVersion 2. param�ter, a verzi� elem�nek c�me
    push  ecx                           // UsbGetDLLVersion 1. param�ter, a verzi� elem�nek c�me
    call  UsbGetDLLVersion              // Beolvasom a HID_KER_USB.DLL verzi�j�t
    or    eax,eax                       // Sikeres volt?
    jnz   @hibret                       // Nem, hib�val vissza
    mov   edx,[esi + DLLVER.versil]     // Ez �rdekel
    and   [esi + DLLVER.versil],$ffff   // Csak az als� r�sz marad
    shr   edx,16                        // A fels� r�sz alulra
    mov   [esi + DLLVER.versih],edx     // A verzi� m�sik elemr�sze
    lea   esi,[esi + SIZDNE]            // A m�sik elem c�me
    lea   eax,[esi + DLLVER.mianev]     // A n�v helye
    lea   edx,[esi + DLLVER.versih]     // A verzi� egyik elem�nek c�me
    lea   ecx,[esi + DLLVER.versil]     // A verzi� m�sik elem�nek c�me
    push  MAX_PATH                      // verdll 4. param�ter, pufferm�ret
    push  eax                           // verdll 3. param�ter, a puffer c�me
    push  edx                           // verdll 2. param�ter, a verzi� elem�nek c�me
    push  ecx                           // verdll 1. param�ter, a verzi� elem�nek c�me
    call  verdll                        // Beolvasom a SLDLL.DLL verzi�j�t
    or    eax,eax                       // Sikeres volt?
    jnz   @hibret                       // Nem, hib�val vissza
    mov   edx,[esi + DLLVER.versil]     // Ez �rdekel
    and   [esi + DLLVER.versil],$ffff   // Csak az als� r�sz marad
    shr   edx,16                        // A fels� r�sz alulra
    mov   [esi + DLLVER.versih],edx     // A verzi� m�sik elemr�sze
    call  UsbGetNumdev                  // Megn�zem, hogy van-e nekem sz�nt eszk�z
    or    eax,eax                       // Nulla?
    jnz   @vanusb                       // Nem, van eszk�z
    mov   eax,ERROR_FUNCTION_NOT_CALLED // Ha nincs USB eszk�z, ez a hibak�dom
    jmp   @elmarv                       // Hibak�ddal vissza
  @vanusb:
    lea   esi,tullei                    // A kit�ltend�k c�me
    push  False                         // UsbHidGetProperty 3. param�ter, hexa �rt�ket v�rok
    push  esi                           // UsbHidGetProperty 2. param�ter, a t�bl�zat c�me
    push  0                             // UsbHidGetProperty 1. param�ter, az eszk�z sorsz�ma
    call  UsbHidGetProperty             // Beolvasom a param�tereket
    or    eax,eax                       // Volt hiba?
    jnz   @elmarv                       // Igen, a hibak�ddal visszat�rek
    mov   eax,devata                    // Itt adom �t
    mov   edx,offset devusb             // Ez a param�ter c�mt�rol�ja
    mov   [eax],edx                     // �tadtam a le�r� c�m�t
    lea   ecx,[esi + USBTUL.USB_Product_Number]// Innen olvasom be
    mov   ax,[ecx]                      // Az azonos�t�
    lea   ecx,[edx + DEVSEL.azonos]     // Ide kell tenni
    mov   [ecx],ax                      // �tm�soltam
    lea   ecx,[esi + USBTUL.USB_Product_Versio_H]// Innen olvasom be
    mov   ax,[ecx]                      // A verzi�p�ros
    lea   ecx,[edx + DEVSEL.idever.VERTAR.versih]// Ide kell tenni
    call  bcdtob                        // BCD-r�l bin�risra alak�tom az AL-t �s az AH-t
    mov   [ecx],ax                      // �tm�soltam
    lea   ecx,[esi + USBTUL.USB_Product_Year]// Innen olvasom be
    movzx eax,word ptr [ecx]            // Az azonos�t�
    mov   cl,100                        // Lev�lasztom az �v als� k�t �rt�ke�t
    div   cl                            // Elosztottam (AH <- marad�k, AL <- h�nyados
    lea   ecx,[edx + DEVSEL.idever.VERTAR.datume]// Ide kell tenni
    call  bcdtob                        // BCD-r�l bin�risra alak�tom az AL-t �s az AH-t
    mov   [ecx],ah                      // �tm�soltam
    lea   ecx,[esi + USBTUL.USB_Product_Month]// Innen olvasom be
    mov   ax,[ecx]                      // A h�nap �s nap p�ros
    lea   ecx,[edx + DEVSEL.idever.VERTAR.datumh]// Ide kell tenni
    call  bcdtob                        // BCD-r�l bin�risra alak�tom az AL-t �s az AH-t
    mov   [ecx],ax                      // �tm�soltam
    lea   ecx,[esi + USBTUL.USB_Product]// Innen olvasom be
    lea   eax,[edx + DEVSEL.produc]     // Ide kell tenni
    lea   esi,[esi + USBTUL.USB_Manufacturer]// Innen olvasom be
    lea   edx,[edx + DEVSEL.manufa]     // Ide kell tenni
    push  ecx                           // Jelkit 2. param�ter, amit konvert�lni kell
    push  eax                           // Jelkit 1. param�ter, ahova a jellemz� ker�l
    push  esi                           // Jelkit 2. param�ter, amit konvert�lni kell
    push  edx                           // Jelkit 1. param�ter, ahova a jellemz� ker�l
    call  jelkit                        // �talak�tom �s kit�lt�m a jellemz�t
    call  jelkit                        // �talak�tom �s kit�lt�m a jellemz�t
//
// A keres� thread-nek maxim�lis priorit�st adok
//
    xor   eax,eax                       // Visszat�r�s NO_ERROR �rt�kkel
    mov   [belfut],al                   // Nem fut v�grehajt�s
  @elmarv:
    pop   esi                           // Vissza a rontott
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A DLL �ltal el�rhet� eszk�z�k felm�r�s�nek ind�t�sa.                            //
//                                                                                  //
//  Param�ter:                                                                      //
//                Nincs                                                             //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    A c�m sikeresenn �tad�sra ker�lt      //
//                ERROR_DLL_INIT_FAILED       A DLL m�g nem volt elind�tva          //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLDLL_Felmeres: Dword; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibak�d
    mov   edx,[pwndfu]                  // WNDProc �rt�ke
    or    edx,edx                       // Volt m�r?
    jz    @hibret                       // Visszat�rek hibajellel
    call  eszrem                        // Elt�vol�tom az eszk�zle�r�kat
    xor   eax,eax                       // Null�zok
    push  eax                           // CreateThread 6. param�ter
    push  eax                           // CreateThread 5. param�ter
    push  eax                           // CreateThread 4. param�ter, a param�ter c�me (nincs)
    push  offset feldev                 // CreateThread 3. param�ter, a thread k�dj�nak c�me
    push  eax                           // CreateThread 2. param�ter
    push  eax                           // CreateThread 1. param�ter
    push  eax                           // CreateEvent 4. param�ter, nincs neve
    push  eax                           // CreateEvent 3. param�ter, nincs jelezve alapban
    push  1                             // CreateEvent 2. param�ter, k�zzel piszk�lom
    push  eax                           // CreateEvent 1. param�ter, nincs Security Attributes
    call  CreateEvent                   // V�rakoz�si handle k�sz�t�s
    mov   [varuze],eax                  // Erre fogok v�rakozni
    call  CreateThread                  // Elk�sz�tem a felm�r�st v�grehajt� Thread-et
    or    eax,eax                       // Sikeres volt?
    jz    @hibget                       // Nem, hib�val vissza
    mov   [felhnd],eax                  // Thread handle kit�ltve
//
// A keres� thread-nek maxim�lis priorit�st adok
//
    push  THREAD_PRIORITY_TIME_CRITICAL // SetThreadPriority 2. param�ter
    push  eax                           // SetThreadPriority 1. param�ter
    call  SetThreadPriority             // Megemelem a priorit�s�t
    or    eax,eax                       // Sikeres volt?
    jnz   @retsik                       // Igen, visszat�rhetek
  @hibget:
    call  GetLastError                  // Beolvasom a hiba k�dj�t
    jmp   @hibret                       // Visszat�rek a hiba k�dj�val
  @retsik:
    xor   eax,eax                       // Sikeres visszat�r�s jelz�se NO_ERROR k�ddal
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  Az eszk�zlista c�m�nek bek�r�se.                                                //
//                                                                                  //
//  Param�ter:                                                                      //
//                (out) devata      A t�bl�zat c�m�nek m�solata                     //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    A c�m sikeresenn �tad�sra ker�lt      //
//                ERROR_DLL_INIT_FAILED       A DLL m�g nem volt elind�tva          //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLDLL_Listelem(devata: PDevlis): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibak�d
    mov   edx,[pwndfu]                  // WNDProc �rt�ke
    or    edx,edx                       // Volt m�r?
    jz    @hibret                       // Visszat�rek hibajellel
    mov   edx,devata                    // A param�ter
    mov   ecx,dev485                    // Kit�lt�m
    mov   [edx],ecx                     // Kit�lt�m
    xor   eax,eax                       // Sikeres visszat�r�s jelz�se NO_ERROR k�ddal
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  Az azonos�t� megv�ltoztat�s�nak k�r�se.                                         //
//                                                                                  //
//  Param�terek:                                                                    //
//                (in)  amitva      Az azonos�t�t v�ltozat� panel azonos�t�ja       //
//                (in)  amirev      Az �j azonos�t� �rt�ke                          //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    A v�ltoztat�s sikeresen elindult      //
//                ERROR_DLL_INIT_FAILED       A DLL m�g nem volt elind�tva          //
//                ERROR_ALREADY_ASSIGNED      Az �j azonos�t� jelenleg m�s panel    //
//                                            azonos�t�ja, k�t egyforma nem lehet.  //
//                ERROR_INVALID_DATA          Az azonos�t� �rt�ke 0, vagy nincs     //
//                                            t�pusjel�l� bitp�rosa.                //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLDLL_AzonositoCsereInditas(amitva, amirev: Word): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibak�d
    mov   edx,[pwndfu]                  // WNDProc �rt�ke
    or    edx,edx                       // Volt m�r?
    jz    @hibret                       // Visszat�rek hibajellel
    xor   ecx,ecx                       // Nincs el�tag vizsg�lat
    mov   ax,amirev                     // Erre v�ltoztatna
    test  ax,$c000                      // A legfels� k�t bit l�tezik?
    jz    @marane                       // Nincs, akkor nem j� az �rt�ke
    test  ax,$3ff                       // Az azonos�t� nulla?
    jnz   @kovhas                       // Nem, akkor mehetek keresni
//
// Vagy hib�s az azonos�t�, vagy m�r van olyan
//
  @marane:
    mov   eax,ERROR_INVALID_DATA        // Hibak�d
    jmp   @hibret                       // Nincs ez a k�t bit, kil�pek hibak�ddal
  @kovhas:
    call  ervazo                        // Azonos�t� lek�rdez�s
    jz    @marane                       // Van m�r ilyen, pedig nem lehet k�t egyforma
//
// Nincs olyan amire v�ltoztatni akar
//
    mov   ax,amitva                     // Ezt v�ltoztatn�m
    call  ervazo                        // Azonos�t� lek�rdez�s
    jnz   @marane                       // Nincs ilyen, hib�s az azonos�t�
//
// Avn olyan, amit megv�ltoztatna, megn�zem a t�pusazonoss�got
//
    mov   ax,amirev                     // Erre v�ltoztatna
    xor   ax,amitva                     // A k�l�nbs�gek
    and   ax,$c000                      // A legfels� bitp�ros egyforma?
    jnz   @marane                       // nem egyform�k, m�sra nem lehet v�ltoztatni
    mov   cx,amirev                     // Erre v�ltoztatna
    shl   ecx,16                        // A fels� r�szre teszem
    mov   cx,amitva                     // Ezt v�ltoztatom
    xor   eax,eax                       // Null�zok
    push  eax                           // CreateThread 6. param�ter
    push  eax                           // CreateThread 5. param�ter
    push  ecx                           // CreateThread 4. param�ter, a param�ter maga
    push  offset chgazo                 // CreateThread 3. param�ter, a thread k�dj�nak c�me
    push  eax                           // CreateThread 2. param�ter
    push  eax                           // CreateThread 1. param�ter
    push  eax                           // CreateEvent 4. param�ter, nincs neve
    push  eax                           // CreateEvent 3. param�ter, nincs jelezve alapban
    push  1                             // CreateEvent 2. param�ter, k�zzel piszk�lom
    push  eax                           // CreateEvent 1. param�ter, nincs Security Attributes
    call  CreateEvent                   // V�rakoz�si handle k�sz�t�s
    mov   [varuze],eax                  // Erre fogok v�rakozni
    call  CreateThread                  // Elk�sz�tem a felm�r�st v�grehajt� Thread-et
    or    eax,eax                       // Sikeres volt?
    jz    @hibava                       // Nem, hib�val vissza
    mov   [felhnd],eax                  // Thread handle kit�ltve
//
// A Thread-nek maxim�lis priorit�st adok
//
    push  THREAD_PRIORITY_TIME_CRITICAL // SetThreadPriority 2. param�ter
    push  eax                           // SetThreadPriority 1. param�ter
    call  SetThreadPriority             // Megemelem a priorit�s�t
    or    eax,eax                       // Sikeres volt?
    jnz   @rendav                       // Igen, sikeres volt
  @hibava:
    call  GetLastError                  // Beolvasom a hibak�dot
    jmp   @hibret                       // Hibak�ddal vissza
  @rendav:
    xor   eax,eax                       // NO_ERROR k�ddal jelzem, hogy sikeres volt
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A f�rmver friss�t�s ind�t�sa.                                                   //
//                                                                                  //
//  Param�terek:                                                                    //
//                (in)  filnam      A friss�t�sre haszn�land� f�jl neve             //
//                (out) msgert      Sikeres h�v�s eset�n a friss�t�si csomagok      //
//                                  sz�ma, egy�bk�nt a hib�hoz tartoz� �rt�k        //
//                                  �zenet k�dja (message code)                     //
//                (in)  amitir      A friss�tend� panel azonos�t�ja                 //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    A friss�t�s sikeresen elindult        //
//                ERROR_DLL_INIT_FAILED       A DLL m�g nem volt elind�tva          //
//                ERROR_OPEN_FAILED           A megadott f�jlt nem siker�lt         //
//                                            megnyitni                             //
//                ERROR_MOD_NOT_FOUND         A megadott f�jl nem f�rmver           //
//                                            friss�t�si adatokat tartalmaz         //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLLDLL_Upgrade(filnam: PChar; var drbkod: Dword; amitir: Word): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibak�d
    mov   edx,[pwndfu]                  // WNDProc �rt�ke
    or    edx,edx                       // Volt m�r?
    jz    @hibret                       // Visszat�rek hibajellel
    mov   ax,amitir                     // Az el�tag
    xor   ecx,ecx                       // Nincs el�tag vizsg�lat
    call  ervazo                        // Azonos�t� lek�rdez�s
    jnz   @hibret                       // Hib�s az azonos�t�
    push  ebx                           // Elrontom
    push  esi                           // Elrontom
    xor   eax,eax                       // Null�zok
    push  eax                           // CreateFile 7. param�ter, nincs Overlapped elem
    push  FILE_ATTRIBUTE_NORMAL         // CreateFile 6. param�ter, norm�l f�jl
    push  OPEN_EXISTING                 // CreateFile 5. param�ter, megnyit�si m�d
    push  eax                           // CreateFile 4. param�ter, nincs Security m�d
    push  FILE_SHARE_READ               // CreateFile 3. param�ter, a tov�bbiak ezt tehetik meg
    push  GENERIC_READ                  // CreateFile 2. param�ter, csak olvasni akarom
    push  filnam                        // CreateFile 1. param�ter, a f�jl neve
    call  CreateFile                    // Megnyitom, vagy legal�bbis megpr�b�lom
    mov   ebx,eax                       // �tm�solom
    inc   eax                           // Siker�lt megnyitni? (INVALID_HANDLE_VALUE + 1 = 0)
    jz    @openes                       // Nem siker�lt
    xor   eax,eax                       // Null�zok
    xchg  eax,[upglei]                  // A le�r� �rt�k�nek beolvas�sa
    or    eax,eax                       // Volt el�z� �rt�ke?
    jz    @eloern                       // Nem volt el�z� �rt�ke
    push  eax                           // GloablFree 1. param�ter, a puffer c�me
    call  GlobalFree                    // Eldobom az el�z� puffert
  @eloern:
    push  0                             // GetFileSize 2. param�ter, a magasab 32 bit c�me
    push  ebx                           // GetFileSize 1. param�ter, a f�jl Handle �rt�ke
    call  GetFileSize                   // Beolvasom a hosszt
    mov   esi,eax                       // M�solat a hosszr�l
    xor   edx,edx                       // A magas r�szt null�ztam, mert oszt�sra k�sz�l�k
    mov   ecx,67                        // A rekordhossz
    div   ecx                           // EAX <- h�nyados, EDX <- marad�k
    or    edx,edx                       // A marad�k nulla?
    jnz   @fihopo                       // Nem, ez f�jl hossz probl�m�t vet�t el�re
    test  eax,111b                      // 8-al oszthat�?
    jnz   @fihopo                       // Nem, ez f�jl hossz probl�m�t vet�t el�re
    mov   edx,drbkod                    // A v�lasz c�me
    mov   [edx],eax                     // �tadom a hibak�d hely�re
    push  eax                           // K�s�bbre a rekordsz�m
    lea   eax,[esi + SIZUPG]            // A foglaland� hossz
    push  eax                           // GlobalAlloc 2. param�ter, a foglaland� hossz
    push  GMEM_FIXED OR GMEM_ZEROINIT   // GlobalAlloc 1. param�ter, a foglal�s m�dja
    call  GlobalAlloc                   // Lefoglalom a puffert
    mov   [upglei],eax                  // Kit�lt�m a c�mmel
    pop   edx                           // Rekordsz�m vissza
    mov   [eax + UPGPCK.packdb],edx     // Rekordsz�m kit�lt�s
    mov   dx,amitir                     // Az azonos�t� amit m�dos�tok
    mov   [eax + UPGPCK.devazo],dx      // Azonos�t� kit�lt�s
    lea   ecx,[eax + SIZUPG]            // Ez a f�jlpuffer c�me
    push  eax                           // Hely a stackben
    mov   eax,esp                       // A hely c�me
    xor   edx,edx
    push  edx                           // ReadFile 5. param�ter, Overlapped m�velet nincs
    push  eax                           // ReadFile 4. param�ter, a v�lasz c�me
    push  esi                           // ReadFile 3. param�ter, a beolvas�s hossza
    push  ecx                           // ReadFile 2. param�ter, a puffer c�me
    push  ebx                           // ReadFile 1. param�ter, a f�jl Handle �rt�ke
    call  ReadFile                      // Beolvasom a f�jlt
    pop   eax                           // Eldobom a v�lasz hossz�t
    push  ebx                           // CloseHandle 1. param�ter
    call  CloseHandle                   // Lez�rom
    call  indpck                        // Elind�tom a friss�t�s menet�t
    xor   eax,eax                       // NO_ERROR k�ddal l�pek ki
    jmp   @befkil                       // Befejem
  @fihopo:
    push  ebx                           // CloseHandle 1. param�ter
    call  CloseHandle                   // Lez�rom
    mov   eax,ERROR_FILE_INVALID        // Kil�p�si hibak�d
    mov   edx,drbkod                    // A v�lasz c�me
    mov   [edx],eax                     // �tadom a hibak�d hely�re
    jmp   @befkil                       // Befejem
  @openes:
    call  GetLastError                  // Beolvasom a hibak�dot
    mov   edx,drbkod                    // A v�lasz c�me
    mov   [edx],eax                     // �tadom a hibak�d hely�re
    mov   eax,ERROR_OPEN_FAILED         // Kil�p�si hibak�d
  @befkil:
    pop   esi                           // Rontott vissza
    pop   ebx                           // Rontott vissza
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A LED l�mpa RGB �sszetev�inek be�ll�t�sa.                                       //
//                                                                                  //
//  Param�terek:                                                                    //
//                (in)  rgbert      A be�ll�tand� RGB �rt�kek t�bl�zata             //
//                (in)  amital      A be�ll�tand� LED-l�mpa azonos�t�ja             //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    A be�ll�t�s sikeresen elindult        //
//                ERROR_DLL_INIT_FAILED       A DLL m�g nem volt elind�tva          //
//                ERROR_INVALID_DATA          Az azonos�t� t�pusjel�l� bitp�rosa    //
//                                            nem "SLLELO" �rt�k, azaz nem          //
//                                            LED l�mpa panel ker�l megsz�l�t�sra   //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLLDLL_LEDLampa(rgbert: HABASZ; amital: Word): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibak�d
    mov   edx,[pwndfu]                  // WNDProc �rt�ke
    or    edx,edx                       // Volt m�r?
    jz    @hibret                       // Visszat�rek hibajellel
    mov   ax,amital                     // Ezt k�ldte
    mov   ecx,SLLELO                    // A k�v�nt el�tag
    call  ervazo                        // Azonos�t� lek�rdez�s
    jnz   @hibret                       // Hib�s az azonos�t�
    mov   edx,offset sajpuf             // Az �zenet puffere
    mov   cx,amital                     // Ezt k�ldte
    mov   [edx + USB_buf.address],cx    // Ezt kell megv�ltoztatni
    mov   [edx + USB_buf.tipus],LEDLRG  // A k�r�s k�dja
    mov   eax,Dword ptr rgbert          // Az RGB param�ter
    mov   dword ptr [edx + USB_buf.ledszb],eax// �tadom az RGB �rt�keket
    push  edx                           // UsbHidWrite 2. param�ter, a puffer c�me
    push  0                             // UsbHidWrite 1. param�ter, az eszk�z sorsz�ma
    call  UsbHidWrite                   // Elind�tom a LED l�mpa be�ll�t�st
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A LED ny�l RGB �sszetev�inek �s ir�ny�nak be�ll�t�sa.                           //
//                                                                                  //
//  Param�terek:                                                                    //
//                (in)  rgbert      A be�ll�tand� RGB �rt�kek t�bl�zata             //
//                (in)  jobrai      A be�ll�tand� ir�ny (jobbra = True)             //
//                (in)  amital      A be�ll�tand� LED ny�l azonos�t�ja              //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    A be�ll�t�s sikeresen elindult        //
//                ERROR_DLL_INIT_FAILED       A DLL m�g nem volt elind�tva          //
//                ERROR_INVALID_DATA          Az azonos�t� t�pusjel�l� bitp�rosa    //
//                                            nem "SLNELO" �rt�k, azaz nem          //
//                                            LED ny�l panel ker�l megsz�l�t�sra    //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLLDLL_LEDNyil(rgbert: HABASZ; jobrai: BOOL; amital: Word): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibak�d
    mov   edx,[pwndfu]                  // WNDProc �rt�ke
    or    edx,edx                       // Volt m�r?
    jz    @hibret                       // Visszat�rek hibajellel
    mov   ax,amital                     // Ezt k�ldte
    mov   ecx,SLNELO                    // A k�v�nt el�tag
    call  ervazo                        // Azonos�t� lek�rdez�s
    jnz   @hibret                       // Hib�s az azonos�t�
    mov   edx,offset sajpuf             // Az �zenet puffere
    mov   cx,amital                     // Ezt k�ldte
    mov   [edx + USB_buf.address],cx    // Ezt kell megv�ltoztatni
    mov   [edx + USB_buf.tipus],NYILRG  // A k�r�s k�dja
    mov   eax,Dword ptr rgbert          // Az RGB param�ter
    mov   dword ptr [edx + USB_buf.ledszb],eax// �tadom az RGB �rt�keket
    mov   eax,jobrai                    // Az ir�ny
    or    eax,eax                       // False?
    jz    @marafa                       // Igen, az is marad
    mov   al,1                          // Legyen True
  @marafa:
    mov   [edx + USB_buf.lednir],al     // �tadom az ir�ny �rt�keket
    push  edx                           // UsbHidWrite 2. param�ter, a puffer c�me
    push  0                             // UsbHidWrite 1. param�ter, az eszk�z sorsz�ma
    call  UsbHidWrite                   // Elind�tom a LED ny�l be�ll�t�st
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  Hangstring lej�tsz�s ind�t�sa.                                                  //
//                                                                                  //
//  Param�terek:                                                                    //
//                (in)  hangho      A hangt�bl�zat lej�tszand� elemeinek sz�ma      //
//                (in)  amitku      A lej�tszand� hangok t�bl�zata                  //
//                (in)  amital      A hnagsz�r� panel azonos�t�ja                   //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    A be�ll�t�s sikeresen elindult        //
//                ERROR_DLL_INIT_FAILED       A DLL m�g nem volt elind�tva          //
//                ERROR_INVALID_DATA          Az azonos�t� t�pusjel�l� bitp�rosa    //
//                                            nem "SLHELO" �rt�k, azaz nem          //
//                                            hangsz�r� panel lett megsz�l�tva      //
//                ERROR_BAD_LENGTH            A hanghossz 0, vagy nagyobb mint 16   //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLLDLL_Hangkuldes(hangho: Integer;const amitku: HANGLA; amital: Word): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibak�d
    mov   edx,[pwndfu]                  // WNDProc �rt�ke
    or    edx,edx                       // Volt m�r?
    jz    @hibret                       // Visszat�rek hibajellel
    mov   ax,amital                     // Ezt k�ldte
    mov   ecx,SLHELO                    // A k�v�nt el�tag
    call  ervazo                        // Azonos�t� lek�rdez�s
    jnz   @hibret                       // Hib�s az azonos�t�
    mov   edx,offset sajpuf             // Az �zenet puffere
    mov   cx,amital                     // Ezt k�ldte
    mov   [edx + USB_buf.address],cx    // Ezt kell megv�ltoztatni
    mov   eax,ERROR_BAD_LENGTH          // Hibak�d
    mov   ecx,hangho                    // Ennyi hangelemet tartalmaz at�bl�zat
    or    ecx,ecx                       // Nulla az elemsz�m?
    jz    @hibret                       // Nem lehet nulla a hossz
    cmp   ecx,16                        // Enn�l nagyobb?
    ja    @hibret                       // Igen, akkor hib�s a hossz
    imul  ecx,ecx,SIZHTB                // Ennyi b�jtb�l �ll
    mov   [edx + USB_buf.counter],cl    // A k�r�s b�jtsz�ma
    mov   al,HANGIN OR $80              // Ha hossz� k�ld�s lesz
    cmp   cl,30                         // Van ennyi?
    ja    @marahk                       // T�bb is, marad a hossz� k�r�s
    mov   al,HANGIN                     // R�vid k�ld�s lesz
  @marahk:
    mov   [edx + USB_buf.tipus],al      // A k�r�s k�dja
    push  edi                           // Elrontom
    push  esi                           // Elrontom
    lea   edi,[edx + USB_buf.hangtb]    // Ahova tenni kell
    mov   esi,amitku                    // Itt van a lista
    cld                                 // El�refele m�soljon
    rep   movsb                         // �tm�solom
    pop   esi                           // Vissza a rontott
    pop   edi                           // Vissza a rontott
    push  edx                           // UsbHidWrite 2. param�ter, a puffer c�me
    push  0                             // UsbHidWrite 1. param�ter, az eszk�z sorsz�ma
    call  UsbHidWrite                   // Elind�tom a hangk�ld�st
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A DLL �ltal el�rhet� panel �llapot�nak lek�rdez�se.                             //
//                                                                                  //
//  Param�ter:                                                                      //
//                (in)  amitke      A lek�rdezen� panel azonos�t�ja                 //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    A c�m sikeresenn �tad�sra ker�lt      //
//                ERROR_DLL_INIT_FAILED       A DLL m�g nem volt elind�tva          //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLDLL_GetStatus(amitke: Word): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibak�d
    mov   edx,[pwndfu]                  // WNDProc �rt�ke
    or    edx,edx                       // Volt m�r?
    jz    @hibret                       // Visszat�rek hibajellel
    mov   ax,amitke                     // Ezt k�ldte
    xor   ecx,ecx                       // Az el�tagot nem kell vizsg�lni
    call  ervazo                        // Azonos�t� lek�rdez�s
    jnz   @hibret                       // Hib�s az azonos�t�
    mov   edx,offset sajpuf             // Az �zenet puffere
    mov   cx,amitke                     // Ezt k�ldte
    mov   [edx + USB_buf.address],cx    // Ezt kell megv�ltoztatni
    mov   [edx + USB_buf.tipus],STATER  // A k�r�s k�dja
    push  edx                           // UsbHidWrite 2. param�ter, a puffer c�me
    push  0                             // UsbHidWrite 1. param�ter, az eszk�z sorsz�ma
    call  UsbHidWrite                   // Elind�tom a st�tuszk�r�st
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  Adott teend� t�bl�zat v�grehajt�s�nak elind�t�sa.                               //
//                                                                                  //
//  Param�ter:                                                                      //
//                (in)  hanydb      A v�grehajtand� t�bl�zat m�rete                 //
//                (in)  tblveg      A v�grehajtand� t�bl�zat c�me                   //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    A v�grehajt�s sikeresen elindult      //
//                ERROR_DLL_INIT_FAILED       A DLL m�g nem volt elind�tva          //
//                ERROR_REQ_NOT_ACCEP         Jelnleg �ppen fut egy v�grehajt�s     //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//  A v�grehajt�s v�g�r�l LISVAL �zenet megy, aminek LPARAM �rt�ke t�j�koztat       //
//  a v�grehajt�sr�l.                                                               //
//                NO_ERROR                    A v�grehajt�s sikeresen befejez�d�tt  //
//                ERROR_INVALID_DATA          Az azonos�t� t�pusjel�l� bitp�rosa    //
//                                            hib�s, vagy nincs ilyen eszk�z        //
//                ERROR_BAD_LENGTH            A hanghossz 0, vagy nagyobb mint 16   //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLDLL_SetLista(hanydb: Integer; const tblveg:LISTBL): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibak�d
    mov   edx,[pwndfu]                  // WNDProc �rt�ke
    or    edx,edx                       // Volt m�r?
    jz    @hibret                       // Visszat�rek hibajellel
    mov   eax,ERROR_REQ_NOT_ACCEP       // Hibak�d
    mov   edx,offset belfut             // A fut�sjelz� c�me
    xor   ecx,ecx                       // Null�z�shoz
    or    cl,[edx]                      // Beolvasom az �llapotot
    jnz   @hibret                       // Most m�g fut, visszat�rek hibajellel
    mov   [belakt],ecx                  // A kezd� offszet
    inc   byte ptr [edx]                // Fut�sjelz�s ind�t�s (1 lesz)
    mov   eax,hanydb                    // A lista elemsz�ma
    mov   edx,tblveg                    // A kapott lista param�ter c�me
    mov   [belmax],eax                  // �tm�soltam
    mov   [belpoi],edx                  // Kitettem
    xor   eax,eax                       // Null�z�shoz
    mov   [belakt],eax                  // A kezd� offszet
    call  belkoi                        // Elind�tom az els� elemet
    xor   eax,eax                       // NO_ERROR
  @hibret:
end;

procedure statim(hwnd: THandle; uMsg: Uint; idEvent: Uint; dwTime: Dword); stdcall; Assembler;
var
  timerb: USB_buf;
asm
    push  [timtar]                      // KillTimer 2. param�ter, a timer azonos�t�ja
    push  [msghnd]                      // KillTimer 1. param�ter, a window param�ter
    call  KillTimer                     // Le�ll�tom az id�z�t�st
    lea   ecx,timerb                    // A puffer c�me
    xor   eax,eax                       // Null�z�s
    mov   [ecx + USB_buf.reportID],al   // A puffer elej�t null�zni kell
    mov   [ecx + USB_buf.tipus],STATER  // Ez az ind�t�s
    mov   dx,[aktadr]                   // Az �rv�nyes azonos�t�
    mov   [ecx + USB_buf.address],dx    // Ez az azonos�t� legyen
    push  ecx                           // UsbHidWrite 2. param�ter, a puffer c�me
    push  eax                           // UsbHidWrite 1. param�ter, az eszk�z sorsz�ma
    inc   [diruze]                      // Direkt �zenet megy
    call  UsbHidWrite                   // Elind�tom a st�tsuzk�r�st
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// E DLL verzi�j�nak �s teljes nev�nek lek�rdez�se.                                 //
//                                                                                  //
//  Param�terek:  (out)  versms  A DLL verzi�j�nak magasabbik r�sze                 //
//                (out)  versls  A DLL verzi�j�nak alacsonyabbik r�sze              //
//                (out)  dllnam  A DLL neve teljes el�r�si �tvonallal               //
//                (in)   namlen  A DLL n�v hely�nek m�rete                          //
//                       (a sz�ks�ges ter�let maxim�lis m�rete: MAX_PATH)           //
//                                                                                  //
//  Viszzat�r�si �rt�k:                                                             //
//                NO_ERROR                    Sikeres m�velet                       //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function verdll(var versms, versls: Dword; dllnam: PChar; namlen: Dword): Dword; stdcall; Assembler;
asm
    push  edi                           // Mentem, mert haszn�lni fogom
    push  esi                           // Mentem, mert haszn�lni fogom
    mov   edi,dllnam                    // A "dllnam" �rt�ke t�bbsz�r is kell
    push  namlen                        // GetModuleFileName 3. param�ter
    push  edi                           // GetModuleFileName 2. param�ter
    push  [HInstance]                   // GetModuleFileName 1. param�ter
    call  GetModuleFileName             // Bek�rem a DLL n�v�t �s hely�t
    push  eax                           // Helyet csin�lok a v�lasznak
    push  esp                           // GetFileVersionInfoSize 2. param�ter
    push  edi                           // GetFileVersionInfoSize 1. param�ter
    call  GetFileVersionInfoSize        // Beolvastatom a hosszat
    pop   edx                           // Eldobom a param�tert
    or    eax,eax                       // Sikeres lek�rdez�s?
    jnz   @nevoke                       // Igen, sikeres volt
    call  GetLastError                  // Hibak�d bek�r�s
    jmp   @rethik                       // Visszat�r�s a hibak�ddal
  @nevoke:
    mov   esi,eax                       // M�solat a hosszr�l
    sub   esp,eax                       // A stackben csin�lok ennyi helyet
    mov   eax,esp                       // EAX <- a puffer c�me
    xor   edx,edx                       // A v�laszhely c�me
    push  '\'                           // Param�terk�nt mentem, de v�laszhely is
    mov   ecx,esp                       // A v�laszhely c�me
    push  edx                           // VerQueryValue 4. param�ter
    push  ecx                           // VerQueryValue 3. param�ter
    push  edx                           // VerQueryValue 2. param�ter
    push  eax                           // VerQueryValue 1. param�ter
    push  eax                           // GetFileVersionInfo 4. param�ter
    push  esi                           // GetFileVersionInfo 3. param�ter
    push  esi                           // GetFileVersionInfo 2. param�ter
    push  edi                           // GetFileVersionInfo 1. param�ter
    call  GetFileVersionInfo            // Beolvasom
    call  VerQueryValue                 // �talak�tom
    pop   edx                           // Ez a v�laszpuffer c�me (elimin�l�s is!)
    mov   ecx,[edx + TVSFixedFileInfo.dwProductVersionMS]// M�solat
    mov   eax,[edx + TVSFixedFileInfo.dwProductVersionLS]// M�solat
    add   esp,esi                       // A foglalt stack felszabad�t�s
    mov   edi,versms                    // Ide m�solok ("Version_MS" param�ter c�me)
    mov   esi,versls                    // Ide m�solok ("Version_LS" param�ter c�me)
    mov   [edi],ecx                     // A "Version_MS" v�lasz
    mov   [esi],eax                     // A "Version_LS" v�lasz
    xor   eax,eax                       // Visszat�r�s NO_ERROR-al
  @rethik:
    pop   esi                           // Vissza a rontott
    pop   edi                           // Vissza a rontott
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//   A csatlakoztatott eszk�z�k lev�laszt�s�nak figyel�se, �j eszk�z�k              //
//   csatlakoztat�s�nak �szlel�se.                                                  //
//   az er�forr�sainak felszabad�t�s�val.                                           //
//                                                                                  //
//    Input:  Window  <- Az �zenet handle tartalma                                  //
//            Message <- Az �zenet k�dja                                            //
//            wParam  <- Az �zenet wParam �rt�ke                                    //
//            lParam  <- Az �zenet lParam �rt�ke                                    //
//                                                                                  //
//    Output: Ha nincs az eszk�z�k sz�m�ban v�ltoz�s: -> az eredeti pontra tov�bb   //
//            Ha van elt�vol�tott eszk�z haszn�latban -> lev�laszt�s �s �zenet a    //
//                                                       v�ltoz�sr�l                //
//            Ha van csatlakoztathat� eszk�z          -> csatlakoztat�s �s �zenet   //
//                                                       a v�ltoz�sr�l              //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function wndprc(Window: HWND; Message, wParam, lParam: Dword): Dword; stdcall; Assembler;
asm
//
// �zenetk�d figyel�s, ha nem nekem sz�l, tov�bbk�ld�m
//
    mov   ecx,[msgkod]                  // A saj�t �zenetsz�mom
    cmp   Message,ecx                   // A "Message" param�terben ez a k�d?
    jnz   @maskot                       // Nem, akkor standard elj�r�s
//
// Nekem �zentek, de a saj�t DLL-em �zent?
//
    cmp   wParam,LISVAL                 // �t�zen�s?
    jz    @maskot                       // Nem, akkor standard elj�r�s
    mov   edx,lParam                    // Ezt �zente
    mov   eax,[diruze]                  // Direkt �zenet sz�ml�l�
    or    eax,eax                       // Puffer j�tt?
    jnz   @nempuf                       // Nem, saj�t �zenet megy
//
// Nekem �zentek, de mit is?
//
    or    edx,edx                       // Nulla?
    jnz   @vanpuc                       // Puffer c�m volt
//
// Az USB eszk�z�k sz�m�nak v�ltoz�s�r�l �zen
//
  @nelive:
    call  UsbGetNumdev                  // Az aktu�lis mennyis�g lek�rdez�se
    or    eax,eax                       // Van valamennyi?
    jnz   @valvan                       // Igen, van
    push  eax                           // UsbHidDevClose 1. param�ter, az elt�vvol�tand� sorsz�ma
    call  UsbHidDevClose                // Elt�vol�tottam
    push  eax                           // CallWindowProc 5. param�ter, az �zenethez kapcsol�d� �rt�k (lParam)
    push  USBREM                        // CallWindowProc 4. param�ter, az �zenet k�dja (wParam)
    push  Message                       // CallWindowProc 3. param�ter, az �zenet sz�ma
    push  Window                        // CallWindowProc 2. param�ter, kinek (window) sz�l
    push  [pwndfu]                      // CallWindowProc 1. param�ter, a l�nc eleme, ahol folytassa
    call  CallWindowProc                // Megh�vom a tov�bbiakat
//
// Ha volt el�z�leg le�r�, akkor azt felszabad�tom
//
    xor   eax,eax                       // Null�zok
    xchg  eax,[offset devusb + DEVSEL.produc]// Az elem sz�veges le�r�ja
    or    eax,eax                       // Kell visszaadni?
    jz    @nemadp                       // Most nem kell
    push  eax                           // GloablFree 1. param�ter, a puffer c�me
    call  GlobalFree                    // Eldobom a stringet
  @nemadp:
    xor   eax,eax                       // Null�zok
    xchg  eax,[offset devusb + DEVSEL.manufa]// Az elem gy�rt�  le�r�ja
    or    eax,eax                       // Kell visszaadni?
    jz    @sajint                       // Most nem kell, sikeresen elt�vol�tottam
    push  eax                           // GloablFree 1. param�ter, a puffer c�me
    call  GlobalFree                    // Eldobom a stringet
    call  eszrem                        // Elt�vol�tom az eszk�zle�r�kat
    jmp   @sajint                       // Feldolgoztam
  @valvan:
    push  esi                           // Elrontan�m
    mov   esi,eax                       // M�solom a darabsz�mot
  @esekoz:
    dec   esi                           // Ez az utols�?
    jz    @macsae                       // Igen, ez az
    push  esi                           // UsbHidDevClose 1. param�ter, az elt�vvol�tand� sorsz�ma
    call  UsbHidDevClose                // Elt�vol�tottam
    jmp   @esekoz                       // Vissza, hogy z�rhassam a t�bbit, ha kell
  @macsae:
    pop   esi                           // Rontott vissza
    call  SLDLL_Felmeres                // Elind�tom a felm�r�st
    jmp   @sajint                       // Feldolgoztam
//
// Puffert k�ld�tt, a v�lasz szerint el�gazok
//
  @vanpuc:
    mov   eax,[diruze]                  // Direkt �zenet sz�ml�l�
    or    eax,eax                       // Puffer j�tt?
    jnz   @nempuf                       // Nem, direkt �zenet megy
//
// Beolvasom a puffer t�pus�t
//
    mov   al,[edx + USB_buf.tipus]      // A t�pus m�solata
//
// A t�pust�l f�gg� �zenet kialak�t�sa, ha st�tuszk�r�s, sim�n mehet
//
    mov   ecx,STATKV                    // Az �zenet t�pusa
    cmp   al,STATER                     // Csak sim�n st�tuszt k�r?
    jz    @aknoku                       // Igen, alapst�tusz k�ld�s
//
// Ha a h�rom elem valamelyik�t �ll�tom, megn�zem, hogy lista-k�r�s volt-e
//
    mov   ecx,HANGEL                    // Az �zenet t�pusa
    cmp   al,HANGIN                     // Hanstring ind�t�s?
    jz    @aknokl                       // Igen, alapst�tusz k�ld�s
    mov   ecx,LEDRGB                    // Az �zenet t�pusa
    cmp   al,LEDLRG                     // LED �rt�kek be�ll�t�sa?
    jz    @aknokl                       // Igen, alapst�tusz k�ld�s
    cmp   al,NYILRG                     // A ny�l RGB �s ir�ny �rt�kek be�ll�t�sa?
    jnz   @neledj                       // Nem, m�s van
    mov   ecx,NYIRGB                    // Az �zenet t�pusa
//
// A h�rom elem be�ll�t�sk�r�s volt
//
  @aknokl:
    cmp   [belfut],0                    // Most �ppen fut?
    jz    @aknoku                       // Nem, akkor sim�n elk�ld�m
    call  belkoi                        // Ind�tom a k�vetkez� elemet
    jmp   @sajint                       // Feldolgoztam
//
// A v�lasz �ltal�nos st�tusz lesz
//
  @aknoku:
    lea   eax,[edx + USB_buf.statta]    // Itt vannak a st�tusz RGB �rt�kek
    push  eax                           // CallWindowProc 5. param�ter, az �zenethez kapcsol�d� �rt�k (lParam)
    push  ecx                           // CallWindowProc 4. param�ter, az �zenet t�pusa (wParam)
    push  Message                       // CallWindowProc 3. param�ter, az �zenet sz�ma
    push  Window                        // CallWindowProc 2. param�ter, kinek (window) sz�l
    push  [pwndfu]                      // CallWindowProc 1. param�ter, a l�nc eleme, ahol folytassa
    call  CallWindowProc                // Megh�vom a tov�bbiakat
    jmp   @sajint                       // Meg�zentem az �llapotot
//
// Nem �ltal�nos st�tsuz v�lasz kell
//
  @neledj:
    cmp   al,SFLASH                     // Friss�t�si l�p�s inform�ci� j�tt?
    jnz   @maskoj                       // Nem, m�s van
//
// A f�mver friss�t�s folyamat�t kell k�vetni
//
    movzx eax,[edx + USB_buf.counter]   // A hibajelz� m�solata
    mov   ecx,[upglei]                  // A friss�t� strukt�ra c�me
    mov   [ecx + UPGPCK.errcod],al      // A hibak�dot �tadom
    push  eax                           // A hibak�dot elmentem
    push  ecx                           // CallWindowProc 5. param�ter, az �zenethez kapcsol�d� �rt�k (lParam)
    push  FIRMUZ                        // CallWindowProc 4. param�ter, az �zenet k�dja (wParam)
    push  Message                       // CallWindowProc 3. param�ter, az �zenet sz�ma
    push  Window                        // CallWindowProc 2. param�ter, kinek (window) sz�l
    push  [pwndfu]                      // CallWindowProc 1. param�ter, a l�nc eleme, ahol folytassa
    call  CallWindowProc                // Megh�vom a tov�bbiakat
    pop   eax                           // Hibak�d vissza
    or    al,al                         // Volt hiba?
    jnz   @sajint                       // Igen, csak befejezem
    call  indpck                        // Folytatom a k�vetkez� elem elk�ld�s�vel
    jmp   @sajint                       // Meg�zentem az �llapotot
//
// Nem k�dfiss�t�s megy, esetleg �jra kell ind�tan?
//
  @maskoj:
    cmp   al,KFLASH                     // Reset jelz�s j�tt?
    jnz   @elkupv                       // Nem, akkor v�laszt vizsg�lok
//
// A f�mver friss�t�s v�ge, �jraind�t�sr�l �zenek
//
    xor   eax,eax                       // Null�z�shoz
    xchg  eax,[upglei]                  // A pointer amit vissza kell adni
    push  eax                           // GlobalFree 1. param�ter, a blokk c�me
    call  GlobalFree                    // Visszaadom a puffert
    push  eax                           // CallWindowProc 5. param�ter, az �zenethez kapcsol�d� �rt�k (lParam)
    push  FIRMEN                        // CallWindowProc 4. param�ter, az �zenet k�dja (wParam)
    push  Message                       // CallWindowProc 3. param�ter, az �zenet sz�ma
    push  Window                        // CallWindowProc 2. param�ter, kinek (window) sz�l
    push  [pwndfu]                      // CallWindowProc 1. param�ter, a l�nc eleme, ahol folytassa
    call  CallWindowProc                // Megh�vom a tov�bbiakat
    jmp   @sajint                       // Meg�zentem az �llapotot
//
// Saj�t esem�nyre v�r�s vizsg�lat
//
  @nempuf:
    dec   [diruze]                      // Direkt �zenet sz�ml�l� cs�kkent�s
  @elkupv:
    mov   [locpuf],edx                  // Ezt a puffert k�ldte
    mov   eax,[varuze]                  // A v�rakoz�s Handle �rt�ke
    or    eax,eax                       // V�rnak v�laszra?
    jz    @maskot                       // Nem v�rnak, akkor �zenek
//
// Saj�t v�rakoz�s akt�v, jelzem a pufferk�ld�st
//
    push  [varuze]                      // SetEvent 1. param�ter, a jelzend� Handle �rt�ke
    call  SetEvent                      // J�tt puffer jelz�s
    jmp   @sajint                       // Feldolgoztam
  @maskot:
    push  lParam                        // CallWindowProc 5. param�ter, az �zenethez kapcsol�d� �rt�k (lParam)
    push  wParam                        // CallWindowProc 4. param�ter, az �zenethez kapcsol�d� �rt�k (wParam)
    push  Message                       // CallWindowProc 3. param�ter, az �zenet sz�ma
    push  Window                        // CallWindowProc 2. param�ter, kinek (window) sz�l
    push  [pwndfu]                      // CallWindowProc 1. param�ter, a l�nc eleme, ahol folytassa
    call  CallWindowProc                // Megh�vom a tov�bbiakat
  @sajint:
end;

function feldev(vakvan: Pointer): Dword; stdcall; Assembler;
asm
    push  ebx                           // Rontani fogom
    push  esi                           // Rontani fogom
    push  edi                           // Rontani fogom
    mov   ecx,offset sajpuf             // A pufferem c�me
    mov   [ecx + USB_buf.tipus],FEL485  // Ez az ind�t�sa a felm�r�snek
    push  ecx                           // UsbHidWrite 2. param�ter, a puffer c�me
    push  0                             // UsbHidWrite 1. param�ter, az eszk�z sorsz�ma
    inc   [diruze]                      // Direkt �zenet megy
    call  UsbHidWrite                   // Elind�tom a felm�r�st
    or    eax,eax                       // WAIT_OBJECT_0 a v�lasz?
    jnz   @timerb                       // Kil�pek hiba�zenettel
    push  10000                         // WaitForSingleObject 2. param�ter, a v�rakoz�s ideje (10 sec.)
    push  [varuze]                      // WaitForSingleObject 1. param�ter, a v�rakoz�s Handle �rt�ke
    call  WaitForSingleObject           // Kiv�rom a v�laszt
    or    eax,eax                       // WAIT_OBJECT_0 a v�lasz?
    jnz   @timerb                       // Kil�pek hiba�zenettel
    push  [varuze]                      // ResetEvent 1. param�ter, a v�rakoz�s Handle �rt�ke
    call  ResetEvent                    // T�rl�m, hogy �jra v�rakozhassak r�
    mov   edx,[locpuf]                  // Az �rkezett puffer c�me
    mov   ax,[edx + USB_buf.esuadr]     // A c�m
    mov   [aktadr],ax                   // Az aktu�lis c�m
//
// Id�z�t�s ind�t�s
//
  @felmfu:
    xor   eax,eax                       // Null�z�s
    mov   edx,10                        // SetTimer 3. param�ter, az id�z�t�s (msec.-ben)
    push  offset statim                 // SetTimer 4. param�ter, a megh�vand� rutin c�me
    push  edx                           // SetTimer 3. param�ter, az id�z�t�s (msec.-ben)
    push  edx                           // SetTimer 2. param�ter, az azonos�t�
    push  [msghnd]                      // SetTimer 1. param�ter, a window param�ter
    call  SetTimer                      // Elind�tom az id�z�t�t
    mov   [timtar],eax                  // Elteszem az azonos�t�t
    push  200                           // WaitForSingleObject 2. param�ter, a v�rakoz�s ideje (200 msec.)
    push  [varuze]                      // WaitForSingleObject 1. param�ter, a v�rakoz�s Handle �rt�ke
    call  WaitForSingleObject           // V�rok �rkezett pufferre
    or    eax,eax                       // WAIT_OBJECT_0 a v�lasz?
    jnz   @timerb                       // Kil�pek hiba�zenettel
    push  [varuze]                      // ResetEvent 1. param�ter, a v�rakoz�s Handle �rt�ke
    call  ResetEvent                    // T�rl�m, hogy �jra v�rakozhassak r�
//
// Megn�zem, hogy tart-e m�g a lek�rdez�s
//
    mov   edx,[locpuf]                  // Az �rkezett puffer c�me
    mov   ax,[edx + USB_buf.esuadr]     // A c�m
    mov   [aktadr],ax                   // Az aktu�lis c�m
    xor   eax,eax                       // Null�zok
    mov   al,[edx + USB_buf.felmnu]     // A felm�r�s feladatsz�ma (0 lesz, ha v�ge a felm�r�snek)
    or    eax,eax                       // Fut m�g a felm�r�s?
    jnz   @felmfu                       // A felm�r�s m�g fut
    mov   al,[edx + USB_buf.felmhi]     // A felm�r�s hibasz�ma (0 eset�n sikeres volt)
    or    eax,eax                       // Sikeres volt a felm�r�s?
    jnz   @felmhf                       // A felm�r�s hib�ra futott
    mov   al,[edx + USB_buf.darkby]     // A felm�r�s 16 bites azonos�t�inak sz�ma
    or    eax,eax                       // Sikeres volt a felm�r�s?
    jz    @felmth                       // A felm�r�sben nem lehet olyan, hogy egy sem
    cmp   al,[edx + USB_buf.darkby]     // Egyfoma a 16 bites �s a 64 bites azonos�t�k sz�ma?
    jnz   @felmda                       // Ha nem egyforma, akkor hiba van
//
// A megtal�lt azonos�t�k lek�rdez�se
//
    mov   ecx,offset sajpuf             // A pufferem c�me
    mov   [ecx + USB_buf.tipus],AZOLEK  // Lek�rdez�s
    push  ecx                           // UsbHidWrite 2. param�ter, a puffer c�me
    push  0                             // UsbHidWrite 1. param�ter, az eszk�z sorsz�ma
    call  UsbHidWrite                   // Elind�tom a felm�r�st
    or    eax,eax                       // WAIT_OBJECT_0 a v�lasz?
    jnz   @timerb                       // Kil�pek hiba�zenettel
    push  200                           // WaitForSingleObject 2. param�ter, a v�rakoz�s ideje (200 msec.)
    push  [varuze]                      // WaitForSingleObject 1. param�ter, a v�rakoz�s Handle �rt�ke
    call  WaitForSingleObject           // Kiv�rom a v�laszt
    or    eax,eax                       // WAIT_OBJECT_0 a v�lasz?
    jnz   @timerb                       // Kil�pek hiba�zenettel
    push  [varuze]                      // ResetEvent 1. param�ter, a v�rakoz�s Handle �rt�ke
    call  ResetEvent                    // T�rl�m, hogy �jra v�rakozhassak r�
    mov   edx,[locpuf]                  // Az �rkezett puffer c�me
    movzx ecx,[edx + USB_buf.counter]   // A megtal�lt eszk�z�k darabsz�ma
    mov   [drb485],ecx                  // A darabsz�mot elteszem
    imul  eax,ecx,SIZAPU                // A foglaland� puffer hossza
    push  eax                           // GlobalAlloc 2. param�ter, a foglaland� hossz
    push  GMEM_FIXED OR GMEM_ZEROINIT   // GlobalAlloc 1. param�ter, a foglal�s m�dja
    call  GlobalAlloc                   // Helyet foglalok a le�r�nak
    mov   [dev485],eax                  // A puffer c�me
//
// A c�meket kit�lt�m
//
    mov   ecx,[drb485]                  // Az eszk�z�k sz�ma
    mov   edx,[locpuf]                  // Az �rkezett puffer c�me
    lea   edx,[edx + USB_buf.hanlis]    // Az els� k�ld�tt elem c�me
    lea   ebx,[eax + DEVSEL.azonos]     // Az els� kit�ltend� elem c�me
  @azokci:
    mov   ax,word ptr [edx]             // Az azonos�t� beolvas�s
    mov   [ebx],ax                      // �tadtam
    lea   edx,[edx + 2]                 // A k�vetkez�re a forr�s
    lea   ebx,[ebx + SIZAPU]            // A k�vetkez�re a c�l
    loop  @azokci                       // Mindegyiket �tpakolom
//
// A jellemz�ket k�rdezem le
//
    xor   esi,esi                       // Az elemek sz�ma
    mov   ebx,offset sajpuf             // Az USB pufferem c�me
    mov   edi,[dev485]                  // A jellemz�k puffer�nek c�m�re
  @kovlek:
    xor   eax,eax                       // Null�z�shoz
//
// A verzi� �s a verzi� d�tum�nak lek�rdez�se
//
    mov   [ebx + USB_buf.tipus],AZOTUL  // A lek�rdez�s
    mov   [ebx + USB_buf.counter],al    // A lek�rdez�s els� menet
    mov   dx,[edi + DEVSEL.azonos]      // A kit�ltend� c�m
    mov   [ebx + USB_buf.address],dx    // A lek�rdez�s c�m�rt�ke
    push  ebx                           // UsbHidWrite 2. param�ter, a puffer c�me
    push  eax                           // UsbHidWrite 1. param�ter, az eszk�z sorsz�ma
    call  UsbHidWrite                   // Elind�tom a felm�r�st
    or    eax,eax                       // WAIT_OBJECT_0 a v�lasz?
    jnz   @timerb                       // Kil�pek hiba�zenettel
    push  200                           // WaitForSingleObject 2. param�ter, a v�rakoz�s ideje (200 msec.)
    push  [varuze]                      // WaitForSingleObject 1. param�ter, a v�rakoz�s Handle �rt�ke
    call  WaitForSingleObject           // Kiv�rom a v�laszt
    or    eax,eax                       // WAIT_OBJECT_0 a v�lasz?
    jnz   @timerb                       // Kil�pek hiba�zenettel
    push  [varuze]                      // ResetEvent 1. param�ter, a v�rakoz�s Handle �rt�ke
    call  ResetEvent                    // T�rl�m, hogy �jra v�rakozhassak r�
    mov   edx,[locpuf]                  // Az �rkezett puffer c�me
//
// A verzi�lelemek �tpakol�sa 5 hosszan
//
    lea   edx,[edx + USB_buf.kulver]    // A verzi� adatok pufferc�me
    lea   ecx,[edi + DEVSEL.idever]     // A kipakoland� adat c�me
    mov   ax,[edx]                      // Ezt k�ldte (verzi� h, verzi� l)
    call  bcdtob                        // BCD-r�l bin�risra alak�tom az AL-t �s az AH-t
    mov   [ecx],ax                      // Az �rt�kek �tad�sa
    mov   ax,[edx + 2]                  // Ezt k�ldte (�v, h�nap)
    call  bcdtob                        // BCD-r�l bin�risra alak�tom az AL-t �s az AH-t
    mov   [ecx + 2],ax                  // Az �rt�kek �tad�sa
    mov   al,[edx + 4]                  // Ezt k�ldte (nap)
    call  bcdtob                        // BCD-r�l bin�risra alak�tom az AL-t �s az AH-t
    mov   [ecx + 4],al                  // Az �rt�kek �tad�sa
//
// M�sodik tulajdons�g (az eszk�zle�r�s) lek�rdez�se
//
    inc   [ebx + USB_buf.counter]       // A lek�rdez�s m�sodik menet
    push  ebx                           // UsbHidWrite 2. param�ter, a puffer c�me
    push  0                             // UsbHidWrite 1. param�ter, az eszk�z sorsz�ma
    call  UsbHidWrite                   // Elind�tom a felm�r�st
    or    eax,eax                       // WAIT_OBJECT_0 a v�lasz?
    jnz   @timerb                       // Kil�pek hiba�zenettel
    push  200                           // WaitForSingleObject 2. param�ter, a v�rakoz�s ideje (200 msec.)
    push  [varuze]                      // WaitForSingleObject 1. param�ter, a v�rakoz�s Handle �rt�ke
    call  WaitForSingleObject           // Kiv�rom a v�laszt
    or    eax,eax                       // WAIT_OBJECT_0 a v�lasz?
    jnz   @timerb                       // Kil�pek hiba�zenettel
    push  [varuze]                      // ResetEvent 1. param�ter, a v�rakoz�s Handle �rt�ke
    call  ResetEvent                    // T�rl�m, hogy �jra v�rakozhassak r�
    mov   edx,[locpuf]                  // Az �rkezett puffer c�me
    lea   edx,[edx + USB_buf.kuluni]    // Az unik�d� jellemz� c�me
    lea   ecx,[edi + DEVSEL.produc]     // A kipakoland� adat c�me
    push  edx                           // Jelkit 2. param�ter, amit konvert�lni kell
    push  ecx                           // Jelkit 1. param�ter, ahova a jellemz� ker�l
    call  jelkit                        // �talak�tom �s kit�lt�m a jellemz�t
//
// Harmadik tulajdons�g (a gy�rt�) lek�rdez�se
//
    inc   [ebx + USB_buf.counter]       // A lek�rdez�s harmadik menet
    push  ebx                           // UsbHidWrite 2. param�ter, a puffer c�me
    push  0                             // UsbHidWrite 1. param�ter, az eszk�z sorsz�ma
    call  UsbHidWrite                   // Elind�tom a felm�r�st
    or    eax,eax                       // WAIT_OBJECT_0 a v�lasz?
    jnz   @timerb                       // Kil�pek hiba�zenettel
    push  200                           // WaitForSingleObject 2. param�ter, a v�rakoz�s ideje (200 msec.)
    push  [varuze]                      // WaitForSingleObject 1. param�ter, a v�rakoz�s Handle �rt�ke
    call  WaitForSingleObject           // Kiv�rom a v�laszt
    or    eax,eax                       // WAIT_OBJECT_0 a v�lasz?
    jnz   @timerb                       // Kil�pek hiba�zenettel
    push  [varuze]                      // ResetEvent 1. param�ter, a v�rakoz�s Handle �rt�ke
    call  ResetEvent                    // T�rl�m, hogy �jra v�rakozhassak r�
    mov   edx,[locpuf]                  // Az �rkezett puffer c�me
    lea   edx,[edx + USB_buf.kuluni]    // Az unik�d� jellemz� c�me
    lea   ecx,[edi + DEVSEL.manufa]    // A kipakoland� adat c�me
    push  edx                           // Jelkit 2. param�ter, amit konvert�lni kell
    push  ecx                           // Jelkit 1. param�ter, ahova a jellemz� ker�l
    call  jelkit                        // �talak�tom �s kit�lt�m a jellemz�t
    lea   edi,[edi + SIZAPU]            // A k�vetkez� t�rol�ra l�pk
    inc   esi                           // A k�vetkez� elem
    cmp   [drb485],esi                  // El�rte m�r a darabsz�mot
    jnz   @kovlek                       // M�g lek�rdez�s lesz
    dec   esi                           // A legnagyobb index ez lesz
    push  esi                           // quicksort 2. param�ter, a jobboldali �rt�k
    push  0                             // quicksort 1. param�ter, a baloldali �rt�k
    call  quicksort                     // Lerendezem
    mov   edx,FELMOK                    // Az �zenet k�dja (felm�r�s v�ge)
    mov   eax,[drb485]                  // A darabsz�mot �tadom
    jmp   @simuzv                       // A felm�r�s v�g�r�l �zenet megy
//
// A felm�r�s hib�ra futott, a 16 �s 64 bites darabsz�m nem egyforma
//
  @felmda:
    mov   edx,FELMDE                    // Hiba�zenet
    jmp   @simuzv                       // Hiba�zenet megy
//
// A felm�r�s hib�ra futott, nincs egy darab sem, ilyen elvben sem lehet
//
  @felmth:
    mov   edx,FELMHD                    // Hiba�zenet
    jmp   @simuzv                       // Hiba�zenet megy
//
// A felm�r�s hib�ra futott, hibak�d EAX-ben
//
  @felmhf:
    mov   edx,FELMHK                    // Hiba�zenet
    jmp   @simuzv                       // Hiba�zenet megy
//
// A v�laszv�r�s ideje letelt
//
  @timerb:
    mov   edx,VALTIO                    // Hiba�zenet
  @simuzv:
    inc   [diruze]                      // Direkt �zenet megy
    push  eax                           // PostMessage 4. param�ter, a hib�hoz kapcsol�d� �rt�k (lParam)
    push  edx                           // PostMessage 3. param�ter, a hiba k�dja (wParam)
    push  [msgkod]                      // PostMessage 2. param�ter, az �zenet sz�ma
    push  [msghnd]                      // PostMessage 1. param�ter, az �zenet window Handle �rt�ke
    call  PostMessage                   // �zenet megy a t�rt�ntekr�l
  @lefuaz:
    xor   eax,eax                       // Null�z�shoz
    xchg  eax,[varuze]                  // EAX <- v�rakoz�s Handle
    push  eax                           // CloseHandle
    call  CloseHandle                   // Lez�rom
    xor   eax,eax                       // Null�z�shoz
    xchg  eax,[felhnd]                  // EAX <- saj�t Thread-em Handle �rt�ke
    push  eax                           // CloseHandle
    call  CloseHandle                   // Lez�rom
    pop   edi                           // Rontott vissza
    pop   esi                           // Rontott vissza
    pop   ebx                           // Rontott vissza
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  Az azonos�t� megv�ltoztat�s�nak k�r�se.                                         //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function chgazo(parrom: Dword): Dword; stdcall; Assembler;
asm
    mov   edx,offset sajpuf             // Ide teszem a param�tereket
    mov   [edx + USB_buf.tipus],AZOMOD  // A t�pust kit�lt�m
    mov   ax,bx                         // Ezt kell megv�ltoztatni
    mov   [edx + USB_buf.address],ax    // A c�met kit�lt�m
    mov   eax,parrom                       // A param�ter
    shr   eax,16                        // Erre kell megv�ltoztatni
    mov   [edx + USB_buf.gepkou],ax     // Az �j c�met kit�lt�m
    push  edx                           // UsbHidWrite 2. param�ter, a puffer c�me
    push  0                             // UsbHidWrite 1. param�ter, az eszk�z sorsz�ma
    inc   [diruze]                      // Direkt �zenet megy
    call  UsbHidWrite                   // Elind�tom a v�ltoztat�st
    or    eax,eax                       // Volt hiba?
    jnz   @visfel                       // Igen, akkor visszat�rek
    push  800                           // WaitForSingleObject 2. param�ter, a v�rakoz�s ideje (800 msec.)
    push  [varuze]                      // WaitForSingleObject 1. param�ter, a v�rakoz�s Handle �rt�ke
    call  WaitForSingleObject           // Kiv�rom a v�laszt
    or    eax,eax                       // WAIT_OBJECT_0 a v�lasz?
    jnz   @visfel                       // Kil�pek hiba�zenettel
    xor   ecx,ecx                       // Kezd��rt�k
    mov   edx,[dev485]                  // A le�r�k list�ja
    mov   ax,bx                         // Ezt v�ltoztatn�m
  @kovmeg:
    cmp   ax,[edx + DEVSEL.azonos]      // Ilyen van a list�ban?
    jnz   @eznemo                       // Ez nem az
    mov   eax,parrom                    // A param�ter
    shr   eax,16                        // Erre kell megv�ltoztatni
    mov   [edx + DEVSEL.azonos],ax      // �t�rtam
    jmp   @valkes                       // Meg van, �t�rtam
  @eznemo:
    lea   edx,[edx + SIZAPU]            // A k�vetkez�re l�pek
    inc   ecx                           // A k�vetkez�re
    cmp   ecx,[drb485]                  // El�rt a v�g�re?
    jnz   @kovmeg                       // M�g nem, folytatom
  @valkes:
    mov   ax,bx                         // Ezt v�ltoztatn�m
    mov   edx,offset devusb             // Ez a param�ter c�mt�rol�ja
    cmp   ax,[edx + DEVSEL.azonos]      // Az USB eszk�znek ez a c�me?
    jnz   @renmev                       // Nem az, mehet vissza sikeresen
    mov   eax,parrom                    // A param�ter
    shr   eax,16                        // Erre kell megv�ltoztatni
    mov   [edx + DEVSEL.azonos],ax      // Az USB eszk�znek is ez a c�me
  @renmev:
    xor   eax,eax                       // NO_ERROR amivel visszat�rek
  @visfel:
    push  eax                           // Hibak�d k�s�bbre
    xor   eax,eax                       // Null�z�shoz
    xchg  eax,[varuze]                  // EAX <- v�rakoz�s Handle
    push  eax                           // CloseHandle 1. param�ter, a z�rand� Handle �rt�ke
    call  CloseHandle                   // Lez�rom
    xor   eax,eax                       // Null�z�shoz
    xchg  eax,[felhnd]                  // EAX <- saj�t Thread-em Handle �rt�ke
    push  eax                           // CloseHandle
    call  CloseHandle                   // Lez�rom
    pop   eax                           // A hibak�d vissza
    inc   [diruze]                      // Direkt �zenet megy
    push  eax                           // PostMessage 4. param�ter, a hib�hoz kapcsol�d� �rt�k (lParam)
    push  AZOOKE                        // PostMessage 3. param�ter, az �zenet k�dja (wParam)
    push  [msgkod]                      // PostMessage 2. param�ter, az �zenet sz�ma
    push  [msghnd]                      // PostMessage 1. param�ter, az �zenet window Handle �rt�ke
    call  PostMessage                   // �zenet megy a t�rt�ntekr�l
end;

procedure jelkit(var erechr: PChar; const mibol: USBTUL); stdcall; Assembler;
var
  machar: array [0..1023] of Char;
asm
    push  esi                           // Elromlana
    push  edi                           // Elromlana
    mov   eax,erechr                    // A felszabad�tand� puffer c�me
    mov   eax,[eax]                     // Ez a puffer az
    or    eax,eax                       // Volt m�r foglalva?
    jz    @punefo                       // M�g nem volt
    push  eax                           // GlobalFree 1. param�ter
    call  GlobalFree                    // Ez eredeti felszabad�tva
  @punefo:
    push  mibol                         // lstrlenw 1. param�ter
    call  lstrlenw                      // Norm�l stringhossz meg�llap�t�s
    xor   ecx,ecx                       // Null�zok
    mov   edx,mibol                     // A forr�s c�me
    lea   esi,machar                    // Az eredm�ny c�me
    push  ecx                           // WideCharToMultiByte 8. param�ter
    push  ecx                           // WideCharToMultiByte 7. param�ter
    push  1024                          // WideCharToMultiByte 6. param�ter
    push  esi                           // WideCharToMultiByte 5. param�ter
    push  eax                           // WideCharToMultiByte 4. param�ter
    push  mibol                         // WideCharToMultiByte 3. param�ter
    push  WC_COMPOSITECHECK	            // WideCharToMultiByte 2. param�ter
    push  CP_ACP	                      // WideCharToMultiByte 1. param�ter
    call  WideCharToMultiByte           // �tkonvert�lom
    mov   byte ptr [esi + eax],0        // Stringv�gjel
    inc   eax                           // Hely a stringv�gnek
    push  eax                           // GlobalAlloc 2. param�ter
    push  GMEM_FIXED                    // GlobalAlloc 1. param�ter
    call  GlobalAlloc                   // Lefoglalom a puffert
    mov   edx,erechr                    // A felszabad�tand� puffer c�me
    mov   [edx],eax                     // Ez a puffer az
    push  esi                           // lstrcpya 2. param�ter, amit m�solni kell
    push  eax                           // lstrcpya 1. ahova m�solni kell
    call  lstrcpya                      // Belem�solom
    pop   edi                           // Rontott vissza
    pop   esi                           // Rontott vissza
end;

procedure bcdtob(mitala: Word); Assembler;
asm
    push  ebx                           // Elrontom
    mov   bl,al                         // M�solom az L r�szt
    mov   bh,al                         // M�solom az L r�szt
    and   bl,00001111b                  // Csak az als� 4 bit marad
    and   bh,11110000b                  // Csak a fels� 4 bit marad (16 szoros a l�tszat)
    shr   bh,1                          // M�r csak 8-szoros a l�tszat
    mov   al,bh                         // 8 szoros �tpakolva
    shr   bh,2                          // M�r csak 2-szeres a l�tszat
    add   al,bh                         // AL <- 8 + 2 = 10 szeres
    add   al,bl                         // AL <- bin�risan a r�gi BCD AL
    mov   bl,ah                         // M�solom az L r�szt
    mov   bh,ah                         // M�solom az L r�szt
    and   bl,00001111b                  // Csak az als� 4 bit marad
    and   bh,11110000b                  // Csak a fels� 4 bit marad (16 szoros a l�tszat)
    shr   bh,1                          // M�r csak 8-szoros a l�tszat
    mov   ah,bh                         // 8 szoros �tpakolva
    shr   bh,2                          // M�r csak 2-szeres a l�tszat
    add   ah,bh                         // AH <- 8 + 2 = 10 szeres
    add   ah,bl                         // AH <- bin�risan a r�gi BCD AH
    pop   ebx                           // Vissza a rontott
end;

procedure indpck; stdcall; Assembler;
var
  sajpuf: USB_buf;
asm
    push  ebx                           // Elrontom
    push  esi                           // Elrontom
    push  edi                           // Elrontom
    lea   edx,sajpuf                    // A puffer c�me
    mov   ecx,[upglei]                  // Ez a le�r� c�me
    mov   ax,[ecx + UPGPCK.devazo]      // Az azonos�t�
    mov   [edx + USB_buf.address],ax    // Rekordsz�m kit�lt�s
    mov   [edx + USB_buf.ReportID],0    // Az els� b�jtot null�zni kell
    mov   eax,[ecx + UPGPCK.aktdar]     // Itt tart jelenleg
    mov   ebx,eax                       // M�solom
    shr   ebx,1                         // A fel�t veszem, mert k�t r�szletben megy a csomag
    cmp   ebx,[ecx + UPGPCK.packdb]     // El�rt m�r a v�g�re?
    jnz   @vanmek                       // M�g nem �rt a v�g�re, k�ld�zgetni kell
    mov   [edx + USB_buf.tipus],KFLASH  // Az �jraind�t�si parancs megy
    mov   [edx + USB_buf.counter],0     // A hossz �rt�ke
    jmp   @usbkuv                       // Elmehet a parancs
  @vanmek:
    lea   edi,[edx + USB_buf.pufbel]    // A puffer c�m�t el�k�sz�tem
    inc   [ecx + UPGPCK.aktdar]         // Megn�velem a darabsz�mot
    mov   [edx + USB_buf.tipus],SFLASH OR $80// A friss�t� puffer elk�ld�s�nek k�dja
    imul  esi,ebx,67                    // A rekordhosszal szorzok
    lea   esi,[ecx + esi + SIZUPG]      // Ez az alapc�m (p�ratlan menet)
    mov   ecx,33                        // A hossz m�sodik (p�ratlan) menetben
    test  eax,1                         // P�ros a sz�ml�l�?
    jnz   @nparos                       // P�ratlan k�ld�s param�terei maradnak
    inc   ecx                           // A hossz els�nek 34
    lea   esi,[esi + 33]                // A 67-es puffer m�sik r�sze lesz elk�ldve
  @nparos:
    mov   [edx + USB_buf.counter],cl    // A hossz kit�lt�se
    cld                                 // El�refele m�soljon
    rep   movsb                         // �tm�solom a puffert
  @usbkuv:
    push  edx                           // UsbHidWrite 2. param�ter, a puffer c�me
    push  0                             // UsbHidWrite 1. param�ter, az eszk�z sorsz�ma
    call  UsbHidWrite                   // Elind�tom a puffert
    pop   edi                           // Vissza a rontott
    pop   esi                           // Vissza a rontott
    pop   ebx                           // Vissza a rontott
end;
//
// AX <- a keresett azonos�t�
// CX <- 0, ha nem kell vizsg�lni, egy�bk�nt a k�v�nt t�pus bitp�ros
//
procedure ervazo; Assembler;
asm
    push  ebx                           // Elrontom
    xor   ebx,ebx                       // Alapra teszem
    mov   edx,[dev485]                  // Az eszk�zle�r�k kezd�c�me
  @kerazc:
    cmp   ax,[edx + DEVSEL.azonos]      // Ilyen van a list�ban?
    jz    @megvan                       // Megtal�ltam
    lea   edx,[edx + SIZAPU]            // A k�vetkez�re l�pek
    inc   ebx                           // A k�vetkez�re
    cmp   ebx,[drb485]                  // El�rt a v�g�re?
    jnz   @kerazc                       // M�g nem, folytatom
    jmp   @nemazi                       // Nem tal�ltam ilyet
  @megvan:
    or    ecx,ecx                       // Vizsg�ljam?
    jz    @zersta                       // Nem kell vizsg�lni
    and   ax,$c000                      // Csak a t�pus azonos�t� bitjei maradnak
    xor   ax,cx                         // A k�v�nt el�tag az?
    jz    @zersta                       // Nem kell vizsg�lni
  @nemazi:
    mov   eax,ERROR_INVALID_DATA        // Hibak�d
    or    eax,eax                       // Z�r� st�tusz be�ll�t�s
  @zersta:
    pop   ebx                           // Rontott vissza
end;
//
// Rendezem a megtal�lt elemeket az azonos�t�juk szerint
//
procedure quicksort(bal, jobb: Integer); stdcall; Assembler;
asm
    push  ebx                           // Elrontom
    push  esi                           // Elrontom
    push  edi                           // Elrontom
//
//  M�solatot k�sz�tek a bal �s jobb elemr�l i-be �s j-be
//
    mov   eax,bal                       // M�solat
    mov   edx,jobb                      // M�solat
    mov   edi,eax                       // Elpakolom (i)
    mov   ebx,edx                       // Elpakolom (j)
//
//  A pivot elem t�mbindexe
//
    add   eax,edx                       // EAX <- i + j
    shr   eax,1                         // EAX <- (i + j) DIV 2
//
//  A pivot elem meghat�roz�sa, beolvas�sa
//
    imul  esi,eax,SIZAPU                // A elem t�vols�ga ez elej�t�l
    add   esi,[dev485]                  // A puffer c�me
    mov   cx,[esi + DEVSEL.azonos]      // A vizsg�land� azonos�t� (pivot)
//
//  Itt van a k�ls� WHILE ciklus feje
//
  @kulwhi:
    cmp   edi,ebx                       // Ha i nagyobb mint j, akkor nincs ciklus
    jg    @kulwhv                       // M�r v�ge van
//
//  A ciklusba megyek, kisz�m�tom az i-edik t�mbelem c�m�t
//
    imul  esi,edi,SIZAPU                // A elem t�vols�ga ez elej�t�l
    add   esi,[dev485]                  // A puffer c�me
//
// Ha a t�mbelem �rt�ke nagyobb vagy egyenl�, akkor nem keresek tov�bb
//
  @felwhi:
    cmp   [esi + DEVSEL.azonos],cx      // A m�sik azonos�t�
    jae   @felwhv                       // Nincs tov�bb
//
//  Most kisebb, akkor a k�vetkez�re l�pek
//
    inc   edi                           // Offszet a k�vetkez�re
    lea   esi,[esi + SIZAPU]            // A k�vetkez� elem c�m�re l�pek
    jmp   @felwhi                        // �j ellen�rz�sre
//
//  Megvan a nagyobb elem indexe (i), kisz�m�tom a j-edik t�mbelem c�m�t
//
  @felwhv:
    imul  esi,ebx,SIZAPU                // A elem t�vols�ga ez elej�t�l
    add   esi,[dev485]                  // A puffer c�me
//
//  Ha a t�mbelem �rt�ke kisebb vagy egyenl�, akkor nem keresek tov�bb
//
  @alswhi:
    cmp   [esi + DEVSEL.azonos],cx      // A m�sik azonos�t�
    jbe   @alswhv                       // Nincs tov�bb
//
//  Most nagyobb, akkor az el�z�re l�pek
//
    dec   ebx                           // Offszet az el�z�re
    lea   esi,[esi - SIZAPU]            // Az el�z� elem c�m�re l�pek
    jmp   @alswhi                        // �j ellen�rz�sre
//
//  Megvan a kisebb elem indexe (j), megn�zem az indexek viszony�t,
//  ha i nagyobb mint j, akkor nem cser�lek
//
  @alswhv:
    cmp   edi,ebx                       // Az i �s j viszonya?
    jg    @kulwhi                       // A k�ls� ciklusba
//
//  Elvben cser�lni kell, de ha az indexek (i �s j) egyform�k, nincs �rtelme
//
    jz    @cseren                       // Azonos offszetekn�l nincs csere
//
//  Nem egyform�k cser�le
//
    imul  edx,edi,SIZAPU                // A elem t�vols�ga ez elej�t�l
    add   edx,[dev485]                  // A puffer c�me
//
//  Azonos�t� csere
//
    mov   ax,[edx + DEVSEL.azonos]      // Az egyik azonos�t�
    xchg  ax,[esi + DEVSEL.azonos]      // A m�sik azonos�t�
    mov   [edx + DEVSEL.azonos],ax      // Csere a m�sikba
//
//  A product le�r�s elem (pointer) cser�je
//
    mov   eax,[edx + DEVSEL.produc]     // Az egyik c�m
    xchg  eax,[esi + DEVSEL.produc]     // A m�sik c�m
    mov   [edx + DEVSEL.produc],eax     // Csere a m�sikba
//
//  A gy�rt�t le�r� elem (pointer) cser�je
//
    mov   eax,[edx + DEVSEL.manufa]     // Az egyik c�m
    xchg  eax,[esi + DEVSEL.manufa]     // A m�sik c�m
    mov   [edx + DEVSEL.manufa],eax     // Csere a m�sikba
//
//  A verzi�t le�r� elemek cser�je (5 hossz�)
//
    mov   eax,dword ptr [edx + DEVSEL.idever]// Az egyik �rt�kn�gyes
    xchg  eax,dword ptr [esi + DEVSEL.idever]// A m�sik �rt�kn�gyes
    mov   dword ptr [edx + DEVSEL.idever],eax// Csere a m�sikba
    mov   al,byte ptr [edx + DEVSEL.idever + 4]// Az egyik marad�k
    xchg  al,byte ptr [esi + DEVSEL.idever + 4]// A m�sik marad�k
    mov   byte ptr [edx + DEVSEL.idever + 4],al// Csere a m�sikba
//
//  �tl�pem az aktu�lis elemeket
//
  @cseren:
    inc   edi                           // Baloldali n�vel�s
    dec   ebx                           // Jobboldali cs�kkent�s
    jmp   @kulwhi                       // A k�ls� ciklusba
//
//  Megt�rt�ntek a cser�k (ha kellett), j�het a jobb �s bal oldal rendez�se
//  ha a bal �rt�k nagyobb vagy egyenl� j-n�l, nem is kell megh�vni rendez�sre
//
  @kulwhv:
    cmp   bal,ebx                       // A bal �s a j viszonya
    jge    @nemhib                      // Nincs bels� h�v�s
//
// A bal �s a j elemeket (tov�bb) rendezem
//
    push  ebx                           // quicksort 2. param�ter, a jobboldali �rt�k
    push  bal                           // quicksort 1. param�ter, a baloldali �rt�k
    call  quicksort                     // Lerendezem
//
//  Ha a
//  Ha az i �rt�k nagyobb vagy egyenl� i-n�l, nem is kell megh�vni rendez�sre
//
  @nemhib:
    cmp   edi,jobb                      // Viszonyuk
    jge   @nemhij                       // Nincs bels� h�v�s
//
//  Az i �s a jobb elemeket (tov�bb) rendezem
//
    push  jobb                          // quicksort 2. param�ter, a jobboldali �rt�k
    push  edi                           // quicksort 1. param�ter, a baloldali �rt�k
    call  quicksort                     // Lerendezem
//
//  A bal �s jobb indexek k�z�tt (n�vekv� �rt�kre) rendezett a t�mb
//
  @nemhij:
    pop   edi                           // Rontott vissza
    pop   esi                           // Rontott vissza
    pop   ebx                           // Rontott vissza
end;
//
//  Az eszk�zle�r�ban foglaltak felszabad�t�sa, majd az eszk�zle�r� visszad�sa
//
procedure eszrem; stdcall; Assembler;
asm
    push  ebx                           // Elrontom
    xor   ebx,ebx                       // Null�zok
    mov   ebx,[dev485]                  // Ez volt el�tte
    or    ebx,ebx                       // Nulla?
    jz    @aknesa                       // Igen, nincs mit felszabad�tani
    push  esi                           // Elrontan�m
    push  edi                           // Elrontan�m
//
// Ha volt el�z�leg lista, akkor azt felszabad�tom
//
    xor   esi,esi                       // Alaphelyzet
  @kovelf:
    imul  edi,esi,SIZAPU                // Az offszet
    mov   eax,[edi + ebx + DEVSEL.produc]// Az elem sz�veges le�r�ja
    or    eax,eax                       // Kell visszaadni?
    jz    @nemadp                       // Most nem kell
    push  eax                           // GloablFree 1. param�ter, a puffer c�me
    call  GlobalFree                    // Eldobom a stringet
  @nemadp:
    mov   eax,[edi + ebx + DEVSEL.manufa]// Az elem gy�rt�  le�r�ja
    or    eax,eax                       // Kell visszaadni?
    jz    @nemadm                       // Most nem kell
    push  eax                           // GloablFree 1. param�ter, a puffer c�me
    call  GlobalFree                    // Eldobom a stringet
  @nemadm:
    inc   esi                           // A k�vetkez� elemre l�pek
    cmp   [drb485],esi                  // Van m�g?
    jnz   @kovelf                       // Igen, akkor fussunk neki
    pop   edi                           // Vissza a rontott
    pop   esi                           // Vissza a rontott
    push  ebx                           // GloablFree 1. param�ter, a puffer c�me
    call  GlobalFree                    // Eldobom a le�r�t
  @aknesa:
    pop   ebx                           // Vissza a rontott
end;
//
// Feladatlista k�vetkez� elem�nek ind�t�sa, ha van m�g, ha nincs �zenetk�ld�s
//
function belkoi: Dword; stdcall; Assembler;
asm
    push  ebx                           // Elrontom
    mov   eax,[belakt]                  // Itt tart most
    cmp   eax,[belmax]                  // El�rt m�r a v�g�re
    jnz   @folyin                       // M�g nem �rt a v�g�re
    xor   eax,eax                       // Minden rendben (NO_ERROR)
    jmp   @valveg                       // Lefutott valamennyi
  @folyin:
    inc   [belakt]                      // A k�vetkez�re
    imul  ebx,eax,SIZBEL                // A t�bl�zat elej�hez k�pesti offszet
    add   ebx,[belpoi]                  // A t�bl�zatra r�tolom
    mov   ax,[ebx + LISELE.azonos]      // A k�ld�tt azonos�t�
    mov   ecx,SLLELO                    // A k�v�nt el�tag
    call  ervazo                        // Azonos�t� lek�rdez�s
    jnz   @nemale                       // Nem LED l�mpa azonos�t�
    mov   edx,offset sajpuf             // Az �zenet puffere
    mov   cx,[ebx + LISELE.azonos]      // Ezt k�ldte
    mov   [edx + USB_buf.address],cx    // Ezt kell megv�ltoztatni
    mov   [edx + USB_buf.tipus],LEDLRG  // A k�r�s k�dja
    mov   eax,dword ptr [ebx + LISELE.lamrgb]// Az RGB param�ter
    mov   dword ptr [edx + USB_buf.ledszb],eax// �tadom az RGB �rt�keket
    jmp   @elkul                        // Elk�ld�m a parancsot
  @nemale:
    mov   ax,[ebx + LISELE.azonos]      // A k�ld�tt azonos�t�
    mov   ecx,SLNELO                    // A k�v�nt el�tag
    call  ervazo                        // Azonos�t� lek�rdez�s
    jnz   @nemani                       // Nem a ny�l az azonos�t�
    mov   edx,offset sajpuf             // Az �zenet puffere
    mov   cx,[ebx + LISELE.azonos]      // A k�ld�tt azonos�t�
    mov   [edx + USB_buf.address],cx    // Ezt kell megv�ltoztatni
    mov   [edx + USB_buf.tipus],NYILRG  // A k�r�s k�dja
    mov   eax,dword ptr [ebx + LISELE.nilrgb]// Az RGB param�ter
    mov   dword ptr [edx + USB_buf.ledszb],eax// �tadom az RGB �rt�keket
    mov   eax,[ebx + LISELE.jobrai]     // Az ir�ny
    or    eax,eax                       // False?
    jz    @marafa                       // Igen, az is marad
    mov   al,1                          // Legyen True
  @marafa:
    mov   [edx + USB_buf.lednir],al     // �tadom az ir�ny �rt�keket
    jmp   @elkul                        // Elk�ld�m a parancsot
  @nemani:
    mov   ax,[ebx + LISELE.azonos]      // A k�ld�tt azonos�t�
    mov   ecx,SLHELO                    // A k�v�nt el�tag
    call  ervazo                        // Azonos�t� lek�rdez�s
    mov   eax,ERROR_INVALID_DATA        // Hibak�d
    jnz   @valveg                       // Nem a hangsz�r� azonos�t�, m�s meg nincs
    mov   edx,offset sajpuf             // Az �zenet puffere
    mov   cx,[ebx + LISELE.azonos]      // Ezt k�ldte
    mov   [edx + USB_buf.address],cx    // Ezt kell megv�ltoztatni
    mov   eax,ERROR_BAD_LENGTH          // Hibak�d
    movzx ecx,[ebx + LISELE.handrb]     // Ezt k�ldte hossznak
    or    ecx,ecx                       // Nulla az elemsz�m?
    jz    @valveg                       // Nem lehet nulla a hossz
    cmp   ecx,16                        // Enn�l nagyobb?
    ja    @valveg                       // Igen, akkor hib�s a hossz
    imul  ecx,ecx,SIZHTB                // Ennyi b�jtb�l �ll
    mov   [edx + USB_buf.counter],cl    // A k�r�s b�jtsz�ma
    mov   al,HANGIN OR $80              // Ha hossz� k�ld�s lesz
    cmp   cl,30                         // Van ennyi?
    ja    @marahk                       // T�bb is, marad a hossz� k�r�s
    mov   al,HANGIN                     // R�vid k�ld�s lesz
  @marahk:
    mov   [edx + USB_buf.tipus],al      // A k�r�s k�dja
    push  edi                           // Elrontom
    push  esi                           // Elrontom
    mov   esi,[ebx + LISELE.hantbp]     // Ez a t�bl�zat c�me
    lea   edi,[edx + USB_buf.hangtb]    // Ahova tenni kell
    cld                                 // El�refele m�soljon
    rep   movsb                         // �tm�solom
    pop   esi                           // Vissza a rontott
    pop   edi                           // Vissza a rontott
  @elkul:
    push  edx                           // UsbHidWrite 2. param�ter, a puffer c�me
    push  0                             // UsbHidWrite 1. param�ter, az eszk�z sorsz�ma
    call  UsbHidWrite                   // Elind�tom a felm�r�st
    or    eax,eax                       // Siker�lt?
    jz    @renveg                       // Igen, sikeres az ind�t�s
  @valveg:
    mov   [belfut],0                    // M�r nem fut
    push  eax                           // PostMessage 4. param�ter, a v�grehajt�s v�lasza (lParam)
    push  LISVAL                        // PostMessage 3. param�ter, a v�lasz k�dja (wParam)
    push  [msgkod]                      // PostMessage 2. param�ter, az �zenet sz�ma
    push  [msghnd]                      // PostMessage 1. param�ter, az �zenet window Handle �rt�ke
    call  PostMessage                   // �zenet megy a t�rt�ntekr�l
  @renveg:
    pop   ebx                           // A rontott vissza
end;

exports
  SLDLL_Open,
  SLDLL_Felmeres,
  SLDLL_Listelem,
  SLDLL_AzonositoCsereInditas,
  SLLDLL_Upgrade,
  SLLDLL_LEDLampa,
  SLLDLL_LEDNyil,
  SLLDLL_Hangkuldes,
  SLDLL_GetStatus,
  SLDLL_SetLista;
asm

end.

