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
  PRODUCT_ID              = $4c53;                          // A kívánt ProductID (SL)
//
// Ezek az egyes elemek azonosítói
//
  SLLELO	                = $4000;                          // LED  lámpa elõtag
  SLNELO                  = $8000;                          // LED nyíil elõtag
  SLHELO                  = $c000;                          // SLH elõtag
//
// Legfeljebb ennyi elemet tud egyszerre kezelni
//
  MAXRES	                = 21;                             // Legfeljebb ennyi elemnek van hely
//
// Az egyes paneloknak szóló USB üzenet kódjai
//
  STATER	                =	1;                              // A státusz beolvasása
  AZOMOD	                =	2;                              // Az azonosító beállítása
  AZOLEK                  = 3;                              // Az azonosítók lekérdezése
  AZOTUL                  = 4;                              // Az azonosító tulajdonság lekérdezése
  LEDLRG                  = 5;                              // LED lámpa színbeállítás
  NYILRG                  = 6;                              // LED nyíl irány és színbeállítás
  HANGIN	                = 7;                              // Hang indítás
//
  FEL485	                =	29;                       			// RS485 vonali felmérés indítás
//
  SFLASH                  =	30;                             // Flash írás adat
  KFLASH                  = 31;                             // Flash írás válasz
//
// Válaszkódok
//
  FELMOK                  = 1;                              // A felmérés rendben lezajlott
  AZOOKE                  = 2;                              // Az azonosító váltás rendben lezajlott
  FIRMUZ                  = 3;                              // Förmvercsere információs kódja
  FIRMEN                  = 4;                              // Förmvercsere vége, újraindítás elndul
  LEDRGB                  = 5;                              // A LED lámpa RGB értéke
  NYIRGB                  = 6;                              // A nyíl RGB és irány értéke
  HANGEL                  = 7;                              // A hangstring állapota
  STATKV                  = 8;                              // A státusz értéke
  LISVAL	                = 9;                              // A táblázat végének a válasza

  USBREM                  = -1;                             // Az USB vezérlõ eltávolításra került
  VALTIO                  = -2;                             // Felmérés közben válaszvárás time-out következett be
  FELMHK                  = -3;                             // Felmérés vége hibával
  FELMHD                  = -4;                             // Nincs egy darab sem hibakód (elvben sem lehet ilyen)
  FELMDE                  = -5;                             // A 16 és 64 bites darabszám nem egyforma (elvben sem lehet ilyen)

type
  VERTAR = packed record                                    // Verziótároló pl. 1.00 17/11/28 formátumban
    versih: Byte;                                           // A szoftver verziójának elsõ tagja           0     1
    versil: Byte;                                           // A szoftver verziójának második tagja        1     1
    datume: Byte;                                           // A szoftver verzió készítésének éve          2     1
    datumh: Byte;                                           // A szoftver verzió készítésének hónapja      3     1
    datumn: Byte;                                           // A szoftver verzió készítésének napja        4     1
  end;                                                      // Az egész hossza                             5

  DEVSEL = packed record                                    // Az elemek azonosításának leírója
    azonos: Word;                                           // Az elem azonosítója a bitpárossal együtt    0     2
    idever: VERTAR;                                         // Az elem verzióleírója                       2     5
    produc: PChar;                                          // Az elem szöveges leírója                    7     4
    manufa: PChar;                                          // Az elem gyártó  leírója                    11     4
  end;                                                      // Az egész hossza                            15
  PDEVSEL = ^DEVSEL;

  DEVLIS = array of DEVSEL;
  PDEVLIS = ^DEVLIS;

  NEVTAR = array [0..(MAX_PATH - 1)] of Char;               // A DLL nevének és helyének tárolója

  DLLVER = packed record                                    // A DLL verziójának leiírója
    versih: Dword;                                          // A DLL verziójának elsõ része                0     4
    versil: Dword;                                          // A DLL verziójának második része             4     4
    mianev: NEVTAR;                                         // A DLL neve és helye                         8   MAX_PATH (260)
  end;                                                      // Az egész hossza                            MAX_PATH + 8 = 268

  DLLNEV = array [0..1] of DLLVER;                          // Csak két DLL lesz használva
  PDLLNEV = ^DLLNEV;

  MERESE = packed record                                    // A proci belsõ mérésének értékei
    vddert: Word;                                           // A proci VDD mért értéke VREF-el             0     2
    vdddrb: Byte;                                           // A VDD mérés darabszáma                      2     1
    tmpkul: Word;                                           // A proci hõmérséklete                        3     2
    tmpdrb: Byte;                                           // A hõmérsékletmérés darabszáma               5     1
  end;                                                      // Az egész hossza                             6

  HABASZ = packed record                                    // Az RGB összetevõk leírása
    rossze: Byte;                                           // Az R összetevõ értéke                       0     1
    gossze: Byte;                                           // A G összetevõ értéke                        1     1
    bossze: Byte;                                           // A B összetevõ értéke                        2     1
  end;                                                      // Az egész hossza                             3

  DEVNUM  = array [0..(MAXRES - 1)] of Word;                // Azonosító tároló

  HANGLE = packed record                                    // Egy hang leírása
    hangho: Word;                                           // A hang hossza milisec.-ben                  0     2
    hangso: Byte;                                           // A hang sorszáma (0..32)                     2     1
    hanger: Byte;                                           // A hang hangereje (0..63)                    3     1
  end;                                                      // Az egész hossza                             4

  HANGLA = array [0..15] of HANGLE;                         // Hangleírók táblázata
  PHANGL = ^HANGLA;                                         // A táblázatra mutató pointer

  LISELE = packed record                                    // Lista szerinti teendõk elemleírás
    azonos: Word;                                           // Az elem azonosítója a bitpárossal együtt    0     2
    case Integer of
      1:
      (
        lamrgb: HABASZ;                                     // A LED lámpa RGB értékei                     2     3
      );
      2:
      (
        nilrgb: HABASZ;                                     // A nyíl RGB értékei                          2     3
        jobrai: BOOL;                                       // A nyíl iránya                               5     4
      );
      3:
      (
        handrb: Byte;                                       // A hang darabszáma                           2     1
        hantbp: PHANGL;                                     // A táblázatra mutató pointer                 3     4
      );
  end;                                                      // Az egész hossza                             7

  LISTBL = array [0..99] of LISELE;
  PLISTB = ^LISTBL;

  VIDTAR = array [0..31] of WideChar;

  PUPGPCK = ^UPGPCK;
  UPGPCK = packed record
    packdb: Dword;                                          // A csomagok maximuma                         0     4
    aktdar: Dword;                                          // A csomagok számlálója                       4     4
    devazo: Word;                                           // A 485-ös eszköz címe                        8     2
    errcod: Byte;                                           // Az üzenet kódja                            10     1
  end;                                                      // Az egész hossza                            11

  ELSPUF = array [0..33] of Byte;
  PELSPUF = ^ELSPUF;
  MASPUF = array [0..32] of Byte;
  PMASPUF = ^MASPUF;

  PELVSTA = ^ELVSTA;
  ELVSTA = packed record
    merlam: MERESE;                                         // A proci mért értékei                        0     6
    rgbert: HABASZ;                                         // Az aktuális színösszetevõk értéke           6     3
    nyilal: Byte;                                           // A nyíl iránya                               9     1
    hanakt: Byte;                                           // A hang állapota                            10     1
  end;                                                      // Az egész hossza                            11

  pUSB_buf = ^USB_buf;
  USB_buf = packed record
    reportID: Byte;                                         // For HID (not used, always 0)                0     1
    tipus: Byte;                                            // Az üzenet típuskódja                        1     1
    counter: Byte;                                          // Az üzenet számlálója                        2     1
    address: Word;                                          // Az üzenet címtartalma                       3     2
    case Integer of
      1:
      (
        pufbel: array [0..63] of Byte;                      // Az üzenet bájtos tárolóban                  5    64
      );
      2:
      (
        statta: ELVSTA;                                     // A státusz állapota                          5    11
        felmnu: Byte;                                       // A felmérés állapotszáma                    16     1
        darkby: Byte;                                       // A felmérés szerinti 16 bitesek száma       17     1
        darnby: Byte;                                       // A felmérés szerinti 64 bitesek száma       18     1
        felmhi: Byte;                                       // A felmérés hibakódja                       19     1
        felmcn: Byte;                                       // A felmérés hiba számláló értéke            20     1
        felmel: Byte;                                       // A felmérés hiba eltérésszámlálója          21     1
        esuadr: Word;                                       // Az aktuális azonosító                      22     2
      );
      3:
      (
        gepkou: Word;                                       // A beállítandó gépkód                        5     2
      );
      4:
      (
        ledszb: HABASZ;                                     // A színösszetevõk értékei                    5     3
        lednir: Byte;                                       // Az irány értéke                             8     1
      );
      5:
      (
        hanlis: DEVNUM;                                     // Ez a megtalált elemek azonosítója           5    42
      );
      6:
      (
        kulver: VERTAR;                                     // Ez a verzió válasz                          5     5
      );
      7:
      (
        kuluni: VIDTAR;                                     // A karakteres leíró válasz                   5    64
      );
      8:
      (
        hangtb: HANGLA;                                     // A lejátszandó hanglista                     5    64
      );
      9:
      (
        pufels: ELSPUF;                                     // A kódfrissítés elsõ puferrésze               5    34
      );
      10:
      (
        pufmas: MASPUF;                                     // A kódfrissítés második puferrésze            5    33
      );
  end;                                                      // Az egész hossza                            69

var
  aktadr: Word;                                               // Az aktuális cím
  drb485: Dword;                                              // Az RS 485 eszközök mennyisége
  diruze: Dword;                                              // Direkt üzenet számláló
  pwndfu: TFNWndProc = NIL;                                   // A proceduracím tárolója
  msghnd: THandle;                                            // MSG handle
  msgkod: Dword;                                              // MSG kód
  devusb: DEVSEL;                                             // Az USB eszköz leírója
  dllpar: DLLNEV;                                             // A két DLL paraméterei
  felhnd: THandle;                                            // Felmérés Thread handle
  sajpuf: USB_buf;                                            // A saját pufferem
  varuze: THandle;                                            // Eseményre várakozás
  locpuf: pUSB_buf;                                           // A vett puffer pointere
  dev485: DEVLIS;                                             // A leírók címe
  upglei: PUPGPCK;                                            // A frissítés leírója
  timtar: Uint;                                               // Timer azonosító
  belmax: Integer;                                            // A lista darabszáma
  belakt: Integer;                                            // A lista aktuális értéke
  belpoi: PLISTB;                                             // A lista pointere
  belfut: Boolean;                                            // A lista aktuális állapota


// A DLL használatbavételének indítása
function  SLDLL_Open(wndhnd, msgert: Dword; mianev: PDLLNEV; devata: PDEVSEL): Dword; stdcall; Assembler; Forward;
// Az elérhetõ eszközök felmérésének indítása
function SLDLL_Felmeres: Dword; Assembler; Forward;
// A táblázat átadása
function SLDLL_Listelem(devata: PDEVLIS): Dword; stdcall; Assembler; Forward;
// Az azonosító váltásának kérése
function SLDLL_AzonositoCsereInditas(amitva, amirev: Word): Dword; stdcall; Assembler; Forward;
// A kód felülírás elindítása
function SLLDLL_Upgrade(filnam: PChar; var drbkod: Dword; amitir: Word): Dword; stdcall; Assembler; Forward;
// A LED lámpa RGB értékeinek frissítése
function SLLDLL_LEDLampa(rgbert: HABASZ; amital: Word): Dword; stdcall; Assembler; Forward;
// A LED nyíl RGB értékeinek és irányának frissítése
function SLLDLL_LEDNyil(rgbert: HABASZ; jobrai: BOOL; amital: Word): Dword; stdcall; Assembler; Forward;
// Hangstring lejátszás indítása
function SLLDLL_Hangkuldes(hangho: Integer;const amitku: HANGLA; amital: Word): Dword; stdcall; Assembler; Forward;
// Státuszbeolvasás indítás
function SLDLL_GetStatus(amitke: Word): Dword; stdcall; Assembler; Forward
// Státuszbeolvasás indítás
function SLDLL_SetLista(hanydb: Integer; const tblveg:LISTBL): Dword; stdcall; Assembler; Forward
// Az idõzítõ "kettyenési" rutinja
procedure statim(hwnd: THandle; uMsg: Uint; idEvent: Uint; dwTime: Dword); stdcall; Assembler; Forward;
// A DLL verziójának lekérdezése
function  verdll(var versms, versls: Dword; dllnam: PChar; namlen: Dword): Dword; stdcall; Assembler; Forward;
// A lokális window eljárása
function  wndprc(Window: HWND; Message, wParam, lParam: Dword): Dword; stdcall; Assembler; Forward;
// A felmérést végrehajtó Thread
function  feldev(vakvan: Pointer): Dword; stdcall; Assembler; Forward;
// Az azonosító változtatást végzõ Thread
function chgazo(parrom: Dword): Dword; stdcall; Assembler; Forward;
// Az unikódos jellemzõ átalakítása normál karakterre
procedure jelkit(var erechr: PChar; const mibol: USBTUL); stdcall; Assembler; Forward;
// AL és AH (mindkettõ) BCD-rõl binárisra alakítás
procedure bcdtob(mitala: Word); Assembler; Forward;
// A frissítés soron következõ rekordjának indítása
procedure indpck; stdcall; Assembler; Forward;
// Azonosító (AX) vizsgálata létezésre és érvényességre (CX)
procedure ervazo; Assembler; Forward;
// A megtalált elemek rendezése azonosítójuk szerint
procedure quicksort(bal, jobb: Integer); stdcall; Assembler; Forward;
// Az eszközleíróban foglaltak és a leíró felszabadítás
procedure eszrem; stdcall; Assembler; Forward;
// Belsõ végrehajtás
function belkoi: Dword; stdcall; Assembler; Forward;

