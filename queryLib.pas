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

unit queryLib; //engine version 0.90 rev 01
(*$WARNINGS OFF*)
interface

uses
  Windows, SysUtils, Variants, Classes, Forms, NMUDP, tstruct, constants;

type

  TQueryMain = class(TForm)
    UDP: TNMUDP;
    procedure FormCreate(Sender: TObject);
    procedure DisPath(HPacket : TPacketHead;
                        Sinfo : PTSINfo;
                     SPlayers : PTSPlayers;
                      SServer : PTSSList);
    procedure UDPDataReceived(Sender : TComponent;
                         NumberBytes : Integer;
                              FromIP : String;
                                Port : Integer);
    procedure QueryServer(STag : byte; q : ShortString; ip : String);
    procedure WFilter(HPacket : TPacketHead; Stream : String);
    function  P2Rec      (nfo : PTSInfo) : TRInfo;
    function  FCSTiger   (s : String) : PTCSTiger;
    function  FHLSList   (s : string) : PTSSList;
    function  FHLInfo    (s : string) : PTSInfo;
    function  FHLRules   (s : string) : PTSInfo;
    function  FHLPlayers (s : string) : PTSPlayers;
    function  FUTInfo    (s : string) : PTSInfo;
    function  FUTPlayers (s : string) : PTSPlayers;
    function  FUTSList   (s : string) : PTSSList;
    function  FiDSList   (s : string) : PTSSList;
    procedure FIDInfo    (s : string; var IdInfo : PTSInfo;
                                      var IdPlayers : PTSPlayers);
    procedure UDPInvalidHost(var handled: Boolean);
    private
     TabQ : array[0..5] of String[20];
  end;

var QueryMain: TQueryMain;

implementation

uses main, bookmark, servermain, syslib;

{$R *.dfm}

procedure TQueryMain.FormCreate(Sender: TObject);
begin
        TabQ[0] := 'ÿÿÿÿrules'+#$00;
        TabQ[1] := 'ÿÿÿÿplayers'+#$00;
        TabQ[2] := '\players\';
        TabQ[3] := 'ÿÿÿÿinfostring'+#$00;
        TabQ[4] := '\basic\\info\\rules\';
        TabQ[5] := 'ÿÿÿÿgetstatus'+#$00
end;

 (*----------------------------------------------------------------------------+
  "QueryServer" gets "Stag" byte type for UDP Source, "q" ShortString type and
  "ip" String type. It creates and sends a query to server.
 +----------------------------------------------------------------------------*)

procedure TQueryMain.QueryServer(STag : byte; q : ShortString; ip : String);
var Stream: TMemoryStream;
    Address : TAdd;
    j : byte;
begin

    try
     Address := GetAddress(ip,STag);
    except on E:Exception do GetErrorLog(E.Message)
    end;
    
    if Address.ko=1 then exit;

    with udp do
     begin
      tag := STag;
      RemoteHost := Address.ip;
      RemotePort := Address.port
     end;

    Stream := TMemoryStream.Create;

    try
    if q = 'b' then//BroadCast  .. flooded by old ut servers
     for j:=3 to 5 do
      begin
        Stream.Write(TabQ[j][1], Length(TabQ[j]));
        if j=4 then //old Gamespy protocol style Epic
        begin
          Udp.RemotePort := udp.RemotePort + 9;
          Udp.SendStream(Stream);
          Udp.RemotePort := udp.RemotePort - 8;
          Udp.SendStream(Stream);
          Udp.RemotePort := udp.RemotePort - 1
         end;
        Udp.SendStream(Stream);
        Stream.Clear
      end;

    if q = 'r' then//only rules query
     begin
       Stream.Write(TabQ[0][1], Length(TabQ[0]));
       Udp.SendStream(Stream);
       Stream.Clear;
       Stream.Write(TabQ[4][1], Length(TabQ[4]));
       Udp.SendStream(Stream);
       Stream.Clear;
       Stream.Write(TabQ[5][1], Length(TabQ[5]));
       Udp.SendStream(Stream);
       Stream.Clear
     end;

    if q = 'v' then//Valve
     begin
       Stream.Write(TabQ[0][1], Length(TabQ[0]));
       Udp.SendStream(Stream);
       Stream.Clear;
       if Stag = 0
       then Stream.Write(TabQ[1][1], Length(TabQ[1]))
       else Stream.Write(TabQ[3][1], Length(TabQ[3]));
       Udp.SendStream(Stream);
       Stream.Clear
     end;

    if q = 'e' then//Epic
     begin
      if STag = 0
      then Stream.Write(TabQ[2][1], Length(TabQ[2]))
      else Stream.Write(TabQ[4][1], Length(TabQ[4]));
      Udp.SendStream(Stream);
      Stream.Clear
     end;

    if q = 'i' then//iD
     begin
      Stream.Write(TabQ[5][1], Length(TabQ[5]));
      Udp.SendStream(Stream);
      Stream.Clear
     end;

    if length(q) > 1 then//MasterServer
     begin
      Stream.Write(q[1], Length(q));
      Udp.SendStream(Stream);
      Stream.Clear
     end;

    except on E: Exception do GetErrorLog(E.Message)
    end;

    Stream.Free;

    if Stag <> 5 then Ping(Address.Ip+':'+IntToStr(Address.Port),0);
    if Stag < 4 then MainForm.addSubItemAddress
