unit uBaseForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ActnList,
  ExtCtrls, IniFiles, jsonparser, fpjson, fphttpclient, umessageform, process,RegExpr;

type

  { TBaseForm }

  TUserMenu = record
    MenuIcon: string;
    MenuName: string;
    MenuLabel: string;
    MenuaccessId: integer;
    Description: string;
    MenuUrl: string;
    ParentId : string;
    SortOrder: integer;
  end;

  TUser = record
    UseraccessId : Integer;
    UserName: string;
    RealName: string;
    Password: string;
    Email: string;
    Phoneno: string;
    LanguageId: integer;
    ThemeId: integer;
    IsOnline: integer;
    authkey: string;
    wallpaper: string;
    languagename: string;
    themename: string;
    RecordStatus: integer;
    menuitems: array of TUserMenu;
    userfav: array of TUserMenu;
  end;

  THost = class
    Server: string;
    Title: string;
    Company: string;
    Serial: string;
    User: string;
    Password: string;
    Icon: string;
    Wallpaper: string;
    Timeout: integer;
    HostIPGeo: string;
    HostIPExt: string;
  end;

  TBaseForm = class(TForm)
    TrayMainForm: TTrayIcon;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public
    Host                  : THost;
    Pic                   : TPicture;
    FpClient              : TfpHttpClient;
    SlBody,RowsData       : TStringList;
    User                  : TUser;
    JsData                : TJSONData;
    JsObject              : TJSONObject;
    JsArray               : TJSONArray;
    Parser                : TJSONParser;
    JsEnum                : TJSONEnum;
    IsError,Total         : integer;
    Msg                   : string;
    FileIni               : TIniFile;

  protected
    LResponse: String;
    procedure ShowResponse();
    procedure GetDataAPI(url:string);
    procedure ShowMessageAPI(messages:string);
    function GetMessageAPI(messages:string):string;
    procedure GetSimpleDataList(url,idfield,namefield:string);
    procedure DlgMessage(title, messages:string; msgtype:TMsgDlgType);
    function GetExternalIPAddress: string;
    function GetIpAddrList: string;
    function GetDataUser: string;
  end;

var
  BaseForm              : TBaseForm;
  i,j                   : integer;

const
  HeaderMsg = 'Capella ERP Indonesia';

implementation

{$R *.lfm}

{ TBaseForm }

procedure TBaseForm.FormActivate(Sender: TObject);
begin
  //
end;

procedure TBaseForm.FormCreate(Sender: TObject);
begin
    FileIni:= TIniFile.Create('caposwin.ini');
    fpClient:= TfpHttpClient.Create(nil);
    Host:= THost.Create;
    Pic:= TPicture.Create;
    slBody:= TStringList.Create;
    try
      Host.title:= FileIni.ReadString('MAIN','title','');
      Host.company:= FileIni.ReadString('MAIN','company','');
      Host.serial:= FileIni.ReadString('MAIN','serial','');
      Host.icon:= FileIni.ReadString('MAIN','icon','');
      Host.wallpaper:= FileIni.ReadString('MAIN','wallpaper','');
      Host.server:= FileIni.ReadString('API','host','localhost');
      Host.user:= FileIni.ReadString('API','user','');
      Host.password:= FileIni.ReadString('API','password','');
      Host.timeout:= FileIni.ReadInteger('API','timeout',0);
      Host.HostIPExt:= FileIni.ReadString('API','hostipext','');
      Host.HostIPGeo:= FileIni.ReadString('API','hostipgeo','');
      fpClient.AllowRedirect:=true;
      fpClient.IOTimeout:= Host.timeout;
    finally
     FreeAndNil(FileIni);
    end;
end;

procedure TBaseForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(slBody);
  FreeAndNil(fpClient);
  FreeAndNil(Host);
  FreeAndNil(Pic);
  FreeAndNil(jsObject);
  FreeAndNil(Parser);
  FreeAndNil(jsData);
  FreeAndNil(FileIni);
end;

procedure TBaseForm.ShowResponse();
begin
  try
    if (Self.lResponse <> '') then
    begin
      jsData:= GetJSON(lResponse);
      jsObject:= TJSONObject(jsData);
      isError:= jsObject.Get('iserror');
      msg:= jsObject.FindPath('msg').AsString;
      if (isError = 1) then
         DlgMessage(HeaderMsg,msg,mtError)
      else
        DlgMessage(HeaderMsg,msg,mtInformation);
    end;
  except
  on E: Exception do
    DlgMessage(HeaderMsg,'Error: '+E.Message+' or Server does not exist, please contact your System Administrator',mtError)
  end;
end;

procedure TBaseForm.GetDataAPI(url:string);
begin
  LResponse:= FpClient.SimpleFormPost(Host.Server+Url,SlBody);
  try
    if (Self.lResponse <> '') then
    begin
      jsData:= GetJSON(lResponse);
      jsObject:= TJSONObject(jsData);
      isError:= jsObject.Get('iserror');
      if (isError = 0) then
      begin
        try
          total:= jsObject.Get('total');
        except
          total:= 0;
        end;
        msg:= jsObject.Get('msg');
        try
          JsData:= JsObject.Find('rows');
          JsArray:= TJSONArray(JsData);
        except
        end;
      end else
        showresponse();
    end;
  except
  on E: Exception do
    DlgMessage(HeaderMsg,E.Message,mtError)
  end;
end;

