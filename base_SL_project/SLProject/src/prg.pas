unit prg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SLDLL, StdCtrls, Menus, ExtCtrls, Grids, settings, ComCtrls,
  jpeg, globals;

type

  TForm1 = class(TForm)
    Panel1: TPanel;
    MainMenu1: TMainMenu;
    esztek1: TMenuItem;
    Csoportkldstesztelse1: TMenuItem;
    Label1: TLabel;
    Timer1: TTimer;
    Program1: TMenuItem;
    Inicializls1: TMenuItem;
    Kilps1: TMenuItem;
    Programindtsa1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Belltsok1: TMenuItem;
    Eszkzlista1: TMenuItem;
    jsorozathozzadsa1: TMenuItem;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ScrollBox1: TScrollBox;
    ListBox1: TListBox;
    Panel2: TPanel;
    Start1: TMenuItem;
    SaveDialog1: TSaveDialog;
    Programmentse1: TMenuItem;
    Programbetltse1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Programok1: TMenuItem;
    OpenDialog1: TOpenDialog;
    N1: TMenuItem;
    Feladatsorszerkesztse1: TMenuItem;
    N4: TMenuItem;
    Image1: TImage;
    TrackBar1: TTrackBar;
    procedure Kilps1Click(Sender: TObject);
    procedure Inicializls1Click(Sender: TObject);
    procedure Csoportkldstesztelse1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Programindtsa1Click(Sender: TObject);
    procedure Sorozatteszt1Click(Sender: TObject);
    procedure jsorozathozzadsa1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure Start1Click(Sender: TObject);
    procedure Belltsok1Click(Sender: TObject);
    procedure Programmentse1Click(Sender: TObject);
    procedure Programbetltse1Click(Sender: TObject);
    procedure Feladatsorszerkesztse1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Panel2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TrackBar1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    procedure uzfeld(var Msg: TMessage); message UZESAJ;
    procedure start();
    procedure ledbea(const locsta: ELVSTA);
    procedure nyilbe(const locsta: ELVSTA);
    procedure hanbea(const locsta: ELVSTA);
    procedure sendMesgToDevices();
    procedure setRound(roundNumber: integer);

    procedure eszkozPanelLista(mainPanel: TScrollBox);
    procedure ujlista();

    procedure DEVICE_select_by_button(Sender: TObject);
    procedure save_selectted_DEVICE();

    procedure createprogram();
    procedure svaePRG();

    procedure addProgramPanels(Feladatlista: TStringList);
    procedure programsorokPanelhezRendelese(sori: string; mainPanel: TScrollBox);
  end;

var
  Form1: TForm1;
  CONTAINER_NUMBER: integer = 0;
  LISTADB: integer = 0;
  CONTTOP: integer;
  DEVICENUMBER: integer = 0;

  containerINDEX: integer;
  elemINDEX: integer;

  H: HANGLA;

implementation

uses Unit2, Unit3;

{$R *.dfm}



procedure TForm1.programsorokPanelhezRendelese(sori: string; mainPanel: TScrollBox);
var
  i: integer;
  DEV_dev: deviceType;
  DEV_panel: TPanel;
  CONT: TPanel;
  AKTPANELLEFT: integer;
  elemek, darabok:TStringList;
