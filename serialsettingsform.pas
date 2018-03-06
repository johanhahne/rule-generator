unit serialsettingsform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TfrmSerialSettings }

  TfrmSerialSettings = class(TForm)
    Button1: TButton;
    Button2: TButton;
    combo_connection_type: TComboBox;
    Combo_serialSpeed: TComboBox;
    Combo_serial_ports: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Panel_network: TPanel;
    Panel_serial: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure combo_connection_typeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmSerialSettings: TfrmSerialSettings;

implementation

{$R *.lfm}

{ TfrmSerialSettings }

procedure TfrmSerialSettings.FormShow(Sender: TObject);
var
 j, i:integer;
 serials:tstringlist;
begin
   Combo_serial_ports.clear;
   serials:=tstringlist.create;
  FindAllFiles(serials,'/dev/','ttyUSB*',false,faAnyFile);
  FindAllFiles(serials,'/dev/','ttyACM*',false,faAnyFile);
   for j := 0 to serials.Count -1 do
         begin
         Combo_serial_ports.AddItem(serials[j],nil);
   end;
  serials.free;
  if Combo_serial_ports.Items.Count>0 then
  Combo_serial_ports.ItemIndex:=0;

end;

procedure TfrmSerialSettings.Button1Click(Sender: TObject);
begin
  self.ModalResult := mrOK;
end;

procedure TfrmSerialSettings.Button2Click(Sender: TObject);
begin
  self.ModalResult:=mrNone;
  self.Close;
end;

procedure TfrmSerialSettings.combo_connection_typeChange(Sender: TObject);
begin
  if combo_connection_type.Text='Serial' then
  begin
     Panel_network.Visible:=false;
     Panel_serial.Visible:=true;
  end
  else
  begin
  Panel_network.Visible:=true;
  Panel_serial.Visible:=false;
  end;
end;

procedure TfrmSerialSettings.FormCreate(Sender: TObject);
begin

end;

end.

