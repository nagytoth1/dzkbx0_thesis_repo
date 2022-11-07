unit SLDLL;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A DLL használatának megkezdése után az ott megadott üzentszámra küldött         //
//  üzenetekkel tartja a kapcsolatot a hívóval. Az üzenet (Message) WParam értéke   //
//  tartalmazza az üzenet kódját. Ez vagy nagyobb, vagy kisebb mint nulla.          //
//  A negatív érték hibaüzenet. A pozitív az elvégzett mûvelet végrehajtásáról      //
//  ad tájékoztatást. Ha az üzenethez tartozik paraméter, adat, akkor arra az       //
//  üzenet LParam értéke hivatkozik.                                                //
//                                                                                  //
//  Az üzenetekhez tartozó adatok:                                                  //
//                                                                                  //
//  FELMOK (1)  LParam -> a felmérés által talált eszközök száma                    //
//  AZOOKE (2)  LParam -> nem tartalmaz információt                                 //
//  FIRMUZ (3)  LParam -> a frissítés adatait tartalmazó struktúra (UPGPCK) címe    //
//  FIRMEN (4)  LParam -> nem tartalmaz információt                                 //
//  LEDRGB (5)  LParam -> az általános állaptinformáció struktúra (ELVSTA) címe     //
//  NYIRGB (6)  LParam -> az általános állaptinformáció struktúra (ELVSTA) címe     //
//  HANGEL (7)  LParam -> az általános állaptinformáció struktúra (ELVSTA) címe     //
//  STATKV (8)  LParam -> az általános állaptinformáció struktúra (ELVSTA) címe     //
//  LISVAL (9)  LParam -> a táblázat végrehajtás végének hibakódja                  //
//                                                                                  //
//  USBREM (-1) LParam -> nem tartalmaz információt                                 //
//  VALTIO (-2) LParam -> nem tartalmaz információt                                 //
//  FELMHK (-3) LParam -> a felmérés hibászáma                                      //
//  FELMHD (-4) LParam -> nem tartalmaz információt                                 //
//  FELMDE (-4) LParam -> nem tartalmaz információt                                 //
//                                                                                  //
//  Az egyes funkciók vissztérési kódja tájékoztat a hívás sikeres vagy             //
//  sikertelen voltáról. Ha a visszatérési kód NO_ERROR (0), akkor a hívás          //
//  sikeres volt. Ha nem NO_ERROR (0) az érték a kód tájékoztat a sikertelenség     //
//  okáról. A lehetséges értékek az adott hívás leírásában ismertetésre kerülnek.   //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows;

const
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
//
// A DLL helyének leírása
//
  SLDLL_PATH              = 'SLDLL.DLL';	                  // A DLL útvonala és neve

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

  DEVNUM  = array [0..(MAXRES -1 )] of Word;                // Azonosító tároló

  HANGLE = packed record                                    // Egy hang leírása
    hangho: Word;                                           // A hang hossza milisec.-ben                  0     2
    hangso: Byte;                                           // A hang sorszáma (0..32)                     2     1
    hanger: Byte;                                           // A hang hangereje (0..63)                    3     1
  end;                                                      // Az egész hossza                             4

  HANGLA = array [0..15] of HANGLE;                         // Hangleírók táblázata
  PHANGL = ^HANGLA;                                         // A táblázatra mutató pointer

  VIDTAR = array [0..31] of WideChar;

  PUPGPCK = ^UPGPCK;
  UPGPCK = packed record
    packdb: Dword;                                          // A csomagok maximuma                         0     4
    aktdar: Dword;                                          // A csomagok számlálója                       4     4
    devazo: Word;                                           // A 485-ös eszköz címe                        8     2
    errcod: Byte;                                           // Az üzenet kódja                            10     1
  end;                                                      // Az egész hossza                            11

  PELVSTA = ^ELVSTA;
  ELVSTA = packed record
    merlam: MERESE;                                         // A proci mért értékei                        0     6
    rgbert: HABASZ;                                         // Az aktuális színösszetevõk értéke           6     3
    nyilal: Byte;                                           // A nyíl iránya                               9     1
    hanakt: Byte;                                           // A hang állapota                            10     1
  end;                                                      // Az egész hossza                            11
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
//                (in-out) devata   Az USB eszköz jellemzõi                         //
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
function  SLDLL_Open(wndhnd, msgert: Dword; mianev: PDLLNEV; devata: PDEVSEL): Dword; stdcall; external SLDLL_PATH;
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
function SLDLL_Felmeres: Dword; stdcall; external SLDLL_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  Az eszközlista címének bekérése.                                                //
//                                                                                  //
//  Paraméter:                                                                      //
//                (out) dev485      A táblázat címének másolata                     //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    A cím sikeresenn átadásra került      //
//                ERROR_DLL_INIT_FAILED       A DLL még nem volt elindítva          //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLDLL_Listelem(dev485: PDEVLIS): Dword; stdcall; external SLDLL_PATH;
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
function SLDLL_AzonositoCsereInditas(amitva, amirev: Word): Dword; stdcall; external SLDLL_PATH;
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
function SLLDLL_Upgrade(filnam: PChar; var drbkod: Dword; amitir: Word): Dword; stdcall; external SLDLL_PATH;
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
function SLLDLL_LEDLampa(rgbert: HABASZ; amital: Word): Dword; stdcall; external SLDLL_PATH;
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
function SLLDLL_LEDNyil(rgbert: HABASZ; jobrai: BOOL; amital: Word): Dword; stdcall; external SLDLL_PATH;
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
function SLLDLL_Hangkuldes(hangho: Integer;const amitku: HANGLA; amital: Word): Dword; stdcall; external SLDLL_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A DLL által elérhetõ eszközök felmérésének indítása.                            //
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
function SLDLL_GetStatus(amitke: Word): Dword; stdcall; external SLDLL_PATH;
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
function SLDLL_SetLista(hanydb: Integer; const tblveg:LISTBL): Dword; stdcall; external SLDLL_PATH;
//
implementation
//
end.