begin
  DEVICENUMBER := drb485;
  CONT := TPanel.Create(self);
  CONT.Parent := mainPanel;
  CONT.Name := 'DEVLIST_' + inttostr(LISTADB);
  CONT.Caption := inttostr(LISTADB) + '. ütem';
  CONT.Top := CONTTOP;
  CONT.Width := mainpanel.Width;
  CONT.Color := clWhite;
  CONT.BevelOuter := bvLowered;
  CONT.BevelOuter := bvRaised;
  CONT.Width :=  BUTTONWIDTH * DEVICENUMBER;
  CONT.Height := BUTTONHEIGHT;
  CONTTOP := CONTTOP + BUTTONHEIGHT;
  CONTAINERList.Add(CONT);
  CONTAINER_NUMBER := CONTAINERList.Count - 1;

  DEVICEList := Tlist.Create();
  DEVICEPANELLIST := TList.Create();

  AKTPANELLEFT := 0;

  elemek := TStringList.Create();
  Split('/', sori, elemek);

  for i:= 0 to elemek.Count - 1 do
  begin

    darabok := TStringList.Create();
    Split('|', elemek[i], darabok);

    DEV_dev := deviceType.Create(i);
    DEV_dev.setAttr();
    DEV_dev.active := false;
    DEV_dev.devlistAzonosito := dev485[i].azonos;
    DEV_dev.dtype := dev485[i].azonos;

    case(dev485[i].azonos AND $c000) of
     SLLELO:
     begin
       //LEDLampa
       DEV_dev.tipus := 1;
     end;
     SLNELO:
     begin
       //LEDNyil
       DEV_dev.tipus := 2;
     end;
     SLHELO:
     begin
       DEV_dev.tipus := 3;
       //HangszoroKezeles
     end;

    end; //case

    DEV_panel := TPanel.Create(self);
    DEV_panel.Parent := CONTAINERList[CONTAINER_NUMBER];
    DEV_panel.Top := 0;
    DEV_panel.Left := AKTPANELLEFT;
    inc(AKTPANELLEFT, BUTTONWIDTH);
    DEV_panel.Name := 'DEV' + inttostr(i) + '_' + inttostr(LISTADB);
    //DEV_Panel.Caption := inttostr(LISTADB) + '/' + inttostr(i); // + '. eszköz';
    DEV_panel.Tag := i;

    DEV_dev.r := strToInt(darabok[0]);
    DEV_dev.g := strToInt(darabok[1]);
    DEV_dev.b := strToInt(darabok[2]);
    //DEV_dev.b := strToInt(darabok[3]); //Az ütem feldolgozásához a fájlban egy új elem bevezetve. Hanghossz,vagy ütemhossz.
                                         //Ezt adjuk hozzá az alapértelmezett időzítéshez.

    if darabok[3] = 'x' then
    begin
      DEV_panel.Color := clBtnFace;
    end
    else
    begin
      DEV_dev.szin := DEV_dev.r
                    + (DEV_dev.g SHL 8)
                    + (DEV_dev.b SHL 16);
      DEV_dev.irany := strToInt(darabok[3]);

      if debug then showmessage(darabok[3]);

    end;

    DEV_Panel.Color := DEV_dev.szin;
    DEV_Panel.PopupMenu := PopupMenu1;

    if (DEV_dev.r = 0) and (DEV_dev.g = 0) and (DEV_dev.b = 0) then
    begin
      DEV_panel.Color := clBtnFace;
      DEV_Panel.PopupMenu := nil;
    end;

    //if DEV_panel.Color <> clBtnFace then DEV_panel.BevelOuter := bvLowered;

    DEV_panel.Width := BUTTONWIDTH;
    DEV_panel.Height := BUTTONHEIGHT;
    DEV_panel.PopupMenu := nil; //popupMenu1;
    DEV_panel.OnClick := Panel2Click;

    case DEV_dev.irany of
      0: DEV_panel.Caption := '<>';
      1: DEV_panel.Caption := '<';
      2: DEV_panel.Caption := '>';
      3: DEV_panel.Caption := '<>';
    end;

    {if DEV_dev.tipus = 1 then begin
       //DEV_panel.Color := clYellow; //Lámpa
       DEV_Panel.Caption := '<>';
    end;
    if DEV_dev.tipus = 2 then begin
       //DEV_panel.Color := clGreen; //Nyíl
       DEV_Panel.Caption := '<->';
    end;}
    if DEV_dev.tipus = 3 then begin
       //DEV_panel.Color := clBlue; //Hangszóró
       DEV_Panel.Caption := 'H';
       DEV_Panel.Color := clBtnFace;
    end;

    DEVICEList.Add(DEV_dev);
    DEVICEPANELLIST.Add(DEV_panel);

  end;

  DEVICECONTAINERLIST.Add(DEVICEList);
//  CONTAINERList.Add(DEVICEPANELLIST);

end;

procedure TForm1.addProgramPanels(Feladatlista: TStringList);
var
  i: integer;
begin
  for i := 0 to ROUNDNUMBER - 1 do
  begin
     //ujlista();
     inc(LISTADB);
     programsorokPanelhezRendelese(Feladatlista[i], ScrollBox1);
  end;
end;

procedure TForm1.createprogram();
var
  i, j: integer;
  DEVLISTp: TList;
  DEVp: deviceType;
  sor: string;
