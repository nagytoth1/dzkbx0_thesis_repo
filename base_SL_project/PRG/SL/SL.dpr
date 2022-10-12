program SL;

uses
  Windows, Forms,
  SLO in 'SLO.pas' {SLF};

{$R *.RES}

begin
  muthnd := CreateMutex(NIL, False, SLRUNM);
  if(muthnd <> 0) then
  begin
    if(GetLastError = NO_ERROR) then
    begin
      Application.Initialize;
      Application.CreateForm(TSLF, SLF);
      Application.Run;
    end
    else
    begin
      sajuze(MARFUT, mtError, [mbOK], NIL);
    end;
    CloseHandle(muthnd);
  end;
end.
