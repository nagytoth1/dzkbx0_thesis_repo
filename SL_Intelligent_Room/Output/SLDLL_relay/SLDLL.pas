unit SLDLL;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A DLL haszn�lat�nak megkezd�se ut�n az ott megadott �zentsz�mra k�ld�tt         //
//  �zenetekkel tartja a kapcsolatot a h�v�val. Az �zenet (Message) WParam �rt�ke   //
//  tartalmazza az �zenet k�dj�t. Ez vagy nagyobb, vagy kisebb mint nulla.          //
//  A negat�v �rt�k hiba�zenet. A pozit�v az elv�gzett m�velet v�grehajt�s�r�l      //
//  ad t�j�koztat�st. Ha az �zenethez tartozik param�ter, adat, akkor arra az       //
//  �zenet LParam �rt�ke hivatkozik.                                                //
//                                                                                  //
//  Az �zenetekhez tartoz� adatok:                                                  //
//                                                                                  //
//  FELMOK (1)  LParam -> a felm�r�s �ltal tal�lt eszk�z�k sz�ma                    //
//  AZOOKE (2)  LParam -> nem tartalmaz inform�ci�t                                 //
//  FIRMUZ (3)  LParam -> a friss�t�s adatait tartalmaz� strukt�ra (UPGPCK) c�me    //
//  FIRMEN (4)  LParam -> nem tartalmaz inform�ci�t                                 //
//  LEDRGB (5)  LParam -> az �ltal�nos �llaptinform�ci� strukt�ra (ELVSTA) c�me     //
//  NYIRGB (6)  LParam -> az �ltal�nos �llaptinform�ci� strukt�ra (ELVSTA) c�me     //
//  HANGEL (7)  LParam -> az �ltal�nos �llaptinform�ci� strukt�ra (ELVSTA) c�me     //
//  STATKV (8)  LParam -> az �ltal�nos �llaptinform�ci� strukt�ra (ELVSTA) c�me     //
//  LISVAL (9)  LParam -> a t�bl�zat v�grehajt�s v�g�nek hibak�dja                  //
//                                                                                  //
//  USBREM (-1) LParam -> nem tartalmaz inform�ci�t                                 //
//  VALTIO (-2) LParam -> nem tartalmaz inform�ci�t                                 //
//  FELMHK (-3) LParam -> a felm�r�s hib�sz�ma                                      //
//  FELMHD (-4) LParam -> nem tartalmaz inform�ci�t                                 //
//  FELMDE (-4) LParam -> nem tartalmaz inform�ci�t                                 //
//                                                                                  //
//  Az egyes funkci�k visszt�r�si k�dja t�j�koztat a h�v�s sikeres vagy             //
//  sikertelen volt�r�l. Ha a visszat�r�si k�d NO_ERROR (0), akkor a h�v�s          //
//  sikeres volt. Ha nem NO_ERROR (0) az �rt�k a k�d t�j�koztat a sikertelens�g     //
//  ok�r�l. A lehets�ges �rt�kek az adott h�v�s le�r�s�ban ismertet�sre ker�lnek.   //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows;

const
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
//
// A DLL hely�nek le�r�sa
//
  SLDLL_PATH              = 'SLDLL.DLL';	                  // A DLL �tvonala �s neve

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

  DEVNUM  = array [0..(MAXRES -1 )] of Word;                // Azonos�t� t�rol�

  HANGLE = packed record                                    // Egy hang le�r�sa
    hangho: Word;                                           // A hang hossza milisec.-ben                  0     2
    hangso: Byte;                                           // A hang sorsz�ma (0..32)                     2     1
    hanger: Byte;                                           // A hang hangereje (0..63)                    3     1
  end;                                                      // Az eg�sz hossza                             4

  HANGLA = array [0..15] of HANGLE;                         // Hangle�r�k t�bl�zata
  PHANGL = ^HANGLA;                                         // A t�bl�zatra mutat� pointer

  VIDTAR = array [0..31] of WideChar;

  PUPGPCK = ^UPGPCK;
  UPGPCK = packed record
    packdb: Dword;                                          // A csomagok maximuma                         0     4
    aktdar: Dword;                                          // A csomagok sz�ml�l�ja                       4     4
    devazo: Word;                                           // A 485-�s eszk�z c�me                        8     2
    errcod: Byte;                                           // Az �zenet k�dja                            10     1
  end;                                                      // Az eg�sz hossza                            11

  PELVSTA = ^ELVSTA;
  ELVSTA = packed record
    merlam: MERESE;                                         // A proci m�rt �rt�kei                        0     6
    rgbert: HABASZ;                                         // Az aktu�lis sz�n�sszetev�k �rt�ke           6     3
    nyilal: Byte;                                           // A ny�l ir�nya                               9     1
    hanakt: Byte;                                           // A hang �llapota                            10     1
  end;                                                      // Az eg�sz hossza                            11
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
//                (in-out) devata   Az USB eszk�z jellemz�i                         //
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
function  SLDLL_Open(wndhnd, msgert: Dword; mianev: PDLLNEV; devata: PDEVSEL): Dword; stdcall; external SLDLL_PATH;
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
function SLDLL_Felmeres: Dword; stdcall; external SLDLL_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  Az eszk�zlista c�m�nek bek�r�se.                                                //
//                                                                                  //
//  Param�ter:                                                                      //
//                (out) dev485      A t�bl�zat c�m�nek m�solata                     //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    A c�m sikeresenn �tad�sra ker�lt      //
//                ERROR_DLL_INIT_FAILED       A DLL m�g nem volt elind�tva          //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function SLDLL_Listelem(dev485: PDEVLIS): Dword; stdcall; external SLDLL_PATH;
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
function SLDLL_AzonositoCsereInditas(amitva, amirev: Word): Dword; stdcall; external SLDLL_PATH;
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
function SLLDLL_Upgrade(filnam: PChar; var drbkod: Dword; amitir: Word): Dword; stdcall; external SLDLL_PATH;
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
function SLLDLL_LEDLampa(rgbert: HABASZ; amital: Word): Dword; stdcall; external SLDLL_PATH;
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
function SLLDLL_LEDNyil(rgbert: HABASZ; jobrai: BOOL; amital: Word): Dword; stdcall; external SLDLL_PATH;
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
function SLLDLL_Hangkuldes(hangho: Integer;const amitku: HANGLA; amital: Word): Dword; stdcall; external SLDLL_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
//  A DLL �ltal el�rhet� eszk�z�k felm�r�s�nek ind�t�sa.                            //
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
function SLDLL_GetStatus(amitke: Word): Dword; stdcall; external SLDLL_PATH;
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
function SLDLL_SetLista(hanydb: Integer; const tblveg:LISTBL): Dword; stdcall; external SLDLL_PATH;
//
implementation
//
end.
