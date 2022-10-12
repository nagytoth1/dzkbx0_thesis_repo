unit SLO;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, StdCtrls, ExtCtrls, Inifiles, Multimon, Gauges, Winsock,
  SLDLL;
const
//
// Az üzenetszám amin keresztül az SLDLL.DLL kommunikál
//
  UZESAJ                  = WM_USER + 0;                    // Saját USB vett üzenet (USB vett csomag érkezett)
//
// A form LED imitációinak száma
//
  LEDLDB                  = 19;                             // Ennyi LED van a lámpa panelon
  LEDNDB                  = 26;                             // Ennyi LED van a nyíl panelon
//
// Az üzenet fejlécének szöegkonstansai
//
  DLGERR                  = 'Hibajelzés';                   // Üzenet fejléc hiba esetén
  DLGINF                  = 'Információ';                   // Üzenet fejléc normál esetben
  DLGVAL                  = 'Választás';                    // Üzenet fejléc normál esetben
//
// Az INI fájl szövegkonstansai
//
  INIKIT                  = '.INI';
  PARAMS                  = 'Param';
  TOPSZA                  = 'Top';
  LEFSZA                  = 'Left';
  SZINAL                  = 'Lámpaszínarány';
  SZINAN                  = 'Nyílszínarány';
  ARALER                  = 'LEDR';
  ARALEG                  = 'LEDG';
  ARALEB                  = 'LEDB';
  ARANYR                  = 'NyilR';
  ARANYG                  = 'NyilG';
  ARANYB                  = 'NyilB';
//
// A hint megjeneési ideje szövegkonstans
//
  HIDEPA                  = 'HintHidePause';                 // Hint megjelenési idõ
//
// A hangleíró INI rész szövegkonstansai
//
  HANGSS                  = 'Hang';
  HANGDA                  = 'Darabszám';
  HANGHN                  = 'Hanghossz';
  HANGSN                  = 'Hangsorszám';
  HANGEN                  = 'Hangerõ';
//
// Dátumformátum a verzióhoz
//
  DATFOR                  = 'yyyy.MM.dd';
//
// Verziólekéréshez
//
  DEFSTR                  = '\';

  SLRUNM                  = 'Somodi László kijelzõ és hangszóró kezelõ program';
  VERKIF                  = '%s Verzió: %d.%d';
  MARFUT                  = 'Ez a program már fut egy példányban!';
  FEJLET                  = '%s %5.5X %d.%2.2d %4.4d/%2.2d/%2.2d %s';
  MODBEF                  = 'A módosítás és az újraindítás sikeresen megtörtént.';
  VDDHOM                  = 'A VDD értéke: %d.%2.2dV a proci hõmérséklete: %2d.%d°C';
  SELUSB                  = 'Eszköz választás ';
  NUMEST                  = 'Az azonosító beállítása a(z) %4.4X számú %s eszközön ';
  KODSTR                  = 'Kódfrissítés a(z) %4.4X számú %s eszközön ';
  OPFISO                  = 'Nem sikerült megnyitni a %s fájlt. Hibakód: %d %s';
  LEDLIS                  = 'LED lámap színbeállítási hiba. Hibakód: %d %s';
  LEDNIS                  = 'LED nyíl színbeállítási hiba. Hibakód: %d %s';
  HANGIS                  = 'Hangstring indítási hiba. Hibakód: %d %s';
  AZOVNS                  = 'Nem sikerült elindítani. Hibakód: %d %s';
  NEMSIF                  = 'Frissítésindítási hiba. Hibakód: %d. %s';
  DEVNHI                  = 'Eszköz kiválasztás hiba.';
  KODSET                  = 'Kódfrissítés a(z) %s:%d egységen';
  LEDLSU                  = 'A LED lámpa kijelzés beállítása a(z) %4.4X számú %s eszközön ';
  LEDNSU                  = 'A nyíl kijelzés beállítása a(z) %4.4X számú %s eszközön ';
  LEDLSS                  = 'A(z) %s színösszetevõ értéke. (Minimum: %d, maximum %d, most: %d)';
  GEPKIA                  = 'Az érték maximum 16382 lehet, és nem lehet 0!';
  HANGSU                  = 'Hangkialakítás a(z) %4.4X számú %s eszközön ';
  SLLNAM                  = 'SLLHEX.BIN';
  SLNNAM                  = 'SLNHEX.BIN';
  SLHNAM                  = 'SLHHEX.BIN';
  SLLTIT                  = 'A LED lámpa kijelzõ panel frissítését tartalmazó fájl kiválasztása';
  SLNTIT                  = 'A LED nyíl kijelzõ panel frissítését tartalmazó fájl kiválasztása';
  SLHTIT                  = 'A hangszóró meghajtó panel frissítését tartalmazó fájl kiválasztása';
  TALDRB                  = 'A felmérés lezajlott. Az RS485 buszon %d eszközt találtam.';
  HANGES                  = 'Hangerõ (Min.: %d, Max.: %d, Most: %d)';
  HANGST                  = '%s %4d msec. Hangerõ: %3d';
  SZUNET                  = '%s %4d msec.';
  DLLIHI                  = 'A DLL indítása nem sikerült. (Esetleg nincs semmilyen USB eszköz?)' + #13 + #10 + 'Hibakód: %d %s. Kilépek.';
  VALTST                  = 'A felmérésnél válasz Time-Out volt.';
  ENDHIK                  = 'A felmérés hibával ért véget. Hibakód: %d.';
  DARSEM                  = 'A felmérés nem talált egy eszközt sem. (Ilyen nem is lehetne!)';
  DARELT                  = 'Eltérõek a felmérés során megállapitott darabszámok.';
  VALTSE                  = #13 + #10 + 'Újraindítsam a felmérést? (Igen)';
  AZOVST                  = 'Az azonosító megváltoztatása sikeres volt.';
  USBELH                  = 'A vezérlõ USB eszköz eltávolításra került';
  LISENJ                  = 'A feladatlista végrehajtása sikeresen végetért.';
  LISENS                  = 'A feladatlista végrehajtása végetért. Hibakód: %d %s';

