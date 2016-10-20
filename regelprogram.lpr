program regelprogram;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, mainForm, sdposeriallaz, serialsettingsform, serialmonitorform, 
unitconnectionsandstuff
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmSerialSettings, frmSerialSettings);
  Application.CreateForm(TFrmSerialMonitor, FrmSerialMonitor);
  Application.CreateForm(TConnectionsAndStuff, ConnectionsAndStuff);
  Application.Run;
end.

