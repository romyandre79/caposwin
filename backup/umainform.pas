unit umainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Menus, Buttons, StdCtrls, DBGrids, uBaseForm, db, memds, jsonparser,fpjson,
  uutility;

type

  { TMainForm }

  TMainForm = class(TBaseForm)
    ButtonClose: TBitBtn;
    ButtonOK: TBitBtn;
    ComboBoxLanguage: TComboBox;
    ComboBoxTheme: TComboBox;
    DSLanguage: TDataSource;
    DBGrid1: TDBGrid;
    EditEmail: TEdit;
    EditPassword: TEdit;
    EditPhoneNo: TEdit;
    EditRealName: TEdit;
    EditUserName: TEdit;
    ImageListButton: TImageList;
    ImageListMainForm: TImageList;
    ImageWallpaper: TImage;
    LabelEmail: TLabel;
    LabelLanguage: TLabel;
    LabelPassword: TLabel;
    LabelPhoneNo: TLabel;
    LabelRealName: TLabel;
    LabelTheme: TLabel;
    LabelUserName: TLabel;
    MemDSLanguage: TMemDataset;
    MenuItemCloseTab: TMenuItem;
    PageHome: TPageControl;
    PageMenu: TPageControl;
    PanelButton: TPanel;
    PopUpMainForm: TPopupMenu;
    SaveDialogMainForm: TSaveDialog;
    StatusBarMainForm: TStatusBar;
    TabHome: TTabSheet;
    TabProfilUser: TTabSheet;
    TimerMainForm: TTimer;
    TreeViewMainForm: TTreeView;
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure TimerMainFormTimer(Sender: TObject);
    procedure TreeViewMainFormDblClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure ToolButtonClick(Sender: TObject);
  private
    FLanguage, FTheme: TStringList;
    procedure GetLanguageListAllUser();
    procedure GetThemeListAllUser();
  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormActivate(Sender: TObject);
var
  MenuParentNode,SubMenuNode: TTreeNode;
begin
  inherited;
  ImageWallpaper.Picture.LoadFromFile('wallpaper/'+User.wallpaper);
  TimerMainForm.Enabled:=true;
  ImageListMainForm.Clear;
  Pic:= TPicture.Create;
  Pic.LoadFromFile('icons/close.png');
  ButtonClose.Glyph.Assign(Pic.Bitmap);
  for i:=0 to length(User.menuitems)-1 do
  begin
    Pic:= TPicture.Create;
    try
       if (User.menuitems[i].MenuIcon = '') then
         Pic.LoadFromFile('icons/folder.png')
       else
         Pic.LoadFromFile('icons/'+User.menuitems[i].MenuIcon);
       ImageListMainForm.Add(Pic.Bitmap,Pic.Bitmap);
    except
    end;
  end;
  for i:=0 to length(User.menuitems)-1 do
  begin
    if (User.menuitems[i].parentid = '') then
    begin
      MenuParentNode:= TreeViewMainForm.Items.Add(nil,User.menuitems[i].menulabel);
      MenuParentNode.ImageIndex:=i;
      MenuParentNode.SelectedIndex:=MenuParentNode.ImageIndex;
      for j:=0 to length(User.menuitems)-1 do
      begin
        if (User.menuitems[j].parentid <> '') then
        begin
          if (User.menuitems[j].parentid = inttostr(User.menuitems[i].menuaccessid)) then
          begin
            SubMenuNode:= TreeViewMainForm.Items.AddChild(MenuParentNode,User.menuitems[j].menulabel);
            SubMenuNode.ImageIndex:=j;
            SubMenuNode.SelectedIndex:=SubMenuNode.ImageIndex;
          end;
        end;
      end;
    end;
  end;
  GetLanguageListAllUser();
  GetThemeListAllUser();
  LabelEmail.Caption:= GetMessageAPI('email');
  EditEmail.Caption:= User.Email;
  LabelLanguage.Caption:= GetMessageAPI('language');
  ComboBoxLanguage.Text:= User.languagename;
  LabelPassword.Caption:= GetMessageAPI('password');
  EditPassword.Caption:= User.Password;
  LabelPhoneNo.Caption:= GetMessageAPI('phoneno');
  EditPhoneNo.Caption:= User.Phoneno;
  LabelRealName.Caption:= GetMessageAPI('realname');
  EditRealName.Caption:= User.RealName;
  LabelTheme.Caption:= GetMessageAPI('theme');
  ComboBoxTheme.Text:= User.themename;
  LabelUserName.Caption:= GetMessageAPI('username');
  EditUserName.Caption:= User.UserName;
  ImageListButton.Clear;
  Pic:=TPicture.Create;
  Pic.LoadFromFile('icons/add.png');
  ImageListButton.Add(Pic.Bitmap,nil);
  Pic:=TPicture.Create;
  Pic.LoadFromFile('icons/edit.png');
  ImageListButton.Add(Pic.Bitmap,nil);
  Pic:=TPicture.Create;
  Pic.LoadFromFile('icons/copy.png');
  ImageListButton.Add(Pic.Bitmap,nil);
  Pic:=TPicture.Create;
  Pic.LoadFromFile('icons/save.png');
  ImageListButton.Add(Pic.Bitmap,nil);
  ButtonOK.Glyph.Assign(Pic.Bitmap);
  Pic:=TPicture.Create;
  Pic.LoadFromFile('icons/pdf.png');
  ImageListButton.Add(Pic.Bitmap,nil);
  Pic:=TPicture.Create;
  Pic.LoadFromFile('icons/xls.png');
  ImageListButton.Add(Pic.Bitmap,nil);
  Pic:=TPicture.Create;
  Pic.LoadFromFile('icons/search.png');
  ImageListButton.Add(Pic.Bitmap,nil);
  Pic:=TPicture.Create;
  Pic.LoadFromFile('icons/history.png');
  ImageListButton.Add(Pic.Bitmap,nil);
  Pic:=TPicture.Create;
  Pic.LoadFromFile('icons/purge.png');
  ImageListButton.Add(Pic.Bitmap,nil);
  PageMenu.ActivePageIndex:=0;
