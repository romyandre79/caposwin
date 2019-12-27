unit uloginform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, ActnList, uBaseForm, fpjson, jsonparser, umainform,
  uutility;

type

  { TLoginForm }

  TLoginForm = class(TBaseForm)
    actClose: TAction;
    actFormActivated: TAction;
    actLogin: TAction;
    btnLogin: TBitBtn;
    btnClose: TBitBtn;
    edPassword: TEdit;
    edUserName: TEdit;
    imgLogin: TImage;
    imgWallpaper: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure CloseExecute(Sender: TObject);
    procedure LoginExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private

  public

  end;

var
  LoginForm: TLoginForm;

implementation

{$R *.lfm}

{ TLoginForm }

procedure TLoginForm.LoginExecute(Sender: TObject);
begin
  slBody.Clear;
  slBody.Add('username='+edUserName.Text);
  slBody.Add('password='+edPassword.Text);
  try
    GetDataAPI('sysadm/login');
    if (iserror = 0) then
    begin
      jsData:= jsObject.Find('rows');
      jsObject:= TJsonObject(jsData);
      User.useraccessid:= jsObject.Get('useraccessid');
      User.username:= jsObject.Get('username');
      User.realname:= jsObject.Get('realname');
      User.password:= jsObject.Get('password');
      User.email:= jsObject.Get('email');
      User.phoneno:= jsObject.Get('phoneno');
      User.languageid:= jsObject.Get('languageid');
      User.themeid:= jsObject.Get('themeid');
      User.isonline:= jsObject.Get('isonline');
      User.authkey:= jsObject.Get('authkey');
      User.wallpaper:= jsObject.Get('wallpaper');
      User.languagename:= jsObject.Get('languagename');
      User.themename:= jsObject.Get('themename');
      slBody.Clear;
      slBody.Add('token='+User.authkey);
      GetDataAPI('sysadm/getallmenus');
      if (iserror = 0) then
      begin
        JsData:= jsObject.Find('rows');
        JsArray:= TJSONArray(jsData);
        i:=0;
        setLength(User.menuitems,jsArray.Count);
        for jsEnum in jsArray do begin
          jsObject:= TJSONObject(jsEnum.Value);
          if (jsObject.Get('description') <> null) then
             User.menuitems[i].description:= jsObject.Get('description')
          else
              User.menuitems[i].description:= '';
          if (jsObject.Get('menuaccessid') <> null) then
             User.menuitems[i].menuaccessid:= jsObject.Get('menuaccessid')
          else
              User.menuitems[i].menuaccessid:= 0;
          if (jsObject.Get('menuicon') <> null) then
             User.menuitems[i].menuicon:= jsObject.Get('menuicon')
          else
              User.menuitems[i].menuicon:= '';
          if (jsObject.Get('menulabel') <> null) then
             User.menuitems[i].menulabel:= jsObject.Get('menulabel')
          else
              User.menuitems[i].menulabel:= '';
          if (jsObject.Get('menuname') <> null) then
             User.menuitems[i].menuname:= jsObject.Get('menuname')
          else
              User.menuitems[i].menuname:= '';
          if (jsObject.Get('menuurl') <> null) then
             User.menuitems[i].menuurl:= jsObject.Get('menuurl')
          else
              User.menuitems[i].menuurl:= '';
          if (jsObject.Get('parentid') <> null) then
             User.menuitems[i].parentid:= jsObject.Get('parentid')
          else
              User.menuitems[i].parentid:= '';
          if (jsObject.Get('sortorder') <> null) then
             User.menuitems[i].sortorder:= jsObject.Get('sortorder')
          else
              User.menuitems[i].sortorder:= 0;
          if (jsObject.Get('menucode') <> null) then
             User.menuitems[i].menucode:= jsObject.Get('menucode')
          else
              User.menuitems[i].menucode:= '';
          i:= i+1;
        end;
        slBody.Clear;
        slBody.Add('token='+User.authkey);
        GetDataAPI('sysadm/getuserfavs');
        if (iserror = 0) then
        begin
          jsData:= jsObject.Find('rows');
          jsArray:= TJSONArray(jsData);
          i:=0;
          setLength(User.userfav,jsArray.Count);
          for jsEnum in jsArray do begin
            jsObject:= TJSONObject(jsEnum.Value);
            if (jsObject.Get('description') <> null) then
               User.userfav[i].description:= jsObject.Get('description')
            else
                User.userfav[i].description:= '';
            if (jsObject.Get('menuaccessid') <> null) then
               User.userfav[i].menuaccessid:= jsObject.Get('menuaccessid')
            else
                User.userfav[i].menuaccessid:= 0;
            if (jsObject.Get('menuicon') <> null) then
               User.userfav[i].menuicon:= jsObject.Get('menuicon')
            else
                User.menuitems[i].menuicon:= '';
            if (jsObject.Get('menulabel') <> null) then
               User.userfav[i].menulabel:= jsObject.Get('menulabel')
            else
                User.userfav[i].menulabel:= '';
            if (jsObject.Get('menuname') <> null) then
               User.userfav[i].menuname:= jsObject.Get('menuname')
            else
                User.userfav[i].menuname:= '';
            if (jsObject.Get('menuurl') <> null) then
               User.userfav[i].menuurl:= jsObject.Get('menuurl')
            else
                User.userfav[i].menuurl:= '';
            if (jsObject.Get('parentid') <> null) then
               User.userfav[i].parentid:= jsObject.Get('parentid')
            else
                User.userfav[i].parentid:= '';
            if (jsObject.Get('sortorder') <> null) then
               User.userfav[i].sortorder:= jsObject.Get('sortorder')
            else
                User.userfav[i].sortorder:= 0;
            if (jsObject.Get('menucode') <> null) then
               User.userfav[i].menucode:= jsObject.Get('menucode')
            else
                User.userfav[i].menucode:= '';
            i:= i+1;
          end;
        end;
      end;
      Self.Hide;
      MainForm:= TMainForm.Create(self);
      MainForm.ShowModal;
      Self.Show;
    end;
  except
  on E: Exception do
     MessageDlg(HeaderMsg,'Error: '+E.ClassName+' '+E.Message,mtError,[mbOK],'')
  end;
end;

procedure TLoginForm.FormActivate(Sender: TObject);
begin
  inherited;
  GetServerData();
  imgLogin.Picture.LoadFromFile(Host.icon);
  imgWallpaper.Picture.LoadFromFile('wallpaper/'+Host.wallpaper);
  Pic.LoadFromFile('icons/login.png');
  btnLogin.Glyph.Assign(Pic.Bitmap);
  Pic.LoadFromFile('icons/close.png');
  btnClose.Glyph.Assign(Pic.Bitmap);
end;

procedure TLoginForm.CloseExecute(Sender: TObject);
begin
  Close;
end;

end.

