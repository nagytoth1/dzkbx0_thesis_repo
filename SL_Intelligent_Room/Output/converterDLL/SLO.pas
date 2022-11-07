unit SLO;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, StdCtrls, ExtCtrls, Inifiles, Multimon, Gauges, Winsock,
  SLDLL;
const
//
// Az �zenetsz�m amin kereszt�l az SLDLL.DLL kommunik�l
//
  UZESAJ                  = WM_USER + 0;                    // Saj�t USB vett �zenet (USB vett csomag �rkezett)
//
// A form LED imit�ci�inak sz�ma
//
  LEDLDB                  = 19;                             // Ennyi LED van a l�mpa panelon
  LEDNDB                  = 26;                             // Ennyi LED van a ny�l panelon
//
// Az �zenet fejl�c�nek sz�egkonstansai
//
  DLGERR                  = 'Hibajelz�s';                   // �zenet fejl�c hiba eset�n
  DLGINF                  = 'Inform�ci�';                   // �zenet fejl�c norm�l esetben
  DLGVAL                  = 'V�laszt�s';                    // �zenet fejl�c norm�l esetben
//
// Az INI f�jl sz�vegkonstansai
//
  INIKIT                  = '.INI';
  PARAMS                  = 'Param';
  TOPSZA                  = 'Top';
  LEFSZA                  = 'Left';
  SZINAL                  = 'L�mpasz�nar�ny';
  SZINAN                  = 'Ny�lsz�nar�ny';
  ARALER                  = 'LEDR';
  ARALEG                  = 'LEDG';
  ARALEB                  = 'LEDB';
  ARANYR                  = 'NyilR';
  ARANYG                  = 'NyilG';
  ARANYB                  = 'NyilB';
//
// A hint megjene�si ideje sz�vegkonstans
//
  HIDEPA                  = 'HintHidePause';                 // Hint megjelen�si id�
//
// A hangle�r� INI r�sz sz�vegkonstansai
//
  HANGSS                  = 'Hang';
  HANGDA                  = 'Darabsz�m';
  HANGHN                  = 'Hanghossz';
  HANGSN                  = 'Hangsorsz�m';
  HANGEN                  = 'Hanger�';
//
// D�tumform�tum a verzi�hoz
//
  DATFOR                  = 'yyyy.MM.dd';
//
// Verzi�lek�r�shez
//
  DEFSTR                  = '\';

  SLRUNM                  = 'Somodi L�szl� kijelz� �s hangsz�r� kezel� program';
  VERKIF                  = '%s Verzi�: %d.%d';
  MARFUT                  = 'Ez a program m�r fut egy p�ld�nyban!';
  FEJLET                  = '%s %5.5X %d.%2.2d %4.4d/%2.2d/%2.2d %s';
  MODBEF                  = 'A m�dos�t�s �s az �jraind�t�s sikeresen megt�rt�nt.';
  VDDHOM                  = 'A VDD �rt�ke: %d.%2.2dV a proci h�m�rs�klete: %2d.%d�C';
  SELUSB                  = 'Eszk�z v�laszt�s ';
  NUMEST                  = 'Az azonos�t� be�ll�t�sa a(z) %4.4X sz�m� %s eszk�z�n ';
  KODSTR                  = 'K�dfriss�t�s a(z) %4.4X sz�m� %s eszk�z�n ';
  OPFISO                  = 'Nem siker�lt megnyitni a %s f�jlt. Hibak�d: %d %s';
  LEDLIS                  = 'LED l�map sz�nbe�ll�t�si hiba. Hibak�d: %d %s';
  LEDNIS                  = 'LED ny�l sz�nbe�ll�t�si hiba. Hibak�d: %d %s';
  HANGIS                  = 'Hangstring ind�t�si hiba. Hibak�d: %d %s';
  AZOVNS                  = 'Nem siker�lt elind�tani. Hibak�d: %d %s';
  NEMSIF                  = 'Friss�t�sind�t�si hiba. Hibak�d: %d. %s';
  DEVNHI                  = 'Eszk�z kiv�laszt�s hiba.';
  KODSET                  = 'K�dfriss�t�s a(z) %s:%d egys�gen';
  LEDLSU                  = 'A LED l�mpa kijelz�s be�ll�t�sa a(z) %4.4X sz�m� %s eszk�z�n ';
  LEDNSU                  = 'A ny�l kijelz�s be�ll�t�sa a(z) %4.4X sz�m� %s eszk�z�n ';
  LEDLSS                  = 'A(z) %s sz�n�sszetev� �rt�ke. (Minimum: %d, maximum %d, most: %d)';
  GEPKIA                  = 'Az �rt�k maximum 16382 lehet, �s nem lehet 0!';
  HANGSU                  = 'Hangkialak�t�s a(z) %4.4X sz�m� %s eszk�z�n ';
  SLLNAM                  = 'SLLHEX.BIN';
  SLNNAM                  = 'SLNHEX.BIN';
  SLHNAM                  = 'SLHHEX.BIN';
  SLLTIT                  = 'A LED l�mpa kijelz� panel friss�t�s�t tartalmaz� f�jl kiv�laszt�sa';
  SLNTIT                  = 'A LED ny�l kijelz� panel friss�t�s�t tartalmaz� f�jl kiv�laszt�sa';
  SLHTIT                  = 'A hangsz�r� meghajt� panel friss�t�s�t tartalmaz� f�jl kiv�laszt�sa';
  TALDRB                  = 'A felm�r�s lezajlott. Az RS485 buszon %d eszk�zt tal�ltam.';
  HANGES                  = 'Hanger� (Min.: %d, Max.: %d, Most: %d)';
  HANGST                  = '%s %4d msec. Hanger�: %3d';
  SZUNET                  = '%s %4d msec.';
  DLLIHI                  = 'A DLL ind�t�sa nem siker�lt. (Esetleg nincs semmilyen USB eszk�z?)' + #13 + #10 + 'Hibak�d: %d %s. Kil�pek.';
  VALTST                  = 'A felm�r�sn�l v�lasz Time-Out volt.';
  ENDHIK                  = 'A felm�r�s hib�val �rt v�get. Hibak�d: %d.';
  DARSEM                  = 'A felm�r�s nem tal�lt egy eszk�zt sem. (Ilyen nem is lehetne!)';
  DARELT                  = 'Elt�r�ek a felm�r�s sor�n meg�llapitott darabsz�mok.';
  VALTSE                  = #13 + #10 + '�jraind�tsam a felm�r�st? (Igen)';
  AZOVST                  = 'Az azonos�t� megv�ltoztat�sa sikeres volt.';
  USBELH                  = 'A vez�rl� USB eszk�z elt�vol�t�sra ker�lt';
  LISENJ                  = 'A feladatlista v�grehajt�sa sikeresen v�get�rt.';
  LISENS                  = 'A feladatlista v�grehajt�sa v�get�rt. Hibak�d: %d %s';

type
//
// A LED l�mpa megjelen�se
//
  LEDLAR = array [0..(LEDLDB - 1)] of TShape;
//
// A LED ny�l megjelen�se
//
  LEDNAR = array [0..(LEDNDB - 1)] of TShape;
//
// A sz�n�ll�t�shoz tartoz� potm�ter-Label p�ros
//
  LEDLNY = packed record
    potmet: TTrackBar;
    potmel: TLabel;
  end;
//
// Az RGB-hez 3 darab kell bel�le
//
  LEDLFA = array [0..2] of LEDLNY;
//
// Az �zenethez t�pusle�r�k
//
  msgdty = (mtError, mtInformation, mtConfirmation);
//
  kpdlgb = (mbYes, mbNo, mbOK);
  kpdlgbs = set of kpdlgb;
//
// A formom elemei
//
  TSLF = class(TForm)
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    ExitMenuElem: TMenuItem;
    Teendok: TMenuItem;
    AzonositoBeallitasa: TMenuItem;
    Programfrissites: TMenuItem;
    StatusBar: TStatusBar;
    EEPmuvelet: TGroupBox;
    Gauge: TGauge;
    NumEditBox: TGroupBox;
    NOFejLabel: TLabel;
    AzonositoKilep: TButton;
    NumEdit: TEdit;
    AzonositoBeallit: TButton;
    SelDevGroup: TGroupBox;
    DevListBox: TListBox;
    MegsemValasztButton: TButton;
    KivalasztButton: TButton;
    Timer: TTimer;
    FirmwareUpdateDialog: TOpenDialog;
    LEDLampaGroupBox: TGroupBox;
    BeleptetoOraLabel: TLabel;
    LocTimeOraLabel: TLabel;
    LEDLampaLabel: TLabel;
    LEDLampaKilepButton: TButton;
    LEDLampaKijelzo: TMenuItem;
    LEDNyilKijelzo: TMenuItem;
    LEDLampaShape00: TShape;
    LEDLampaShape01: TShape;
    LEDLampaShape02: TShape;
    LEDLampaShape03: TShape;
    LEDLampaShape04: TShape;
    LEDLampaShape05: TShape;
    LEDLampaShape06: TShape;
    LEDLampaShape07: TShape;
    LEDLampaShape08: TShape;
    LEDLampaShape09: TShape;
    LEDLampaShape10: TShape;
    LEDLampaShape11: TShape;
    LEDLampaShape12: TShape;
    LEDLampaShape13: TShape;
    LEDLampaShape14: TShape;
    LEDLampaShape15: TShape;
    LEDLampaShape16: TShape;
    LEDLampaShape17: TShape;
    LEDLampaShape18: TShape;
    LEDLampaRLabel: TLabel;
    LEDLampaRTrackBar: TTrackBar;
    LEDLampaGLabel: TLabel;
    LEDLampaGTrackBar: TTrackBar;
    LEDLampaBLabel: TLabel;
    LEDLampaBTrackBar: TTrackBar;
    LEDNyilGroupBox: TGroupBox;
    LEDNyilLabel: TLabel;
    LEDNyilShape06: TShape;
    LEDNyilShape23: TShape;
    LEDNyilRLabel: TLabel;
    LEDNyilGLabel: TLabel;
    LEDNyilBLabel: TLabel;
    LEDNyilKilepButton: TButton;
    LEDNyilRTrackBar: TTrackBar;
    LEDNyilGTrackBar: TTrackBar;
    LEDNyilBTrackBar: TTrackBar;
    LEDNyilShape07: TShape;
    LEDNyilShape22: TShape;
    LEDNyilShape08: TShape;
    LEDNyilShape21: TShape;
    LEDNyilShape11: TShape;
    LEDNyilShape15: TShape;
    LEDNyilShape24: TShape;
    LEDNyilShape05: TShape;
    LEDNyilShape04: TShape;
    LEDNyilShape25: TShape;
    LEDNyilShape16: TShape;
    LEDNyilShape03: TShape;
    LEDNyilShape02: TShape;
    LEDNyilShape19: TShape;
    LEDNyilShape12: TShape;
    LEDNyilShape20: TShape;
    LEDNyilShape18: TShape;
    LEDNyilShape13: TShape;
    LEDNyilShape10: TShape;
    LEDNyilShape01: TShape;
    LEDNyilShape09: TShape;
    LEDNyilShape14: TShape;
    LEDNyilShape17: TShape;
    LEDNyilShape00: TShape;
    BalraRadioButton: TRadioButton;
    JobbraRadioButton: TRadioButton;
    SzinaranyLEDCheckBox: TCheckBox;
    HangszoroPanelKezeles: TMenuItem;
    SzinaranyNyilCheckBox: TCheckBox;
    HangszoroGroupBox: TGroupBox;
    HangmagassagLabel: TLabel;
    HangszoroLabel: TLabel;
    HangeroLabel: TLabel;
    HangszoroKilepButton: TButton;
    HangeroTrackBar: TTrackBar;
    HangListBox: TListBox;
    LejatszasButton: TButton;
    HangmagassagComboBox: TComboBox;
    HanglistaLabel: TLabel;
    HanghosszLabel: TLabel;
    HanghosszComboBox: TComboBox;
    HangPopupMenu: TPopupMenu;
    Torles: TMenuItem;
    Folfele: TMenuItem;
    Lefele: TMenuItem;
    Ujhang: TMenuItem;
    Ujrafelmeres: TMenuItem;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure KilepClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure MenuinditClick(Sender: TObject);
    procedure NumEditKeyPress(Sender: TObject; var Key: Char);
    procedure AzonositoBeallitClick(Sender: TObject);
    procedure DevListBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DevListBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure KivalasztButtonClick(Sender: TObject);
    procedure NumEditChange(Sender: TObject);
    procedure ExitMenuElemClick(Sender: TObject);
    procedure LEDLampaTrackBarChange(Sender: TObject);
    procedure LEDNyilTrackBarChange(Sender: TObject);
    procedure SzinaranyLEDCheckBoxClick(Sender: TObject);
    procedure HangeroTrackBarChange(Sender: TObject);
    procedure UjhangClick(Sender: TObject);
    procedure HangmagassagComboBoxChange(Sender: TObject);
    procedure TorlesClick(Sender: TObject);
    procedure HangPopupMenuPopup(Sender: TObject);
    procedure HangListBoxClick(Sender: TObject);
    procedure FolfeleClick(Sender: TObject);
    procedure LefeleClick(Sender: TObject);
    procedure LejatszasButtonClick(Sender: TObject);
    procedure SzinaranyNyilCheckBoxClick(Sender: TObject);
    procedure UjrafelmeresClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    // Esem�ny az applik�ci� vonszol�sra
    procedure appmov(var Msg: TMessage); message WM_EXITSIZEMOVE;
    // Az applik�ci� vonszol�sa
    procedure appmor(const holcur: TPoint);
    // Az �rkezett DLL �zenet feldolgoz�sa
    procedure uzfeld(var Msg: TMessage); message UZESAJ;
    // Az applik�ci� m�ret�nek igaz�t�sa sz�ks�ges m�rethez
    procedure posapp(magert, szeler: Integer);
    // A m�velet ablak�nak aktiviz�l�sa
    procedure indwin(melyab: TGroupBox; melygo: TWinControl; gepkod: Dword; const boxstr: String);
    // Hosszbe�ll�t�sok �jragondol�sa
    procedure hosmod;
    // A LED l�mpa �llapot kit�lt�se
    procedure ledbea(const locsta: ELVSTA);
    // A LED ny�l �llapot kit�lt�se
    procedure nyilbe(const locsta: ELVSTA);
    // A hangsz�r� �llapot kit�lt�se
    procedure hanbea(const locsta: ELVSTA);
    // A m�velethez tartoz� eszk�z meghat�roz�sa
    procedure seldev;
    // A m�velet kiv�laszt�sa �s v�grehajt�sa
    procedure indfel;
    // Lista m�retbe�ll�t�s
    procedure listom(var tarbox: TGroupBox; var lisbox: TListBox; kozgom: TButton; widthb: Boolean);
    // Hang�llapot friss�t�s
    procedure frisha;
    // Hangelem kit�tel
    procedure reckit(hovate: Integer);
    // Hangelem a list�ba
    procedure recfri(melyfr: Integer);
