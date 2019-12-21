unit ucphelper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, ZComponent, ZConnection;

implementation

function GetConnection: TZConnection;
var fileini: TIniFile;
begin
     fileini:= TIniFile.Create('caperp.ini');
     try
       GetConnection:= TZConnection.Create(nil);
       GetConnection.Catalog:= fileini.ReadString('DB','dbname','capellafive');
       GetConnection.Database:= fileini.ReadString('DB','dbname','capellafive');
       GetConnection.HostName:= fileini.ReadString('DB','dbname','capellafive');
     finally
       FreeAndNil(fileini);
     end;
end;

end.