end;

procedure TQueryMain.UDPInvalidHost(var handled: Boolean);
begin
        MainForm.Sbstop.Click;
        MainForm.InfoPanel.Clear;
        MainForm.LstPlay.Clear
end;

 (*----------------------------------------------------------------------------+
  "UDPDataReceived" gets "Sender", "NumberBytes" integer type, "Fromip"
  string type and "Port" integer type. Receives and creates the HPacket header.
 +----------------------------------------------------------------------------*)

procedure TQueryMain.UDPDataReceived(Sender : TComponent;
                                NumberBytes : Integer;
                                     FromIP : String;
                                       Port : Integer);
var Stream: TMemoryStream;
          s : String;
    HPacket : TPacketHead;
          i : byte;
begin
      if numberbytes < 0 then exit;

 (*----------------------------------------------------------------------------+
 : Identification of incoming frame :                                          :
 : - Full source IP                                                            :
 : - Original sender (TAG)                                                     :
 : - Source IP                                                                 :
 : - Source Port                                                               :
 +----------------------------------------------------------------------------*)

      if Sender.Tag <> 5 then HPacket.Ping := Ping(FromIP+':'+IntToStr(Port),1);
      
      HPacket.UdpTag := Sender.Tag;
      HPacket.ip := FromIp;
      HPacket.port := Port;
      HPacket.Address := FromIP+':'+inttostr(Port);
      HPacket.Bytes := NumberBytes;

      Stream := TMemoryStream.Create;
      try
       Udp.ReadStream(Stream);
       SetLength(s,NumberBytes);
       Stream.Read(s[1],NumberBytes);
      finally
       Stream.Free;

       if Sender.tag = 5 then
       Case MainServer.CBEGames.ItemIndex of
        0..2 : for i:=7 to 10 do Move(s[i],HPacket.MQuery[i-7],SizeOf(byte));
       end;
       
       WFilter(HPacket, s)
      end
end;

 (*----------------------------------------------------------------------------+
  "WFilter" gets "Hpacket" TPacketHead type and "stream" string type. It
  parses the head of the stream and give it a way.
 +----------------------------------------------------------------------------*)

procedure TqueryMain.WFilter(HPacket : TPacketHead; Stream : String);
var NPSPLayers : PTSPLayers;
    NPSInfo : PTSInfo;
    HeadStr : string[5];

