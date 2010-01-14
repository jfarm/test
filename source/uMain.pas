unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, RscmDataAccess, RscmControls,
  VirtualTrees, uTcpHandler;

type
  // 주석
  TForm1 = class(TForm)
    rs: TRscmRecordSet;
    db: TRscmDataBridge;
    Panel1: TPanel;
    Panel2: TPanel;
    pbTotal: TProgressBar;
    memoLog: TMemo;
    vst: TVirtualStringTree;
    Panel3: TPanel;
    btnHttp: TButton;
    btnFtp: TButton;
    btnOpenDialog: TButton;
    pbEach: TProgressBar;
    procedure btnOpenDialogClick(Sender: TObject);
    procedure btnFtpClick(Sender: TObject);
    procedure btnHttpClick(Sender: TObject);
  private
    fStartTime: TDateTime;
    fEndTime: TDateTime;
    function timeDiff(s, e: TDateTime): String;
    function createOpenDialog(opts: TOpenOptions): TOpenDialog;
    procedure sendFile(tcpHandler: ITcpHandler);
    procedure OnSendStream(totalCount: Integer; workCount: Integer);
    procedure OnBeforeSend(index: Integer; localFile: TTcpLocalFile; success: Boolean);
    procedure OnAfterSend(index: Integer; localFile: TTcpLocalFile;  success: Boolean);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses uFtpHandler, uHttpHandler;

{$R *.dfm}

procedure TForm1.btnFtpClick(Sender: TObject);
var
  handler: TFtpHandler;
begin
  handler:= TFtpHandler.Create('192.168.188.130', 21, 'leehj', 'gg');
  handler.changeWorkingDir('test');
  handler.OnBeforeSend:= OnBeforeSend;
  handler.OnAfterSend:= OnAfterSend;
  sendFile(handler);
end;

procedure TForm1.btnHttpClick(Sender: TObject);
var
  handler: THttpHandler;
begin
  handler:= THttpHandler.Create('http://192.168.188.130/~leehj/upload.php', 'attach');
  handler.OnBeforeSend:= OnBeforeSend;
  handler.OnAfterSend:= OnAfterSend;
  handler.OnSendStream:= OnSendStream;
  sendFile(handler);
end;

procedure TForm1.btnOpenDialogClick(Sender: TObject);
var
  I: Integer;
  dlg: TOpenDialog;
  sr : TSearchRec;
begin
  dlg:= createOpenDialog([ofAllowMultiSelect]);
  try
    if not dlg.Execute then Exit;
    if not db.Connected then db.Connected:= true;

    rs.BeginUpdate;
    if rs.Count > 0 then rs.Clear;
    for I := 0 to dlg.Files.Count - 1 do begin
      if FindFirst(dlg.Files[i], faAnyFile, sr) <> 0 then Continue;

      with rs.AddItem(nil, Format('/%d', [i])) do begin
        ColByName('NAME').Value:= dlg.Files[i];
        ColByName('SIZE').Value:= sr.Size;
      end;
    end;
    rs.EndUpdate;
  finally
    dlg.Free;
  end;
end;

function TForm1.createOpenDialog(opts: TOpenOptions): TOpenDialog;
begin
  Result:= TOpenDialog.Create(self);
  with Result do begin
    InitialDir := GetCurrentDir;
    Options := opts;
    Filter := 'All files|*.*';
    FilterIndex := 1;
  end;
end;

procedure TForm1.OnBeforeSend(index: Integer; localFile: TTcpLocalFile; success: Boolean);
begin
  fStartTime:= Now;
end;

procedure TForm1.OnSendStream(totalCount, workCount: Integer);
begin
  if pbEach.Position = 0 then begin
    pbEach.Max:= totalCount;
  end;

  pbEach.Position:= workCount;
  Application.ProcessMessages;
end;

procedure TForm1.OnAfterSend(index: Integer; localFile: TTcpLocalFile; success: Boolean);
  function BoolToStr(b: Boolean): String;
  begin
    if b then
      Result:= 'OK'
    else
      Result:= 'FAIL';
  end;
begin
  fEndTime:= Now;
  memoLog.Lines.Add(Format('%s - [%s: %s]', [
    localFile.fullPath, BoolToStr(success), timeDiff(fEndTime, fStartTime)]));
  pbTotal.StepBy(10);
  
  pbEach.Position:= 0;
end;

procedure TForm1.sendFile(tcpHandler: ITcpHandler);
var
  I: Integer;
  s: TDateTime;
  e: TDateTime;
begin
  if not Assigned(tcpHandler) then
    raise Exception.Create('tcpHandler 가 설정되지 않았습니다.');

  try
    for I := 0 to rs.Count - 1 do begin
      tcpHandler.addFile(TTcpLocalFile.Create(
        rs.Items[i].ColByName('NAME').AsString,
        rs.Items[i].ColByName('SIZE').AsInteger)
      );
    end;
    
    pbTotal.Max:= tcpHandler.getFileCount * 10;
    pbTotal.Position:= 0;
    s:= Now;
    tcpHandler.Send;
    e:= Now;
    memoLog.Lines.Add('TOTAL SPENT' + timeDiff(e, s));
    
  finally
    tcpHandler:= nil;
  end;
end;

function TForm1.timeDiff(s, e: TDateTime): String;
begin
  Result:= FormatDateTime('hh:nn:ss.zzz', e - s);
end;

end.
