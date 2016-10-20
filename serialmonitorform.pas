unit serialmonitorform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  LazHelpHTML, Menus, ExtCtrls,unitconnectionsandstuff;

type

  { TFrmSerialMonitor }

  TFrmSerialMonitor = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
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

procedure TFrmSerialMonitor.Button1Click(Sender: TObject);
begin
  connectionsandstuff.SdpoSerial1.WriteData('!'+Edit1.Text+'#');
end;

procedure TFrmSerialMonitor.Panel1Click(Sender: TObject);
begin

end;

end.

