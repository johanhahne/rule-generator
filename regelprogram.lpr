program regelprogram;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, sdflaz, mainForm, sdposeriallaz, serialsettingsform, serialmonitorform,
  unitconnectionsandstuff, editmapfilesform, mainmdiform, functions, 
FormNewRule;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
   Application.CreateForm(TForm3, Form3);
   Application.CreateForm(TConnectionsAndStuff, ConnectionsAndStuff);
    Application.CreateForm(TFormmapfileeditor, Formmapfileeditor);
   Application.CreateForm(TForm1, Form1);
     Application.CreateForm(TfrmSerialSettings, frmSerialSettings);
  Application.CreateForm(TFrmSerialMonitor, FrmSerialMonitor);

  Application.CreateForm(Tfrmnewrule, frmnewrule);
  Application.Run;
end.

