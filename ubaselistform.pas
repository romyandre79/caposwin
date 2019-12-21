unit ubaselistform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, uBaseForm;

type

  { TBaseListForm }

  TBaseListForm = class(TBaseForm)
    tobBaseList: TToolBar;
    btnNew: TToolButton;
  private

  public

  end;

var
  BaseListForm: TBaseListForm;

implementation

{$R *.lfm}

end.

