unit HID_KER_USB;

interface

uses
  Windows;

const
  JELSIZ                      = 128;    // Jellemzõ maximális hossza

  CRCERR	                    =	1;      // CRC hibás kódmódosító puffer
  NOTUPG	                    =	2;      // Nem végrehajtható kódmódosítás
  WRIERR	                    =	3;      // Íráshiba a kódmódosítás során

  ERROR_FUNCTION_NOT_CALLED   = 1626;   // Function could not be executed. ($65A)

//  HID_KER_USB_PATH            = '..\HID_KER_USB\HID_KER_USB.DLL';// A DLL útvonala és neve
  HID_KER_USB_PATH            = 'HID_KER_USB.DLL';// A DLL útvonala és neve

type

//  PAOFB = ^AOFB;
//  AOFB = array [0..$7ffffffe] of Byte;

  pUSB_buf = ^USB_buf;
  USB_buf = packed record
    reportID: Byte;                                         // For HID (not used, always 0)                0     1
    tipus: Byte;                                            // Az üzenet típuskódja                        1     1
    counter: Byte;                                          // Az üzenet számlálója                        2     1
    address: Word;                                          // Az üzenet címtartalma                       3     2
    pufbel: array [0..63] of Byte;                          // Az üzenet bájtos tárolóban                  5    64
  end;

  USBTUL = packed record
    USB_Manufacturer_Length: Dword;                         // A gyártó string hossza                      0     4
    USB_Manufacturer: array [0..(JELSIZ - 1)] of WideChar;  // Gyártó lekérdezés eredménye                 4   256
    USB_Product_Length: Dword;                              // A készüléknév hossza                      260     4
    USB_Product: array [0..(JELSIZ - 1)] of WideChar;       // Készüléknév lekérdezés eredménye          264   256
    USB_Product_Number: Word;                               // A készülék száma                          520     2
    USB_Product_Versio_H: Byte;                             // A készülék szoftververziójának H része    522     1
    USB_Product_Versio_L: Byte;                             // A készülék szoftververziójának L része    523     1
    USB_Product_Year: Word;                                 // A szoftver dátum év része                 524     2
    USB_Product_Month: Byte;                                // A szoftver dátum hónap része              526     1
    USB_Product_Day: Byte;                                  // A szoftver dátum nap része                527     1
    USB_Handle: THandle;                                    // Handle to USB device                      528     4
    USB_Misc_Length: Dword;                                 // A készüléknév hossza                      532     4
    USB_Misc: array [0..(JELSIZ - 1)] of WideChar;          // Készüléknév lekérdezés eredménye          536   256
  end;                                                      // Az egész hossza                           792