type
//
// A LED lámpa megjelenése
//
  LEDLAR = array [0..(LEDLDB - 1)] of TShape;
//
// A LED nyíl megjelenése
//
  LEDNAR = array [0..(LEDNDB - 1)] of TShape;
//
// A színállításhoz tartozó potméter-Label páros
//
  LEDLNY = packed record
    potmet: TTrackBar;
    potmel: TLabel;
  end;
//
// Az RGB-hez 3 darab kell belõle
//
  LEDLFA = array [0..2] of LEDLNY;
//
// Az üzenethez típusleírók
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
    // Esemény az applikáció vonszolásra
    procedure appmov(var Msg: TMessage); message WM_EXITSIZEMOVE;
    // Az applikáció vonszolása
    procedure appmor(const holcur: TPoint);
    // Az érkezett DLL üzenet feldolgozása
    procedure uzfeld(var Msg: TMessage); message UZESAJ;
    // Az applikáció méretének igazítása szükséges mérethez
    procedure posapp(magert, szeler: Integer);
    // A müvelet ablakának aktivizálása
    procedure indwin(melyab: TGroupBox; melygo: TWinControl; gepkod: Dword; const boxstr: String);
    // Hosszbeállítások újragondolása
    procedure hosmod;
    // A LED lámpa állapot kitöltése
    procedure ledbea(const locsta: ELVSTA);
    // A LED nyíl állapot kitöltése
    procedure nyilbe(const locsta: ELVSTA);
    // A hangszóró állapot kitöltése
    procedure hanbea(const locsta: ELVSTA);
    // A müvelethez tartozó eszköz meghatározása
    procedure seldev;
    // A müvelet kiválasztása és végrehajtása
    procedure indfel;
    // Lista méretbeállítás
    procedure listom(var tarbox: TGroupBox; var lisbox: TListBox; kozgom: TButton; widthb: Boolean);
    // Hangállapot frissítés
    procedure frisha;
    // Hangelem kitétel
    procedure reckit(hovate: Integer);
    // Hangelem a listába
    procedure recfri(melyfr: Integer);
//    // Pufferküldés
//    procedure indpck;
  end;

var
  SLF: TSLF;
  muthnd: THandle;
//
// Hibaüzenet a form pozícióján
//
function sajuze(const kirand: String; dlgtyp: msgdty; dlgbut: kpdlgbs; mitfor: TForm): TModalResult; Forward;
//
implementation
//
// A programom változói
//
var
  lehall: Boolean;                          // Állitható a kijelzés
  lehlis: Boolean;                          // Állitható a listabox
  aktadr: Word;                             // Az aktuális cím
  hangdb: Dword;                            // A hangleíró elemszáma
  minsel: Integer;                          // Alap magasság hálózatválasztáshoz
  drb485: Integer;                          // Az RS485-n elérhetõ eszközök száma
  akt485: Integer;                          // Az RS485-s eszközök száma
  aktind: Integer;                          // A hanglista aktuális indexe;
  ositop, osleft: Integer;                  // Az aktuális képernyõ pozíciója
  scrlef, scrtop, scrhei, scrwid: Integer;  // Elhelyezkedési adatok
  vrefer: Int64 = 2420000;                  // 2.42 V a névleges VREF érték
  vddert: Int64;                            // A VDD aktuális értéke
  sajini: TIniFile;                         // Az INI fájl kezelõ elemei
  mitind: TMenuItem;                        // Amit elindítottunk
  devusb: PDEVSEL;                          // Az USB eszközök jellemzõi
  dev485: DEVLIS;                           // A leírók címe
  ledlaa: LEDLAR;                           // A LED lámpák listája
  lednaa: LEDNAR;                           // A LED nyilak listája
  ledlfs: LEDLFA;                           // A LED lámpák színbeállítása
  lednfs: LEDLFA;                           // A LED nyil színbeállítása
  hangtb: HANGLA;                           // Hangleírók táblázata
  listoi: array of Integer;                 // Index a soros elemekhez
  tblveg: LISTBL;                           // A többszörös végrehajtás puffere