const
  SIZDNE                  = SizeOf(DLLVER);                 // A DLL paramétertároló hossza
  SIZAPU                  = SizeOf(DEVSEL);                 // A jellemzõ puffer hossza
  SIZUPG                  = SizeOf(UPGPCK);                 // Az upgrade leíró hossza
  SIZHTB                  = SizeOf(HANGLE);                 // Egy hangelem hossza
  SIZBEL                  = SizeOf(LISELE);                 // Egy listaelem hossza
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A DLL használatának megkezdése.                                                  //
//                                                                                  //
//  Paraméterek:                                                                    //
//                (in)  wndhnd      A használat eseményeinek üzenetét fogadó        //
//                                  handle (handle of destination window)           //
//                (in)  msgert      A beérkezõ (válasz) pufferekrõl tájékoztató     //
//                                  üzenet kódja (message code)                     //
//                (in-out) mianev   A DLL verziótáblázat címe                       //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    Sikeresen kapcsolódott a jelen        //
//                                            lévõ eszközökhöz                      //
//                ERROR_ALREADY_INITIALIZED   A rutin már használatba vette         //
//                                            (korábban) az eszközöket              //
//                ERROR_FUNCTION_NOT_CALLED   Nincs USB-s eszköz                    //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  SLDLL_Open(wndhnd, msgert: Dword; mianev: PDLLNEV; devata: PDEVSEL): Dword; stdcall; Assembler;
var
  tullei: USBTUL;
asm
    push  esi                           // Elrontom
    mov   eax,ERROR_ALREADY_INITIALIZED // Hibakód
    mov   edx,[pwndfu]                  // WNDProc értéke
    or    edx,edx                       // Volt már?
    jnz   @elmarv                       // Igen, volt már
//
// Átmásolom a hívás paramétereit
//
    mov   eax,wndhnd                    // Ez a(z) "wndhnd" paraméter
    mov   edx,msgert                    // Ez a(z) "msgert" paraméter
    mov   [msghnd],eax                  // Ez lesz az üzenet handle
    mov   [msgkod],edx                  // Ez lesz az üzenet kódja
//
// A window láncra felkapcsolom a DLL-t is
//
    push  offset wndprc                 // SetWindowLong 3. paraméter
    push  GWL_WNDPROC                   // SetWindowLong 2. paraméter
    push  eax                           // SetWindowLong 1. paraméter
    call  SetWindowLong                 // WND proc. belépõpont készítés
    or    eax,eax                       // Státusz kiértékelés
    jnz   @getako                       // Sikeresen kialakítottam
  @hibret:
    call  GetLastError                  // A hibakóddal térek vissza
    jmp   @elmarv                       // Mehet vissza
  @getako:
    mov   [pwndfu],eax                  // WNDProc új értéke
//
// Elindítom az üzenetküldést
//
    push  PRODUCT_ID                    // UsbHidOpen 3. paraméter, az USB azonosító
    push  [msgkod]                      // UsbHidOpen 2. paraméter, az üzenetszám
    push  [msghnd]                      // UsbHidOpen 1. paraméter, az üzenet Window Handle értéke
    call  UsbHidOpen                    // Csatlakozom az eszközhöz
    or    eax,eax                       // Sikeres volt?
    jnz   @elmarv                       // Nem sikerült megnyitni, hibakóddal visszatérek
    mov   esi,offset dllpar             // A puffer címe
    mov   edx,mianev                    // A válasz helye
    or    edx,edx                       // NIL a paraméter?
    jz    @akneto                       // Igen, akkor nem töltöm ki
    mov   [edx],esi                     // A leíró címét átadom
  @akneto:
    lea   eax,[esi + DLLVER.mianev]     // A név helye
    lea   edx,[esi + DLLVER.versih]     // A verzió egyik elemének címe
    lea   ecx,[esi + DLLVER.versil]     // A verzió másik elemének címe
    push  MAX_PATH                      // UsbGetDLLVersion 4. paraméter, pufferméret
    push  eax                           // UsbGetDLLVersion 3. paraméter, a puffer címe
    push  edx                           // UsbGetDLLVersion 2. paraméter, a verzió elemének címe
    push  ecx                           // UsbGetDLLVersion 1. paraméter, a verzió elemének címe
    call  UsbGetDLLVersion              // Beolvasom a HID_KER_USB.DLL verzióját
    or    eax,eax                       // Sikeres volt?
    jnz   @hibret                       // Nem, hibával vissza
    mov   edx,[esi + DLLVER.versil]     // Ez érdekel
    and   [esi + DLLVER.versil],$ffff   // Csak az alsó rész marad
    shr   edx,16                        // A felsõ rész alulra
    mov   [esi + DLLVER.versih],edx     // A verzió másik elemrésze
    lea   esi,[esi + SIZDNE]            // A másik elem címe
    lea   eax,[esi + DLLVER.mianev]     // A név helye
    lea   edx,[esi + DLLVER.versih]     // A verzió egyik elemének címe
    lea   ecx,[esi + DLLVER.versil]     // A verzió másik elemének címe
    push  MAX_PATH                      // verdll 4. paraméter, pufferméret
    push  eax                           // verdll 3. paraméter, a puffer címe
    push  edx                           // verdll 2. paraméter, a verzió elemének címe
    push  ecx                           // verdll 1. paraméter, a verzió elemének címe
    call  verdll                        // Beolvasom a SLDLL.DLL verzióját
    or    eax,eax                       // Sikeres volt?
    jnz   @hibret                       // Nem, hibával vissza
    mov   edx,[esi + DLLVER.versil]     // Ez érdekel
    and   [esi + DLLVER.versil],$ffff   // Csak az alsó rész marad
    shr   edx,16                        // A felsõ rész alulra
    mov   [esi + DLLVER.versih],edx     // A verzió másik elemrésze
    call  UsbGetNumdev                  // Megnézem, hogy van-e nekem szánt eszköz
    or    eax,eax                       // Nulla?
    jnz   @vanusb                       // Nem, van eszköz
    mov   eax,ERROR_FUNCTION_NOT_CALLED // Ha nincs USB eszköz, ez a hibakódom
    jmp   @elmarv                       // Hibakóddal vissza
  @vanusb:
    lea   esi,tullei                    // A kitöltendõk címe
    push  False                         // UsbHidGetProperty 3. paraméter, hexa értéket várok
    push  esi                           // UsbHidGetProperty 2. paraméter, a táblázat címe
    push  0                             // UsbHidGetProperty 1. paraméter, az eszköz sorszáma
    call  UsbHidGetProperty             // Beolvasom a paramétereket
    or    eax,eax                       // Volt hiba?
    jnz   @elmarv                       // Igen, a hibakóddal visszatérek
    mov   eax,devata                    // Itt adom át
    mov   edx,offset devusb             // Ez a paraméter címtárolója
    mov   [eax],edx                     // Átadtam a leíró címét
    lea   ecx,[esi + USBTUL.USB_Product_Number]// Innen olvasom be
    mov   ax,[ecx]                      // Az azonosító
    lea   ecx,[edx + DEVSEL.azonos]     // Ide kell tenni
    mov   [ecx],ax                      // Átmásoltam
    lea   ecx,[esi + USBTUL.USB_Product_Versio_H]// Innen olvasom be
    mov   ax,[ecx]                      // A verziópáros
    lea   ecx,[edx + DEVSEL.idever.VERTAR.versih]// Ide kell tenni
    call  bcdtob                        // BCD-rõl binárisra alakítom az AL-t és az AH-t
    mov   [ecx],ax                      // Átmásoltam
    lea   ecx,[esi + USBTUL.USB_Product_Year]// Innen olvasom be
    movzx eax,word ptr [ecx]            // Az azonosító
    mov   cl,100                        // Leválasztom az év alsó két értékeét
    div   cl                            // Elosztottam (AH <- maradék, AL <- hányados
    lea   ecx,[edx + DEVSEL.idever.VERTAR.datume]// Ide kell tenni
    call  bcdtob                        // BCD-rõl binárisra alakítom az AL-t és az AH-t
    mov   [ecx],ah                      // Átmásoltam
    lea   ecx,[esi + USBTUL.USB_Product_Month]// Innen olvasom be
    mov   ax,[ecx]                      // A hónap és nap páros
    lea   ecx,[edx + DEVSEL.idever.VERTAR.datumh]// Ide kell tenni
    call  bcdtob                        // BCD-rõl binárisra alakítom az AL-t és az AH-t
    mov   [ecx],ax                      // Átmásoltam
    lea   ecx,[esi + USBTUL.USB_Product]// Innen olvasom be
    lea   eax,[edx + DEVSEL.produc]     // Ide kell tenni
    lea   esi,[esi + USBTUL.USB_Manufacturer]// Innen olvasom be
    lea   edx,[edx + DEVSEL.manufa]     // Ide kell tenni
    push  ecx                           // Jelkit 2. paraméter, amit konvertálni kell
    push  eax                           // Jelkit 1. paraméter, ahova a jellemzõ kerül
    push  esi                           // Jelkit 2. paraméter, amit konvertálni kell
    push  edx                           // Jelkit 1. paraméter, ahova a jellemzõ kerül
    call  jelkit                        // Átalakítom és kitöltöm a jellemzõt
    call  jelkit                        // Átalakítom és kitöltöm a jellemzõt
//
// A keresõ thread-nek maximális prioritást adok
//
    xor   eax,eax                       // Visszatérés NO_ERROR értékkel
    mov   [belfut],al                   // Nem fut végrehajtás
  @elmarv:
    pop   esi                           // Vissza a rontott
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A DLL által elérhetõ eszközök felmérésének indítása.                            //
//                                                                                  //
//  Paraméter:                                                                      //
//                Nincs                                                             //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    A cím sikeresenn átadásra került      //
//                ERROR_DLL_INIT_FAILED       A DLL még nem volt elindítva          //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLDLL_Felmeres: Dword; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibakód
    mov   edx,[pwndfu]                  // WNDProc értéke
    or    edx,edx                       // Volt már?
    jz    @hibret                       // Visszatérek hibajellel
    call  eszrem                        // Eltávolítom az eszközleírókat
    xor   eax,eax                       // Nullázok
    push  eax                           // CreateThread 6. paraméter
    push  eax                           // CreateThread 5. paraméter
    push  eax                           // CreateThread 4. paraméter, a paraméter címe (nincs)
    push  offset feldev                 // CreateThread 3. paraméter, a thread kódjának címe
    push  eax                           // CreateThread 2. paraméter
    push  eax                           // CreateThread 1. paraméter
    push  eax                           // CreateEvent 4. paraméter, nincs neve
    push  eax                           // CreateEvent 3. paraméter, nincs jelezve alapban
    push  1                             // CreateEvent 2. paraméter, kézzel piszkálom
    push  eax                           // CreateEvent 1. paraméter, nincs Security Attributes
    call  CreateEvent                   // Várakozási handle készítés
    mov   [varuze],eax                  // Erre fogok várakozni
    call  CreateThread                  // Elkészítem a felmérést végrehajtó Thread-et
    or    eax,eax                       // Sikeres volt?
    jz    @hibget                       // Nem, hibával vissza
    mov   [felhnd],eax                  // Thread handle kitöltve
