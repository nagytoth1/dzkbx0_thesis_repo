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
    tipus: integer; //A GUI típus
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

   {panelek listája}  CONTAINERList: TList;
   {eszközök konténere} DEVICECONTAINERLIST: TList;
   {eszközök listája} DEVICEList: TList;
   {panelek listája}  DEVICEPANELLIST: TList;
   {program sorok listája a mentéshez} programSorok: TStringList;

   //A kiválasztott eszköz attribútumai a beállítási panel inicializálásához
   GIrany: integer = 0;
   GColor: TColor = CLRed;
   DEV_button_tag: integer = 0;
   GType: integer = 1;
   AKT_MENTETT_ESZKOZ: deviceType;
   AKT_PANEL: TPanel;


   //A kiválasztott eszköz listája és az azt tartalmazó konténerlista indexe a mentéshez és a
   //betöltéshez a beállítások használatakor
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