procedure TBaseForm.ShowMessageAPI(messages: string);
begin
  slBody.Clear;
  slBody.Add('messages='+messages);
  try
    GetDataAPI('sysadm/getcatalog');
  finally
   ShowResponse();
  end;
end;

function TBaseForm.GetMessageAPI(messages: string): string;
begin
  slBody.Clear;
  slBody.Add('messages='+messages);
  try
    GetDataAPI('sysadm/getcatalog');
    if (Self.lResponse <> '') then
    begin
      jsData:= GetJSON(lResponse);
      jsObject:= TJSONObject(jsData);
      isError:= jsObject.Get('iserror');
      if (isError = 0) then
        result:= jsObject.Get('msg')
      else
        result:= messages;
    end;
  except
  on E: Exception do
     DlgMessage(HeaderMsg,'Error: '+E.Message,mtError);
  end;
end;

procedure TBaseForm.GetSimpleDataList(url,idfield,namefield: string);
begin
  GetDataAPI(url);
  RowsData:= TStringList.Create;
  try
     if (lResponse <> '') then
     begin
       for JsEnum in JsArray do begin
         JsObject:= TJSONObject(JsEnum.Value);
         RowsData.Add(JsObject.FindPath(namefield).AsString+'='+JsObject.FindPath(idfield).AsString);
       end;
     end;
  except
  on E: Exception do
     DlgMessage(HeaderMsg,'Error: '+E.Message,mtError);
  end;
end;

procedure TBaseForm.DlgMessage(title, messages: string; msgtype: TMsgDlgType);
begin
  MessageForm:= TMessageForm.Create(nil);
  try
    MessageForm.MessageMemo.Text:= messages;
    MessageForm.Caption:= title;
    if (msgtype = mtInformation) then
       MessageForm.ImageMessage.Picture.LoadFromFile('icons/info.png')
    else
    if (msgtype = mtError) then
      MessageForm.ImageMessage.Picture.LoadFromFile('icons/error.png');
    MessageForm.ShowModal;
  finally
    FreeAndNil(MessageForm);
  end;
end;

function TBaseForm.GetExternalIPAddress: string;
var
  HTTPClient: TFPHTTPClient;
  IPRegex: TRegExpr;
  RawData: string;
begin
  try
    HTTPClient := TFPHTTPClient.Create(nil);
    IPRegex := TRegExpr.Create;
    try
      //returns something like:
      {
<html><head><title>Current IP Check</title></head><body>Current IP Address: 44.151.191.44</body></html>
      }
      RawData:=HTTPClient.Get(Host.Hostipext);
      // adjust for expected output; we just capture the first IP address now:
      IPRegex.Expression := RegExprString('\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b');
      //or
      //\b(?:\d{1,3}\.){3}\d{1,3}\b
      if IPRegex.Exec(RawData) then
      begin
        result := IPRegex.Match[0];
      end
      else
      begin
        result := 'Got invalid results getting external IP address. Details:'+LineEnding+
          RawData;
      end;
    except
      on E: Exception do
      begin
        result := 'Error retrieving external IP address: '+E.Message;
      end;
    end;
  finally
    HTTPClient.Free;
    IPRegex.Free;
  end;
end;

function TBaseForm.GetIpAddrList: string;
var
  AProcess: TProcess;
  s: string;
  sl: TStringList;
  i: integer;

begin
  Result:='';
  sl:=TStringList.Create();
  {$IFDEF WINDOWS}
  AProcess:=TProcess.Create(nil);
  AProcess.Executable := 'ipconfig.exe';
  AProcess.Options := AProcess.Options + [poUsePipes, poNoConsole];
  try
    AProcess.Execute();
    Sleep(500); // poWaitOnExit don't work as expected
    sl.LoadFromStream(AProcess.Output);
  finally
    AProcess.Free();
  end;
  for i:=0 to sl.Count-1 do
  begin
    if (Pos('IPv4', sl[i])=0) and (Pos('IP-', sl[i])=0) and (Pos('IP Address', sl[i])=0) then Continue;
    s:=sl[i];
    s:=Trim(Copy(s, Pos(':', s)+1, 999));
    if Pos(':', s)>0 then Continue; // IPv6
    Result:=Result+s+'  ';
  end;
  {$ENDIF}
  {$IFDEF UNIX}
  AProcess:=TProcess.Create(nil);
  AProcess.Executable := '/sbin/ifconfig';
  AProcess.Options := AProcess.Options + [poUsePipes, poWaitOnExit];
  try
    AProcess.Execute();
    sl.LoadFromStream(AProcess.Output);
  finally
    AProcess.Free();
  end;

  for i:=0 to sl.Count-1 do
  begin
    n:=Pos('inet addr:', sl[i]);
    if n=0 then Continue;
    s:=sl[i];
    s:=Copy(s, n+Length('inet addr:'), 999);
    Result:=Result+Trim(Copy(s, 1, Pos(' ', s)))+'  ';
  end;
  {$ENDIF}
  sl.Free();
end;

function TBaseForm.GetDataUser: string;
var
  lat,lon: string;
begin
  LResponse:= FpClient.SimpleGet(Host.HostIpGeo+GetExternalIPAddress);
  if (lResponse <> '') then
  begin
    jsData:= GetJSON(lResponse);
    jsObject:= TJSONObject(jsData);
    lat:= JsObject.Get('lat');
    lon:= JsObject.Get('lon');
  end;
  result:= User.UserName+';'+GetExternalIPAddress+';'+GetIpAddrList+';'+lat+';'+lon;
end;


end.

