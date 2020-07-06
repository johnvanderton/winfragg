object QueryMain: TQueryMain
  Left = 432
  Top = 329
  Width = 153
  Height = 57
  Caption = 'QueryMain'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object UDP: TNMUDP
    RemotePort = 0
    LocalPort = 17878
    ReportLevel = 3
    OnDataReceived = UDPDataReceived
    OnInvalidHost = UDPInvalidHost
    Left = 112
  end
end
