unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  LazHelpHTML;

type

  { TFrmSerialMonitor }

  TFrmSerialMonitor = class(TForm)
    Memo1: TMemo;
    procedure Memo1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmSerialMonitor: TFrmSerialMonitor;

implementation

{$R *.lfm}

{ TFrmSerialMonitor }

procedure TFrmSerialMonitor.Memo1Change(Sender: TObject);
begin

end;

end.

