unit uBaseForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ActnList,
  ComCtrls, DBCtrls, DBGrids, uutility;

type

  { TBaseForm }

  TBaseForm = class(TForm)
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public

  protected

  end;

var
  BaseForm              : TBaseForm;

implementation

{$R *.lfm}

{ TBaseForm }

procedure TBaseForm.FormActivate(Sender: TObject);
begin
  //
end;

procedure TBaseForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //
end;

procedure TBaseForm.FormCreate(Sender: TObject);
begin
  //
  GetServerData();
end;

procedure TBaseForm.FormDestroy(Sender: TObject);
begin
  //
end;

end.