//    // Pufferk�ld�s
//    procedure indpck;
  end;

var
  SLF: TSLF;
  muthnd: THandle;
//
// Hiba�zenet a form poz�ci�j�n
//
function sajuze(const kirand: String; dlgtyp: msgdty; dlgbut: kpdlgbs; mitfor: TForm): TModalResult; Forward;
//
implementation
//
// A programom v�ltoz�i
//
var
  lehall: Boolean;                          // �llithat� a kijelz�s
  lehlis: Boolean;                          // �llithat� a listabox
  aktadr: Word;                             // Az aktu�lis c�m
  hangdb: Dword;                            // A hangle�r� elemsz�ma
  minsel: Integer;                          // Alap magass�g h�l�zatv�laszt�shoz
  drb485: Integer;                          // Az RS485-n el�rhet� eszk�z�k sz�ma
  akt485: Integer;                          // Az RS485-s eszk�z�k sz�ma
  aktind: Integer;                          // A hanglista aktu�lis indexe;
  ositop, osleft: Integer;                  // Az aktu�lis k�perny� poz�ci�ja
  scrlef, scrtop, scrhei, scrwid: Integer;  // Elhelyezked�si adatok
  vrefer: Int64 = 2420000;                  // 2.42 V a n�vleges VREF �rt�k
  vddert: Int64;                            // A VDD aktu�lis �rt�ke
  sajini: TIniFile;                         // Az INI f�jl kezel� elemei
  mitind: TMenuItem;                        // Amit elind�tottunk
  devusb: PDEVSEL;                          // Az USB eszk�z�k jellemz�i
  dev485: DEVLIS;                           // A le�r�k c�me
  ledlaa: LEDLAR;                           // A LED l�mp�k list�ja
  lednaa: LEDNAR;                           // A LED nyilak list�ja
  ledlfs: LEDLFA;                           // A LED l�mp�k sz�nbe�ll�t�sa
  lednfs: LEDLFA;                           // A LED nyil sz�nbe�ll�t�sa
  hangtb: HANGLA;                           // Hangle�r�k t�bl�zata
  listoi: array of Integer;                 // Index a soros elemekhez
  tblveg: LISTBL;                           // A t�bbsz�r�s v�grehajt�s puffere
//
  capstr: String;                           // Fejl�c kialak�t�s stringje
  statso: String;                           // A st�tusz sor�nak tartalma
  butwit: array[kpdlgb] of Integer;         // Kezd�skor null�val felt�ltve
//
// Az �zenet elemei
//
  butcap: array[kpdlgb] of PChar = ('&Igen', '&Nem', '&OK');
  capdlg: array[msgdty] of String = (DLGERR, DLGINF, DLGVAL);
  iconid: array[msgdty] of PChar = (IDI_HAND, IDI_ASTERISK, IDI_QUESTION);
  modret: array[kpdlgb] of Integer = (mrYes, mrNo, mrOk);
//
// K�dfriss�t�s sor�n el�fordul� hib�k sz�vegei
//
  hibtxt: array [1..4] of PChar = ('CRC hib�s k�dm�dos�t� puffer.',
                                   'Nem friss�thet� ez a verzi�.',
                                   'K�d m�dos�t�sn�l �r�shiba.',
                                   'Ismeretlen hibak�d.'
                                  );
//
// A sz�n�sszetev�k "sz�veg" konstansai
//
  szintb: array [0..2] of String = ('R',
                                    'G',
                                    'B'
                                  );
////////////////////////////////////////////////////////////////////////////////////
//                                                                                //
// Az egyes bels� rutinok defini�l�sa.                                            //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////
//
// BCD b�jt bin�risra alak�t�s
//
function bcdtob(amibcd: Byte): Dword; Forward;
//
// A kurzor poz�ci�j�hoz kapcsol�d� monitor adatainak lek�rdez�se
//
procedure apppos(const holcur: TPoint); Forward;
//
// Numerikus hibak�db�l sz�veges hibale�r�s (string) konvert�l�s
//
function gethks(hibkod: Dword): String; Assembler; Forward;
//
// Az INI f�jl fel�l�r�sa csak sz�ks�g eset�n
//
procedure iniupd(const szeknm, keynam: String; const keyert: BOOL); Forward; overload;
procedure iniupd(const szeknm, keynam: String; const keyert: String); Forward; overload;
procedure iniupd(const szeknm, keynam: String; keyert: Integer); Forward; overload;
//
// H�m�rs�klet �s VDD kialak�t�s
//
procedure homvdd(const mitmer: MERESE; mitlab: TLabel); Forward;
//
// Jellmz� string kialak�t�sa
//
function verstr(var melyik: DEVSEL): String; Forward;
//
{$R *.DFM}
//
function sajuze(const kirand: String; dlgtyp: msgdty; dlgbut: kpdlgbs; mitfor: TForm): TModalResult;
var
  i, j, hormar, vermar, horspa, verspa, butwid, buthei, itxwid, itxhei: Integer;
  butspa, vertma, vertsp: Integer;
  holcur, diunsi: TPoint;
  txtrct: TRect;
  buffer: array[0..51] of Byte;
  forbut, defbut, canbut: kpdlgb;
  letreh: TForm;

  function Max(i, j: Integer): Integer;
  begin
    if(i > j) then
    begin
      Result := i
    end
    else
    begin
      Result := j;
    end;
  end;