//
// A keresõ thread-nek maximális prioritást adok
//
    push  THREAD_PRIORITY_TIME_CRITICAL // SetThreadPriority 2. paraméter
    push  eax                           // SetThreadPriority 1. paraméter
    call  SetThreadPriority             // Megemelem a prioritását
    or    eax,eax                       // Sikeres volt?
    jnz   @retsik                       // Igen, visszatérhetek
  @hibget:
    call  GetLastError                  // Beolvasom a hiba kódját
    jmp   @hibret                       // Visszatérek a hiba kódjával
  @retsik:
    xor   eax,eax                       // Sikeres visszatérés jelzése NO_ERROR kóddal
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  Az eszközlista címének bekérése.                                                //
//                                                                                  //
//  Paraméter:                                                                      //
//                (out) devata      A táblázat címének másolata                     //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    A cím sikeresenn átadásra került      //
//                ERROR_DLL_INIT_FAILED       A DLL még nem volt elindítva          //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLDLL_Listelem(devata: PDevlis): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibakód
    mov   edx,[pwndfu]                  // WNDProc értéke
    or    edx,edx                       // Volt már?
    jz    @hibret                       // Visszatérek hibajellel
    mov   edx,devata                    // A paraméter
    mov   ecx,dev485                    // Kitöltöm
    mov   [edx],ecx                     // Kitöltöm
    xor   eax,eax                       // Sikeres visszatérés jelzése NO_ERROR kóddal
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  Az azonosító megváltoztatásának kérése.                                         //
//                                                                                  //
//  Paraméterek:                                                                    //
//                (in)  amitva      Az azonosítót változató panel azonosítója       //
//                (in)  amirev      Az új azonosító értéke                          //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    A változtatás sikeresen elindult      //
//                ERROR_DLL_INIT_FAILED       A DLL még nem volt elindítva          //
//                ERROR_ALREADY_ASSIGNED      Az új azonosító jelenleg más panel    //
//                                            azonosítója, két egyforma nem lehet.  //
//                ERROR_INVALID_DATA          Az azonosító értéke 0, vagy nincs     //
//                                            típusjelölõ bitpárosa.                //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLDLL_AzonositoCsereInditas(amitva, amirev: Word): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibakód
    mov   edx,[pwndfu]                  // WNDProc értéke
    or    edx,edx                       // Volt már?
    jz    @hibret                       // Visszatérek hibajellel
    xor   ecx,ecx                       // Nincs elõtag vizsgálat
    mov   ax,amirev                     // Erre változtatna
    test  ax,$c000                      // A legfelsõ két bit létezik?
    jz    @marane                       // Nincs, akkor nem jó az értéke
    test  ax,$3ff                       // Az azonosító nulla?
    jnz   @kovhas                       // Nem, akkor mehetek keresni
//
// Vagy hibás az azonosító, vagy már van olyan
//
  @marane:
    mov   eax,ERROR_INVALID_DATA        // Hibakód
    jmp   @hibret                       // Nincs ez a két bit, kilépek hibakóddal
  @kovhas:
    call  ervazo                        // Azonosító lekérdezés
    jz    @marane                       // Van már ilyen, pedig nem lehet két egyforma
//
// Nincs olyan amire változtatni akar
//
    mov   ax,amitva                     // Ezt változtatnám
    call  ervazo                        // Azonosító lekérdezés
    jnz   @marane                       // Nincs ilyen, hibás az azonosító
//
// Avn olyan, amit megváltoztatna, megnézem a típusazonosságot
//
    mov   ax,amirev                     // Erre változtatna
    xor   ax,amitva                     // A különbségek
    and   ax,$c000                      // A legfelsõ bitpáros egyforma?
    jnz   @marane                       // nem egyformák, másra nem lehet változtatni
    mov   cx,amirev                     // Erre változtatna
    shl   ecx,16                        // A felsõ részre teszem
    mov   cx,amitva                     // Ezt változtatom
    xor   eax,eax                       // Nullázok
    push  eax                           // CreateThread 6. paraméter
    push  eax                           // CreateThread 5. paraméter
    push  ecx                           // CreateThread 4. paraméter, a paraméter maga
    push  offset chgazo                 // CreateThread 3. paraméter, a thread kódjának címe
    push  eax                           // CreateThread 2. paraméter
    push  eax                           // CreateThread 1. paraméter
    push  eax                           // CreateEvent 4. paraméter, nincs neve
    push  eax                           // CreateEvent 3. paraméter, nincs jelezve alapban
    push  1                             // CreateEvent 2. paraméter, kézzel piszkálom
    push  eax                           // CreateEvent 1. paraméter, nincs Security Attributes
    call  CreateEvent                   // Várakozási handle készítés
    mov   [varuze],eax                  // Erre fogok várakozni
    call  CreateThread                  // Elkészítem a felmérést végrehajtó Thread-et
    or    eax,eax                       // Sikeres volt?
    jz    @hibava                       // Nem, hibával vissza
    mov   [felhnd],eax                  // Thread handle kitöltve
