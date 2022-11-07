unit HID_KER_USB;

interface

uses
  Windows;

const
  JELSIZ                      = 128;    // Jellemz� maxim�lis hossza

  CRCERR	                    =	1;      // CRC hib�s k�dm�dos�t� puffer
  NOTUPG	                    =	2;      // Nem v�grehajthat� k�dm�dos�t�s
  WRIERR	                    =	3;      // �r�shiba a k�dm�dos�t�s sor�n

  ERROR_FUNCTION_NOT_CALLED   = 1626;   // Function could not be executed. ($65A)

//  HID_KER_USB_PATH            = '..\HID_KER_USB\HID_KER_USB.DLL';// A DLL �tvonala �s neve
  HID_KER_USB_PATH            = 'HID_KER_USB.DLL';// A DLL �tvonala �s neve

type

//  PAOFB = ^AOFB;
//  AOFB = array [0..$7ffffffe] of Byte;

  pUSB_buf = ^USB_buf;
  USB_buf = packed record
    reportID: Byte;                                         // For HID (not used, always 0)                0     1
    tipus: Byte;                                            // Az �zenet t�pusk�dja                        1     1
    counter: Byte;                                          // Az �zenet sz�ml�l�ja                        2     1
    address: Word;                                          // Az �zenet c�mtartalma                       3     2
    pufbel: array [0..63] of Byte;                          // Az �zenet b�jtos t�rol�ban                  5    64
  end;

  USBTUL = packed record
    USB_Manufacturer_Length: Dword;                         // A gy�rt� string hossza                      0     4
    USB_Manufacturer: array [0..(JELSIZ - 1)] of WideChar;  // Gy�rt� lek�rdez�s eredm�nye                 4   256
    USB_Product_Length: Dword;                              // A k�sz�l�kn�v hossza                      260     4
    USB_Product: array [0..(JELSIZ - 1)] of WideChar;       // K�sz�l�kn�v lek�rdez�s eredm�nye          264   256
    USB_Product_Number: Word;                               // A k�sz�l�k sz�ma                          520     2
    USB_Product_Versio_H: Byte;                             // A k�sz�l�k szoftververzi�j�nak H r�sze    522     1
    USB_Product_Versio_L: Byte;                             // A k�sz�l�k szoftververzi�j�nak L r�sze    523     1
    USB_Product_Year: Word;                                 // A szoftver d�tum �v r�sze                 524     2
    USB_Product_Month: Byte;                                // A szoftver d�tum h�nap r�sze              526     1
    USB_Product_Day: Byte;                                  // A szoftver d�tum nap r�sze                527     1
    USB_Handle: THandle;                                    // Handle to USB device                      528     4
    USB_Misc_Length: Dword;                                 // A k�sz�l�kn�v hossza                      532     4
    USB_Misc: array [0..(JELSIZ - 1)] of WideChar;          // K�sz�l�kn�v lek�rdez�s eredm�nye          536   256
  end;                                                      // Az eg�sz hossza                           792