begin
  for i := 0 to DEVICECONTAINERLIST.Count - 1 do
  begin

     DEVLISTp := DEVICECONTAINERLIST[i];
     sor := '';
     for j := 0 to DEVLISTp.Count - 1 do
     begin
       DEVp := DEVLISTp[j];
       if (DEVp.tipus = 1) or (DEVp.tipus = 2) then
       begin //Lámpa iránya 0/balra, 1/jobbra, 2/mindkettõ
         sor :=  sor + inttostr(DEVp.r) + '|'
               + inttostr(DEVp.g) + '|'
               + inttostr(DEVp.b) + '|';
         if DEVp.irany = 1 then sor := sor + '0|';
         if DEVp.irany = 2 then sor := sor + '1|';
         if DEVp.irany = 3 then sor := sor + '2|';
         if DEVp.irany = 0 then sor := sor + '2|';
       end; //if

       if DEVp.tipus = 3 then
       begin //hangszóró
       DEVp := DEVLISTp[j];
         //sor := sor + '0|0|0|x/';
         sor :=  sor + inttostr(DEVp.hangero) + '|'
                + inttostr(DEVp.hangszin) + '|'
                + inttostr(DEVp.hanghossz) + '|';
         sor := sor + 'x|';
       end; //if

       //if DEVp.utemhossz = 0 then
       //begin
       //  sor := sor + inttostr(DEVp.utemhossz) + "|";
       //end;
       //Kell az időzítésnél a beállítás, vagyis, hogy a 0 alapértelmezett, és az eltérő értékek mit jelentenek.
       //A timerben az ontimer eseményt kell átátllítani ehhez az értékhez képest. Ezt kell az alapértelmezetthez hozzáadni.
       //Lehetne ez milisec-ben megadva, és akkor nem kel konvertálni. pl.: 10 az alap, ezt szsorozzuk 1000-el, majd hozzáadjuk a
       //timer idejéhez.s

       sor := copy(sor, 0, length(sor) - 1);
       sor := sor + '/';
       //showmessage(sor);
      end; //for i
     sor := copy(sor, 0, length(sor) - 1);
     programSorok.Add(sor);
  end; //for j
end;

procedure TForm1.svaePRG();
begin
  try
    programSorok := TStringList.Create();
    createProgram();
    if Savedialog1.Execute then
    begin
      programSorok.SaveToFile(Savedialog1.FileName);
    end;
  except
    showmessage('HIba a fájl mentése során, ellenõrizze a jogosultságot és az elérési utat!');
  end;
end;

procedure TForm1.ujlista();
begin
  inc(LISTADB);
  eszkozPanelLista(ScrollBox1);
end;

procedure TForm1.eszkozPanelLista(mainPanel: TScrollBox);
var
  i: integer;
  DEV_dev: deviceType;
  DEV_panel: TPanel;
  CONT: TPanel;
  AKTPANELLEFT: integer;