//
  capstr: String;                           // Fejléc kialakítás stringje
  statso: String;                           // A státusz sorának tartalma
  butwit: array[kpdlgb] of Integer;         // Kezdéskor nullával feltöltve
//
// Az üzenet elemei
//
  butcap: array[kpdlgb] of PChar = ('&Igen', '&Nem', '&OK');
  capdlg: array[msgdty] of String = (DLGERR, DLGINF, DLGVAL);
  iconid: array[msgdty] of PChar = (IDI_HAND, IDI_ASTERISK, IDI_QUESTION);
  modret: array[kpdlgb] of Integer = (mrYes, mrNo, mrOk);
//
// Kódfrissítés során elõforduló hibák szövegei
//
  hibtxt: array [1..4] of PChar = ('CRC hibás kódmódosító puffer.',
                                   'Nem frissíthetõ ez a verzió.',
                                   'Kód módosításnál íráshiba.',
                                   'Ismeretlen hibakód.'
                                  );
//
// A színösszetevõk "szöveg" konstansai
//
  szintb: array [0..2] of String = ('R',
                                    'G',
                                    'B'
                                  );
////////////////////////////////////////////////////////////////////////////////////
//                                                                                //
// Az egyes belsõ rutinok definiálása.                                            //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////
//
// BCD bájt binárisra alakítás
//
function bcdtob(amibcd: Byte): Dword; Forward;
//
// A kurzor pozíciójához kapcsolódó monitor adatainak lekérdezése
//
procedure apppos(const holcur: TPoint); Forward;
//
// Numerikus hibakódból szöveges hibaleírás (string) konvertálás
//
function gethks(hibkod: Dword): String; Assembler; Forward;
//
// Az INI fájl felülírása csak szükség esetén
//
procedure iniupd(const szeknm, keynam: String; const keyert: BOOL); Forward; overload;
procedure iniupd(const szeknm, keynam: String; const keyert: String); Forward; overload;
procedure iniupd(const szeknm, keynam: String; keyert: Integer); Forward; overload;
//
// Hõmérséklet és VDD kialakítás
//
procedure homvdd(const mitmer: MERESE; mitlab: TLabel); Forward;
//
// Jellmzõ string kialakítása
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
  // Létrehozom az üzenet Form-ját
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
  // Létrehozom az üzenet Form-ját
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
  // Elhelyezem a saját programomhoz képest X irányba középre
  //
  i := i + ((hormar - letreh.Width) DIV 2);
  //
  // Ellenõrzöm, hogy nem lóg-e le a képernyõrõl balra
  //
  if(i < scrlef) then
  begin
    i := scrlef;
  end;
  //
  // Ellenõrzöm, hogy nem lóg-e le a képernyõrõl jobbra
  //
  if((i + letreh.Width) > scrwid) then
  begin
    i := hormar - letreh.Width;
  end;
  //
  // Most már OK. az X pozíció
  //
  letreh.Left := i;
  //
  // Elhelyezem a saját programomhoz képest Y irányba középre
  //
  j := j + ((vermar - letreh.Height) DIV 2);
  //
  // Ellenõrzöm, hogy nem lóg-e le a képernyõrõl fent
  //
  if(j < scrtop) then
  begin
    j := scrtop;
  end;
  //
  // Ellenõrzöm, hogy nem lóg-e le a képernyõrõl lent
  //
  if((j + letreh.Height) > scrhei) then
  begin
    j := vermar - letreh.Height;
  end;
  //
  // Most már OK. az Y pozíció
  //
  letreh.Top := j;
  if(mitfor = NIL) then
  begin
    holcur.x := 0;
    holcur.y := 0;
    apppos(holcur);
    //
    // Elhelyezem a saját programomhoz képest X irányba középre
    //
    i := ((scrwid - letreh.Width) DIV 2);
    //
    // Ellenõrzöm, hogy nem lóg-e le a képernyõrõl balra
    //
    if(i < scrlef) then
    begin
      i := scrlef;
    end;
    //
    // Ellenõrzöm, hogy nem lóg-e le a képernyõrõl jobbra
    //
    if((i + letreh.Width) > scrwid) then
    begin
      i := scrwid - letreh.Width;
    end;
    //
    // Most már OK. az X pozíció
    //
    letreh.Left := i;
    //
    // Elhelyezem a saját programomhoz képest Y irányba középre
    //
    j := ((scrhei - letreh.Height) DIV 2);
    //
    // Ellenõrzöm, hogy nem lóg-e le a képernyõrõl fent
    //
    if(j < scrtop) then
    begin
      j := scrtop;
    end;
    //
    // Ellenõrzöm, hogy nem lóg-e le a képernyõrõl lent
    //
    if((j + letreh.Height) > scrhei) then
    begin
      j := scrhei - letreh.Height;
    end;
    //
    // Most már OK. az Y pozíció
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
    // Elhelyezem a saját programomhoz képest X irányba középre
    //
    i := i + ((mitfor.Width - letreh.Width) DIV 2);
    //
    // Ellenõrzöm, hogy nem lóg-e le a képernyõrõl balra
    //
    if(i < scrlef) then
    begin
      i := scrlef;
    end;
    //
    // Ellenõrzöm, hogy nem lóg-e le a képernyõrõl jobbra
    //
    if((i + letreh.Width) > scrwid) then
    begin
      i := scrwid - letreh.Width;
    end;
    //
    // Most már OK. az X pozíció
    //
    letreh.Left := i;
    //
    // Elhelyezem a saját programomhoz képest Y irányba középre
    //
    j := j + ((mitfor.Height - letreh.Height) DIV 2);
    //
    // Ellenõrzöm, hogy nem lóg-e le a képernyõrõl fent
    //
    if(j < scrtop) then
    begin
      j := scrtop;
    end;
    //
    // Ellenõrzöm, hogy nem lóg-e le a képernyõrõl lent
    //
    if((j + letreh.Height) > scrhei) then
    begin
      j := scrhei - letreh.Height;
    end;
    //
    // Most már OK. az Y pozíció
    //
    letreh.Top := j;
  end;
  //
  // Csilingelek hozzá
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
  // Elindítom az üzenet Form-ját
  //
  letreh.ShowModal;
  //
  // Üzenet vége, eliminálom a létrehozott Form-ot
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
    xor   ecx,ecx                       // Nullázok
    mov   edi,edx                       // A válaszstring címe
    push  ecx                           // A paraméter helye
    mov   edx,esp                       // A puffer címe
    push  ecx                           // FormatMessage 7. paraméter
    push  ecx                           // FormatMessage 6. paraméter
    push  edx                           // FormatMessage 5. paraméter, a PChar címe
    push  LANG_NEUTRAL OR (SUBLANG_DEFAULT SHL 16)// FormatMessage 4. paraméter
    push  eax                           // FormatMessage 3. paraméter, hibkod értéke
    push  ecx                           // FormatMessage 2. paraméter
    push  FORMAT_MESSAGE_ALLOCATE_BUFFER OR FORMAT_MESSAGE_FROM_SYSTEM// FormatMessage 1. paraméter
    mov   eax,edi                       // LStrClr 1. paraméter, a válaszstring leírója
    call  System.@LStrClr               // Az eredeti hozzárendelést megszûntetem
    call  FormatMessage                 // Beolvasom a hibakód szövegét
    pop   edx                           // LStrFromPCharLen 2. paraméter, ez a szövegcím
    sub   eax,2                         // Ennyivel kevesebb legyen a hossza
    js    @hibava                       // Negatív lett, nem volt sikeres
    mov   ecx,eax                       // LStrFromPCharLen 3. paraméter, a hossz
    push  edx                           // LocalFree 1. paraméter
    mov   eax,edi                       // LStrFromPCharLen 1. paraméter, a válaszstring címe
    call  System.@LStrFromPCharLen      // A válasz átmásolása stringbe
    call  LocalFree                     // Felszabadítom a FormatMessage pufferét
  @hibava:
    pop   edi                           // Vissza a mentett érték
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
  l := ((((mitmer.tmpkul * vrefer * 10) DIV (mitmer.tmpdrb * 1023)) - 7640000) DIV 287) + 5; // A hõmérséklet 0.01° lépésben kerekítéssel
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
  // Az elõzõ pozíció beolvasása
  //
  ositop := sajini.ReadInteger(PARAMS, TOPSZA, Top);
  osleft := sajini.ReadInteger(PARAMS, LEFSZA, Left);
  //
  // A Hint-k idejének beállítása (Csak az ini szerkesztésével módosítható az idõ!)
  //
  Application.HintHidePause := sajini.ReadInteger(PARAMS, HIDEPA, 10000);
  Top := ositop;
  Left := osleft;
  //
  // A program paraméterek alapján verzió összeállítás
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
  // A kilépéskori hanglista beolvasása
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
  // A LED lámpa eszköz LED imitáló tömb kialakítása
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
  // A LED lámpa eszköz RGB beállító tömb kialakítása
  //
  ledlfs[0].potmet := LEDLampaRTrackBar;
  ledlfs[0].potmel := LEDLampaRLabel;
  ledlfs[1].potmet := LEDLampaGTrackBar;
  ledlfs[1].potmel := LEDLampaGLabel;
  ledlfs[2].potmet := LEDLampaBTrackBar;
  ledlfs[2].potmel := LEDLampaBLabel;
  //
  // A LED lámpa színarány visszaállítása
  //
  SzinaranyLEDCheckBox.Checked := sajini.ReadBOOL(PARAMS, SZINAL, False);
  ledlfs[0].potmet.Tag := sajini.ReadInteger(PARAMS, ARALER, 0);
  ledlfs[1].potmet.Tag := sajini.ReadInteger(PARAMS, ARALEG, 0);
  ledlfs[2].potmet.Tag := sajini.ReadInteger(PARAMS, ARALEB, 0);
  //
  // A LED nyíl eszköz LED imitáló tömb kialakítása
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
  // A LED nyíl eszköz RGB beállító tömb kialakítása
  //
  lednfs[0].potmet := LEDNyilRTrackBar;
  lednfs[0].potmel := LEDNyilRLabel;
  lednfs[1].potmet := LEDNyilGTrackBar;
  lednfs[1].potmel := LEDNyilGLabel;
  lednfs[2].potmet := LEDNyilBTrackBar;
  lednfs[2].potmel := LEDNyilBLabel;
  //
  // A LED nyíl színarány visszaállítása
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
    // a bal oldal korrekciója, ha kicsúszott a bal oldalon
    Left := scrlef;
  end;
  if(Top < scrtop) then
  begin
    // a tetejének korrekciója, ha kicsúszott felül
    Top := scrtop;
  end;
  if(Left > ((scrlef + scrwid) - Width)) then
  begin
    // a jobb oldal korrekciója, ha kicsúszott a jobb oldalon
    Left := (scrlef + scrwid) - Width;
  end;
  if(Top > ((scrtop + scrhei) - Height)) then
  begin
    // az aljának korrekciója, ha kicsúszott alul
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
      // Az események válaszai. (Pozitív kódok.)
      //
      case(i) of
        //
        // A felmérés lezajlott üzenet
        //
        FELMOK:
        begin
          drb485 := Msg.LParam;
          sajuze(Format(TALDRB, [drb485]), mtInformation, [mbOK], SLF);
          //
          // Lekérdezem a talált elemek táblázatának címét
          //
          SLDLL_Listelem(@dev485);
          //
          // Beállítom a menüelemek engedélyeit (Amik mindenképpen "vannak")
          //
          Teendok.Enabled := drb485 > 0;
          AzonositoBeallitasa.Enabled := drb485 > 0;
          Programfrissites.Enabled := drb485 > 0;
          Ujrafelmeres.Enabled := True;
          //
          // A specifikus elemek engedélyét is beállítom
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
        // Azonosító váltás lezaklott üzenet érkezett
        //
        AZOOKE:
        begin
          sajuze(AZOVST, mtInformation, [mbOK], SLF);
          KilepClick(NIL);
        end;
        //
        // A kódfrissítés folyamatának követése
        //
        FIRMUZ:
        begin
          upgpoi := PUPGPCK(Msg.LParam);
          i := upgpoi^.errcod;
          if(i = 0) then
          begin
            //
            // Mivel a kódküldözgetés két lépésbõl áll, csak a felével kell a számlálónak számolni
            //
            Gauge.Progress := upgpoi^.aktdar DIV 2;
          end
          else
          begin
            //
            // A frissítés hibaüzenettel ért véget
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
        // Az újraindulás üzenete
        //
        FIRMEN: // Förmvercsere vége, újraindítás elndul
        begin
          sajuze(MODBEF, mtInformation, [mbYes], SLF);
          KilepClick(NIL);
        end;
        //
        // A LED lámpa RGB értékeinek állítását visszajelzõ üzenet
        //
        LEDRGB: // A LED lámpa RGB értéke
        begin
          if(LEDLampaGroupBox.Visible) then
          begin
            lehall := True;
            ledbea(PELVSTA(Msg.LParam)^);
          end;
        end;
        //
        // A LED nyíl RGB értékeinek állítását
        // vagy irányának módosítását visszajelzõ üzenet
        //
        NYIRGB: // A nyíl RGB értéke
        begin
          if(LEDNyilGroupBox.Visible) then
          begin
            lehall := True;
            nyilbe(PELVSTA(Msg.LParam)^);
          end;
        end;
        //
        // A hangstring elindítását visszajelzõ üzenet
        //
        HANGEL: // A hangstring állapota
        begin
          if(HangszoroGroupBox.Visible) then
          begin
            hanbea(PELVSTA(Msg.LParam)^);
          end;
        end;
        //
        // A menüindítás és státuszbekérés Timer üzenetének
        // visszajelzése
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
        USBREM: // Az USB vezérlõ eltávolításra került
        begin
          ujfelk := False;
          s := USBELH;
        end;
        VALTIO: // Válaszvárás time-out következett be
        begin
          s := VALTST;
        end;
        FELMHK: // Felmérés vége hibával
        begin
          s := Format(ENDHIK, [Msg.LParam]);
        end;
        FELMHD: // Nincs egy darab sem hibakód (elvben sem lehet ilyen)
        begin
          s := DARSEM;
        end;
        FELMDE: // A 16 és 64 bites darabszám nem egyforma
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
        // Az USB eszköz eltávolítása esetén letiltom a menüelemeket
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
  // Az INI fájl elemeinek frissítése (Csak akkor, ha nem éppen azonosak!)
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
// Kilépéskori alapállapot beállítás
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
// A megjeneõ form elem elhelyezése a monitoron
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
// A Form elem (TGroupBox) indításkori kialakítása és elhelyezése
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
        s := 'LED lámpa';
      end;
      2:
      begin
        s := 'LED nyíl';
      end;
      3:
      begin
        s := 'hangszóró';
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
// A DLL leíró státusz sor hossza miatti form elemek átrendezése
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
  // A menüelemek miatti minimum hossz kiszámítása
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
  // A státusz sor szükséges mérete
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
// A LED lámpa aktualizálása a panel értékeivel szinkronban
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
    // A szín értékének összeállítása
    //
    kulcol := locsta.rgbert.rossze + (locsta.rgbert.gossze SHL 8) + (locsta.rgbert.bossze SHL 16);
    //
    // A LED lámpa potmétereinek beállítása
    //
    ledlfs[0].potmet.Position := locsta.rgbert.rossze;
    ledlfs[1].potmet.Position := locsta.rgbert.gossze;
    ledlfs[2].potmet.Position := locsta.rgbert.bossze;
    //
    // A LED lámpa potmétereinek fejléc szöveg beállítása
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
    // A LED lámpa szimbólum színbeállítása
    //
    i := 0;
    while(i < LEDLDB) do
    begin
      ledlaa[i].Brush.Color := kulcol;
      inc(i);
    end;
    //
    // A státusz sorba VDD és proci hõmérséklet
    //
    homvdd(locsta.merlam, LEDLampaLabel);
    lehall := True;
    //
    // A Timer indítása (új állapot kérés egy idõ után)
    //
    Timer.Enabled := True;
  end;
