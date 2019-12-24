unit uBaseForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ActnList,
  ExtCtrls, IniFiles, jsonparser, fpjson, fphttpclient, umessageform,
  process,RegExpr,Buttons,strutils,StdCtrls,ComCtrls,Toolwin, DBCtrls, DBGrids,
  memds, db,Grids;

type

  { TBaseForm }

  TMenuStructure=record
    FormType: string;
    MenuName: string;
    ListUrl: string;
    CopyUrl: string;
    SaveUrl: string;
    DeleteUrl: string;
    UploadUrl: string;
    DownPDF: string;
    DownXLS: string;
    Button: string;
    Search: string;
    Grid: TJSONData;
    Page: integer;
    Rows: integer;
  end;

  TUserMenu = record
    MenuIcon: string;
    MenuName: string;
    MenuLabel: string;
    MenuAccessId: integer;
    Description: string;
    MenuUrl: string;
    ParentId : string;
    SortOrder: integer;
    MenuCode: string;
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
    Authkey: string;
    Wallpaper: string;
    LanguageName: string;
    ThemeName: string;
    RecordStatus: integer;
    MenuItems: array of TUserMenu;
    UserFav: array of TUserMenu;
  end;

  THost = class
    Server: string;
    Title: string;
    Company: string;
    Serial: string;
    Rows: integer;
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
    procedure ToolButtonClick(Sender: TObject);

  private

  public
    Host                  : THost;
    MenuStructure         : TMenuStructure;
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
    Msg,HeaderMsg         : string;
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
    procedure MenuGenerator(ParentComponent: TWinControl;ParentImageList: TImageList);
    procedure AddButtonToToolbar(var Bar: TToolBar; ButtonName, ButtonCaption: string;
      ImageIndex: integer);
    procedure FillGrid(MyMemDS: TMemDataset; MyDS: TDataSource; ListUrl: string;
      Page, Rows: integer);
    function GetAccess(MenuAction: string): boolean;
    function GetMenuAccessID(MenuLabel: string): integer;
    function GetSplitItem(Delimiter: Char; Str: string; Index: integer): string;
    procedure GridDblClick(Sender: TObject);
    procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings);
    function GetMenuAccessName(MenuLabel: string): string;
  end;

var
  BaseForm              : TBaseForm;
  i,j                   : integer;


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
  RowsData:= TStringList.Create;
  try
    Host.title:= FileIni.ReadString('MAIN','title','');
    HeaderMsg:= Host.title;
    Host.company:= FileIni.ReadString('MAIN','company','');
    Host.serial:= FileIni.ReadString('MAIN','serial','');
    Host.icon:= FileIni.ReadString('MAIN','icon','');
    Host.wallpaper:= FileIni.ReadString('MAIN','wallpaper','');
    Host.rows:= FileIni.ReadInteger('MAIN','rows',10);
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
  FreeAndNil(RowsData);
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
  result:= User.UserName+','+GetExternalIPAddress+','+GetIpAddrList+','+lat+','+lon;
end;

procedure TBaseForm.Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
  ListOfStrings.Clear;
  ListOfStrings.Delimiter       := Delimiter;
  ListOfStrings.StrictDelimiter := True;
  ListOfStrings.DelimitedText   := Str;
end;

function TBaseForm.GetSplitItem(Delimiter: Char; Str: string; Index: integer): string;
var ListofStrings: TStringList;
begin
  ListofStrings:= TStringList.Create;
  try
    ListOfStrings.Delimiter       := Delimiter;
    ListOfStrings.StrictDelimiter := True;
    ListOfStrings.DelimitedText   := Str;
    result:= ListofStrings[index];
  finally
    FreeAndNil(ListofStrings);
  end;
end;