begin

  //Konténer panel listában, hogy lehessen hozzáadni késõbb új elemeket.

  DEVICENUMBER := drb485;

  CONT := TPanel.Create(self);
  CONT.Parent := mainPanel;
  CONT.Name := 'DEVLIST_' + inttostr(LISTADB);
  CONT.Caption := inttostr(LISTADB) + '. ütem';
  CONT.Top := CONTTOP; //mainPanel.Top;
  //CONT.Align := AlTop;
  CONT.Width := mainpanel.Width;
  CONT.Color := clWhite;
  CONT.BevelOuter := bvLowered;
  CONT.BevelOuter := bvRaised;
  CONT.Width :=  BUTTONWIDTH * DEVICENUMBER;
  CONT.Height := BUTTONHEIGHT;
  CONTTOP := CONTTOP + BUTTONHEIGHT;
  CONTAINERList.Add(CONT);
  CONTAINER_NUMBER := CONTAINERList.Count - 1;

  //Egy panelen szereplõ eszközök listája, egy lista a paneleknek és egy a hozzájuk rendelt elemeknek.
  //a tag és a dtag az összerendelés alapja, más azonosító nincs, ami megmutatnû, hogy melyik panel melyik
  //eszközzel kapcsolódik össze.
  //a popupmenu is a tag alapján választja ki a beállítani, vagy egyéb módon alakítani kívánt eszközt.

  DEVICEList := Tlist.Create();
  DEVICEPANELLIST := TList.Create();

  AKTPANELLEFT := 0;
  for i:= 0 to DEVICENUMBER - 1 do
  begin

    DEV_dev := deviceType.Create(i);
    DEV_dev.setAttr();
    DEV_dev.active := false;
    DEV_dev.devlistAzonosito := dev485[i].azonos;
    DEV_dev.dtype := dev485[i].azonos;

    //DEV_dev.tipus := (dev485[i].azonos AND $c000) SHL 6;

    case(dev485[i].azonos AND $c000) of
     SLLELO:
     begin
       //LEDLampa
       DEV_dev.tipus := 1;
     end;
     SLNELO:
     begin
       //LEDNyil
       DEV_dev.tipus := 2;
     end;
     SLHELO:
     begin
       DEV_dev.tipus := 3;
       //HangszoroKezeles
     end;

    end; //case

    DEV_panel := TPanel.Create(self);
    DEV_panel.Parent := CONTAINERList[CONTAINER_NUMBER];
    DEV_panel.Top := 0;
    DEV_panel.Left := AKTPANELLEFT;
    inc(AKTPANELLEFT, BUTTONWIDTH);
    //DEV_panel.Name := 'DEV' + inttostr(i) + '_' + inttostr(LISTADB);
    DEV_Panel.Caption := inttostr(LISTADB) + '/' + inttostr(i); // + '. eszköz';
    DEV_panel.Tag := i;
    DEV_panel.Color := clBtnFace; //$00C08000;
    DEV_panel.Width := BUTTONWIDTH;
    DEV_panel.Height := BUTTONHEIGHT;
    DEV_panel.PopupMenu := popupMenu1;
    DEV_panel.OnClick := Panel2Click;

    if debug then showmessage(inttostr(DEV_dev.tipus));

    DEV_dev.r := 0;
    DEV_dev.g := 0;
    DEV_dev.b := 0;
    DEV_dev.szin := clBtnFace;
    DEV_dev.irany := 3;

    if DEV_dev.tipus = 1 then begin
       //DEV_panel.Color := clYellow; //Lámpa
       DEV_Panel.Caption := '<>';
    end;
    if DEV_dev.tipus = 2 then begin
       //DEV_panel.Color := clGreen; //Nyíl
       DEV_Panel.Caption := '<->';
    end;
    if DEV_dev.tipus = 3 then begin
       //DEV_panel.Color := clBlue; //Hangszóró
       DEV_Panel.Caption := 'H'
    end;

    DEVICEList.Add(DEV_dev);
    DEVICEPANELLIST.Add(DEV_panel);

  end;

  DEVICECONTAINERLIST.Add(DEVICEList);
//  CONTAINERList.Add(DEVICEPANELLIST);

end;


procedure TForm1.setRound(roundNumber: integer);
var
  RES, i: integer;
  EDB: integer;
  prgString, prgLine: string;
  elements: tStringList;
begin

  if SLprogram.Count > roundNumber then
  begin
    prgLine := SLProgram[roundNumber];
    programElements := TStringList.Create();
    Split('/', prgLine, programElements);

    if debug then listbox1.Items.Add('-------- Programsor -------');
    if debug then listbox1.Items.Add(prgLine);
    if debug then listbox1.Items.Add('-------- ---------- -------');

    EDB := programElements.Count;
    if debug then listbox1.Items.Add('EDB: ' + inttostr(EDB));

    for i := 0 to EDB - 1 do
    begin
     try

      elements := TStringList.Create();
      prgString := programElements[i];

      if debug then listbox1.Items.Add('-------- Elemek -------');
      if debug then listbox1.Items.Add('elem ' + inttostr(i) + ' ' +prgString);

      Split('|', prgString, elements);

      teststring := teststring + prgString + ':' + inttostr(i) + '. elemre.';

      if debug then listbox1.Items.Add(inttostr(dev485[i].azonos));

      if debug then listbox1.Items.Add('SL: ' + inttostr(dev485[i].azonos AND $c000));

      case(dev485[i].azonos AND $c000) of
       SLLELO:
       begin
         //LEDLampa
         devList[i].azonos := dev485[i].azonos;
         devList[i].vilrgb.rossze := strToInt(elements[0]);
         devList[i].vilrgb.gossze := strToInt(elements[1]);
         devList[i].vilrgb.bossze := strToInt(elements[2]);
         devList[i].nilmeg := strToInt(elements[3]);
       end;
       SLNELO:
       begin
         //LEDNyil
         devList[i].azonos := dev485[i].azonos;
         devList[i].vilrgb.rossze := strToInt(elements[0]);
         devList[i].vilrgb.gossze := strToInt(elements[1]);
         devList[i].vilrgb.bossze := strToInt(elements[2]);
         devList[i].nilmeg := strToInt(elements[3]); // 1 //2 strToBool(elements[3]);
       end;
       SLHELO:
       begin
         devList[i].azonos := dev485[i].azonos;


         devList[i].handrb := 1;
         devList[i].hantbp := @H;
         H[0].hangho := strToInt(elements[2]); //100; //hossz
         H[0].hangso := strToInt(elements[1]); //1;   //sorszáma a táblázatból
         H[0].hanger := strToInt(elements[0]); //10;  //hangerõ

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
33 = szünet
*)


         //HangszoroKezeles
       end;

      end; //case
     except
       showmessage('Elem beállítási hiba');
     end;

  end; //for
   //devList[4].azonos := dev485[4].azonos;
   //devList[4].handrb := 0;

  try
    if debug then listbox1.Items.Add('EDB: ' + inttostr(EDB));
    RES := SLDLL_SetLista(EDB, devList);
  except
    showmessage('Eszközbeállítási hiba: ' + inttostr(RES));
  end;


  end
  else
  begin
    showmessage('Hibás program sorszám: ' + inttostr(roundNumber));
  end;

