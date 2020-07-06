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

unit main;

interface

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, Forms, Buttons,
  Menus, StdCtrls, ComCtrls, ExtCtrls, queryLib, setup, bookmark, ScktComp,
  syslib, ImgList, Registry, ShellAPI, Messages, Clipbrd, tstruct, servermain,
  constants, Dialogs;

type

  TMainForm = class(TForm)
    SBgo: TSpeedButton;
    MainMenu: TMainMenu;
    About: TMenuItem;
    CBedit: TComboBox;
    InfoPanel: TMemo;
    SBadd: TSpeedButton;
    LstPlay: TListView;
    Sbstop: TSpeedButton;
    SBroll: TSpeedButton;
    PopupMenu: TPopupMenu;
    SBnfo: TSpeedButton;
    StatusB: TStatusBar;
    ImgLst: TImageList;
    Img: TImage;
    AddServerAuto: TMenuItem;
    ColorDialog: TColorDialog;
    FontDialog: TFontDialog;
    Files: TMenuItem;
    serverlist: TMenuItem;
    Registry: TMenuItem;
    ExitMenu: TMenuItem;
    Bookmarks: TMenuItem;
    Find: TMenuItem;
    PopupMenuIcon: TPopupMenu;
    N9: TMenuItem;
    Getrules1: TMenuItem;
    procedure WndProc(var Message: TMessage);override;
    procedure ChangeColors(Sender : TObject);
    procedure ChangeFonts(Sender : TObject);
    procedure GetPacket(HPacket : TPacketHead; nfo : PTSInfo; pl : PTSPlayers);
    procedure SBrollClick(Sender: TObject);
    procedure Settings2Click(Sender: TObject);
    procedure SBnfoClick(Sender: TObject);
    procedure CBeditDblClick(Sender: TObject);
    procedure BookmarksClick(Sender: TObject);
    procedure LstPlayColumnClick(Sender: TObject; Column : TListColumn);
    procedure LstPlayCompare(Sender: TObject; Item1, Item2: TListItem;
                             Data: Integer; var Compare: Integer);
    procedure est1Click(Sender: TObject);
    procedure FindClick(Sender: TObject);
    procedure SBgoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    Procedure DisplayInfo(HPacket : TPacketHead; Rnfo : TRInfo);
    Procedure DisplayPlayers(HPacket : TPacketHead; pl : PTSPlayers);
    Procedure DisplayRules(HPacket : TPacketHead; nfo : PTSINfo);
    procedure SBrefClick(Sender: TObject);
    procedure SBaddClick(Sender: TObject);
    procedure AddServerAutoClick(Sender: TObject);
    procedure PreLaunch(HPacket : TPacketHead; Rnfo : TRInfo);
    procedure SbstopClick(Sender: TObject);
    procedure AboutClick(Sender: TObject);
    procedure Preferences1Click(Sender: TObject);
    procedure AMUWinfragg1Click(Sender: TObject);
    procedure ExportInfo(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Exit1Click(Sender: TObject);
    procedure Restore1Click(Sender: TObject);
    procedure ExitMenuClick(Sender: TObject);
    procedure DisplayIconServer(icn : byte);
    procedure Paste1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure CBeditChange(Sender: TObject);
    procedure addSubItemAddress;
    procedure Getrules1Click(Sender: TObject);
    private
     Atom_Received : Atom;
     CurrentServerInfo : TRInfo;
     IconNotifyData : TNotifyIconData;
     LastIp : ShortString;
     NbPacket, ColumnToSort : Cardinal;
     MaxPlayers : SmallInt;
     ColumnSortUp : boolean;
     Pass : String;
    public
     BrutalClock, AutoRefresh : TTimer;

  end;

var MainForm: TMainForm;

implementation

{$R *.dfm}

(*----------------------------------------------------------------------------+
  "WndProc" listens for messages coming from Windows.
  WM_USER + 17878 for messages about TrayIcon.
  WM_USER + 17879 for a new occurence of Winfragg with (-IP) flag (not empty).
 +----------------------------------------------------------------------------*)

procedure TMainForm.WndProc(var Message: TMessage);
var p : TPoint;
    TextIN : PChar;

procedure ShutDown;
begin
        Shell_NotifyIcon(NIM_DELETE, @IconNotifyData);
        Message.Msg := 1;
        Message.LParam :=0;
        Message.Result:=0;
        Halt
end;

begin
        Case Message.Msg of
         WM_QUERYENDSESSION : ShutDown;
         WM_ENDSESSION : ShutDown;
         WM_DESTROY: ShutDown;
         WM_QUIT : ShutDown;

         WM_SYSCOMMAND:
          Case Message.WParam and $FFF0 of
           SC_MINIMIZE:
            begin
             MainForm.Hide;
             MainBook.Hide;
             MainServer.Hide;
             SetupMain.Hide;
             Exit
            end
          end;

         WM_USER + 17878 :
          Case Message.lParam of
           WM_RBUTTONDOWN:
            begin
             GetCursorPos(p);
             PopupMenuIcon.Popup(p.x, p.y)
            end;
           WM_LBUTTONDOWN:
            begin
             Show;
             SetForegroundWindow(Self.handle)
            end
          end;

         WM_USER + 17879 :
          begin
           atom_Received := Message.WParam;
           GetMem(TextIN, 256);
           GlobalGetAtomName(atom_Received, TextIN, 256);
           if Copy(TextIN,1,11) = 'winfragg://' then
           CBEdit.Text := StringReplace(Copy(TextIN,10,Length(TextIn)),'/','',[rfReplaceAll])
           else CBEdit.Text := TextIn;
           GlobalDeleteAtom(atom_received);
           FreeMem(TextIN);
           SBNfo.Click
          end
        end;
        inherited
end;

procedure TMainForm.SBrollClick(Sender: TObject);
begin
        with Mainform do
         if Height = 392
         then
          begin
           Sbstop.Click;
           Height := 101;
           SBroll.Tag := 0;
          end
         else
          begin
           Height := 392;
           SBroll.Tag := 1;
          end;
        SBRoll.Caption := '^'
end;

procedure TMainForm.DisplayIconServer(icn : byte);
begin
        Img.Canvas.Brush.Color := clBtnFace;
        Img.Canvas.FillRect(Img.Canvas.ClipRect);
        ImgLst.Draw(Img.Canvas,0,0,icn,true)
end;

 (*----------------------------------------------------------------------------+
  "DisplayPlayers" gets "HPacket" TPacketHead type and "pl" PSPlayers type.
  The syntax was inspired from "eD2k Utils" (BierBaron).
 +----------------------------------------------------------------------------*)

Procedure TMainForm.DisplayPlayers(HPacket : TPacketHead; pl : PTSPlayers);
var LstItem : TListItem;
    MaxId,i : byte;
    top : PTSPlayers;
begin
        top := pl;

        MaxId := 0;
        while pl^.Next <> nil do
         begin
           LstItem := LstPlay.FindCaption(0, pl^.id, false, true, false);
           if LstItem = nil then
             begin
              LstItem := LstPlay.Items.Add;
              LstItem.Caption := pl^.id;
              LstItem.SubItems.Add(pl^.name);
              LstItem.SubItems.Add(inttostr(pl^.fragg));
              LstItem.SubItems.Add(pl^.team);
              LstItem.SubItems.Add(pl^.ping);
              LstItem.SubItems.Add(pl^.time);
              LstItem.SubItems.Add(pl^.id)
             end
           else
            with LstPlay.Items[LstItem.Index] do
             begin
              SubItems[0] := pl^.name;
              SubItems[1] := inttostr(pl^.fragg);
              SubItems[2] := pl^.team;
              SubItems[3] := pl^.ping;
              SubItems[4] := pl^.time 
             end;
           inc(MaxId);
           pl := pl^.Next;
         end;

         if CurrentServerInfo.IdRec = 'HLRules' then
         if MaxId < LstPlay.Items.Count then
          for i:=LstPlay.Items.Count downto MaxId do
          begin
            LstItem:=LstPlay.FindCaption(0, inttostr(i), true, true, false);
            if LstItem <> nil then LstPlay.Items[LstItem.Index].Delete
          end;

        FreeMemPlayers(top)//or dispose
end;

Procedure TMainForm.DisplayRules(HPacket : TPacketHead; nfo : PTSINfo);
begin
    PopupMenu.Items[6].Tag := 0;    
    SBStop.Click;
    InfoPanel.Clear;

    while nfo <> nil do
     begin
        InfoPanel.Lines.Add(nfo.Variable + ' = ' + nfo.Value);
        nfo := nfo^.Next
     end
end;

(*----------------------------------------------------------------------------+
  "DisplayInfo" gets "HPacket" TPacketHead type and "Rnfo" TRInfo type.
 +----------------------------------------------------------------------------*)

Procedure TMainForm.DisplayInfo(HPacket : TPacketHead; Rnfo : TRInfo);
var LstItem : TListItem;
    i : byte;
begin
      if Rnfo.IdRec = 'HLRules'
      then
        With InfoPanel.Lines do
         begin
          Add ('Reserved Slot(s) : ' + Rnfo.ReservedSlots);
          Add ('TimeLeft : ' + Rnfo.TimeLeft);
          Add ('FriendlyFire : ' + Rnfo.FF);
          Add (Rnfo.Extra);
          exit
         end;

      InfoPanel.Clear;
      DisplayIconServer(Rnfo.icn);

      if Rnfo.IdRec = 'HLInfo'
      then
       begin
        QueryMain.QueryServer(0,'v',HPacket.Address);
        With InfoPanel.Lines do
         begin
          Add('HostName : ' + Rnfo.HostName);
          Add('Description : ' + Rnfo.Description);
          Add('Server : ' + Rnfo.TypeServer);
          Add('OS : ' + Rnfo.OS);
          Add('Map : ' + Rnfo.Map);
          Add('PassWord : ' + Rnfo.PassWord);
          Add('Players : ' + Rnfo.NumPlayers + '/' + Rnfo.MaxPlayers);
          Add('Anti-Cheat : ' + Rnfo.AC)
        end;
      end;

      if Rnfo.IdRec = 'UTInfo'
      then
       begin
        QueryMain.QueryServer(0,'e',HPacket.Address);
        With InfoPanel.Lines do
         begin
          Add ('HostName : ' + Rnfo.HostName);
          Add ('GameName : ' + Rnfo.Description);
          Add ('GameType : ' + Rnfo.GameType);
          Add ('Map : ' + Rnfo.Map);
          Add ('Players : ' + Rnfo.NumPlayers + '/' + Rnfo.MaxPlayers);
          Add ('Reserved Slot(s) : ' + Rnfo.ReservedSlots);
          Add ('PassWord : ' + Rnfo.PassWord);
          Add ('FF : ' + Rnfo.FF);
          Add ('Anti-Cheat : ' + Rnfo.AC)
         end;
       end;

      if Rnfo.IdRec = 'IdInfo'
      then
        With InfoPanel.Lines do
         begin
          Add ('HostName : ' + Rnfo.HostName);
          Add ('Version : ' + Rnfo.GameVersion);
          Add ('GameType : ' + Rnfo.GameType);
          Add ('GameMod : ' + Rnfo.Description);
          Add ('Map : ' + Rnfo.Map);
          Add ('Players : ' + Rnfo.NumPlayers + '/' + Rnfo.MaxPlayers);
          Add ('ReservedSlot(s) : ' + Rnfo.ReservedSlots);
          Add ('PassWord : ' + Rnfo.PassWord);
          Add ('FF : ' + Rnfo.FF);
          Add ('Anti-Cheat : ' + Rnfo.AC)
         end;

      for i:=LstPlay.Items.Count downto strtoint(Rnfo.NumPlayers)+1 do
       begin
         LstItem:=LstPlay.FindCaption(0, inttostr(i), true, true, false);
         if LstItem <> nil then LstPlay.Items[LstItem.Index].Delete
         else
          begin
           LstItem:=LstPlay.FindCaption(0, inttostr(i-1), true, true, false);
           if LstItem <> nil then LstPlay.Items[LstItem.Index].Delete
          end
        end
end;

(*----------------------------------------------------------------------------+
  "PreLaunch" gets "HPacket" TPacketHead type and "Rnfo" TRInfo type. Builds the
  command line before launching.
 +----------------------------------------------------------------------------*)

procedure TMainForm.PreLaunch(HPacket : TPacketHead; Rnfo : TRInfo);
var CommandString : String;

procedure GoMsg;
var i,  IndexGame : byte;
        Connector : ShortString;
begin
      Sbstop.Click;
      SBgo.Enabled := false;
      InfoPanel.Lines.Add(LAUNCHINGCANVAS);
      InfoPanel.Lines.Add('');
      InfoPanel.Lines.Add('Taking slot..');
      InfoPanel.Lines.Add('Identification Engine');
      IndexGame := 0;//null

      if Rnfo.IdRec = 'HLRules' then
         begin
          IndexGame := 6;//Half-Life
          InfoPanel.Lines.Add('    .: Half-Life engine OK');

          Connector := ' -game ' + CurrentServerInfo.GameDir
                                 + ' +connect '
                                 + HPacket.Address
                                 + ' +password ' + Pass
         end;

      if Rnfo.IdRec = 'UTInfo' then
         begin
          InfoPanel.Lines.Add('    .: Unreal engine OK');
          case Rnfo.Icn of
            7,9 : begin
                    if Rnfo.Icn=9 then IndexGame := 13//UT2003
                    else IndexGame := 12;//UT
                    Connector:= ' '
                                + HPacket.ip + ':'+ RNfo.UTHostPort
                                + '/?name=' + SetupMain.EGPName.Text
                                + ' ?password=' + Pass
                  end;
             10 : begin
                    IndexGame := 14;//BattleField
                    Connector:= ' +restart 1 +joinServer '
                                + HPacket.ip + ':'+ RNfo.UTHostPort
                                + ' +isInternet 1 +playerName '
                                + SetupMain.EGPName.Text
                                + ' +password ' + Pass
                  end;
             11 : begin
                    IndexGame := 7;//Medal of Honor
                    Connector:= ' +set name '
                                + SetupMain.EGPName.Text
                                + ' +password ' + Pass
                                + ' +connect '
                                + HPacket.ip + ':'+ RNfo.UTHostPort
                  end;
             12 : begin
                    IndexGame := 8;//Operation Flashpoint
                    Connector:= ' -connect=' + HPacket.ip
                                + ' -port=' + RNfo.UTHostPort
                                + ' -password=' + Pass
                                + ' -name=' + SetupMain.EGPName.Text
                  end;
          13,14 : begin
                    if Rnfo.Icn=13 then IndexGame := 9 //Serious Sam
                    else IndexGame := 10; //Serious Sam 2
                    Connector:= ' +connect '
                                + HPacket.ip + ':'+ RNfo.UTHostPort
                                + ' +password ' + Pass
                  end;
             15 : begin
                    InfoPanel.Lines.Add('    ..: LithTech engine OK');
                    IndexGame := 0; //Alien versus Predator 2
                    Connector:= ' -windowtitle "Aliens vs. Predator 2"'
                                + ' -rez AVP2.REZ -rez SOUNDS.REZ'
                                + ' -rez AVP2L.REZ -rez AVP2DLL.REZ'
                                + ' -rez MULTI.REZ -rez AVP2P.REZ'
                                + ' -rez AVP2P1.REZ +gsa 1'
                                + ' gsa_ip ' + HPAcket.ip
                                + ' gsa_port ' + inttostr(HPAcket.port)
                                + ' +gsa_pw ' + Pass
                                + ' +gsa_name ' + SetupMain.EGPName.Text
                  end;
          end;
         end;

      if Rnfo.IdRec = 'IdInfo' then
         begin
          InfoPanel.Lines.Add('    .: Id engine OK');
          case Rnfo.Icn of
           16 : begin
                  IndexGame := 1;//Quake3
                  Connector:= ' +set fs_game ' + Rnfo.Description
                              + ' +name ' + SetupMain.EGPName.Text
                              + ' +password ' + Pass
                              {+ +setu team s }
                              + ' +connect '
                              + HPAcket.Address
                end;
           17 : begin
                  IndexGame := 2;//RTCW
                  Connector:= ' +name ' + SetupMain.EGPName.Text
                              + ' +password ' + Pass
                              + ' +connect '
                              + HPAcket.Address
                end;
           18 : begin
                  IndexGame := 3;//RTCW ET
                  Connector:= ' +name ' + SetupMain.EGPName.Text
                              + ' +password ' + Pass
                              + ' +connect '
                              + HPAcket.Address
                end;
           19 : begin
                  IndexGame := 4;//Jedi Knight 2
                  Connector:= ' +name ' + SetupMain.EGPName.Text
                              + ' +password ' + Pass
                              + ' +connect '
                              + HPAcket.Address
                end;
           20 : begin
                  IndexGame := 5;//Soldier of fortune 2
                  Connector:= ' +name ' + SetupMain.EGPName.Text
                              + ' +password ' + Pass
                              + ' +connect '
                              + HPAcket.Address
                end;
           21 : begin
                  IndexGame := 11;//Star Trek Elite Force
                  Connector:= ' -client -ip ' + HPacket.ip
                              + ' -name ' + SetupMain.EGPName.Text
                              + ' -password ' + Pass
                end
          end;
         end;

      if SetupMain.ListGame.Items[IndexGame].SubItems[1] = '' then
       begin
         InfoPanel.Lines.Add('    .: Search path empty !');
         InfoPanel.Lines.Add('    ..: Please find the right path');
         SBgo.Enabled := true;
         exit
       end;

      InfoPanel.Lines.Add('    .: Search path OK');

      if IndexGame = 0
      then
        CommandString :=
        StringReplace(SetupMain.ListGame.Items[IndexGame].SubItems[1],
                      'avp2.exe','LithTech.exe',[rfReplaceAll])
        + Connector;

      if IndexGame <> 5
      then
        CommandString :=
              SetupMain.ListGame.Items[IndexGame].SubItems[1] + Connector
      else
        CommandString := SetupMain.ListGame.Items[IndexGame].SubItems[1];

      For i:=6 to SetupMain.ListGame.Items[IndexGame].SubItems.count-3 do
      begin
        if SetupMain.ListGame.Items[IndexGame].SubItems[i+2] = '1'
        then CommandString :=
             CommandString
              + ' '
              + SetupMain.ListGame.Items[IndexGame].SubItems[i+1]
      end;

      CommandString :=
      CommandString + ' ' + SetupMain.ListGame.Items[IndexGame].SubItems[2];

      if IndexGame = 5
      then CommandString := CommandString + Connector;

      if SetupMain.CBGStats.Checked
      then
        try
          if Rnfo.IdRec = 'HLRules'
          then SysLib.HttpPost(HPacket.Address, CurrentServerInfo.Description)
          else SysLib.HttpPost(HPacket.Address, Rnfo.Description);
          InfoPanel.Lines.Add('    ..: HTTP report OK');
        except on E:Exception do
         begin
          GetErrorLog(E.Message);
          MainForm.InfoPanel.Lines.Add('    ..: HTTP report failed');
         end
        end;

      if SetupMain.CBCopyclip.Checked
      then ClipBoard.AsText := HPacket.Address;

      if SetupMain.CBMinjoin.Checked
      then Hide;

      InfoPanel.Lines.Add('    .: Processing executable..');
      
      try
        SysLib.CreateProcessSimple(CommandString);
      except on E:Exception do getErrorLog(E.Message);
      end;

      SBgo.Enabled := true;
      if SetupMain.CBQonjoin.Checked then application.terminate
end;

procedure FullMsg;
begin
        if SetupMain.RBFloodJoin.Checked
        then
         begin
           if SetupMain.RBFloodJoin.Tag = 0
           then
            begin
              BrutalClock := TTimer.Create(nil);
              BrutalClock.Name := 'BrutalClock';
              BrutalClock.Interval := BRUTALCLOKVALUE;
              BrutalClock.Enabled := true;
              BrutalClock.OnTimer := SBgoClick;
              SetupMain.RBFloodJoin.Tag := 1
            end;
           InfoPanel.Lines.Add('Retrying connection please wait');
           exit
         end;

        if SBGo.Tag = 1 //switch stuff
         then
          begin
            SBGo.Tag := 0;
            GoMSg;
            exit
          end
         else SBGo.Tag := 1;

        with InfoPanel.Lines do
         begin
          Add(NOSLOTSCANVAS);
          Add('');
          Add('   .:Reserved Solt(s) = '+Rnfo.ReservedSlots);
          Add('');
          Add('   ..:Press GO to continue')
         end;

        SBgo.Enabled := true
end;

begin
        InfoPanel.Clear;

        if Rnfo.IdRec = 'HLRules'
        then
          if Maxplayers - strtoint(Rnfo.ReservedSlots) > 0 then GoMsg
          else FullMsg
        else
         begin
          if Rnfo.PassWord = 'Required'
          then
           if not InputQuery('Password required','Insert the password',Pass)
           then exit;

          MaxPlayers := strtoint(Rnfo.MaxPlayers);
          Maxplayers := Maxplayers -
                        StrToInt(Rnfo.NumPlayers)-
                        StrToInt(Rnfo.ReservedSlots);

          if Rnfo.IdRec = 'HLInfo'
          then
            begin
              CurrentServerInfo := Rnfo;//because flrules next !
              QueryMain.QueryServer(1,'ÿÿÿÿrules',cbedit.Text)
            end
          else if Maxplayers > 0 then GoMsg
               else FullMsg

         end
end;

(*----------------------------------------------------------------------------+
  "GetPacket" gets "HPacket" TPacketHead type, "nfo" PSInfo type and "pl"
  PSPlayers type. HPAcket.UdpTag equal 0 for a simple query and 1 for a query
  before launching. 
 +----------------------------------------------------------------------------*)

procedure TMainForm.GetPacket(HPacket:TPacketHead; nfo:PTSInfo; pl:PTSPlayers);
begin
        NbPacket := NbPacket + HPacket.Bytes;
        StatusB.Panels[0].Text := 'Rx : ' + inttostr(NbPacket) + ' byte(s)';

        Case HPAcket.UdpTag of
        0 : begin
             if LastIp <> HPacket.Address
             then
              begin
                LastIP := HPacket.Address;
                NbPacket := 0;
                LstPlay.Clear;
                SBGO.Tag := 0
              end;

             if PopupMenu.Items[6].Tag = 1 then
              begin
               DisplayRules(HPacket, nfo);
               exit
              end;

             if nfo <> nil then DisplayInfo(HPacket, QueryMain.P2Rec(nfo));
             if pl <> nil then DisplayPlayers(HPacket, pl)
            end;

        else try PreLaunch(HPacket,QueryMain.P2Rec(nfo))
             except on E:Exception do getErrorLog(E.Message)
             end
        end
end;

(*----------------------------------------------------------------------------+
  "SBnfoClick" does a broadcast on current server.
 +----------------------------------------------------------------------------*)

procedure TMainForm.SBnfoClick(Sender: TObject);
begin   
        if SetupMain.RBFloodJoin.Tag = 1 then SBStop.Click;

        if SBnfo.tag = 0 then
         begin
           if SetupMain.CBAutoRefreshQueryMain.Checked
           then
            begin
             AutoRefresh.Enabled:=true;
             SBnfo.tag:=1
            end
         end;

        if MainForm.Height < 392 then SBroll.Click;

        try QueryMain.QueryServer(0,'b',cbedit.Text)
        except on E:Exception do GetErrorLog(E.message)
        end
end;

procedure TMainForm.Getrules1Click(Sender: TObject);
begin
        PopupMenu.Items[6].Tag := 1;
        if MainForm.Height < 392 then SBroll.Click;

        try QueryMain.QueryServer(0,'r',cbedit.Text)
        except on E:Exception do GetErrorLog(E.message)
        end
end;

procedure TMainForm.BookmarksClick(Sender: TObject);
begin
        MainBook.visible:=true;
        MainBook.BringToFront;
        MainBook.SBRefresh.Click
end;

procedure TMainForm.Settings2Click(Sender: TObject);
begin   
        SetupMain.PGeneral.BringToFront;
        SetupMain.Show;
        SetupMain.LoadGameconf
end;

procedure TMainForm.LstPlayColumnClick(Sender: TObject; Column: TListColumn);
begin
        ColumnToSort := Column.Index;
        ColumnSortUp := not ColumnSortUp;
        (Sender as TCustomListView).AlphaSort
end;

 (*----------------------------------------------------------------------------+
  "LstPlayCompare" compares values into the ListView (players). The syntax was
  inspired from "eD2k Utils" (BierBaron).
 +----------------------------------------------------------------------------*)

procedure TMainForm.LstPlayCompare(Sender: TObject; Item1,
          Item2: TListItem; Data: Integer; var Compare: Integer);
var ix, code1, code2: Integer;
    x, y: real;
begin
        ix := ColumnToSort - 1;

        if ix < 0 then
         begin
            if strtoint(Item1.caption) < strtoint(Item2.Caption)
            then If ColumnSortUp then Compare := Compare * -1;
            exit;
         end;

         Val(Item1.SubItems[ix], x, Code1);
         Val(Item2.SubItems[ix], y, Code2);

         If ((Code1 = 0) and (Code2 = 0)) then
          begin
           If (x < y) then Compare := -1
           else Compare := 1;
          end
         else Compare := CompareText(Item1.SubItems[ix],Item2.SubItems[ix]);

        If ColumnSortUp then Compare := Compare * -1
end;

procedure TMainForm.SBgoClick(Sender: TObject);
begin
        Mainform.Height := 250;
        SBRoll.Caption := '~~~';

        Sbstop.Click;

        try QueryMain.QueryServer(1,'b',cbEdit.Text)
        except on E:Exception do getErrorLog(E.Message)
        end            
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
       Img.Canvas.Brush.Color := clBtnFace;
       Img.Canvas.FillRect(Img.Canvas.ClipRect);
       ImgLst.Draw(Img.Canvas,0,0,0,true);

       AutoRefresh := TTimer.Create(self);
       Autorefresh.Enabled := false;
       Autorefresh.OnTimer := SBnfoClick;

       with IconNotifyData do
        begin
         hIcon := Application.Icon.Handle;
         uCallbackMessage := WM_USER + 17878;
         cbSize := sizeof(IconNotifyData);
         Wnd := Handle;
         uID := 0;
         uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP
        end;

       StrPCopy(IconNotifyData.szTip, Application.Title);
       Shell_NotifyIcon(NIM_ADD, @IconNotifyData);
       SetWindowLong(Application.Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW);
       Application.ShowMainForm := False
end;

procedure TMainForm.ChangeColors(Sender : TObject);
begin
        case Tcomponent(Sender).Tag of
         0 : ColorDialog.Color := InfoPanel.Color;
         1 : ColorDialog.Color := LstPlay.Color;
         2 : ColorDialog.Color := CBedit.Color;
        end;
        
        if ColorDialog.Execute
        then
         case Tcomponent(Sender).Tag of
          0 : begin
               InfoPanel.Color := ColorDialog.Color;
               SetupMain.SColorInfo.Brush.Color := ColorDialog.Color
              end;
          1 : begin
               LstPlay.Color := ColorDialog.Color;
               SetupMain.SColorPlayer.Brush.Color := ColorDialog.Color
              end;
          2 : begin
               CBedit.Color := ColorDialog.Color;
               SetupMain.SColorField.Brush.Color := ColorDialog.Color
              end;
         end;
end;

procedure TMainForm.ChangeFonts(Sender : TObject);
begin
        case Tcomponent(Sender).Tag of
         0 : FontDialog.Font := InfoPanel.Font;
         1 : FontDialog.Font := LstPlay.Font;
         2 : FontDialog.Font := CBedit.Font;
        end;
        
        if FontDialog.Execute
        then
         case Tcomponent(Sender).Tag of
          0 : begin InfoPanel.Font := FontDialog.Font;
                    SetupMain.BFontInfo.Font := FontDialog.Font;
              end;
          1 : begin LstPlay.Font := FontDialog.Font;
                    SetupMain.BFontPlayers.Font := FontDialog.Font;
              end;
          2 : CBedit.Font := FontDialog.Font;
         end
end;

 (*----------------------------------------------------------------------------+
  "ExportInfo" exports values from registry.
 +----------------------------------------------------------------------------*)

procedure TMainForm.ExportInfo(Sender: TObject);
const BaseKey = 'HKEY_CURRENT_USER' ;
var strProgram, strCommand,strBranch : String;
begin
    Case (Sender as TMenuItem).Tag of
    0 : begin
         SetupMain.SaveD.FileName := 'Winfragg.reg (Fixed)';
         strBranch  := 'HKEY_CURRENT_USER\Software\AMU\winfragg';
         strCommand := '/E Winfragg.reg ' + strBranch + #0;
         end;
    1 : begin
         SetupMain.SaveD.FileName := 'WinfraggApparence.reg (Fixed name)';
         strBranch  := 'HKEY_CURRENT_USER\Software\AMU\winfragg\windows\main';
         strCommand := '/E WinfraggApparence.reg ' + strBranch + #0;
        end;
   10 :
        begin
         SetupMain.SaveD.FileName := 'WinfraggServerList.reg (Fixed name)';
         strBranch  := 'HKEY_CURRENT_USER\Software\AMU\winfragg\bookmark';
         strCommand := '/E WinfraggServerList.reg ' + strBranch + #0;
        end

    end;
    if SetupMain.SaveD.Execute then
    begin
     strProgram := 'REGEDIT' + #0;
     try
     ShellExecute(0,nil,@strProgram[1],@strCommand[1],nil,SW_NORMAL)
     except on E:Exception do getErrorLog(E.Message);
     end
    end
end;

procedure TMainForm.SbstopClick(Sender: TObject);
begin
        SBnfo.Tag := 0;
        AutoRefresh.Enabled := false;                 

        if SetupMain.RBFloodJoin.Tag = 0 then exit;
        
        SetupMain.RBFloodJoin.Tag := 0;
        BrutalClock.Destroy;
        InfoPanel.Clear
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
        SetupMain.BClosesettingsClick(Sender);
        MainBook.SBQuit.Click;
        Shell_NotifyIcon(NIM_DELETE, @IconNotifyData)
end;

procedure TMainForm.addSubItemAddress;
begin
        if CBedit.Items.IndexOf(CbEdit.Text) = -1
        then CBedit.Items.Append(CbEdit.Text)
end;

procedure TMainForm.est1Click(Sender: TObject);
begin
        InfoPanel.SelectAll;
        Infopanel.CopyToClipboard
end;

procedure TMainForm.AboutClick(Sender: TObject);
begin
        SetupMain.PAbout.BringToFront;
        SetupMain.Show
end;

procedure TMainForm.Restore1Click(Sender: TObject);
begin
        SetForegroundWindow(Self.handle);
        Show
end;

procedure TMainForm.FindClick(Sender: TObject);
begin
        MainServer.visible := true;
        MainServer.BringToFront
end;

procedure TMainForm.SBaddClick(Sender: TObject);
begin
        MainBook.AddServer(Sender);
end;

procedure TMainForm.AddServerAutoClick(Sender: TObject);
begin
        MainBook.AddServer(Sender);
end;

procedure TMainForm.Preferences1Click(Sender: TObject);
begin
        Settings2Click(Sender)
end;

procedure TMainForm.SBrefClick(Sender: TObject);
begin
        SBnfo.Click
end;

procedure TMainForm.AMUWinfragg1Click(Sender: TObject);
begin
        About.Click
end;

procedure TMainForm.CBeditDblClick(Sender: TObject);
begin
        SBnfo.Click
end;

procedure TMainForm.CBeditChange(Sender: TObject);
begin
        SBStop.Click
end;

procedure TMainForm.Paste1Click(Sender: TObject);
begin
        CBEdit.Text := ClipBoard.AsText
end;

procedure TMainForm.Copy1Click(Sender: TObject);
begin
        ClipBoard.AsText := CBedit.Text
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
        Close
end;

procedure TMainForm.ExitMenuClick(Sender: TObject);
begin
        Close
end;

end.