//
// A Thread-nek maximális prioritást adok
//
    push  THREAD_PRIORITY_TIME_CRITICAL // SetThreadPriority 2. paraméter
    push  eax                           // SetThreadPriority 1. paraméter
    call  SetThreadPriority             // Megemelem a prioritását
    or    eax,eax                       // Sikeres volt?
    jnz   @rendav                       // Igen, sikeres volt
  @hibava:
    call  GetLastError                  // Beolvasom a hibakódot
    jmp   @hibret                       // Hibakóddal vissza
  @rendav:
    xor   eax,eax                       // NO_ERROR kóddal jelzem, hogy sikeres volt
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A förmver frissítés indítása.                                                   //
//                                                                                  //
//  Paraméterek:                                                                    //
//                (in)  filnam      A frissítésre használandó fájl neve             //
//                (out) msgert      Sikeres hívás esetén a frissítési csomagok      //
//                                  száma, egyébként a hibához tartozó érték        //
//                                  üzenet kódja (message code)                     //
//                (in)  amitir      A frissítendõ panel azonosítója                 //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    A frissítés sikeresen elindult        //
//                ERROR_DLL_INIT_FAILED       A DLL még nem volt elindítva          //
//                ERROR_OPEN_FAILED           A megadott fájlt nem sikerült         //
//                                            megnyitni                             //
//                ERROR_MOD_NOT_FOUND         A megadott fájl nem förmver           //
//                                            frissítési adatokat tartalmaz         //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLLDLL_Upgrade(filnam: PChar; var drbkod: Dword; amitir: Word): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibakód
    mov   edx,[pwndfu]                  // WNDProc értéke
    or    edx,edx                       // Volt már?
    jz    @hibret                       // Visszatérek hibajellel
    mov   ax,amitir                     // Az elõtag
    xor   ecx,ecx                       // Nincs elõtag vizsgálat
    call  ervazo                        // Azonosító lekérdezés
    jnz   @hibret                       // Hibás az azonosító
    push  ebx                           // Elrontom
    push  esi                           // Elrontom
    xor   eax,eax                       // Nullázok
    push  eax                           // CreateFile 7. paraméter, nincs Overlapped elem
    push  FILE_ATTRIBUTE_NORMAL         // CreateFile 6. paraméter, normál fájl
    push  OPEN_EXISTING                 // CreateFile 5. paraméter, megnyitási mód
    push  eax                           // CreateFile 4. paraméter, nincs Security mód
    push  FILE_SHARE_READ               // CreateFile 3. paraméter, a továbbiak ezt tehetik meg
    push  GENERIC_READ                  // CreateFile 2. paraméter, csak olvasni akarom
    push  filnam                        // CreateFile 1. paraméter, a fájl neve
    call  CreateFile                    // Megnyitom, vagy legalábbis megpróbálom
    mov   ebx,eax                       // Átmásolom
    inc   eax                           // Sikerült megnyitni? (INVALID_HANDLE_VALUE + 1 = 0)
    jz    @openes                       // Nem sikerült
    xor   eax,eax                       // Nullázok
    xchg  eax,[upglei]                  // A leíró értékének beolvasása
    or    eax,eax                       // Volt elõzõ értéke?
    jz    @eloern                       // Nem volt elõzõ értéke
    push  eax                           // GloablFree 1. paraméter, a puffer címe
    call  GlobalFree                    // Eldobom az elõzõ puffert
  @eloern:
    push  0                             // GetFileSize 2. paraméter, a magasab 32 bit címe
    push  ebx                           // GetFileSize 1. paraméter, a fájl Handle értéke
    call  GetFileSize                   // Beolvasom a hosszt
    mov   esi,eax                       // Másolat a hosszról
    xor   edx,edx                       // A magas részt nulláztam, mert osztásra készülök
    mov   ecx,67                        // A rekordhossz
    div   ecx                           // EAX <- hányados, EDX <- maradék
    or    edx,edx                       // A maradék nulla?
    jnz   @fihopo                       // Nem, ez fájl hossz problémát vetít elõre
    test  eax,111b                      // 8-al osztható?
    jnz   @fihopo                       // Nem, ez fájl hossz problémát vetít elõre
    mov   edx,drbkod                    // A válasz címe
    mov   [edx],eax                     // Átadom a hibakód helyére
    push  eax                           // Késõbbre a rekordszám
    lea   eax,[esi + SIZUPG]            // A foglalandó hossz
    push  eax                           // GlobalAlloc 2. paraméter, a foglalandó hossz
    push  GMEM_FIXED OR GMEM_ZEROINIT   // GlobalAlloc 1. paraméter, a foglalás módja
    call  GlobalAlloc                   // Lefoglalom a puffert
    mov   [upglei],eax                  // Kitöltöm a címmel
    pop   edx                           // Rekordszám vissza
    mov   [eax + UPGPCK.packdb],edx     // Rekordszám kitöltés
    mov   dx,amitir                     // Az azonosító amit módosítok
    mov   [eax + UPGPCK.devazo],dx      // Azonosító kitöltés
    lea   ecx,[eax + SIZUPG]            // Ez a fájlpuffer címe
    push  eax                           // Hely a stackben
    mov   eax,esp                       // A hely címe
    xor   edx,edx
    push  edx                           // ReadFile 5. paraméter, Overlapped mûvelet nincs
    push  eax                           // ReadFile 4. paraméter, a válasz címe
    push  esi                           // ReadFile 3. paraméter, a beolvasás hossza
    push  ecx                           // ReadFile 2. paraméter, a puffer címe
    push  ebx                           // ReadFile 1. paraméter, a fájl Handle értéke
    call  ReadFile                      // Beolvasom a fájlt
    pop   eax                           // Eldobom a válasz hosszát
    push  ebx                           // CloseHandle 1. paraméter
    call  CloseHandle                   // Lezárom
    call  indpck                        // Elindítom a frissítés menetét
    xor   eax,eax                       // NO_ERROR kóddal lépek ki
    jmp   @befkil                       // Befejem
  @fihopo:
    push  ebx                           // CloseHandle 1. paraméter
    call  CloseHandle                   // Lezárom
    mov   eax,ERROR_FILE_INVALID        // Kilépési hibakód
    mov   edx,drbkod                    // A válasz címe
    mov   [edx],eax                     // Átadom a hibakód helyére
    jmp   @befkil                       // Befejem
  @openes:
    call  GetLastError                  // Beolvasom a hibakódot
    mov   edx,drbkod                    // A válasz címe
    mov   [edx],eax                     // Átadom a hibakód helyére
    mov   eax,ERROR_OPEN_FAILED         // Kilépési hibakód
  @befkil:
    pop   esi                           // Rontott vissza
    pop   ebx                           // Rontott vissza
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A LED lámpa RGB összetevõinek beállítása.                                       //
//                                                                                  //
//  Paraméterek:                                                                    //
//                (in)  rgbert      A beállítandó RGB értékek táblázata             //
//                (in)  amital      A beállítandó LED-lámpa azonosítója             //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    A beállítás sikeresen elindult        //
//                ERROR_DLL_INIT_FAILED       A DLL még nem volt elindítva          //
//                ERROR_INVALID_DATA          Az azonosító típusjelölõ bitpárosa    //
//                                            nem "SLLELO" érték, azaz nem          //
//                                            LED lámpa panel kerül megszólításra   //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLLDLL_LEDLampa(rgbert: HABASZ; amital: Word): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibakód
    mov   edx,[pwndfu]                  // WNDProc értéke
    or    edx,edx                       // Volt már?
    jz    @hibret                       // Visszatérek hibajellel
    mov   ax,amital                     // Ezt küldte
    mov   ecx,SLLELO                    // A kívánt elõtag
    call  ervazo                        // Azonosító lekérdezés
    jnz   @hibret                       // Hibás az azonosító
    mov   edx,offset sajpuf             // Az üzenet puffere
    mov   cx,amital                     // Ezt küldte
    mov   [edx + USB_buf.address],cx    // Ezt kell megváltoztatni
    mov   [edx + USB_buf.tipus],LEDLRG  // A kérés kódja
    mov   eax,Dword ptr rgbert          // Az RGB paraméter
    mov   dword ptr [edx + USB_buf.ledszb],eax// Átadom az RGB értékeket
    push  edx                           // UsbHidWrite 2. paraméter, a puffer címe
    push  0                             // UsbHidWrite 1. paraméter, az eszköz sorszáma
    call  UsbHidWrite                   // Elindítom a LED lámpa beállítást
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A LED nyíl RGB összetevõinek és irányának beállítása.                           //
//                                                                                  //
//  Paraméterek:                                                                    //
//                (in)  rgbert      A beállítandó RGB értékek táblázata             //
//                (in)  jobrai      A beállítandó irány (jobbra = True)             //
//                (in)  amital      A beállítandó LED nyíl azonosítója              //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    A beállítás sikeresen elindult        //
//                ERROR_DLL_INIT_FAILED       A DLL még nem volt elindítva          //
//                ERROR_INVALID_DATA          Az azonosító típusjelölõ bitpárosa    //
//                                            nem "SLNELO" érték, azaz nem          //
//                                            LED nyíl panel kerül megszólításra    //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLLDLL_LEDNyil(rgbert: HABASZ; jobrai: BOOL; amital: Word): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibakód
    mov   edx,[pwndfu]                  // WNDProc értéke
    or    edx,edx                       // Volt már?
    jz    @hibret                       // Visszatérek hibajellel
    mov   ax,amital                     // Ezt küldte
    mov   ecx,SLNELO                    // A kívánt elõtag
    call  ervazo                        // Azonosító lekérdezés
    jnz   @hibret                       // Hibás az azonosító
    mov   edx,offset sajpuf             // Az üzenet puffere
    mov   cx,amital                     // Ezt küldte
    mov   [edx + USB_buf.address],cx    // Ezt kell megváltoztatni
    mov   [edx + USB_buf.tipus],NYILRG  // A kérés kódja
    mov   eax,Dword ptr rgbert          // Az RGB paraméter
    mov   dword ptr [edx + USB_buf.ledszb],eax// Átadom az RGB értékeket
    mov   eax,jobrai                    // Az irány
    or    eax,eax                       // False?
    jz    @marafa                       // Igen, az is marad
    mov   al,1                          // Legyen True
  @marafa:
    mov   [edx + USB_buf.lednir],al     // Átadom az irány értékeket
    push  edx                           // UsbHidWrite 2. paraméter, a puffer címe
    push  0                             // UsbHidWrite 1. paraméter, az eszköz sorszáma
    call  UsbHidWrite                   // Elindítom a LED nyíl beállítást
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  Hangstring lejátszás indítása.                                                  //
//                                                                                  //
//  Paraméterek:                                                                    //
//                (in)  hangho      A hangtáblázat lejátszandó elemeinek száma      //
//                (in)  amitku      A lejátszandó hangok táblázata                  //
//                (in)  amital      A hnagszóró panel azonosítója                   //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    A beállítás sikeresen elindult        //
//                ERROR_DLL_INIT_FAILED       A DLL még nem volt elindítva          //
//                ERROR_INVALID_DATA          Az azonosító típusjelölõ bitpárosa    //
//                                            nem "SLHELO" érték, azaz nem          //
//                                            hangszóró panel lett megszólítva      //
//                ERROR_BAD_LENGTH            A hanghossz 0, vagy nagyobb mint 16   //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLLDLL_Hangkuldes(hangho: Integer;const amitku: HANGLA; amital: Word): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibakód
    mov   edx,[pwndfu]                  // WNDProc értéke
    or    edx,edx                       // Volt már?
    jz    @hibret                       // Visszatérek hibajellel
    mov   ax,amital                     // Ezt küldte
    mov   ecx,SLHELO                    // A kívánt elõtag
    call  ervazo                        // Azonosító lekérdezés
    jnz   @hibret                       // Hibás az azonosító
    mov   edx,offset sajpuf             // Az üzenet puffere
    mov   cx,amital                     // Ezt küldte
    mov   [edx + USB_buf.address],cx    // Ezt kell megváltoztatni
    mov   eax,ERROR_BAD_LENGTH          // Hibakód
    mov   ecx,hangho                    // Ennyi hangelemet tartalmaz atáblázat
    or    ecx,ecx                       // Nulla az elemszám?
    jz    @hibret                       // Nem lehet nulla a hossz
    cmp   ecx,16                        // Ennél nagyobb?
    ja    @hibret                       // Igen, akkor hibás a hossz
    imul  ecx,ecx,SIZHTB                // Ennyi bájtból áll
    mov   [edx + USB_buf.counter],cl    // A kérés bájtszáma
    mov   al,HANGIN OR $80              // Ha hosszú küldés lesz
    cmp   cl,30                         // Van ennyi?
    ja    @marahk                       // Több is, marad a hosszú kérés
    mov   al,HANGIN                     // Rövid küldés lesz
  @marahk:
    mov   [edx + USB_buf.tipus],al      // A kérés kódja
    push  edi                           // Elrontom
    push  esi                           // Elrontom
    lea   edi,[edx + USB_buf.hangtb]    // Ahova tenni kell
    mov   esi,amitku                    // Itt van a lista
    cld                                 // Elõrefele másoljon
    rep   movsb                         // Átmásolom
    pop   esi                           // Vissza a rontott
    pop   edi                           // Vissza a rontott
    push  edx                           // UsbHidWrite 2. paraméter, a puffer címe
    push  0                             // UsbHidWrite 1. paraméter, az eszköz sorszáma
    call  UsbHidWrite                   // Elindítom a hangküldést
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A DLL által elérhetõ panel állapotának lekérdezése.                             //
//                                                                                  //
//  Paraméter:                                                                      //
//                (in)  amitke      A lekérdezenõ panel azonosítója                 //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    A cím sikeresenn átadásra került      //
//                ERROR_DLL_INIT_FAILED       A DLL még nem volt elindítva          //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLDLL_GetStatus(amitke: Word): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibakód
    mov   edx,[pwndfu]                  // WNDProc értéke
    or    edx,edx                       // Volt már?
    jz    @hibret                       // Visszatérek hibajellel
    mov   ax,amitke                     // Ezt küldte
    xor   ecx,ecx                       // Az elõtagot nem kell vizsgálni
    call  ervazo                        // Azonosító lekérdezés
    jnz   @hibret                       // Hibás az azonosító
    mov   edx,offset sajpuf             // Az üzenet puffere
    mov   cx,amitke                     // Ezt küldte
    mov   [edx + USB_buf.address],cx    // Ezt kell megváltoztatni
    mov   [edx + USB_buf.tipus],STATER  // A kérés kódja
    push  edx                           // UsbHidWrite 2. paraméter, a puffer címe
    push  0                             // UsbHidWrite 1. paraméter, az eszköz sorszáma
    call  UsbHidWrite                   // Elindítom a státuszkérést
  @hibret:
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  Adott teendõ táblázat végrehajtásának elindítása.                               //
//                                                                                  //
//  Paraméter:                                                                      //
//                (in)  hanydb      A végrehajtandó táblázat mérete                 //
//                (in)  tblveg      A végrehajtandó táblázat címe                   //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    A végrehajtás sikeresen elindult      //
//                ERROR_DLL_INIT_FAILED       A DLL még nem volt elindítva          //
//                ERROR_REQ_NOT_ACCEP         Jelnleg éppen fut egy végrehajtás     //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//  A végrehajtás végérõl LISVAL üzenet megy, aminek LPARAM értéke tájékoztat       //
//  a végrehajtásról.                                                               //
//                NO_ERROR                    A végrehajtás sikeresen befejezõdött  //
//                ERROR_INVALID_DATA          Az azonosító típusjelölõ bitpárosa    //
//                                            hibás, vagy nincs ilyen eszköz        //
//                ERROR_BAD_LENGTH            A hanghossz 0, vagy nagyobb mint 16   //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLDLL_SetLista(hanydb: Integer; const tblveg:LISTBL): Dword; stdcall; Assembler;
asm
    mov   eax,ERROR_DLL_INIT_FAILED     // Hibakód
    mov   edx,[pwndfu]                  // WNDProc értéke
    or    edx,edx                       // Volt már?
    jz    @hibret                       // Visszatérek hibajellel
    mov   eax,ERROR_REQ_NOT_ACCEP       // Hibakód
    mov   edx,offset belfut             // A futásjelzõ címe
    xor   ecx,ecx                       // Nullázáshoz
    or    cl,[edx]                      // Beolvasom az állapotot
    jnz   @hibret                       // Most még fut, visszatérek hibajellel
    mov   [belakt],ecx                  // A kezdõ offszet
    inc   byte ptr [edx]                // Futásjelzés indítás (1 lesz)
    mov   eax,hanydb                    // A lista elemszáma
    mov   edx,tblveg                    // A kapott lista paraméter címe
    mov   [belmax],eax                  // Átmásoltam
    mov   [belpoi],edx                  // Kitettem
    xor   eax,eax                       // Nullázáshoz
    mov   [belakt],eax                  // A kezdõ offszet
    call  belkoi                        // Elindítom az elsõ elemet
    xor   eax,eax                       // NO_ERROR
  @hibret:
end;

procedure statim(hwnd: THandle; uMsg: Uint; idEvent: Uint; dwTime: Dword); stdcall; Assembler;
var
  timerb: USB_buf;
asm
    push  [timtar]                      // KillTimer 2. paraméter, a timer azonosítója
    push  [msghnd]                      // KillTimer 1. paraméter, a window paraméter
    call  KillTimer                     // Leállítom az idõzítést
    lea   ecx,timerb                    // A puffer címe
    xor   eax,eax                       // Nullázás
    mov   [ecx + USB_buf.reportID],al   // A puffer elejét nullázni kell
    mov   [ecx + USB_buf.tipus],STATER  // Ez az indítás
    mov   dx,[aktadr]                   // Az érvényes azonosító
    mov   [ecx + USB_buf.address],dx    // Ez az azonosító legyen
    push  ecx                           // UsbHidWrite 2. paraméter, a puffer címe
    push  eax                           // UsbHidWrite 1. paraméter, az eszköz sorszáma
    inc   [diruze]                      // Direkt üzenet megy
    call  UsbHidWrite                   // Elindítom a státsuzkérést
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// E DLL verziójának és teljes nevének lekérdezése.                                 //
//                                                                                  //
//  Paraméterek:  (out)  versms  A DLL verziójának magasabbik része                 //
//                (out)  versls  A DLL verziójának alacsonyabbik része              //
//                (out)  dllnam  A DLL neve teljes elérési útvonallal               //
//                (in)   namlen  A DLL név helyének mérete                          //
//                       (a szükséges terület maximális mérete: MAX_PATH)           //
//                                                                                  //
//  Viszzatérési érték:                                                             //
//                NO_ERROR                    Sikeres mûvelet                       //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function verdll(var versms, versls: Dword; dllnam: PChar; namlen: Dword): Dword; stdcall; Assembler;
asm
    push  edi                           // Mentem, mert használni fogom
    push  esi                           // Mentem, mert használni fogom
    mov   edi,dllnam                    // A "dllnam" értéke többször is kell
    push  namlen                        // GetModuleFileName 3. paraméter
    push  edi                           // GetModuleFileName 2. paraméter
    push  [HInstance]                   // GetModuleFileName 1. paraméter
    call  GetModuleFileName             // Bekérem a DLL névét és helyét
    push  eax                           // Helyet csinálok a válasznak
    push  esp                           // GetFileVersionInfoSize 2. paraméter
    push  edi                           // GetFileVersionInfoSize 1. paraméter
    call  GetFileVersionInfoSize        // Beolvastatom a hosszat
    pop   edx                           // Eldobom a paramétert
    or    eax,eax                       // Sikeres lekérdezés?
    jnz   @nevoke                       // Igen, sikeres volt
    call  GetLastError                  // Hibakód bekérés
    jmp   @rethik                       // Visszatérés a hibakóddal
  @nevoke:
    mov   esi,eax                       // Másolat a hosszról
    sub   esp,eax                       // A stackben csinálok ennyi helyet
    mov   eax,esp                       // EAX <- a puffer címe
    xor   edx,edx                       // A válaszhely címe
    push  '\'                           // Paraméterként mentem, de válaszhely is
    mov   ecx,esp                       // A válaszhely címe
    push  edx                           // VerQueryValue 4. paraméter
    push  ecx                           // VerQueryValue 3. paraméter
    push  edx                           // VerQueryValue 2. paraméter
    push  eax                           // VerQueryValue 1. paraméter
    push  eax                           // GetFileVersionInfo 4. paraméter
    push  esi                           // GetFileVersionInfo 3. paraméter
    push  esi                           // GetFileVersionInfo 2. paraméter
    push  edi                           // GetFileVersionInfo 1. paraméter
    call  GetFileVersionInfo            // Beolvasom
    call  VerQueryValue                 // Átalakítom
    pop   edx                           // Ez a válaszpuffer címe (eliminálás is!)
    mov   ecx,[edx + TVSFixedFileInfo.dwProductVersionMS]// Másolat
    mov   eax,[edx + TVSFixedFileInfo.dwProductVersionLS]// Másolat
    add   esp,esi                       // A foglalt stack felszabadítás
    mov   edi,versms                    // Ide másolok ("Version_MS" paraméter címe)
    mov   esi,versls                    // Ide másolok ("Version_LS" paraméter címe)
    mov   [edi],ecx                     // A "Version_MS" válasz
    mov   [esi],eax                     // A "Version_LS" válasz
    xor   eax,eax                       // Visszatérés NO_ERROR-al
  @rethik:
    pop   esi                           // Vissza a rontott
    pop   edi                           // Vissza a rontott
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//   A csatlakoztatott eszközök leválasztásának figyelése, új eszközök              //
//   csatlakoztatásának észlelése.                                                  //
//   az erõforrásainak felszabadításával.                                           //
//                                                                                  //
//    Input:  Window  <- Az üzenet handle tartalma                                  //
//            Message <- Az üzenet kódja                                            //
//            wParam  <- Az üzenet wParam értéke                                    //
//            lParam  <- Az üzenet lParam értéke                                    //
//                                                                                  //
//    Output: Ha nincs az eszközök számában változás: -> az eredeti pontra tovább   //
//            Ha van eltávolított eszköz használatban -> leválasztás és üzenet a    //
//                                                       változásról                //
//            Ha van csatlakoztatható eszköz          -> csatlakoztatás és üzenet   //
//                                                       a változásról              //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function wndprc(Window: HWND; Message, wParam, lParam: Dword): Dword; stdcall; Assembler;
asm
//
// Üzenetkód figyelés, ha nem nekem szól, továbbküldöm
//
    mov   ecx,[msgkod]                  // A saját üzenetszámom
    cmp   Message,ecx                   // A "Message" paraméterben ez a kód?
    jnz   @maskot                       // Nem, akkor standard eljárás