//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A DLL haszn�lat�nak megkezd�se.                                                  //
//                                                                                  //
//  Param�terek:                                                                    //
//                (in)  wndhnd   A haszn�lat esem�nyeinek �zenet�t fogad� handle    //
//                               (handle of destination window)                     //
//                (in)  msgert   A be�rkez� (v�lasz) pufferekr�l t�j�koztat�        //
//                               �zenet k�dja (message code)                        //
//                (in)  prodid   A haszn�lni k�v�nt eszk�z Product_ID �rt�ke        //
//                               (1-65534)                                          //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    Sikeresen kapcsol�dott a jelen        //
//                                            l�v� eszk�z�kh�z                      //
//                ERROR_ALREADY_INITIALIZED   A rutin m�r haszn�latba vette         //
//                                            (kor�bban) az eszk�z�ket              //
//                ERROR_MOD_NOT_FOUND         Ilyen Product_ID-vel rendelkez�       //
//                                            eszk�z jelenleg nincs csatlakoztatva  //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  UsbHidOpen(wndhnd, msgert: Dword; prodid: Word): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A param�terekkel azonos�tott eszk�z haszn�lat�nak befejez�se, az esetleg         //
// akt�v k�dfriss�t�sek lez�r�s�val. (A h�v�s kiadhat� akkor is, ha az              //
// UsbHidOpen h�v�ssal a DLL haszn�lata m�g nem volt kezdem�nyezve.)                //
//                                                                                  //
//  Param�terek:                                                                    //
//                (in)  devnum   A lez�rni k�v�nt eszk�z sorsz�ma                   //
//                               (0-t�l UsbGetNumdev - 1 �rt�kig)                   //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    Sikeres m�velet                       //
//                ERROR_MOD_NOT_FOUND         Ilyen sz�m� eszk�z nincs jelenleg     //
//                                            csatlakoztatva                        //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function UsbHidDevClose(devnum: Dword): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A DLL haszn�lat�nak befejez�se, az esetleg akt�v k�dfriss�t�sek lez�r�s�val.     //
// (A h�v�s kiadhat� akkor is, ha az UsbHidOpen h�v�ssal a DLL haszn�lata m�g       //
// nem volt kezdem�nyezve.)                                                         //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
procedure UsbHidClose; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A DLL �ltal haszn�lt (csatlakoztatott) eszk�z�k sz�m�nak lek�rdez�se.            //
//                                                                                  //
//  Visszat�r�si �rt�k:   A csatlakoztatott eszk�z�k sz�ma                          //
//                        (0 eset�n egy eszk�z sincs csatlakoztatva)                //                                                          //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  UsbGetNumdev: Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A k�v�nt eszk�z jellemz�inek bek�r�se.                                           //
//                                                                                  //
//  Param�terek:                                                                    //
//                (in)  devnum   A lek�rdezni k�v�nt eszk�z sorsz�ma                //
//                               (0-t�l UsbGetNumdev - 1 �rt�kig)                   //
//                (out) devpro   Az eszk�z jellemz�inek t�rhelye                    //
//                (in)  nummod   Az eszk�zsz�m m�dja                                //
//                              (False eset�n hex, True eset�n decim�lis form�tum)  //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    Sikeres m�velet, jellemz�k a          //
//                                            "devpro" param�terrel le�rt helyen    //
//                ERROR_MOD_NOT_FOUND         Ilyen sz�m� eszk�z nincs jelenleg     //
//                                            csatlakoztatva                        //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  UsbHidGetProperty(devnum: Dword; var devpro: USBTUL; nummod: BOOL): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A k�v�nt eszk�znek �zenet k�ld�se.                                               //
//                                                                                  //
//  Param�terek:                                                                    //
//                (in)  devnum   A megc�mzett eszk�z sorsz�ma                       //
//                               (0-t�l UsbGetNumdev - 1 �rt�kig)                   //
//                (in)  buffer   A k�ldeni k�v�nt �zenetpuffer c�me (PUSB_buf)      //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    Sikeres m�velet                       //
//                ERROR_MOD_NOT_FOUND         Ilyen sz�m� eszk�z nincs jelenleg     //
//                                            csatlakoztatva                        //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  UsbHidWrite(devnum: Dword; const buffer): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A k�v�nt eszk�z�n k�dfriss�t�s (firmware update) ind�t�sa.                       //
//                                                                                  //
//  Param�terek:                                                                    //
//                (in)  devnum   A megc�mzett eszk�z sorsz�ma                       //
//                               (0-t�l UsbGetNumdev - 1 �rt�kig)                   //
//                (in)  fwname   A k�d friss�t�st tartalmaz� f�jl nev�nek c�me      //
//                (out) hibkod   NO_ERROR v�lasz eset�n a friss�t� csomagok sz�ma,  //
//                               m�s v�lasz eset�n a hiba l�trej�tt�nek Windows     //
//                               hibak�dja                                          //
//                (in)  msgert   A friss�t�s folyamat�r�l t�j�koztat� �zenet        //
//                               k�dja (message code)                               //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    Sikeres friss�t�sind�t�s              //
//                ERROR_MOD_NOT_FOUND         Ilyen sz�m� eszk�z nincs jelenleg     //
//                                            csatlakoztatva                        //
//                ERROR_FUNCTION_NOT_CALLED   A friss�t�s jelenleg akt�v            //
//                ERROR_OPEN_FAILED           A friss�t�sindit�sn�l f�jl m�veleti   //
//                                            hiba (konkr�t hibak�d "hibkod"-ban)   //
//                ERROR_FILE_INVALID          Hib�s k�dfriss�t� f�jl fel�p�t�s      //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  UsbHidUpgrade(devnum: Dword; const fwname: PChar; var hibkod: Dword; msgert: Dword): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A k�v�nt eszk�z�n a k�dfriss�t�s (firmware update) le�ll�t�sa. (A h�v�s          //
// kiadhat� akkor is, ha az UsbHidUpgrade h�v�ssal a k�dfriss�t�s m�g nem volt      //
// kezdem�nyezve, vagy a friss�t�s m�r v�get �rt.)                                  //
//                                                                                  //
//  Param�terek:                                                                    //
//                (in)  devnum   A megc�mzett eszk�z sorsz�ma                       //
//                               (0-t�l UsbGetNumdev - 1 �rt�kig)                   //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    Sikeresen le lett �ll�tva             //
//                                            vagy a friss�t�s jelenleg nem akt�v.  //
//                ERROR_MOD_NOT_FOUND         Ilyen sz�m� eszk�z nincs jelenleg     //
//                                            csatlakoztatva                        //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function  UsbHidUpgradeClose(devnum: Dword): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// A DLL verzi�j�nak �s teljes nev�nek lek�rdez�se.                                 //
//                                                                                  //
//  Param�terek:  (out)  versms  A DLL verzi�j�nak magasabbik r�sze                 //
//                (out)  versls  A DLL verzi�j�nak alacsonyabbik r�sze              //
//                (out)  dllnam  A DLL neve teljes el�r�si �tvonallal               //
//                (in)   namlen  A DLL n�v hely�nek m�rete                          //
//                       (a sz�ks�ges ter�let maxim�lis m�rete: MAX_PATH)           //
//                                                                                  //
//  Visszat�r�si �rt�k:                                                             //
//                NO_ERROR                    Sikeres m�velet                       //
//                egy�b �rt�kek               Windows m�veleti hibak�dok            //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
function UsbGetDLLVersion(var versms, versls: Dword; dllnam: PChar; namlen: Dword): Dword; stdcall; external HID_KER_USB_PATH;
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// Be�rkez� (v�lasz) puffer esem�ny�nek �zenetfel�p�t�se. Az �zenet k�dja           //
// (message code) az UsbHidOpen "msgert" param�terek�nt lett megadva. A k�d         //
// �rt�k�nek "illik" nagyobbnak lenni, mint WM_USER �rt�ke.                         //
//                                                                                  //
//  WParam: (Dword)   LParam nem nulla eset�n az �zenetet k�ld� eszk�z sz�ma        //
//                    (l�sd m�g "devnum" h�v�s param�terek)                         //
//  LParam: (Dword)   Nem nulla eset�n a WParam sz�m� eszk�z �ltal k�ld�tt          //
//                    puffer c�me (PUSB_buf)                                        //
//                    0 eset�n a csatlakoztatott eszk�z�k sz�m�ban t�rt�n�          //
//                    v�ltoz�s bejelent�se. Ilyen esetben a csatlakoztatott         //
//                    eszk�z�k sorsz�ma (devnum) megv�ltozhat!                      //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////
//                                                                                  //
// K�dfriss�t�s esem�ny�nek �zenetfel�p�t�se. Az �zenet k�dja (message code) az     //
// UsbHidUpgrade "msgert" param�terek�nt lett megadva. A friss�t�s folyamat�ban     //
// az elk�ld�t friss�t� rekordra adott v�lasz ut�n j�n l�tre. A k�d �rt�k�nek       //
// "illik" nagyobbnak lenni, mint WM_USER �rt�ke.                                   //
//                                                                                  //
//  WParam: (Dword)   LParam = NO_ERROR eset�n a m�g h�ral�v� k�dfriss�t�           //
//                    rekordok sz�ma. (0 eset�n a k�dfriss�t�s k�sz)                //
//                                                                                  //
//  LParam: (Dword)   A friss�t�s hibak�dja                                         //
//                        NO_ERROR            Sikeres m�velet                       //
//                        CRCERR	            CRC hib�s k�dm�dos�t� rekord          //
//                                            van a k�dfiss�t�sre kijel�lt          //
//                                            f�jlban.                              //
//                        NOTUPG	            Nem v�grehajthat� a k�dm�dos�t�s      //
//                                            a f�rmver aktu�lis verzi�j�n a        //
//                                            a k�dfiss�t�sre kijel�lt f�jllal      //
//                                            (elt�r� bels� f�rmver strukt�r�k)     //
//                        WRIERR	            A k�d m�dos�t�s sor�n �r�shiba az     //
//                                            eszk�z k�dter�let�n                   //
//                        egy�b �rt�kek       Az adott eszk�zre jellemz� egy�b      //
//                                            hiba (pl. jogosults�gi hi�ny...)      //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////
//
implementation
//
end.
