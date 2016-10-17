unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Menus, ExtCtrls, SdpoSerial,contnrs, simpleipc,Unit2,Unit3, db;

type


    TmapRec = record
    name:string;
    bus,module,port,state:string;
  end;

  TruleRec = record
    guid,rulegroup,rulename,inpbus,inpmodule,inpport,inpstate,outpbus,outpport,outpmodule,outpstate,hrstart,minstart,hrend,minend,lpressec,mapbuttonname,mapfunctionname,mapbuttonstate,mapfuctionstate:string;
  end;
  rulerecpointer = ^Trulerec;


  Tdescr = class(Tobject)
    desc:string;
  end;

  Trulelist = array of TruleRec;
  Tmaplist = array of TmapRec;



  { TForm1 }

  TForm1 = class(TForm)
    btnconnectserial: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Combo_frmhr: TComboBox;
    Combo_frmmin: TComboBox;
    combo_inpbus1: TComboBox;
    combo_inpport1: TComboBox;
    combo_inpstate1: TComboBox;
    Combo_longpress_sec1: TComboBox;
    combo_outpmodule: TComboBox;
    combo_outpport: TComboBox;
    combo_outpstate: TComboBox;
    Combo_longpress_sec: TComboBox;
    combo_inpbutton: TComboBox;
    combo_inpstate: TComboBox;
    combo_outpstate1: TComboBox;
    Combo_outputbus: TComboBox;
    Combo_function_Name: TComboBox;
    combo_rulename: TComboBox;
    combo_rulegroup: TComboBox;
    Combo_tohr: TComboBox;
    Combo_tomin: TComboBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
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
    Panel6: TPanel;
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
    procedure Button6Click(Sender: TObject);
    procedure compChange(Sender: TObject);
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
    procedure TreeView1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure WriteToArray(var Avalue:TruleRec;guid:string);
    procedure GenArduinoRules(var A: Tstringlist);
    procedure SendSerialData(Header,data:string);
  private
    procedure addRuleToTreeview(var rulerec: TruleRec; treeview: TTreeView);
    function ComposeRule(rrec: TruleRec): string;
    procedure DeleteFromrules(var A: Trulelist; const Index: Cardinal);
    procedure fillCombo(combo:TComboBox;list:Tmaplist);
    procedure fillTimeCombo;
    function getNameFromMaplist(bus,module, port: string; list: Tmaplist): string;
    function getTreenode(nodename: string;treeview:ttreeview): ttreenode;

    function getValFromMaplist(Mapname, valToGet: string; list: Tmaplist): string;

    procedure loadMapFile(filename: string; maplist: Tmaplist);
    procedure resetChangedColors;
    procedure loadfuncMapfile(filename,listtype:string;var  list:Tmaplist);
    { private declarations }
  public
    { public declarations }
    var
  filename:string;

  rulelist : Trulelist;
  nodedescr:Tdescr;
  current_rule,lastgroup,lastrule,serialbuff:string;
   buttonmaplist,buttonStateMaplist: Tmaplist;
   functionmaplist,functionStateMaplist: Tmaplist;
   changed_controls: TObjectList;
   loadingdata:boolean;
   prulerec:rulerecpointer;
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
refreshdata;
SaveFile(false);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  try
  if TreeView1.Selected =nil then
   SaveRules(true)
   else
   SaveRules(false);
 //  lastgroup:=combo_rulegroup.text;
 //  lastrule:=combo_rulename.text;
 //refreshdata;
 //SaveFile(false);

 resetChangedColors
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

procedure TForm1.Button6Click(Sender: TObject);
begin
     SaveRules(true);
 //  lastgroup:=combo_rulegroup.text;
 //  lastrule:=combo_rulename.text;
 //refreshdata;
 //SaveFile(false);

 resetChangedColors
end;

procedure TForm1.compChange(Sender: TObject);
begin

   if loadingdata=false then
   begin
   if TWinControl(sender).Color <> clRed then
   changed_controls.Add(sender);
   TWinControl(sender).Color := clRed;

   end;
end;
procedure TForm1.resetChangedColors;
var
  i,j:integer;
begin
     for i := changed_controls.Count-1 downto 0 do
     begin
        TWinControl(changed_controls[i]).Color := clAppWorkspace;
        changed_controls.Delete(i);
     end;

