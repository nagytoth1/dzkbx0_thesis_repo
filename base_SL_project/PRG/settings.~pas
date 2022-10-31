unit settings;
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SLDLL, StdCtrls, Menus, ExtCtrls, Grids, StrUtils;

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

//Használata: Split('^', Forrás, Eredmény);
procedure Split (const Delimiter: Char; Input: string; const Strings: TStrings) ;
begin
   Assert(Assigned(Strings));
   Strings.Clear;
   Strings.Delimiter := Delimiter;
   Strings.DelimitedText :=  '"' +
      StringReplace(Input, Delimiter, '"' + Delimiter + '"', [rfReplaceAll]) + '"' ;
end;

procedure setRounds();
var
  //i: integer;
  elemszam: integer;
begin

  lista[0].azonos := dev485[0].azonos;
  lista[0].vilrgb.rossze := 20;
  lista[0].vilrgb.gossze := 0;
  lista[0].vilrgb.bossze := 0;
  //devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  lista[1].azonos := dev485[1].azonos;
  lista[1].vilrgb.rossze := 20;
  lista[1].vilrgb.gossze := 0;
  lista[1].vilrgb.bossze := 0;
  //devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  lista[2].azonos := dev485[2].azonos;
  lista[2].vilrgb.rossze := 20;
  lista[2].vilrgb.gossze := 0;
  lista[2].vilrgb.bossze := 0;
  //devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  lista[3].azonos := dev485[3].azonos;
  lista[3].vilrgb.rossze := 20;
  lista[3].vilrgb.gossze := 0;
  lista[3].vilrgb.bossze := 0;
  //devList[i].nilmeg := 0; // 1 //2 strToBool(elements[3]);

  elemszam := 2;

  SLDLL_SetLista(elemszam, lista);
end;
end.