begin
  //
  // L�trehozom az �zenet Form-j�t
  //
  i := 0;
  j := ORD('A');
  while(i < 52) do
  begin
    buffer[i] := j;
    buffer[i + 1] := j + 32;
    i := i + 2;
    inc(j);
  end;
  //
  // L�trehozom az �zenet Form-j�t
  //
  letreh := TForm.CreateNew(Application);
  with letreh do
  begin
    BiDiMode := Application.BiDiMode;
    BorderStyle := bsDialog;
    Canvas.Font := Font;
    GetTextExtentPoint(Canvas.Handle, PChar(@buffer[0]), i, TSize(diunsi));
    diunsi.X := diunsi.X DIV i;
    hormar := MulDiv(8, diunsi.X, 4);
    vermar := MulDiv(8, diunsi.Y, 8);
    horspa := MulDiv(10, diunsi.X, 4);
    verspa := MulDiv(10, diunsi.Y, 8);
    butwid := MulDiv(50, diunsi.X, 4);
    vertma := MulDiv(8, diunsi.Y, 8);
    vertsp := MulDiv(10, diunsi.Y, 8);
    for forbut := Low(kpdlgb) to High(kpdlgb) do
    begin
      if(forbut in dlgbut) then
      begin
        if(butwit[forbut] = 0) then
        begin
          txtrct := Rect(0, 0, 0, 0);
          Windows.DrawText(Canvas.Handle, butcap[forbut], -1, txtrct,
                           DT_CALCRECT OR DT_LEFT OR DT_SINGLELINE OR DrawTextBiDiModeFlagsReadingOnly);
          butwit[forbut] := txtrct.Right - txtrct.Left + 8;
        end;
        if(butwit[forbut] > butwid) then
        begin
          butwid := butwit[forbut];
        end;
      end;
    end;
    buthei := MulDiv(14, diunsi.Y, 8);
    butspa := MulDiv(4, diunsi.X, 4);
    txtrct := Rect(0, 0, Screen.Width DIV 2, 0);
    DrawText(Canvas.Handle, PChar(kirand), Length(kirand) + 1, txtrct,
             DT_EXPANDTABS OR DT_CALCRECT OR DT_WORDBREAK OR DrawTextBiDiModeFlagsReadingOnly);
    itxwid := txtrct.Right;
    itxhei := txtrct.Bottom;
    itxwid := itxwid + 32 + horspa;
    if(itxhei < 32) then
    begin
      itxhei := 32;
    end;
    i := 0;
    for forbut := Low(kpdlgb) to High(kpdlgb) do
    begin
      if(forbut in dlgbut) then
      begin
        inc(i);
      end;
    end;
    j := 0;
    if(i <> 0) then
    begin
      j := butwid * i + butspa * (i - 1);
    end;
    ClientWidth := Max(itxwid, butwid) + (hormar * 2);
    ClientHeight := itxhei + buthei + verspa + (vermar * 2);
    Caption := capdlg[dlgtyp];
    TImage(i) := TImage.Create(letreh);
    TImage(i).Name := 'Image';
    TImage(i).Parent := letreh;
    TImage(i).Picture.Icon.Handle := LoadIcon(0, iconid[dlgtyp]);
    TImage(i).SetBounds(hormar, vermar, 32, 32);
    TLabel(i) := TLabel.Create(letreh);
    TLabel(i).Name := 'Message';
    TLabel(i).Parent := letreh;
    TLabel(i).WordWrap := True;
    TLabel(i).Caption := kirand;
    TLabel(i).BoundsRect := txtrct;
    TLabel(i).BiDiMode := letreh.BiDiMode;
    hormar := itxwid - txtrct.Right + hormar;
    if(TLabel(i).UseRightToLeftAlignment) then
    begin
      hormar := letreh.ClientWidth - hormar - TLabel(i).Width;
    end;
    TLabel(i).SetBounds(hormar, vermar, txtrct.Right, txtrct.Bottom);
    if(mbOk in dlgbut) then
    begin
      defbut := mbOk;
    end
    else
    begin
      defbut := mbYes;
    end;
    if(mbNo in dlgbut) then
    begin
      canbut := mbNo;
    end
    else
    begin
      canbut := mbOk;
    end;
    j := (ClientWidth - j) DIV 2;
    for forbut := Low(kpdlgb) to High(kpdlgb) do
    begin
      if(forbut in dlgbut) then
      begin
        TButton(i) := TButton.Create(letreh);
        TButton(i).Name := PChar(@butcap[forbut][1]);
        TButton(i).Parent := letreh;
        TButton(i).Caption := butcap[forbut];
        TButton(i).ModalResult := modret[forbut];
        if(forbut = defbut) then
        begin
          TButton(i).Default := True;
        end;
        if(forbut = canbut) then
        begin
         TButton(i).Cancel := True;
        end;
        TButton(i).SetBounds(j, itxhei + vertma + vertsp, butwid, buthei);
        j := j + butwid + butspa;
      end;
    end;
  end;
  if(mitfor = NIL) then
  begin
    holcur.x := 0;
    holcur.y := 0;
    i := 0;
    j := 0;
    holcur.x := 0;
    holcur.y := 0;
    apppos(holcur);
    hormar := scrwid;
    vermar := scrhei;
  end
  else
  begin
    i := mitfor.Left;
    j := mitfor.Top;
    holcur.x := i;
    holcur.y := j;
    apppos(holcur);
    hormar := mitfor.Width;
    vermar := mitfor.Height;
  end;
  //
  // Elhelyezem a saj�t programomhoz k�pest X ir�nyba k�z�pre
  //
  i := i + ((hormar - letreh.Width) DIV 2);
  //
  // Ellen�rz�m, hogy nem l�g-e le a k�perny�r�l balra
  //
  if(i < scrlef) then
  begin
    i := scrlef;
  end;
  //
  // Ellen�rz�m, hogy nem l�g-e le a k�perny�r�l jobbra
  //
  if((i + letreh.Width) > scrwid) then
  begin
    i := hormar - letreh.Width;
  end;
  //
  // Most m�r OK. az X poz�ci�
  //
  letreh.Left := i;
  //
  // Elhelyezem a saj�t programomhoz k�pest Y ir�nyba k�z�pre
  //
  j := j + ((vermar - letreh.Height) DIV 2);
  //
  // Ellen�rz�m, hogy nem l�g-e le a k�perny�r�l fent
  //
  if(j < scrtop) then
  begin
    j := scrtop;
  end;
  //
  // Ellen�rz�m, hogy nem l�g-e le a k�perny�r�l lent
  //
  if((j + letreh.Height) > scrhei) then
  begin
    j := vermar - letreh.Height;
  end;
  //
  // Most m�r OK. az Y poz�ci�
  //
  letreh.Top := j;
  if(mitfor = NIL) then
  begin
    holcur.x := 0;
    holcur.y := 0;
    apppos(holcur);
    //
    // Elhelyezem a saj�t programomhoz k�pest X ir�nyba k�z�pre
    //
    i := ((scrwid - letreh.Width) DIV 2);
    //
    // Ellen�rz�m, hogy nem l�g-e le a k�perny�r�l balra
    //
    if(i < scrlef) then
    begin
      i := scrlef;
    end;
    //
    // Ellen�rz�m, hogy nem l�g-e le a k�perny�r�l jobbra
    //
    if((i + letreh.Width) > scrwid) then
    begin
      i := scrwid - letreh.Width;
    end;
    //
    // Most m�r OK. az X poz�ci�
    //
    letreh.Left := i;
    //
    // Elhelyezem a saj�t programomhoz k�pest Y ir�nyba k�z�pre
    //
    j := ((scrhei - letreh.Height) DIV 2);
    //
    // Ellen�rz�m, hogy nem l�g-e le a k�perny�r�l fent
    //
    if(j < scrtop) then
    begin
      j := scrtop;
    end;
    //
    // Ellen�rz�m, hogy nem l�g-e le a k�perny�r�l lent
    //
    if((j + letreh.Height) > scrhei) then
    begin
      j := scrhei - letreh.Height;
    end;
    //
    // Most m�r OK. az Y poz�ci�
    //
    letreh.Top := j;
  end
  else
  begin
    i := mitfor.Left;
    j := mitfor.Top;
    holcur.x := i;
    holcur.y := j;
    apppos(holcur);
    //
    // Elhelyezem a saj�t programomhoz k�pest X ir�nyba k�z�pre
    //
    i := i + ((mitfor.Width - letreh.Width) DIV 2);
    //
    // Ellen�rz�m, hogy nem l�g-e le a k�perny�r�l balra
    //
    if(i < scrlef) then
    begin
      i := scrlef;
    end;
    //
    // Ellen�rz�m, hogy nem l�g-e le a k�perny�r�l jobbra
    //
    if((i + letreh.Width) > scrwid) then
    begin
      i := scrwid - letreh.Width;
    end;
    //
    // Most m�r OK. az X poz�ci�
    //
    letreh.Left := i;
    //
    // Elhelyezem a saj�t programomhoz k�pest Y ir�nyba k�z�pre
    //
    j := j + ((mitfor.Height - letreh.Height) DIV 2);
    //
    // Ellen�rz�m, hogy nem l�g-e le a k�perny�r�l fent
    //
    if(j < scrtop) then
    begin
      j := scrtop;
    end;
    //
    // Ellen�rz�m, hogy nem l�g-e le a k�perny�r�l lent
    //
    if((j + letreh.Height) > scrhei) then
    begin
      j := scrhei - letreh.Height;
    end;
    //
    // Most m�r OK. az Y poz�ci�
    //
    letreh.Top := j;
  end;
  //
  // Csilingelek hozz�
  //
  case(dlgtyp) of
    mtError:
    begin
      MessageBeep(MB_ICONERROR);
    end;
    else
    begin
      MessageBeep(MB_ICONQUESTION);
//MB_ICONASTERISK	SystemAsterisk
//MB_ICONEXCLAMATION	SystemExclamation
//MB_ICONHAND	SystemHand
//MB_ICONQUESTION	SystemQuestion
//MB_OK	SystemDefault
    end;
  end;
  //
  // Elind�tom az �zenet Form-j�t
  //
  letreh.ShowModal;
  //
  // �zenet v�ge, elimin�lom a l�trehozott Form-ot
  //
  Result := letreh.ModalResult;
  letreh.Free;
end;
//
function bcdtob(amibcd: Byte): Dword;
begin
  Result := (amibcd AND $0f) + (amibcd SHR 4) * 10;
end;
//
procedure apppos(const holcur: TPoint);
var
  moninf: tagMONITORINFOA;
begin
  moninf.cbSize := SizeOf(tagMONITORINFOA);
  GetMonitorInfo(MonitorFromPoint(holcur, MONITOR_DEFAULTTONEAREST), @moninf);
  scrtop := moninf.rcWork.Top;
  scrlef := moninf.rcWork.Left;
	scrwid := moninf.rcWork.Right - scrlef;
	scrhei := moninf.rcWork.Bottom - scrtop;
end;
//
function gethks(hibkod: Dword): String; Assembler;
asm
    push  edi                           // El fogom rontani
    xor   ecx,ecx                       // Null�zok
    mov   edi,edx                       // A v�laszstring c�me
    push  ecx                           // A param�ter helye
    mov   edx,esp                       // A puffer c�me
    push  ecx                           // FormatMessage 7. param�ter
    push  ecx                           // FormatMessage 6. param�ter
    push  edx                           // FormatMessage 5. param�ter, a PChar c�me
    push  LANG_NEUTRAL OR (SUBLANG_DEFAULT SHL 16)// FormatMessage 4. param�ter
    push  eax                           // FormatMessage 3. param�ter, hibkod �rt�ke
    push  ecx                           // FormatMessage 2. param�ter
    push  FORMAT_MESSAGE_ALLOCATE_BUFFER OR FORMAT_MESSAGE_FROM_SYSTEM// FormatMessage 1. param�ter
    mov   eax,edi                       // LStrClr 1. param�ter, a v�laszstring le�r�ja
    call  System.@LStrClr               // Az eredeti hozz�rendel�st megsz�ntetem
    call  FormatMessage                 // Beolvasom a hibak�d sz�veg�t
    pop   edx                           // LStrFromPCharLen 2. param�ter, ez a sz�vegc�m
    sub   eax,2                         // Ennyivel kevesebb legyen a hossza
    js    @hibava                       // Negat�v lett, nem volt sikeres
    mov   ecx,eax                       // LStrFromPCharLen 3. param�ter, a hossz
    push  edx                           // LocalFree 1. param�ter
    mov   eax,edi                       // LStrFromPCharLen 1. param�ter, a v�laszstring c�me
    call  System.@LStrFromPCharLen      // A v�lasz �tm�sol�sa stringbe
    call  LocalFree                     // Felszabad�tom a FormatMessage puffer�t
  @hibava:
    pop   edi                           // Vissza a mentett �rt�k
end;
//
procedure iniupd(const szeknm, keynam: String; const keyert: BOOL);
begin
  if(sajini.ReadBOOL(szeknm, keynam, NOT keyert) <> keyert) then
  begin
    try
      sajini.WriteBOOL(szeknm, keynam, keyert);
    except
    end;
  end;
end;
//
procedure iniupd(const szeknm, keynam: String; const keyert: String);
begin
  if(sajini.ReadString(szeknm, keynam, keyert + '1') <> keyert) then
  begin
    try
      sajini.WriteString(szeknm, keynam, keyert);
    except
    end;
  end;
end;
//
procedure iniupd(const szeknm, keynam: String; keyert: Integer);
begin
  if(sajini.ReadInteger(szeknm, keynam, keyert + 1) <> keyert) then
  begin
    try
      sajini.WriteInteger(szeknm, keynam, keyert);
    except
    end;
  end;
end;
//
procedure homvdd(const mitmer: MERESE; mitlab: TLabel);
var
  i, j, k, l: Integer;
  s: String;
begin
  vddert := (((mitmer.vddert * vrefer) DIV (mitmer.vdddrb * 511)) + vrefer + 500) DIV 1000; // VDD milivoltban
  i := (vddert + 5) DIV 1000;
  j := ((vddert + 5) MOD 1000) DIV 10;
  l := ((((mitmer.tmpkul * vrefer * 10) DIV (mitmer.tmpdrb * 1023)) - 7640000) DIV 287) + 5; // A h�m�rs�klet 0.01� l�p�sben kerek�t�ssel
  k := l DIV 100;
  l := (l MOD 100) DIV 10;
  if(l < 0) then
  begin
    l := -l;
  end;
  s := Format(VDDHOM,[i, j, k, l]);
  if(s <> mitlab.Caption) then
  begin
    mitlab.Caption := s;
  end;
end;
//
function verstr(var melyik: DEVSEL): String;
begin
  Result := Format(FEJLET, [melyik.produc,
                            melyik.azonos AND $3fff,
                            melyik.idever.versih,
                            melyik.idever.versil,
                            melyik.idever.datume + 2000,
                            melyik.idever.datumh,
                            melyik.idever.datumn,
                            melyik.manufa]);