end;
//
// A LED nyíl aktualizálása a panel értékeivel szinkronban
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
    // A LED nyíl irányának meghatározása
    //
    irabal := locsta.nyilal = 0;
    //
    // A szín értékének összeállítása
    //
    kulcol := locsta.rgbert.rossze + (locsta.rgbert.gossze SHL 8) + (locsta.rgbert.bossze SHL 16);
    //
    // A LED nyíl potmétereinek beállítása
    //
    lednfs[0].potmet.Position := locsta.rgbert.rossze;
    lednfs[1].potmet.Position := locsta.rgbert.gossze;
    lednfs[2].potmet.Position := locsta.rgbert.bossze;
    //
    // A LED nyíl irányának jelzése
    //
    BalraRadioButton.Checked := irabal;
    JobbraRadioButton.Checked := NOT irabal;
    //
    // A LED nyíl potmétereinek fejléc szöveg beállítása
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
    // A LED nyíl szimbólum színbeállítása
    //
    i := 0;
    while(i < LEDNDB) do
    begin
      case(i) of
        //
        // Balra mutató irányban szereplõ LED szmbólumok be-, vagy kikapcsolása
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
        // Jobbra mutató irányban szereplõ LED szmbólumok be-, vagy kikapcsolása
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
        // Mindkét irányban szereplõ LED szmbólumok bekapcsolása
        //
        begin
          lednaa[i].Brush.Color := kulcol;
        end;
      end;
      inc(i);
    end;
    //
    // A státusz sorba VDD és proci hõmérséklet
    //
    homvdd(locsta.merlam, LEDNyilLabel);
    lehall := True;
    //
    // A Timer indítása (új állapot kérés egy idõ után)
    //
    Timer.Enabled := True;
  end;
