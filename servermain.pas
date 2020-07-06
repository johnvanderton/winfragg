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

unit servermain;

interface

uses
  Windows, SysUtils, Variants, Classes, Controls, Forms, ComCtrls, QueryLib,
  ExtCtrls, Buttons, StdCtrls, Menus, NMHttp, constants, tstruct, Clipbrd,
  Graphics, ShellApi, Dialogs;

type

  TMainServer = class(TForm)
    lvServers : TListView;
    TopPanel: TShape;
    StatusB: TStatusBar;
    CBMap: TComboBox;
    CBmod: TComboBox;
    CBPing: TComboBox;
    CBPinging: TComboBox;
    LPing: TLabel;
    CBEGames: TComboBoxEx;
    SBSearch: TSpeedButton;
    SBStop: TSpeedButton;
    SBPing: TSpeedButton;
    Pop: TPopupMenu;
    SBSetup: TSpeedButton;
    Image1: TImage;
    CBName: TComboBox;
    LName: TLabel;
    CBGames: TComboBoxEx;   
    CBNetwork: TComboBoxEx;
    lvServers2: TListView;
    Pop2: TPopupMenu;
    function  SetFilters : TFilter;
    function  Initialize : Boolean;
    function  Filter(HPacket : TPacketHead; Nfo : TRInfo) : boolean;
    procedure LoadTigerList(Tlst : PTCsTiger);
    Procedure addItem(Sender : Tobject);
    Procedure AddServer(HPacket : TPacketHead; Nfo : TRInfo);
    procedure QueryTiming(Sender : TObject);
    procedure GetPacket(HPacket : TPacketHead; nfo : TRInfo; lst : PTSSList);
    procedure LoadMasterList(HPacket : TPacketHead; Ml : PTSSList);
    procedure SBSearchClick(Sender: TObject);
    procedure SBStopClick(Sender: TObject);
    procedure SBSetupClick(Sender: TObject);
    procedure lvServersColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvServersCompare(Sender: TObject; Item1, Item2: TListItem;
                               Data: Integer; var Compare: Integer);
    procedure lvServersDblClick(Sender: TObject);
    procedure SBPingClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvServersContextPopup(Sender: TObject; MousePos: TPoint;
                                    var Handled: Boolean);
    procedure Refreshserver1Click(Sender: TObject);
    procedure Importtobookmark1Click(Sender: TObject);
    procedure Go1Click(Sender: TObject);
    procedure RestoredefaultColumnwidth1Click(Sender: TObject);
    procedure HTTPOPacketRecvd(Sender: TObject);
    procedure HTTPODisconnect(Sender: TObject);
    procedure Copyiptoclipboard1Click(Sender: TObject);
    procedure DisplayRules;
    procedure lvServers2ContextPopup(Sender: TObject; MousePos: TPoint;
                                     var Handled: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Image1Click(Sender: TObject);
    procedure CBEGamesClick(Sender: TObject);
    protected
     ColumnToSort: integer;
     ColumnSortUp: boolean;
    private
     MasterFilter : TFilter;
     DelayQuery : TTImer;
     HTTPO : TNMHTTP;
     TopM : PTSSList;
     nbServ, ListIndex : Word;
     ProgressBar : TProgressBar;
  end;

var MainServer: TMainServer;

implementation

uses main, setup, bookmark, syslib;

{$R *.dfm}

procedure TMainServer.FormCreate(Sender: TObject);
begin
        DelayQuery := TTimer.create (nil);
        DelayQuery.Enabled := false;
        DelayQuery.OnTimer := QueryTiming;

        HTTPO := TNMHTTP.Create(Nil);
        HTTPO.OnPacketRecvd := HTTPOPacketRecvd;
        HTTPO.OnDisconnect  := HTTPODisconnect;
        HTTPO.TimeOut := HTTPMASTERQUERYTIMEOUT;
        HTTPO.Port := 80;

        ProgressBar := TProgressBar.Create(Self);
        with ProgressBar do
        begin
         Parent := StatusB;
         Top    := 2;
         Left   := 1;
         Width  := StatusB.Panels[0].Width;
         Height := Parent.ClientHeight - 2;
         Smooth := true
        end
end;

procedure TMainServer.SBSetupClick(Sender: TObject);
begin
        SetupMain.PAdvance.BringToFront;
        SetupMain.Show
end;

procedure TMainServer.SBStopClick(Sender: TObject);
begin
        if DelayQuery.Enabled then DelayQuery.Enabled := false;
        SBStop.Tag := SBSearch.Tag
end;

procedure TMainServer.SBPingClick(Sender: TObject);
begin
        if lvServers.Items.Count = 0 then exit;
        ListIndex:=0;
        SBPing.Enabled := false;
        DelayQuery.Tag := 1;
        DelayQuery.Enabled := true
end;

Procedure TMainServer.addItem(Sender : Tobject);
begin
        if (Sender as TComboBox).Items.IndexOf((Sender as TComboBox).Text) = -1
        then (Sender as TComboBox).Items.Append((Sender as TComboBox).Text)
end;

function TMainServer.Initialize : Boolean;
var S, Code : Integer;
begin
        Result := false;

        val(CBPing.Text,S,Code);
        if (Code <> 0) and (CBPinging.Text <> '') then
         begin
          MessageDlg('Invalid ping value', mtWarning, [mbOk], 0);
          exit
         end;

        Case CBEGames.ItemIndex of
         0..9 : begin
                  addItem(CBMap);
                  addItem(CBMod);
                  addItem(CBPing);
                end;
       10..11 : addItem(CBName)
        end;

        lvServers.Clear;
        ProgressBar.Position := 0;
        ProgressBar.Max := 0;
        StatusB.Panels[2].Text := '';
        DelayQuery.Interval := SetupMain.SENetwork.Value;
        DelayQuery.Enabled := false;
        SBSearch.Tag := 1;
        SBStop.Tag := 0;                              
        nbserv := 0;
        TopM:=new(PTSSList);
        TopM^.Next := nil;
        
        Result := true
end;

(*----------------------------------------------------------------------------+
  "SetFilters" creates a master filter with current settings.
 +----------------------------------------------------------------------------*)

function TMainServer.SetFilters : TFilter;
var Game, Mode : String[5];
begin
        ProgressBar.Max := SetupMain.SPMaxServerQuery.Value;

        With Result do
        begin

         MaxSrv := SetupMain.SPMaxServerQuery.Value;
         PassWord := SetupMain.CBPassword.Checked;
         EmptySrv := SetupMain.CBEmptyServer.Checked;
         FullSrv := SetupMain.CBFullServer.Checked;
         DedicSrv := SetupMain.CBDServer.Checked;
         ACProtect := SetupMain.CBVAC.Checked;
         FriendlyFire := SetupMain.CBFF.Checked;
         QueryMaster := '';

        case CBEGames.ItemIndex of
     0..3 : //HL
            begin
             Case CBEGames.ItemIndex of
              0 : MasterIP := VLMSIPEAST;
              1 : MasterIP := VLMSIPWEST;
              2 : MasterIP := VLMSIPCENTRAL;
              3 : MasterIP := STEAMMSCENTRAL; 
             end;
             QueryPing := VLPING;
             QueryServer := VLQUERY;
             if CBmod.Text <> ''
             then QueryMaster := '\gamedir\' + CBmod.Text;
             if CBMap.Text <> ''
             then QueryMaster := QueryMaster + '\map\' + CBMap.Text;
             if FullSrv
             then QueryMaster := QueryMaster + '\full\1';
             if EmptySrv
             then QueryMaster := QueryMaster + '\empty\1';
             if PassWord
             then QueryMaster := QueryMaster + '\password\1';
             if DedicSrv
             then QueryMaster := QueryMaster + '\type\d';
             if ACProtect
             then QueryMaster := QueryMaster + '\secure\1'
            end;
     4..8 : //iD
            begin
              QueryPing := IDPING;
              QueryServer := IDQUERY;
              QueryMaster := 'ÿÿÿÿgetservers ';
              Case CBEGames.ItemIndex of
               4 : begin
                     QueryMaster := QueryMaster +
                                        SetupMain.ListGame.Items[4].SubItems[4];
                     MasterIP := IDMSIPJK2
                   end;
               5 : begin
                     QueryMaster := QueryMaster +
                                        SetupMain.ListGame.Items[1].SubItems[4];
                     MasterIP := IDMSIPMONSTER
                   end;
               6 : begin
                     QueryMaster := QueryMaster +
                                        SetupMain.ListGame.Items[3].SubItems[4];
                     MasterIP := IDMSIPRTCWET
                   end;
               7 : begin
                     QueryMaster := QueryMaster +
                                        SetupMain.ListGame.Items[2].SubItems[4];
                     MasterIP := IDMSIPMONSTER
                   end;
               8 : begin
                     QueryMaster := QueryMaster +
                                        SetupMain.ListGame.Items[5].SubItems[4];
                     MasterIP := IDMSIPSOF2
                   end
              end
            end;
        9 : //UT
            begin
              QueryServer := EPQUERY;
              QueryPing := EPPING;
              QueryMaster := EPMASTERQUERY
            end;
   10..11 : //CsTiger
            begin
              Mode := 's=';
              if CBEGames.ItemIndex = 10 then Mode := 'p=';
              Case CBGames.ItemIndex of
               0 : Game := 'all';
               1 : Game := 'hl';
               2 : Game := 'q3';
               3 : Game := 'ut2k3';
               4 : Game := 'bf42'
              end;
              QueryMaster := CSTIGERQ + Mode + CBName.Text + '&e=' + Game;
            end
        end;
        end;

        MasterFilter := Result
end;

procedure TMainServer.DisplayRules;
begin
        With MasterFilter do
        begin
         StatusB.Panels[2].Text := ' No rule(s)';
         if DedicSrv
         then StatusB.Panels[2].Text := ' | Dedicated';
         if EmptySrv
         then StatusB.Panels[2].Text := ' | No Empty';
         if FullSrv
         then StatusB.Panels[2].Text := StatusB.Panels[2].Text + ' | No Fully';
         if ACProtect
         then StatusB.Panels[2].Text := StatusB.Panels[2].Text + ' | AC';
         if PassWord
         then StatusB.Panels[2].Text := StatusB.Panels[2].Text + ' | No Password';
         if FriendlyFire
         then StatusB.Panels[2].Text := StatusB.Panels[2].Text + ' | Friendly Fire'
        end
end;

procedure TMainServer.SBSearchClick(Sender: TObject);
var HPacket : TPacketHead;
begin
        if not Initialize then exit;
        
        SetFilters;
        DisplayRules;

        Case CBEGames.ItemIndex of
     0..8 : LoadMasterList(HPacket,nil);
    9..11 : begin
             HTTPO.Tag := CBEGames.ItemIndex;
             HTTPO.Get(MasterFilter.QueryMaster)
            end
        end
end;

procedure TMainServer.Refreshserver1Click(Sender: TObject);
begin
        QueryMain.QueryServer(4,MasterFilter.QueryServer,lvServers.Selected.Caption)
end;

procedure TMainServer.HTTPODisconnect(Sender: TObject);
begin
        DelayQuery.Tag := 0;
        DelayQuery.Enabled := true
end;

procedure TMainServer.HTTPOPacketRecvd(Sender: TObject);
var HPacket : TPacketHead;
begin
        Case TNMHTTP(Sender).Tag of
        9 : LoadMasterList(HPacket,QueryMain.FUTSList(HTTPO.Body))
        else LoadTigerList(QueryMain.FCSTiger(HTTPO.Body))
        end
end;

(*----------------------------------------------------------------------------+
  "LoadTigerList" gets "Tlst" PTCsTiger type. Displays the players coming from
  CsTiger.de report.
 +----------------------------------------------------------------------------*)

procedure TMainServer.LoadTigerList(Tlst : PTCsTiger);
var Curr : PTCsTiger;
    LstItem : TListItem;
begin
        lvServers2.Clear;

        Curr := TLst;

        While Curr^.Next <> nil do
         begin
          if Curr.Game <> 0 then
          begin
           LstItem := lvServers2.Items.Add;
           With LstItem.SubItems do
           begin
            LstItem.ImageIndex := Curr^.Game;
            LstItem.Caption := Curr^.Address;
            Add(Curr^.SPName);
            if CBEGames.ItemIndex = 11 then Add('')
            else Add(Curr^.PSNAme)
           end;
          end;
          Curr := Curr^.Next;
         end;

         ProgressBar.Position := ProgressBar.Max;
         StatusB.Panels[1].Text := IntToStr(lvServers2.Items.Count) + ' Item(s) found';
         Dispose(Tlst)
end;

 (*----------------------------------------------------------------------------+
  "GetPacket" gets "HPacket" TPacketHead type, "nfo" TRInfo type and "lst"
  PSSList type. Adds or loads new incoming servers.
 +----------------------------------------------------------------------------*)

procedure TMainServer.GetPacket(HPacket : TPacketHead; nfo : TRInfo; lst : PTSSList);
begin
        if lst <> nil then LoadMasterList(HPacket,lst)
        else
         if HPacket.UdpTag = 6 then AddServer(HPacket,nfo)
         else
          if Filter(HPacket, nfo) then AddServer(HPacket,nfo)          
end;

(*----------------------------------------------------------------------------+
  "LoadMasterList" gets "HPacket" TPacketHead type and "Ml" PSSList type.
  Loads the Master server list before query.
 +----------------------------------------------------------------------------*)

procedure TMainServer.LoadMasterList(HPacket : TPacketHead; Ml : PTSSList);
var Curr : PTSSList;
    i : byte;
begin   
        if Ml = nil then
         Case CBEGames.ItemIndex of
          0..3 : for i:=0 to 3 do HPacket.MQuery[i]:=0
         end
        else
         begin
          Curr := Ml;
          while (Curr^.Next <> nil) and
                (nbserv < MasterFilter.MaxSrv) and
                (SBStop.Tag <> 1) do
            begin
              inc(nbserv);
              StatusB.Panels[1].Text := inttostr(nbserv) + ' server(s) received';
              Curr := Curr^.Next 
            end;
          Curr^.Next := TopM^.Next;
          TopM^.Next := Ml;
          if (HPacket.MQuery[0] = 0) and (CBEGames.ItemIndex = 0)
          then nbserv := MasterFilter.MaxSrv;
         end;

        if CBEGames.ItemIndex = 9 then exit;

        if (nbserv < MasterFilter.MaxSrv) and (SBStop.Tag = 0)
        then
         Case CBEGames.ItemIndex of
          0..3 : QueryMain.QueryServer(5,#$31+chr(HPacket.MQuery[0])+
                                              chr(HPacket.MQuery[1])+
                                              chr(HPacket.MQuery[2])+
                                              chr(HPacket.MQuery[3])+
                                              MasterFilter.QueryMaster,
                                              MasterFilter.MasterIP)
         else QueryMain.QueryServer(5, MasterFilter.QueryMaster, MasterFilter.MasterIP)
         end
        else
         begin
          DelayQuery.Tag := 0;
          DelayQuery.Enabled := true
         end
end;

(*----------------------------------------------------------------------------+
  "QueryTiming" performs a ping "1" or a query "0" for each interval of time.
 +----------------------------------------------------------------------------*)

procedure TMainServer.QueryTiming(Sender : TObject);
begin
        Case TTImer(Sender).Tag of
        0 : begin
             QueryMain.QueryServer(4,MasterFilter.QueryServer,TopM^.Address);
             dec(nbServ);
             ProgressBar.Position := ProgressBar.Max - nbServ;
             if TopM^.Next <> nil then TopM:=TopM^.Next
             else DelayQuery.Enabled := false
            end;
        1 : begin
             if ListIndex > lvServers.Items.Count-1
             then
              begin
               DelayQuery.Enabled := false;
               SBPing.Enabled := true;
               exit
              end;
             QueryMain.QueryServer(6,MasterFilter.QueryPing,lvServers.Items[ListIndex].Caption);
             inc(ListIndex)
            end
        end
end;

(*----------------------------------------------------------------------------+
  "Filter" gets "HPacket" TPacketHead type and "Nfo" TRInfo type. Performs a
  filtering of the list.
 +----------------------------------------------------------------------------*)

function TMainServer.Filter(HPacket : TPacketHead; Nfo : TRInfo) : boolean;
begin
        Result := false;

        if CBEGames.ItemIndex > 3 then//exclude Half Life
        begin

         if CBPinging.Text = '=' then
            if HPacket.Ping <> StrToInt(CBPing.Text) then exit;
         if CBPinging.Text = '>' then
            if HPacket.Ping < StrToInt(CBPing.Text) then exit;
         if CBPinging.Text = '<' then
            if HPacket.Ping > StrToInt(CBPing.Text) then exit;

         if (MasterFilter.FriendlyFire) and (Nfo.FF = 'OFF')
         then exit;
         if (Nfo.Description <> CBMod.Text) and (CBMod.Text <> '')
         then exit;
         if (Nfo.Map <> CBMap.Text) and (CBMap.Text <> '')
         then exit;
         if (MasterFilter.PassWord) and (Nfo.PassWord <> '-' )
         then exit;
         if (MasterFilter.ACProtect) and (Nfo.AC = 'OFF')
         then exit;
         if (MasterFilter.EmptySrv) and (Nfo.NumPlayers = '0')
         then exit;
         if (MasterFilter.DedicSrv) and (Nfo.NumPlayers <> 'Dedicated')
         then exit;
         if (MasterFilter.FullSrv) and
            ((Nfo.NumPlayers + Nfo.ReservedSlots) >=  Nfo.MaxPlayers)
         then exit;
        end;

        Result := true
end;

Procedure TMainServer.AddServer(HPacket : TPacketHead; Nfo : TRInfo);
var LstItem : TListItem;
begin
        LstItem:= lvServers.FindCaption(0,HPacket.ip +':'+
                                          inttostr(HPacket.port)
                                         ,false, true, false);

        if LstItem <> nil then
        With lvServers.Items[LstItem.Index] do
         begin
          if HPacket.UdpTag = 6
          then
           Begin
            SubItems[4]:=inttostr(HPacket.Ping);
            exit;
           end;
          ImageIndex := nfo.Icn;
          SubItems[0]:=nfo.HostName;
          SubItems[1]:=nfo.Description;
          SubItems[2]:=nfo.OS;
          SubItems[3]:=nfo.Map;
          SubItems[5]:=(nfo.NumPlayers + '/' + nfo.MaxPlayers);
          SubItems[6]:=nfo.PassWord;
          SubItems[10]:=nfo.TypeServer
         end
        else
        begin
          LstItem := lvServers.Items.Add;
          With LstItem.SubItems do
           begin
            LstItem.ImageIndex := nfo.Icn;
            LstItem.Caption := HPacket.Address;
            Add(nfo.HostName);
            Add(nfo.Description);
            Add(nfo.OS);
            Add(nfo.Map);
            Add(inttostr(HPacket.Ping));
            Add(nfo.NumPlayers + '/' + nfo.MaxPlayers);
            Add(nfo.PassWord);
            Add(nfo.AC);
            Add(nfo.FF);
            Add(nfo.TimeLeft);
            Add(nfo.TypeServer)
           end
        end
end;

procedure TMainServer.lvServersColumnClick(Sender: TObject;
  Column: TListColumn);
begin
        ColumnToSort := Column.Index;
        ColumnSortUp := not ColumnSortUp;
        TCustomListView(Sender).AlphaSort
end;

 (*----------------------------------------------------------------------------+
  "LstPlayCompare" compares values into the Listview (players). The syntax was
  inspired from "eD2k Utils" (BierBaron).
 +----------------------------------------------------------------------------*)

procedure TMainServer.lvServersCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var ix, code1, code2: Integer;
    x, y: real;
begin
        ix := ColumnToSort - 1;

        if ix < 0 then
         begin
          if item1.ImageIndex < item2.ImageIndex then compare := -1
          else compare := 1;
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

procedure TMainServer.RestoredefaultColumnwidth1Click(Sender: TObject);
begin
        Case (Sender as TComponent).Tag of
        1 : With lvServers do
             begin
              Column[0].Width := 140;
              Column[1].Width := 160;
              Column[2].Width := 100;
              Column[3].Width := 100;
              Column[4].Width := 90;
              Column[5].Width := 40;
              Column[6].Width := 65;
              Column[7].Width := 65;
              Column[8].Width := 35;
              Column[9].Width := 35;
              Column[10].Width := 60;
              Column[11].Width := 70
             end;
        2 :  With lvServers2 do
             begin
              Column[0].Width := 140;
              Column[1].Width := 160;
              Column[2].Width := 300
             end
        end
end;

procedure TMainServer.lvServersDblClick(Sender: TObject);
begin
        Case (Sender as TComponent).Tag of
         1 : begin
              if lvServers.ItemIndex < 0 then exit;
              MainForm.CBedit.Text := lvServers.Selected.Caption
             end;
         2 : begin
              if lvServers2.ItemIndex < 0 then exit;
              MainForm.CBedit.Text := lvServers2.Selected.Caption
             end
         end;

        MainForm.SBnfo.Click;
        MainForm.BringToFront
end;

procedure TMainServer.Go1Click(Sender: TObject);
begin
        Case (Sender as TComponent).Tag of
         1 : MainForm.CBedit.Text := lvServers.Selected.Caption;
         2 : MainForm.CBedit.Text := lvServers2.Selected.Caption
        end;
        
        MainForm.BringToFront;
        MainForm.SBgo.Click
end;

procedure TMainServer.Importtobookmark1Click(Sender: TObject);
begin
        Case (Sender as TComponent).Tag of
         1 : MainForm.CBedit.Text := lvServers.Selected.Caption;
         2 : MainForm.CBedit.Text := lvServers2.Selected.Caption
        end;
        
        MainBook.AddServer(Sender)
end;

procedure TMainServer.Copyiptoclipboard1Click(Sender: TObject);
begin
        Case (Sender as TComponent).Tag of
         1 :Clipboard.AsText := LvServers.Selected.Caption;
         2 :Clipboard.AsText := LvServers2.Selected.Caption
        end
end;

procedure TMainServer.lvServers2ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
        if TListView(Sender).GetItemAt(MousePos.X,MousePos.Y) = nil
        then
         With Pop2 do
          begin
           Items[0].Enabled := false;
           Items[1].Enabled := false;
           Items[3].Enabled := false;
           Items[5].Enabled := false
        end
        else
         With Pop2 do
          begin
           Items[0].Enabled := true;
           Items[1].Enabled := true;
           Items[3].Enabled := true;
           Items[5].Enabled := true
          end
end;

procedure TMainServer.lvServersContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
        if LvServers.GetItemAt(MousePos.X,MousePos.Y) = nil
        then
         With Pop do
         begin
           Items[0].Enabled := false;
           Items[1].Enabled := false;
           Items[2].Enabled := false;
           Items[4].Enabled := false;
           Items[6].Enabled := false
         end
        else
          With Pop do
          begin
           Items[0].Enabled := true;
           Items[1].Enabled := true;
           Items[2].Enabled := true;
           Items[4].Enabled := true;
           Items[6].Enabled := true
          end
end;

procedure TMainServer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
        SBStop.Click
end;

procedure TMainServer.Image1Click(Sender: TObject);
begin
        try
         ShellExecute(Application.MainForm.Handle, Nil,
                      pchar('http://www.cstiger.de'), Nil, Nil, SW_SHOWNORMAL)
        except on E:Exception do getErrorLog(E.Message)
        end
end;

procedure TMainServer.CBEGamesClick(Sender: TObject);
begin
        Case CBEGames.ItemIndex of
           0..9: begin
                  lvServers.BringToFront;
                  TopPanel.Height := 26
                 end;
         10..11: begin
                  lvServers2.BringToFront;
                  TopPanel.Height := 79
                 end
        end
end;

end.
