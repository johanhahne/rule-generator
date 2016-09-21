unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Menus, ExtCtrls, SdpoSerial,contnrs,Unit2,Unit3, db;

type
  TruleRec = record
    guid,rulegroup,rulename,inpbus,inpmodule,inpport,inpstate,outpbus,outpport,outpmodule,outpstate,hrstart,minstart,hrend,minend,lpressec:string;

  end;

  Tdescr = class(Tobject)
    desc:string;
  end;

  Trulelist = array of TruleRec;

  { TForm1 }

  TForm1 = class(TForm)
    btnconnectserial: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Combo_frmhr: TComboBox;
    Combo_frmmin: TComboBox;
    combo_outpmodule: TComboBox;
    combo_outpport: TComboBox;
    combo_outpstate: TComboBox;
    Combo_longpress_sec: TComboBox;
    combo_inpbus: TComboBox;
    combo_inpport: TComboBox;
    combo_inpstate: TComboBox;
    Combo_outputbus: TComboBox;
    combo_rulename: TComboBox;
    combo_rulegroup: TComboBox;
    Combo_tohr: TComboBox;
    Combo_tomin: TComboBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    MainMenu1: TMainMenu;
    MainMenu2: TMainMenu;
    MainMenu3: TMainMenu;
    Memo1: TMemo;
    Memo2: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    SdpoSerial1: TSdpoSerial;
    Splitter1: TSplitter;
    TreeView1: TTreeView;
    procedure btnconnectserialClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure combo_inpstateChange(Sender: TObject);
    procedure Combo_longpress_secChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure loadfile;
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure SaveFile(SaveAs:boolean);
    procedure MenuItem2Click(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure refreshdata;
    procedure SdpoSerial1RxData(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure TreeView1Click(Sender: TObject);
    procedure PopulateDataFields;
    procedure SaveRules(SaveAs:boolean);
    procedure WriteToArray(var Avalue:TruleRec);
    procedure GenArduinoRules(var A: Tstringlist);
    procedure SendSerialData(Header,data:string);
  private
    procedure DeleteFromrules(var A: Trulelist; const Index: Cardinal);
    { private declarations }
  public
    { public declarations }
    var
  filename:string;

  rulelist : Trulelist;
  nodedescr:Tdescr;
  lastgroup,lastrule,serialbuff:string;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnconnectserialClick(Sender: TObject);
begin
       if SdpoSerial1.Active then
       begin
       SdpoSerial1.Active := false;
       btnconnectserial.Caption:='Not Connected';
       end;
    if frmSerialSettings.ShowModal=mrOK then
  begin
    if SdpoSerial1.Active then SdpoSerial1.active:=false;
   case frmSerialSettings.Combo_serialSpeed.text of
       '4800': SdpoSerial1.BaudRate:=br__4800 ;
       '9600': SdpoSerial1.BaudRate:=br__9600 ;
       '57600': SdpoSerial1.BaudRate:=br_57600;
       '115200': SdpoSerial1.BaudRate:=br115200 ;
  end;
    SdpoSerial1.Device:=frmSerialSettings.Combo_serial_ports.Text;
   try
   SdpoSerial1.Active:=true;

   finally
   if SdpoSerial1.Active then btnconnectserial.Caption:='Connected';
   end;

  end;
 end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  SdpoSerial1.WriteData('!4#'+#10);
end;



procedure TForm1.Button2Click(Sender: TObject);
begin
  SaveRules(true);
  lastgroup:=combo_rulegroup.text;
  lastrule:=combo_rulename.text;
refreshdata;
SaveFile(false);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  try
   SaveRules(false);
   lastgroup:=combo_rulegroup.text;
   lastrule:=combo_rulename.text;
 refreshdata;
 SaveFile(false);
finally
end;

end;

procedure TForm1.Button4Click(Sender: TObject);
var
  i,idx:integer;
begin
   for i := 0 to Length(rulelist)-1 do
 begin
   if (rulelist[i].rulegroup=combo_rulegroup.Text) and (rulelist[i].rulename=combo_rulename.Text) then
   begin
       idx:=i;
       break;
   end;

 end;
   DeleteFromrules(rulelist,idx);
   refreshdata;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
    SdpoSerial1.WriteData('!5#'+#10);
end;

procedure TForm1.combo_inpstateChange(Sender: TObject);
begin



end;

procedure TForm1.Combo_longpress_secChange(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
begin
 for i := 0 to 63 do
 begin
   combo_inpport.AddItem(inttostr(i+1),nil);
   if i < 24 then
   begin
     if i < 10 then
     begin
     Combo_frmhr.AddItem('0'+inttostr(i),nil) ;
     Combo_tohr.AddItem('0'+inttostr(i),nil);
     end
     else
     begin
       Combo_frmhr.AddItem(inttostr(i),nil);
       Combo_tohr.AddItem(inttostr(i),nil);

     end;
     end;
   if i < 60 then
   begin
     if i < 10 then

     begin
     Combo_frmmin.AddItem('0'+inttostr(i),nil);
     Combo_tomin.AddItem('0'+inttostr(i),nil);
     end
     else
     begin
       Combo_frmmin.AddItem(inttostr(i),nil);
       Combo_tomin.AddItem(inttostr(i),nil);

     end;
     end;



   end;



  combo_inpport.ItemIndex:=0;
  Combo_tomin.ItemIndex:=59;
  Combo_frmmin.ItemIndex:=0;
  Combo_frmhr.ItemIndex:=0;
  Combo_tohr.ItemIndex:=59;
end;

procedure TForm1.loadfile;
var
i:integer;
filestrings,rulestrings:tstringlist;

begin
 filestrings:=TStringList.Create;
 if OpenDialog1.Execute then
 begin
 filename:=OpenDialog1.FileName;
 filestrings.SaveToFile(filename+'.bak');
 filestrings.LoadFromFile(filename);
 filestrings.SaveToFile(filename+'.bak');

 end;
  SetLength(rulelist,filestrings.Count);
   try
  for i := 0 to filestrings.Count-1 do
  begin
    if trim(filestrings[i])<>'' then
    begin
    try
    rulestrings:=TStringList.Create;
    rulestrings.Delimiter:=',';
    rulestrings.StrictDelimiter:=true;
    rulestrings.DelimitedText:=filestrings[i];
    rulelist[i].rulegroup:=rulestrings[0];
    rulelist[i].rulename:=rulestrings[1];
    rulelist[i].inpbus:=rulestrings[2];
    rulelist[i].inpmodule:=rulestrings[3];
    rulelist[i].inpport:=rulestrings[4];
    rulelist[i].inpstate:=rulestrings[5];
    rulelist[i].outpbus:=rulestrings[6];
    rulelist[i].outpmodule:=rulestrings[7];
    rulelist[i].outpport:=rulestrings[8];
    rulelist[i].outpstate:=rulestrings[9];
    rulelist[i].hrstart:=rulestrings[10];
    rulelist[i].minstart:=rulestrings[11];
    rulelist[i].hrend:=rulestrings[12];
    rulelist[i].minend:=rulestrings[13];
    rulelist[i].guid:=rulestrings[14];
    rulelist[i].lpressec:=rulestrings[15];

    finally
      FreeAndNil(rulestrings);

    end;

    end;
  end;
      FreeAndNil(filestrings);
   except
       FreeAndNil(filestrings);
       ShowMessage('Error reading file');
   end;


end;

procedure TForm1.MenuItem11Click(Sender: TObject);
begin
  FrmSerialMonitor.Visible:= not FrmSerialMonitor.Visible;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  SaveFile(true);
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  SaveFile(false);
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  SaveFile(true);
end;

procedure TForm1.MenuItem7Click(Sender: TObject);
var
outpfilename:string;
oupstrings:TStringList;
begin
oupstrings:=TStringList.create;
GenArduinoRules(oupstrings);
   if SaveDialog2.execute then
      begin
      outpfilename:=SaveDialog2.FileName;
      end;
   if outpfilename <> '' then
      begin
      oupstrings.SaveToFile(outpfilename);
      end
      else
      ShowMessage('Invalid filename');
      freeandnil(oupstrings);



end;

procedure TForm1.MenuItem8Click(Sender: TObject);
var
i:integer;
oupstrings:TStringList;
begin
oupstrings:=TStringList.create;


    if SdpoSerial1.Active then
       begin

       GenArduinoRules(oupstrings);
      SdpoSerial1.WriteData('!2#'+#10);
       for i := 0 to oupstrings.Count -1 do
       begin

         SdpoSerial1.WriteData('!3,'+oupstrings[i]+'#'+#10);
         memo2.Append('!3,'+oupstrings[i]+'#'+#10);
          sleep(200);
       end;
       SdpoSerial1.WriteData('!4#'+#10);

       end
       else
       begin
         ShowMessage('Not connected');
       end;
 freeandnil(oupstrings);
end;

procedure TForm1.SaveFile(SaveAs: boolean);
var
  i:integer;
  sfile:tstringlist;
  addstring:string;

begin
 if SaveAs then
 begin
      if SaveDialog1.execute then
      begin
      filename:=SaveDialog1.FileName;
      end;
 end
 else
 begin

 end;

 sfile:=tstringlist.create;


 for i := 0 to length(rulelist)-1 do
 begin
   addstring:=rulelist[i].rulegroup +','+  rulelist[i].rulename+','+ rulelist[i].inpbus +','+  rulelist[i].inpmodule+','+ rulelist[i].inpport +','+ rulelist[i].inpstate
   +','+ rulelist[i].outpbus +','+ rulelist[i].outpmodule +','+ rulelist[i].outpport +','+ rulelist[i].outpstate +','+ rulelist[i].hrstart +','+ rulelist[i].minstart +','+ rulelist[i].hrend
   +','+ rulelist[i].minend +','+ rulelist[i].guid +','+ rulelist[i].lpressec;
    sfile.Add(addstring);

 end;
 sfile.SaveToFile(filename);
  if SaveAs then
 ShowMessage('file saved to: '+filename);












end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  loadfile;
  refreshdata;
  if TreeView1.items.Count>0 then
    TreeView1.Selected :=TreeView1.Items[0];
end;

procedure TForm1.Panel1Click(Sender: TObject);
begin

end;

procedure TForm1.refreshdata;
var
tn,tn1:TTreeNode;
i:integer;

found:boolean;
begin
 found:=false;


 TreeView1.Items.Clear;
 combo_rulegroup.Clear;
 for i := 0 to length(rulelist)-1 do
 begin
   tn := TreeView1.Items.FindNodeWithText(rulelist[i].rulegroup) ;
   if tn= nil then
   begin
        TreeView1.Items.add(nil,rulelist[i].rulegroup);
        tn := TreeView1.Items.FindNodeWithText(rulelist[i].rulegroup) ;
        combo_rulegroup.AddItem(rulelist[i].rulegroup,nil);
   end;
   end;
   combo_rulegroup.text:=lastgroup;
  for i := 0 to length(rulelist)-1 do
 begin
      tn := TreeView1.Items.FindNodeWithText(rulelist[i].rulegroup) ;
      tn1:=nil;
      tn1:= tn.FindNode(rulelist[i].rulename);
      if tn1=nil then
   tn1:=TreeView1.Items.AddChild(TreeView1.Items.FindNodeWithText(rulelist[i].rulegroup),rulelist[i].rulename);

   end;

 tn := TreeView1.Items.FindNodeWithText(lastgroup);
 if tn <> nil then
    begin
      tn1 := tn.FindNode(lastrule);
       if tn1 <> nil then
         begin
            TreeView1.Selected := tn1;

          end;


    end;

end;

procedure TForm1.SdpoSerial1RxData(Sender: TObject);
var
tmpstr:string;
begin
FrmSerialMonitor.Memo1.lines.add(SdpoSerial1.ReadData) ;
FrmSerialMonitor.Memo1.SelStart:=length(FrmSerialMonitor.Memo1.text);
FrmSerialMonitor.Memo1.SelLength:=0;
FrmSerialMonitor.Memo1.SetFocus;
end;

procedure TForm1.TreeView1Change(Sender: TObject; Node: TTreeNode);
begin

end;

procedure TForm1.TreeView1Click(Sender: TObject);
var
n:TTreeNode;
begin
 try
 if TreeView1.Items.Count>0 then
 if TreeView1.Selected.Level=1 then
   begin


 n:= TreeView1.Selected.Parent;
 if n <> nil then
 begin
      lastgroup:=n.Text;
      lastrule:=TreeView1.Selected.Text;

 end;
    PopulateDataFields;

 end;
   except

   end;

end;

procedure TForm1.PopulateDataFields;
var
i:integer;
begin
 for i := 0 to Length(rulelist)-1 do
 begin
   if (rulelist[i].rulegroup=TreeView1.Selected.Parent.Text) and (rulelist[i].rulename=TreeView1.Selected.Text) then
   begin
     combo_rulegroup.Text:=rulelist[i].rulegroup;
     combo_rulename.Text:=rulelist[i].rulename;
     Combo_frmhr.Text:=rulelist[i].hrstart;
     Combo_frmmin.Text:=rulelist[i].minstart;
     combo_inpbus.Text:=rulelist[i].inpbus;
     combo_inpport.Text:=rulelist[i].inpport;
     combo_inpstate.Text:=rulelist[i].inpstate;
     Combo_longpress_sec.Text:=rulelist[i].lpressec;
     combo_outpmodule.Text:=rulelist[i].outpmodule;
     combo_outpport.Text:=rulelist[i].outpport;
     combo_outpstate.Text:=rulelist[i].outpstate;
     Combo_tohr.Text:=rulelist[i].hrend;
     Combo_tomin.Text:=rulelist[i].minend;
     Combo_outputbus.text:=rulelist[i].outpbus;



   end;
 end;

end;

procedure TForm1.SaveRules(SaveAs: boolean);
var
found:boolean;
i,foundindex:integer;
newname:string;
begin
 found:=false;
 for i := 0 to Length(rulelist)-1 do
 begin
   if (rulelist[i].rulegroup=combo_rulegroup.Text) and (rulelist[i].rulename=combo_rulename.Text) then
   begin
     if not saveas then
          begin
                WriteToArray(rulelist[i]);
                found:=true;
                break;

          end
          else
          begin
           found:=true;
           break;
          end;
   end;
  end;
 if not found then saveas:=true;



if saveas then
 begin
   if found then
    begin
          newname:= InputBox('Name exists, enter new name','Enter new name!','');
           if trim(newname)<>''then
            begin
                 combo_rulename.Text:=newname;
                SetLength(rulelist,length(rulelist)+1);
                WriteToArray(rulelist[length(rulelist)-1]);

            end
           else
           ShowMessage('Empty name, nothing saved..');
   end
   else
   begin
   SetLength(rulelist,length(rulelist)+1);
   WriteToArray(rulelist[length(rulelist)-1]);
   end;
 end;



end;

procedure TForm1.WriteToArray(var Avalue: TruleRec);
begin
     Avalue.rulegroup:=combo_rulegroup.Text;
    Avalue.rulename:=combo_rulename.Text;
    Avalue.inpbus:=combo_inpbus.Text;
    Avalue.inpmodule:='0';
    Avalue.inpport:=combo_inpport.Text;
    Avalue.inpstate:=combo_inpstate.Text;
    Avalue.outpbus:=Combo_outputbus.text;
    Avalue.outpmodule:=combo_outpmodule.Text;
    Avalue.outpport:=combo_outpport.Text;
    Avalue.outpstate:=combo_outpstate.Text;
    Avalue.hrstart:=Combo_frmhr.Text;
    Avalue.minstart:=Combo_frmmin.Text;
    Avalue.hrend:=Combo_tohr.Text;
    Avalue.minend:=Combo_tomin.Text;
    Avalue.guid:='0';
    Avalue.lpressec:=Combo_longpress_sec.text;
end;

procedure TForm1.GenArduinoRules(var A: Tstringlist);
var
i:integer     ;
addstring:string;
begin
  for i := 0 to length(rulelist)-1 do
 begin
   addstring:=rulelist[i].inpbus +','+ rulelist[i].inpmodule +','+rulelist[i].inpport +','+ rulelist[i].inpstate
   +','+ rulelist[i].outpbus +','+ rulelist[i].outpmodule +','+ rulelist[i].outpport +','+ rulelist[i].outpstate +','+ rulelist[i].hrstart +','+ rulelist[i].minstart +','+ rulelist[i].hrend
   +','+ rulelist[i].minend +','+ rulelist[i].lpressec;

    a.Add(addstring);
 end;

end;

procedure TForm1.SendSerialData(Header, data: string);
begin
  {
    BT = Begin transmission
    DF = Delete File
    AS = Add string to file
    RD = Relay Data
    PF = Print File
    }





end;

procedure TForm1.DeleteFromrules(var A: Trulelist; const Index: Cardinal);
var
  ALength: Cardinal;
  TailElements: Cardinal;
begin
  ALength := Length(A);
  Assert(ALength > 0);
  Assert(Index < ALength);
  Finalize(A[Index]);
  TailElements := ALength - Index;
  if TailElements > 0 then
    Move(A[Index + 1], A[Index], SizeOf(TruleRec) * TailElements);
  Initialize(A[ALength - 1]);
  SetLength(A, ALength - 1);
end;


end.

