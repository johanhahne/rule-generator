unit editmapfilesform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, DBGrids,unitconnectionsandstuff;

type
      TchangedRadio = procedure(Sender : Tobject;data:string) of object;



  { TFormmapfileeditor }

  TFormmapfileeditor = class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    ComboValOne: TComboBox;
    ComboValTwo: TComboBox;
    ComboValThree: TComboBox;
    DBGrid1: TDBGrid;
    Memo1: TMemo;
    Panel2: TPanel;
    Panel3: TPanel;
    Radiofunctionmap: TRadioButton;
    Radioinputmap: TRadioButton;
    Radiofunctionstate: TRadioButton;
    Radioinputstate: TRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
    procedure RadioinputstateChange(Sender: TObject);
         procedure addToCombo(combo: TComboBox; Avalue: string);
  private

    FchangedRadio:TchangedRadio;
    { private declarations }
  public
    { public declarations }
    currentfile:string;
       procedure addMaplistToCombo(combo:TComboBox;maplist:Tmaplist;field:string) ;
       published
    property changedRadio:TchangedRadio read FchangedRadio write FchangedRadio ;
  end;

var
  Formmapfileeditor: TFormmapfileeditor;

implementation

{$R *.lfm}

{ TFormmapfileeditor }

procedure TFormmapfileeditor.Panel3Click(Sender: TObject);
begin

end;

procedure TFormmapfileeditor.FormCreate(Sender: TObject);
begin

end;

procedure TFormmapfileeditor.Button1Click(Sender: TObject);

  var
  line,sone,stwo,sthree:string;
begin
  sone:=ComboValOne.text;
  stwo:=ComboValtwo.text;
  sthree:=ComboValthree.text;
  line := ComboBox1.text +','+sone;
 if (ComboBox1.text <> '') and (trim(sone) <>'') then
 begin
      if trim(stwo) <>'' then
             begin
                    line:=line+','+stwo;
                    if trim(sthree) <>'' then
                    begin
                           line:=line+','+sthree;
                    end;
             end;
      memo1.Lines.Add(line);

 end;
       RadioinputstateChange(self);
end;

procedure TFormmapfileeditor.RadioinputstateChange(Sender: TObject);
begin
 memo1.Lines.SaveToFile(currentfile);
  if Assigned(FchangedRadio) then FchangedRadio(Sender,'');



end;

procedure TFormmapfileeditor.addToCombo(combo:TComboBox;Avalue:string);
var
  i:integer;
  found:boolean;
begin
  found:=false;
  for i := 0 to combo.Items.Count-1 do
  begin
    if combo.Items[i]= Avalue then
    found:=true;
  end;
  if not found then combo.Items.Add(Avalue);


end;

procedure TFormmapfileeditor.addMaplistToCombo(combo: TComboBox;
  maplist: Tmaplist; field: string);
var
  i:integer;
begin
  combo.Clear;
     for i := 0 to length(maplist)-1 do
     begin
       if Field='name' then
       addToCombo(combo,maplist[i].name);
       if Field='bus' then
              addToCombo(combo,maplist[i].bus);
       if Field='module'then
              addToCombo(combo,maplist[i].module);
       if Field='port'then
              addToCombo(combo,maplist[i].port);
       if Field='state'then
              addToCombo(combo,maplist[i].state);
     end;
     combo.Refresh;
end;

end.