//
// Nekem üzentek, de a saját DLL-em üzent?
//
    cmp   wParam,LISVAL                 // Átüzenés?
    jz    @maskot                       // Nem, akkor standard eljárás
    mov   edx,lParam                    // Ezt üzente
    mov   eax,[diruze]                  // Direkt üzenet számláló
    or    eax,eax                       // Puffer jött?
    jnz   @nempuf                       // Nem, saját üzenet megy
//
// Nekem üzentek, de mit is?
//
    or    edx,edx                       // Nulla?
    jnz   @vanpuc                       // Puffer cím volt
//
// Az USB eszközök számának változásáról üzen
//
  @nelive:
    call  UsbGetNumdev                  // Az aktuális mennyiség lekérdezése
    or    eax,eax                       // Van valamennyi?
    jnz   @valvan                       // Igen, van
    push  eax                           // UsbHidDevClose 1. paraméter, az eltávvolítandó sorszáma
    call  UsbHidDevClose                // Eltávolítottam
    push  eax                           // CallWindowProc 5. paraméter, az üzenethez kapcsolódó érték (lParam)
    push  USBREM                        // CallWindowProc 4. paraméter, az üzenet kódja (wParam)
    push  Message                       // CallWindowProc 3. paraméter, az üzenet száma
    push  Window                        // CallWindowProc 2. paraméter, kinek (window) szól
    push  [pwndfu]                      // CallWindowProc 1. paraméter, a lánc eleme, ahol folytassa
    call  CallWindowProc                // Meghívom a továbbiakat
//
// Ha volt elõzõleg leíró, akkor azt felszabadítom
//
    xor   eax,eax                       // Nullázok
    xchg  eax,[offset devusb + DEVSEL.produc]// Az elem szöveges leírója
    or    eax,eax                       // Kell visszaadni?
    jz    @nemadp                       // Most nem kell
    push  eax                           // GloablFree 1. paraméter, a puffer címe
    call  GlobalFree                    // Eldobom a stringet
  @nemadp:
    xor   eax,eax                       // Nullázok
    xchg  eax,[offset devusb + DEVSEL.manufa]// Az elem gyártó  leírója
    or    eax,eax                       // Kell visszaadni?
    jz    @sajint                       // Most nem kell, sikeresen eltávolítottam
    push  eax                           // GloablFree 1. paraméter, a puffer címe
    call  GlobalFree                    // Eldobom a stringet
    call  eszrem                        // Eltávolítom az eszközleírókat
    jmp   @sajint                       // Feldolgoztam
  @valvan:
    push  esi                           // Elrontanám
    mov   esi,eax                       // Másolom a darabszámot
  @esekoz:
    dec   esi                           // Ez az utolsó?
    jz    @macsae                       // Igen, ez az
    push  esi                           // UsbHidDevClose 1. paraméter, az eltávvolítandó sorszáma
    call  UsbHidDevClose                // Eltávolítottam
    jmp   @esekoz                       // Vissza, hogy zárhassam a többit, ha kell
  @macsae:
    pop   esi                           // Rontott vissza
    call  SLDLL_Felmeres                // Elindítom a felmérést
    jmp   @sajint                       // Feldolgoztam
//
// Puffert küldött, a válasz szerint elágazok
//
  @vanpuc:
    mov   eax,[diruze]                  // Direkt üzenet számláló
    or    eax,eax                       // Puffer jött?
    jnz   @nempuf                       // Nem, direkt üzenet megy
//
// Beolvasom a puffer típusát
//
    mov   al,[edx + USB_buf.tipus]      // A típus másolata
//
// A típustól függõ üzenet kialakítása, ha státuszkérés, simán mehet
//
    mov   ecx,STATKV                    // Az üzenet típusa
    cmp   al,STATER                     // Csak simán státuszt kér?
    jz    @aknoku                       // Igen, alapstátusz küldés
//
// Ha a három elem valamelyikét állítom, megnézem, hogy lista-kérés volt-e
//
    mov   ecx,HANGEL                    // Az üzenet típusa
    cmp   al,HANGIN                     // Hanstring indítás?
    jz    @aknokl                       // Igen, alapstátusz küldés
    mov   ecx,LEDRGB                    // Az üzenet típusa
    cmp   al,LEDLRG                     // LED értékek beállítása?
    jz    @aknokl                       // Igen, alapstátusz küldés
    cmp   al,NYILRG                     // A nyíl RGB és irány értékek beállítása?
    jnz   @neledj                       // Nem, más van
    mov   ecx,NYIRGB                    // Az üzenet típusa
//
// A három elem beállításkérés volt
//
  @aknokl:
    cmp   [belfut],0                    // Most éppen fut?
    jz    @aknoku                       // Nem, akkor simán elküldöm
    call  belkoi                        // Indítom a következõ elemet
    jmp   @sajint                       // Feldolgoztam
//
// A válasz általános státusz lesz
//
  @aknoku:
    lea   eax,[edx + USB_buf.statta]    // Itt vannak a státusz RGB értékek
    push  eax                           // CallWindowProc 5. paraméter, az üzenethez kapcsolódó érték (lParam)
    push  ecx                           // CallWindowProc 4. paraméter, az üzenet típusa (wParam)
    push  Message                       // CallWindowProc 3. paraméter, az üzenet száma
    push  Window                        // CallWindowProc 2. paraméter, kinek (window) szól
    push  [pwndfu]                      // CallWindowProc 1. paraméter, a lánc eleme, ahol folytassa
    call  CallWindowProc                // Meghívom a továbbiakat
    jmp   @sajint                       // Megüzentem az állapotot
//
// Nem általános státsuz válasz kell
//
  @neledj:
    cmp   al,SFLASH                     // Frissítési lépés információ jött?
    jnz   @maskoj                       // Nem, más van
//
// A fömver frissítés folyamatát kell követni
//
    movzx eax,[edx + USB_buf.counter]   // A hibajelzõ másolata
    mov   ecx,[upglei]                  // A frissító struktúra címe
    mov   [ecx + UPGPCK.errcod],al      // A hibakódot átadom
    push  eax                           // A hibakódot elmentem
    push  ecx                           // CallWindowProc 5. paraméter, az üzenethez kapcsolódó érték (lParam)
    push  FIRMUZ                        // CallWindowProc 4. paraméter, az üzenet kódja (wParam)
    push  Message                       // CallWindowProc 3. paraméter, az üzenet száma
    push  Window                        // CallWindowProc 2. paraméter, kinek (window) szól
    push  [pwndfu]                      // CallWindowProc 1. paraméter, a lánc eleme, ahol folytassa
    call  CallWindowProc                // Meghívom a továbbiakat
    pop   eax                           // Hibakód vissza
    or    al,al                         // Volt hiba?
    jnz   @sajint                       // Igen, csak befejezem
    call  indpck                        // Folytatom a következõ elem elküldésével
    jmp   @sajint                       // Megüzentem az állapotot
//
// Nem kódfissítés megy, esetleg újra kell indítan?
//
  @maskoj:
    cmp   al,KFLASH                     // Reset jelzés jött?
    jnz   @elkupv                       // Nem, akkor választ vizsgálok
//
// A fömver frissítés vége, újraindításról üzenek
//
    xor   eax,eax                       // Nullázáshoz
    xchg  eax,[upglei]                  // A pointer amit vissza kell adni
    push  eax                           // GlobalFree 1. paraméter, a blokk címe
    call  GlobalFree                    // Visszaadom a puffert
    push  eax                           // CallWindowProc 5. paraméter, az üzenethez kapcsolódó érték (lParam)
    push  FIRMEN                        // CallWindowProc 4. paraméter, az üzenet kódja (wParam)
    push  Message                       // CallWindowProc 3. paraméter, az üzenet száma
    push  Window                        // CallWindowProc 2. paraméter, kinek (window) szól
    push  [pwndfu]                      // CallWindowProc 1. paraméter, a lánc eleme, ahol folytassa
    call  CallWindowProc                // Meghívom a továbbiakat
    jmp   @sajint                       // Megüzentem az állapotot
//
// Saját eseményre várás vizsgálat
//
  @nempuf:
    dec   [diruze]                      // Direkt üzenet számláló csökkentés
  @elkupv:
    mov   [locpuf],edx                  // Ezt a puffert küldte
    mov   eax,[varuze]                  // A várakozás Handle értéke
    or    eax,eax                       // Várnak válaszra?
    jz    @maskot                       // Nem várnak, akkor üzenek
//
// Saját várakozás aktív, jelzem a pufferküldést
//
    push  [varuze]                      // SetEvent 1. paraméter, a jelzendõ Handle értéke
    call  SetEvent                      // Jött puffer jelzés
    jmp   @sajint                       // Feldolgoztam
  @maskot:
    push  lParam                        // CallWindowProc 5. paraméter, az üzenethez kapcsolódó érték (lParam)
    push  wParam                        // CallWindowProc 4. paraméter, az üzenethez kapcsolódó érték (wParam)
    push  Message                       // CallWindowProc 3. paraméter, az üzenet száma
    push  Window                        // CallWindowProc 2. paraméter, kinek (window) szól
    push  [pwndfu]                      // CallWindowProc 1. paraméter, a lánc eleme, ahol folytassa
    call  CallWindowProc                // Meghívom a továbbiakat
  @sajint:
end;

function feldev(vakvan: Pointer): Dword; stdcall; Assembler;
asm
    push  ebx                           // Rontani fogom
    push  esi                           // Rontani fogom
    push  edi                           // Rontani fogom
    mov   ecx,offset sajpuf             // A pufferem címe
    mov   [ecx + USB_buf.tipus],FEL485  // Ez az indítása a felmérésnek
    push  ecx                           // UsbHidWrite 2. paraméter, a puffer címe
    push  0                             // UsbHidWrite 1. paraméter, az eszköz sorszáma
    inc   [diruze]                      // Direkt üzenet megy
    call  UsbHidWrite                   // Elindítom a felmérést
    or    eax,eax                       // WAIT_OBJECT_0 a válasz?
    jnz   @timerb                       // Kilépek hibaüzenettel
    push  10000                         // WaitForSingleObject 2. paraméter, a várakozás ideje (10 sec.)
    push  [varuze]                      // WaitForSingleObject 1. paraméter, a várakozás Handle értéke
    call  WaitForSingleObject           // Kivárom a választ
    or    eax,eax                       // WAIT_OBJECT_0 a válasz?
    jnz   @timerb                       // Kilépek hibaüzenettel
    push  [varuze]                      // ResetEvent 1. paraméter, a várakozás Handle értéke
    call  ResetEvent                    // Törlöm, hogy újra várakozhassak rá
    mov   edx,[locpuf]                  // Az érkezett puffer címe
    mov   ax,[edx + USB_buf.esuadr]     // A cím
    mov   [aktadr],ax                   // Az aktuális cím
