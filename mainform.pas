unit mainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Menus, ExtCtrls, DBGrids, ActnList, SdpoSerial, contnrs, simpleipc,
  serialsettingsform, serialmonitorform, db, SdfData, unitconnectionsandstuff,
  editmapfilesform, mainmdiform, functions,FormNewRule,fgl;

type


  {  TmapRec = record
    name:string;
    bus,module,port,state:string;
  end;
        }
  TruleRec = record
    guid,rulegroup,rulename,inpbus,inpmodule,inpport,inpstate,outpbus,outpport,outpmodule,outpstate,hrstart,minstart,hrend,minend,lpressec,mapbuttonname,mapfunctionname,mapbuttonstate,mapfuctionstate:string;
  end;
  rulerecpointer = ^Trulerec;


  Tdescr = class(Tobject)
    desc:string;
  end;

  Trulelist = array of TruleRec;
//  Tmaplist = array of TmapRec;

 //   TArduinoRuleFileslist = specialize TfpgObjectList<TArduinoFile>;

  { TForm1 }

  TForm1 = class(TForm)
    btnconnectserial: TButton;
    btnTestRule: TButton;
    ButNewRule: TButton;
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button2: TButton;
    Button3: TButton;
    Button5: TButton;
    Button7: TButton;
    Button9: TButton;
    Button_delete: TButton;
    combo_bus: TComboBox;
    Combo_mod: TComboBox;
    Combo_port: TComboBox;
    Combo_name: TComboBox;
    ComboEhr: TComboBox;
    ComboEmin: TComboBox;
    ComboLongPress: TComboBox;
    ComboShr: TComboBox;
    ComboSmin: TComboBox;
    Combosorttype: TComboBox;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Label19: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    ListBox_mapfiles: TListBox;
    listbox_files_on_sd: TListBox;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel2: TPanel;
    Panel_dbgrid: TPanel;
    Panel_treeview: TPanel;
    Panel5: TPanel;
    Panel_input_map: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    pnlcombos: TPanel;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    SdfDataSet1: TSdfDataSet;
    Splitter1: TSplitter;
    TreeView1: TTreeView;
    procedure btnconnectserialClick(Sender: TObject);
    procedure ButNewRuleClick(Sender: TObject);

    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button_deleteClick(Sender: TObject);
    procedure CombosorttypeChange(Sender: TObject);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure FormCreate(Sender: TObject);
    procedure listbox_files_on_sdChangeBounds(Sender: TObject);
    procedure listbox_files_on_sdClick(Sender: TObject);
    procedure listbox_files_on_sdDblClick(Sender: TObject);
    procedure ListBox_mapfilesClick(Sender: TObject);
    procedure ListBox_mapfilesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Populatetreeview(rulefile:TArduinoFile; treeview:TTreeView;clearfirst:boolean;sorttype:string);
    function addNode(treeview:ttreeview;ParentNode:TTreeNode;Newnodename:string):ttreenode;
    function addrootNodeToTreeView(treeview:ttreeview;Newnodename:string):ttreenode;
    function findInRuleFile(func,event,eventstate,funcstate:string):boolean;
    procedure SdpoSerial1RxData(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure fillcombos;
    procedure refreshFileListbox;
    function getArduinoFile(filename:string):TArduinoFile;
    procedure setCurrentRulefile(filename:string);
    function checkMapFiles:boolean;


  private
    procedure addfieldtocombo(dataset: tdataset; fieldindex: integer;
      combobox: TComboBox);
    function checkarduinofiles(filename: string): boolean;
    procedure fillListFilesOnSD(Adata: String);
    procedure fill_inp_map_combos(mapfile: TArduinoFile);
    procedure ParseInputSerialData(Adata: string);
    procedure recievedata(data: string);
    procedure SendSerialData(Header, data: string);
    procedure populatelist(listbox:TListBox;dataset:TDataSet;fldidx:integer);

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
   //Arduinorulefiles:Tarduinorulefileslist;
      Arduinorulefiles:Tobjectlist;
   loadingdata:boolean;
   prulerec:rulerecpointer;
   serialdata:string;
   inputmapfile,functionmapfile,ismap,fsmap,activerulefile:TArduinoFile;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}
   {fieldnumbers in rulefile
 Const
   crfInpbus = 2;
   crfInpmod = 3;
   crfInpport = 4;
   crfinpstate = 5;
   crfoutpbus = 6;
   crfoutpmodule = 7;
   crfoutpport = 8;
   crfoutpstate = 9;
   crfhrstart = 10;
   crfminstart = 11;
   crfhrend = 12;
   crfminend = 13;
   crflpress = 15;
   {fieldnumbers in map inputstate}
   cmfIState=0;
   cmfIvalue=1;

   {fieldnumbers in map input}
   cmfINPname = 0;
   cmfINPbus = 1;
   cmfINPmod = 2;
   cmfINPport = 3;

   {fieldnumbers in map function state}
   cmfFState=0;
   cmfFvalue=1;

   {fieldnumbers in map functions}
   cmfFUname = 0;
   cmfFUbus = 1;
   cmfFUmod = 2;
   cmfFUport = 3;
                   }
 {fieldnumbers in rulefile }
 Const
   crfInpbus = 0;
   crfInpmod = 1;
   crfInpport = 2;
   crfinpstate = 3;
   crfoutpbus = 4;
   crfoutpmodule = 5;
   crfoutpport = 6;
   crfoutpstate = 7;
   crfhrstart = 8;
   crfminstart = 9;
   crfhrend = 10;
   crfminend = 11;
   crflpress = 12;
   {fieldnumbers in map inputstate}
   cmfIState=0;
   cmfIvalue=1;

   {fieldnumbers in map input}
   cmfINPname = 0;
   cmfINPbus = 1;
   cmfINPmod = 2;
   cmfINPport = 3;

   {fieldnumbers in map function state}
   cmfFState=0;
   cmfFvalue=1;

   {fieldnumbers in map functions}
   cmfFUname = 0;
   cmfFUbus = 1;
   cmfFUmod = 2;
   cmfFUport = 3;