end;

procedure TForm1.loadfuncMapfile(filename, listtype: string; var  list: Tmaplist);
var
i:integer;
filestrings,rulestrings:tstringlist;
 g:TGuid;
begin
 filestrings:=TStringList.Create;
 filestrings.LoadFromFile(filename);

  SetLength(list,filestrings.Count);
   try
  for i := 0 to filestrings.Count-1 do
  begin
    if trim(filestrings[i])<>'' then
    begin

    rulestrings:=TStringList.Create;
    rulestrings.Delimiter:=',';
    rulestrings.StrictDelimiter:=true;
    rulestrings.DelimitedText:=filestrings[i];
    list[i].name:=rulestrings[0];
    if listtype='state' then
    begin
    list[i].state:=rulestrings[1];
    end;

    if (listtype='functions') or (listtype='buttons') then
    begin
     list[i].bus:=rulestrings[1];
     list[i].module:=rulestrings[2];
     list[i].port:=rulestrings[3];

    end;

    end;
  end;
      FreeAndNil(filestrings);
   except
       FreeAndNil(filestrings);
       ShowMessage('Error reading rule file');
   end;


end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
begin
    changed_controls:=TObjectList.create(False);
          loadfuncMapfile(ExtractFilePath(ParamStr(0))+'inputstatemap','state',buttonStateMaplist);
    loadfuncMapfile(ExtractFilePath(ParamStr(0))+'functionstatemap','state',functionStateMaplist);
    loadfuncMapfile(ExtractFilePath(ParamStr(0))+'inputmap','buttons',buttonmaplist);
    loadfuncMapfile(ExtractFilePath(ParamStr(0))+'functionmap','functions',functionmaplist);
    fillTimeCombo;
fillCombo(Combo_function_Name,functionmaplist);
fillCombo(combo_inpstate,buttonStateMaplist);
fillCombo(combo_inpbutton,buttonmaplist);
fillCombo(combo_outpstate1,functionStateMaplist);


end;
procedure tform1.fillCombo(combo:TComboBox;list:Tmaplist);
var
  i:integer;
begin
combo.Clear;
     for i := 0 to length(list)-1 do
     begin
       combo.AddItem(list[i].name,nil);
     end;

end;

procedure TForm1.fillTimeCombo;
var
  i:integer;
begin
            for i := 0 to 63 do
 begin
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
  Combo_tomin.ItemIndex:=59;
  Combo_frmmin.ItemIndex:=0;
  Combo_frmhr.ItemIndex:=0;
  Combo_tohr.ItemIndex:=59;
end;

procedure TForm1.loadfile;
var
i:integer;
filestrings,rulestrings:tstringlist;
 g:TGuid;
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
    CreateGUID(g);
    if rulestrings[14]='0' then
    rulelist[i].guid:=GUIDToString(g)
    else
    rulelist[i].guid:=rulestrings[14];
    rulelist[i].lpressec:=rulestrings[15];
    rulelist[i].mapbuttonstate:=rulestrings[16];
    rulelist[i].mapfuctionstate:=rulestrings[17];

    rulelist[i].mapbuttonname:=getNameFromMaplist(rulelist[i].inpbus,rulelist[i].inpmodule,rulelist[i].inpport,buttonmaplist);
    rulelist[i].mapfunctionname:=getNameFromMaplist(rulelist[i].outpbus,rulelist[i].outpmodule,rulelist[i].outpport,functionmaplist);

    finally
      FreeAndNil(rulestrings);

    end;

    end;
  end;
      FreeAndNil(filestrings);
   except
       FreeAndNil(filestrings);
       ShowMessage('Error reading rule file');
   end;


end;


procedure TForm1.loadMapFile(filename:string; maplist: Tmaplist);
var
i:integer;
filestrings,mapstrings:tstringlist;

