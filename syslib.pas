 (*----------------------------------------------------------------------------+
  Winfragg(c) is created by Wash for A.M.U

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  The CsTiger searching feature is an exclusivity for Winfragg(c) only.

  Amu's page : http://winfragg.sourceforge.net/
  Dev Page   : https://sourceforge.net/projects/winfragg/
  Contact    : amunit@users.sourceforge.net
  CsTiger    : http://www.cstiger.de
  Borland    : http://www.borland.com
 +----------------------------------------------------------------------------*)

unit syslib;

interface

uses
  Windows, SysUtils, querylib, NMHttp, Controls, WinSock, constants,
  tstruct, setup;

function  CreateProcessSimple(sExecutableFilePath : string ): string;
function  GetAddress(Address : string; STag : byte) : TAdd;
function  Ping(ip : String; s : byte) : Word;
function  Lookup(str : string) : ShortString;
function  iDNameFormat(s : ShortString) : ShortString;
procedure FreeMemInfo(P : PTSInfo);
procedure FreeMemPlayers(Pl : PTSPlayers);
procedure GetErrorLog(E : String);
procedure HttpPost(Address : String; Description : ShortString);

implementation

uses main;

var TopTime : PTClockSlot;
    ErrorLogFile : TLogErrorFile;

 (*----------------------------------------------------------------------------+
  "iDNameFormat" gets "s" ShortString type. Returns a ShorString without color
  character codes.
 +----------------------------------------------------------------------------*)

function iDNameFormat(s : ShortString) : ShortString;
var i : byte;
begin
        Result:='';
        For i:=0 to length(s) do
        begin
         if s[i]='"' then Delete(s,i,1);
         if s[i]='^' then Delete(s,i,2)
        end;
        Result:=s
end;

 (*----------------------------------------------------------------------------+
  "Ping" gets "ip" ShortString type and "s" byte type. Starts or Stops ping.
  The syntax was improved with advice of Gforce (.hlla).
 +----------------------------------------------------------------------------*)

function Ping(ip : String; s : byte) : Word;
var Curr, Last, Prev : PTClockSlot;
begin
        Result := MAXPING;

        if TopTime = nil
        then
          begin
           TopTime := new(PTClockSlot);
           TopTime^.nxt := nil;
          end;

        Prev := new(PTClockSlot);
        Curr := TopTime;
        
        while (Curr^.ip <> ip) and (Curr^.nxt <> nil) do
          begin
           Prev := Curr;
           Curr := Curr^.nxt
          end;

        case s of
          0 : if Curr^.ip <> ip
              then
                begin
                 Last := new(PTClockSlot);
                 Last^.ip := ip;
                 Last^.tc := GetTickCount;
                 Last^.nxt := nil;
                 Curr^.nxt := Last
                end
               else Curr^.tc := GetTickCount
        else if Curr^.ip = ip
             then
               begin
                 Result := GetTickCount-Curr^.tc;
                 Prev^.nxt := Curr^.nxt;
                 Dispose(Curr)
               end
	end
end;

(*----------------------------------------------------------------------------+
  "Lookup" gets "str" string type. Resolves hostnames.
 +----------------------------------------------------------------------------*)

function Lookup(str : string) : ShortString;
var Phe: PHostEnt;
begin
        Result:='';
        pHe := gethostbyname(Pchar(str));
        if pHe = nil then exit;
        Result:=inet_ntoa(PInAddr(pHe^.h_addr_list^)^)
end;

(*----------------------------------------------------------------------------+
  "GetAddress" gets "address" string type and "STag" byte type. Validates new
  IP.
 +----------------------------------------------------------------------------*)

function GetAddress (Address : String; STag : byte) : TAdd;
var i : Word;
    ip, port : String;
    