end;
//
// A hang string összeállítása és elindítása
//
procedure TSLF.hanbea(const locsta: ELVSTA);
begin
  if(lehlis) then
  begin
    lehlis := False;
    //
    // A státusz sorba VDD és proci hõmérséklet
    //
    homvdd(locsta.merlam, HangszoroLabel);
    lehlis := True;
    //
    // A lejátszás állapotának követése
    //
    if(locsta.hanakt = 0) then
    begin
      LejatszasButton.Enabled := True;
    end;
    //
    // A Timer indítása (új állapot kérés egy idõ után)
    //
    Timer.Enabled := True;
  end;
end;
//
// Több lehetséges eszköz esetén szelekciós ablak készítés
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
  // Listakészítés a lehetséges elemekrõl
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
  // A lista ellenõrzése, hogy van-e több kiválasztandó elem
  //
  if(Length(listoi) = 1) then
  begin
    //
    // Csak egy panel van ilyen, egybõl indítom a feladatot
    //
    akt485 := listoi[0];
    aktadr := dev485[akt485].azonos;
    indfel;
  end
  else
  begin
    //
    // Van több lehetséges panel, elindítom a szelekciós elemet
    //
    listom(SelDevGroup, DevListBox, NIL, True);         // Méretre igazítás
    DevListBox.ItemIndex := 0;                          // Kezdõ index
    indwin(SelDevGroup, DevlistBox, $ffffffff, SELUSB); // Választás indítás
  end;