begin
 mapstrings:=TStringList.Create;
 filestrings:=TStringList.Create;
  filestrings.LoadFromFile(filename);
  SetLength(maplist,mapstrings.Count);
   try
  for i := 0 to filestrings.Count-1 do
  begin
    if trim(filestrings[i])<>'' then
    begin
    try
    mapstrings:=TStringList.Create;
    mapstrings.Delimiter:=',';
    mapstrings.StrictDelimiter:=true;
    mapstrings.DelimitedText:=filestrings[i];
    maplist[i].name:=mapstrings[0];
    maplist[i].bus:=mapstrings[1];
    maplist[i].module:=mapstrings[2];
    maplist[i].port:=mapstrings[3];

    finally
      FreeAndNil(mapstrings);

    end;

    end;
  end;
      FreeAndNil(filestrings);
   except
       FreeAndNil(filestrings);
       ShowMessage('Error reading map file ' +filename);
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
   addstring:= ComposeRule(rulelist[i]);
    sfile.Add(addstring);

 end;
 sfile.SaveToFile(filename);
  if SaveAs then
 ShowMessage('file saved to: '+filename);
end;
function tform1.ComposeRule(rrec:TruleRec):string;
begin
 result:= rrec.rulegroup +','+  rrec.rulename+','+ rrec.inpbus +','+  rrec.inpmodule+','+ rrec.inpport +','+ rrec.inpstate
   +','+ rrec.outpbus +','+ rrec.outpmodule +','+ rrec.outpport +','+ rrec.outpstate +','+ rrec.hrstart +','+ rrec.minstart +','+ rrec.hrend
   +','+ rrec.minend +','+ rrec.guid +','+ rrec.lpressec+','+ rrec.mapbuttonstate+','+ rrec.mapfuctionstate;


end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  loadfile;
  refreshdata;
  //if TreeView1.items.Count>0 then
   // TreeView1.Selected. :=TreeView1.Items[0];
end;

procedure TForm1.Panel1Click(Sender: TObject);
begin

end;

procedure TForm1.refreshdata;
var

i,j:integer;
found:boolean;

begin
  TreeView1.Items.Clear;

  for i := 0 to length(rulelist)-1 do
  begin
     addRuleToTreeview(rulelist[i],TreeView1);
    end;
  end;




  procedure TForm1.addRuleToTreeview(var rulerec: TruleRec; treeview: TTreeView);
var
  tn,tn1:TTreeNode;
begin
 new(prulerec);
     tn :=  getTreenode(rulerec.rulegroup ,TreeView1);
    if  tn <> nil then
    begin
    tn1 := TreeView1.Items.AddChild(tn,rulerec.rulename);
    prulerec:=@rulerec;
    tn1.Data:=prulerec;

end;

end;

function TForm1.getTreenode(nodename: string; treeview: ttreeview): ttreenode;
var
j:integer;
begin
   for j := 0 to TreeView1.Items.Count-1 do
    begin
      if TreeView1.Items[j].Text = nodename then
      begin
      result := treeview.items[j];
      break;
      end
      else
   result:=nil;

    end ;
  if TreeView1.Items.Count =0 then
   result:=nil;
    if result=nil then
   result:= TreeView1.Items.Add(nil,nodename);
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
 if TreeView1.Selected<>nil then
if TreeView1.Selected.Data<>nil then
   begin
   memo2.Text:=ComposeRule(rulerecpointer(TreeView1.Selected.Data)^);
   current_rule:=rulerecpointer(TreeView1.Selected.Data)^.guid;

   PopulateDataFields;
   end;
   except

   end;


   end;



procedure TForm1.PopulateDataFields;
var
i:integer;
begin
     loadingdata:=true;
     combo_rulegroup.Text:=rulerecpointer(TreeView1.Selected.Data)^.rulegroup;
     combo_rulename.Text:=rulerecpointer(TreeView1.Selected.Data)^.rulename;
     Combo_frmhr.Text:=rulerecpointer(TreeView1.Selected.Data)^.hrstart;
     Combo_frmmin.Text:=rulerecpointer(TreeView1.Selected.Data)^.minstart;
     combo_inpbutton.Text:=rulerecpointer(TreeView1.Selected.Data)^.mapbuttonname;
  //   combo_inpport.Text:=rulelist[i].inpport;
   combo_inpstate.Text:=rulerecpointer(TreeView1.Selected.Data)^.mapbuttonstate;
   Combo_longpress_sec.Text:=rulerecpointer(TreeView1.Selected.Data)^.lpressec;
   Combo_function_Name.Text:=rulerecpointer(TreeView1.Selected.Data)^.mapfunctionname;
  //   combo_outpport.Text:=rulelist[i].outpport;
 combo_outpstate1.Text:=rulerecpointer(TreeView1.Selected.Data)^.mapfuctionstate;
     Combo_tohr.Text:=rulerecpointer(TreeView1.Selected.Data)^.hrend;
     Combo_tomin.Text:=rulerecpointer(TreeView1.Selected.Data)^.minend;
    // Combo_outputbus.text:=rulerecpointer(TreeView1.Selected.Data)^.outpbus;
     loadingdata:=false;