function TBaseForm.GetAccess(MenuAction: string):boolean;
begin
  SlBody.Clear;
  SlBody.Add('token='+User.Authkey);
  SlBody.Add('menuname='+MenuStructure.MenuName);
  slBody.Add('menuaction='+MenuAction);
  GetDataAPI('sysadm/checkaccess');
  result:=false;
  if (iserror = 0) then
  begin
    for JsEnum in JsArray do begin
      JsObject:= TJSONObject(JsEnum.Value);
      if (JsObject.Get('access') = 1) then
      begin
        result:= true;
        break;
      end
    end;
  end;
end;

procedure TBaseForm.AddButtonToToolbar(var Bar: TToolBar; ButtonName,
  ButtonCaption: string; ImageIndex: integer);
var
  NewBtn: TToolButton;
  lastbtnidx: integer;
begin
  NewBtn := TToolButton.Create(bar);
  NewBtn.Caption := ButtonCaption;
  NewBtn.Name:= ButtonName;
  NewBtn.ImageIndex:= ImageIndex;
  lastbtnidx := bar.ButtonCount - 1;
  if lastbtnidx > -1 then
    NewBtn.Left := bar.Buttons[lastbtnidx].Left + bar.Buttons[lastbtnidx].Width
  else
    NewBtn.Left := 0;
  NewBtn.Parent := bar;
  NewBtn.OnClick:= @ToolButtonClick;
end;

procedure TBaseForm.ToolButtonClick(Sender: TObject);
begin
  case TToolButton(Sender).ImageIndex of
    0: showmessage('new');
    1: showmessage('edit');
    2: showmessage('copy');
    3: showmessage('save');
    4: showmessage('pdf');
    5: showmessage('xls');
    6: ShowMessage('history');
    7: ShowMessage('purge');
  end;
end;

function TBaseForm.GetMenuAccessID(MenuLabel: string):integer;
begin
  for i:=0 to length(User.menuitems) do
  begin
   if (User.menuitems[i].MenuLabel = MenuLabel) then
   begin
     result:= User.menuitems[i].MenuaccessId;
     break;
   end;
  end;
end;

function TBaseForm.GetMenuAccessName(MenuLabel: string):string;
begin
  for i:=0 to length(User.menuitems) do
  begin
   if (User.menuitems[i].MenuLabel = MenuLabel) then
   begin
     result:= User.menuitems[i].MenuName;
     break;
   end;
  end;
end;

procedure TBaseForm.MenuGenerator(ParentComponent: TWinControl;ParentImageList: TImageList);
var
  PanelToolbar: TToolBar;
  GridMenu: TDBGrid;
  MemDSMenu: TMemDataset;
  DataSourceMenu: TDataSource;
  FieldDefMenu: TFieldDef;
  TempStringList: TStringList;
  MenuCode: string;
  FieldTypeMenu: TFieldType;
  FieldSize: word;
  FieldRequired: boolean;
  i: integer;
  FieldColumn: TColumn;
