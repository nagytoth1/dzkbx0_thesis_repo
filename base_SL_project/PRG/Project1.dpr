program Project1;

{%ToDo 'Project1.todo'}

uses
  Forms,
  prg in 'prg.pas' {Form1},
  settings in 'settings.pas',
  Unit2 in 'Unit2.pas' {Form2},
  globals in 'globals.pas',
  Unit3 in 'Unit3.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