end;
//
// A feladat kiválasztása
//
procedure TSLF.indfel;
var
  i, j: Dword;
begin
  //
  // Az azonosítót módosító feladatrész indítása
  // (Ez minden paneltípusnál azonos, de kezelni kell
  // a típusjelzõ bitpárosokat)
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
    // Kódfrissítés (förmvercsere) indítása
    // (Ez minden paneltípusnál azonos, de kezelni kell
    // a típusjelzõ bitpárosokat)
    //
    if(mitind = Programfrissites) then
    begin
        //
        // A kódfrissítésnél meghatározom a frissító fájl ajánlott nevét
        // és a fájlválasztó ablak fejlécének szövegét
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
      // Elindítom a fájlválasztót
      //
      if(FirmwareUpdateDialog.Execute) then
      begin
        //
        // A fájlkiválasztás megtörtént, indítom a frissítést.
        //
        j := SLLDLL_Upgrade(PChar(FirmwareUpdateDialog.FileName), i, dev485[akt485].azonos);
        case(j) of
          NO_ERROR:
          begin
            //
            // A frissítés sikeresen elindult, megjelenítem a frissítés menetét mutató
            // folyamatjelzõt, és kalibrálom az ütemet jelzõ elemet
            //
            Gauge.MaxValue := i;
            Gauge.MinValue := 0;
            Gauge.Progress := 0;
            indwin(EEPmuvelet, NIL, dev485[akt485].azonos, KODSTR);
          end;
          //
          // Nem sikerült a frissítést elindítani, megüzenem annak okát
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
      // LED lámpa kezelés indítás
      //
      if(mitind = LEDLampaKijelzo) then
      begin
        indwin(LEDLampaGroupBox, LEDLampaKilepButton, dev485[akt485].azonos, LEDLSU);
        lehall := True;
        //
        // Státusz kéréssel beolvasom (és majd kiteszem) az aktuális állapotot
        //
        SLDLL_GetStatus(dev485[akt485].azonos);
      end
      else
      begin
        //
        // LED nyíl kezelés indítás
        //
        if(mitind = LEDNyilKijelzo) then
        begin
          indwin(LEDNyilGroupBox, LEDNyilKilepButton, dev485[akt485].azonos, LEDNSU);
          lehall := True;
          //
          // Státusz kéréssel beolvasom (és majd kiteszem) az aktuális állapotot
          //
          SLDLL_GetStatus(dev485[akt485].azonos);
        end
        else
        begin
          //
          // Hang string kialakítás és hangindítás kezelés indítás
          //
          if(mitind = HangszoroPanelKezeles) then
          begin
            //
            // Kiteszem az utolsónak szerkesztett hanglistát
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
            // Státusz kéréssel beolvasom (és majd kiteszem) az aktuális állapotot
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
// A ListBox méretéhez igazítom az azt befoglaló környezetet
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
// A Form indítása
//
procedure TSLF.FormActivate(Sender: TObject);
var
  i: Integer;
  holcur: TPoint;
  nevlei: PDLLNEV;