//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A DLL használatának megkezdése.                                                  //
//                                                                                  //
//  Paraméterek:                                                                    //
//                (in)  wndhnd   A használat eseményeinek üzenetét fogadó handle    //
//                               (handle of destination window)                     //
//                (in)  msgert   A beérkezõ (válasz) pufferekrõl tájékoztató        //
//                               üzenet kódja (message code)                        //
//                (in)  prodid   A használni kívánt eszköz Product_ID értéke        //
//                               (1-65534)                                          //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    Sikeresen kapcsolódott a jelen        //
//                                            lévõ eszközökhöz                      //
//                ERROR_ALREADY_INITIALIZED   A rutin már használatba vette         //
//                                            (korábban) az eszközöket              //
//                ERROR_MOD_NOT_FOUND         Ilyen Product_ID-vel rendelkezõ       //
//                                            eszköz jelenleg nincs csatlakoztatva  //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  UsbHidOpen(wndhnd, msgert: Dword; prodid: Word): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A paraméterekkel azonosított eszköz használatának befejezése, az esetleg         //
// aktív kódfrissítések lezárásával. (A hívás kiadható akkor is, ha az              //
// UsbHidOpen hívással a DLL használata még nem volt kezdeményezve.)                //
//                                                                                  //
//  Paraméterek:                                                                    //
//                (in)  devnum   A lezárni kívánt eszköz sorszáma                   //
//                               (0-tól UsbGetNumdev - 1 értékig)                   //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    Sikeres mûvelet                       //
//                ERROR_MOD_NOT_FOUND         Ilyen számú eszköz nincs jelenleg     //
//                                            csatlakoztatva                        //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function UsbHidDevClose(devnum: Dword): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A DLL használatának befejezése, az esetleg aktív kódfrissítések lezárásával.     //
// (A hívás kiadható akkor is, ha az UsbHidOpen hívással a DLL használata még       //
// nem volt kezdeményezve.)                                                         //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
procedure UsbHidClose; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A DLL által használt (csatlakoztatott) eszközök számának lekérdezése.            //
//                                                                                  //
//  Visszatérési érték:   A csatlakoztatott eszközök száma                          //
//                        (0 esetén egy eszköz sincs csatlakoztatva)                //                                                          //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  UsbGetNumdev: Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A kívánt eszköz jellemzõinek bekérése.                                           //
//                                                                                  //
//  Paraméterek:                                                                    //
//                (in)  devnum   A lekérdezni kívánt eszköz sorszáma                //
//                               (0-tól UsbGetNumdev - 1 értékig)                   //
//                (out) devpro   Az eszköz jellemzõinek tárhelye                    //
//                (in)  nummod   Az eszközszám módja                                //
//                              (False esetén hex, True esetén decimális formátum)  //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    Sikeres mûvelet, jellemzõk a          //
//                                            "devpro" paraméterrel leírt helyen    //
//                ERROR_MOD_NOT_FOUND         Ilyen számú eszköz nincs jelenleg     //
//                                            csatlakoztatva                        //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  UsbHidGetProperty(devnum: Dword; var devpro: USBTUL; nummod: BOOL): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A kívánt eszköznek üzenet küldése.                                               //
//                                                                                  //
//  Paraméterek:                                                                    //
//                (in)  devnum   A megcímzett eszköz sorszáma                       //
//                               (0-tól UsbGetNumdev - 1 értékig)                   //
//                (in)  buffer   A küldeni kívánt üzenetpuffer címe (PUSB_buf)      //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    Sikeres mûvelet                       //
//                ERROR_MOD_NOT_FOUND         Ilyen számú eszköz nincs jelenleg     //
//                                            csatlakoztatva                        //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  UsbHidWrite(devnum: Dword; const buffer): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A kívánt eszközön kódfrissítés (firmware update) indítása.                       //
//                                                                                  //
//  Paraméterek:                                                                    //
//                (in)  devnum   A megcímzett eszköz sorszáma                       //
//                               (0-tól UsbGetNumdev - 1 értékig)                   //
//                (in)  fwname   A kód frissítést tartalmazó fájl nevének címe      //
//                (out) hibkod   NO_ERROR válasz esetén a frissítõ csomagok száma,  //
//                               más válasz esetén a hiba létrejöttének Windows     //
//                               hibakódja                                          //
//                (in)  msgert   A frissítés folyamatáról tájékoztató üzenet        //
//                               kódja (message code)                               //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    Sikeres frissítésindítás              //
//                ERROR_MOD_NOT_FOUND         Ilyen számú eszköz nincs jelenleg     //
//                                            csatlakoztatva                        //
//                ERROR_FUNCTION_NOT_CALLED   A frissítés jelenleg aktív            //
//                ERROR_OPEN_FAILED           A frissítésinditásnál fájl mûveleti   //
//                                            hiba (konkrét hibakód "hibkod"-ban)   //
//                ERROR_FILE_INVALID          Hibás kódfrissítõ fájl felépítés      //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  UsbHidUpgrade(devnum: Dword; const fwname: PChar; var hibkod: Dword; msgert: Dword): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A kívánt eszközön a kódfrissítés (firmware update) leállítása. (A hívás          //
// kiadható akkor is, ha az UsbHidUpgrade hívással a kódfrissítés még nem volt      //
// kezdeményezve, vagy a frissítés már véget ért.)                                  //
//                                                                                  //
//  Paraméterek:                                                                    //
//                (in)  devnum   A megcímzett eszköz sorszáma                       //
//                               (0-tól UsbGetNumdev - 1 értékig)                   //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    Sikeresen le lett állítva             //
//                                            vagy a frissítés jelenleg nem aktív.  //
//                ERROR_MOD_NOT_FOUND         Ilyen számú eszköz nincs jelenleg     //
//                                            csatlakoztatva                        //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  UsbHidUpgradeClose(devnum: Dword): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A DLL verziójának és teljes nevének lekérdezése.                                 //
//                                                                                  //
//  Paraméterek:  (out)  versms  A DLL verziójának magasabbik része                 //
//                (out)  versls  A DLL verziójának alacsonyabbik része              //
//                (out)  dllnam  A DLL neve teljes elérési útvonallal               //
//                (in)   namlen  A DLL név helyének mérete                          //
//                       (a szükséges terület maximális mérete: MAX_PATH)           //
//                                                                                  //
//  Visszatérési érték:                                                             //
//                NO_ERROR                    Sikeres mûvelet                       //
//                egyéb értékek               Windows mûveleti hibakódok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function UsbGetDLLVersion(var versms, versls: Dword; dllnam: PChar; namlen: Dword): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// Beérkezõ (válasz) puffer eseményének üzenetfelépítése. Az üzenet kódja           //
// (message code) az UsbHidOpen "msgert" paramétereként lett megadva. A kód         //
// értékének "illik" nagyobbnak lenni, mint WM_USER értéke.                         //
//                                                                                  //
//  WParam: (Dword)   LParam nem nulla esetén az üzenetet küldõ eszköz száma        //
//                    (lásd még "devnum" hívás paraméterek)                         //
//  LParam: (Dword)   Nem nulla esetén a WParam számú eszköz által küldött          //
//                    puffer címe (PUSB_buf)                                        //
//                    0 esetén a csatlakoztatott eszközök számában történõ          //
//                    változás bejelentése. Ilyen esetben a csatlakoztatott         //
//                    eszközök sorszáma (devnum) megváltozhat!                      //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// Kódfrissétés eseményének üzenetfelépítése. Az üzenet kódja (message code) az     //
// UsbHidUpgrade "msgert" paramétereként lett megadva. A frissítés folyamatában     //
// az elküldöt frissítõ rekordra adott válasz után jön létre. A kód értékének       //
// "illik" nagyobbnak lenni, mint WM_USER értéke.                                   //
//                                                                                  //
//  WParam: (Dword)   LParam = NO_ERROR esetén a még háralévõ kódfrissítõ           //
//                    rekordok száma. (0 esetén a kódfrissítés kész)                //
//                                                                                  //
//  LParam: (Dword)   A frissítés hibakódja                                         //
//                        NO_ERROR            Sikeres mûvelet                       //
//                        CRCERR	            CRC hibás kódmódosító rekord          //
//                                            van a kódfissítésre kijelölt          //
//                                            fájlban.                              //
//                        NOTUPG	            Nem végrehajtható a kódmódosítás      //
//                                            a förmver aktuális verzióján a        //
//                                            a kódfissítésre kijelölt fájllal      //
//                                            (eltérõ belsõ förmver struktúrák)     //
//                        WRIERR	            A kód módosítás során íráshiba az     //
//                                            eszköz kódterületén                   //
//                        egyéb értékek       Az adott eszközre jellemzõ egyéb      //
//                                            hiba (pl. jogosultsági hiány...)      //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
//
implementation
//
end.