end;
//
procedure TSLF.FormCreate(Sender: TObject);
var
  i, j: Dword;
 	dwbuff: array of Byte;
	ffi: PVSFixedFileInfo;
  datepuf: _WIN32_FILE_ATTRIBUTE_DATA;
  lpSystemTime: TSYSTEMTIME;
  exenam: String;
begin
  exenam := Application.Exename;
  Application.ShowHint := True;
  sajini := TIniFile.Create(ChangeFileExt(exenam, INIKIT));
  //
  // Az el�z� poz�ci� beolvas�sa
  //
  ositop := sajini.ReadInteger(PARAMS, TOPSZA, Top);
  osleft := sajini.ReadInteger(PARAMS, LEFSZA, Left);
  //
  // A Hint-k idej�nek be�ll�t�sa (Csak az ini szerkeszt�s�vel m�dos�that� az id�!)
  //
  Application.HintHidePause := sajini.ReadInteger(PARAMS, HIDEPA, 10000);
  Top := ositop;
  Left := osleft;
  //
  // A program param�terek alapj�n verzi� �ssze�ll�t�s
  //
  ShortDateFormat := DATFOR;
  GetFileAttributesEx(PChar(exenam), GetFileExInfoStandard	, @datepuf);
  FileTimeToSystemTime(datepuf.ftLastWriteTime, lpSystemTime);
  i := GetFileVersionInfoSize(PChar(exenam), j);
  SetLength(dwbuff, i);
  GetFileVersionInfo(PChar(exenam), j, i, @dwbuff[0]);
	VerQueryValue(@dwbuff[0], DEFSTR, Pointer(ffi), i);
  capstr := Caption + Format(' %d.%d %4.4d/%2.2d/%2.2d', [
	    ffi^.dwProductVersionMS SHR 16,
	    ffi^.dwProductVersionMS AND $ffff,
//	    ffi^.dwProductVersionLS SHR 16,
//	    ffi^.dwProductVersionLS AND $ffff,
      lpSystemTime.wYear,
      lpSystemTime.wMonth,
      lpSystemTime.wDay
     ]);
  Caption := capstr;
  //
  // A kil�p�skori hanglista beolvas�sa
  //
  hangdb := sajini.ReadInteger(HANGSS, HANGDA, 0);
  if(hangdb > Dword(Length(hangtb))) then
  begin
    hangdb := Length(hangtb);
  end;
  i := 0;
  while(i < hangdb) do
  begin
    exenam := HANGHN + IntToStr(i);
    hangtb[i].hangho := sajini.ReadInteger(HANGSS, exenam, 0);
    exenam := HANGSN + IntToStr(i);
    hangtb[i].hangso := sajini.ReadInteger(HANGSS, exenam, 0);
    exenam := HANGEN + IntToStr(i);
    hangtb[i].hanger := sajini.ReadInteger(HANGSS, exenam, 0);
    inc(i);
  end;
  //
  // A LED l�mpa eszk�z LED imit�l� t�mb kialak�t�sa
  //
  ledlaa[0] := LEDLampaShape00;
  ledlaa[1] := LEDLampaShape01;
  ledlaa[2] := LEDLampaShape02;
  ledlaa[3] := LEDLampaShape03;
  ledlaa[4] := LEDLampaShape04;
  ledlaa[5] := LEDLampaShape05;
  ledlaa[6] := LEDLampaShape06;
  ledlaa[7] := LEDLampaShape07;
  ledlaa[8] := LEDLampaShape08;
  ledlaa[9] := LEDLampaShape09;
  ledlaa[10] := LEDLampaShape10;
  ledlaa[11] := LEDLampaShape11;
  ledlaa[12] := LEDLampaShape12;
  ledlaa[13] := LEDLampaShape13;
  ledlaa[14] := LEDLampaShape14;
  ledlaa[15] := LEDLampaShape15;
  ledlaa[16] := LEDLampaShape16;
  ledlaa[17] := LEDLampaShape17;
  ledlaa[18] := LEDLampaShape18;
  //
  // A LED l�mpa eszk�z RGB be�ll�t� t�mb kialak�t�sa
  //
  ledlfs[0].potmet := LEDLampaRTrackBar;
  ledlfs[0].potmel := LEDLampaRLabel;
  ledlfs[1].potmet := LEDLampaGTrackBar;
  ledlfs[1].potmel := LEDLampaGLabel;
  ledlfs[2].potmet := LEDLampaBTrackBar;
  ledlfs[2].potmel := LEDLampaBLabel;
  //
  // A LED l�mpa sz�nar�ny vissza�ll�t�sa
  //
  SzinaranyLEDCheckBox.Checked := sajini.ReadBOOL(PARAMS, SZINAL, False);
  ledlfs[0].potmet.Tag := sajini.ReadInteger(PARAMS, ARALER, 0);
  ledlfs[1].potmet.Tag := sajini.ReadInteger(PARAMS, ARALEG, 0);
  ledlfs[2].potmet.Tag := sajini.ReadInteger(PARAMS, ARALEB, 0);
  //
  // A LED ny�l eszk�z LED imit�l� t�mb kialak�t�sa
  //
  lednaa[0] := LEDNyilShape00;
  lednaa[1] := LEDNyilShape01;
  lednaa[2] := LEDNyilShape02;
  lednaa[3] := LEDNyilShape03;
  lednaa[4] := LEDNyilShape04;
  lednaa[5] := LEDNyilShape05;
  lednaa[6] := LEDNyilShape06;
  lednaa[7] := LEDNyilShape07;
  lednaa[8] := LEDNyilShape08;
  lednaa[9] := LEDNyilShape09;
  lednaa[10] := LEDNyilShape10;
  lednaa[11] := LEDNyilShape11;
  lednaa[12] := LEDNyilShape12;
  lednaa[13] := LEDNyilShape13;
  lednaa[14] := LEDNyilShape14;
  lednaa[15] := LEDNyilShape15;
  lednaa[16] := LEDNyilShape16;
  lednaa[17] := LEDNyilShape17;
  lednaa[18] := LEDNyilShape18;
  lednaa[19] := LEDNyilShape19;
  lednaa[20] := LEDNyilShape20;
  lednaa[21] := LEDNyilShape21;
  lednaa[22] := LEDNyilShape22;
  lednaa[23] := LEDNyilShape23;
  lednaa[24] := LEDNyilShape24;
  lednaa[25] := LEDNyilShape25;
  //
  // A LED ny�l eszk�z RGB be�ll�t� t�mb kialak�t�sa
  //
  lednfs[0].potmet := LEDNyilRTrackBar;
  lednfs[0].potmel := LEDNyilRLabel;
  lednfs[1].potmet := LEDNyilGTrackBar;
  lednfs[1].potmel := LEDNyilGLabel;
  lednfs[2].potmet := LEDNyilBTrackBar;
  lednfs[2].potmel := LEDNyilBLabel;
  //
  // A LED ny�l sz�nar�ny vissza�ll�t�sa
  //
  SzinaranyNyilCheckBox.Checked := sajini.ReadBOOL(PARAMS, SZINAN, False);
  lednfs[0].potmet.Tag := sajini.ReadInteger(PARAMS, ARANYR, 0);
  lednfs[1].potmet.Tag := sajini.ReadInteger(PARAMS, ARANYG, 0);
  lednfs[2].potmet.Tag := sajini.ReadInteger(PARAMS, ARANYB, 0);
end;

procedure TSLF.appmov(var Msg: TMessage);
var
  holcur: TPoint;
begin
  inherited;
  GetCursorPos(holcur);
  appmor(holcur)
end;

procedure TSLF.appmor(const holcur: TPoint);
begin
  apppos(holcur);
  if(Left < scrlef) then
  begin
    // a bal oldal korrekci�ja, ha kics�szott a bal oldalon
    Left := scrlef;
  end;
  if(Top < scrtop) then
  begin
    // a tetej�nek korrekci�ja, ha kics�szott fel�l
    Top := scrtop;
  end;
  if(Left > ((scrlef + scrwid) - Width)) then
  begin
    // a jobb oldal korrekci�ja, ha kics�szott a jobb oldalon
    Left := (scrlef + scrwid) - Width;
  end;
  if(Top > ((scrtop + scrhei) - Height)) then
  begin
    // az alj�nak korrekci�ja, ha kics�szott alul
    Top := (scrtop + scrhei) - Height;
  end;
  ositop := Top;
  osleft := Left;
end;

procedure TSLF.uzfeld(var Msg: TMessage);
var
  ujfelk: Boolean;
  i: Integer;
  upgpoi: PUPGPCK;
  s: String;
begin
  i := Msg.WParam;
  if(i <> 0) then
  begin
    if(i > 0) then
    begin
      //
      // Az esem�nyek v�laszai. (Pozit�v k�dok.)
      //
      case(i) of
        //
        // A felm�r�s lezajlott �zenet
        //
        FELMOK:
        begin
          drb485 := Msg.LParam;
          sajuze(Format(TALDRB, [drb485]), mtInformation, [mbOK], SLF);
          //
          // Lek�rdezem a tal�lt elemek t�bl�zat�nak c�m�t
          //
          SLDLL_Listelem(@dev485);
          //
          // Be�ll�tom a men�elemek enged�lyeit (Amik mindenk�ppen "vannak")
          //
          Teendok.Enabled := drb485 > 0;
          AzonositoBeallitasa.Enabled := drb485 > 0;
          Programfrissites.Enabled := drb485 > 0;
          Ujrafelmeres.Enabled := True;
          //
          // A specifikus elemek enged�ly�t is be�ll�tom
          //
          LEDLampaKijelzo.Enabled := False;
          LEDNyilKijelzo.Enabled := False;
          HangszoroPanelKezeles.Enabled := False;
          i := 0;
          while(i < drb485) do
          begin
            case(dev485[i].azonos AND $c000) of
              SLLELO:
              begin
                LEDLampaKijelzo.Enabled := True;
              end;
              SLNELO:
              begin
                LEDNyilKijelzo.Enabled := True;
              end;
              SLHELO:
              begin
                HangszoroPanelKezeles.Enabled := True;;
              end;
            end;
            inc(i);
          end;
        end;
        //
        // Azonos�t� v�lt�s lezaklott �zenet �rkezett
        //
        AZOOKE:
        begin
          sajuze(AZOVST, mtInformation, [mbOK], SLF);
          KilepClick(NIL);
        end;
        //
        // A k�dfriss�t�s folyamat�nak k�vet�se
        //
        FIRMUZ:
        begin
          upgpoi := PUPGPCK(Msg.LParam);
          i := upgpoi^.errcod;
          if(i = 0) then
          begin
            //
            // Mivel a k�dk�ld�zget�s k�t l�p�sb�l �ll, csak a fel�vel kell a sz�ml�l�nak sz�molni
            //
            Gauge.Progress := upgpoi^.aktdar DIV 2;
          end
          else
          begin
            //
            // A friss�t�s hiba�zenettel �rt v�get
            //
            if(i > Length(hibtxt)) then
            begin
              i := Length(hibtxt);
            end;
            sajuze(hibtxt[i], mtError, [mbOK], SLF);
            KilepClick(NIL);
          end;
        end;
        //
        // Az �jraindul�s �zenete
        //
        FIRMEN: // F�rmvercsere v�ge, �jraind�t�s elndul
        begin
          sajuze(MODBEF, mtInformation, [mbYes], SLF);
          KilepClick(NIL);
        end;
        //
        // A LED l�mpa RGB �rt�keinek �ll�t�s�t visszajelz� �zenet
        //
        LEDRGB: // A LED l�mpa RGB �rt�ke
        begin
          if(LEDLampaGroupBox.Visible) then
          begin
            lehall := True;
            ledbea(PELVSTA(Msg.LParam)^);
          end;
        end;
        //
        // A LED ny�l RGB �rt�keinek �ll�t�s�t
        // vagy ir�ny�nak m�dos�t�s�t visszajelz� �zenet
        //
        NYIRGB: // A ny�l RGB �rt�ke
        begin
          if(LEDNyilGroupBox.Visible) then
          begin
            lehall := True;
            nyilbe(PELVSTA(Msg.LParam)^);
          end;
        end;
        //
        // A hangstring elind�t�s�t visszajelz� �zenet
        //
        HANGEL: // A hangstring �llapota
        begin
          if(HangszoroGroupBox.Visible) then
          begin
            hanbea(PELVSTA(Msg.LParam)^);
          end;
        end;
        //
        // A men�ind�t�s �s st�tuszbek�r�s Timer �zenet�nek
        // visszajelz�se
        //
        STATKV:
        begin
          if(LEDLampaGroupBox.Visible) then
          begin
            ledbea(PELVSTA(Msg.LParam)^);
          end;
          if(LEDNyilGroupBox.Visible) then
          begin
            nyilbe(PELVSTA(Msg.LParam)^);
          end;
          if(HangszoroGroupBox.Visible) then
          begin
            hanbea(PELVSTA(Msg.LParam)^);
          end;
        end;
        LISVAL:
        begin
          i := Msg.LParam;
          if(i = NO_ERROR) then
          begin
            sajuze(LISENJ, mtInformation,  [mbOK], SLF);
            tblveg[1].lamrgb.rossze := tblveg[1].lamrgb.rossze XOR 255;
          end
          else
          begin
            sajuze(Format(LISENS, [i, gethks(i)]), mtError,  [mbOK], SLF);
          end;
        end;
      end;
    end
    else
    begin
      ujfelk := True;
      case(i) of
        USBREM: // Az USB vez�rl� elt�vol�t�sra ker�lt
        begin
          ujfelk := False;
          s := USBELH;
        end;
        VALTIO: // V�laszv�r�s time-out k�vetkezett be
        begin
          s := VALTST;
        end;
        FELMHK: // Felm�r�s v�ge hib�val
        begin
          s := Format(ENDHIK, [Msg.LParam]);
        end;
        FELMHD: // Nincs egy darab sem hibak�d (elvben sem lehet ilyen)
        begin
          s := DARSEM;
        end;
        FELMDE: // A 16 �s 64 bites darabsz�m nem egyforma
        begin
          s := DARELT;
        end;
      end;
      if(ujfelk) then
      begin
        i := sajuze(s + VALTSE, mtConfirmation, [mbYes, mbNo], SLF);
        if(i = mrYes) then
        begin
          SLDLL_Felmeres;
        end
        else
        begin
          Close;
        end;
      end
      else
      begin
        //
        // Az USB eszk�z elt�vol�t�sa eset�n letiltom a men�elemeket
        //
        KilepClick(NIL);
        Teendok.Enabled := False;
        Ujrafelmeres.Enabled := True;
        AzonositoBeallitasa.Enabled := False;
        LEDLampaKijelzo.Enabled := False;
        LEDNyilKijelzo.Enabled := False;
        HangszoroPanelKezeles.Enabled := False;
        Programfrissites.Enabled := False;
        sajuze(s, mtError, [mbOK], SLF);
      end;
    end;
  end
  else
  begin