{ TForm1 }

procedure TForm1.btnconnectserialClick(Sender: TObject);
begin
       if connectionsandstuff.SdpoSerial1.Active then
       begin
         connectionsandstuff.SdpoSerial1.Active := false;
         btnconnectserial.Caption:='Connect';
       end
       else
       begin
            if frmSerialSettings.ShowModal=mrOK then
          begin
            if connectionsandstuff.SdpoSerial1.Active then connectionsandstuff.SdpoSerial1.active:=false;
           case frmSerialSettings.Combo_serialSpeed.text of
               '4800': connectionsandstuff.SdpoSerial1.BaudRate:=br__4800 ;
               '9600': connectionsandstuff.SdpoSerial1.BaudRate:=br__9600 ;
               '57600': connectionsandstuff.SdpoSerial1.BaudRate:=br_57600;
               '115200': connectionsandstuff.SdpoSerial1.BaudRate:=br115200 ;
          end;
            connectionsandstuff.SdpoSerial1.Device:=frmSerialSettings.Combo_serial_ports.Text;
           try
           connectionsandstuff.SdpoSerial1.Active:=true;

           finally
           if connectionsandstuff.SdpoSerial1.Active then
             begin
                  FrmSerialMonitor.Memo1.lines.Clear;
                  btnconnectserial.Caption:='Connected';
                  FrmSerialMonitor.Visible:= true;
                 ConnectionsAndStuff.ReceiveData:=@recievedata;
              //    ConnectionsAndStuff.SdpoSerial1.OnRxData:=SdpoSerial1RxData;
             end;
           end;

          end;
       end;
 end;

procedure TForm1.ButNewRuleClick(Sender: TObject);
var
  node:TTreeNode;
  a:string;
