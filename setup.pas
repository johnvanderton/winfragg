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

unit setup;

interface

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  jpeg, ExtCtrls, ComCtrls, StdCtrls, Buttons, ShellApi, Registry,
  Spin, constants, Dialogs;

type
  TSetupMain = class(TForm)
    ListGame: TListView;   
    TreeView: TTreeView;
    PGeneral: TPanel;
    LGeneral: TLabel;
    LPlayer: TLabel;
    EGPName: TEdit;
    PAbout: TPanel;
    VersionInfo: TMemo;
    CBGMin: TCheckBox;
    PGames: TPanel;
    PColors: TPanel;
    LBDisplay: TLabel;
    CBQonjoin: TCheckBox;
    PAdvance: TPanel;
    LbAdvancedSettings: TLabel;
    CBAutoRefreshQueryMain: TCheckBox;
    SEAutoRefreshQueryMain: TSpinEdit;
    PNetwork: TPanel;
    LBNetworkSettings: TLabel;
    RB28k: TRadioButton;
    RB36k6: TRadioButton;
    RB56k: TRadioButton;
    RBISDN: TRadioButton;
    RBBroad: TRadioButton;
    SENetwork: TSpinEdit;
    BClosesettings: TButton;
    LBInfoPanel: TLabel;
    LBPlayerPanel: TLabel;
    PGConfig: TPanel;
    LBConfigGame: TLabel;
    LBPath: TLabel;
    LBExtra: TLabel;
    SBSeek: TSpeedButton;
    EPath: TEdit;
    EEXtra: TEdit;
    CBProto: TComboBox;
    LBProto: TLabel;
    PMisc: TListView;
    SpinProto: TSpinEdit;
    SBSave: TSpeedButton;
    SBBAck: TSpeedButton;
    LBPort: TLabel;
    EPort: TEdit;
    OpenD: TOpenDialog;
    LBVal: TLabel;
    Image2: TImage;
    LBBookmarkList: TLabel;
    CBSaveServer: TCheckBox;
    CBAutoRefreshQueryBook: TCheckBox;
    SEAutoRefreshQueryBook: TSpinEdit;
    SColorInfo: TShape;
    SColorPlayer: TShape;
    BChangeInfoColor: TButton;
    BChangePlayerColor: TButton;
    BFontInfo: TButton;
    BFontPlayers: TButton;
    LBAddressField: TLabel;
    SColorField: TShape;
    BChangeFieldColor: TButton;
    SBReset: TSpeedButton;
    SaveD: TSaveDialog;
    RBGoClick: TRadioButton;
    RBQClick: TRadioButton;
    Bevel8: TBevel;
    LBONjoin: TLabel;
    RBFloodJoin: TRadioButton;
    RBNormalJoin: TRadioButton;
    CBGStats: TCheckBox;
    SPMaxServerQuery: TSpinEdit;
    CBMaxServerQuery: TCheckBox;
    LBMasterQueryServer: TLabel;
    CBFullServer: TCheckBox;
    CBEmptyServer: TCheckBox;
    CBPassword: TCheckBox;
    CBDServer: TCheckBox;
    CBVAC: TCheckBox;
    CBFF: TCheckBox;
    LBWarningFlood: TLabel;
    CBCopyclip: TCheckBox;
    CBMinjoin: TCheckBox;
    procedure Image2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BClosesettingsClick(Sender: TObject);
    procedure SBBAckClick(Sender: TObject);
    procedure LoadValue(Gnode : TListItem);
    procedure SBSeekClick(Sender: TObject);
    procedure CBProtoChange(Sender: TObject);
    procedure RB28kClick(Sender: TObject);
    procedure Initializing();
    procedure TreeViewClick(Sender: TObject);
    procedure LoadGameconf;
    procedure SBSaveClick(Sender: TObject);
    procedure RB36k6Click(Sender: TObject);
    procedure RB56kClick(Sender: TObject);
    procedure RBISDNClick(Sender: TObject);
    procedure RBBroadClick(Sender: TObject);
    procedure CBAutoRefreshQueryMainClick(Sender: TObject);
    procedure CBMaxServerQueryClick(Sender: TObject);
    procedure CBAutoRefreshQueryBookClick(Sender: TObject);
    procedure BChangeInfoColorClick(Sender: TObject);
    procedure BChangePlayerColorClick(Sender: TObject);
    procedure BFontInfoClick(Sender: TObject);
    procedure BFontPlayersClick(Sender: TObject);
    procedure BFontFieldClick(Sender: TObject);
    procedure BChangeFieldColorClick(Sender: TObject);
    procedure SBResetClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure SENetworkChange(Sender: TObject);
    procedure ListGameMouseDown(Sender: TObject; Button: TMouseButton;
                                Shift: TShiftState; X, Y: Integer);
    procedure SEAutoRefreshQueryMainChange(Sender: TObject);
  end;

