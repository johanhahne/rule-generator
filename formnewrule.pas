unit FormNewRule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { Tfrmnewrule }

  Tfrmnewrule = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Comboinput: TComboBox;
    Comboinputstate: TComboBox;
    Combofunction: TComboBox;
    ComboEhr: TComboBox;
    ComboEmin: TComboBox;
    comboFuncState: TComboBox;
    ComboLongPress: TComboBox;
    ComboShr: TComboBox;
    ComboSmin: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmnewrule: Tfrmnewrule;

implementation

{$R *.lfm}

{ Tfrmnewrule }

procedure Tfrmnewrule.Button1Click(Sender: TObject);
begin
  self.ModalResult:=mrOK;
end;

procedure Tfrmnewrule.Button2Click(Sender: TObject);
begin
   self.ModalResult:=mrCancel;
end;

end.

