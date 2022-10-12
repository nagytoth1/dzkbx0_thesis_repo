unit globals;

interface

uses

  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Buttons, ExtCtrls, StdCtrls;

const
  BUTTONWIDTH = 70;
  BUTTONHEIGHT = 60;
  debug = false;

type
  DeviceType = class
    devlistAzonosito: byte;
    active: boolean;
    dtag: integer;
    dtype: byte;
    tipus: integer; //A GUI t�pus
    szin: TColor;
    irany: integer;
    hangszin: integer;
    hangero: byte;
    hanghossz: integer;
    idotartam: integer;
    r, g, b: integer;
    constructor create(dtag: integer; dtype: integer = 0) overload;
    procedure setAttr(szin: integer = 0; irany: integer = 0; hangmagassag : integer = 0; idotartam: integer = 0);
  end;

var

   SLinterval: integer = 1000;

   vanprogram: boolean = false;

   {panelek list�ja}  CONTAINERList: TList;
   {eszk�z�k kont�nere} DEVICECONTAINERLIST: TList;
   {eszk�z�k list�ja} DEVICEList: TList;
   {panelek list�ja}  DEVICEPANELLIST: TList;
   {program sorok list�ja a ment�shez} programSorok: TStringList;

   //A kiv�lasztott eszk�z attrib�tumai a be�ll�t�si panel inicializ�l�s�hoz
   GIrany: integer = 0;
   GColor: TColor = CLRed;
   DEV_button_tag: integer = 0;
   GType: integer = 1;
   AKT_MENTETT_ESZKOZ: deviceType;
   AKT_PANEL: TPanel;


   //A kiv�lasztott eszk�z list�ja �s az azt tartalmaz� kont�nerlista indexe a ment�shez �s a
   //bet�lt�shez a be�ll�t�sok haszn�latakor
   containerIndex: integer = 0;
   elemIndex: integer = 0;

implementation

constructor deviceType.create(dtag: integer; dtype: integer = 0) overload;
begin
   self.dtag := dtag;
   self.dtype := dtype;
end;

procedure deviceType.setAttr(szin: integer = 0; irany: integer = 0; hangmagassag: integer = 0;
idotartam: integer = 0);
begin
  self.irany := irany;
  self.szin := szin;
  //self.hangszin := hangszin;
  //self.hanghossz := hanghossz;
  //self.hangmagassag := hangmagassag;
  self.idotartam := idotartam;
end;

end.