begin
  //
  // A kezelõ DLL elindítása. Átadom a sajét Window Handle értékét
  // és a kommunikációs üzenet számát. Ez nem lehet kisebb mint WM_USER.
  // Sikeres indítás esetén visszakapom a kt DLL verzióját, és
  // pontos specifikációját, valamint a csatlakozó panel leírását. Egyben
  // elindul az RS485-ös buszon található elemek meghatározása is. A keresés
  // végét "FELMOK" üzenet jelzi. (Lásd ott.)
  //
  i := SLDLL_Open(Handle, UZESAJ, @nevlei, @devusb);
  if(i <> NO_ERROR) then
  begin
    //
    //
    //
    posapp(116, 94);
    //
    // Az elindítás nem sikerült, a hiba okát negüzenem
    //
    sajuze(PChar(Format(DLLIHI,[i, gethks(i)])), mtError, [mbOK], SLF);
    Close;
  end
  else
  begin
    //
    // Sikeres elindulta DLL, a fejlécben kiírom  kapcsolattartó elem jellemzõit
    //
    Caption := capstr + ' ' + verstr(devusb^);
    //
    // A státuszsorba kiteszem a két DLL jellemzõit
    //
    statso := Format(VERKIF,[nevlei^[0].mianev, nevlei^[0].versih, nevlei^[0].versil]) + ' és ' +
              Format(VERKIF,[nevlei^[1].mianev, nevlei^[1].versih, nevlei^[1].versil]);
    StatusBar.Panels[0].Text := statso;
    StatusBar.Hint := statso;
    //
    // A szükséges méretre igazítom a Formot és a GroupBox-okat
    //
    hosmod;
    //
    // Alaphelyzetet állítok
    //
    posapp(116, minsel);
    holcur.y := ositop;
    holcur.x := osleft;
    appmor(holcur);
    HangeroTrackBarChange(NIL);
  end;