end;


procedure TForm1.sendMesgToDevices();
begin
  TimerIntervall := SLinterval;
  Timer1.Interval := timerIntervall;
  Timer1.Enabled := true;
end;

procedure TForm1.start();
var
  i: integer;
  RES: integer;
  nevlei, devusb: pchar;
begin
  RES := SLDLL_Open(Form1.Handle, UZESAJ, @nevlei, @devusb);
  label1.Caption := inttostr(RES);
  //listbox1.Items.LoadFromFile(ExtractFilePath(ParamStr(0)) + PROGRAMFILENAME);
  //SLprogram := TStringList.Create();
  //SLprogram.LoadFromFile(ExtractFilePath(ParamStr(0)) + PROGRAMFILENAME);
  //ROUNDNUMBER := SLprogram.Count;
end;

procedure TForm1.Kilps1Click(Sender: TObject);
begin
  Form1.Close();
end;

procedure TForm1.Inicializls1Click(Sender: TObject);
begin
   try
     start();
   except
     showmessage('Eszköz inicializálási hiba, ellenõrizze az eszközök csatlakozóit!');
   end;
end;

procedure TForm1.Csoportkldstesztelse1Click(Sender: TObject);
var
  i: integer;
  elemszam: integer;
begin

  lista[0].azonos := dev485[0].azonos;
  lista[0].vilrgb.rossze := 0;
  lista[0].vilrgb.gossze := 0;
  lista[0].vilrgb.bossze := 0;
devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  lista[1].azonos := dev485[1].azonos;
  lista[1].vilrgb.rossze := 0;
  lista[1].vilrgb.gossze := 0;
  lista[1].vilrgb.bossze := 0;
devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  lista[2].azonos := dev485[2].azonos;
devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);
  lista[2].vilrgb.rossze := 20;
  lista[2].vilrgb.gossze := 0;
  lista[2].vilrgb.bossze := 0;


  lista[3].azonos := dev485[3].azonos;
  lista[3].vilrgb.rossze := 20;
  lista[3].vilrgb.gossze := 0;
  lista[3].vilrgb.bossze := 0;
devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  elemszam := 2;

  i := SLDLL_SetLista(elemszam, lista);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Label1.Caption := inttostr(MyCounter + 1) + '. kör';
  setRound(myCounter);
  //label1.Caption := teststring;
  if MyCounter < SLprogram.Count - 1 then
  begin
    inc(MyCounter);
  end
  else
  begin
    Timer1.Enabled := false;
  end;
end;

