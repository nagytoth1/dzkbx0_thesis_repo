unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Buttons, ExtCtrls, StdCtrls, globals;

type
  TForm2 = class(TForm)
    Panel1: TPanel;
    TrackBar1: TTrackBar;
    SpeedButton3: TSpeedButton;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    colorpanel: TPanel;
    Panel4: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    procedure TrackBar1Change(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Mainclick(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure Panel4Click(Sender: TObject);
    procedure Panel4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel4MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  lightColor: TColor;

implementation

{$R *.dfm}

procedure TForm2.Mainclick(Sender: TObject);
begin
{  if ((Sender as TPanel).BevelOuter = bvRaised) then
  begin
    (Sender as TPanel).BevelOuter := bvLowered;
    (Sender as TPanel).Color := lightColor;
    (Sender as TPanel).Tag := 1;
    //(Sender as TPanel).Font.Color := clWhite;
  end
  else
  begin
    (Sender as TPanel).BevelOuter := bvRaised;
    (Sender as TPanel).Color := clBtnFace;
    (Sender as TPanel).Tag := 0;
    //(Sender as TPanel).Font.Color := clBlack;
  end;

  if (Panel2.Tag = 1) and (Panel3.Tag = 1) then
  begin
     AKT_MENTETT_ESZKOZ.irany := 3;
  end;

  if (Panel2.Tag = 1) and (Panel3.Tag = 0) then
  begin
     AKT_MENTETT_ESZKOZ.irany := 1;
  end;

  if (Panel2.Tag = 0) and (Panel3.Tag = 1) then
  begin
     AKT_MENTETT_ESZKOZ.irany := 2;
  end;

  if (Panel2.Tag = 0) and (Panel3.Tag = 0) then
  begin
     AKT_MENTETT_ESZKOZ.irany := 0;
  end;
}
  AKT_MENTETT_ESZKOZ.active := true;

end;

procedure TForm2.TrackBar1Change(Sender: TObject);
begin
  lightColor :=  TrackBar1.Position
              + (trackbar2.Position SHL 8)
              + (trackbar3.Position SHL 16);

  case AKT_MENTETT_ESZKOZ.irany of
     1: Panel2.Color := lightColor;
     2: Panel3.Color := lightColor;
     3: Panel4.Color := lightColor;
  end;
     //0: Panel3.Color := lightColor;

  colorpanel.Color := lightColor;

  AKT_MENTETT_ESZKOZ.r := TrackBar1.Position;
  AKT_MENTETT_ESZKOZ.g := TrackBar2.Position;
  AKT_MENTETT_ESZKOZ.b := TrackBar3.Position;

  gColor := lightColor;
  AKT_MENTETT_ESZKOZ.szin := lightColor;
end;

procedure TForm2.Panel3Click(Sender: TObject);
begin
  AKT_MENTETT_ESZKOZ.active := true;
  AKT_MENTETT_ESZKOZ.irany := 2;
  Panel3.Color := lightColor;
  Panel2.Color := clBtnFace;
  Panel4.Color := clBtnFace;
end;

procedure TForm2.FormShow(Sender: TObject);
var
  a, b, c: integer;
begin
   lightColor := AKT_MENTETT_ESZKOZ.szin;
   GColor := AKT_MENTETT_ESZKOZ.szin;
   AKT_MENTETT_ESZKOZ.active := true;
   a := lightColor;
   b := lightColor;
   c := lightColor;

   //showmessage(inttostr(((lightColor SHR 8) AND $FF)));

   TrackBar1.Position := (a AND $FF);
   TrackBar2.Position := ((b SHR 8) AND $FF) ;
   TrackBar3.Position := ((c SHR 16) AND $FF);

   colorpanel.Color := lightColor;

   case AKT_MENTETT_ESZKOZ.irany of
     1: begin  //bal
          //Panel2.BevelOuter := bvLowered;
          //Panel3.BevelOuter := bvRaised;
          //Panel4.BevelOuter := bvRaised;
          Panel3.Color := clBtnFace;
          Panel2.Color := AKT_MENTETT_ESZKOZ.szin;
          Panel4.Color := clBtnFace;
        end;
     2: begin   //jobb
          //Panel2.BevelOuter := bvRaised;
          //Panel3.BevelOuter := bvLowered;
          //Panel4.BevelOuter := bvRaised;
          Panel2.Color := clBtnFace;
          Panel3.Color := AKT_MENTETT_ESZKOZ.szin;
          Panel4.Color := clBtnFace;
        end;
     3: begin  //mindkettõ
          //Panel2.BevelOuter := bvRaised;
          //Panel3.BevelOuter := bvRaised;
          //Panel4.BevelOuter := bvLowered;
          Panel2.Color := clBtnFace;
          Panel4.Color := AKT_MENTETT_ESZKOZ.szin;
          Panel3.Color := clBtnFace;
        end;
     0: begin  //egyik sem
          //Panel2.BevelOuter := bvRaised;
          //Panel3.BevelOuter := bvRaised;
          //Panel4.BevelOuter := bvRaised;
          Panel2.Color := clBtnFace;
          Panel3.Color := clBtnFace;
          Panel4.Color := clBtnFace;
        end;
   end;
end;

procedure TForm2.Panel2Click(Sender: TObject);
begin
  AKT_MENTETT_ESZKOZ.active := true;
  AKT_MENTETT_ESZKOZ.irany := 1;
  Panel2.Color := lightColor;
  Panel3.Color := clBtnFace;
  Panel4.Color := clBtnFace;
end;

procedure TForm2.SpeedButton3Click(Sender: TObject);
begin
  if debug then showmessage(inttostr(AKT_MENTETT_ESZKOZ.irany));
  Form2.Close();
end;

procedure TForm2.Panel4Click(Sender: TObject);
begin
  AKT_MENTETT_ESZKOZ.active := true;
  AKT_MENTETT_ESZKOZ.irany := 3;
  Panel4.Color := lightColor;
  Panel2.Color := clBtnFace;
  Panel3.Color := clBtnFace;
end;

procedure TForm2.Panel4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  (Sender as TPanel).BevelOuter := bvLowered;
end;

procedure TForm2.Panel4MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  (Sender as TPanel).BevelOuter := bvRaised;
end;

end.