begin
  TempStringList:= TStringList.Create;
  try
    for JsEnum in JsArray do
    begin
      jsObject:= TJSONObject(jsEnum.Value);
      MenuStructure.MenuName:= JsObject.Get('menuname');
      MenuCode:= JsObject.Get('menucode');
      JsData:= GetJSON(MenuCode);
      JsObject:= TJSONObject(JsData);
      MenuStructure.FormType:= JsObject.Get('Form');
      MenuStructure.ListUrl:= JsObject.Get('ListUrl');
      MenuStructure.CopyUrl:= JsObject.Get('CopyUrl');
      MenuStructure.SaveUrl:= JsObject.Get('SaveUrl');
      MenuStructure.DeleteUrl:= JsObject.Get('DeleteUrl');
      MenuStructure.UploadUrl:= JsObject.Get('UploadUrl');
      MenuStructure.DownPDF:= JsObject.Get('DownPDF');
      MenuStructure.DownXLS:= JsObject.Get('DownXLS');
      MenuStructure.Button:= JsObject.Get('Button');
      MenuStructure.Search:= JsObject.Get('Search');
      MenuStructure.Grid:= JsObject.Find('Grid');
    end;

    PanelToolbar:= TToolBar.Create(ParentComponent);
    PanelToolbar.Name:= 'PanelToolbar'+MenuStructure.MenuName;
    PanelToolbar.Align:= alTop;
    PanelToolbar.Height:= 50;
    PanelToolbar.ButtonWidth:=36;
    PanelToolbar.ButtonHeight:=36;
    PanelToolbar.Caption:='';
    PanelToolbar.EdgeInner:= esNone;
    PanelToolbar.EdgeOuter:= esNone;
    PanelToolbar.EdgeBorders:= [];
    PanelToolbar.Visible:= true;
    PanelToolbar.Flat:=true;
    PanelToolbar.Images:= ParentImageList;
    PanelToolbar.Parent:= ParentComponent;

    if (GetAccess('iswrite') = true) then
    begin
      if (AnsiContainsText(lowercase(MenuStructure.Button),'new')) then
        AddButtonToToolbar(PanelToolbar, 'ButtonNew'+MenuStructure.MenuName, '',0);
      if (AnsiContainsText(lowercase(MenuStructure.Button),'edit')) then
        AddButtonToToolbar(PanelToolbar, 'ButtonEdit'+MenuStructure.MenuName, '',1);
      if (AnsiContainsText(lowercase(MenuStructure.Button),'copy')) then
        AddButtonToToolbar(PanelToolbar, 'ButtonCopy'+MenuStructure.MenuName, '',2);
      if (AnsiContainsText(lowercase(MenuStructure.Button),'save')) then
        AddButtonToToolbar(PanelToolbar, 'ButtonSave'+MenuStructure.MenuName, '',3);
    end;
    if (GetAccess('isdownload') = true) then
    begin
      if (AnsiContainsText(lowercase(MenuStructure.Button),'pdf')) then
        AddButtonToToolbar(PanelToolbar, 'ButtonPdf'+MenuStructure.MenuName, '',4);
      if (AnsiContainsText(lowercase(MenuStructure.Button),'xls')) then
        AddButtonToToolbar(PanelToolbar, 'ButtonXls'+MenuStructure.MenuName, '',5);
    end;
    if (AnsiContainsText(lowercase(MenuStructure.Button),'history')) then
      AddButtonToToolbar(PanelToolbar, 'ButtonHistory'+MenuStructure.MenuName, '',6);
    if (GetAccess('ispurge') = true) then
      if (AnsiContainsText(lowercase(MenuStructure.Button),'purge')) then
        AddButtonToToolbar(PanelToolbar, 'ButtonPurge'+MenuStructure.MenuName, '',7);

    GridMenu:= TDBGrid.Create(ParentComponent);
    GridMenu.Name:= 'Grid'+MenuStructure.MenuName;
    GridMenu.Align:= alClient;
    GridMenu.Visible:= true;
    Gridmenu.Parent:= ParentComponent;
    GridMenu.AutoEdit:=false;
    GridMenu.OnDblClick:=@GridDblClick;
    JsArray:= TJSONArray(MenuStructure.Grid);
    for JsEnum in JsArray do
    begin
      jsObject:= TJSONObject(jsEnum.Value);
      FieldColumn:= GridMenu.Columns.Add;
      FieldColumn.FieldName:= JsObject.Get('fieldname');
      FieldColumn.Title.Caption:= GetMessageAPI(JsObject.Get('fieldname'));
      try
        if (JsObject.Get('fieldkey') = 'true') then
           FieldColumn.Visible:= false;
      except
        FieldColumn.Visible:= true;
      end;
      FieldColumn.Alignment:= taLeftJustify;
      FieldColumn.Title.Alignment:= taCenter;
      FieldColumn.Title.MultiLine:= true;
      try
        if (JsObject.Get('fieldtype') = 'integer') then
          FieldColumn.Alignment:= taRightJustify
        else
        if (JsObject.Get('fieldtype') = 'decimal') then
           FieldColumn.Alignment:= taRightJustify
        else
        if (JsObject.Get('fieldtype') = 'checkbox') then
          FieldColumn.ButtonStyle:= cbsCheckboxColumn
        else
          FieldColumn.Alignment:= taLeftJustify;
      except
        FieldColumn.Alignment:= taLeftJustify;
      end;
      try
        FieldColumn.Width:= strtoint(JsObject.Get('width'));
      except
        FieldColumn.Width:=50;
      end;
    end;

    MemDSMenu:= TMemDataset.Create(Self);
    MemDSMenu.Name:= 'MemDataSet'+MenuStructure.MenuName;
    JsArray:= TJSONArray(MenuStructure.Grid);
    i:=0;
    for JsEnum in JsArray do
    begin
      FieldRequired:= false;
      jsObject:= TJSONObject(jsEnum.Value);
      try
        if (JsObject.Get('fieldtype') = 'integer') then
           FieldTypeMenu:= ftInteger
        else
        if (JsObject.Get('fieldtype') = 'string') then
           FieldTypeMenu:= ftString
        else
        if (JsObject.Get('fieldtype') = 'text') then
           FieldTypeMenu:= ftWideString
        else
        if (JsObject.Get('fieldtype') = 'decimal') then
           FieldTypeMenu:= ftFloat
        else
        if (JsObject.Get('fieldtype') = 'checkbox') then
           FieldTypeMenu:= ftInteger
        else
        if (JsObject.Get('fieldtype') = 'date') then
           FieldTypeMenu:= ftDate
        else
        if (JsObject.Get('fieldtype') = 'datetime') then
           FieldTypeMenu:= ftDateTime
      except
        FieldTypeMenu:= ftString;
      end;
      try
        FieldSize:= strtoint(JsObject.Get('fieldsize'));
      except
        FieldSize:=0;
      end;
      try
        FieldRequired:= StrToBool(JsObject.Get('fieldrequire'));
      except
      end;
      FieldDefMenu:= MemDSMenu.FieldDefs.Add(JsObject.Get('fieldname'), FieldTypeMenu,
        FieldSize, FieldRequired,i);
      try
        if (JsObject.Get('fieldkey') = 'true') then
           FieldDefMenu.Attributes:= FieldDefMenu.Attributes + [faReadonly,faHiddenCol];
      except
      end;
      i:=i+1;
    end;
    SlBody.Clear;
    SlBody.Add('token='+User.Authkey);
    RowsData.CommaText:= MenuStructure.Search;

    DataSourceMenu:= TDataSource.Create(Self);
    DataSourceMenu.Name:= 'DataSource'+MenuStructure.MenuName;
    DataSourceMenu.DataSet:= MemDSMenu;

    FillGrid(MemDSMenu, DataSourceMenu, MenuStructure.ListUrl,1,Host.Rows);
    GridMenu.DataSource:= DataSourceMenu;

  finally
    FreeAndNil(TempStringList);
  end;
end;

procedure TBaseForm.GridDblClick(Sender: TObject);
begin
  if (GetAccess('iswrite') = true) then
    TDBGrid(Sender).Options:= TDBGrid(Sender).Options + [dgEditing];
end;

procedure TBaseForm.FillGrid(MyMemDS: TMemDataset; MyDS: TDataSource; ListUrl:string; Page, Rows: integer);
var i:integer;
begin
  MyDS.DataSet:= nil;
  if (MyMemDS.Active = false) then
    MyMemDS.Active:=true;
  SlBody.Add('page='+inttostr(Page));
  SlBody.Add('rows='+inttostr(Rows));
  GetDataAPI(ListUrl);i:=0;
  if (iserror = 0) then
  begin
    MyMemDS.Insert;
    for JsEnum in JsArray do
    begin
      JsObject:= TJSONObject(JsEnum.Value);
      if (MyMemDS.FindField(JsObject.Names[i]) <> nil) then
      begin
       MyMemDS.FieldByName(JsObject.Names[i]).AsString:= JsObject.Get(JsObject.Names[i]);
       i:=i+1;
      end;
    end;
    MyMemDS.Post;
  end;
  MyDs.DataSet:= MyMemDS;
end;

end.