var SetupMain: TSetupMain;

implementation

uses Main, syslib, bookmark, servermain;

{$R *.dfm}

procedure TSetupMain.FormCreate(Sender: TObject);
var MyRegistry: TRegistry;
begin
     try
        VersionInfo.Lines.LoadFromFile(VERSIONFILE)
        except on E:Exception do getErrorLog(E.Message);
     end;

     MyRegistry := TRegistry.Create;

     if not MyRegistry.OpenKey('SOFTWARE\AMU\winfragg\',false) then
        MessageDlg
        ('No informations retrieved in registry.'+#13+
         'You are running for the fisrt time or reconfiguring. '+
         'Please set the options.'
         +#13
         +#13+
         '<! The network''s value has been validated on LAN,T1,Broadband !>'
         +#13
         +#13+
         'Just for fun :), Wash',mtWarning, [mbOk], 0)
     else Initializing;

     MyRegistry.CloseKey;
     MyRegistry.Free
end;

(*----------------------------------------------------------------------------+
  "LoadGameconf" loads gamepaths and settings into ListGame (memory)
 +----------------------------------------------------------------------------*)

procedure TSetupMain.LoadGameconf;
var i,j:byte;
    MyRegistry: TRegistry;
begin
        MyRegistry := TRegistry.Create;
        ListGame.Items.BeginUpdate;

        For i:=0 to ListGame.Items.Count-1  do
         if MyRegistry.OpenKey('SOFTWARE\AMU\winfragg\games\'
                                + ListGame.Items[i].SubItems[0], false)
         then
         begin
           ListGame.Items[i].SubItems[1] := MyRegistry.ReadString('pathgame');
           ListGame.Items[i].SubItems[2] := MyRegistry.ReadString('extracmd');
           ListGame.Items[i].SubItems[3] := MyRegistry.ReadString('gamedefaultport');
           ListGame.Items[i].SubItems[4] := MyRegistry.ReadString('protocolvalue');
           ListGame.Items[i].SubItems[5] := MyRegistry.ReadString('protocolname');
           j:=6;
           While j < ListGame.Items[i].SubItems.Count - 1 do
             begin
              ListGame.Items[i].SubItems[j+2]:=
              inttostr(MyRegistry.ReadInteger(ListGame.Items[i].SubItems[j]));
              inc(j,3)
             end;
           MyRegistry.CloseKey;
         end;
        ListGame.Items.EndUpdate; 
        MyRegistry.Free
end;

(*----------------------------------------------------------------------------+
  "Initializing" loads values from registry 
 +----------------------------------------------------------------------------*)

procedure TSetupMain.Initializing();
var MyRegistry: TRegistry;
    i : byte;
begin
        MyRegistry := TRegistry.Create;

        with MyRegistry do
        begin

         OpenKey('SOFTWARE\AMU\winfragg\',false);
          EGPName.Text := ReadString('playername');
          CBGStats.Checked := ReadBool('statsreport');
          CBGMin.Checked := ReadBool('minimizeonstart');
          CBCopyClip.Checked := ReadBool('copytoclipboardonjoin');
          CBMinJoin.Checked := ReadBool('minimizeonjoin');
          CBQonJoin.Checked := ReadBool('quitonjoin');
          RBGoClick.Checked := ReadBool('bookgoclick');
          RBQClick.Checked := ReadBool('bookqclick');
          RBFloodJoin.Checked := ReadBool('brutalflood');
          RBNormalJoin.Checked := ReadBool('normaljoin');
          RB28k.Checked := ReadBool('m28k');
          RB36k6.Checked := ReadBool('m36k6');
          RB36k6.Checked := ReadBool('m56k');
          RBISDN.Checked := ReadBool('misdn');
          RBBroad.Checked := ReadBool('mbroad');
          SENetwork.Value := ReadInteger('networkdelay');
          CBAutoRefreshQueryMain.Checked := ReadBool('autorefreshquerymain');
          SEAutoRefreshQueryMain.Value := ReadInteger('autorefreshquerymainvalue');
          CBMaxServerQuery.Checked :=  ReadBool('maxserverquery');
          CBAutoRefreshQueryBook.Checked := ReadBool('autorefreshquerybook');
          SEAutoRefreshQueryBook.Value := ReadInteger('autorefreshquerybookvalue');
          SPMaxServerQuery.Value := ReadInteger('maxserverqueryvalue');
          CBSaveServer.Checked := ReadBool('alwayssaveserverlist');
          CBFullServer.Checked := ReadBool('qfullserver');
          CBEmptyServer.Checked := ReadBool('qemptyserver');
          CBPassword.Checked := ReadBool('qpasswordserver');
          CBDServer.Checked := ReadBool('qdedicatedserver');
          CBVAC.Checked := ReadBool('qvacserver');
          CBFF.Checked := ReadBool('qffserver');
          if ReadBool('enlarged') then MainForm.SBroll.Click;
         CloseKey;

         OpenKey('SOFTWARE\AMU\winfragg\windows\main',false);
          MainForm.Left := ReadInteger('mainleft');
          MainForm.Top := ReadInteger('maintop');
          MainForm.LstPlay.Column[0].Width := ReadInteger('col0');
          MainForm.LstPlay.Column[1].Width := ReadInteger('col1');
          MainForm.LstPlay.Column[2].Width := ReadInteger('col2');
          MainForm.LstPlay.Column[3].Width := ReadInteger('col3');
          MainForm.LstPlay.Column[4].Width := ReadInteger('col4');
          MainForm.LstPlay.Column[5].Width := ReadInteger('col5');
          MainForm.InfoPanel.Color := ReadInteger('infopanelcolor');
          MainForm.InfoPanel.Font.Charset := ReadInteger('infopanelfontcharset');
          MainForm.InfoPanel.Font.Color := ReadInteger('infopanelfontcolor');
          MainForm.InfoPanel.Font.Size := ReadInteger('infopanelfontsize');
          MainForm.LstPlay.Color := ReadInteger('playerpanelcolor');
          MainForm.LstPlay.Font.Charset := ReadInteger('playerpanelfontcharset');
          MainForm.LstPlay.Font.Color := ReadInteger('playerpanelfontcolor');
          MainForm.LstPlay.Font.Size := ReadInteger('playerpanelfontsize');
          MainForm.CBedit.Color := ReadInteger('addressfieldcolor');
          SetupMain.SColorPlayer.Brush.Color := MainForm.LstPlay.Color;
          SetupMain.SColorInfo.Brush.Color := MainForm.InfoPanel.Color;
          SColorField.Brush.Color := MainForm.CBedit.Color;
         CloseKey;

         OpenKey('SOFTWARE\AMU\winfragg\windows\bookmark',false);
          MainBook.Left := ReadInteger('bookleft');
          MainBook.Top := ReadInteger('booktop');
          MainBook.Width := ReadInteger('bookwidth');
          MainBook.Height := ReadInteger('bookheight');
          MainBook.lvServers.Column[0].Width := ReadInteger('col0');
          MainBook.lvServers.Column[1].Width := ReadInteger('col1');
          MainBook.lvServers.Column[2].Width := ReadInteger('col2');
          MainBook.lvServers.Column[3].Width := ReadInteger('col3');
          MainBook.lvServers.Column[4].Width := ReadInteger('col4');
          MainBook.lvServers.Column[5].Width := ReadInteger('col5');
          MainBook.lvServers.Column[6].Width := ReadInteger('col6');
          MainBook.lvServers.Column[7].Width := ReadInteger('col7');
          MainBook.lvServers.Column[8].Width := ReadInteger('col8');
          MainBook.lvServers.Column[9].Width := ReadInteger('col9');
         CloseKey;

         OpenKey('SOFTWARE\AMU\winfragg\windows\serverquery',false);
          MainServer.Left := ReadInteger('serveleft');
          MainServer.Top := ReadInteger('servetop');
          MainServer.Width := ReadInteger('servewidth');
          MainServer.Height := ReadInteger('serveheight');
          MainServer.TopPanel.Height := ReadInteger('servertoppanelheigth');
          MainServer.lvServers.Column[0].Width := ReadInteger('col0');
          MainServer.lvServers.Column[1].Width := ReadInteger('col1');
          MainServer.lvServers.Column[2].Width := ReadInteger('col2');
          MainServer.lvServers.Column[3].Width := ReadInteger('col3');
          MainServer.lvServers.Column[4].Width := ReadInteger('col4');
          MainServer.lvServers.Column[5].Width := ReadInteger('col5');
          MainServer.lvServers.Column[6].Width := ReadInteger('col6');
          MainServer.lvServers.Column[7].Width := ReadInteger('col7');
          MainServer.lvServers.Column[8].Width := ReadInteger('col8');
          MainServer.lvServers.Column[9].Width := ReadInteger('col9');
          MainServer.lvServers.Column[10].Width := ReadInteger('col10');
          MainServer.lvServers.Column[11].Width := ReadInteger('col11');
          if MainServer.TopPanel.Height > 27
          then MainServer.lvServers2.BringToFront
          else MainServer.lvServers.BringToFront;
         CloseKey;

         OpenKey('SOFTWARE\AMU\winfragg\logs\history',false);
          for i:=0 to 4 do
          begin
           MainForm.CBedit.Items.Add (ReadString('ip'+IntTostr(i)));
           MainServer.CBName.Items.Add (ReadString('name'+IntTostr(i)));
           MainServer.CBMap.Items.Add (ReadString('map'+IntTostr(i)));
           MainServer.CBMod.Items.Add (ReadString('mod'+IntTostr(i)));
           MainServer.CBPing.Items.Add (ReadString('ping'+IntTostr(i)));
          end;

          MainForm.CBedit.Text := ReadString('ip0');
          
          MainServer.CBEGames.ItemIndex := ReadInteger('indexquerygame');
          MainServer.CBMap.Text := ReadString('map0');
          MainServer.CBMod.Text := ReadString('mod0');
          MainServer.CBPinging.text := ReadString('querypinging');
          MainServer.CBPing.Text := ReadString('ping4');
          MainServer.CBName.ItemIndex := ReadInteger('serverqueryname');
          MainServer.CBGames.ItemIndex := ReadInteger('serverquerygame');                     
          MainServer.CBNetwork.ItemIndex := ReadInteger('serverquerynetwork');
         CloseKey;

         RootKey:=HKEY_LOCAL_MACHINE;
         lazywrite := false;

         Openkey('Software\Classes\winfragg\shell\open\command',true);
          WriteString('',Application.ExeName +  ' %1');
         Closekey;
         OpenKey('SOFTWARE\Classes\winfragg\', false);
          WriteString('','URL:wgg Protocol');
          WriteString('URL Protocol','');
         Closekey;

         Free;
        end;

        if not CBGMin.Checked then MainForm.Show;
        MainBook.Sbar.Panels[1].Text := 'Network delay : '
                               + SetupMain.SENetwork.Text + ' ms';
end;

(*----------------------------------------------------------------------------+
  "LoadGameconf" saves values to registry
 +----------------------------------------------------------------------------*)

procedure TSetupMain.BClosesettingsClick(Sender: TObject);
var MyRegistry: TRegistry;
    i,j : byte;
begin
        MyRegistry := TRegistry.Create;

        with MyRegistry do
        begin

         OpenKey('SOFTWARE\AMU\winfragg\',true);
          WriteString('playername',EGPName.Text);
          WriteBool('statsreport',CBGStats.Checked);
          WriteBool('minimizeonstart',CBGMin.Checked);
          WriteBool('copytoclipboardonjoin',CBCopyclip.Checked);
          WriteBool('minimizeonjoin',CBMinjoin.Checked);
          WriteBool('quitonjoin',CBQonjoin.Checked);
          WriteBool('bookgoclick',RBGoClick.Checked);
          WriteBool('bookqclick',RBQClick.Checked);
          WriteBool('m28k',RB28k.Checked);
          WriteBool('m36k6',RB36k6.Checked);
          WriteBool('m56k',RB36k6.Checked);
          WriteBool('misdn',RBISDN.Checked);
          WriteBool('mbroad',RBBroad.Checked);
          WriteBool('brutalflood',RBFloodJoin.Checked);
          WriteBool('normaljoin',RBNormalJoin.Checked);
          WriteInteger('networkdelay',SENetwork.Value);
          WriteBool('alwayssaveserverlist',CBSaveServer.Checked);
          WriteBool('allowbasicreportstat',CBGStats.Checked);
          WriteBool('autorefreshquerymain',CBAutoRefreshQueryMain.Checked);
          WriteInteger('autorefreshquerymainvalue',SEAutoRefreshQueryMain.Value);
          WriteBool('autorefreshquerybook',CBAutoRefreshQueryBook.Checked);
          WriteInteger('autorefreshquerybookvalue',SEAutoRefreshQueryBook.Value);
          WriteBool('maxserverquery',CBMaxServerQuery.Checked);
          WriteInteger('maxserverqueryvalue',SPMaxServerQuery.Value);
          WriteBool('qfullserver',CBFullServer.Checked);
          WriteBool('qemptyserver',CBEmptyServer.Checked);
          WriteBool('qpasswordserver',CBPassword.Checked);
          WriteBool('qdedicatedserver',CBDServer.Checked);
          WriteBool('qvacserver',CBVAC.Checked);
          WriteBool('qffserver',CBFF.Checked);

          if MainForm.Height > 200 then WriteBool('enlarged',true)
          else WriteBool('enlarged',false);
         CloseKey;

         OpenKey('SOFTWARE\AMU\winfragg\windows\main',true);
          WriteInteger('mainleft',MainForm.Left);
          WriteInteger('maintop',MainForm.Top);
          WriteInteger('col0',MainForm.LstPlay.Column[0].Width);
          WriteInteger('col1',MainForm.LstPlay.Column[1].Width);
          WriteInteger('col2',MainForm.LstPlay.Column[2].Width);
          WriteInteger('col3',MainForm.LstPlay.Column[3].Width);
          WriteInteger('col4',MainForm.LstPlay.Column[4].Width);
          WriteInteger('col5',MainForm.LstPlay.Column[5].Width);
          WriteInteger('infopanelcolor',MainForm.InfoPanel.Color);
          WriteInteger('infopanelfontcharset',MainForm.InfoPanel.Font.Charset);
          WriteInteger('infopanelfontcolor',MainForm.InfoPanel.Font.Color);
          WriteInteger('infopanelfontsize',MainForm.InfoPanel.Font.Size);
          WriteInteger('playerpanelcolor',MainForm.LstPlay.Color);
          WriteInteger('playerpanelfontcharset',MainForm.LstPlay.Font.Charset);
          WriteInteger('playerpanelfontcolor',MainForm.LstPlay.Font.Color);
          WriteInteger('playerpanelfontsize',MainForm.LstPlay.Font.Size);
          WriteInteger('addressfieldcolor',MainForm.CBedit.Color);
         CloseKey;

         OpenKey('SOFTWARE\AMU\winfragg\windows\bookmark',true);
          WriteInteger('bookleft',MainBook.Left);
          WriteInteger('booktop',MainBook.Top);
          WriteInteger('bookwidth',MainBook.Width);
          WriteInteger('bookheight',MainBook.Height);
          WriteInteger('col0',MainBook.lvServers.Column[0].Width);
          WriteInteger('col1',MainBook.lvServers.Column[1].Width);
          WriteInteger('col2',MainBook.lvServers.Column[2].Width);
          WriteInteger('col3',MainBook.lvServers.Column[3].Width);
          WriteInteger('col4',MainBook.lvServers.Column[4].Width);
          WriteInteger('col5',MainBook.lvServers.Column[5].Width);
          WriteInteger('col6',MainBook.lvServers.Column[6].Width);
          WriteInteger('col7',MainBook.lvServers.Column[7].Width);
          WriteInteger('col8',MainBook.lvServers.Column[8].Width);
          WriteInteger('col9',MainBook.lvServers.Column[9].Width);
          WriteInteger('col10',MainBook.lvServers.Column[10].Width);
         CloseKey;

         OpenKey('SOFTWARE\AMU\winfragg\windows\serverquery',true);
          WriteInteger('serveleft',MainServer.Left);
          WriteInteger('servetop',MainServer.Top);
          WriteInteger('servewidth',MainServer.Width);
          WriteInteger('serveheight',MainServer.Height);
          WriteInteger('servertoppanelheigth',MainServer.TopPanel.Height);
          WriteInteger('col0',MainServer.lvServers.Column[0].Width);
          WriteInteger('col1',MainServer.lvServers.Column[1].Width);
          WriteInteger('col2',MainServer.lvServers.Column[2].Width);
          WriteInteger('col3',MainServer.lvServers.Column[3].Width);
          WriteInteger('col4',MainServer.lvServers.Column[4].Width);
          WriteInteger('col5',MainServer.lvServers.Column[5].Width);
          WriteInteger('col6',MainServer.lvServers.Column[6].Width);
          WriteInteger('col7',MainServer.lvServers.Column[7].Width);
          WriteInteger('col8',MainServer.lvServers.Column[8].Width);
          WriteInteger('col9',MainServer.lvServers.Column[9].Width);
          WriteInteger('col10',MainServer.lvServers.Column[10].Width);
          WriteInteger('col11',MainServer.lvServers.Column[11].Width);
          WriteInteger('s2col0',MainServer.lvServers2.Column[0].Width);
          WriteInteger('s2col1',MainServer.lvServers2.Column[1].Width);
          WriteInteger('s2col2',MainServer.lvServers2.Column[2].Width);
         CloseKey;

         OpenKey('SOFTWARE\AMU\winfragg\logs\history',true);

          WriteInteger('indexquerygame',MainServer.CBEGames.ItemIndex);
          WriteInteger('serverqueryname',MainServer.CBName.ItemIndex);
          WriteInteger('serverquerygame',MainServer.CBGames.ItemIndex);
          WriteInteger('serverquerynetwork',MainServer.CBNetwork.ItemIndex);
          
          j:=0;
          for i:=MainForm.CBedit.Items.Count downto 0 do
           if (MainForm.CBedit.Items[i] <> '') and (j < 5) then
            begin
             MyRegistry.WriteString('ip'+IntToStr(j),MainForm.CBedit.Items[i]);
             inc(j)
            end;

          j:=0;
          for i:=MainServer.CBName.Items.Count downto 0 do
           if (MainServer.CBName.Items[i] <> '') and (j < 5) then
            begin
             MyRegistry.WriteString('name'+IntToStr(j),MainServer.CBName.Items[i]);
             inc(j)
            end;

          j:=0;
          for i:=MainServer.CBMap.Items.Count downto 0 do
           if (MainServer.CBMap.Items[i] <> '') and (j < 5) then
            begin
             MyRegistry.WriteString('map'+IntToStr(j),MainServer.CBMap.Items[i]);
             inc(j)
            end;

          j:=0;
          for i:=MainServer.CBMod.Items.Count downto 0 do
           if (MainServer.CBMod.Items[i] <> '') and (j < 5) then
            begin
             MyRegistry.WriteString('mod'+IntToStr(j),MainServer.CBMod.Items[i]);
             inc(j)
            end;

          j:=0;
          for i:=MainServer.CBPing.Items.Count downto 0 do
           if (MainServer.CBPing.Items[i] <> '') and (j < 5) then
            begin
             MyRegistry.WriteString('ping'+IntToStr(j),MainServer.CBPing.Items[i]);
             inc(j)
            end;
         CloseKey;

         if Tform(Sender).Tag = 0 then exit
         else hide;

         For i:=0 to ListGame.Items.Count-1 do
         With MyRegistry do
          begin
           OpenKey('SOFTWARE\AMU\winfragg\games\'+ListGame.Items[i].SubItems[0], true);
           WriteString('pathgame',ListGame.Items[i].SubItems[1]);
           WriteString('extracmd',ListGame.Items[i].SubItems[2]);
           WriteString('gamedefaultport',ListGame.Items[i].SubItems[3]);
           WriteString('protocolvalue',ListGame.Items[i].SubItems[4]);
           WriteString('protocolname',ListGame.Items[i].SubItems[5]);
           j:=6;
           While j < ListGame.Items[i].SubItems.Count-1 do
             begin
                WriteInteger(ListGame.Items[i].SubItems[j],
                             strtoint(ListGame.Items[i].SubItems[j+2]));
                inc(j,3)
             end;
           CloseKey
          end;

         Free;
        end;
end;

procedure TSetupMain.SBBAckClick(Sender: TObject);
begin
        ListGame.ItemFocused.Selected := false;
        PGames.BringToFront
end;

(*----------------------------------------------------------------------------+
  "LoadValue" gets "Gnode" TListItem type. Loads values from ListGame's items
 +----------------------------------------------------------------------------*)

procedure TSetupMain.LoadValue(Gnode : TListItem);
var NList : TListItem;
    i : byte;
begin
        LBConfigGame.Caption := Gnode.Caption;
        EPath.Text   := Gnode.SubItems[1];
        EExtra.Text  := Gnode.SubItems[2];
        EPort.Text   := Gnode.SubItems[3];
        SPinProto.value := strtoint(Gnode.SubItems[4]);
        CBProto.Text := Gnode.SubItems[5];

        PMisc.Clear;
        i:=6;
        While i < Gnode.SubItems.Count - 1 do
        begin
           NList := PMisc.Items.Add;
           if Gnode.SubItems[i+2] = '1'
           then NList.Checked := true;
           NList.Caption := Gnode.SubItems[i];
           inc(i);
           NList.SubItems.Add(Gnode.SubItems[i]);
           inc(i,2);
        end;

        if i > 6 then PMisc.Visible := true
        else PMisc.Visible := false
end;

procedure TSetupMain.SBSeekClick(Sender: TObject);//into items..
begin
        case ListGame.Selected.ImageIndex of
            1 : OpenD.Filter := 'Half-Life|*.exe';
            9 : OpenD.Filter := 'Unreal 2003|*.exe';
            7 : OpenD.Filter := 'Unreal Tournament|*.exe';
           10 : OpenD.Filter := 'BatteField|*.exe';
           11 : OpenD.Filter := 'Medal of Honor|*.exe';
           12 : OpenD.Filter := 'Operation FlashPoint|*.exe';
           13 : OpenD.Filter := 'Serious Sam|*.exe';
           14 : OpenD.Filter := 'Serious Sam 2|*.exe';
           15 : OpenD.Filter := 'Alien vs Predator 2|*.exe';
           16 : OpenD.Filter := 'Quake 3|*.exe';
           17 : OpenD.Filter := 'Return to Castle Wolfenstein|*.exe';
           18 : OpenD.Filter := 'Wolfenstein Enemy Territory|*.exe';
           19 : OpenD.Filter := 'Jedi Knight 2|*.exe';
           20 : OpenD.Filter := 'Soldier of Fortune 2|*.exe';
           21 : OpenD.Filter := 'Star Trek|*.exe'
        end;

        OpenD.execute;
        if OpenD.FileName <> '' then EPath.text := OpenD.FileName
end;

procedure TSetupMain.CBProtoChange(Sender: TObject);
begin
        case CBProto.ItemIndex of
            0 : SpinProto.Value := 43;
            1 : SpinProto.Value := 45;
            2 : SpinProto.Value := 46;
            3 : SpinProto.Value := 15;
            4 : SpinProto.Value := 16;
            5 : SpinProto.Value := 43;
            6 : SpinProto.Value := 45;
            7 : SpinProto.Value := 46;
            8 : SpinProto.Value := 47;
            9 : SpinProto.Value := 48;
           10 : SpinProto.Value := 66;
           11 : SpinProto.Value := 67;
           12 : SpinProto.Value := 68;
           13 : SpinProto.Value := 56;
           14 : SpinProto.Value := 57;
           15 : SpinProto.Value := 58;
           16 : SpinProto.Value := 59;
           17 : SpinProto.Value := 60;
           18 : SpinProto.Value := 2003;
           19 : SpinProto.Value := 2004;
           20 : SpinProto.Value := 23;
           21 : SpinProto.Value := 24;
           22 : SpinProto.Value := 82
        end;
end;

procedure TSetupMain.TreeViewClick(Sender: TObject);
begin
        if (Sender as TTreeView).Selected.StateIndex > -1 then
          case (Sender as TTreeView).Selected.Index of
            0 : PGeneral.BringToFront;
            1 : Pcolors.BringToFront;
            2 : PNetwork.BringToFront;
            3 : PAbout.BringToFront;
          end
        else
          if (Sender as TTreeView).Selected.Index = 0
          then PGames.BringToFront
          else PAdvance.BringToFront
end;

procedure TSetupMain.SBSaveClick(Sender: TObject);
var i,j : byte;
begin
        if ListGame.Selected = nil then exit;

        With ListGame.Selected do
         begin
          SubItems[1] := EPath.Text;
          SubItems[2] := EEXtra.Text;
          SubItems[3] := EPort.Text;
          SubItems[4] := SpinProto.Text;
          SubItems[5] := CBProto.Text;
         end;

        i:=0; j:=8;
        while i < PMisc.Items.Count do
        begin
         if PMisc.Items[i].Checked then ListGame.Selected.SubItems[j] := '1'
         else ListGame.Selected.SubItems[j] := '0';
         inc(i); inc(j,3)
        end
end;

procedure TSetupMain.SBResetClick(Sender: TObject);
begin
        MainForm.InfoPanel.Color := ClBlack;
        MainForm.InfoPanel.Font.Name := 'Terminal';
        MainForm.InfoPanel.Font.Color := ClSilver;
        MainForm.InfoPanel.Font.Size := 7;

        SetupMain.SColorInfo.Brush.Color := ClBlack;
        SetupMain.BFontInfo.Font := MainForm.InfoPanel.Font;

        MainForm.LstPlay.Color := ClBlack;
        MainForm.LstPlay.Font.Name := 'Terminal';
        MainForm.LstPlay.Font.Color := ClSilver;
        MainForm.LstPlay.Font.Size := 7;

        SetupMain.SColorPlayer.Brush.Color := ClBlack;
        SetupMain.BFontPlayers.Font := MainForm.LstPlay.Font;

        MainForm.CBedit.Color := ClBlack;
        SetupMain.SColorField.Brush.Color := ClBlack
end;

procedure TSetupMain.CBAutoRefreshQueryMainClick(Sender: TObject);
begin
        SEAutoRefreshQueryMain.enabled := CBAutoRefreshQueryMain.Checked;
        MainForm.AutoRefresh.Enabled := CBAutoRefreshQueryMain.Checked;

        if CBAutoRefreshQueryMain.Checked
        then
         begin
          MainForm.AutoRefresh.Interval := SEAutoRefreshQueryMain.Value*1000;
          if MainForm.SBroll.Tag = 1
          then MainForm.AutoRefresh.Enabled := true;
        end
end;

procedure TSetupMain.CBMaxServerQueryClick(Sender: TObject);
begin
        SPMaxServerQuery.Enabled := CBMaxServerQuery.Checked;
        if not CBMaxServerQuery.Checked
        then  SPMaxServerQuery.Value := MAXSERVER
end;

procedure TSetupMain.CBAutoRefreshQueryBookClick(Sender: TObject);
begin
        SEAutoRefreshQueryBook.Enabled := CBAutoRefreshQueryBook.Checked;
        if CBAutoRefreshQueryBook.Checked
        then
          MainBook.Sbar.Panels[2].Text := 'Auto retry delay : '
                                 + SetupMain.SEAutoRefreshQueryBook.Text
                                 + ' sec'
        else
          MainBook.Sbar.Panels[2].Text := 'Auto retry delay : disabled'

end;

procedure TSetupMain.SENetworkChange(Sender: TObject);
begin
        MainBook.Sbar.Panels[1].Text := 'Network delay : '
                               + SetupMain.SENetwork.Text + ' ms';
end;

procedure TSetupMain.ListGameMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
       if ListGame.Selected = nil then exit;
       if Button=mbleft then
        begin
         LoadValue(ListGame.ItemFocused);
         PGConfig.BringToFront
        end
end;

procedure TSetupMain.Image2Click(Sender: TObject);
begin
        try
        ShellExecute(Application.MainForm.Handle, Nil,
                     pchar('http://winfragg.sourceforge.net'), Nil, Nil, SW_SHOWNORMAL)
        except on E:Exception do getErrorLog(E.Message)
        end
end;

procedure TSetupMain.SEAutoRefreshQueryMainChange(Sender: TObject);
begin
        MainForm.AutoRefresh.Interval:=SetupMain.SEAutoRefreshQueryMain.Value*1000
end;

procedure TSetupMain.RB28kClick(Sender: TObject);
begin
        SENetwork.Value := m28k;
end;

procedure TSetupMain.RB36k6Click(Sender: TObject);
begin
        SENetwork.Value := m36k;
end;

procedure TSetupMain.RB56kClick(Sender: TObject);
begin
        SENetwork.Value := m56k;
end;

procedure TSetupMain.RBISDNClick(Sender: TObject);
begin
        SENetwork.Value := ISDN;
end;

procedure TSetupMain.RBBroadClick(Sender: TObject);
begin
        SENetwork.Value := DSL;
end;

procedure TSetupMain.BChangeInfoColorClick(Sender: TObject);
begin
        MainForm.ChangeColors(Sender)
end;
                  
procedure TSetupMain.BChangePlayerColorClick(Sender: TObject);
begin
        MainForm.ChangeColors(Sender)
end;

procedure TSetupMain.BChangeFieldColorClick(Sender: TObject);
begin
        MainForm.ChangeColors(Sender)
end;

procedure TSetupMain.BFontInfoClick(Sender: TObject);
begin
        MainForm.ChangeFonts(Sender)
end;

procedure TSetupMain.BFontPlayersClick(Sender: TObject);
begin
        MainForm.ChangeFonts(Sender)
end;

procedure TSetupMain.BFontFieldClick(Sender: TObject);
begin
        MainForm.ChangeFonts(Sender)
end;

procedure TSetupMain.FormActivate(Sender: TObject);
begin
        BClosesettings.SetFocus
end;

end.