begin
        Result.ko := 1;

        if length(Address) < 1 then exit;

        i:=1;
        while (Address[i] <> ':') and (i < length(Address)) do
         begin
            if ord(Address[i]) <> 32 then ip := ip + Address[i];
            inc(i)
         end;

        if (i = length(Address)) or (ip = '') then exit;

        if Stag > 2 then Result.ip := ip
        else Result.ip := lookup(ip);

        inc(i);

        While i <= length(Address) do
         begin
            if (ord(Address[i]) < 58) and (ord(Address[i]) > 47)
            then Port := Port + Address[i];
            inc(i)
         end;

        Result.port := StrToInt(port);
        Result.ko := 0
end;

(*----------------------------------------------------------------------------+
  "CreateProcessSimple" gets "sExecutableFilePath" string type. Creates a new
  process for the selected game.
 +----------------------------------------------------------------------------*)

function CreateProcessSimple(sExecutableFilePath : string ): string;
var pi : TProcessInformation;
    si : TStartupInfo;
   rep : string;
     i : smallint;
begin
      i := length(sExecutableFilePath);
      rep := sExecutableFilePath;
      while not (sExecutableFilePath[i] = '\') do// test ! end of string
      begin
        delete(rep,i,1);
        dec(i);
      end;
      FillMemory( @si, sizeof( si ), 0 );
      si.cb := sizeof( si );
      CreateProcess(Nil,PChar(sExecutableFilePath),Nil, Nil,
                    False,NORMAL_PRIORITY_CLASS, Nil, PChar(rep), si, pi );
      CloseHandle( pi.hProcess );
      CloseHandle( pi.hThread )
end;

(*----------------------------------------------------------------------------+
  "HttpPost" gets "address" string type and "description" ShortString
  type. Reports statistic informations.
 +----------------------------------------------------------------------------*)

procedure HttpPost(Address : String; Description : ShortString);
var HTTPx : TNMHTTP;
begin
        HTTPx := TNMHTTP.Create(nil);
        HTTPx.Timeout := HTTPSTATREPORTTIMEOUT;
        HTTPx.Port:=80;
        MainForm.InfoPanel.Lines.Add(HTTPREPORTCANVAS);
        HTTPx.Get(WideString(HTTPREPORTDEST
          + 'postwf.php?'
          + 'nick='+ StringReplace(iDNameFormat(SetupMain.EGPName.Text),
                                   ' ',
                                   '%20',
                                   [rfReplaceAll])
          + '&ip=' + Address
          + '&gm=' + StringReplace(Description,' ','_',[rfReplaceAll])
          + '&ver=' + version));
        HTTPx.Free
end;

(*----------------------------------------------------------------------------+
  "GetErrorLog" gets an "E" string type. Reports an error into a file.
 +----------------------------------------------------------------------------*)

procedure GetErrorLog (E : String);
var Error : String;
begin
        AssignFile(ErrorLogFile, LOGFILENAME);
        if not FileExists(LOGFILENAME) then ReWrite(ErrorLogFile)
        else Reset(ErrorLogFile);
        Append(ErrorLogFile);
        Error:=DateToStr(Date) + ' @ '
                               + TimeToStr(Now)
                               + ' Exception : '
                               + E
                               +#$0D+#$0A;
        Write(ErrorLogFile,Error);
        Close(ErrorLogFile)
end;

(*----------------------------------------------------------------------------+
  Experimental stuff to release a pointer list from memory..
 +----------------------------------------------------------------------------*)

function freeInfo(P : PTSInfo):PTSInfo;
begin
        Result := P^.Next
end;

procedure FreeMemInfo(P : PTSInfo);
begin
        if P <> nil then FreeMemInfo(freeInfo(p));
        dispose(P)
end;

function freePPlay(Pl : PTSPLayers):PTSPlayers;
begin
        Result := Pl^.Next
end;

procedure FreeMemPlayers(Pl : PTSPlayers);
begin
        if Pl^.Next <> nil then FreeMemPlayers(freePPLay(Pl));
        dispose(Pl)
end;

end.