begin

    if TreeView1.Selected <> nil then
      begin

              if TreeView1.Selected.Parent <> nil then
            begin
                 if TreeView1.Selected.Parent.Parent <> nil then
                   begin
                        if Combosorttype.Text='function' then
                        if TreeView1.Selected.Parent.Parent.parent <> nil then
                         begin
                                frmnewrule.Combofunction.text:=TreeView1.Selected.Parent.Parent.parent.text;
                                 frmnewrule.Comboinput.Text:=TreeView1.Selected.Parent.Parent.text; ;
                                 frmnewrule.comboFuncState.text:=TreeView1.Selected.text;
                                 frmnewrule.Comboinputstate.text:=TreeView1.Selected.Parent.text;
                         end;
                        if Combosorttype.Text='event' then
                        if TreeView1.Selected.Parent.Parent.parent <> nil then
                         begin
                                frmnewrule.Comboinput.text:=TreeView1.Selected.Parent.Parent.parent.text;
                                 frmnewrule.Combofunction.Text:=TreeView1.Selected.Parent.text; ;
                                 frmnewrule.comboFuncState.text:=TreeView1.Selected.text;
                                 frmnewrule.Comboinputstate.text:=TreeView1.Selected.Parent.parent.text;

                         end;



                   end;
            end;

      end;

  if frmnewrule.ShowModal = mrOK then
    begin


     activerulefile.dataset.Insert;
     activerulefile.dataset.Fields[crfInpbus].asstring:= inputmapfile.locateindataset(cmfINPbus,cmfINPname,frmnewrule.Comboinput.Text);
     activerulefile.dataset.Fields[crfInpmod].asstring:=inputmapfile.locateindataset(cmfINPmod,cmfINPname,frmnewrule.Comboinput.Text);
     activerulefile.dataset.Fields[crfInpport].asstring:=inputmapfile.locateindataset(cmfINPport,cmfINPname,frmnewrule.Comboinput.Text);
     a:=ismap.locateindataset(cmfIState,cmfIvalue,frmnewrule.Comboinputstate.Text);
     activerulefile.dataset.Fields[crfinpstate].asstring:=ismap.locateindataset(cmfIvalue,cmfIState,frmnewrule.Comboinputstate.Text);

     activerulefile.dataset.Fields[crfoutpbus].asstring:=functionmapfile.locateindataset(cmfFUbus,cmfFUname,frmnewrule.Combofunction.Text);
     activerulefile.dataset.Fields[crfoutpmodule].asstring:=functionmapfile.locateindataset(cmfFUmod,cmfFUname,frmnewrule.Combofunction.Text);
     activerulefile.dataset.Fields[crfoutpport].asstring:=functionmapfile.locateindataset(cmfFUport,cmfFUname,frmnewrule.Combofunction.Text);

     activerulefile.dataset.Fields[crfoutpstate].asstring:=fsmap.locateindataset(cmfFvalue,cmfFState,frmnewrule.comboFuncState.Text);

     activerulefile.dataset.Fields[crfhrstart].asstring:=frmnewrule.ComboShr.Text;
     activerulefile.dataset.Fields[crfminstart].asstring:=frmnewrule.ComboSmin.Text;
     activerulefile.dataset.Fields[crfhrend].asstring:=frmnewrule.ComboEhr.Text;
     activerulefile.dataset.Fields[crfminend].asstring:=frmnewrule.ComboEmin.Text;
     activerulefile.dataset.Fields[crflpress].asstring:=frmnewrule.ComboLongPress.Text;
     activerulefile.dataset.Post;
     Populatetreeview(activerulefile,TreeView1,false,Combosorttype.text);


    end;
end;

procedure TForm1.recievedata(data: string);
begin
      FrmSerialMonitor.Memo1.lines.add(data) ;
      FrmSerialMonitor.Memo1.SelStart:=length(FrmSerialMonitor.Memo1.text);
      FrmSerialMonitor.Memo1.SelLength:=0;
      FrmSerialMonitor.Memo1.SetFocus;
//          if pos('mapbutton',data) > 0 then
 //     identifyTriggerInput(data);


end;






procedure TForm1.Button10Click(Sender: TObject);
begin
  serialmonitorform.FrmSerialMonitor.Visible:= not   serialmonitorform.FrmSerialMonitor.Visible;
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
   Formmapfileeditor.Visible:= not   Formmapfileeditor.Visible;
end;

procedure TForm1.Button12Click(Sender: TObject);
var
  sl:tstringlist;
  a:string;
begin
  sl:=TStringList.Create;
  activerulefile.dataset.First;
  while not activerulefile.dataset.eof do
  begin
  a:=activerulefile.dataset.Fields[crfInpbus].asstring +';';
  a:=a+activerulefile.dataset.Fields[crfInpmod].asstring +';';
  a:=a+activerulefile.dataset.Fields[crfInpport].asstring +';';
    a:=a+activerulefile.dataset.Fields[crfinpstate].asstring +';';
    a:=a+activerulefile.dataset.Fields[crfoutpbus].asstring +';';
    a:=a+activerulefile.dataset.Fields[crfoutpmodule].asstring +';';
    a:=a+activerulefile.dataset.Fields[crfoutpport].asstring +';';
    a:=a+activerulefile.dataset.Fields[crfoutpstate].asstring +';';
    a:=a+activerulefile.dataset.Fields[crfhrstart].asstring +';';
    a:=a+activerulefile.dataset.Fields[crfminstart].asstring +';';
    a:=a+activerulefile.dataset.Fields[crfhrend].asstring +';';
    a:=a+activerulefile.dataset.Fields[crfminend].asstring +';';
    a:=a+activerulefile.dataset.Fields[crflpress].asstring ;
  sl.Add(a);
  activerulefile.dataset.next;

  end;
  sl.SaveToFile('/home/johan/main.r');
  sl.Destroy;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  connectionsandstuff.SdpoSerial1.WriteData('!4,rulefile#');
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  sl:tstringlist ;
  r:TArduinoFile;
begin

  sl:=TStringList.Create;
