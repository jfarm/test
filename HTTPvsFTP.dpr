program HTTPvsFTP;

uses
  Forms,
  uMain in 'uMain.pas' {Form1},
  uTcpHandler in 'uTcpHandler.pas',
  uFtpHandler in 'uFtpHandler.pas',
  uHttpHandler in 'uHttpHandler.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