procedure TForm1.uzfeld(var Msg: TMessage);
var
  i: Integer;
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
          //sajuze(Format(TALDRB, [drb485]), mtInformation, [mbOK], SLF);
          //
          // Lekérdezem a talált elemek táblázatának címét
          //
          SLDLL_Listelem(@dev485);
          //
          // Beállítom a menüelemek engedélyeit (Amik mindenképpen "vannak")
          //

          //
          // A specifikus elemek engedélyét is beállítom
          //
          i := 0;
          while(i < drb485) do
          begin
            case(dev485[i].azonos AND $c000) of
              SLLELO:
              begin
                //LEDLampaKijelzo.Enabled := True;
              end;
              SLNELO:
              begin
                //LEDNyilKijelzo.Enabled := True;
              end;
              SLHELO:
              begin
                //HangszoroPanelKezeles.Enabled := True;;
              end;
            end;
            inc(i);
          end;
        end;
        //
        // Azonosító váltás lezajlott üzenet érkezett
        //
        AZOOKE:
        begin
          //megváltoztattam az eszköz számát, akkor jön ez a válasz
        end;
        //
        // A kódfrissítés folyamatának követése
        //
        {FIRMUZ:
        begin
          upgpoi := PUPGPCK(Msg.LParam);
          i := upgpoi^.errcod;
          if(i = 0) then
          begin
            //
            // Mivel a kódküldözgetés két lépésbol áll, csak a felével kell a számlálónak számolni
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
        end;}
        //
        // Az újraindulás üzenete
        //
        {FIRMEN: // Förmvercsere vége, újraindítás elndul
        begin
          sajuze(MODBEF, mtInformation, [mbYes], SLF);
          KilepClick(NIL);
        end;}
        //
        // A LED lámpa RGB értékeinek állítását visszajelzo üzenet
        //
        LEDRGB: // A LED lámpa RGB értéke  beállítás eredménye visszafelé
        begin
            ledbea(PELVSTA(Msg.LParam)^);
        end;
        //
        // A LED nyíl RGB értékeinek állítását
        // vagy irányának módosítását visszajelzo üzenet
        //
        NYIRGB: // A nyíl RGB értéke
        begin
            nyilbe(PELVSTA(Msg.LParam)^);
        end;
        //
        // A hangstring elindítását visszajelzo üzenet
        //
        HANGEL: // A hangstring állapota visszajött
        begin
            hanbea(PELVSTA(Msg.LParam)^);
        end;
        //
        // A menüindítás és státuszbekérés Timer üzenetének
        // visszajelzése
        //
        STATKV:
        begin
          //itt kapom vissza az értékeket
        end;
        LISVAL:
        begin
          //A lista_hívás adja vissza message-ben
        end;

      end;
    end
    else
    begin
       //ekkor hibaüzenet van
      case(i) of
        USBREM:
        begin
           // Az USB vezérlo eltávolításra került
        end;
        VALTIO:
        begin
          // Válaszvárás time-out következett be
        end;
        FELMHK:
        begin
          // Felmérés vége hibával
          //s := Format(ENDHIK, [Msg.LParam]);
        end;
        FELMHD:
        begin
          // Nincs egy darab sem hibakód (elvben sem lehet ilyen)
          //s := DARSEM;
        end;
        FELMDE:
        begin
          // A 16 és 64 bites darabszám nem egyforma
          //s := DARELT;
        end;
      end;

      //ha új felmérést akarok indítani, ez kell
      //SLDLL_Felmeres;
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

//hang beállítás folyamatának az eredménye (aktív, vagy nem?)
procedure TForm1.hanbea(const locsta: ELVSTA);
begin
    if(locsta.hanakt = 0) then
    begin
      //van-e még hang?
    end;
end;


//visszaadja a nyil értékeit beállítás után
procedure TForm1.nyilbe(const locsta: ELVSTA);
var
  irabal: Boolean;
  r, g, b: byte;
begin
    irabal := locsta.nyilal = 0;
    r := locsta.rgbert.rossze;
    g := locsta.rgbert.gossze;
    b := locsta.rgbert.bossze;
end;

//visszaadja a színt a ledlámpánál
procedure TForm1.ledbea(const locsta: ELVSTA);
var
  r, g, b:byte;
begin
    r := locsta.rgbert.rossze;  //0..255
    g := locsta.rgbert.gossze;
    b := locsta.rgbert.bossze;
end;

procedure TForm1.Programindtsa1Click(Sender: TObject);
begin
  if vanprogram then
  begin
    Label1.Caption := '';
    MyCounter := 0;
    sendMesgToDevices();
  end
  else
  begin
    Programbetltse1Click(Sender);
  end;
end;

procedure TForm1.Sorozatteszt1Click(Sender: TObject);
begin
   eszkozPanelLista(scrollbox1);
end;

procedure TForm1.jsorozathozzadsa1Click(Sender: TObject);
begin
  ujlista();
end;