//
// Idõzítés indítás
//
  @felmfu:
    xor   eax,eax                       // Nullázás
    mov   edx,10                        // SetTimer 3. paraméter, az idõzítés (msec.-ben)
    push  offset statim                 // SetTimer 4. paraméter, a meghívandó rutin címe
    push  edx                           // SetTimer 3. paraméter, az idõzítés (msec.-ben)
    push  edx                           // SetTimer 2. paraméter, az azonosító
    push  [msghnd]                      // SetTimer 1. paraméter, a window paraméter
    call  SetTimer                      // Elindítom az idõzítõt
    mov   [timtar],eax                  // Elteszem az azonosítót
    push  200                           // WaitForSingleObject 2. paraméter, a várakozás ideje (200 msec.)
    push  [varuze]                      // WaitForSingleObject 1. paraméter, a várakozás Handle értéke
    call  WaitForSingleObject           // Várok érkezett pufferre
    or    eax,eax                       // WAIT_OBJECT_0 a válasz?
    jnz   @timerb                       // Kilépek hibaüzenettel
    push  [varuze]                      // ResetEvent 1. paraméter, a várakozás Handle értéke
    call  ResetEvent                    // Törlöm, hogy újra várakozhassak rá
//
// Megnézem, hogy tart-e még a lekérdezés
//
    mov   edx,[locpuf]                  // Az érkezett puffer címe
    mov   ax,[edx + USB_buf.esuadr]     // A cím
    mov   [aktadr],ax                   // Az aktuális cím
    xor   eax,eax                       // Nullázok
    mov   al,[edx + USB_buf.felmnu]     // A felmérés feladatszáma (0 lesz, ha vége a felmérésnek)
    or    eax,eax                       // Fut még a felmérés?
    jnz   @felmfu                       // A felmérés még fut
    mov   al,[edx + USB_buf.felmhi]     // A felmérés hibaszáma (0 esetén sikeres volt)
    or    eax,eax                       // Sikeres volt a felmérés?
    jnz   @felmhf                       // A felmérés hibára futott
    mov   al,[edx + USB_buf.darkby]     // A felmérés 16 bites azonosítóinak száma
    or    eax,eax                       // Sikeres volt a felmérés?
    jz    @felmth                       // A felmérésben nem lehet olyan, hogy egy sem
    cmp   al,[edx + USB_buf.darkby]     // Egyfoma a 16 bites és a 64 bites azonosítók száma?
    jnz   @felmda                       // Ha nem egyforma, akkor hiba van
//
// A megtalált azonosítók lekérdezése
//
    mov   ecx,offset sajpuf             // A pufferem címe
    mov   [ecx + USB_buf.tipus],AZOLEK  // Lekérdezés
    push  ecx                           // UsbHidWrite 2. paraméter, a puffer címe
    push  0                             // UsbHidWrite 1. paraméter, az eszköz sorszáma
    call  UsbHidWrite                   // Elindítom a felmérést
    or    eax,eax                       // WAIT_OBJECT_0 a válasz?
    jnz   @timerb                       // Kilépek hibaüzenettel
    push  200                           // WaitForSingleObject 2. paraméter, a várakozás ideje (200 msec.)
    push  [varuze]                      // WaitForSingleObject 1. paraméter, a várakozás Handle értéke
    call  WaitForSingleObject           // Kivárom a választ
    or    eax,eax                       // WAIT_OBJECT_0 a válasz?
    jnz   @timerb                       // Kilépek hibaüzenettel
    push  [varuze]                      // ResetEvent 1. paraméter, a várakozás Handle értéke
    call  ResetEvent                    // Törlöm, hogy újra várakozhassak rá
    mov   edx,[locpuf]                  // Az érkezett puffer címe
    movzx ecx,[edx + USB_buf.counter]   // A megtalált eszközök darabszáma
    mov   [drb485],ecx                  // A darabszámot elteszem
    imul  eax,ecx,SIZAPU                // A foglalandó puffer hossza
    push  eax                           // GlobalAlloc 2. paraméter, a foglalandó hossz
    push  GMEM_FIXED OR GMEM_ZEROINIT   // GlobalAlloc 1. paraméter, a foglalás módja
    call  GlobalAlloc                   // Helyet foglalok a leírónak
    mov   [dev485],eax                  // A puffer címe
//
// A címeket kitöltöm
//
    mov   ecx,[drb485]                  // Az eszközök száma
    mov   edx,[locpuf]                  // Az érkezett puffer címe
    lea   edx,[edx + USB_buf.hanlis]    // Az elsõ küldött elem címe
    lea   ebx,[eax + DEVSEL.azonos]     // Az elsõ kitöltendõ elem címe
  @azokci:
    mov   ax,word ptr [edx]             // Az azonosító beolvasás
    mov   [ebx],ax                      // Átadtam
    lea   edx,[edx + 2]                 // A következõre a forrás
    lea   ebx,[ebx + SIZAPU]            // A következõre a cél
    loop  @azokci                       // Mindegyiket átpakolom
//
// A jellemzõket kérdezem le
//
    xor   esi,esi                       // Az elemek száma
    mov   ebx,offset sajpuf             // Az USB pufferem címe
    mov   edi,[dev485]                  // A jellemzõk pufferének címére
  @kovlek:
    xor   eax,eax                       // Nullázáshoz
//
// A verzió és a verzió dátumának lekérdezése
//
    mov   [ebx + USB_buf.tipus],AZOTUL  // A lekérdezés
    mov   [ebx + USB_buf.counter],al    // A lekérdezés elsõ menet
    mov   dx,[edi + DEVSEL.azonos]      // A kitöltendõ cím
    mov   [ebx + USB_buf.address],dx    // A lekérdezés címértéke
    push  ebx                           // UsbHidWrite 2. paraméter, a puffer címe
    push  eax                           // UsbHidWrite 1. paraméter, az eszköz sorszáma
    call  UsbHidWrite                   // Elindítom a felmérést
    or    eax,eax                       // WAIT_OBJECT_0 a válasz?
    jnz   @timerb                       // Kilépek hibaüzenettel
    push  200                           // WaitForSingleObject 2. paraméter, a várakozás ideje (200 msec.)
    push  [varuze]                      // WaitForSingleObject 1. paraméter, a várakozás Handle értéke
    call  WaitForSingleObject           // Kivárom a választ
    or    eax,eax                       // WAIT_OBJECT_0 a válasz?
    jnz   @timerb                       // Kilépek hibaüzenettel
    push  [varuze]                      // ResetEvent 1. paraméter, a várakozás Handle értéke
    call  ResetEvent                    // Törlöm, hogy újra várakozhassak rá
    mov   edx,[locpuf]                  // Az érkezett puffer címe
//
// A verziólelemek átpakolása 5 hosszan
//
    lea   edx,[edx + USB_buf.kulver]    // A verzió adatok puffercíme
    lea   ecx,[edi + DEVSEL.idever]     // A kipakolandó adat címe
    mov   ax,[edx]                      // Ezt küldte (verzió h, verzió l)
    call  bcdtob                        // BCD-rõl binárisra alakítom az AL-t és az AH-t
    mov   [ecx],ax                      // Az értékek átadása
    mov   ax,[edx + 2]                  // Ezt küldte (év, hónap)
    call  bcdtob                        // BCD-rõl binárisra alakítom az AL-t és az AH-t
    mov   [ecx + 2],ax                  // Az értékek átadása
    mov   al,[edx + 4]                  // Ezt küldte (nap)
    call  bcdtob                        // BCD-rõl binárisra alakítom az AL-t és az AH-t
    mov   [ecx + 4],al                  // Az értékek átadása
//
// Második tulajdonság (az eszközleírás) lekérdezése
//
    inc   [ebx + USB_buf.counter]       // A lekérdezés második menet
    push  ebx                           // UsbHidWrite 2. paraméter, a puffer címe
    push  0                             // UsbHidWrite 1. paraméter, az eszköz sorszáma
    call  UsbHidWrite                   // Elindítom a felmérést
    or    eax,eax                       // WAIT_OBJECT_0 a válasz?
    jnz   @timerb                       // Kilépek hibaüzenettel
    push  200                           // WaitForSingleObject 2. paraméter, a várakozás ideje (200 msec.)
    push  [varuze]                      // WaitForSingleObject 1. paraméter, a várakozás Handle értéke
    call  WaitForSingleObject           // Kivárom a választ
    or    eax,eax                       // WAIT_OBJECT_0 a válasz?
    jnz   @timerb                       // Kilépek hibaüzenettel
    push  [varuze]                      // ResetEvent 1. paraméter, a várakozás Handle értéke
    call  ResetEvent                    // Törlöm, hogy újra várakozhassak rá
    mov   edx,[locpuf]                  // Az érkezett puffer címe
    lea   edx,[edx + USB_buf.kuluni]    // Az unikódú jellemzõ címe
    lea   ecx,[edi + DEVSEL.produc]     // A kipakolandó adat címe
    push  edx                           // Jelkit 2. paraméter, amit konvertálni kell
    push  ecx                           // Jelkit 1. paraméter, ahova a jellemzõ kerül
    call  jelkit                        // Átalakítom és kitöltöm a jellemzõt
//
// Harmadik tulajdonság (a gyártó) lekérdezése
//
    inc   [ebx + USB_buf.counter]       // A lekérdezés harmadik menet
    push  ebx                           // UsbHidWrite 2. paraméter, a puffer címe
    push  0                             // UsbHidWrite 1. paraméter, az eszköz sorszáma
    call  UsbHidWrite                   // Elindítom a felmérést
    or    eax,eax                       // WAIT_OBJECT_0 a válasz?
    jnz   @timerb                       // Kilépek hibaüzenettel
    push  200                           // WaitForSingleObject 2. paraméter, a várakozás ideje (200 msec.)
    push  [varuze]                      // WaitForSingleObject 1. paraméter, a várakozás Handle értéke
    call  WaitForSingleObject           // Kivárom a választ
    or    eax,eax                       // WAIT_OBJECT_0 a válasz?
    jnz   @timerb                       // Kilépek hibaüzenettel
    push  [varuze]                      // ResetEvent 1. paraméter, a várakozás Handle értéke
    call  ResetEvent                    // Törlöm, hogy újra várakozhassak rá
    mov   edx,[locpuf]                  // Az érkezett puffer címe
    lea   edx,[edx + USB_buf.kuluni]    // Az unikódú jellemzõ címe
    lea   ecx,[edi + DEVSEL.manufa]    // A kipakolandó adat címe
    push  edx                           // Jelkit 2. paraméter, amit konvertálni kell
    push  ecx                           // Jelkit 1. paraméter, ahova a jellemzõ kerül
    call  jelkit                        // Átalakítom és kitöltöm a jellemzõt
    lea   edi,[edi + SIZAPU]            // A következõ tárolóra lépk
    inc   esi                           // A következõ elem
    cmp   [drb485],esi                  // Elérte már a darabszámot
    jnz   @kovlek                       // Még lekérdezés lesz
    dec   esi                           // A legnagyobb index ez lesz
    push  esi                           // quicksort 2. paraméter, a jobboldali érték
    push  0                             // quicksort 1. paraméter, a baloldali érték
    call  quicksort                     // Lerendezem
    mov   edx,FELMOK                    // Az üzenet kódja (felmérés vége)
    mov   eax,[drb485]                  // A darabszámot átadom
    jmp   @simuzv                       // A felmérés végérõl üzenet megy
//
// A felmérés hibára futott, a 16 és 64 bites darabszám nem egyforma
//
  @felmda:
    mov   edx,FELMDE                    // Hibaüzenet
    jmp   @simuzv                       // Hibaüzenet megy
//
// A felmérés hibára futott, nincs egy darab sem, ilyen elvben sem lehet
//
  @felmth:
    mov   edx,FELMHD                    // Hibaüzenet
    jmp   @simuzv                       // Hibaüzenet megy
//
// A felmérés hibára futott, hibakód EAX-ben
//
  @felmhf:
    mov   edx,FELMHK                    // Hibaüzenet
    jmp   @simuzv                       // Hibaüzenet megy
//
// A válaszvárás ideje letelt
//
  @timerb:
    mov   edx,VALTIO                    // Hibaüzenet
  @simuzv:
    inc   [diruze]                      // Direkt üzenet megy
    push  eax                           // PostMessage 4. paraméter, a hibához kapcsolódó érték (lParam)
    push  edx                           // PostMessage 3. paraméter, a hiba kódja (wParam)
    push  [msgkod]                      // PostMessage 2. paraméter, az üzenet száma
    push  [msghnd]                      // PostMessage 1. paraméter, az üzenet window Handle értéke
    call  PostMessage                   // Üzenet megy a történtekrõl
  @lefuaz:
    xor   eax,eax                       // Nullázáshoz
    xchg  eax,[varuze]                  // EAX <- várakozás Handle
    push  eax                           // CloseHandle
    call  CloseHandle                   // Lezárom
    xor   eax,eax                       // Nullázáshoz
    xchg  eax,[felhnd]                  // EAX <- saját Thread-em Handle értéke
    push  eax                           // CloseHandle
    call  CloseHandle                   // Lezárom
    pop   edi                           // Rontott vissza
    pop   esi                           // Rontott vissza
    pop   ebx                           // Rontott vissza
