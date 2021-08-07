program Parse;

uses
  Vcl.Forms,
  Thread in 'Thread.pas',
  MainFrm in 'MainFrm.pas' {Main};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
