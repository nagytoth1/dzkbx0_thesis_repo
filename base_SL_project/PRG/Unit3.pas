unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, globals;

type
  TForm3 = class(TForm)
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.TrackBar1Change(Sender: TObject);
begin
    //AKT_MENTETT_ESZKOZ.hangero := TrackBar1.Position;
end;

procedure TForm3.TrackBar2Change(Sender: TObject);
begin
    //AKT_MENTETT_ESZKOZ.hangszin := TrackBar2.Position;
end;

procedure TForm3.TrackBar3Change(Sender: TObject);
begin
    //AKT_MENTETT_ESZKOZ.hanghossz := TrackBar3.Position;
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
  AKT_MENTETT_ESZKOZ.hangero := trackBar1.Position;
    AKT_MENTETT_ESZKOZ.hangszin := trackBar2.Position;
      AKT_MENTETT_ESZKOZ.hanghossz := trackBar3.Position;
  form3.Close();
end;

procedure TForm3.FormShow(Sender: TObject);
begin
   AKT_MENTETT_ESZKOZ.active := true;
   trackBar1.Position := AKT_MENTETT_ESZKOZ.hangero;
   trackBar2.Position := AKT_MENTETT_ESZKOZ.hangszin;
   trackBar3.Position := AKT_MENTETT_ESZKOZ.hanghossz;

   

end;

end.