sl.LoadFromFile('/home/johan/git/rule-generator/functionmap');
functionmapfile:=TArduinoFile.create('functionmap',sl.Text);
 sl.Destroy;
 sl:=TStringList.Create;
 sl.LoadFromFile('/home/johan/git/rule-generator/functionstatemap');
 fsmap:=TArduinoFile.create('fsmap',sl.Text);
  sl.Destroy;

//sl:=TStringList.Create;
//sl.LoadFromFile('/home/johan/git/rule-generator/reglerodesberga.rules');

//r:=TArduinoFile.create('rulefile.r',sl.Text);

//Arduinorulefiles.Add(r);

// sl.Destroy;
 //DBGrid3.DataSource:=rulefile.datasource;
sl:=TStringList.Create;
sl.LoadFromFile('/home/johan/git/rule-generator/inputmap');
inputmapfile:=TArduinoFile.create('rulefile',sl.Text);
 sl.Destroy;
  sl:=TStringList.Create;
 sl.LoadFromFile('/home/johan/git/rule-generator/inputstatemap');
 ismap:=TArduinoFile.create('rulefile',sl.Text);
  sl.Destroy;



end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  activerulefile.dataset.Edit;
  activerulefile.dataset.Fields[crflpress].AsString:=ComboLongPress.Text;
  activerulefile.dataset.Fields[crfhrstart].AsString:=ComboShr.Text;
  activerulefile.dataset.Fields[crfhrend].AsString:=ComboEhr.Text;
  activerulefile.dataset.Fields[crfminstart].AsString:=ComboSmin.Text;
  activerulefile.dataset.Fields[crfminend].AsString:=ComboEmin.Text;
  activerulefile.dataset.Post;
  ShowMessage('Rule saved');
end;

function TForm1.checkarduinofiles(filename:string):boolean;
var
  i:integer;
begin
Result:=false;
  for i :=0 to Arduinorulefiles.Count-1 do
   begin
        if TArduinoFile(Arduinorulefiles.Items[i]).Filename = filename then
        begin
            result:=True;
            break;
        end;

   end;

end;

procedure TForm1.Button7Click(Sender: TObject);
var
r:TArduinoFile;
i:integer;
found:boolean;
sl:TStringList;
begin

  if OpenDialog1.Execute then
  begin
      if not checkarduinofiles(OpenDialog1.FileName) then
   begin
   sl:=TStringList.Create;
   sl.LoadFromFile(OpenDialog1.FileName);
   if ExtractFileName(OpenDialog1.FileName) = 'istate.m' then
   begin
        if Assigned(ismap) then FreeAndNil(ismap);
        ismap := TArduinoFile.create(ExtractFileName(OpenDialog1.FileName),sl.Text);
   end
   else
   if ExtractFileName(OpenDialog1.FileName) = 'inp.m' then
   begin
        if Assigned(inputmapfile) then FreeAndNil(inputmapfile);
        inputmapfile := TArduinoFile.create(ExtractFileName(OpenDialog1.FileName),sl.Text);
   end
   else
   if ExtractFileName(OpenDialog1.FileName) = 'fstate.m' then
   begin
        if Assigned(fsmap) then FreeAndNil(fsmap);
        fsmap := TArduinoFile.create(ExtractFileName(OpenDialog1.FileName),sl.Text);
   end
   else
   if ExtractFileName(OpenDialog1.FileName) = 'func.m' then
   begin
        if Assigned(functionmapfile) then FreeAndNil(functionmapfile);
        functionmapfile := TArduinoFile.create(ExtractFileName(OpenDialog1.FileName),sl.Text);
   end
   else
   begin
   r:=TArduinoFile.create(ExtractFileName(OpenDialog1.FileName),sl.Text);
   Arduinorulefiles.Add(r);
   end;
   sl.Destroy;
   refreshFileListbox;





   end
   else
   begin
        ShowMessage('Duplicate filename detected');
   end;
  end;


end;

procedure TForm1.Button_deleteClick(Sender: TObject);
var
node:TTreeNode;
begin
node:= TreeView1.Selected;
if node <> nil then
if node.Parent <> nil then
  begin
       if node.Parent.Parent <> nil then
         begin
              if node.Parent.Parent.parent <> nil then
               begin
                  if  MessageDlg('Delete rule?','Really?!',mtWarning,[mbOK, mbAbort],'') = mrOK then
                   begin
                    activerulefile.DataSet.edit;
                    activerulefile.DataSet.Delete;
                    Populatetreeview(activerulefile,TreeView1,true,Combosorttype.text);
                   end;

               end;
          end;
  end;

end;

procedure TForm1.CombosorttypeChange(Sender: TObject);
begin
   Populatetreeview(activerulefile,TreeView1,true,Combosorttype.text)
end;

