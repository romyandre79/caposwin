program caposwin;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, memdslaz, uBaseForm, uloginform, umessageform, uutility
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='Capella ERP Indonesia';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TLoginForm, LoginForm);
  Application.Run;
end.

