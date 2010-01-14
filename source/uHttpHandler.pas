unit uHttpHandler;

interface

uses
  uTcpHandler,
  IdExplicitTLSClientServerBase, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHttp, IdMultipartFormData;

type
  { // PHP CODE
    <?
    $uploadDir = "uploads/";
    $tmpAttachPath = $_FILES['attach']['tmp_name'];
    $attachPath = $uploadDir.$_FILES['attach']['name'];

    if(move_uploaded_file($tmpAttachPath, $attachPath))
        echo "OK";
    else
        echo $_FILES['attach']['error'];
    ?>
  }
  THttpHandler = class(TDefaultTcpHandler, ITcpHandler)
  private
    fUploadUrl: String;
    fFileFieldName: String;
    fHttp: TIdHttp;

    fWorkMaxCount: Integer;
  public
    constructor Create(uploadUrl: String; fileFieldName: String);
    destructor Destroy; override;
    procedure SendFile(localFile: TTcpLocalFile); override;
    
    procedure OnWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Integer);
    procedure OnWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Integer);
    procedure OnWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
  end;

implementation

{ THttpHandler }

constructor THttpHandler.Create(uploadUrl: String; fileFieldName: String);
begin
  fHttp:= TIdHTTP.Create(nil);
  fHttp.OnWorkBegin:= OnWorkBegin;
  fHttp.OnWork:= OnWork;
  fHttp.OnWorkEnd:= OnWorkEnd;
  
  fUploadUrl:= uploadUrl;
  fFileFieldName:= fileFieldName;
end;


destructor THttpHandler.Destroy;
begin
  try
    if fHttp.Connected then fHttp.Disconnect;
  finally
    fHttp.Free;
  end;
  inherited;
end;

procedure THttpHandler.OnWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Integer);
begin
  if (fWorkMaxCount > 0) and Assigned(fOnSendStream) then
    fOnSendStream(fWorkMaxCount, AWorkCount);
end;

procedure THttpHandler.OnWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Integer);
begin
  fWorkMaxCount:= AWorkCountMax;
end;

procedure THttpHandler.OnWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  fWorkMaxCount:= 0;
end;

procedure THttpHandler.SendFile(localFile: TTcpLocalFile);
var
  multiPart: TidMultiPartFormDataStream;
begin
  multiPart:= TidMultiPartFormDataStream.Create;
  try
    fHttp.Request.ContentType := multiPart.RequestContentType;
    multiPart.AddFormField('MAX_FILE_SIZE', '100000000000');
    multiPart.AddFile(fFileFieldName, localFile.fullPath, 'application/octet-stream');
    multiPart.Position:= 0;
    fHttp.Post(fUploadUrl, multiPart);
  finally
    multiPart.Free;
  end;
end;

end.