procedure TForm1.DBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=46 then
     begin
      if  MessageDlg('Delete row?','Really?!',mtWarning,[mbOK, mbAbort],'') = mrOK then
         begin
          dbgrid1.DataSource.DataSet.edit;
          dbgrid1.DataSource.DataSet.Delete;
         end;
     end;

end;

procedure TForm1.FormCreate(Sender: TObject);

begin
form1.Top := 1;
    form1.Left := 1;
    form1.Align:=alClient;
    form1.BorderStyle := bsNone;
form1.Parent:=Form3;
Arduinorulefiles:=Tobjectlist.Create(true);
//rulefile:= TArduinoFile.create('','');






end;

procedure TForm1.listbox_files_on_sdChangeBounds(Sender: TObject);
begin
  if checkMapFiles then
setCurrentRulefile(listbox_files_on_sd.Items[listbox_files_on_sd.ItemIndex]);
end;

procedure TForm1.listbox_files_on_sdClick(Sender: TObject);
begin
  if checkMapFiles then
     begin
setCurrentRulefile(listbox_files_on_sd.Items[listbox_files_on_sd.ItemIndex]);

Panel_treeview.Visible:=true;
Panel_dbgrid.Visible:=false;
  editmapfilesform.Formmapfileeditor.DBGrid1.DataSource:=activerulefile.datasource;
     end;

end;

procedure TForm1.listbox_files_on_sdDblClick(Sender: TObject);
begin


end;
  procedure TForm1.fill_inp_map_combos(mapfile:TArduinoFile);

  begin
  combo_bus.Clear;
          Combo_mod.Clear;
          Combo_port.clear;
          Combo_name.Clear;
          mapfile.dataset.First;
          while not mapfile.dataset.eof do
                begin
                     Combo_name.AddItem(mapfile.dataset.Fields[cmfFUname].AsString,nil);
                     Combo_bus.AddItem(mapfile.dataset.Fields[cmfFUbus].AsString,nil);
                     Combo_mod.AddItem(mapfile.dataset.Fields[cmfFUmod].AsString,nil);
                     Combo_port.AddItem(mapfile.dataset.Fields[cmfFUport].AsString,nil);
                     mapfile.dataset.next;
                end;
  end;

procedure TForm1.ListBox_mapfilesClick(Sender: TObject);
begin

  Panel_treeview.Visible:=false;
  Panel_dbgrid.Visible:=true;

  if ListBox_mapfiles.Items[ListBox_mapfiles.ItemIndex] = 'istate.m' then
  begin
  DBGrid1.DataSource:=ismap.datasource;
          Panel_input_map.Visible:=false;
  end;
    if ListBox_mapfiles.Items[ListBox_mapfiles.ItemIndex] = 'inp.m' then
    begin
         fill_inp_map_combos(inputmapfile);
                 Panel_input_map.Visible:=true;
         DBGrid1.DataSource:=inputmapfile.datasource;
    end;
      if ListBox_mapfiles.Items[ListBox_mapfiles.ItemIndex] = 'fstate.m' then
      begin
        DBGrid1.DataSource:=fsmap.datasource;
                Panel_input_map.Visible:=false;
        end;

        if ListBox_mapfiles.Items[ListBox_mapfiles.ItemIndex] = 'func.m' then
        begin

        fill_inp_map_combos(functionmapfile);
        Panel_input_map.Visible:=true;
        DBGrid1.DataSource:=functionmapfile.datasource;

        end;
      end;



procedure TForm1.ListBox_mapfilesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TForm1.Populatetreeview(rulefile:TArduinoFile; treeview: TTreeView;clearfirst:boolean;sorttype:string);
var
i:integer;
n:TTreeNode;
begin
  if clearfirst then
treeview.Items.Clear;
rulefile.dataset.First;
if sorttype = 'function' then
for i := 0 to rulefile.dataset.RecordCount-1 do
    begin
    n:=addrootNodeToTreeView(treeview,functionmapfile.locateindataset(cmfFUname,cmfFUbus, rulefile.dataset.Fields[crfoutpbus].asstring,cmfFUmod, rulefile.dataset.Fields[crfoutpmodule].asstring,cmfFUport, rulefile.dataset.Fields[crfoutpport].asstring));
    n:=addNode(TreeView1,n,inputmapfile.locateindataset(cmfINPname,cmfINPbus, rulefile.dataset.Fields[crfInpbus].asstring,cmfINPmod, rulefile.dataset.Fields[crfInpmod].asstring,cmfINPport, rulefile.dataset.Fields[crfInpport].asstring));
    n:=addNode(TreeView1,n,ismap.locateindataset(cmfIState,cmfIvalue, rulefile.dataset.Fields[crfinpstate].asstring));
    n:=addNode(TreeView1,n,fsmap.locateindataset(cmfFState,cmfFvalue, rulefile.dataset.Fields[crfoutpstate].asstring));
    rulefile.dataset.Next;
    end;