begin
      if (HPacket.UdpTag=0) and (HPacket.Ping < MAXPING)
      then MainForm.StatusB.Panels[1].Text := 'Ping : ' +inttostr(HPacket.ping) +' Ms';

      if HPacket.UdpTag=6
      then
       begin
        DisPath (HPacket,nil,nil,nil);
        exit;
       end;

      HeadStr := copy(Stream,1,5);

      if (HeadStr = 'ÿÿÿÿE') or (copy(Stream,10,5) = 'ÿÿÿÿE')
      then DisPath (HPacket,FHLRules(Stream),nil,nil);

      if HeadStr = 'ÿÿÿÿD'
      then DisPath (HPacket,nil,FHLPlayers(Stream),nil);

      if HeadStr = 'ÿÿÿÿi'
      then DisPath (HPacket,FHLInfo(Stream),nil,nil);

      if HeadStr = 'ÿÿÿÿf'
      then DisPath (HPacket,nil,nil,FHLSList(Stream));

      if HeadStr = 'ÿÿÿÿg'
      then DisPath (HPacket,nil,nil,FiDSList(Stream));

      if HeadStr = 'ÿÿÿÿL'
      then Dispath (HPacket,nil,nil,nil);

      if HeadStr = 'ÿÿÿÿs'
      then
        try//a modif FIDnfo : function renvoie struct
         FIDInfo(Stream,NPSINFO,NPSPLayers);//Error on players fraggs (browser servr)
         DisPath(HPacket,NPSINFO,NPSPLayers,nil)
        except on E: Exception do GetErrorLog(E.Message)        
        end;

      if HeadStr[1] = '\'//flood !!
      then
        begin
         if (HeadStr = '\play') or
            (HeadStr = '\team') or
            (HeadStr = '\ping')
          then DisPath (HPacket,nil,FUTPlayers(Stream),nil)
          else
             if (copy(Stream,1,8) <> '\queryid') and
                (copy(Stream,1,6) <> '\final')
             then DisPath (HPacket,FUTInfo(Stream),nil,nil)
        end;
end;

 (*----------------------------------------------------------------------------+
  "DisPath" gets "Hpacket" PSPlayers type, "Sinfo" PSINfo type, "SPlayers"
  PSPlayers type and "SServer" PSSList type. It dispatchs each packets.
 +----------------------------------------------------------------------------*)

procedure TQueryMain.DisPath(HPacket : TPacketHead;
                               Sinfo : PTSINfo;
                            SPlayers : PTSPlayers;
                             SServer : PTSSList);
begin
    Case HPacket.UdpTag of
     0..1 : MainForm.GetPacket(HPacket,SInfo,SPlayers);
     2..3 : MainBook.GetPacket(HPacket,P2REC(SInfo));
     4..6 : Mainserver.GetPacket(HPacket,P2REC(SInfo),SServer)
    end
end;

 (*----------------------------------------------------------------------------+
  "P2Rec" gets "nfo" PSInfo type. Creates a record type (PSInfo).
 +----------------------------------------------------------------------------*)

function TqueryMain.P2Rec (nfo : PTSInfo) : TRInfo;
var V,Code : integer;
     extra : string;
       top : PTSInfo;
