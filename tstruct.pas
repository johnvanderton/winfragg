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

 (*----------------------------------------------------------------------------+
  TLogErrorFile : Log error file type
  TAdd          : Server's address record
  TClockSlot    : New slot entry record (asynchronous ping)
  TCsTiger      : New record coming from CsTiger report
  TFilter       : Master server's filter record
  TSInfo        : Server info rec used for HLrules, HLInfo, UTInforules & IDInfo
  TSPlayers     : Players record used for UTPalyers, HLplayers & IDplayers
  TSSlist       : Master server's list record
  TPacketHead   : Head of each packet stream
  TRInfo        : Server information packet
 +----------------------------------------------------------------------------*)
 
unit tstruct;

interface

Type
        TLogErrorFile = TextFile;

        TAdd = Record
                Ip : String;
              Port : Word;
                Ko : Byte
        end;

        PTClockSlot = ^TClockSlot;
        TClockSlot = Record
                Ip : String;
                Tc : Word;
               Nxt : PTClockSlot
        end;

        PTCsTiger = ^TCsTiger;
        TCsTiger = Record
            SPName : ShortString;
            PSNAme : ShortString;
           Address : ShortString;
              Game : Byte;
              Next : PTCsTiger
        end;

        TFilter = Record
       QueryServer : Char;
          MasterIP : ShortString;
            Engine : ShortString;
              GMod : ShortString;
               Map : ShortString;
       QueryMaster : ShortString;
         QueryPing : ShortString;
          EmptySrv : Boolean;
           FullSrv : Boolean;
      FriendlyFire : Boolean;
          DedicSrv : Boolean;
         ACProtect : Boolean;
          PassWord : Boolean;
         Unrespond : Boolean;
            MaxSrv : Word
        end;

        PTSInfo = ^TSInfo;
        TSInfo = record
          Variable : ShortString;
             Value : ShortString;
              Next : PTSInfo
        end;

        PTSPlayers = ^TSPlayers;
        TSPlayers = Record
                Id : String[3];
             Fragg : SmallInt;
              Name : String;
              Ping : ShortString;
              Team : ShortString;
              Time : ShortString;
              Next : PTSPlayers
        end;

        PTSSList = ^TSSlist;
        TSSlist = Record
           Address : String;
              Next : PTSSList
        end;

        TPacketHead = Record
           Address : String;
             Bytes : Cardinal;
                Ip : ShortString;
              Port : Word;
              Ping : Word;
            UdpTag : Byte;
            MQuery : Array [0..3] of Byte
        end;
                                              
        TRInfo = Record
             IdRec : String[7];
             Extra : String;
               Icn : Byte;
                OS : ShortString;
          Protocol : ShortString;
        UTHostPort : ShortString;
          HostName : ShortString;
        TypeServer : ShortString;
             Modif : ShortString;
              Game : ShortString;
       Description : ShortString;
           GameDir : ShortString;
          GameType : ShortString;
         GameStyle : ShortString;
       GameVersion : ShortString;
          PassWord : ShortString;
               Map : ShortString;
        MaxPlayers : ShortString;
        NumPlayers : ShortString;
     ReservedSlots : ShortString;
          TimeLeft : ShortString;
                AC : ShortString;
                FF : ShortString
        end;

implementation

end.
