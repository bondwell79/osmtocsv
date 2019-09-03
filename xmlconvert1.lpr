program xmlconvert1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp
  { you can add units after this };

type

  { xmlconvert }

  xmlconvert = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

var

linea         : string;

lat,lon       : string;

v_name        : string;
v_city        : string;
v_street      : string;
v_postcode    : string;
v_housenumber : string;



{ xmlconvert }

Function buscapos (cad,inecad: string;pos2:word) : word;
var
x1,x2,x3,x4 : longint;
begin
{buscar en inecad}
if pos2=0 then pos2:=1;
if pos2>length(inecad) then pos2:=1;

x3:=1;
if (inecad<>'') and (length(inecad)>=length(cad))
   then
   begin
   x1:=pos2;
        repeat;
               if x3<=length(cad) then
               if (inecad[x1]=cad[x3])
                                    then
                                     begin
                                      if x3=1 then x4:=x1;
                                      inc(x3);
                                     end
                                     else
                                      begin
                                        if x3>1 then x1:=x4;
                                        x3:=1;
                                      end;
        inc(x1);
        until (x1>length(inecad));
   end;
if (x3>length(cad)) then buscapos:=x4 else buscapos:=0; {0 = no encontrado}
end;

function capturar (variable:string):string;

var
p1,p2 : word;
ps    : string;

begin

  p1:=buscapos(variable,linea,1)+length(variable);

  if p1>length(variable) then
          begin
          ps:='';
          // encontrado empezar a copiar
          while ((p1<length(linea)) and (linea[p1]<>'"'))
                do begin
                ps:=ps+linea[p1];
                inc(p1);
                end;

          end;

  capturar:=ps;

end;
function transformar ( fichero_origen,fichero_destino: string) : longint;

var
  fc1,fc2               : textfile;
  resultado,cx1,cx2,ld  : string;
  tlineas               : longint;


Begin

  assignfile(fc1,fichero_origen);
  assignfile(fc2,fichero_destino);

  reset (fc1);
  rewrite(fc2);
  writeln(fc2,'lat'+chr(9)+'lon'+chr(9)+'nombre'+chr(9)+'ciudad'+chr(9)+'calle'+chr(9)+'cp');
  ld:='';
  while not eof(fc1) do

        begin
        // reitera cada linea del fichero origen

        readln(fc1,linea);

        // proceso
        resultado:='';

        cx1:=capturar ('lat="');
        cx2:=capturar ('lon="');

        if (cx1<>'') and (cx2<>'')  then
                                  begin
                                  // nueva coordenada
                                  if (lat<>'') and (lon<>'') and (v_street+v_housenumber<>ld) then
                                                           begin
                                                           // guardamos la anterior localizacion y sus datos en destino
                                                             resultado:=lat+chr(9)+lon+chr(9)+v_name+chr(9)+v_city+chr(9)+v_street+', '+v_housenumber+chr(9)+v_postcode;
                                                             writeln(fc2,resultado);
                                                             write('*');
                                                             ld:=v_street+v_housenumber;
                                                             inc(tlineas);
                                                           end;

                                  // actualizamos actual lat lon
                                  lat:=cx1;
                                  lon:=cx2;
                                  end;

        cx1:=capturar('name" v="'); if (cx1<>'') then v_name:=cx1;
        cx1:=capturar('city" v="'); if (cx1<>'') then v_city:=cx1;
        cx1:=capturar('street" v="');if (cx1<>'') then v_street:=cx1;
        cx1:=capturar('postcode" v="');if (cx1<>'') then v_postcode:=cx1;
        cx1:=capturar('housenumber" v="');if (cx1<>'') then v_housenumber:=cx1;
        write('.');
        end;



closefile(fc1);
closefile(fc2);
transformar:=tlineas;

end;

procedure xmlconvert.DoRun;
var
  ErrorMsg: String;
  tr : longint;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin

    writeln (' CONVERSOR de ficheros OSM (Open Streets Maps) v 1.00 ');
    writeln (' WASX ALPHA SOFTWARE 1984, 2019 ');
    writeln (' Programado por Rubén Pastor Villarrubia');
    writeln;
    writeln('uso: ');
    writeln(' osmtocsv {fichero origen}.osm {fichero destino}.csv');
    Terminate;
    Exit;
  end;

  { add your program here }
   writeln (' CONVERSOR de ficheros OSM (Open Streets Maps) v 1.01 ');
   writeln (' WASX ALPHA SOFTWARE 1984, 2019 ');
   writeln (' Programado por Rubén Pastor Villarrubia');
   writeln;

   if (paramstr(1)<>'') and (paramstr(2)<>'') then

   begin
   // convertir
   tr:=transformar (paramstr(1),paramstr(2));
   writeln;writeln;
   writeln('Generados '+inttostr(tr)+' registros');
   writeln;writeln;
   writeln('Proceso terminado');
   end
   else writeln(' Error: no ha indicado fichero de origen o destino. ');




  // stop program loop
  Terminate;
end;

constructor xmlconvert.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor xmlconvert.Destroy;
begin
  inherited Destroy;
end;


var
  Application: xmlconvert;
begin
  Application:=xmlconvert.Create(nil);
  Application.Title:='xmlconvert';
  Application.Run;
  Application.Free;
end.