end;
//
// "Idõnként" stástusz kérést indítok, ha olyan GroupBox az aktív, amelyik
// a választ feldolgozza. A Timer újraindításáról a státusz üzenetet (STATKV)
// feldolgozó programrész gondoskodik,
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
// A menüelemre kattintottak
//
procedure TSLF.MenuinditClick(Sender: TObject);
begin
  mitind := TMenuItem(Sender);
  seldev;
end;
//
// Az azonosító váltás leütéseit kezelõ programrész. (Csak számokat enged meg.)
//
procedure TSLF.NumEditKeyPress(Sender: TObject; var Key: Char);
begin
  case(Key) of
    ' '..'/',
    ':'..'ÿ':
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
// Az azonosító szerkesztés értékének követése
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
// Az azonosító módosítását kezdeményezték
//
procedure TSLF.AzonositoBeallitClick(Sender: TObject);
var
  i: Integer;
  gepkou: Word;
begin
  if(NumEdit.Text <> '') then
  begin
    //
    // Ellenõrzöm, hogy a szabályoknak megfelel-e
    //
    gepkou := StrToInt(NumEdit.Text);
    if((gepkou > 16382) OR (gepkou = 0))then
    begin
      //
      // Hibaüzenet, mert nem szabályos az értéke
      //
      sajuze(GEPKIA, mtError, [mbOK], SLF);
    end
    else
    begin
      //
      // Elindítom az azonosító megváltoztatását
      //
      i := SLDLL_AzonositoCsereInditas(dev485[akt485].azonos, gepkou OR NumEdit.Tag);
      if(i <> NO_ERROR) then
      begin
        //
        // Enm sikerült az indítás, a hibáról üzenek
        //
        sajuze(PChar(Format(AZOVNS,[i, gethks(i)])), mtError, [mbOK], SLF);
      end;
    end;
  end;
end;
//
// A Listbox elemének Hint-ben megjelenítése
//
procedure TSLF.DevListBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i: Integer;
  alopos: TPoint;
  s: String;
  // A hint szöveg kialakítása
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
// Kiválasztás Enter-rel
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
// A panelek listából kiválasztása történt
//
procedure TSLF.KivalasztButtonClick(Sender: TObject);
begin
  akt485 := listoi[DevListBox.ItemIndex];
  aktadr := dev485[akt485].azonos;
  indfel;
  SelDevGroup.Visible := False;
end;
//
// Kilépés menüleme, aktivizálja a programból a kilépést
//
procedure TSLF.ExitMenuElemClick(Sender: TObject);
begin
  Close;
end;
//
// A színarányok megõrzésének számítási menete
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
// LED lámpa színbeállítás aktivizálás
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
// LED nyíl színbeállítás és irányváltás aktivizálás
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
// LED lámpa színarány beállításnál arányok mentése
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
// LED nyíl színarány beállításnál arányok mentése
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
// Hangerõ potméter változtatás kezelése
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
// Új hang létrehozása a hangtáblázatba
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
// A hanglista elemének szövegfrissítése
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
// A hangtáblázat elemének beállítása az aktuális értékre
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
// A hangmagasság változtatás kezelése
//
procedure TSLF.HangmagassagComboBoxChange(Sender: TObject);
begin
  if(lehlis) then
  begin
    frisha;
  end;
end;
//
// A hanglista egy elemének törlése
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
// A hanglista felbukkanó menü elemeinek kialakítása
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
// Az aktuális hang szerinti beállítások átadása
//
procedure TSLF.reckit(hovate: Integer);
begin
  HangmagassagComboBox.Itemindex := hangtb[hovate].hangso;
  HanghosszComboBox.Text := IntToStr(hangtb[hovate].hangho);
  HangeroTrackBar.Position := hangtb[hovate].hanger;
end;
//
// A hang kiválasztás kezelése
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
// A kiválasztott hang fölfele tolása
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
// A kiválasztott hang lefele tolása
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
// Az aktuális hanglista indítása
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
// A buszon található eszközök újrafelmérése
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
