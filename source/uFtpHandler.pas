unit uFtpHandler;

interface

uses
  Classes, uTcpHandler,
  IdExplicitTLSClientServerBase, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdFTP;

type
  // ftp handler
  TFtpHandler = class(TDefaultTcpHandler, ITcpHandler)
  private
    fFtp: TIdFTP;
  public
    constructor Create(host: String; port: Integer; uid, pwd: String);
    destructor Destroy; override;
    procedure ChangeWorkingDir(dir: String);
    procedure SendFile(localFile: TTcpLocalFile); override;
  end;


implementation

{ TCar }

procedure TFtpHandler.ChangeWorkingDir(dir: String);
begin
  if fFtp.Connected then
    fFtp.ChangeDir(dir);
end;

constructor TFtpHandler.Create(host: String; port: Integer; uid, pwd: String);
begin
  fFtp:= TIdFTP.Create(nil);
  fFtp.Host:= host;
  fFtp.Port:= port;
  fFtp.Username:= uid;
  fFtp.Password:= pwd;
  fFtp.Connect;
end;

destructor TFtpHandler.Destroy;
begin
  try
    if fFtp.Connected then fFtp.Quit;
  finally
    fFtp.Free;
  end;
  inherited;
end;

procedure TFtpHandler.SendFile(localFile: TTcpLocalFile);
var
  stream: TStream;
begin
  stream:= localFile.CreateStream();
  try
    fFtp.Put(stream, localFile.name);
  finally
    stream.Free;
  end;
end;

end.