end;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  Az azonosító megváltoztatásának kérése.                                         //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function chgazo(parrom: Dword): Dword; stdcall; Assembler;
asm
    mov   edx,offset sajpuf             // Ide teszem a paramétereket
    mov   [edx + USB_buf.tipus],AZOMOD  // A típust kitöltöm
    mov   ax,bx                         // Ezt kell megváltoztatni
    mov   [edx + USB_buf.address],ax    // A címet kitöltöm
    mov   eax,parrom                       // A paraméter
    shr   eax,16                        // Erre kell megváltoztatni
    mov   [edx + USB_buf.gepkou],ax     // Az új címet kitöltöm
    push  edx                           // UsbHidWrite 2. paraméter, a puffer címe
    push  0                             // UsbHidWrite 1. paraméter, az eszköz sorszáma
    inc   [diruze]                      // Direkt üzenet megy
    call  UsbHidWrite                   // Elindítom a változtatást
    or    eax,eax                       // Volt hiba?
    jnz   @visfel                       // Igen, akkor visszatérek
    push  800                           // WaitForSingleObject 2. paraméter, a várakozás ideje (800 msec.)
    push  [varuze]                      // WaitForSingleObject 1. paraméter, a várakozás Handle értéke
    call  WaitForSingleObject           // Kivárom a választ
    or    eax,eax                       // WAIT_OBJECT_0 a válasz?
    jnz   @visfel                       // Kilépek hibaüzenettel
    xor   ecx,ecx                       // Kezdõérték
    mov   edx,[dev485]                  // A leírók listája
    mov   ax,bx                         // Ezt változtatnám
  @kovmeg:
    cmp   ax,[edx + DEVSEL.azonos]      // Ilyen van a listában?
    jnz   @eznemo                       // Ez nem az
    mov   eax,parrom                    // A paraméter
    shr   eax,16                        // Erre kell megváltoztatni
    mov   [edx + DEVSEL.azonos],ax      // Átírtam
    jmp   @valkes                       // Meg van, átírtam
  @eznemo:
    lea   edx,[edx + SIZAPU]            // A következõre lépek
    inc   ecx                           // A következõre
    cmp   ecx,[drb485]                  // Elért a végére?
    jnz   @kovmeg                       // Még nem, folytatom
  @valkes:
    mov   ax,bx                         // Ezt változtatnám
    mov   edx,offset devusb             // Ez a paraméter címtárolója
    cmp   ax,[edx + DEVSEL.azonos]      // Az USB eszköznek ez a címe?
    jnz   @renmev                       // Nem az, mehet vissza sikeresen
    mov   eax,parrom                    // A paraméter
    shr   eax,16                        // Erre kell megváltoztatni
    mov   [edx + DEVSEL.azonos],ax      // Az USB eszköznek is ez a címe
  @renmev:
    xor   eax,eax                       // NO_ERROR amivel visszatérek
  @visfel:
    push  eax                           // Hibakód késõbbre
    xor   eax,eax                       // Nullázáshoz
    xchg  eax,[varuze]                  // EAX <- várakozás Handle
    push  eax                           // CloseHandle 1. paraméter, a zárandó Handle értéke
    call  CloseHandle                   // Lezárom
    xor   eax,eax                       // Nullázáshoz
    xchg  eax,[felhnd]                  // EAX <- saját Thread-em Handle értéke
    push  eax                           // CloseHandle
    call  CloseHandle                   // Lezárom
    pop   eax                           // A hibakód vissza
    inc   [diruze]                      // Direkt üzenet megy
    push  eax                           // PostMessage 4. paraméter, a hibához kapcsolódó érték (lParam)
    push  AZOOKE                        // PostMessage 3. paraméter, az üzenet kódja (wParam)
    push  [msgkod]                      // PostMessage 2. paraméter, az üzenet száma
    push  [msghnd]                      // PostMessage 1. paraméter, az üzenet window Handle értéke
    call  PostMessage                   // Üzenet megy a történtekrõl
end;

procedure jelkit(var erechr: PChar; const mibol: USBTUL); stdcall; Assembler;
var
  machar: array [0..1023] of Char;
asm
    push  esi                           // Elromlana
    push  edi                           // Elromlana
    mov   eax,erechr                    // A felszabadítandó puffer címe
    mov   eax,[eax]                     // Ez a puffer az
    or    eax,eax                       // Volt már foglalva?
    jz    @punefo                       // Még nem volt
    push  eax                           // GlobalFree 1. paraméter
    call  GlobalFree                    // Ez eredeti felszabadítva
  @punefo:
    push  mibol                         // lstrlenw 1. paraméter
    call  lstrlenw                      // Normál stringhossz megállapítás
    xor   ecx,ecx                       // Nullázok
    mov   edx,mibol                     // A forrás címe
    lea   esi,machar                    // Az eredmény címe
    push  ecx                           // WideCharToMultiByte 8. paraméter
    push  ecx                           // WideCharToMultiByte 7. paraméter
    push  1024                          // WideCharToMultiByte 6. paraméter
    push  esi                           // WideCharToMultiByte 5. paraméter
    push  eax                           // WideCharToMultiByte 4. paraméter
    push  mibol                         // WideCharToMultiByte 3. paraméter
    push  WC_COMPOSITECHECK	            // WideCharToMultiByte 2. paraméter
    push  CP_ACP	                      // WideCharToMultiByte 1. paraméter
    call  WideCharToMultiByte           // Átkonvertálom
    mov   byte ptr [esi + eax],0        // Stringvégjel
    inc   eax                           // Hely a stringvégnek
    push  eax                           // GlobalAlloc 2. paraméter
    push  GMEM_FIXED                    // GlobalAlloc 1. paraméter
    call  GlobalAlloc                   // Lefoglalom a puffert
    mov   edx,erechr                    // A felszabadítandó puffer címe
    mov   [edx],eax                     // Ez a puffer az
    push  esi                           // lstrcpya 2. paraméter, amit másolni kell
    push  eax                           // lstrcpya 1. ahova másolni kell
    call  lstrcpya                      // Belemásolom
    pop   edi                           // Rontott vissza
    pop   esi                           // Rontott vissza
end;

procedure bcdtob(mitala: Word); Assembler;
asm
    push  ebx                           // Elrontom
    mov   bl,al                         // Másolom az L részt
    mov   bh,al                         // Másolom az L részt
    and   bl,00001111b                  // Csak az alsó 4 bit marad
    and   bh,11110000b                  // Csak a felsõ 4 bit marad (16 szoros a látszat)
    shr   bh,1                          // Már csak 8-szoros a látszat
    mov   al,bh                         // 8 szoros átpakolva
    shr   bh,2                          // Már csak 2-szeres a látszat
    add   al,bh                         // AL <- 8 + 2 = 10 szeres
    add   al,bl                         // AL <- binárisan a régi BCD AL
    mov   bl,ah                         // Másolom az L részt
    mov   bh,ah                         // Másolom az L részt
    and   bl,00001111b                  // Csak az alsó 4 bit marad
    and   bh,11110000b                  // Csak a felsõ 4 bit marad (16 szoros a látszat)
    shr   bh,1                          // Már csak 8-szoros a látszat
    mov   ah,bh                         // 8 szoros átpakolva
    shr   bh,2                          // Már csak 2-szeres a látszat
    add   ah,bh                         // AH <- 8 + 2 = 10 szeres
    add   ah,bl                         // AH <- binárisan a régi BCD AH
    pop   ebx                           // Vissza a rontott
end;

procedure indpck; stdcall; Assembler;
var
  sajpuf: USB_buf;
asm
    push  ebx                           // Elrontom
    push  esi                           // Elrontom
    push  edi                           // Elrontom
    lea   edx,sajpuf                    // A puffer címe
    mov   ecx,[upglei]                  // Ez a leíró címe
    mov   ax,[ecx + UPGPCK.devazo]      // Az azonosító
    mov   [edx + USB_buf.address],ax    // Rekordszám kitöltés
    mov   [edx + USB_buf.ReportID],0    // Az elsõ bájtot nullázni kell
    mov   eax,[ecx + UPGPCK.aktdar]     // Itt tart jelenleg
    mov   ebx,eax                       // Másolom
    shr   ebx,1                         // A felét veszem, mert két részletben megy a csomag
    cmp   ebx,[ecx + UPGPCK.packdb]     // Elért már a végére?
    jnz   @vanmek                       // Még nem ért a végére, küldözgetni kell
    mov   [edx + USB_buf.tipus],KFLASH  // Az újraindítási parancs megy
    mov   [edx + USB_buf.counter],0     // A hossz értéke
    jmp   @usbkuv                       // Elmehet a parancs
  @vanmek:
    lea   edi,[edx + USB_buf.pufbel]    // A puffer címét elõkészítem
    inc   [ecx + UPGPCK.aktdar]         // Megnövelem a darabszámot
    mov   [edx + USB_buf.tipus],SFLASH OR $80// A frissítõ puffer elküldésének kódja
    imul  esi,ebx,67                    // A rekordhosszal szorzok
    lea   esi,[ecx + esi + SIZUPG]      // Ez az alapcím (páratlan menet)
    mov   ecx,33                        // A hossz második (páratlan) menetben
    test  eax,1                         // Páros a számláló?
    jnz   @nparos                       // Páratlan küldés paraméterei maradnak
    inc   ecx                           // A hossz elsõnek 34
    lea   esi,[esi + 33]                // A 67-es puffer másik része lesz elküldve
  @nparos:
    mov   [edx + USB_buf.counter],cl    // A hossz kitöltése
    cld                                 // Elõrefele másoljon
    rep   movsb                         // Átmásolom a puffert
  @usbkuv:
    push  edx                           // UsbHidWrite 2. paraméter, a puffer címe
    push  0                             // UsbHidWrite 1. paraméter, az eszköz sorszáma
    call  UsbHidWrite                   // Elindítom a puffert
    pop   edi                           // Vissza a rontott
    pop   esi                           // Vissza a rontott
    pop   ebx                           // Vissza a rontott
end;
//
// AX <- a keresett azonosító
// CX <- 0, ha nem kell vizsgálni, egyébként a kívánt típus bitpáros
//
procedure ervazo; Assembler;
asm
    push  ebx                           // Elrontom
    xor   ebx,ebx                       // Alapra teszem
    mov   edx,[dev485]                  // Az eszközleírók kezdõcíme
  @kerazc:
    cmp   ax,[edx + DEVSEL.azonos]      // Ilyen van a listában?
    jz    @megvan                       // Megtaláltam
    lea   edx,[edx + SIZAPU]            // A következõre lépek
    inc   ebx                           // A következõre
    cmp   ebx,[drb485]                  // Elért a végére?
    jnz   @kerazc                       // Még nem, folytatom
    jmp   @nemazi                       // Nem találtam ilyet
  @megvan:
    or    ecx,ecx                       // Vizsgáljam?
    jz    @zersta                       // Nem kell vizsgálni
    and   ax,$c000                      // Csak a típus azonosító bitjei maradnak
    xor   ax,cx                         // A kívánt elõtag az?
    jz    @zersta                       // Nem kell vizsgálni
  @nemazi:
    mov   eax,ERROR_INVALID_DATA        // Hibakód
    or    eax,eax                       // Zéró státusz beállítás
  @zersta:
    pop   ebx                           // Rontott vissza
end;
//
// Rendezem a megtalált elemeket az azonosítójuk szerint
//
procedure quicksort(bal, jobb: Integer); stdcall; Assembler;
asm
    push  ebx                           // Elrontom
    push  esi                           // Elrontom
    push  edi                           // Elrontom
//
//  Másolatot készítek a bal és jobb elemrõl i-be és j-be
//
    mov   eax,bal                       // Másolat
    mov   edx,jobb                      // Másolat
    mov   edi,eax                       // Elpakolom (i)
    mov   ebx,edx                       // Elpakolom (j)
//
//  A pivot elem tömbindexe
//
    add   eax,edx                       // EAX <- i + j
    shr   eax,1                         // EAX <- (i + j) DIV 2
//
//  A pivot elem meghatározása, beolvasása
//
    imul  esi,eax,SIZAPU                // A elem távolsága ez elejétõl
    add   esi,[dev485]                  // A puffer címe
    mov   cx,[esi + DEVSEL.azonos]      // A vizsgálandó azonosító (pivot)
