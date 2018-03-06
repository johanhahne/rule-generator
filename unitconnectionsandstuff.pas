unit unitconnectionsandstuff;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, ExtCtrls, SdpoSerial,blcksock;

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
    rcvTimer: TTimer;

    procedure DataModuleCreate(Sender: TObject);
    procedure rcvTimerTimer(Sender: TObject);
    procedure SdpoSerial1RxData(Sender: TObject);
    procedure SockRxData();


  private
      FReceiveData : TReceiveData;
       serialdata:string;

    { private declarations }
  public
    { public declarations }
    procedure SendMessage(Msgtype: integer; MsgData: string);
    function ConnectionConnect(baudrate, device:string):boolean; overload;
    function ConnectionConnect(IP:string; Port:integer):boolean; overload;
    procedure ConnectionDisConnect;
    property ReceiveData:TReceiveData read FReceiveData write FReceiveData ;
    var
    sock:TTCPBlockSocket;
    connectionActive:boolean;

  end;

var
  ConnectionsAndStuff: TConnectionsAndStuff;

implementation

{$R *.lfm}

{ TConnectionsAndStuff }

procedure TConnectionsAndStuff.DataModuleCreate(Sender: TObject);
begin

end;

procedure TConnectionsAndStuff.rcvTimerTimer(Sender: TObject);
begin
  SockRxData();
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

procedure TConnectionsAndStuff.SockRxData;
var
    buffer: String = '';
    tmpstr:string;
spos,epos:integer;
begin
rcvTimer.Enabled:=false;
  repeat
     // serialdata:=serialdata+sock.RecvString(4000);
     // serialdata:=sock.RecvTerminated(4000,'#');
      serialdata:=serialdata+sock.RecvPacket(4000);
    //  serialdata:=serialdata+'#';
      tmpstr:=serialdata;
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
    until serialdata='';

    rcvTimer.Enabled:=true;
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

 if Assigned(sock) then
    begin
        sock.SendString(mess);
       // SockRxData();
    end;





 end;

 function TConnectionsAndStuff.ConnectionConnect(baudrate, device: string
   ): boolean;
 begin



    if connectionsandstuff.SdpoSerial1.Active then connectionsandstuff.SdpoSerial1.active:=false;
           case baudrate of
               '4800': connectionsandstuff.SdpoSerial1.BaudRate:=br__4800 ;
               '9600': connectionsandstuff.SdpoSerial1.BaudRate:=br__9600 ;
               '57600': connectionsandstuff.SdpoSerial1.BaudRate:=br_57600;
               '115200': connectionsandstuff.SdpoSerial1.BaudRate:=br115200 ;
          end;
            connectionsandstuff.SdpoSerial1.Device:=device;
           try
           connectionsandstuff.SdpoSerial1.Active:=true;

           finally
           if connectionsandstuff.SdpoSerial1.Active then
             begin
                 result:=true;
                 connectionActive:=true;
             end
           else
           begin
               result:=false;
           end;
 end;

 end;

 function TConnectionsAndStuff.ConnectionConnect(IP: string; Port: integer): boolean;
 begin
 if not Assigned(sock) then
       sock:= TTCPBlockSocket.Create;

 sock.Connect(ip,inttostr(port));
 if sock.LastError <> 0 then
    begin
       result:=false;
    end
    else
    begin
        Result:=true;
        rcvTimer.Enabled:=true;
        connectionActive:=true;

    end;

 end;

 procedure TConnectionsAndStuff.ConnectionDisConnect;
 begin
 if  Assigned(sock) then
   freeandnil(sock);
 if connectionsandstuff.SdpoSerial1.Active then
    connectionsandstuff.SdpoSerial1.Active:=false;
 connectionActive:=false;
  rcvTimer.Enabled:=false;

 end;

end.