begin
        if nfo = nil then exit;

        top := nfo;

        Result.HostName := '-';
        Result.Icn := 0;
        Result.Protocol := '-';
        Result.UTHostPort := '0';
        Result.OS := '-';
        Result.TypeServer := '-';
        Result.Modif := '-';
        Result.Game := '-';
        Result.Description := '-';
        Result.GameDir := '-';
        Result.GameType := '-';
        Result.GameStyle := '-';
        Result.GameVersion := '-';
        Result.PassWord := '-';
        Result.Map := '-';
        Result.MaxPlayers := '0';
        Result.NumPlayers := '0';
        Result.ReservedSlots := '0';
        Result.TimeLeft := '0';
        Result.AC := '-';
        Result.FF := '-';
        Result.Extra := '-';

        while nfo^.next <> nil do
        begin

         if nfo^.Variable = 'IdPacket'
         then Result.IdRec := nfo^.Value;

         if (nfo^.Variable = 'hostname')
         then Result.HostName := nfo^.Value;

         if (nfo^.Variable = 'sv_hostname')
         then Result.HostName := iDNameFormat(nfo^.Value);

         if nfo^.Variable = 'os'
         then if nfo^.Value = 'l'
              then Result.OS := 'Linux'
              else Result.OS := 'Windows';

         if (nfo^.Variable = 'map') or
            (nfo^.Variable = 'mapname')
         then Result.Map := nfo^.Value;

         if (nfo^.Variable = 'password') or
            (nfo^.Variable = 'g_needpass')
         then if nfo^.Value = '1'
              then Result.PassWord := 'Required';


         if (nfo^.Variable = 'protocol') and
            (Result.IdRec = 'IdInfo')
         then
         begin
          Result.Protocol := nfo^.Value;
          case strtoint(nfo^.Value) of
               15..16 : Result.Icn := 19;
               23..24 : Result.Icn := 21;
               56..60 : Result.Icn := 17;
               80..82 : Result.Icn := 18;
            2003,2004 : Result.Icn := 20
          else Result.Icn := 16//Q3 default
          end
         end;

         if (nfo^.Variable = 'hostport')
         then Result.UTHostPort := nfo^.Value;

         if nfo^.Variable = 'gamedir'
         then
         begin
          Result.GameDir := nfo^.Value;
          Result.Icn := 1;//valve default
          if nfo^.Value = 'cstrike' then Result.Icn := 2;
          if nfo^.Value = 'dod' then Result.Icn := 3;
          if nfo^.Value = 'firearms' then Result.Icn := 4;
          if nfo^.Value = 'ns' then Result.Icn := 5;
          if nfo^.Value = 'tfc' then Result.Icn := 6
         end;

         if (nfo^.Variable = 'gamename')
         then
         begin
           if (Result.IdRec = 'UTInfo') then
             begin
              Result.Icn := 9;//ut2 + ut2d default
              if nfo^.Value = 'ut'
              then Result.Icn := 7;
              if nfo^.Value = 'bfield1942'
              then Result.Icn := 10;
              if nfo^.Value = 'mohaa'
              then Result.Icn := 11;
              if (nfo^.Value = 'opflash') or (nfo^.Value = 'opflashr')
              then Result.Icn := 12;
              if nfo^.Value = 'serioussam'
              then Result.Icn := 13;
              if nfo^.Value = 'serioussamse'
              then Result.Icn := 14;
              if nfo^.Value = 'avp2'
              then Result.Icn := 15
             end ;
           Result.Description := nfo^.Value;
         end;

         if nfo^.Variable = 'gametype'
         then Result.GameType :=nfo^.Value;

         if nfo^.Variable = 'gamestyle'
         then Result.GameType :=nfo^.Value;

         if (nfo^.Variable = 'version') or
            (nfo^.Variable = 'gamever')
         then Result.GameVersion := nfo^.Value;

         if nfo^.Variable = 'description'
         then Result.Description := nfo^.Value;

         if nfo^.Variable = 'type'
         then if nfo^.Value = 'd'
              then Result.TypeServer := 'Dedicated Server'
              else Result.TypeServer := 'Public Server';

         if (nfo^.Variable = 'players') or
            (nfo^.Variable = 'numplayers')
         then Result.NumPlayers := nfo^.Value;

         if (nfo^.Variable = 'max') or
            (nfo^.Variable = 'sv_maxClients') or
            (nfo^.Variable = 'sv_maxclients') or
            (nfo^.Variable = 'maxplayers')
         then Result.MaxPlayers := nfo^.Value;

         if nfo^.Variable = 'g_gametype'
         then
         begin
          val(nfo^.Value,V,Code);
          if Code = 0
          then
            case strtoint(nfo^.Value) of
             0 : Result.GameType := 'Free for All';
             1 : Result.GameType := 'One on One Tournament';
             2 : Result.GameType := 'Single Player FFA';
             3 : Result.GameType := 'Team Deathmatch';
             4 : Result.GameType := 'Capture the Flag';
             5 : Result.GameType := 'One Flag CTF';
             6 : Result.GameType := 'Obelisk';
             7 : Result.GameType := 'Harvester';
             8 : Result.GameType := 'Team Tournament'
            end
          else Result.GameType := nfo^.Value;
         end;

         if (nfo^.Variable = 'reserve_slots') or
            (nfo^.Variable = 'sv_privateClients')
         then Result.ReservedSlots := nfo^.Value;

         if (nfo^.Variable = 'sv_cheats') or
            (nfo^.Variable = 'secure') or
            (nfo^.Variable = 'sv_punkbuster')
         then if nfo^.Value = '1'
              then Result.AC := 'ON'
              else Result.AC := 'OFF';

         if (nfo^.Variable = 'mp_timeleft') or
            (nfo^.Variable = 'cm_timeleft')
         then Result.TimeLeft := nfo^.Value;

         if (nfo^.Variable = 'mp_friendlyfire') or
            (nfo^.Variable = 'g_friendlyFire')  or
            (nfo^.Variable = 'g_friendlyfire')  or
            (nfo^.Variable = 'friendlyfire')    or
            (nfo^.Variable = 'Soldier Friendly Fire')
         then
          if nfo^.Value = '1'
          then Result.FF := 'ON'
          else Result.FF := 'OFF';