//
//  Itt van a külsõ WHILE ciklus feje
//
  @kulwhi:
    cmp   edi,ebx                       // Ha i nagyobb mint j, akkor nincs ciklus
    jg    @kulwhv                       // Már vége van
//
//  A ciklusba megyek, kiszámítom az i-edik tömbelem címét
//
    imul  esi,edi,SIZAPU                // A elem távolsága ez elejétõl
    add   esi,[dev485]                  // A puffer címe
//
// Ha a tömbelem értéke nagyobb vagy egyenlõ, akkor nem keresek tovább
//
  @felwhi:
    cmp   [esi + DEVSEL.azonos],cx      // A másik azonosító
    jae   @felwhv                       // Nincs tovább
//
//  Most kisebb, akkor a következõre lépek
//
    inc   edi                           // Offszet a következõre
    lea   esi,[esi + SIZAPU]            // A következõ elem címére lépek
    jmp   @felwhi                        // Új ellenõrzésre
//
//  Megvan a nagyobb elem indexe (i), kiszámítom a j-edik tömbelem címét
//
  @felwhv:
    imul  esi,ebx,SIZAPU                // A elem távolsága ez elejétõl
    add   esi,[dev485]                  // A puffer címe
//
//  Ha a tömbelem értéke kisebb vagy egyenlõ, akkor nem keresek tovább
//
  @alswhi:
    cmp   [esi + DEVSEL.azonos],cx      // A másik azonosító
    jbe   @alswhv                       // Nincs tovább
//
//  Most nagyobb, akkor az elõzõre lépek
//
    dec   ebx                           // Offszet az elõzõre
    lea   esi,[esi - SIZAPU]            // Az elõzõ elem címére lépek
    jmp   @alswhi                        // Új ellenõrzésre
//
//  Megvan a kisebb elem indexe (j), megnézem az indexek viszonyát,
//  ha i nagyobb mint j, akkor nem cserélek
//
  @alswhv:
    cmp   edi,ebx                       // Az i és j viszonya?
    jg    @kulwhi                       // A külsõ ciklusba
//
//  Elvben cserélni kell, de ha az indexek (i és j) egyformák, nincs értelme
//
    jz    @cseren                       // Azonos offszeteknél nincs csere
//
//  Nem egyformák cseréle
//
    imul  edx,edi,SIZAPU                // A elem távolsága ez elejétõl
    add   edx,[dev485]                  // A puffer címe
//
//  Azonosító csere
//
    mov   ax,[edx + DEVSEL.azonos]      // Az egyik azonosító
    xchg  ax,[esi + DEVSEL.azonos]      // A másik azonosító
    mov   [edx + DEVSEL.azonos],ax      // Csere a másikba
//
//  A product leírás elem (pointer) cseréje
//
    mov   eax,[edx + DEVSEL.produc]     // Az egyik cím
    xchg  eax,[esi + DEVSEL.produc]     // A másik cím
    mov   [edx + DEVSEL.produc],eax     // Csere a másikba
//
//  A gyártót leíró elem (pointer) cseréje
//
    mov   eax,[edx + DEVSEL.manufa]     // Az egyik cím
    xchg  eax,[esi + DEVSEL.manufa]     // A másik cím
    mov   [edx + DEVSEL.manufa],eax     // Csere a másikba
//
//  A verziót leíró elemek cseréje (5 hosszú)
//
    mov   eax,dword ptr [edx + DEVSEL.idever]// Az egyik értéknégyes
    xchg  eax,dword ptr [esi + DEVSEL.idever]// A másik értéknégyes
    mov   dword ptr [edx + DEVSEL.idever],eax// Csere a másikba
    mov   al,byte ptr [edx + DEVSEL.idever + 4]// Az egyik maradék
    xchg  al,byte ptr [esi + DEVSEL.idever + 4]// A másik maradék
    mov   byte ptr [edx + DEVSEL.idever + 4],al// Csere a másikba
//
//  Átlépem az aktuális elemeket
//
  @cseren:
    inc   edi                           // Baloldali növelés
    dec   ebx                           // Jobboldali csökkentés
    jmp   @kulwhi                       // A külsõ ciklusba
//
//  Megtörténtek a cserék (ha kellett), jöhet a jobb és bal oldal rendezése
//  ha a bal érték nagyobb vagy egyenlõ j-nél, nem is kell meghívni rendezésre
//
  @kulwhv:
    cmp   bal,ebx                       // A bal és a j viszonya
    jge    @nemhib                      // Nincs belsõ hívás
//
// A bal és a j elemeket (tovább) rendezem
//
    push  ebx                           // quicksort 2. paraméter, a jobboldali érték
    push  bal                           // quicksort 1. paraméter, a baloldali érték
    call  quicksort                     // Lerendezem
//
//  Ha a
//  Ha az i érték nagyobb vagy egyenlõ i-nél, nem is kell meghívni rendezésre
//
  @nemhib:
    cmp   edi,jobb                      // Viszonyuk
    jge   @nemhij                       // Nincs belsõ hívás
//
//  Az i és a jobb elemeket (tovább) rendezem
//
    push  jobb                          // quicksort 2. paraméter, a jobboldali érték
    push  edi                           // quicksort 1. paraméter, a baloldali érték
    call  quicksort                     // Lerendezem
//
//  A bal és jobb indexek között (növekvõ értékre) rendezett a tömb
//
  @nemhij:
    pop   edi                           // Rontott vissza
    pop   esi                           // Rontott vissza
    pop   ebx                           // Rontott vissza
end;
//
//  Az eszközleíróban foglaltak felszabadítása, majd az eszközleíró visszadása
//
procedure eszrem; stdcall; Assembler;
asm
    push  ebx                           // Elrontom
    xor   ebx,ebx                       // Nullázok
    mov   ebx,[dev485]                  // Ez volt elõtte
    or    ebx,ebx                       // Nulla?
    jz    @aknesa                       // Igen, nincs mit felszabadítani
    push  esi                           // Elrontanám
    push  edi                           // Elrontanám
//
// Ha volt elõzõleg lista, akkor azt felszabadítom
//
    xor   esi,esi                       // Alaphelyzet
  @kovelf:
    imul  edi,esi,SIZAPU                // Az offszet
    mov   eax,[edi + ebx + DEVSEL.produc]// Az elem szöveges leírója
    or    eax,eax                       // Kell visszaadni?
    jz    @nemadp                       // Most nem kell
    push  eax                           // GloablFree 1. paraméter, a puffer címe
    call  GlobalFree                    // Eldobom a stringet
  @nemadp:
    mov   eax,[edi + ebx + DEVSEL.manufa]// Az elem gyártó  leírója
    or    eax,eax                       // Kell visszaadni?
    jz    @nemadm                       // Most nem kell
    push  eax                           // GloablFree 1. paraméter, a puffer címe
    call  GlobalFree                    // Eldobom a stringet
  @nemadm:
    inc   esi                           // A következõ elemre lépek
    cmp   [drb485],esi                  // Van még?
    jnz   @kovelf                       // Igen, akkor fussunk neki
    pop   edi                           // Vissza a rontott
    pop   esi                           // Vissza a rontott
    push  ebx                           // GloablFree 1. paraméter, a puffer címe
    call  GlobalFree                    // Eldobom a leírót
  @aknesa:
    pop   ebx                           // Vissza a rontott
end;
//
// Feladatlista következõ elemének indítása, ha van még, ha nincs üzenetküldés
//
function belkoi: Dword; stdcall; Assembler;
asm
    push  ebx                           // Elrontom
    mov   eax,[belakt]                  // Itt tart most
    cmp   eax,[belmax]                  // Elért már a végére
    jnz   @folyin                       // Még nem ért a végére
    xor   eax,eax                       // Minden rendben (NO_ERROR)
    jmp   @valveg                       // Lefutott valamennyi
  @folyin:
    inc   [belakt]                      // A következõre
    imul  ebx,eax,SIZBEL                // A táblázat elejéhez képesti offszet
    add   ebx,[belpoi]                  // A táblázatra rátolom
    mov   ax,[ebx + LISELE.azonos]      // A küldött azonosító
    mov   ecx,SLLELO                    // A kívánt elõtag
    call  ervazo                        // Azonosító lekérdezés
    jnz   @nemale                       // Nem LED lámpa azonosító
    mov   edx,offset sajpuf             // Az üzenet puffere
    mov   cx,[ebx + LISELE.azonos]      // Ezt küldte
    mov   [edx + USB_buf.address],cx    // Ezt kell megváltoztatni
    mov   [edx + USB_buf.tipus],LEDLRG  // A kérés kódja
    mov   eax,dword ptr [ebx + LISELE.lamrgb]// Az RGB paraméter
    mov   dword ptr [edx + USB_buf.ledszb],eax// Átadom az RGB értékeket
    jmp   @elkul                        // Elküldöm a parancsot
  @nemale:
    mov   ax,[ebx + LISELE.azonos]      // A küldött azonosító
    mov   ecx,SLNELO                    // A kívánt elõtag
    call  ervazo                        // Azonosító lekérdezés
    jnz   @nemani                       // Nem a nyíl az azonosító
    mov   edx,offset sajpuf             // Az üzenet puffere
    mov   cx,[ebx + LISELE.azonos]      // A küldött azonosító
    mov   [edx + USB_buf.address],cx    // Ezt kell megváltoztatni
    mov   [edx + USB_buf.tipus],NYILRG  // A kérés kódja
    mov   eax,dword ptr [ebx + LISELE.nilrgb]// Az RGB paraméter
    mov   dword ptr [edx + USB_buf.ledszb],eax// Átadom az RGB értékeket
    mov   eax,[ebx + LISELE.jobrai]     // Az irány
    or    eax,eax                       // False?
    jz    @marafa                       // Igen, az is marad
    mov   al,1                          // Legyen True
  @marafa:
    mov   [edx + USB_buf.lednir],al     // Átadom az irány értékeket
    jmp   @elkul                        // Elküldöm a parancsot
  @nemani:
    mov   ax,[ebx + LISELE.azonos]      // A küldött azonosító
    mov   ecx,SLHELO                    // A kívánt elõtag
    call  ervazo                        // Azonosító lekérdezés
    mov   eax,ERROR_INVALID_DATA        // Hibakód
    jnz   @valveg                       // Nem a hangszóró azonosító, más meg nincs
    mov   edx,offset sajpuf             // Az üzenet puffere
    mov   cx,[ebx + LISELE.azonos]      // Ezt küldte
    mov   [edx + USB_buf.address],cx    // Ezt kell megváltoztatni
    mov   eax,ERROR_BAD_LENGTH          // Hibakód
    movzx ecx,[ebx + LISELE.handrb]     // Ezt küldte hossznak
    or    ecx,ecx                       // Nulla az elemszám?
    jz    @valveg                       // Nem lehet nulla a hossz
    cmp   ecx,16                        // Ennél nagyobb?
    ja    @valveg                       // Igen, akkor hibás a hossz
    imul  ecx,ecx,SIZHTB                // Ennyi bájtból áll
    mov   [edx + USB_buf.counter],cl    // A kérés bájtszáma
    mov   al,HANGIN OR $80              // Ha hosszú küldés lesz
    cmp   cl,30                         // Van ennyi?
    ja    @marahk                       // Több is, marad a hosszú kérés
    mov   al,HANGIN                     // Rövid küldés lesz
  @marahk:
    mov   [edx + USB_buf.tipus],al      // A kérés kódja
    push  edi                           // Elrontom
    push  esi                           // Elrontom
    mov   esi,[ebx + LISELE.hantbp]     // Ez a táblázat címe
    lea   edi,[edx + USB_buf.hangtb]    // Ahova tenni kell
    cld                                 // Elõrefele másoljon
    rep   movsb                         // Átmásolom
    pop   esi                           // Vissza a rontott
    pop   edi                           // Vissza a rontott
  @elkul:
    push  edx                           // UsbHidWrite 2. paraméter, a puffer címe
    push  0                             // UsbHidWrite 1. paraméter, az eszköz sorszáma
    call  UsbHidWrite                   // Elindítom a felmérést
    or    eax,eax                       // Sikerült?
    jz    @renveg                       // Igen, sikeres az indítás
  @valveg:
    mov   [belfut],0                    // Már nem fut
    push  eax                           // PostMessage 4. paraméter, a végrehajtás válasza (lParam)
    push  LISVAL                        // PostMessage 3. paraméter, a válasz kódja (wParam)
    push  [msgkod]                      // PostMessage 2. paraméter, az üzenet száma
    push  [msghnd]                      // PostMessage 1. paraméter, az üzenet window Handle értéke
    call  PostMessage                   // Üzenet megy a történtekrõl
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

