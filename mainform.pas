unit mainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Menus, ExtCtrls, DBGrids, ActnList, SdpoSerial, contnrs, simpleipc,
  serialsettingsform, serialmonitorform, db, SdfData, unitconnectionsandstuff,
  editmapfilesform, mainmdiform, functions;

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



  { TForm1 }

  TForm1 = class(TForm)
    btnconnectserial: TButton;
    btnTestRule: TButton;
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button2: TButton;
    Button5: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    DataSource1: TDataSource;
    Label19: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    ListBox1: TListBox;
    listbox_files_on_sd: TListBox;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel2: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    SdfDataSet1: TSdfDataSet;
    Splitter1: TSplitter;
    TreeView1: TTreeView;
    procedure btnconnectserialClick(Sender: TObject);

    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Populatetreeview(rulefile:TArduinoFile; treeview:TTreeView);
    function addNode(treeview:ttreeview;ParentNode:TTreeNode;Newnodename:string):ttreenode;
    function addrootNodeToTreeView(treeview:ttreeview;Newnodename:string):ttreenode;
    function findInRuleFile(func,event,eventstate:string):boolean;
    procedure SdpoSerial1RxData(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);



  private
    procedure fillListFilesOnSD(Adata: String);
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
   changed_controls: TObjectList;
   loadingdata:boolean;
   prulerec:rulerecpointer;
   serialdata:string;
   inputmapfile,rulefile,functionmapfile,ismap,fsmap,activerulefile:TArduinoFile;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

 {fieldnumbers in rulefile}
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

procedure TForm1.Button1Click(Sender: TObject);
begin
  connectionsandstuff.SdpoSerial1.WriteData('!4,rulefile#');
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  sl:tstringlist ;
begin

  sl:=TStringList.Create;
sl.LoadFromFile('/home/johan/git/rule-generator/functionmap');
functionmapfile:=TArduinoFile.create('functionmap',sl.Text);
 sl.Destroy;



 sl:=TStringList.Create;
 sl.LoadFromFile('/home/johan/git/rule-generator/functionstatemap');
 fsmap:=TArduinoFile.create('fsmap',sl.Text);
  sl.Destroy;


sl:=TStringList.Create;
sl.LoadFromFile('/home/johan/git/rule-generator/reglerodesberga.rules');
rulefile:=TArduinoFile.create('rulefile',sl.Text);
 sl.Destroy;
 DBGrid3.DataSource:=rulefile.datasource;

sl:=TStringList.Create;
sl.LoadFromFile('/home/johan/git/rule-generator/inputmap');
inputmapfile:=TArduinoFile.create('rulefile',sl.Text);
 sl.Destroy;


  sl:=TStringList.Create;
 sl.LoadFromFile('/home/johan/git/rule-generator/inputstatemap');
 ismap:=TArduinoFile.create('rulefile',sl.Text);
  sl.Destroy;

  Populatetreeview(rulefile,TreeView1);



end;

procedure TForm1.FormCreate(Sender: TObject);

begin
form1.Top := 1;
    form1.Left := 1;
    form1.Align:=alClient;
    form1.BorderStyle := bsNone;
form1.Parent:=Form3;








end;

procedure TForm1.Populatetreeview(rulefile:TArduinoFile; treeview: TTreeView);
var
i:integer;
n:TTreeNode;
begin
rulefile.dataset.First;
for i := 0 to rulefile.dataset.RecordCount-1 do
    begin

    n:=addrootNodeToTreeView(treeview,functionmapfile.locateindataset(cmfFUname,cmfFUbus, rulefile.dataset.Fields[crfoutpbus].asstring,cmfFUmod, rulefile.dataset.Fields[crfoutpmodule].asstring,cmfFUport, rulefile.dataset.Fields[crfoutpport].asstring));
    n:=addNode(TreeView1,n,inputmapfile.locateindataset(cmfINPname,cmfINPbus, rulefile.dataset.Fields[crfInpbus].asstring,cmfINPmod, rulefile.dataset.Fields[crfInpmod].asstring,cmfINPport, rulefile.dataset.Fields[crfInpport].asstring));
    n:=addNode(TreeView1,n,ismap.locateindataset(cmfIState,cmfIvalue, rulefile.dataset.Fields[crfinpstate].asstring));
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

function TForm1.findInRuleFile(func, event, eventstate: string): boolean;
var
funcbus,funcmod,funcport,evbus,evmod,evport,evstate:string;
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
SetLength(b,7);
b[0]:= crfoutpbus;//,
b[1]:=crfoutpmodule;
b[2]:=crfoutpport;
b[3]:=crfInpbus;
b[4]:=crfInpmod;
b[5]:=crfInpport;
b[6]:=crfinpstate;
SetLength(a,7);
a[0]:= funcbus;//,
a[1]:=funcmod;
a[2]:=funcport;
a[3]:=evbus;
a[4]:=evmod;
a[5]:=evport;
a[6]:=evstate;
rulefile.locateindataset(b,a);

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
begin
if node.Parent <> nil then
  begin
       if node.Parent.Parent <> nil then
         begin
              findInRuleFile(node.Parent.Parent.Text,node.Parent.Text,node.Text);
         end;
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