(*!!*)   if nfo^.Variable = 'wwclconfig_version'
         then Extra := Extra + 'WWCL config version : ' + nfo^.value + #$0D;

(*!!*)   if nfo^.Variable = 'admin_mod_version'
         then Extra := Extra + 'AdMinModVersion : ' + nfo^.value + #$0D;

(*!!*)   if nfo^.Variable = 'clanmod_version'
         then Extra := Extra + 'ClanModVersion : ' + nfo^.value + #$0D;

(*!!*)   if nfo^.Variable = 'logmod_version'
         then Extra := Extra + 'LogModVersion : ' + nfo^.value + #$0D;

(*!!*)   if nfo^.Variable = 'amx_match_deluxe'
         then Extra := Extra + 'AMX Version : ' + nfo^.value + #$0D;

         nfo:=nfo^.Next
        end;

        Result.Extra := extra;

        FreeMemInfo(top)
end;

 (*----------------------------------------------------------------------------+
  "FCSTiger" gets "s" string type. Returns a PTCSTiger pointer list. It parses
  informations coming from searching server of CsTiger.de.
 +----------------------------------------------------------------------------*)

function TQueryMain.FCSTiger(s : String) : PTCSTiger;
var nxt : PTCSTiger;
    i : Word;
    j : byte;
  tmp : String;
