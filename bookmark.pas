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
 
unit bookmark;

interface

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, Forms, Clipbrd,
  Buttons, ComCtrls, queryLib, ExtCtrls, StdCtrls, sysLib, Menus, Registry,
  Dialogs, tstruct, Setup;

type
  TMainBook = class(TForm)
    lvServers: TListView;
    SBar: TStatusBar;
    Board: TPanel;
    SBRefresh: TSpeedButton;
    SBQuit: TSpeedButton;
    SBSave: TSpeedButton;
    PopupMenu: TPopupMenu;
    AddserverManually: TMenuItem;
    SBExport: TSpeedButton;
    SBGo: TSpeedButton;
    SBAdd: TSpeedButton;
    SBConfig: TSpeedButton;
    Advancedsettings1: TMenuItem;
    RestoreDefaultcolwigth1: TMenuItem;
    procedure GetPacket(HPacket : TPacketHead; SInfo : TRINfo);
    procedure lvServersColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvServersCompare(Sender: TObject; Item1, Item2: TListItem;
                               Data: Integer; var Compare: Integer);
    procedure SBSaveClick(Sender: TObject);
    procedure Queryserver1Click(Sender: TObject);
    procedure Removeserver1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure lvServersContextPopup(Sender: TObject; MousePos: TPoint;
              var Handled: Boolean);
    procedure Removeall1Click(Sender: TObject);
    procedure SBRefreshClick(Sender: TObject);
    procedure AddServer(Sender : TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure lvServersDeletion(Sender: TObject; Item: TListItem);
    procedure lvServersInsert(Sender: TObject; Item: TListItem);
    procedure Copyserverinfo2Click(Sender: TObject);
    procedure Copyserverinfo1Click(Sender: TObject);
    procedure Operation(n : byte);
    procedure SBExportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Refreshing(Sender: TObject);
    procedure RefreshTming1Click(Sender: TObject);
    procedure lvServersDblClick(Sender: TObject);
    procedure SBGoClick(Sender: TObject);
    procedure Go1Click(Sender: TObject);
    procedure SBQuitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MinimizeTray;
    procedure SBAddClick(Sender: TObject);
    procedure SBConfigClick(Sender: TObject);
    procedure RestoreDefaultcolwigth1Click(Sender: TObject);
    private
     ColumnToSort: integer;
     ColumnSortUp: boolean;
     LatencyTimer, AutoRefreshTimer : TTimer;
     Index : byte;
  end;

var MainBook: TMainBook;

implementation

uses main;

{$R *.dfm}

(*----------------------------------------------------------------------------+
  "Operation" indicates the current action.
 +----------------------------------------------------------------------------*)

procedure TMainBook.Operation(n : byte);
var i,j : byte;
begin
        Case n of
         1 : begin
              i:=0; j:=0;
              while i <= lvServers.Items.Count -1 do
               begin
                if LvServers.Items[i].SubItems[1] <> '' then inc(j);
                inc(i);
               end;
              Sbar.Panels[0].Text := inttostr(lvServers.Items.Count) +
                                     ' server(s) listed, ' +
                                     inttostr(j) + ' active(s) server(s)'
             end;
         2 : begin
              Sbar.Panels[0].Text :=
              inttostr(lvServers.Items.Count)+
              ' server(s) succesfully saved to registry';
              SBSave.Enabled := false
             end
        end
end;

(*----------------------------------------------------------------------------+
  "GetPacket" gets HPacket TPacketHead type and SInfo TRInfo type informations.
  It does an insertion or an update of servers.
 +----------------------------------------------------------------------------*)

procedure TMainBook.GetPacket(HPacket : TPacketHead; SInfo : TRInfo);
var LstItem, LStItem2 : TListItem;
begin
        LstItem:= lvServers.FindCaption(0, HPacket.ip +':'+
                                           inttostr(HPacket.port)
                                          ,false, true, false);

        if LstItem <> nil
        then
          if HPacket.UdpTag <> 2
          then
            with lvServers.Items[LstItem.Index] do
              if SInfo.IdRec = 'HLRules'
              then
              begin
                SubItems[4] := inttostr(Hpacket.ping);
                SubItems[7] := SInfo.FF;
                SubItems[8] := SInfo.AC;
                SubItems[9] := SInfo.TimeLeft;
              end
              else
              begin
                ImageIndex  := SInfo.Icn;
                SubItems[0] := SInfo.HostName;
                SubItems[1] := SInfo.Map;
                SubItems[2] := SInfo.Description;
                SubItems[3] := SInfo.GameType;
                SubItems[5] := SInfo.NumPlayers + '/' + SInfo.MaxPlayers;
                SubItems[6] := SInfo.PassWord;
                if SInfo.IdRec <> 'HLInfo'
                then
                  begin
                   SubItems[4] := inttostr(Hpacket.ping);
                   SubItems[7] := SInfo.FF;
                   SubItems[8] := SInfo.AC
                  end
              end
          else MessageDlg('Server already exists in bookmark',
                           mtInformation, [mbOk], 0)
        else
          if HPacket.udpTag = 2 then
          begin
            LStItem2 := LvServers.Items.Add;
            With LStItem2.SubItems do
              begin
                LStItem2.Caption := HPacket.ip+':'+inttostr(HPacket.port);
                LStItem2.ImageIndex := 0;
                Add('');
                Add('');
                Add('');
                Add('');
                Add('');
                Add('');
                Add('');
                Add('');
                Add('');
                Add('')
              end;
            SBRefresh.Click
           end
end;

(*----------------------------------------------------------------------------+
  "Refreshing" does a query for each server in bookmark.
 +----------------------------------------------------------------------------*)

procedure TMainBook.Refreshing;
var Q : ShortString;
begin
        if index = LvServers.Items.Count then
         begin
          LatencyTimer.Free;
          SBRefresh.Enabled := true;
          Index := 0;
          Operation(1);
          if SetupMain.CBAutoRefreshQueryBook.Checked
          then
            With AutoRefreshTimer do
             begin
              Interval :=SetupMain.SEAutoRefreshQueryBook.Value*1000;
              Enabled := true
             end
          else AutoRefreshTimer.Enabled := false;
          exit
         end;

         case LvServers.Items[index].ImageIndex of
                 0 : Q := 'b';//BroadCast
              1..6 : Q := 'v';//Valve
             7..14 : Q := 'e';//Epic
            15..21 : Q := 'i'//iD
         end;

         try
         QueryMain.QueryServer(3,Q,LvServers.Items[index].Caption)
         except on E:Exception do GetErrorLog(E.Message)
         end;
         
         inc(index)
end;

procedure TMainBook.SBRefreshClick(Sender: TObject);
begin
        if (not SBRefresh.Enabled) or (lvServers.Items.Count = 0) then exit;

        if SBRefresh.Enabled then SBRefresh.Enabled := false;

        LatencyTimer := TTimer.create (nil);
        LatencyTimer.Interval := SetupMain.SENetwork.Value;
        LatencyTimer.OnTimer := Refreshing
end;

procedure TMainBook.lvServersColumnClick(Sender: TObject;
  Column: TListColumn);
begin
        ColumnToSort := Column.Index;
        ColumnSortUp := not ColumnSortUp;
        (Sender as TCustomListView).AlphaSort
end;

 (*----------------------------------------------------------------------------+
  "lvServersCompare" compares values into the Listview (players). The syntax
  was inspired from "eD2k Utils" (BierBaron).
 +----------------------------------------------------------------------------*)

procedure TMainBook.lvServersCompare(Sender: TObject; Item1,
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

procedure TMainBook.SBSaveClick(Sender: TObject);
var MyRegistry: TRegistry;
    i : byte;
begin
        MyRegistry := TRegistry.Create;
        With MyRegistry do
        begin
         OpenKey('SOFTWARE\AMU\winfragg\bookmark',true);

         i:=0;
         While not (i = lvServers.Items.Count) do
          begin
           WriteString('server'+inttostr(i),lvServers.Items[i].Caption);
           inc(i);
          end;

         While ValueExists('server'+inttostr(i)) do
         begin
           MyRegistry.DeleteValue('server'+inttostr(i));
           inc(i);
         end;  
         CloseKey;
         Free
         
        end;
        
        Operation(2)
end;

procedure TMainBook.lvServersContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
        if LvServers.GetItemAt(MousePos.X,MousePos.Y) = nil
        then
         With PopupMenu do
         begin
             Items[1].Enabled := false;
             Items[2].Enabled := false;
             Items[7].Enabled := false;
             Items[8].Enabled := false;
             Items[9].Enabled := false;
             Items[10].Enabled := false;
         end
         else
          With PopupMenu do
          begin
             Items[1].Enabled := true;
             Items[2].Enabled := true;
             Items[7].Enabled := true;
             Items[8].Enabled := true;
             Items[9].Enabled := true;
             Items[10].Enabled := true;
          end
end;

procedure TMainBook.Removeall1Click(Sender: TObject);
begin      
        if LvServers.Items.Count > 0
        then
          if MessageDlg(#13+'Remove all the server List ? ',
                         mtConfirmation, [mbYes, mbNo], 0) = mrYes
          then LvServers.Clear
end;

 (*----------------------------------------------------------------------------+
  "AddServer" adds a new server.
 +----------------------------------------------------------------------------*)

procedure TMainBook.AddServer(Sender : TObject);
var HPacket : TPackethead;
    NewIP : String;
    NAddress : TAdd;
    NPacket : TRInfo;
begin   
        NewIP := Mainform.CBedit.text;
        if not inputQuery('Add server to bookmark',
                          '(Note : auto add server requires an active server)',
                          NewIp)
        then exit;

        Naddress := GetAddress(NewIp,0);//again ds queryserver ..
        if NAddress.ko = 0
        then
          begin
            HPacket.ip := Naddress.ip;
            HPacket.port := Naddress.port;
            HPacket.UdpTag := 2;
            if TMenuItem(Sender).Tag = 2
            then
             try
             QueryMain.QueryServer(2,'b',HPacket.ip +':'+inttostr(HPacket.port))//3
             except on E:Exception do GetErrorLog(E.Message)
             end
            else GetPacket(HPacket,NPacket);
            MainBook.Visible := true;
            MainBook.BringToFront
          end
        else MessageDlg('Please insert a valid IP'+#13+
                        '(Format : xxx.xxx.xxx.xxx:xxxxx)', mtWarning, [mbOk], 0)
end;

procedure TMainBook.FormCreate(Sender: TObject);
var MyRegistry: TRegistry;
    NItem : TListItem;
    i : byte;
begin
        MyRegistry := TRegistry.Create;
        MyRegistry.OpenKey('SOFTWARE\AMU\winfragg\bookmark\', false);

        i:=0;
        while MyRegistry.ValueExists('server'+ inttostr(i))=true do
        begin
           NItem := LvServers.Items.Add;
           NItem.Caption := Myregistry.ReadString('server'+inttostr(i));
           NItem.SubItems.Add('');
           NItem.SubItems.Add('');
           NItem.SubItems.Add('');
           NItem.SubItems.Add('');
           NItem.SubItems.Add('');
           NItem.SubItems.Add('');
           NItem.SubItems.Add('');
           NItem.SubItems.Add('');
           NItem.SubItems.Add('');
           NItem.SubItems.Add('');
           NItem.SubItems.Add('');
           inc(i)
        end;

        MyRegistry.CloseKey;
        MyRegistry.Free;

        Operation(2);

        AutoRefreshTimer:=TTimer.Create(self);
        AutoRefreshTimer.Enabled := false;
        AutoRefreshTimer.OnTimer := SBRefreshClick
end;

procedure TMainBook.RestoreDefaultcolwigth1Click(Sender: TObject);
begin
        lvServers.Column[0].Width := 140;
        lvServers.Column[1].Width := 160;
        lvServers.Column[2].Width := 100;
        lvServers.Column[3].Width := 100;
        lvServers.Column[4].Width := 90;
        lvServers.Column[5].Width := 40;
        lvServers.Column[6].Width := 45;
        lvServers.Column[7].Width := 55;
        lvServers.Column[8].Width := 35;
        lvServers.Column[9].Width := 35;
        lvServers.Column[10].Width := 60
end;

procedure TMainBook.Queryserver1Click(Sender: TObject);
begin
        MainForm.InfoPanel.Clear;
        MainForm.LstPlay.Clear;
        MainForm.CBedit.Text := LvServers.Selected.Caption;
        MainForm.BringToFront;
        MainForm.SBnfo.Click
end;

procedure TMainBook.SBQuitClick(Sender: TObject);
begin
        if SBSave.Enabled then
        begin
         if SetupMain.CBSaveServer.Checked then SBSave.Click
         else
          if MessageDlg(#13+'Save the server list ? ',
                         mtConfirmation, [mbYes, mbNo], 0) = mrYes
          then SBSave.Click
          else SBSave.Enabled := false
        end;

        MainBook.Close
end;

procedure TMainBook.SBGoClick(Sender: TObject);
begin
        if LvServers.SelCount = 0 then
        begin
           MessageDlg(#13+'Please choose a server first..',mtWarning, [mbOk], 0);
           exit
        end;

        MainForm.CBedit.Text := LvServers.Selected.Caption;
        MainForm.DisplayIconServer(LvServers.Selected.ImageIndex);
        MainForm.BringToFront;
        MainForm.SBGo.Click
end;

procedure TMainBook.lvServersDblClick(Sender: TObject);
begin
        if lvServers.ItemIndex < 0 then exit;

        if SetupMain.RBQClick.Checked then Queryserver1Click(nil)
        else SBGo.Click
end;

procedure TMainBook.SBConfigClick(Sender: TObject);
begin
        SetupMain.PAdvance.BringToFront;
        SetupMain.Show
end;

procedure TMainBook.RefreshTming1Click(Sender: TObject);
begin
        SetupMain.PNetwork.BringToFront;
        SetupMain.Show
end;

procedure TMainBook.MinimizeTray;
begin
        AutoRefreshTimer.Enabled := false;
        Hide
end;

procedure TMainBook.Go1Click(Sender: TObject);
begin
        SBGo.Click
end;

procedure TMainBook.FormClose(Sender: TObject; var Action: TCloseAction);
begin
        AutoRefreshTimer.Enabled := false
end;

procedure TMainBook.Removeserver1Click(Sender: TObject);
begin
        LvServers.Items.Delete(LvServers.Selected.Index)
end;

procedure TMainBook.Exit1Click(Sender: TObject);
begin
        Close
end;

procedure TMainBook.Refresh1Click(Sender: TObject);
begin
        SBRefresh.Click
end;

procedure TMainBook.lvServersDeletion(Sender: TObject; Item: TListItem);
begin
        SBsave.Enabled := true
end;

procedure TMainBook.lvServersInsert(Sender: TObject; Item: TListItem);
begin
        SBsave.Enabled := true
end;

procedure TMainBook.Copyserverinfo2Click(Sender: TObject);
begin
        Clipboard.AsText := LvServers.Selected.Caption
end;

procedure TMainBook.Copyserverinfo1Click(Sender: TObject);
begin
        ClipBoard.AsText := LVservers.Selected.SubItems.Text
end;

procedure TMainBook.SBExportClick(Sender: TObject);
begin
        MainForm.Serverlist.Click
end;

procedure TMainBook.SBAddClick(Sender: TObject);
begin
        AddserverManually.Click
end;

end.