procedure TForm1.FormShow(Sender: TObject);
begin
   CONTTOP := 0;
   try
     start();
   except
     showmessage('Eszköz inicializálási hiba, ellenõrizze az eszközök csatlakozóit!');
   end;
end;

procedure TForm1.save_selectted_DEVICE();
var
  CONTAINERX: TList;
  AcTPanel: TPanel;
  ActPanelContainer: TList;
begin
 try
// showmessage(inttostr(CONTAINER.Count));
  CONTAINERX := DEVICECONTAINERLIST[containerIndex - 1];
  if debug then showmessage('count container:' + inttostr(CONTAINERX.Count));

  CONTAINERX[elemIndex] := AKT_MENTETT_ESZKOZ;
  if debug then showmessage(inttostr(DEVICECONTAINERList.Count));

  DEVICECONTAINERList[ContainerIndex - 1] := CONTAINERX;

  if debug then Showmessage(inttostr(AKT_MENTETT_ESZKOZ.szin));

  if debug then Label1.Caption := inttostr(AKT_MENTETT_ESZKOZ.dtag);
 except
   showmessage('Elem beállítások mentése sikertelen, rossz index, vagy nem létezõ eszköz.');
 end;
end;

procedure TForm1.DEVICE_select_by_button(Sender: TObject);
var
  N, N7: string;
  DEV: deviceType;
  CONTAINER: TList;
begin
 try
  N := (Sender as TPanel).Name;
  N7 := copy(N, pos('_', N) + 1, length(N));
  containerIndex := strToInt(N7);
  elemIndex := (Sender as TPanel).Tag;
  if debug then showmessage(N7 + '/' + inttostr(elemIndex));

  CONTAINER := DEVICECONTAINERLIST[containerIndex  - 1];
  DEV := CONTAINER[elemIndex];

  if debug then Label1.Caption := inttostr(DEV.dtag);

  GIrany := DEV.irany;
  GColor := DEV.szin;
  GType := DEV.tipus;
  DEV_button_tag := (Sender as TPanel).Tag;
  AKT_MENTETT_ESZKOZ := DEV;

 except
  showmessage('Elem inicializálási hiba, hibás index, vagy nem létezõ eszköz. Ellenõrizze a csatlakozási pontokat');
 end;
end;

procedure TForm1.Panel2Click(Sender: TObject);
var
  N, N7: string;
  DEV: deviceType;
  CONTAINER: TList;
begin
  AKT_PANEL := Sender as TPanel;
  DEVICE_select_by_button(Sender);
  AKT_MENTETT_ESZKOZ.active := NOT AKT_MENTETT_ESZKOZ.active;
  save_selectted_DEVICE();

  {N := (Sender as TPanel).Name;
  N7 := copy(N, pos('_', N) + 1, length(N));
  containerINDEX := strToInt(N7);
  elemINDEX := (Sender as TPanel).Tag;
  if debug then showmessage(N7 + '/' + inttostr(elemINDEX));

  //DEVICEList;
  //DEVICEPANELLIST;

  //CONTAINERList.Add(DEVICEList);
  //DEVICECONTAINERLIST.Add();

  CONTAINER := DEVICECONTAINERLIST[containerINDEX - 1];
  DEV := CONTAINER[elemIndex];

  //if debug then showmessage(inttostr(DEV.dtag));

  if debug then showmessage('Aktív:' + booltostr(DEV.active));
  DEV.active := NOT DEV.active;
  if debug then showmessage('Aktív:' + booltostr(DEV.active));

  CONTAINER[elemINdex] := DEV;
  CONTAINERLIST[containerINDEX - 1] := CONTAINER;}

  //showmessage((Sender as TPanel).Caption);

  if ((Sender as TPanel).BevelOuter = bvRaised) then
  begin
    (Sender as TPanel).BevelOuter := bvLowered;
//    (Sender as TPanel).Color := clRed;
//    (Sender as TPanel).Font.Color := clWhite;
    (Sender as TPanel).PopupMenu := PopupMenu1;
    AKT_PANEl.BevelWidth := 1;
  end
  else
  begin
//    (Sender as TPanel).Color := clBtnFace;
    (Sender as TPanel).BevelOuter := bvRaised;
//    (Sender as TPanel).Font.Color := clBlack;
    (Sender as TPanel).PopupMenu := nil;
    AKT_PANEl.BevelWidth := 1;
  end;

end;

procedure TForm1.Start1Click(Sender: TObject);
var
  r: integer;