if sorttype = 'event' then
for i := 0 to rulefile.dataset.RecordCount-1 do
    begin
    n:=addrootNodeToTreeView(treeview,inputmapfile.locateindataset(cmfINPname,cmfINPbus, rulefile.dataset.Fields[crfInpbus].asstring,cmfINPmod, rulefile.dataset.Fields[crfInpmod].asstring,cmfINPport, rulefile.dataset.Fields[crfInpport].asstring));
    n:=addNode(TreeView1,n,ismap.locateindataset(cmfIState,cmfIvalue, rulefile.dataset.Fields[crfinpstate].asstring));
    n:=addNode(TreeView1,n,functionmapfile.locateindataset(cmfFUname,cmfFUbus, rulefile.dataset.Fields[crfoutpbus].asstring,cmfFUmod, rulefile.dataset.Fields[crfoutpmodule].asstring,cmfFUport, rulefile.dataset.Fields[crfoutpport].asstring));
    n:=addNode(TreeView1,n,fsmap.locateindataset(cmfFState,cmfFvalue, rulefile.dataset.Fields[crfoutpstate].asstring));
    rulefile.dataset.Next;
    end;



end;

function TForm1.addNode(treeview:ttreeview;ParentNode: TTreeNode; Newnodename: string):ttreenode;
var
i:integer;
found:boolean;
n:ttreenode;
begin
found:=false;
for i :=0 to ParentNode.Count-1 do
    begin

                 if
                 ParentNode.items[i].Text=Newnodename then
                 begin
                     found:=true;
                     result:=ParentNode.items[i];
                 end;

    end;
    if found = false then
    begin
    result:= treeview.items.AddChild(ParentNode,Newnodename);

    end;


end;


function TForm1.addrootNodeToTreeView(treeview: ttreeview; Newnodename: string
  ): ttreenode;
var
i:integer;
found:boolean;
begin
found:=false;
for i :=0 to treeview.Items.Count-1 do
    begin
         if treeview.items[i].Parent=nil then
            begin
                 if
                 treeview.items[i].Text=Newnodename then
                 begin
                     found:=true;
                     result:=treeview.items[i];
                 end;

            end;
    end;
    if found = false then
    begin
    result:= treeview.Items.AddFirst(nil,Newnodename);
    end;
end;

function TForm1.findInRuleFile(func, event, eventstate,funcstate: string): boolean;
var
funcbus,funcmod,funcport,evbus,evmod,evport,evstate,functstate:string;
a: array of string;
b:array of integer;
begin

funcbus:= functionmapfile.locateindataset(cmfFUbus,cmfFUname, func);
funcmod:= functionmapfile.locateindataset(cmfFUmod,cmfFUname, func);
funcport:= functionmapfile.locateindataset(cmfFUport,cmfFUname, func);
evbus:= inputmapfile.locateindataset(cmfINPbus,cmfINPname, event);
evmod:= inputmapfile.locateindataset(cmfINPmod,cmfINPname, event);
evport:= inputmapfile.locateindataset(cmfINPport,cmfINPname, event);
evstate:= ismap.locateindataset(cmfIvalue,cmfIState, eventstate);
functstate:=fsmap.locateindataset(cmfFvalue,cmfFState, funcstate);
SetLength(b,8);
b[0]:= crfoutpbus;//,
b[1]:=crfoutpmodule;
b[2]:=crfoutpport;
b[3]:=crfInpbus;
b[4]:=crfInpmod;
b[5]:=crfInpport;
b[6]:=crfinpstate;
b[7]:=crfoutpstate;

SetLength(a,8);
a[0]:= funcbus;//,
a[1]:=funcmod;
a[2]:=funcport;
a[3]:=evbus;
a[4]:=evmod;
a[5]:=evport;
a[6]:=evstate;
a[7]:=functstate;
if activerulefile.locateindataset(b,a) then Result := true;

end;