//    if(PUSB_buf(Msg.LParam)^.tipus = $7f) then
//    begin
//      sajuze(PARKIA, mtError, [mbOK], SLF);
//    end;
  end;
end;

procedure TSLF.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i, j: Integer;
  s: String;
begin
  KilepClick(NIL);
  //
  // Az INI f�jl elemeinek friss�t�se (Csak akkor, ha nem �ppen azonosak!)
  //
  iniupd(PARAMS, TOPSZA, ositop);
  iniupd(PARAMS, LEFSZA, osleft);
  iniupd(PARAMS, TOPSZA, ositop);
  iniupd(PARAMS, LEFSZA, osleft);
  iniupd(PARAMS, SZINAL, SzinaranyLEDCheckBox.Checked);
  iniupd(PARAMS, ARALER, ledlfs[0].potmet.Tag);
  iniupd(PARAMS, ARALEG, ledlfs[1].potmet.Tag);
  iniupd(PARAMS, ARALEB, ledlfs[2].potmet.Tag);
  iniupd(PARAMS, SZINAN, SzinaranyNyilCheckBox.Checked);
  iniupd(PARAMS, ARANYR, lednfs[0].potmet.Tag);
  iniupd(PARAMS, ARANYG, lednfs[1].potmet.Tag);
  iniupd(PARAMS, ARANYB, lednfs[2].potmet.Tag);
  iniupd(PARAMS, HIDEPA, Application.HintHidePause);
  i := sajini.ReadInteger(HANGSS, HANGDA, 0);
  j := hangdb;
  if(j <> i) then
  begin
    sajini.EraseSection(HANGSS);
    iniupd(HANGSS, HANGDA, j);
  end;
  i := 0;
  while(i < j) do
  begin
    s := HANGHN + IntToStr(i);
    iniupd(HANGSS, s, hangtb[i].hangho);
    s := HANGSN + IntToStr(i);
    iniupd(HANGSS, s, hangtb[i].hangso);
    s := HANGEN + IntToStr(i);
    iniupd(HANGSS, s, hangtb[i].hanger);
    inc(i);
  end;
  sajini.Free;
end;
//
// Kil�p�skori alap�llapot be�ll�t�s
//
procedure TSLF.KilepClick(Sender: TObject);
begin
  EEPmuvelet.Visible := False;
  NumEditBox.Visible := False;
  EEPmuvelet.Visible := False;
  LEDLampaGroupBox.Visible := False;
  HangszoroGroupBox.Visible := False;
  LEDNyilGroupBox.Visible := False;
  SelDevGroup.Visible := False;
  Teendok.Enabled := drb485 > 0;
  SelDevGroup.Height := 104;
  SelDevGroup.Width := 361;
  DevListBox.Height := 17;
  DevListBox.Width := 315;
  posapp(116, minsel);
  Top := ositop;
  Left := osleft;
end;
//
// A megjene� form elem elhelyez�se a monitoron
//
procedure TSLF.posapp(magert, szeler: Integer);
var
  i: Integer;
  holcur: TPoint;
  function iabs(i: Integer): Integer; Assembler;
  asm
    or  eax,eax
    jns @maraze
    neg eax
  @maraze:
  end;
begin
  holcur.x := Left;
  holcur.y := Top;
  apppos(holcur);
  i := Left + ((Width - szeler) DIV 2);
  if(i > scrlef) then
  begin
    if((i + szeler) > scrwid) then
    begin
      i := scrwid - szeler;
    end
    else
    begin
      i := Left;
    end;
  end
  else
  begin
    i := scrlef;
  end;
  Left := i;
  i := Top + ((Height - magert) DIV 2);
  if(i > scrtop) then
  begin
    if((i + magert) > scrhei) then
    begin
      i := scrhei - magert;
    end
    else
    begin
      i := Top;
    end;
  end
  else
  begin
    i := scrtop;
  end;
  Top := i;
  if((Width <> szeler) OR (Height <> magert)) then
  begin
    Width := szeler;
    Height := magert;
  end;
end;
//
// A Form elem (TGroupBox) ind�t�skori kialak�t�sa �s elhelyez�se
//
procedure TSLF.indwin(melyab: TGroupBox; melygo: TWinControl; gepkod: Dword; const boxstr: String);
var
  holcur: TPoint;
  s: String;
begin
  melyab.Visible := True;
  if(gepkod > $ffff) then
  begin
    if(boxstr <> '') then
    begin
      melyab.Caption := boxstr;
    end;
  end
  else
  begin
    melyab.Tag := gepkod AND $c000;
    case(gepkod SHR 14) of
      1:
      begin
        s := 'LED l�mpa';
      end;
      2:
      begin
        s := 'LED ny�l';
      end;
      3:
      begin
        s := 'hangsz�r�';
      end;
    end;
    melyab.Caption := Format(boxstr,[gepkod AND $3fff, s]);
  end;
  Teendok.Enabled := False;
  posapp(melyab.Height + 52 + StatusBar.Height, melyab.Width + 22);
  holcur.x := Left;
  holcur.y := Top;
  appmor(holcur);
  if(melygo <> NIL) then
  begin
    melygo.SetFocus;
  end
  else
  begin
    melyab.SetFocus;
  end;
end;
//
// A DLL le�r� st�tusz sor hossza miatti form elemek �trendez�se
//
procedure TSLF.hosmod;
var
  i, j: Integer;
  locrec: SIZE;
  rect: TRect;
begin
  i := 0;
  j := MainMenu.Items.Count;
  //
  // A men�elemek miatti minimum hossz kisz�m�t�sa
  //
  minsel := GetSystemMetrics(SM_CXMENUSIZE) - 6;
  while(i < j) do
  begin
    if(GetMenuItemRect(Handle, MainMenu.Handle, i, rect)) then
    begin
      minsel := minsel + (rect.Right - rect.Left);
      inc(i);
    end;
  end;
  //
  // A st�tusz sor sz�ks�ges m�rete
  //
  GetTextExtentPoint32(StatusBar.Canvas.Handle,
                       PChar(statso),
                       Length(statso),
                       locrec);
  i := locrec.cx;
  if(i > minsel) then
  begin
    minsel := i;
  end;
  j := SelDevGroup.Width + 22;
  if(j < minsel) then
  begin
    i := minsel - j;
    SelDevGroup.Width := SelDevGroup.Width + i;
  end;
  j := NumEditBox.Width + 22;
  if(j < minsel) then
  begin
    i := minsel - j;
    NumEditBox.Width := NumEditBox.Width + i;
    NumEdit.Left := NumEdit.Left + (i DIV 2);
  end;
  j := EEPmuvelet.Width + 22;
  if(j < minsel) then
  begin
    i := minsel - j;
    EEPmuvelet.Width := EEPmuvelet.Width + i;
  end;
  j := LEDLampaGroupBox.Width + 22;
  if(j < minsel) then
  begin
    i := minsel - j;
    LEDLampaGroupBox.Width := LEDLampaGroupBox.Width + i;
    LEDLampaKilepButton.Left := LEDLampaKilepButton.Left + (i DIV 2);
  end;
  j := HangszoroGroupBox.Width + 22;
  if(j < minsel) then
  begin
    i := minsel - j;
    HangszoroGroupBox.Width := HangszoroGroupBox.Width + i;
    j := (i DIV 2);
    HangszoroKilepButton.Left := HangszoroKilepButton.Left + j;
    LejatszasButton.Left := LejatszasButton.Left + j; 
  end;
  j := LEDNyilGroupBox.Width + 22;
  if(j < minsel) then
  begin
    i := minsel - j;
    LEDNyilGroupBox.Width := LEDNyilGroupBox.Width + i;
    LEDNyilKilepButton.Left := LEDNyilKilepButton.Left + (i DIV 2);
  end;
//  posapp(116, minsel);
end;
//
// A LED l�mpa aktualiz�l�sa a panel �rt�keivel szinkronban
//
procedure TSLF.ledbea(const locsta: ELVSTA);
var
  i: Integer;
  kulcol: TColor;
  s: String;
begin
  if(lehall) then
  begin
    lehall := False;
    //
    // A sz�n �rt�k�nek �ssze�ll�t�sa
    //
    kulcol := locsta.rgbert.rossze + (locsta.rgbert.gossze SHL 8) + (locsta.rgbert.bossze SHL 16);
    //
    // A LED l�mpa potm�tereinek be�ll�t�sa
    //
    ledlfs[0].potmet.Position := locsta.rgbert.rossze;
    ledlfs[1].potmet.Position := locsta.rgbert.gossze;
    ledlfs[2].potmet.Position := locsta.rgbert.bossze;
    //
    // A LED l�mpa potm�tereinek fejl�c sz�veg be�ll�t�sa
    //
    i := 0;
    while(i < 3) do
    begin
      s := Format(LEDLSS,[szintb[i], ledlfs[i].potmet.Min, ledlfs[i].potmet.Max, ledlfs[i].potmet.Position]);
      if(ledlfs[i].potmel.Caption <> s) then
      begin
        ledlfs[i].potmel.Caption := s;
      end;
      inc(i);
    end;
    //
    // A LED l�mpa szimb�lum sz�nbe�ll�t�sa
    //
    i := 0;
    while(i < LEDLDB) do
    begin
      ledlaa[i].Brush.Color := kulcol;
      inc(i);
    end;
    //
    // A st�tusz sorba VDD �s proci h�m�rs�klet
    //
    homvdd(locsta.merlam, LEDLampaLabel);
    lehall := True;
    //
    // A Timer ind�t�sa (�j �llapot k�r�s egy id� ut�n)
    //
    Timer.Enabled := True;
  end;
