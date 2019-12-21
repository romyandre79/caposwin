unit uRESTRequest;

interface

uses
  Classes, SysUtils, IdHTTP, fpjson, jsonparser;

Const
 UrlBase = 'http://%s:%d/';

Type
 TRSCharset = (rscUTF8, rscANSI);
 TSendEvent = (seGET,   sePOST, sePUT, seDELETE);

Type
 TRESTClient = Class(TComponent) //Novo Componente de Acesso a Requisições REST para o RESTDataware
 Protected
  //Variáveis, Procedures e  Funções Protegidas
  HttpRequest : TIdHTTP;
 Private
  //Variáveis, Procedures e Funções Privadas
  vRSCharset : TRSCharset;
  vHost      : String;
  vPort      : Integer;
 Public
  //Métodos, Propriedades, Variáveis, Procedures e Funções Publicas
  Function    SendEvent(EventData : String)              : String;Overload;
  Function    SendEvent(EventData : String;
                        RBody     : TStringList;
                        EventType : TSendEvent = sePOST) : String;Overload;
  Constructor Create(AOwner: TComponent);
  Destructor  Destroy;
 Published
  //Métodos e Propriedades
  Property Charset : TRSCharset Read vRSCharset Write vRSCharset;
  Property Host    : String     Read vHost      Write vHost;
  Property Port    : Integer    Read vPort      Write vPort;
End;

implementation

Function TRESTClient.SendEvent(EventData : String) : String;
Var
 RBody : TStringList;
Begin
 Try
  Result := SendEvent(Format(UrlBase, [vHost, vPort]) + EventData, RBody, seGET);
 Except
 End;
End;

Function TRESTClient.SendEvent(EventData : String;
                               RBody     : TStringList;
                               EventType : TSendEvent = sePOST) : String;
Var
 StringStream : TStringStream;
 vURL         : String;
Begin
 Try
  If Pos(Uppercase(Format(UrlBase, [vHost, vPort])), Uppercase(EventData)) = 0 Then
   vURL := LowerCase(Format(UrlBase, [vHost, vPort]) + EventData)
  Else
   vURL := LowerCase(EventData);
  If vRSCharset = rscUTF8 Then
   HttpRequest.Request.Charset := 'utf-8'
  Else If vRSCharset = rscANSI Then
   HttpRequest.Request.Charset := 'ansi';
  Case EventType Of
   seGET : Result := HttpRequest.Get(vURL);
   sePOST,
   sePUT,
   seDELETE :
    Begin;
     If EventType = sePOST Then
      Result := HttpRequest.Post(vURL, RBody)
     Else If EventType = sePUT Then
      Begin
       StringStream := TStringStream.Create(RBody.Text);
       Result := HttpRequest.Put(vURL, StringStream);
       StringStream.Free;
      End
     Else If EventType = seDELETE Then
      Result := HttpRequest.Delete(vURL);
    End;
  End;
 Except

 End;
End;

Constructor TRESTClient.Create(AOwner: TComponent);
Begin
 Inherited;
 HttpRequest := TIdHTTP.Create(Nil);
 HttpRequest.Request.ContentType := 'application/json';
 vHost       := 'localhost';
 vPort       := 8080;
End;

Destructor  TRESTClient.Destroy;
Begin
 HttpRequest.Free;
 Inherited;
End;

end.