procedure TForm1.SdpoSerial1RxData(Sender: TObject);
var
tmpstr:string;
spos,epos:integer;
begin
   {
 //while ConnectionsAndStuff.SdpoSerial1.DataAvailable do

serialdata:=serialdata+connectionsandstuff.SdpoSerial1.ReadData;
spos := Pos('!', serialdata);
epos := Pos('#', serialdata);
while (spos > 0) and (epos > 0) do
begin
spos := Pos('!', serialdata);
epos := Pos('#', serialdata);

    //  if (spos > 0) and (epos > 0) then
    //  begin
    if  trim(Copy(serialdata, spos + 1, epos-2)) <> '' then
      FrmSerialMonitor.Memo1.lines.add(trim(Copy(serialdata, spos + 1, epos-2))) ;
      FrmSerialMonitor.Memo1.SelStart:=length(FrmSerialMonitor.Memo1.text);
      FrmSerialMonitor.Memo1.SelLength:=0;
      FrmSerialMonitor.Memo1.SetFocus;
      {
      if pos('mapbutton',trim(Copy(serialdata, spos + 1, epos-2))) > 0 then
      identifyTriggerInput(trim(Copy(serialdata, spos + 1, epos-2)));
      }
      serialdata := Copy(serialdata, epos + 1, Length(serialdata));
    //  end;




 end;

     }

end;

procedure TForm1.TreeView1Change(Sender: TObject; Node: TTreeNode);
var
imin,imax:integer;
begin
try
if node <> nil then
if node.Parent <> nil then
  begin
       if node.Parent.Parent <> nil then
         begin
              if node.Parent.Parent.parent <> nil then
               begin
                   if Combosorttype.Text='function' then
                   begin
                         if findInRuleFile(node.Parent.Parent.parent.Text,node.Parent.Parent.Text,node.Parent.Text,node.Text) then
                           begin
                                ComboShr.Text:=activerulefile.dataset.Fields[crfhrstart].asstring;
                                ComboEhr.Text:=activerulefile.dataset.Fields[crfhrend].asstring;
                                Comboemin.Text:=activerulefile.dataset.Fields[crfminend].asstring;
                                ComboSmin.Text:=activerulefile.dataset.Fields[crfminstart].asstring;
                                ComboLongPress.Text:=activerulefile.dataset.Fields[crflpress].asstring;
                               // comboFuncState.Text:=fsmap.locateindataset(cmfFState,cmfFvalue,rulefile.dataset.Fields[crfoutpstate].asstring);
                           end;
                    end;
                   if Combosorttype.Text = 'event' then
                      begin
                       if findInRuleFile(node.Parent.Text,node.Parent.Parent.parent.Text,node.Parent.Parent.Text,node.Text) then
                           begin
                                ComboShr.Text:=activerulefile.dataset.Fields[crfhrstart].asstring;
                                ComboEhr.Text:=activerulefile.dataset.Fields[crfhrend].asstring;
                                Comboemin.Text:=activerulefile.dataset.Fields[crfminend].asstring;
                                ComboSmin.Text:=activerulefile.dataset.Fields[crfminstart].asstring;
                                ComboLongPress.Text:=activerulefile.dataset.Fields[crflpress].asstring;
                               // comboFuncState.Text:=fsmap.locateindataset(cmfFState,cmfFvalue,rulefile.dataset.Fields[crfoutpstate].asstring);
                           end;
                       end;
                   end;

              end;
         end;
   if node <> nil then
      if node.HasChildren then
      pnlcombos.Visible:=false
      else
       pnlcombos.Visible:=true
   else
   pnlcombos.Visible:=false;



   except

   end;


 //  pnlcombos.Left:=Node.DisplayTextRight +120;
  // pnlcombos.Top:=node.DisplayExpandSignRect.Top - pnlcombos.Height-(TreeView1.Height-node.DisplayExpandSignRect.Top );


  // pnlcombos.Parent:=TreeView1;
end;

procedure TForm1.fillcombos;
var
i:integer;
begin
//comboFuncState.Clear;
ComboSmin.Clear;
ComboShr.Clear;
ComboEhr.Clear;
ComboEmin.Clear;

while not fsmap.dataset.EOF do
      begin
         //  comboFuncState.AddItem(fsmap.dataset.Fields[cmfFUname].asstring,nil);
           fsmap.dataset.next;
      end;
for i := 0 to 59 do
    begin
         if i < 10 then
           begin
           ComboSmin.AddItem('0'+inttostr(i),nil) ;
           ComboEmin.AddItem('0'+inttostr(i),nil) ;
           end
           else
           begin
           ComboSmin.AddItem(inttostr(i),nil);
           ComboEmin.AddItem(inttostr(i),nil);
           end;
    end;