end;
//
// A LED ny�l aktualiz�l�sa a panel �rt�keivel szinkronban
//
procedure TSLF.nyilbe(const locsta: ELVSTA);
var
  i: Integer;
  irabal: Boolean;
  kulcol: TColor;
  s: String;
begin
  if(lehall) then
  begin
    lehall := False;
    //
    // A LED ny�l ir�ny�nak meghat�roz�sa
    //
    irabal := locsta.nyilal = 0;
    //
    // A sz�n �rt�k�nek �ssze�ll�t�sa
    //
    kulcol := locsta.rgbert.rossze + (locsta.rgbert.gossze SHL 8) + (locsta.rgbert.bossze SHL 16);
    //
    // A LED ny�l potm�tereinek be�ll�t�sa
    //
    lednfs[0].potmet.Position := locsta.rgbert.rossze;
    lednfs[1].potmet.Position := locsta.rgbert.gossze;
    lednfs[2].potmet.Position := locsta.rgbert.bossze;
    //
    // A LED ny�l ir�ny�nak jelz�se
    //
    BalraRadioButton.Checked := irabal;
    JobbraRadioButton.Checked := NOT irabal;
    //
    // A LED ny�l potm�tereinek fejl�c sz�veg be�ll�t�sa
    //
    i := 0;
    while(i < 3) do
    begin
      s := Format(LEDLSS,[szintb[i], lednfs[i].potmet.Min, lednfs[i].potmet.Max, lednfs[i].potmet.Position]);
      if(lednfs[i].potmel.Caption <> s) then
      begin
        lednfs[i].potmel.Caption := s;
      end;
      inc(i);
    end;
    //
    // A LED ny�l szimb�lum sz�nbe�ll�t�sa
    //
    i := 0;
    while(i < LEDNDB) do
    begin
      case(i) of
        //
        // Balra mutat� ir�nyban szerepl� LED szmb�lumok be-, vagy kikapcsol�sa
        //
        0, 1, 17, 18, 20:
        begin
          if(irabal) then
          begin
            lednaa[i].Brush.Color := kulcol;
          end
          else
          begin
            lednaa[i].Brush.Color := 0;
          end;
        end;
        //
        // Jobbra mutat� ir�nyban szerepl� LED szmb�lumok be-, vagy kikapcsol�sa
        //
        9, 10, 12, 13, 14:
        begin
          if(irabal) then
          begin
            lednaa[i].Brush.Color := 0;
          end
          else
          begin
            lednaa[i].Brush.Color := kulcol;
          end;
        end;
        else
        //
        // Mindk�t ir�nyban szerepl� LED szmb�lumok bekapcsol�sa
        //
        begin
          lednaa[i].Brush.Color := kulcol;
        end;
      end;
      inc(i);
    end;
    //
    // A st�tusz sorba VDD �s proci h�m�rs�klet
    //
    homvdd(locsta.merlam, LEDNyilLabel);
    lehall := True;
    //
    // A Timer ind�t�sa (�j �llapot k�r�s egy id� ut�n)
    //
    Timer.Enabled := True;
  end;
end;
//
// A hang string �ssze�ll�t�sa �s elind�t�sa
//
procedure TSLF.hanbea(const locsta: ELVSTA);
begin
  if(lehlis) then
  begin
    lehlis := False;
    //
    // A st�tusz sorba VDD �s proci h�m�rs�klet
    //
    homvdd(locsta.merlam, HangszoroLabel);
    lehlis := True;
    //
    // A lej�tsz�s �llapot�nak k�vet�se
    //
    if(locsta.hanakt = 0) then
    begin
      LejatszasButton.Enabled := True;
    end;
    //
    // A Timer ind�t�sa (�j �llapot k�r�s egy id� ut�n)
    //
    Timer.Enabled := True;
  end;
end;
//
// T�bb lehets�ges eszk�z eset�n szelekci�s ablak k�sz�t�s
//
procedure TSLF.seldev;
var
  i, j, k: Integer;
begin
  NumEditBox.Visible := False;
  Teendok.Enabled := False;
  EEPmuvelet.Visible := False;
  DevListBox.Height := 17;
  SelDevGroup.Height := 104;
  DevListBox.Items.Clear;
  DevListBox.ExtendedSelect := False;
  DevListBox.Items.Clear;
  //
  // Listak�sz�t�s a lehets�ges elemekr�l
  //
  j := drb485;
  i := 0;
  SetLength(listoi, 0);
  while(i < j) do
  begin
    if((Integer((dev485[i].azonos AND $c000)) = mitind.Tag) OR (mitind.Tag = 0)) then
    begin
      k := Length(listoi);
      SetLength(listoi, k + 1);
      listoi[k] := i;
      DevListBox.Items.Add(verstr(dev485[i]));
    end;
    inc(i);
  end;
  //
  // A lista ellen�rz�se, hogy van-e t�bb kiv�lasztand� elem
  //
  if(Length(listoi) = 1) then
  begin
    //
    // Csak egy panel van ilyen, egyb�l ind�tom a feladatot
    //
    akt485 := listoi[0];
    aktadr := dev485[akt485].azonos;
    indfel;
  end
  else
  begin
    //
    // Van t�bb lehets�ges panel, elind�tom a szelekci�s elemet
    //
    listom(SelDevGroup, DevListBox, NIL, True);         // M�retre igaz�t�s
    DevListBox.ItemIndex := 0;                          // Kezd� index
    indwin(SelDevGroup, DevlistBox, $ffffffff, SELUSB); // V�laszt�s ind�t�s
  end;
end;
//
// A feladat kiv�laszt�sa
//
procedure TSLF.indfel;
var
  i, j: Dword;
begin
  //
  // Az azonos�t�t m�dos�t� feladatr�sz ind�t�sa
  // (Ez minden panelt�pusn�l azonos, de kezelni kell
  // a t�pusjelz� bitp�rosokat)
  //
  if(mitind = AzonositoBeallitasa) then
  begin
    NumEdit.Text := '';
    NumEdit.Tag := dev485[akt485].azonos AND $c000;
    NumEdit.Text := IntToStr(dev485[akt485].azonos AND $3fff);
    NumEdit.SelStart := 0;
    NumEdit.SelLength := 0;
    indwin(NumEditBox, AzonositoKilep, dev485[akt485].azonos, NUMEST);
  end
  else
  begin
    //
    // K�dfriss�t�s (f�rmvercsere) ind�t�sa
    // (Ez minden panelt�pusn�l azonos, de kezelni kell
    // a t�pusjelz� bitp�rosokat)
    //
    if(mitind = Programfrissites) then
    begin
        //
        // A k�dfriss�t�sn�l meghat�rozom a friss�t� f�jl aj�nlott nev�t
        // �s a f�jlv�laszt� ablak fejl�c�nek sz�veg�t
        //
        case(dev485[akt485].azonos SHR 14) of
        1:
        begin
          FirmwareUpdateDialog.FileName := SLLNAM;
          FirmwareUpdateDialog.Title := SLLTIT;
        end;
        2:
        begin
          FirmwareUpdateDialog.FileName := SLNNAM;
          FirmwareUpdateDialog.Title := SLNTIT;
        end;
        3:
        begin
          FirmwareUpdateDialog.FileName := SLHNAM;
          FirmwareUpdateDialog.Title := SLHTIT;
        end;
      end;
      //
      // Elind�tom a f�jlv�laszt�t
      //
      if(FirmwareUpdateDialog.Execute) then
      begin
        //
        // A f�jlkiv�laszt�s megt�rt�nt, ind�tom a friss�t�st.
        //
        j := SLLDLL_Upgrade(PChar(FirmwareUpdateDialog.FileName), i, dev485[akt485].azonos);
        case(j) of
          NO_ERROR:
          begin
            //
            // A friss�t�s sikeresen elindult, megjelen�tem a friss�t�s menet�t mutat�
            // folyamatjelz�t, �s kalibr�lom az �temet jelz� elemet
            //
            Gauge.MaxValue := i;
            Gauge.MinValue := 0;
            Gauge.Progress := 0;
            indwin(EEPmuvelet, NIL, dev485[akt485].azonos, KODSTR);
          end;
          //
          // Nem siker�lt a friss�t�st elind�tani, meg�zenem annak ok�t
          //
          ERROR_OPEN_FAILED:
          begin
            sajuze(PChar(Format(OPFISO,[FirmwareUpdateDialog.FileName, i, gethks(i)])), mtError, [mbOK], SLF);
          end;
          ERROR_MOD_NOT_FOUND:
          begin
            sajuze(DEVNHI, mtError, [mbOK], SLF);
          end;
          else
          begin
            sajuze(PChar(Format(NEMSIF, [j, gethks(j)])), mtError, [mbOK], SLF);
          end;
        end;
      end;
    end
    else
    begin
      //
      // LED l�mpa kezel�s ind�t�s
      //
      if(mitind = LEDLampaKijelzo) then
      begin
        indwin(LEDLampaGroupBox, LEDLampaKilepButton, dev485[akt485].azonos, LEDLSU);
        lehall := True;
        //
        // St�tusz k�r�ssel beolvasom (�s majd kiteszem) az aktu�lis �llapotot
        //
        SLDLL_GetStatus(dev485[akt485].azonos);
      end
      else
      begin
        //
        // LED ny�l kezel�s ind�t�s
        //
        if(mitind = LEDNyilKijelzo) then
        begin
          indwin(LEDNyilGroupBox, LEDNyilKilepButton, dev485[akt485].azonos, LEDNSU);
          lehall := True;
          //
          // St�tusz k�r�ssel beolvasom (�s majd kiteszem) az aktu�lis �llapotot
          //
          SLDLL_GetStatus(dev485[akt485].azonos);
        end
        else
        begin
          //
          // Hang string kialak�t�s �s hangind�t�s kezel�s ind�t�s
          //
          if(mitind = HangszoroPanelKezeles) then
          begin
            //
            // Kiteszem az utols�nak szerkesztett hanglist�t
            //
            HangListBox.Items.Clear;
            i := 0;
            j := Length(hangtb);
            while(i < j) do
            begin
              recfri(i);
              inc(i);
            end;
            if(j > 0) then
            begin
              HangListBox.ItemIndex := 0;
              reckit(0);
            end;
            lehlis := True;
            indwin(HangszoroGroupBox, HangszoroKilepButton, dev485[akt485].azonos, HANGSU);
            //
            // St�tusz k�r�ssel beolvasom (�s majd kiteszem) az aktu�lis �llapotot
            //
            SLDLL_GetStatus(dev485[akt485].azonos);
          end
          else
          begin
          end;
        end;
      end;
    end;
  end;
end;
//
// A ListBox m�ret�hez igaz�tom az azt befoglal� k�rnyezetet
//
procedure TSLF.listom(var tarbox: TGroupBox; var lisbox: TListBox; kozgom: TButton; widthb: Boolean);
var
  i, j, k, l, m, n: Integer;
  locrec: SIZE;
  holcur: TPoint;