end;

procedure TMainForm.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.ButtonOKClick(Sender: TObject);
begin
  SlBody.Clear;
  SlBody.Add('token='+User.authkey);
  SlBody.Add('useraccessid='+ IntToStr(User.UseraccessId));
  SlBody.Add('username='+User.UserName);
  SlBody.Add('realname='+User.RealName);
  SlBody.Add('password='+User.Password);
  SlBody.Add('email='+User.Email);
  SlBody.Add('phoneno='+User.Phoneno);
  SlBody.Add('languageid='+inttostr(User.LanguageId));
  SlBody.Add('themeid='+inttostr(User.themeid));
  SlBody.Add('datauser='+GetDataUser);
  try
     GetDataAPI('useraccess/saveprofile');
     DlgMessage(HeaderMsg,msg+' Application will close',mtInformation);
     Application.Terminate;
  except
  on E: Exception do
     DlgMessage(HeaderMsg,'Error: '+E.Message,mtError);
  end;
end;

procedure TMainForm.TimerMainFormTimer(Sender: TObject);
begin
  StatusBarMainForm.Panels[1].Text:= DateToStr(now)+ ' '+ TimeToStr(now);
end;

procedure TMainForm.TreeViewMainFormDblClick(Sender: TObject);
var
  TabMenu: TTabSheet;
  i: integer;
  s: string;
begin
  TabMenu:= TTabSheet.Create(PageMenu);
  TabMenu.Caption:='';
  //try
    for i := 0 to PageMenu.PageCount-1 do
    begin
      s:= PageMenu.Pages[i].Caption;
      if (s = TreeViewMainForm.Selected.Text) then
      begin
        TabMenu:= PageMenu.Pages[i];
        break;
      end
    end;
    if (TabMenu.Caption = '') then
    begin
      TabMenu:= PageMenu.AddTabSheet;
      TabMenu.Caption:= TreeViewMainForm.Selected.Text;
      SlBody.Clear;
      SlBody.Add('id='+inttostr(GetMenuAccessID(TreeViewMainForm.Selected.Text)));
      SlBody.Add('token='+User.Authkey);
      GetDataAPI('menuaccess/one');
      if (iserror = 0) then
        MenuGenerator(TabMenu,ImageListButton);
      if (FindComponent('ButtonNew'+GetMenuAccessName(TreeViewMainForm.Selected.Text)) <> nil) then
         TToolButton(FindComponent('ButtonNew'+GetMenuAccessName(TreeViewMainForm.Selected.Text))).OnClick:= @ToolButtonClick;
      if (FindComponent('ButtonEdit'+GetMenuAccessName(TreeViewMainForm.Selected.Text)) <> nil) then
         TToolButton(FindComponent('ButtonEdit'+GetMenuAccessName(TreeViewMainForm.Selected.Text))).OnClick:= @ToolButtonClick;
      if (FindComponent('ButtonCopy'+GetMenuAccessName(TreeViewMainForm.Selected.Text)) <> nil) then
         TToolButton(FindComponent('ButtonCopy'+GetMenuAccessName(TreeViewMainForm.Selected.Text))).OnClick:= @ToolButtonClick;
      if (FindComponent('ButtonSave'+GetMenuAccessName(TreeViewMainForm.Selected.Text)) <> nil) then
         TToolButton(FindComponent('ButtonSave'+GetMenuAccessName(TreeViewMainForm.Selected.Text))).OnClick:= @ToolButtonClick;
    end;
    if (TabMenu.Caption <> '') then
      PageMenu.ActivePage:= TabMenu;
  //except
  //end;
end;

procedure TMainForm.GetLanguageListAllUser();
var i: integer;
begin
  try
    GetSimpleDataList('language/listalluser','languageid','languagename');
    FLanguage:= RowsData;
    for i:= 0 to RowsData.Count-1 do
      ComboBoxLanguage.Items.Add(RowsData.Names[i]);
  except
  end;
end;

procedure TMainForm.GetThemeListAllUser();
var i: integer;
begin
  try
    GetSimpleDataList('theme/listalluser','themeid','themename');
    FTheme:= RowsData;
    for i:= 0 to RowsData.Count-1 do
      ComboBoxTheme.Items.Add(RowsData.Names[i]);
  except
  end;
end;

procedure TMainForm.GridDblClick(Sender: TObject);
begin
  if (GetAccess('iswrite') = true) then
     TDBGrid(Sender).Options:= TDBGrid(Sender).Options + [dgEditing];
end;

procedure TMainForm.ToolButtonClick(Sender: TObject);
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

end.