for i := 0 to 23 do
    begin
         if i < 10 then
           begin
           ComboShr.AddItem('0'+inttostr(i),nil) ;
           ComboEhr.AddItem('0'+inttostr(i),nil) ;
           end
           else
           begin
           ComboShr.AddItem(inttostr(i),nil);
           ComboEhr.AddItem(inttostr(i),nil);
           end;
    end;
 frmnewrule.ComboShr.Items:=ComboShr.items;
 frmnewrule.Comboehr.Items:=Comboehr.items;
 frmnewrule.ComboSmin.Items:=ComboSmin.items;
 frmnewrule.Comboemin.Items:=Comboemin.items;
 frmnewrule.ComboLongPress.Items:=ComboLongPress.items;
  frmnewrule.ComboShr.text:='00';
 frmnewrule.Comboehr.text:='00';
 frmnewrule.ComboSmin.text:='00';
 frmnewrule.Comboemin.text:='00';
 frmnewrule.ComboLongPress.text:='0';
addfieldtocombo(ismap.dataset,cmfIState,frmnewrule.Comboinputstate);
addfieldtocombo(fsmap.dataset,cmfFState,frmnewrule.comboFuncState);
addfieldtocombo(functionmapfile.dataset,cmfFUname,frmnewrule.Combofunction);
addfieldtocombo(inputmapfile.dataset,cmfINPname,frmnewrule.Comboinput);


end;

procedure TForm1.refreshFileListbox;
var
i:integer;
a:string;
begin
    listbox_files_on_sd.Clear;
    ListBox_mapfiles.Clear;
for i := 0 to Arduinorulefiles.Count -1 do
    begin
         listbox_files_on_sd.AddItem(TArduinoFile(Arduinorulefiles.items[i]).Filename,nil);
    end;

if  Assigned(ismap) then
    begin
    ListBox_mapfiles.AddItem(ismap.Filename,nil);
    end ;

    if  Assigned(fsmap) then
    begin
    ListBox_mapfiles.AddItem(fsmap.Filename,nil);
    end;
    if  Assigned(functionmapfile) then
    begin
    ListBox_mapfiles.AddItem(functionmapfile.Filename,nil);
    end;

    if  Assigned(inputmapfile) then
    begin
    ListBox_mapfiles.AddItem(inputmapfile.Filename,nil);
    end;


end;

function TForm1.getArduinoFile(filename: string): TArduinoFile;
var
i:integer;
begin
for i := 0 to Arduinorulefiles.Count -1 do
    begin
         if TArduinoFile(Arduinorulefiles.items[i]).Filename = filename then
           begin
           result:=TArduinoFile(Arduinorulefiles.items[i]);
           break;
           end;
    end;
end;

procedure TForm1.setCurrentRulefile(filename:string);
begin
 activerulefile:= getArduinoFile(filename);
 Populatetreeview(activerulefile,TreeView1,true,Combosorttype.text);
 fillcombos;
end;

function TForm1.checkMapFiles: boolean;
begin
  if not Assigned(ismap) then
    begin
    result :=false;
    showmessage('inpu tstate map file is not loaded');
    end
    else
    if not Assigned(fsmap) then
    begin
    result :=false;
    showmessage('function state map file is not loaded');
    end
    else
    if not Assigned(functionmapfile) then
    begin
    result :=false;
    showmessage('function map map file is not loaded');
    end
    else
    if not Assigned(inputmapfile) then
    begin
    result :=false;
    showmessage('input map map file is not loaded');
    end
    else
    result:=true;






end;

  procedure TForm1.addfieldtocombo(dataset: tdataset; fieldindex: integer;
   combobox: TComboBox);

 begin
 combobox.clear;
 dataset.First;
 while not dataset.eof do
       begin
         combobox.AddItem(dataset.Fields[fieldindex].asstring,nil);
         dataset.next;
       end;

 end;

procedure TForm1.ParseInputSerialData(Adata: string);
var
strlst:tstringlist;
begin
strlst:=tstringlist.Create;
strlst.Delimiter:=',';
strlst.StrictDelimiter:=true;
strlst.DelimitedText:=Adata;
try
   case strlst[0] of
       '6' : fillListFilesOnSD(strlst[1]);
      // '2' : identifyTriggerInput(strlst);
   end;

finally
FreeAndNil(strlst);

end;
end;


procedure TForm1.fillListFilesOnSD(Adata:String);
var
strlst:tstringlist;
begin
strlst:=tstringlist.Create;
strlst.Delimiter:=';';
strlst.StrictDelimiter:=true;
strlst.DelimitedText:=Adata;

 listbox_files_on_sd.Clear;
 listbox_files_on_sd.Items:=strlst;
 if Assigned(strlst) then FreeAndNil(strlst);




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

procedure TForm1.populatelist(listbox: TListBox; dataset: TDataSet;
  fldidx: integer);
var
i:integer;
begin
listbox.Clear;
dataset.First;
for i :=0 to dataset.RecordCount - 1 do
    begin
         listbox.AddItem(dataset.Fields[fldidx].asstring,nil);
         dataset.Next;
    end;
end;




end.