begin
     Result:=new(PTCSTiger);
     Result^.Next := nil;

     i:=0; j:=0;

     while i < length(s) do
      begin
       nxt:=new(PTCSTiger);
       While (i < length(s)) and (s[i] <> #$A) do
        begin
          if copy(s,i,4) = 'ÿÿÿÿ' then
            begin
              Case j of
               0 : Result.SPName := tmp;
               1 : Result.Address := tmp;
               2 : Result.PSNAme := tmp;
              end;
              tmp:='';
              if not (s[i] = #$A) then
               begin
                inc(j);
                inc(i,3);
               end
            end
          else tmp := tmp + s[i];
          inc(i);
        end;

       Result.Game := 0;

       if tmp='hl' then Result.Game := 1;
       if tmp='ut2k3' then Result.Game := 9;
       if tmp='bf42' then Result.Game := 10;
       if tmp='q3' then Result.Game := 16;

       tmp:='';
       nxt^.Next:=Result;
       Result:=nxt;
       j:=0; inc(i)
      end;

      Result:=nxt^.Next
end;

 (*----------------------------------------------------------------------------+
  "FHLInfo" gets "s" string type. Returns a PSInfo pointer list. It filters
  common informations coming from a Valve engine based server.
 +----------------------------------------------------------------------------*)

function TQueryMain.FHLInfo(s : string) : PTSInfo;
var tmp : shortstring;
    nxt : PTSInfo;
    j : byte;
    i : Word;
begin
      Result:=new(PTSInfo);
      Result^.Next := nil;

      i:=25; j:=0;
      nxt:=new(PTSInfo);

      while i < length(s) do
       begin
        tmp := '';

        while (s[i] <> '\') and (s[i] <> #$00)
         do begin tmp := tmp + s[i]; inc (i); end;

        case j of
                0 : nxt^.Variable := tmp;
                1 : nxt^.Value := tmp;
        end;

        if j < 1 then inc(j)
        else begin
                nxt^.Next:=Result;
                Result:=nxt;
                j:=0;
                nxt:=new(PTSInfo)
             end;

       inc (i);

       end;

       nxt^.Variable := 'IdPacket';
       nxt^.Value := 'HLInfo';
       nxt^.Next := Result;

       Result := nxt
end;

 (*----------------------------------------------------------------------------+
  "FHLRules" gets "s" string type. Returns a PSInfo pointer list. It filters
  rules informations coming from a Valve engine based server.
 +----------------------------------------------------------------------------*)

function TqueryMain.FHLRules(s : string) : PTSInfo;//b 1.1 rev 01 Rules crasses A REVOIR
var tmp : String;
    nxt : PTSInfo;
    i : Word;
begin
     Result:=new(PTSInfo);
     Result^.Next := nil;

     i:=8;

     while i < length(s) do
      begin
       nxt:=new(PTSInfo);
       while s[i] <> #$00 do begin tmp := tmp + s[i]; inc (i); end;
       nxt^.Variable := tmp; tmp := '';
       inc (i);
       while s[i] <> #$00 do begin tmp := tmp + s[i]; inc(i); end;
       nxt^.Value := tmp;  tmp:='';
       inc(i);
       nxt^.Next:=Result;
       Result:=nxt;
      end;

      nxt:=new(PTSInfo);
      nxt^.Variable := 'IdPacket';
      nxt^.Value := 'HLRules';
      nxt^.Next := Result;

      Result := nxt
end;

 (*----------------------------------------------------------------------------+
  "FHLPlayers" gets "s" string type. Returns a PSPlayers pointer list. It
  filters players informations coming from a Valve engine based server.
 +----------------------------------------------------------------------------*)

function TqueryMain.FHLPlayers(s : string) : PTSPlayers;//ver 1.2 rev 01
var str : String;
    time : Single;
    nxt : PTSPlayers;
    i : Word;

function GetTime(t : word) : ShortString;
Var h,m,s : Word;
    tmp : ShortString;
begin
      s:=t Mod 60;
      h:=t div 3600;
      t:=(t-s) Mod 3600;
      m:=t div 60;
      if h < 10 then tmp := '0'+inttostr(h)+':'
      else tmp := inttostr(h)+':';
      if m < 10 then tmp := tmp + '0'+ inttostr(m)+':'
      else tmp := tmp + inttostr(m)+':';
      if s < 10 then tmp := tmp + '0'+ inttostr(s)
      else tmp := tmp + inttostr(s);
      GetTime := tmp;
end;

begin
     Result:=new(PTSPlayers);
     Result^.Next := nil;

     i:=7;
     while i <= length(s) do
      begin
       nxt:=new(PTSPlayers);
       nxt^.team := '';
       nxt^.ping := '';
       nxt^.id := inttostr(ord(s[i]));
       inc(i);
       while s[i] <> #$00 do begin str := str + s[i]; inc(i); end;
       nxt^.name := str; str:='';
       inc(i);
       move (s[i],nxt^.fragg,4);
       inc(i,4);
       move (s[i],time,4);
       nxt^.time := GetTime(round(time));
       inc(i,4);

       nxt^.Next:=Result;

       Result:=nxt                                                              
      end;
end;

 (*----------------------------------------------------------------------------+
  "FHLSList" gets "s" string type. Returns a PSSList pointer list. It filters
  server list coming from Valve master server. The syntax was inspired from
  Coldstorage Kquery .
 +----------------------------------------------------------------------------*)

function TQueryMain.FHLSList (s : string) : PTSSList;
var tmp,j : byte;
       ip : string;
     port : Word;
      nxt : PTSSList;
        i : Word;
begin
       Result:=new(PTSSList);
       Result^.Next := nil;

        i:=11;
        while i < length(s) do
        begin
         nxt:=new(PTSSList);
         for j:=0 to 3 do
          begin
            move(s[i],tmp,sizeof(byte));
            inc(i,sizeof(byte));
            if j = 0 then ip := ip + inttostr(ord(tmp))
            else ip := ip + '.' + inttostr(ord(tmp));
          end;

          nxt^.Address := ip;
          ip:='';
          move(s[i],tmp,sizeof(byte));
          port := ord(tmp)*256;
          inc(i,sizeof(byte));
          move(s[i],tmp,sizeof(byte));
          port :=  port + ord(tmp);
          nxt^.Address := nxt^.Address +':'+ inttostr(port);

          nxt^.Next:=Result;
          Result:=nxt
        end
end;

 (*----------------------------------------------------------------------------+
  "FUTInfo" gets "s" string type. Returns a PSInfo pointer list. It filters
  common informations coming from an Epic engine based server.
 +----------------------------------------------------------------------------*)

function TqueryMain.FUTInfo (s : string) : PTSInfo;//b 2.1 rev 0.2
var tmp : shortstring;
    nxt : PTSInfo;
    j : byte;
    i : Word;
begin
      Result:=new(PTSInfo);
      Result^.Next := nil;

      i:=2; j:=0;
      nxt:=new(PTSInfo);

      while i <= length(s) do
       begin
        tmp := '';

        while (s[i] <> '\') and (i <= length(s))
         do begin
                tmp := tmp + s[i];
                inc (i);
            end;

        case j of
                0 : nxt^.Variable := tmp;
                1 : nxt^.Value := tmp;
        end;

        if j < 1 then inc(j)
        else begin
                nxt^.Next:=Result;
                Result:=nxt;
                j:=0;
                nxt:=new(PTSInfo)
             end;

       inc (i);

       end;

       nxt^.Variable := 'IdPacket';
       nxt^.Value := 'UTInfo';
       nxt^.Next := Result;

       Result := nxt
end;

 (*----------------------------------------------------------------------------+
  "FUTPlayers" gets "s" string type. Return a PSPlayers pointer list. It
  filters players informations coming from an Epic engine based server.
 +----------------------------------------------------------------------------*)

function TqueryMain.FUTPlayers (s : string) : PTSPlayers;//f ver 2.1 rev 01
var tmp : ShortString;
    nxt : PTSPlayers;
    j,k : byte;
    i : Word;
begin
      Result:=new(PTSPlayers);
      Result^.Next := nil;

      i:=2; j:=0; k:=0;
      nxt:=new(PTSPlayers);

      while i <= length(s) do
       begin
        tmp := '';

        if j=1
        then while (copy(s,i,6) <> '\frags') and (i < length(s))
                   do begin tmp := tmp + s[i]; inc (i); end
	else while (s[i] <> '\') and (i < length(s))
                   do begin tmp := tmp + s[i]; inc (i); end;

          case j of
                  0 : nxt^.id :=copy(tmp,8,2);//dernière valeur = queryid
                  1 : nxt^.name := tmp;
                  3 : nxt^.fragg := strtoint(tmp);
                  5 : nxt^.ping := tmp;
                  7 : nxt^.team := tmp;
          end;

          if (j=7) and (copy(s,i,5) = '\mesh') then //ut first version j=7 !!
          begin
           while k < 9 do
            begin
                if s[i]='\' then inc(k);
                inc(i);
            end;
           k:=0;
          end
          else inc (i);

          if j < 7 then inc(j)
          else begin
                  nxt^.time := '';
                  nxt^.Next:=Result;
                  Result:=nxt;
                  j:=0;
                  nxt:=new(PTSPlayers)
               end;

       end;

       dispose(nxt)
end;

 (*----------------------------------------------------------------------------+
  "FUTSList" gets "s" string type. Returns a PSSList pointer list. It filters
  server list coming from Epic master server.
 +----------------------------------------------------------------------------*)

function TQueryMain.FUTSList (s : string) : PTSSList;
var i : Word;
    tmpip : String;
    nxt : PTSSList;
begin
        Result:=new(PTSSList);
        Result^.Next := nil;

        i:=5;

        While (i < length(s)) do
        begin
         nxt:=new(PTSSList);

         While (s[i] <> #$0A) and (i < length(s)) do
          if s[i]= #$09 then
           begin
             inc(i);
             While (s[i] <> #$09) and (i < length(s)) do inc(i);
             tmpip := tmpip + ':';
             inc(i);
             While (s[i] <> #$0A) and (i < length(s)) do
              begin
               tmpip := tmpip + s[i];
               inc(i)
              end;
           end
          else
           begin
            tmpip:=tmpip + s[i];
            inc(i);
           end;
           
           Result^.Address := tmpip;
           tmpip:='';

           nxt^.Next:=Result;
           Result:=nxt;

           inc(i)
        end
end;

 (*----------------------------------------------------------------------------+
  "FiDSList" gets "s" string type. Return a PSSList pointer list. It filters
  server list coming from iD master server. The syntax was inspired from
  Coldstorage Kquery .
 +----------------------------------------------------------------------------*)

function TQueryMain.FiDSList (s : string) : PTSSList;//beta 1.3 rev 01 Release mem !!
var tmp,j : byte;
    i, port : Word;
    nxt : PTSSList;
begin
        Result:=new(PTSSList);
        Result^.Next := nil;

        i:=23;
        if s[i] = '\' then inc(i)
        else inc(i,3);//SOF2

        While i+3 < length(s) do
        begin
          nxt:=new(PTSSList);

          move(s[i],j,sizeof(byte));
          nxt^.Address := inttostr(j)+'.';
          inc(i);
          move(s[i],j,sizeof(byte));
          nxt^.Address:= nxt^.Address + inttostr(j)+'.';
          inc(i);
          move(s[i],j,sizeof(byte));
          nxt^.Address:= nxt^.Address + inttostr(j)+'.';
          inc(i);
          move(s[i],j,sizeof(byte));
          nxt^.Address:= nxt^.Address + inttostr(j)+':';
          inc(i);
          move(s[i],tmp,sizeof(byte));
          port := ord(tmp)*256;
          inc(i);
          move(s[i],tmp,sizeof(byte));
          port :=  port + ord(tmp);
          nxt^.Address:= nxt^.Address + inttostr(port);
          inc(i,2);

          nxt^.Next:=Result;
          Result:=nxt;
        end;
end;

 (*----------------------------------------------------------------------------+
  "FiDSList" gets "s" string type. Returns an IdPlayers PSPlayers type and an
  IdInfo PSInfo type. It filters players and common informations coming from an
  iD engine based server.
 +----------------------------------------------------------------------------*)

procedure TQueryMain.FIDInfo (s : string;
                     var IdInfo : PTSInfo;
                  var IdPlayers : PTSPlayers);
var     tmp : ShortString;
        nxt : PTSInfo;
       nxt2 : PTSPlayers;
  j, NumPlayers : byte;
          i : Word;
begin
      IdInfo:=new(PTSInfo);
      IdInfo^.Next := nil;

      i:=20; j:=0;
      nxt:=new(PTSInfo);
      
      while (i <= length(s)) and (s[i] <> #$0A) do
       begin
        inc (i);

        tmp := '';
        while (s[i] <> #$0A) and (s[i] <> '\') do
             begin tmp := tmp + s[i]; inc (i); end;

          case j of
            0 : nxt^.Variable := tmp;
            1 : nxt^.Value := tmp;
          end;

          if j < 1 then inc(j)
          else begin
                  nxt^.Next:=IdInfo;
                  IdInfo:=nxt;
                  j:=0;
                  nxt:=new(PTSInfo)
               end;
       end;

       IdPlayers:=new(PTSPlayers);
       IdPlayers^.Next := nil;

       inc(i); j:=0; NumPlayers:=0;
       nxt2:=new(PTSPlayers);
       
       while i < length(s) do
       begin
          tmp := '';

          while (s[i] <> #$20) and (s[i] <> #$0A) do

            if j = 2 then while s[i]<> #$0A do
             begin
                  tmp := tmp + s[i];
                  inc(i);
             end
            else
             begin
                  tmp := tmp + s[i];
                  inc(i);
             end;

          case j of
            0 : nxt2^.fragg := strtoint(tmp);
            1 : nxt2^.ping := tmp;
            2 : nxt2^.name := iDNameFormat(tmp)
          end;

          if j < 2 then inc(j)
          else
           begin
            inc(NumPlayers);
            nxt2^.id := inttostr(NumPlayers);
            nxt2^.team := '';
            nxt2^.time := '';
            nxt2^.Next:=IdPlayers;
            IdPlayers:=nxt2;
            j:=0;
            nxt2:=new(PTSPlayers)
           end;
        inc (i);
       end;
       
      dispose(nxt2);

      nxt^.Variable := 'players';
      nxt^.Value := inttostr(Numplayers);
      nxt^.Next := IdInfo;
      IdInfo:=nxt;

      nxt:=new(PTSInfo);

      nxt^.Variable := 'IdPacket';
      nxt^.Value := 'IdInfo';
      nxt^.Next := IdInfo;

      IdInfo:=nxt
end;

end.