begin
  r := SLDLL_felmeres();
  label1.Caption := inttostr(r);
end;

procedure TForm1.Belltsok1Click(Sender: TObject);
var
  Caption_type: integer;
begin
if AKT_MENTETT_ESZKOZ <> nil then
begin
  if (AKT_MENTETT_ESZKOZ.tipus = 1) or (AKT_MENTETT_ESZKOZ.tipus = 2) then
  begin
    form2.showmodal();
  end
  else
    form3.showmodal();
  begin

  end;
  save_selectted_DEVICE();
  if (AKT_MENTETT_ESZKOZ.tipus = 1) or (AKT_MENTETT_ESZKOZ.tipus = 2) then
  begin
    AKT_PANEL.Color := lightColor;
  end
  else
  begin
   AKT_PANEL.Color := clBtnFace;
  end;

  Caption_type := AKT_MENTETT_ESZKOZ.tipus;
  case AKT_MENTETT_ESZKOZ.irany of
    0: AKT_PANEL.Caption := '<>';
    1: AKT_PANEL.Caption := '<';
    2: AKT_PANEL.Caption := '>';
    3: AKT_PANEL.Caption := '<>';
  end;
  if Caption_type = 3 then AKT_PANEL.Caption := 'H';
end;
end;

procedure TForm1.Programmentse1Click(Sender: TObject);
begin
  svaePRG();
end;

procedure TForm1.Programbetltse1Click(Sender: TObject);
var
  i: integer;
  p: TPanel;
begin
 try
  if openDialog1.Execute then
  begin
    for i := 0 to CONTAINERList.Count - 1 do
    begin
      p := CONTAINERList[i];
      p.Free();
    end;
    CONTTOP := 0;

    {panelek listája}  CONTAINERList.Free();
    {eszközök konténere} DEVICECONTAINERLIST.Free();

    {eszközök listája} DEVICEList.Free();
    {panelek listája}  DEVICEPANELLIST.Free();


    CONTAINERList := TList.Create();
    DEVICECONTAINERLIST := TList.Create();

    LISTADB := 0;
    listbox1.Items.LoadFromFile(openDialog1.FileName); //(ExtractFilePath(ParamStr(0)) + PROGRAMFILENAME);
    SLprogram := TStringList.Create();
    SLprogram.LoadFromFile(openDialog1.FileName); //(ExtractFilePath(ParamStr(0)) + PROGRAMFILENAME);
    ROUNDNUMBER := SLprogram.Count;
    vanprogram := true;
    addProgramPanels(SLprogram);
  end;
 except
   showmessage('Hibás, vagy sérült src file.');
 end;
end;

procedure TForm1.Feladatsorszerkesztse1Click(Sender: TObject);
begin
    Pagecontrol1.ActivePageIndex := 0;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    CONTAINERList := TList.Create();
    DEVICECONTAINERLIST := TList.Create();
end;

procedure TForm1.Panel2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  pt : TPoint;
begin
  if (Button = mbRight) then
  begin
   //if AKT_MENTETT_ESZKOZ <> nil then
   //begin
    AKT_PANEL := (Sender as TPanel);
    DEVICE_select_by_button(Sender);
    AKT_MENTETT_ESZKOZ.active := true; //NOT AKT_MENTETT_ESZKOZ.active;
    save_selectted_DEVICE();
    showmessage('itt');
{   if ((Sender as TPanel).BevelOuter = bvRaised) then
   begin
     (Sender as TPanel).BevelOuter := bvLowered;
     //(Sender as TPanel).Color := clRed;
     (Sender as TPanel).Font.Color := clWhite;
     (Sender as TPanel).PopupMenu := PopupMenu1;
   end
   else
   begin
     (Sender as TPanel).Color := clBtnFace;
     (Sender as TPanel).BevelOuter := bvRaised;
     //(Sender as TPanel).Font.Color := clBlack;
     (Sender as TPanel).PopupMenu := nil;
   end;}
   //end;
     //popupmenu1.OnPopup((Sender as Tpanel));
     //((Sender as TPanel).Left + 10,
     //                    (Sender as TPanel).Top + 10);
    pt.x := TButton(Sender).Left + 1;
    pt.y := TButton(Sender).Top + TButton(Sender).Height + 1;
    pt := Self.ClientToScreen( pt );
    PopupMenu1.popup( pt.x, pt.y );


  end;

end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  SLInterval := TrackBar1.Position;
end;

end.