end;

procedure TForm1.SaveRules(SaveAs: boolean);
var
found:boolean;
i,foundindex:integer;
newname:string;
g:tguid;
begin
 {
 found:=false;
 if not SaveAs then
begin
 for i := 0 to Length(rulelist)-1 do
 begin
   if rulelist[i].guid=current_rule then
   begin
          begin
                WriteToArray(rulelist[i],current_rule);
                found:=true;
                break;
          end ;
    end;
   end;
 end;
  }


   if not SaveAs then
 begin
    WriteToArray(rulerecpointer(TreeView1.Selected.Data)^,rulerecpointer(TreeView1.Selected.Data)^.guid);

 end;

 if SaveAs then
 begin
   CreateGUID(g);
   SetLength(rulelist,length(rulelist)+1);
   WriteToArray(rulelist[length(rulelist)-1],GUIDToString(g));
   addRuleToTreeview(rulelist[length(rulelist)-1],TreeView1);
   end;
 end;




procedure TForm1.TreeView1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept:=true;
end;

procedure TForm1.WriteToArray(var Avalue: TruleRec;guid:string);
var
g:TGuid;

begin
     CreateGUID(g);

     Avalue.rulegroup:=combo_rulegroup.Text;
     Avalue.rulename:=combo_rulename.Text;
    Avalue.inpbus:=getValFromMaplist(combo_inpbutton.Text,'bus',buttonmaplist);
    Avalue.inpmodule:=getValFromMaplist(combo_inpbutton.Text,'module',buttonmaplist);
    Avalue.inpport:= getValFromMaplist(combo_inpbutton.Text,'port',buttonmaplist);
    Avalue.inpstate:=getValFromMaplist(combo_inpstate.Text,'state',buttonStateMaplist);
    Avalue.outpbus:=getValFromMaplist(Combo_outputbus.text,'state',functionStateMaplist);
    Avalue.outpmodule:=getValFromMaplist(combo_outpmodule.Text,'module', functionmaplist);
    Avalue.outpport:=getValFromMaplist(combo_outpport.Text,'port',functionmaplist);
    Avalue.outpstate:=getValFromMaplist(combo_outpstate.Text,'state',functionmaplist);
    Avalue.hrstart:=Combo_frmhr.Text;
    Avalue.minstart:=Combo_frmmin.Text;
    Avalue.hrend:=Combo_tohr.Text;
    Avalue.minend:=Combo_tomin.Text;
    Avalue.lpressec:=Combo_longpress_sec.text;
    if guid='' then
    Avalue.guid:=GUIDToString(g)
    else
    Avalue.guid:=guid;
    Avalue.mapbuttonname:=combo_inpbutton.Text;
    Avalue.mapbuttonstate:=combo_inpstate.Text;
    Avalue.mapfuctionstate:=combo_outpstate1.Text;
    Avalue.mapfunctionname:=Combo_function_Name.Text;

end;

function TForm1.getNameFromMaplist(bus,module,port:string;list:Tmaplist) :string;
var
i:integer;
begin
    for i := 0 to Length(list)-1 do
    begin
        if (list[i].bus = bus) and (list[i].port = port) and (list[i].module=module) then
        begin
           Result:=list[i].name;
           break;
        end;
    end;
end;
function TForm1.getValFromMaplist(Mapname,valToGet:string;list:Tmaplist) :string;
var
i:integer;
begin
    for i := 0 to Length(list)-1 do
    begin
        if Mapname= list[i].name then
        begin
        if valToGet='bus' then
           Result:=list[i].bus
           else
           if valToGet='module' then
           Result:=list[i].module
           else
           if valToGet='port' then
           Result:=list[i].port
           else
           if valToGet='state' then
           Result:=list[i].state;
           break;
        end;
    end;
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

