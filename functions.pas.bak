unit functions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,db, SdfData,variants;


  type
   { TFile }

    { TArduinoFile }

    TArduinoFile = Class
          constructor create(fname:string;data:string);
          destructor destroy;
  private
    { private declarations }
     Filecontent:tstringlist;

  public
      function locateindataset(returnfieldindex:integer;SFidx:integer;Searchstring:string) :String; overload;
      function locateindataset(returnfieldindex:integer;SFidx1:integer;searchstring1:string;SFidx2:integer;searchstring2:string) :String; overload;
      function locateindataset(returnfieldindex:integer;SFidx1:integer;searchstring1:string;SFidx2:integer;searchstring2:string;SFidx3:integer;searchstring3:string) :String; overload;
      function locateindataset(sfields: array of integer; sstrings: array of string): boolean; overload;

  var
      Filename:String;
      datasource:TDataSource;
      dataset:TSdfDataSet;


  end;
implementation

{ TArduinoFile }

constructor TArduinoFile.create(fname: string;data:string);
var
  aStringStream:TStringStream;
  d:string;
begin
     d:=data;
     datasource:=TDataSource.Create(nil);
     dataset:=TSdfDataSet.Create(nil);
     datasource.DataSet:=dataset;
     dataset.Delimiter:=',';
     try
     aStringStream:=TStringStream.Create(d);
     dataset.LoadFromStream(aStringStream);
     finally
     aStringStream.Free;
     end;
     Try
     dataset.Active:=true;
     datasource.Enabled:=true;
     finally
     end;
     filename:=fname;
end;

destructor TArduinoFile.destroy;
begin
  if Assigned(datasource)then
  freeandnil(datasource);
    if Assigned(dataset)then
  freeandnil(dataset);
end;

function TArduinoFile.locateindataset(returnfieldindex: integer;
  SFidx: integer; Searchstring: string): String;
var
  fieldnames:string;
  found:boolean;
begin
     dataset.first;
     found:=false;

     while (not found) and (not dataset.EOF) do
     begin
     if (dataset.Fields[SFidx].asstring=searchstring) then
     begin
         result := dataset.Fields[returnfieldindex].AsString;
         found:=true;
     end;
     dataset.Next;
     end;

end;

function TArduinoFile.locateindataset(returnfieldindex: integer;
  SFidx1: integer; searchstring1: string; SFidx2: integer; searchstring2: string
  ): String;
var
  fieldnames:string;
  found:boolean;
begin
     dataset.first;
     found:=false;

     while (not found) and (not dataset.EOF) do
     begin
     if (dataset.Fields[SFidx1].asstring=searchstring1) and (dataset.Fields[SFidx2].asstring=searchstring2) then
     begin
         result := dataset.Fields[returnfieldindex].AsString;
         found:=true;
     end;
     dataset.Next;
     end;

end;

function TArduinoFile.locateindataset(returnfieldindex: integer;
  SFidx1: integer; searchstring1: string; SFidx2: integer;
  searchstring2: string; SFidx3: integer; searchstring3: string): String;
var
  fieldnames:string;
  found:boolean;
begin
     dataset.first;
     found:=false;

     while (not found) and (not dataset.EOF) do
     begin
     if (dataset.Fields[SFidx1].asstring=searchstring1) and (dataset.Fields[SFidx2].asstring=searchstring2) and (dataset.Fields[SFidx3].asstring=searchstring3) then
     begin
         result := dataset.Fields[returnfieldindex].AsString;
         found:=true;
     end;
     dataset.Next;
     end;



//     fieldnames:=dataset.Fields[SFidx1].FieldName+';'+dataset.Fields[SFidx2].FieldName+';'+dataset.Fields[SFidx3].FieldName;
     if dataset.Locate(fieldnames,vararrayof([Searchstring1,searchstring2,searchstring3]),[loCaseInsensitive]) then
//  result := dataset.Fields[returnfieldindex].AsString;
end;
function TArduinoFile.locateindataset(sfields: array of integer; sstrings:array of string): boolean;
var
  fieldnames:string;
  found,foundfield:boolean;
  i:integer;
  tmp1,tmp2:string;
begin
     dataset.first;
     found:=false;
     foundfield:=false;

     while (not found) and (not dataset.EOF) do
     begin
          for i := low(sfields) to high(sfields) do
          begin
          tmp1:= dataset.Fields[sfields[i]].asstring;
          tmp2:= sstrings[i];
           if dataset.Fields[sfields[i]].asstring =  sstrings[i] then
           begin
               foundfield:=true;
           end
           else
           begin
            foundfield:=false;
            break;
           end;


          end;
       if foundfield then
       begin
       found:=true;

       break;
       end;

     dataset.Next;
     end;
    Result:=found;
end;



end.