begin
  i := 0;
  j := lisbox.Items.Count;
  l := 0;
  while(i < j) do
  begin
    if(lisbox.Items[i] = '') then
    begin
      GetTextExtentPoint32(lisbox.Canvas.Handle, ' ', 1, locrec);
    end
    else
    begin
      GetTextExtentPoint32(lisbox.Canvas.Handle,
                           PChar(lisbox.Items[i]),
                           Length(lisbox.Items[i]),
                           locrec);
    end;
    k := locrec.cx;
    if(k > l) then
    begin
      l := k;
    end;
    inc(i);
  end;
  holcur.x := Left;
  holcur.y := Top;
  apppos(holcur);
  m := tarbox.Height - lisbox.Height;
  n := tarbox.Width - lisbox.Width;
  i := (j * (locrec.cy + 1)) + 4;
  l := l + 8;
  k := (scrhei - Statusbar.Height - m - (Height - ClientHeight));
  if(i > k) then
  begin
    i := (((k - 4) DIV locrec.cy) * locrec.cy) + 4;
    l := l + GetSystemMetrics(SM_CXVSCROLL);
  end;
  tarbox.Height := i + m;
  lisbox.Height := i;
  k := (scrwid - n - (Width - ClientWidth) - 16);
  if(l > k) then
  begin
    l := k;
  end;
  i := tarbox.Width;
  if(i < minsel) then
  begin
    i := minsel;
  end;
  if(l < (i - n)) then
  begin
    l := (i - n);
  end;
  if(widthb) then
  begin
    tarbox.Width := l + n;
    lisbox.Width := l;
    if(kozgom <> NIL) then
    begin
      kozgom.Left := (tarbox.Width DIV 2) - (kozgom.Width DIV 2);
    end;
  end;
  posapp(tarbox.Height + 52 + StatusBar.Height, tarbox.Width + 22);
end;
//
// A Form ind�t�sa
//
procedure TSLF.FormActivate(Sender: TObject);
var
  i: Integer;
  holcur: TPoint;
  nevlei: PDLLNEV;
begin
  //
  // A kezel� DLL elind�t�sa. �tadom a saj�t Window Handle �rt�k�t
  // �s a kommunik�ci�s �zenet sz�m�t. Ez nem lehet kisebb mint WM_USER.
  // Sikeres ind�t�s eset�n visszakapom a kt DLL verzi�j�t, �s
  // pontos specifik�ci�j�t, valamint a csatlakoz� panel le�r�s�t. Egyben
  // elindul az RS485-�s buszon tal�lhat� elemek meghat�roz�sa is. A keres�s
  // v�g�t "FELMOK" �zenet jelzi. (L�sd ott.)
  //
  i := SLDLL_Open(Handle, UZESAJ, @nevlei, @devusb);
  if(i <> NO_ERROR) then
  begin
    //
    //
    //
    posapp(116, 94);
    //
    // Az elind�t�s nem siker�lt, a hiba ok�t neg�zenem
    //
    sajuze(PChar(Format(DLLIHI,[i, gethks(i)])), mtError, [mbOK], SLF);
    Close;
  end
  else
  begin
    //
    // Sikeres elindulta DLL, a fejl�cben ki�rom  kapcsolattart� elem jellemz�it
    //
    Caption := capstr + ' ' + verstr(devusb^);
    //
    // A st�tuszsorba kiteszem a k�t DLL jellemz�it
    //
    statso := Format(VERKIF,[nevlei^[0].mianev, nevlei^[0].versih, nevlei^[0].versil]) + ' �s ' +
              Format(VERKIF,[nevlei^[1].mianev, nevlei^[1].versih, nevlei^[1].versil]);
    StatusBar.Panels[0].Text := statso;
    StatusBar.Hint := statso;
    //
    // A sz�ks�ges m�retre igaz�tom a Formot �s a GroupBox-okat
    //
    hosmod;
    //
    // Alaphelyzetet �ll�tok
    //
    posapp(116, minsel);
    holcur.y := ositop;
    holcur.x := osleft;
    appmor(holcur);
    HangeroTrackBarChange(NIL);
  end;
end;
//
// "Id�nk�nt" st�stusz k�r�st ind�tok, ha olyan GroupBox az akt�v, amelyik
// a v�laszt feldolgozza. A Timer �jraind�t�s�r�l a st�tusz �zenetet (STATKV)
// feldolgoz� programr�sz gondoskodik,
//
procedure TSLF.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  if(LEDLampaGroupBox.Visible OR LEDNyilGroupBox.Visible OR HangszoroGroupBox.Visible) then
  begin
    SLDLL_GetStatus(aktadr);
  end;
end;
//
// A men�elemre kattintottak
//
procedure TSLF.MenuinditClick(Sender: TObject);
begin
  mitind := TMenuItem(Sender);
  seldev;
end;
//
// Az azonos�t� v�lt�s le�t�seit kezel� programr�sz. (Csak sz�mokat enged meg.)
//
procedure TSLF.NumEditKeyPress(Sender: TObject; var Key: Char);
begin
  case(Key) of
    ' '..'/',
    ':'..'�':
    begin
      Key := #0;
    end;
    Char(VK_RETURN):
    begin
      AzonositoBeallitClick(NIL);
      Key := #0;
    end;
  end;
end;
//
// Az azonos�t� szerkeszt�s �rt�k�nek k�vet�se
//
procedure TSLF.NumEditChange(Sender: TObject);
var
  i, j: Integer;
  erekod: Word;
begin
  if(NumEdit.Text <> '') then
  begin
    i := 0;
    j := drb485;
    erekod := StrToInt(NumEdit.Text);
    if((erekod <> 0) AND (erekod < $3fff)) then
    begin
      erekod := erekod OR NumEdit.Tag;
      while((i < j) AND (dev485[i].azonos <> erekod)) do
      begin
        inc(i);
      end;
    end;
    AzonositoBeallit.Enabled := i = j;
  end
  else
  begin
    AzonositoBeallit.Enabled := False;
  end;
end;
//
// Az azonos�t� m�dos�t�s�t kezdem�nyezt�k
//
procedure TSLF.AzonositoBeallitClick(Sender: TObject);
var
  i: Integer;
  gepkou: Word;
begin
  if(NumEdit.Text <> '') then
  begin
    //
    // Ellen�rz�m, hogy a szab�lyoknak megfelel-e
    //
    gepkou := StrToInt(NumEdit.Text);
    if((gepkou > 16382) OR (gepkou = 0))then
    begin
      //
      // Hiba�zenet, mert nem szab�lyos az �rt�ke
      //
      sajuze(GEPKIA, mtError, [mbOK], SLF);
    end
    else
    begin
      //
      // Elind�tom az azonos�t� megv�ltoztat�s�t
      //
      i := SLDLL_AzonositoCsereInditas(dev485[akt485].azonos, gepkou OR NumEdit.Tag);
      if(i <> NO_ERROR) then
      begin
        //
        // Enm siker�lt az ind�t�s, a hib�r�l �zenek
        //
        sajuze(PChar(Format(AZOVNS,[i, gethks(i)])), mtError, [mbOK], SLF);
      end;
    end;
  end;
end;
//
// A Listbox elem�nek Hint-ben megjelen�t�se
//
procedure TSLF.DevListBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i: Integer;
  alopos: TPoint;
  s: String;
  // A hint sz�veg kialak�t�sa
  function hintki(kerstr: PChar; const lcanva: TCanvas; var tenyho: Integer): String;
  var
    i, j, k, l: Integer;
  begin
    Result := kerstr;
    tenyho := lcanva.TextWidth(Result);
    if(tenyho > scrwid) then
    begin
      l := (tenyho DIV scrwid) + 1;
      k := Length(Result);
      i := k DIV l;
      if((k MOD l) <> 0) then
      begin
        inc(i);
      end;
      SetLength(Result, k + (2 * (l - 1)));
      l := 1;
      j := 0;
      while(l < Length(Result)) do
      begin
        if(k < i) then
        begin
          i := k;
        end;
        StrLCopy(@Result[l], @kerstr[j], i);
        l := l + i;
        j := j + i;
        k := k - i;
        if(l < Length(Result)) then
        begin
          Result[l] := #13;
          inc(l);
          Result[l] := #10;
          inc(l);
        end;
      end;
    end;
  end;
begin
  if(DevListBox.Tag = 2) then
  begin
    alopos.x := X;
    alopos.y := Y;
    i := TListBox(Sender).ItemAtPos(alopos, True);
    if(i > -1) then
    begin
      if(TListBox(Sender).Tag <> i) then
      begin
        TListBox(Sender).Hint := '';
        Application.CancelHint;
      end;
      TListBox(Sender).Tag := i;
      s := hintki(PChar(s), TListBox(Sender).Canvas, i);
      TListBox(Sender).Hint := s;
    end;
  end;
end;
//
// Kiv�laszt�s Enter-rel
//
procedure TSLF.DevListBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if(Key = VK_RETURN) then
  begin
    KivalasztButtonClick(Sender);
  end;
end;
//
// A panelek list�b�l kiv�laszt�sa t�rt�nt
//
procedure TSLF.KivalasztButtonClick(Sender: TObject);
begin
  akt485 := listoi[DevListBox.ItemIndex];
  aktadr := dev485[akt485].azonos;
  indfel;
  SelDevGroup.Visible := False;
end;
//
// Kil�p�s men�leme, aktiviz�lja a programb�l a kil�p�st
//
procedure TSLF.ExitMenuElemClick(Sender: TObject);
begin
  Close;
end;
//
// A sz�nar�nyok meg�rz�s�nek sz�m�t�si menete
//
procedure aranyta(Sender: TObject; var mitala: LEDLFA; aranyt: Boolean);
var
  i, j: Integer;
  arany: Extended;
  ujerte: array [0..2] of Integer;
  s: String;
begin
    i := 0;
    while((i < 3) AND (mitala[i].potmet <> TTrackBar(Sender))) do
    begin
      inc(i);
    end;
    if(i < 3) then
    begin
      if(aranyt) then
      begin
        j := 0;
        while((j < 3) AND (mitala[i].potmet.Tag = 0)) do
        begin
          inc(j);
        end;
        if(j = 3) then
        begin
          j := mitala[i].potmet.Position;
          i := 0;
          while(i < 3) do
          begin
            mitala[i].potmet.Position := j;
            inc(i);
          end;
        end
        else
        begin
          if(mitala[i].potmet.Tag = 0) then
          begin
            mitala[i].potmet.Position := 0;
          end
          else
          begin
            arany := mitala[i].potmet.Position / mitala[i].potmet.Tag;
            j := 0;
            while(j < 3) do
            begin
              if(j = i) then
              begin
                ujerte[j] := mitala[j].potmet.Position;
              end
              else
              begin
                ujerte[j] := Round(mitala[j].potmet.Tag * arany);
              end;
              inc(j);
            end;
            i := 0;
            j := 0;
            while(i < 3) do
            begin
              if(j < ujerte[i]) then
              begin
                j := ujerte[i];
              end;
              inc(i);
            end;
            if(j > 255) then
            begin
              arany := 255 / j;
              i := 0;
              while(i < 3) do
              begin
                ujerte[i] := Round(ujerte[i] * arany);
                inc(i);
              end;
            end;
            i := 0;
            while(i < 3) do
            begin
              mitala[i].potmet.Position := ujerte[i];
              s := Format(LEDLSS,[szintb[i], mitala[i].potmet.Min, mitala[i].potmet.Max, mitala[i].potmet.Position]);
              if(mitala[i].potmel.Caption <> s) then
              begin
                mitala[i].potmel.Caption := s;
              end;
              inc(i);
            end;
          end;
        end;
      end
      else
      begin
        s := Format(LEDLSS,[szintb[i], mitala[i].potmet.Min, mitala[i].potmet.Max, mitala[i].potmet.Position]);
        if(mitala[i].potmel.Caption <> s) then
        begin
          mitala[i].potmel.Caption := s;
        end;
      end;
    end;
