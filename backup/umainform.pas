unit umainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Menus, Buttons, StdCtrls, DBGrids, uBaseForm, db, memds, jsonparser,fpjson;

type

  { TMainForm }

  TMainForm = class(TBaseForm)
    ButtonOK: TBitBtn;
    ButtonClose: TBitBtn;
    ComboBoxLanguage: TComboBox;
    ComboBoxTheme: TComboBox;
    DBGridLanguage: TDBGrid;
    DSLanguage: TDataSource;
    DBGrid1: TDBGrid;
    EditPhoneNo: TEdit;
    EditRealName: TEdit;
    EditEmail: TEdit;
    EditUserName: TEdit;
    EditPassword: TEdit;
    ImageListButton: TImageList;
    ImageListMainForm: TImageList;
    ImageWallpaper: TImage;
    LabelTheme: TLabel;
    LabelPhoneNo: TLabel;
    LabelLanguage: TLabel;
    LabelRealName: TLabel;
    LabelEmail: TLabel;
    LabelUserName: TLabel;
    LabelPassword: TLabel;
    MemDSLanguage: TMemDataset;
    MenuItemCloseTab: TMenuItem;
    PageHome: TPageControl;
    PanelButton: TPanel;
    PageMenu: TPageControl;
    PopUpMainForm: TPopupMenu;
    SaveDialogMainForm: TSaveDialog;
    StatusBarMainForm: TStatusBar;
    TabHome: TTabSheet;
    TabProfilUser: TTabSheet;
    TabSheetLanguage: TTabSheet;
    TimerMainForm: TTimer;
    ToolBarLanguage: TToolBar;
    ToolButtonLanguageCopy: TToolButton;
    ToolButtonLanguagePurge: TToolButton;
    ToolButtonLanguageHistory: TToolButton;
    ToolButtonLanguageSearch: TToolButton;
    ToolButtonLanguageXLS: TToolButton;
    ToolButtonLanguagePDF: TToolButton;
    ToolButtonLanguageSave: TToolButton;
    ToolButtonLanguageEdit: TToolButton;
    ToolButtonLanguageNew: TToolButton;
    TreeViewMainForm: TTreeView;
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure TimerMainFormTimer(Sender: TObject);
    procedure TreeViewMainFormDblClick(Sender: TObject);
  private
    FLanguage, FTheme: TStringList;
    procedure GetLanguageListAllUser();
    procedure GetThemeListAllUser();
    procedure SetUpTab(MenuName: string);
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
  Pic.LoadFromFile('icons/history.png');
  ImageListButton.Add(Pic.Bitmap,nil);
  Pic:=TPicture.Create;
  Pic.LoadFromFile('icons/purge.png');
  ImageListButton.Add(Pic.Bitmap,nil);
  PageMenu.ActivePageIndex:=0;
  For i:= 1 to PageMenu.PageCount - 1 do
  begin
    PageMenu.Pages[i].TabVisible:= false;
  end;
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

procedure TMainForm.SetUpTab(MenuName: string);
var
  MyDB: TDBGrid;
  MyDataSet: TMemDataset;
  MyDataSource: TDataSource;
begin
  for i:= 0 to PageMenu.PageCount-1 do
  begin
    if (lowercase(PageMenu.Pages[i].Name) = LowerCase('TabSheet'+MenuName)) then
    begin
      PageMenu.Pages[i].Caption:= GetMessageAPI(MenuName);
      PageMenu.Pages[i].TabVisible:=true;
      PageMenu.ActivePage:= PageMenu.Pages[i];
      break;
    end;
  end;
  MyDataSource:= TDataSource(FindComponent('DS'+MenuName));
  MyDataSet:= TMemDataset(FindComponent('MemDS'+MenuName));
  MyDB:= TDBGrid(FindComponent('DBGrid'+MenuName));

  if (MyDB <> nil) then
  begin
    MyDB.DataSource:= nil;
    for i:=0 to MyDB.Columns.Count-1 do
       MyDB.Columns[i].Title.Caption:= GetMessageAPI(MyDB.Columns[i].FieldName);
  end;

  if (MyDataSet <> nil) then
    MyDataSet.Active:=true;

  SlBody.Clear;
  SlBody.Add('token='+User.Authkey);
  SlBody.Add('page=1');
  SlBody.Add('rows=10');
  GetDataAPI(MenuName+'/list');
  i:=0;
  if (iserror = 0) then
  begin
    for JsEnum in JsArray do
    begin
      MyDataSet.Insert;
      JsObject:= TJSONObject(JsEnum.Value);
      for j:=0 to MyDataSet.FieldCount-1 do
      begin
        MyDataSet.Fields[j].AsString:= JsObject.Get(MyDataSet.Fields[j].FieldName);
      end;
      MyDataSet.Post;
    end;
  end;

  if (MyDB <> nil) then
     MyDB.DataSource:= MyDataSource;

end;

procedure TMainForm.TreeViewMainFormDblClick(Sender: TObject);
var
  //TabMenu: TTabSheet;
  //i: integer;
  s: string;
begin
  s:= GetMenuAccessName(TreeViewMainForm.Selected.Text);
  SetUpTab(s);
  {
  //TODO: Generate Runtime based on Menu Code
  try
    TabMenu:= nil;
    for i := 0 to PageMenu.PageCount-1 do
    begin
      s:= PageMenu.Pages[i].Caption;
      if (s = TreeViewMainForm.Selected.Text) then
      begin
        TabMenu:= PageMenu.Pages[i];
        break;
      end
    end;
    if (TabMenu = nil) then
    begin
      TabMenu:= PageMenu.AddTabSheet;
      TabMenu.Caption:= TreeViewMainForm.Selected.Text;
      SlBody.Clear;
      SlBody.Add('id='+inttostr(GetMenuAccessID(TreeViewMainForm.Selected.Text)));
      SlBody.Add('token='+User.Authkey);
      GetDataAPI('menuaccess/one');
      if (iserror = 0) then
        MenuGenerator(TabMenu,ImageListButton);
    end;
    if (TabMenu <> nil) then
      PageMenu.ActivePage:= TabMenu;
  except
  end;}
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

end.
