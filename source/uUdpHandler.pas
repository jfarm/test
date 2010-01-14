unit uTcpHandler;

interface

uses
  Forms, Classes, SysUtils;

type
  TTcpLocalFile = class;
  TTcpLocalFileList = class;

  TTcpSndNotify = procedure (index: Integer; localFile: TTcpLocalFile; success: Boolean) of object;
  TTcpSndStreamNotify = procedure (totalCount: Integer; workCount: Integer) of object;
  ITcpHandler = Interface(IInterface)
    procedure Send;
    procedure addFile(localFile: TTcpLocalFile);
    function GetFileCount: Integer;
  end;
  // not default handler
  TDefaultTcpHandler = Class(TInterfacedObject, ITcpHandler)
  private
    fLocalFileList: TTcpLocalFileList;
    function GetLocalFile(index: Integer): TTcpLocalFile;
  protected
    fOnBeforeSend: TTcpSndNotify;
    fOnAfterSend: TTcpSndNotify;
    fOnSendStream: TTcpSndStreamNotify;
    property LocalFiles[index: Integer]: TTcpLocalFile read GetLocalFile;
  public
    destructor Destroy; override;
    procedure Send;
    procedure SendFile(localFile: TTcpLocalFile); virtual; abstract;
    procedure addFile(localFile: TTcpLocalFile);
    function GetFileCount: Integer;
    property OnBeforeSend: TTcpSndNotify read fOnBeforeSend write fOnBeforeSend;
    property OnAfterSend: TTcpSndNotify read fOnAfterSend write fOnAfterSend;
    property OnSendStream: TTcpSndStreamNotify read fOnSendStream write fOnSendStream;
  End;

  TTcpLocalFile = class
  private
    fFullPath: String;
    fSize: Int64;
    function GetName: String;
  public
    constructor Create(fullPath: String; size: Int64);
    function CreateStream(mode: Word): TFileStream;  overload;
    function CreateStream(): TFileStream; overload;
    property fullPath: String read fFullPath;
    property name: String read GetName;
    property size: Int64 read fSize;
  end;

  TTcpLocalFileList = class(TList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    function GetItem(Index: Integer): TTcpLocalFile;
    procedure SetItem(Index: Integer; AObject: TTcpLocalFile);
  public
    function Remove(AObject: TTcpLocalFile): Integer;
    property Items[Index: Integer]: TTcpLocalFile read GetItem write SetItem; default;
  end;
implementation

{ TDefaultTcpHandler }

procedure TDefaultTcpHandler.addFile(localFile: TTcpLocalFile);
begin
  if not Assigned(fLocalFileList) then
    fLocalFileList:= TTcpLocalFileList.Create;
  fLocalFileList.Add(localFile);
end;

destructor TDefaultTcpHandler.Destroy;
begin
  if Assigned(fLocalFileList) then
    fLocalFileList.Free;
  inherited;
end;

function TDefaultTcpHandler.GetFileCount: Integer;
begin
  if not Assigned(fLocalFileList) then
    Result:= 0
  else
    Result:= fLocalFileList.Count;
end;

function TDefaultTcpHandler.GetLocalFile(index: Integer): TTcpLocalFile;
begin
  if not Assigned(fLocalFileList) then
    raise Exception.Create('추가된 파일이 없습니다.');
  if (index < 0) or (fLocalFileList.Count <= index) then
    raise Exception.Create(Format('index %d는 추가된 파일 목록 범위를 벗어납니다.', [index]));

  Result:= fLocalFileList[index];
end;

procedure TDefaultTcpHandler.Send;
var
  I: Integer;
  success: Boolean;
begin
  if not Assigned(fLocalFileList) then
    raise Exception.Create('전송할 파일이 없습니다.');

  for I := 0 to fLocalFileList.Count - 1 do begin
    if Assigned(fOnBeforeSend) then fOnBeforeSend(i, fLocalFileList[i], true);
    try
      SendFile(fLocalFileList[i]);
      success:= true;
    except
      success:= false;
    end;
    if Assigned(fOnAfterSend) then fOnAfterSend(i, fLocalFileList[i], success);
    Application.ProcessMessages;
  end;
end;

{ TSimpleTcpLocalFile }
constructor TTcpLocalFile.Create(fullPath: String; size: Int64);
begin
  fFullPath:= fullPath;
  fSize:= size;
end;

function TTcpLocalFile.CreateStream(mode: Word): TFileStream;
begin
  Result:= TFileStream.Create(fFullPath, mode);
end;

function TTcpLocalFile.CreateStream: TFileStream;
begin
  Result:= CreateStream(fmOpenRead);
end;

function TTcpLocalFile.GetName: String;
begin
  Result:= ExtractFileName(fFullPath);
end;

{ TSimpleTcpLocalFileList }

function TTcpLocalFileList.GetItem(Index: Integer): TTcpLocalFile;
begin
  Result := inherited Items[Index];
end;

procedure TTcpLocalFileList.Notify(Ptr: Pointer;
  Action: TListNotification);
begin
  if Action = lnDeleted then
    TTcpLocalFile(Ptr).Free;
  inherited Notify(Ptr, Action);
end;

function TTcpLocalFileList.Remove(AObject: TTcpLocalFile): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TTcpLocalFileList.SetItem(Index: Integer;
  AObject: TTcpLocalFile);
begin
  inherited Items[Index] := AObject;
end;

end.
