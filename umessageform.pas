unit umessageform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, ExtCtrls,
  StdCtrls;

type

  { TMessageForm }

  TMessageForm = class(TForm)
    btnClose: TBitBtn;
    ImageMessage: TImage;
    MessageMemo: TMemo;
    procedure btnCloseClick(Sender: TObject);
  private

  public
    Message: string;
    Title: string;
  end;

var
  MessageForm: TMessageForm;

implementation

{$R *.lfm}

{ TMessageForm }

procedure TMessageForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.

