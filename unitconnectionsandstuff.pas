unit unitconnectionsandstuff;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SdpoSerial;

type
   TReceiveData = procedure(data:string) of object;
     TmapRec = record
    name:string;
    bus,module,port,state:string;
  end;
  Tmaplist = array of TmapRec;
  { TConnectionsAndStuff }

  TConnectionsAndStuff = class(TDataModule)
    SdpoSerial1: TSdpoSerial;
    procedure DataModuleCreate(Sender: TObject);
    procedure SdpoSerial1RxData(Sender: TObject);

  private
      FReceiveData : TReceiveData;
       serialdata:string;

    { private declarations }
  public
    { public declarations }
    procedure SendMessage(Msgtype: integer; MsgData: string);
    published
    property ReceiveData:TReceiveData read FReceiveData write FReceiveData ;

  end;

var
  ConnectionsAndStuff: TConnectionsAndStuff;

implementation

{$R *.lfm}

{ TConnectionsAndStuff }

procedure TConnectionsAndStuff.DataModuleCreate(Sender: TObject);
begin

end;

procedure TConnectionsAndStuff.SdpoSerial1RxData(Sender: TObject);
var
tmpstr:string;
spos,epos:integer;
begin

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
    if  trim(Copy(serialdata, spos + 5, epos-(spos + 5))) <> '' then
       if Assigned(FReceiveData) then FReceiveData(trim(Copy(serialdata, spos + 5, epos-(spos + 5))));
       serialdata := Copy(serialdata, epos+1 , Length(serialdata));
    //  end;
 end;
end;
 procedure TConnectionsAndStuff.SendMessage(Msgtype:integer;MsgData:string);
 var
 mess,messtype:string;

 i:integer;
 begin
 if Msgtype < 10 then
    messtype:='0'+IntToStr(Msgtype)
    else
      messtype:=IntToStr(Msgtype) ;
mess:='!0000,'+messtype+','+MsgData+'#';
 if SdpoSerial1.Active then
    begin
      SdpoSerial1.WriteData(mess);
    end;

 end;

end.

