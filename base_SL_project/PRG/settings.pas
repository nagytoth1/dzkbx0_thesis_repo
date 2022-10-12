unit settings;
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SLDLL, StdCtrls, Menus, ExtCtrls, Grids;

const
  PROGRAMFILENAME = 'program.src';
  UZESAJ = WM_USER + 0;
  c1 = 52845;
  c2 = 22719;

  //procedure setRound(roundNumber: integer);
  procedure setRounds();

var
  teststring: string;
  drb485: integer;
  dev485:DEVLIS;
  lista: LISTBL;
  devList: LISTBL;

  SLprogram: TStringList;
  programElements: TStringList;
  ROUNDNUMBER: integer = 0;
  ELEMENTNUMBER: integer;

  timerIntervall: integer = 1000;
  MyCounter: integer = 0;

procedure Split (const Delimiter: Char; Input: string; const Strings: TStrings) ;

implementation

procedure Split (const Delimiter: Char; Input: string; const Strings: TStrings) ;
begin
   Assert(Assigned(Strings));
   Strings.Clear;
   Strings.Delimiter := Delimiter;
   Strings.DelimitedText :=  '"' +
      StringReplace(Input, Delimiter, '"' + Delimiter + '"', [rfReplaceAll]) + '"' ;
end;
//Használata: Split('^', Forrás, Eredmény);


procedure setRounds();
var
  i: integer;
  elemszam: integer;
begin

  lista[0].azonos := dev485[0].azonos;
  lista[0].vilrgb.rossze := 20;
  lista[0].vilrgb.gossze := 0;
  lista[0].vilrgb.bossze := 0;
  devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  lista[1].azonos := dev485[1].azonos;
  lista[1].vilrgb.rossze := 20;
  lista[1].vilrgb.gossze := 0;
  lista[1].vilrgb.bossze := 0;
  devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  lista[2].azonos := dev485[2].azonos;
  lista[2].vilrgb.rossze := 20;
  lista[2].vilrgb.gossze := 0;
  lista[2].vilrgb.bossze := 0;
  devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  lista[3].azonos := dev485[3].azonos;
  lista[3].vilrgb.rossze := 20;
  lista[3].vilrgb.gossze := 0;
  lista[3].vilrgb.bossze := 0;
  devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  elemszam := 2;

  i := SLDLL_SetLista(elemszam, lista);
end;

end.

{   DEVSEL = packed record                                    // Az elemek azonosításának leírója
    azonos: Word;                                           // Az elem azonosítója a bitpárossal együtt    0     2
    idever: VERTAR;                                         // Az elem verzióleírója                       2     5
    produc: PChar;                                          // Az elem szöveges leírója                    7     4
    manufa: PChar;                                          // Az elem gyártó  leírója                    11     4
  end;                                                      // Az egész hossza                            15
  PDEVSEL = ^DEVSEL;

  DEVLIS = array of DEVSEL;
  PDEVLIS = ^DEVLIS;}

 //returns MD5 has for a file



{
procedure TForm1.Button2Click(Sender: TObject);
var
  i: integer;
  rgbert: HABASZ;
  //
  //  HABASZ = packed record                                    // Az RGB összetevõk leírása
  //  rossze: Byte;                                           // Az R összetevõ értéke                       0     1
  //  gossze: Byte;                                           // A G összetevõ értéke                        1     1
  //  bossze: Byte;                                           // A B összetevõ értéke                        2     1
  //end;                                                      // Az egész hossza                             3
  //
  jobrai: boolean;
  aktadr: word;
  hangdb: integer;
  hangtb: HANGLA;
  //{
  //HANGLE = packed record                                    // Egy hang leírása
  //  hangho: Word;                                           // A hang hossza milisec.-ben                  0     2
  //  hangso: Byte;                                           // A hang sorszáma (0..32)                     2     1
  //  hanger: Byte;                                           // A hang hangereje (0..63)                    3     1
  //end;                                                      // Az egész hossza                             4

  HANGLA = array [0..15] of HANGLE;                         // Hangleírók táblázata

begin
 jobrai := true; //jobbra
 //a kapott felmérési táblázatból egy cím, (aktadr, vagy ilyesmi) aktadr := xyz;

 rgbert.rossze := 0;
 rgbert.gossze := 0;
 rgbert.bossze := 0;

 aktadr := dev485[1].azonos;
 i := SLLDLL_LEDLampa(rgbert, aktadr);

 //aktadr := dev485[1].azonos;
 //i := SLLDLL_LEDLampa(rgbert, aktadr);

 //aktadr := dev485[2].azonos;
 //i := SLLDLL_LEDNyil(rgbert, jobrai, aktadr);

 //aktadr := dev485[2].azonos;
 //i := SLLDLL_Hangkuldes(hangdb, hangtb, aktadr);

end;
}
{

procedure TForm1.Button4Click(Sender: TObject);
var
  i: integer;
  elemszam: integer;
begin
  lista[0].azonos := dev485[0].azonos;
  lista[0].lamrgb.rossze := 255;
  lista[0].lamrgb.gossze := 0;
  lista[0].lamrgb.bossze := 0;

  lista[1].azonos := dev485[1].azonos;
  lista[1].lamrgb.rossze := 0;
  lista[1].lamrgb.gossze := 0;
  lista[1].lamrgb.bossze := 0;

  elemszam := 2;

  i := SLDLL_SetLista(elemszam, lista);
end;
}

{
procedure TForm1.Nyltesztelse1Click(Sender: TObject);
begin
 //aktadr := dev485[1].azonos;
 //i := SLLDLL_LEDLampa(rgbert, aktadr);
 //aktadr := dev485[2].azonos;
 //i := SLLDLL_LEDNyil(rgbert, jobrai, aktadr);

end;
}


{
procedure TForm1.Ledlmpatesztelse1Click(Sender: TObject);
var
  i: integer;
  rgbert: HABASZ;
  jobrai: boolean;
  aktadr: word;
  hangdb: integer;
  hangtb: HANGLA;
begin
 jobrai := true; //jobbra
 //a kapott felmérési táblázatból egy cím, (aktadr, vagy ilyesmi) aktadr := xyz;

 rgbert.rossze := 0;
 rgbert.gossze := 0;
 rgbert.bossze := 0;

 aktadr := dev485[1].azonos;
 i := SLLDLL_LEDLampa(rgbert, aktadr);

 //aktadr := dev485[1].azonos;
 //i := SLLDLL_LEDLampa(rgbert, aktadr);

 //aktadr := dev485[2].azonos;
 //i := SLLDLL_LEDNyil(rgbert, jobrai, aktadr);

 //aktadr := dev485[2].azonos;
 //i := SLLDLL_Hangkuldes(hangdb, hangtb, aktadr);

end;
}

{
//visszaadja a színt a ledlámpánál
procedure TForm1.ledbea(const locsta: ELVSTA);
var
  r, g, b:byte;
begin
    r := locsta.rgbert.rossze;  //0..255
    g := locsta.rgbert.gossze;
    b := locsta.rgbert.bossze;
end;
}

{
//hang beállítás folyamatának az eredménye (aktív, vagy nem?)
procedure TForm1.hanbea(const locsta: ELVSTA);
begin
    if(locsta.hanakt = 0) then
    begin
      //van-e még hang?
    end;
end;
}


{
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

}