end;
//
// LED l�mpa sz�nbe�ll�t�s aktiviz�l�s
//
procedure TSLF.LEDLampaTrackBarChange(Sender: TObject);
var
  i: Integer;
  rgbert: HABASZ;
begin
  if(lehall) then
  begin
    lehall := False;
    Timer.Enabled := False;
    aranyta(Sender, ledlfs, SzinaranyLEDCheckBox.Checked);
    rgbert.rossze := ledlfs[0].potmet.Position;
    rgbert.gossze := ledlfs[1].potmet.Position;
    rgbert.bossze := ledlfs[2].potmet.Position;
    i := SLLDLL_LEDLampa(rgbert, aktadr);
    if(i <> NO_ERROR) then
    begin
      sajuze(PChar(Format(LEDLIS,[i, gethks(i)])), mtError, [mbOK], SLF);
    end;
  end;
end;
//
// LED ny�l sz�nbe�ll�t�s �s ir�nyv�lt�s aktiviz�l�s
//
procedure TSLF.LEDNyilTrackBarChange(Sender: TObject);
var
  jobrai: BOOL;
  i: Integer;
  rgbert: HABASZ;
begin
  if(lehall) then
  begin
    lehall := False;
    Timer.Enabled := False;
    aranyta(Sender, lednfs, SzinaranyNyilCheckBox.Checked);
    jobrai := JobbraRadioButton.Checked;
    rgbert.rossze := lednfs[0].potmet.Position;
    rgbert.gossze := lednfs[1].potmet.Position;
    rgbert.bossze := lednfs[2].potmet.Position;
    i := SLLDLL_LEDNyil(rgbert, jobrai, aktadr);
    if(i <> NO_ERROR) then
    begin
      sajuze(PChar(Format(LEDNIS,[i, gethks(i)])), mtError, [mbOK], SLF);
    end;
  end;
end;
//
// LED l�mpa sz�nar�ny be�ll�t�sn�l ar�nyok ment�se
//
procedure TSLF.SzinaranyLEDCheckBoxClick(Sender: TObject);
var
  i: Integer;
begin
  if(SzinaranyLEDCheckBox.Checked) then
  begin
    i := 0;
    while(i < 3) do
    begin
      ledlfs[i].potmet.Tag := ledlfs[i].potmet.Position;
      inc(i);
    end;
  end;
end;
//
// LED ny�l sz�nar�ny be�ll�t�sn�l ar�nyok ment�se
//
procedure TSLF.SzinaranyNyilCheckBoxClick(Sender: TObject);
var
  i: Integer;
begin
  if(SzinaranyNyilCheckBox.Checked) then
  begin
    i := 0;
    while(i < 3) do
    begin
      lednfs[i].potmet.Tag := lednfs[i].potmet.Position;
      inc(i);
    end;
  end;
end;
//
// Hanger� potm�ter v�ltoztat�s kezel�se
//
procedure TSLF.HangeroTrackBarChange(Sender: TObject);
var
  s: String;
begin
  if(lehlis) then
  begin
    s := Format(HANGES,[HangeroTrackBar.Min, HangeroTrackBar.Max, HangeroTrackBar.Position]);
    if(HangeroLabel.Caption <> s) then
    begin
      HangeroLabel.Caption := s;
    end;
    frisha;
  end;
end;
//
// �j hang l�trehoz�sa a hangt�bl�zatba
//
procedure TSLF.UjhangClick(Sender: TObject);
begin
  aktind := Length(hangtb);
  hangdb := aktind + 1;
  HangListBox.Items.Add('');
  HangListBox.Itemindex := aktind;
  frisha;
end;
//
// A hanglista elem�nek sz�vegfriss�t�se
//
procedure TSLF.recfri(melyfr: Integer);
begin
  if(HangListBox.Items.Count <= melyfr) then
  begin
    HangListBox.Items.Add('');
  end;
  if(hangtb[melyfr].hangso < 49) then
  begin
    HangListBox.Items[melyfr] := Format(HANGST, [HangmagassagComboBox.Items[hangtb[melyfr].hangso], hangtb[melyfr].hangho, hangtb[melyfr].hanger]);
  end
  else
  begin
    HangListBox.Items[melyfr] := Format(SZUNET, [HangmagassagComboBox.Items[hangtb[melyfr].hangso], hangtb[melyfr].hangho]);
  end;
end;
//
// A hangt�bl�zat elem�nek be�ll�t�sa az aktu�lis �rt�kre
//
procedure TSLF.frisha;
var
  vanher: Boolean;
begin
  if(hangdb > 0) then
  begin
    hangtb[aktind].hangso := HangmagassagComboBox.Itemindex;
    hangtb[aktind].hangho := StrToInt(HanghosszComboBox.Text);
    hangtb[aktind].hanger := HangeroTrackBar.Position;
    recfri(aktind);
  end;
  vanher := HangmagassagComboBox.Itemindex < 49;
  HangeroLabel.Visible := vanher;
  HangeroTrackBar.Visible := vanher;
end;
//
// A hangmagass�g v�ltoztat�s kezel�se
//
procedure TSLF.HangmagassagComboBoxChange(Sender: TObject);
begin
  if(lehlis) then
  begin
    frisha;
  end;
end;
//
// A hanglista egy elem�nek t�rl�se
//
procedure TSLF.TorlesClick(Sender: TObject);
var
  i, j: Integer;
begin
  j := hangdb - 1;
  i := HangListBox.ItemIndex;
  lehlis := False;
  while(i < j) do
  begin
    hangtb[i] := hangtb[i + 1];
    HangListBox.Items[i] := HangListBox.Items[i + 1];
    inc(i);
  end;
  reckit(i);
  lehlis := True;
  hangdb := j;
  HangListBox.Items.Delete(j);
end;
//
// A hanglista felbukkan� men� elemeinek kialak�t�sa
//
procedure TSLF.HangPopupMenuPopup(Sender: TObject);
var
  i, j: Integer;
begin
  i := HangListBox.Itemindex;
  j := HangListBox.Items.Count;
  HangListBox.PopupMenu.Items[3].Visible := j < 16;
  HangListBox.PopupMenu.Items[0].Visible := (j > 0) AND (i > -1);
  if(i < 1) then
  begin
    HangListBox.PopupMenu.Items[1].Visible := False;
  end
  else
  begin
    HangListBox.PopupMenu.Items[1].Visible := j > 1;
  end;
  if(j < 2) then
  begin
    HangListBox.PopupMenu.Items[2].Visible := False;
  end
  else
  begin
    HangListBox.PopupMenu.Items[2].Visible := (j - 1) > i;
  end;
end;
//
// Az aktu�lis hang szerinti be�ll�t�sok �tad�sa
//
procedure TSLF.reckit(hovate: Integer);
begin
  HangmagassagComboBox.Itemindex := hangtb[hovate].hangso;
  HanghosszComboBox.Text := IntToStr(hangtb[hovate].hangho);
  HangeroTrackBar.Position := hangtb[hovate].hanger;
end;
//
// A hang kiv�laszt�s kezel�se
//
procedure TSLF.HangListBoxClick(Sender: TObject);
begin
  aktind := HangListBox.Itemindex;
  lehlis := False;
  reckit(aktind);
  lehlis := True;
  frisha;
end;
//
// A kiv�lasztott hang f�lfele tol�sa
//
procedure TSLF.FolfeleClick(Sender: TObject);
var
  i, j: Integer;
  s: String;
  c: HANGLE;
begin
  i := HangListBox.Itemindex;
  if(i > 0) then
  begin
    j := i - 1;
    s := HangListBox.Items[i];
    HangListBox.Items[i] := HangListBox.Items[j];
    HangListBox.Items[j] := s;
    c := hangtb[i];
    hangtb[i] := hangtb[j];
    hangtb[j] := c;
    HangListBox.Itemindex := j;
    lehlis := False;
    reckit(j);
    lehlis := True;
  end;
end;
//
// A kiv�lasztott hang lefele tol�sa
//
procedure TSLF.LefeleClick(Sender: TObject);
var
  i, j: Integer;
  s: String;
  c: HANGLE;
begin
  i := HangListBox.Itemindex;
  j := i + 1;
  if(j < HangListBox.Items.Count) then
  begin
    s := HangListBox.Items[i];
    HangListBox.Items[i] := HangListBox.Items[j];
    HangListBox.Items[j] := s;
    c := hangtb[i];
    hangtb[i] := hangtb[j];
    hangtb[j] := c;
    HangListBox.Itemindex := j;
    lehlis := False;
    reckit(j);
    lehlis := True;
  end;
end;
//
// Az aktu�lis hanglista ind�t�sa
//
procedure TSLF.LejatszasButtonClick(Sender: TObject);
var
  i: Integer;
begin
  Timer.Enabled := False;
  i := SLLDLL_Hangkuldes(hangdb, hangtb, aktadr);
  if(i <> NO_ERROR) then
  begin
    sajuze(PChar(Format(HANGIS,[i, gethks(i)])), mtError, [mbOK], SLF);
  end
  else
  begin
    LejatszasButton.Enabled := False;
  end;
end;
//
// A buszon tal�lhat� eszk�z�k �jrafelm�r�se
//
procedure TSLF.UjrafelmeresClick(Sender: TObject);
begin
  Teendok.Enabled := False;
  Ujrafelmeres.Enabled := False;
  AzonositoBeallitasa.Enabled := False;
  LEDLampaKijelzo.Enabled := False;
  LEDNyilKijelzo.Enabled := False;
  HangszoroPanelKezeles.Enabled := False;
  Programfrissites.Enabled := False;
  SLDLL_Felmeres;
end;

procedure TSLF.Button1Click(Sender: TObject);
begin
  tblveg[0].azonos := dev485[0].azonos;
  tblveg[1].azonos := dev485[1].azonos;
  tblveg[0].lamrgb.rossze := 0;
//  tblveg[1].lamrgb.rossze := 0;
  tblveg[0].lamrgb.gossze := 0;
  tblveg[1].lamrgb.gossze := 0;
  tblveg[0].lamrgb.bossze := 0;
  tblveg[1].lamrgb.bossze := 0;
  SLDLL_SetLista(2, tblveg);
end;

initialization

finalization

(*
C''''   4186.0090 Hz
H'''    3951.0664 HZ
B'''    3729.3101 HZ
A'''    3520.0000 HZ
GISZ''' 3322.4376 HZ
G'''    3135.9635 HZ
FISZ''' 2959.9554 HZ
F'''    2793.8259 HZ
E'''    2637.0205 HZ
DISZ''' 2489.0159 HZ
D'''    2349.3181 HZ
CISZ''' 2217.4610 HZ
C'''    2093.0045 Hz
H''     1975.5332 Hz
B''     1864.6550 Hz
A''     1760.0000 Hz
GISZ''  1661.2188 Hz
G''     1567.9817 Hz
FISZ''  1479.9777 Hz
F''     1396.9129 Hz
E''     1318.5102 Hz
DISZ''  1244.5079 Hz
D''     1174.6591 Hz
CISZ''  1108.7305 Hz
C''  	  1046.5023 Hz
H'       987.7666 Hz
B'       932.3275 Hz
A'       880.0000 Hz
GISZ'    830.6094 Hz
G'       783.9909 Hz
FISZ'    739.9888 Hz
F'       698.4565 Hz
E'       659.2551 Hz
DISZ'    622.2540 Hz
D' 	     587.3295 Hz
CISZ' 	 554.3653 Hz
C'       523.2511 Hz
H     	 493.8833 Hz
B        466.1638 Hz
A        440.0000 Hz
GISZ     415.3047 Hz
G 	     391.9954 Hz
FISZ     369.9944 Hz
F        349.2282 Hz
E        329.6276 Hz
DISZ     311.1270 Hz
D        293.6648 Hz
CISZ     277.1826 Hz
C        261.6256 Hz

*)

end.
