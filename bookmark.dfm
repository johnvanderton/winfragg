object MainBook: TMainBook
  Tag = 1
  Left = 64
  Top = 140
  Width = 920
  Height = 494
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'BookMark'
  Color = clBtnFace
  Constraints.MinWidth = 510
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lvServers: TListView
    Left = 0
    Top = 0
    Width = 912
    Height = 418
    Align = alClient
    BevelInner = bvSpace
    BevelOuter = bvSpace
    Columns = <
      item
        Caption = 'IP'
        Width = 155
      end
      item
        Caption = 'Host'
        Width = 200
      end
      item
        Caption = 'Map'
        Width = 80
      end
      item
        Caption = 'Description'
        Width = 100
      end
      item
        Caption = 'GameType'
        Width = 80
      end
      item
        Caption = 'Ping'
      end
      item
        Caption = 'Pop'
      end
      item
        Caption = 'Pass'
        Width = 40
      end
      item
        Caption = 'FF'
        Width = 35
      end
      item
        Caption = 'AC'
      end
      item
        Caption = 'TimeLeft'
        Width = 60
      end>
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    HideSelection = False
    HotTrack = True
    HotTrackStyles = [htUnderlineHot]
    HoverTime = 0
    IconOptions.AutoArrange = True
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    PopupMenu = PopupMenu
    SmallImages = MainForm.ImgLst
    TabOrder = 0
    ViewStyle = vsReport
    OnColumnClick = lvServersColumnClick
    OnCompare = lvServersCompare
    OnContextPopup = lvServersContextPopup
    OnDblClick = lvServersDblClick
    OnDeletion = lvServersDeletion
    OnInsert = lvServersInsert
  end
  object SBar: TStatusBar
    Left = 0
    Top = 448
    Width = 912
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Width = 220
      end
      item
        Alignment = taCenter
        Width = 140
      end
      item
        Alignment = taCenter
        Text = 'Auto retry delay : disabled'
        Width = 50
      end>
    SimplePanel = False
  end
  object Board: TPanel
    Tag = 1
    Left = 0
    Top = 418
    Width = 912
    Height = 30
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 2
    DesignSize = (
      912
      30)
    object SBRefresh: TSpeedButton
      Tag = 1
      Left = 786
      Top = 1
      Width = 70
      Height = 28
      Cursor = crHandPoint
      Anchors = [akRight]
      Caption = '&Refresh'
      Flat = True
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00770000000000
        0007770FFFFFFFFFFF07770FFFFF2FFFFF07770FFFF22FFFFF07770FFF22222F
        FF07770FFFF22FF2FF07770FFFFF2FF2FF07770FF2FFFFF2FF07770FF2FF2FFF
        FF07770FF2FF22FFFF07770FFF22222FFF07770FFFFF22FFFF07770FFFFF2FF0
        0007770FFFFFFFF0F077770FFFFFFFF007777700000000007777}
      OnClick = SBRefreshClick
    end
    object SBQuit: TSpeedButton
      Tag = 1
      Left = 856
      Top = 1
      Width = 55
      Height = 28
      Cursor = crHandPoint
      Anchors = [akTop, akRight, akBottom]
      Caption = '&Quit'
      Flat = True
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        7777777077777777770777000777777777777700007777777077777000777777
        0777777700077770077777777000770077777777770000077777777777700077
        7777777777000007777777777000770077777770000777700777770000777777
        0077770007777777770777777777777777777777777777777777}
      OnClick = SBQuitClick
    end
    object SBSave: TSpeedButton
      Tag = 1
      Left = 66
      Top = 1
      Width = 63
      Height = 28
      Cursor = crHandPoint
      Anchors = [akLeft]
      Caption = '&Save'
      Enabled = False
      Flat = True
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        7777770000000000000770330000007703077033000000770307703300000077
        0307703300000000030770333333333333077033000000003307703077777777
        0307703077777777030770307777777703077030777777770307703077777777
        0007703077777777070770000000000000077777777777777777}
      OnClick = SBSaveClick
    end
    object SBExport: TSpeedButton
      Tag = 1
      Left = 0
      Top = 1
      Width = 66
      Height = 28
      Cursor = crHandPoint
      Anchors = [akLeft]
      Caption = '&Export'
      Flat = True
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        0800000000000001000000000000000000000001000000010000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A60004040400080808000C0C0C0011111100161616001C1C1C00222222002929
        2900555555004D4D4D004242420039393900807CFF005050FF009300D600FFEC
        CC00C6D6EF00D6E7E70090A9AD000000330000006600000099000000CC000033
        00000033330000336600003399000033CC000033FF0000660000006633000066
        6600006699000066CC000066FF00009900000099330000996600009999000099
        CC000099FF0000CC000000CC330000CC660000CC990000CCCC0000CCFF0000FF
        660000FF990000FFCC00330000003300330033006600330099003300CC003300
        FF00333300003333330033336600333399003333CC003333FF00336600003366
        330033666600336699003366CC003366FF003399000033993300339966003399
        99003399CC003399FF0033CC000033CC330033CC660033CC990033CCCC0033CC
        FF0033FF330033FF660033FF990033FFCC0033FFFF0066000000660033006600
        6600660099006600CC006600FF00663300006633330066336600663399006633
        CC006633FF00666600006666330066666600666699006666CC00669900006699
        330066996600669999006699CC006699FF0066CC000066CC330066CC990066CC
        CC0066CCFF0066FF000066FF330066FF990066FFCC00CC00FF00FF00CC009999
        000099339900990099009900CC009900000099333300990066009933CC009900
        FF00996600009966330099336600996699009966CC009933FF00999933009999
        6600999999009999CC009999FF0099CC000099CC330066CC660099CC990099CC
        CC0099CCFF0099FF000099FF330099CC660099FF990099FFCC0099FFFF00CC00
        000099003300CC006600CC009900CC00CC0099330000CC333300CC336600CC33
        9900CC33CC00CC33FF00CC660000CC66330099666600CC669900CC66CC009966
        FF00CC990000CC993300CC996600CC999900CC99CC00CC99FF00CCCC0000CCCC
        3300CCCC6600CCCC9900CCCCCC00CCCCFF00CCFF0000CCFF330099FF6600CCFF
        9900CCFFCC00CCFFFF00CC003300FF006600FF009900CC330000FF333300FF33
        6600FF339900FF33CC00FF33FF00FF660000FF663300CC666600FF669900FF66
        CC00CC66FF00FF990000FF993300FF996600FF999900FF99CC00FF99FF00FFCC
        0000FFCC3300FFCC6600FFCC9900FFCCCC00FFCCFF00FFFF3300CCFF6600FFFF
        9900FFFFCC006666FF0066FF660066FFFF00FF666600FF66FF00FFFF66002100
        A5005F5F5F00777777008686860096969600CBCBCB00B2B2B200D7D7D700DDDD
        DD00E3E3E300EAEAEA00F1F1F100F8F8F800F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00EEEEEEEEEEEE
        EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE00EEEEEEEEEEEEEEEEEEEEEEEEEE
        EE00FE00EEEEEEEEEEEEEEEEEEEEEEEE00FEFEFE00EEEEEEEEEEEEEEEEEEEE00
        FEFEFEFEFE00EEEEEEEEEEEEEEEE00FEFEFEFEFEFEFE00EEEEEEEEEEEE00ECEC
        ECFEFEFEFEECEC00EEEEEEEEEEEEEEEECDD9FEFED3EEEEEEEEEEEEEEEEEEEEEE
        CDD9D3D9D3EEEEEEEEEEEEEEEEEEEECDD3D3D3E6D3EEEEEEEEEEEEEEEEEEC8AC
        CDD3D9E6D3EEEEEEEEEEC8C8C8C8C8C8CDFFE6E6EEEEEEEEEEEEEEC8E6E6E6FF
        FFE6E6EEEEEEEEEEEEEEEEEEC8E6E6E6E6EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
        EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE}
      OnClick = SBExportClick
    end
    object SBGo: TSpeedButton
      Tag = 1
      Left = 730
      Top = 1
      Width = 56
      Height = 28
      Cursor = crHandPoint
      Anchors = [akRight]
      Caption = '&Go !'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        7777777777777777777777777777777777777777777777777777770000000000
        007777F888888888807777F777777777807777F777777777807777F777777777
        807777F777777777807777F777777777807777FFFFFFFFFFF077777777777777
        7777777777777777777777777777777777777777777777777777}
      ParentFont = False
      OnClick = SBGoClick
    end
    object SBAdd: TSpeedButton
      Tag = 1
      Left = 129
      Top = 1
      Width = 56
      Height = 28
      Cursor = crHandPoint
      Anchors = [akLeft]
      Caption = '&Add'
      Flat = True
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        333333333333FF3333333333333C0C333333333333F777F3333333333CC0F0C3
        333333333777377F33333333C30F0F0C333333337F737377F333333C00FFF0F0
        C33333F7773337377F333CC0FFFFFF0F0C3337773F33337377F3C30F0FFFFFF0
        F0C37F7373F33337377F00FFF0FFFFFF0F0C7733373F333373770FFFFF0FFFFF
        F0F073F33373F333373730FFFFF0FFFFFF03373F33373F333F73330FFFFF0FFF
        00333373F33373FF77333330FFFFF000333333373F333777333333330FFF0333
        3333333373FF7333333333333000333333333333377733333333333333333333
        3333333333333333333333333333333333333333333333333333}
      NumGlyphs = 2
      OnClick = SBAddClick
    end
    object SBConfig: TSpeedButton
      Tag = 1
      Left = 185
      Top = 1
      Width = 56
      Height = 28
      Cursor = crHandPoint
      Anchors = [akLeft]
      Caption = '&Setup'
      Flat = True
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00370777033333
        3330337F3F7F33333F3787070003333707303F737773333373F7007703333330
        700077337F3333373777887007333337007733F773F333337733700070333333
        077037773733333F7F37703707333300080737F373333377737F003333333307
        78087733FFF3337FFF7F33300033330008073F3777F33F777F73073070370733
        078073F7F7FF73F37FF7700070007037007837773777F73377FF007777700730
        70007733FFF77F37377707700077033707307F37773F7FFF7337080777070003
        3330737F3F7F777F333778080707770333333F7F737F3F7F3333080787070003
        33337F73FF737773333307800077033333337337773373333333}
      NumGlyphs = 2
      OnClick = SBConfigClick
    end
  end
  object PopupMenu: TPopupMenu
    Images = MainForm.ImgLst
    Left = 8
    Top = 384
    object Refresh1: TMenuItem
      Bitmap.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00770000000000
        0007770FFFFFFFFFFF07770FFFFF2FFFFF07770FFFF22FFFFF07770FFF22222F
        FF07770FFFF22FF2FF07770FFFFF2FF2FF07770FF2FFFFF2FF07770FF2FF2FFF
        FF07770FF2FF22FFFF07770FFF22222FFF07770FFFFF22FFFF07770FFFFF2FF0
        0007770FFFFFFFF0F077770FFFFFFFF007777700000000007777}
      Caption = '&Refresh'
      Default = True
      GroupIndex = 1
      OnClick = Refresh1Click
    end
    object Queryserver1: TMenuItem
      Tag = 2
      Bitmap.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        0800000000000001000000000000000000000001000000010000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A60004040400080808000C0C0C0011111100161616001C1C1C00222222002929
        2900555555004D4D4D004242420039393900807CFF005050FF009300D600FFEC
        CC00C6D6EF00D6E7E70090A9AD000000330000006600000099000000CC000033
        00000033330000336600003399000033CC000033FF0000660000006633000066
        6600006699000066CC000066FF00009900000099330000996600009999000099
        CC000099FF0000CC000000CC330000CC660000CC990000CCCC0000CCFF0000FF
        660000FF990000FFCC00330000003300330033006600330099003300CC003300
        FF00333300003333330033336600333399003333CC003333FF00336600003366
        330033666600336699003366CC003366FF003399000033993300339966003399
        99003399CC003399FF0033CC000033CC330033CC660033CC990033CCCC0033CC
        FF0033FF330033FF660033FF990033FFCC0033FFFF0066000000660033006600
        6600660099006600CC006600FF00663300006633330066336600663399006633
        CC006633FF00666600006666330066666600666699006666CC00669900006699
        330066996600669999006699CC006699FF0066CC000066CC330066CC990066CC
        CC0066CCFF0066FF000066FF330066FF990066FFCC00CC00FF00FF00CC009999
        000099339900990099009900CC009900000099333300990066009933CC009900
        FF00996600009966330099336600996699009966CC009933FF00999933009999
        6600999999009999CC009999FF0099CC000099CC330066CC660099CC990099CC
        CC0099CCFF0099FF000099FF330099CC660099FF990099FFCC0099FFFF00CC00
        000099003300CC006600CC009900CC00CC0099330000CC333300CC336600CC33
        9900CC33CC00CC33FF00CC660000CC66330099666600CC669900CC66CC009966
        FF00CC990000CC993300CC996600CC999900CC99CC00CC99FF00CCCC0000CCCC
        3300CCCC6600CCCC9900CCCCCC00CCCCFF00CCFF0000CCFF330099FF6600CCFF
        9900CCFFCC00CCFFFF00CC003300FF006600FF009900CC330000FF333300FF33
        6600FF339900FF33CC00FF33FF00FF660000FF663300CC666600FF669900FF66
        CC00CC66FF00FF990000FF993300FF996600FF999900FF99CC00FF99FF00FFCC
        0000FFCC3300FFCC6600FFCC9900FFCCCC00FFCCFF00FFFF3300CCFF6600FFFF
        9900FFFFCC006666FF0066FF660066FFFF00FF666600FF66FF00FFFF66002100
        A5005F5F5F00777777008686860096969600CBCBCB00B2B2B200D7D7D700DDDD
        DD00E3E3E300EAEAEA00F1F1F100F8F8F800F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00EEEEEEEEEEEE
        EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE00EEEEEEEEEEEEEEEEEEEEEEEEEE
        EE00FE00EEEEEEEEEEEEEEEEEEEEEEEE00FEFEFE00EEEEEEEEEEEEEEEEEEEE00
        FEFEFEFEFE00EEEEEEEEEEEEEEEE00FEFEFEFEFEFEFE00EEEEEEEEEEEE00ECEC
        ECFEFEFEFEECEC00EEEEEEEEEEEEEEEECDD9FEFED3EEEEEEEEEEEEEEEEEEEEEE
        CDD9D3D9D3EEEEEEEEEEEEEEEEEEEECDD3D3D3E6D3EEEEEEEEEEEEEEEEEEC8AC
        CDD3D9E6D3EEEEEEEEEEC8C8C8C8C8C8CDFFE6E6EEEEEEEEEEEEEEC8E6E6E6FF
        FFE6E6EEEEEEEEEEEEEEEEEEC8E6E6E6E6EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
        EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE}
      Caption = '&Query server'
      GroupIndex = 1
      OnClick = Queryserver1Click
    end
    object Go1: TMenuItem
      Caption = 'Go ! (with password)'
      GroupIndex = 1
      OnClick = Go1Click
    end
    object N1: TMenuItem
      Caption = '-'
      GroupIndex = 1
    end
    object Addserver1: TMenuItem
      Tag = 3
      Caption = '&Add server (auto)'
      GroupIndex = 1
      OnClick = AddServer
    end
    object AddserverManually: TMenuItem
      Caption = '&Add server Manually'
      GroupIndex = 1
      OnClick = AddServer
    end
    object Removeall1: TMenuItem
      Caption = '&Remove all'
      GroupIndex = 1
      OnClick = Removeall1Click
    end
    object Removeserver1: TMenuItem
      Bitmap.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        7777777077777777770777000777777777777700007777777077777000777777
        0777777700077770077777777000770077777777770000077777777777700077
        7777777777000007777777777000770077777770000777700777770000777777
        0077770007777777770777777777777777777777777777777777}
      Caption = '&Remove server'
      GroupIndex = 1
      OnClick = Removeserver1Click
    end
    object N2: TMenuItem
      Caption = '-'
      GroupIndex = 1
    end
    object Copyserverinfo2: TMenuItem
      Bitmap.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        777777777744444444477777774FFFFFFF477777774F00000F470000004FFFFF
        FF470FFFFF4F00000F470F00004FFFFFFF470FFFFF4F00F444470F00004FFFF4
        F4770FFFFF4FFFF447770F00F044444477770FFFF0F0777777770FFFF0077777
        7777000000777777777777777777777777777777777777777777}
      Caption = '&Copy server address'
      GroupIndex = 1
      OnClick = Copyserverinfo2Click
    end
    object Copyserverinfo1: TMenuItem
      Caption = '&Copy server info'
      GroupIndex = 1
      OnClick = Copyserverinfo1Click
    end
    object N3: TMenuItem
      Caption = '-'
      GroupIndex = 1
    end
    object Options1: TMenuItem
      Bitmap.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        0800000000000001000000000000000000000001000000010000FFFFFF00C0C0
        C000808080000000800000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000FFFFFF00010101010101
        0101010101010101010101010404040404040404040401010101010100000000
        0000000000000401010101010000000101000000000004010101010100000003
        0101000000000401010101010000030303010100000004010101010100030300
        0303010000000401010101010000000000030201000004010101010100000000
        0000030101000401010101010000000000000003010004010101010100000000
        0000000003000401010101010000000000000000000004010101010100000404
        0404040400000401010101010101040001010104010101010101010101010101
        0101010101010101010101010101010101010101010101010101}
      Caption = '&Options'
      GroupIndex = 1
      object RefreshTming1: TMenuItem
        Caption = '&Network settings'
        OnClick = RefreshTming1Click
      end
      object Advancedsettings1: TMenuItem
        Caption = '&Advanced settings'
        OnClick = SBConfigClick
      end
    end
    object RestoreDefaultcolwigth1: TMenuItem
      Caption = '&Restore default column width'
      GroupIndex = 1
      OnClick = RestoreDefaultcolwigth1Click
    end
    object N4: TMenuItem
      Caption = '-'
      GroupIndex = 1
    end
    object Exit1: TMenuItem
      Caption = '&Exit'
      GroupIndex = 1
      OnClick = Exit1Click
    end
  end
end