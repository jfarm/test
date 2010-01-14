object Form1: TForm1
  Left = 240
  Top = 131
  Caption = 'HTTP vs FTP'
  ClientHeight = 401
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 560
    Height = 401
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 0
    object Panel2: TPanel
      Left = 0
      Top = 219
      Width = 560
      Height = 182
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object pbTotal: TProgressBar
        Left = 0
        Top = 17
        Width = 560
        Height = 17
        Align = alTop
        TabOrder = 0
      end
      object memoLog: TMemo
        Left = 0
        Top = 34
        Width = 560
        Height = 148
        Align = alClient
        ImeName = 'Microsoft Office IME 2007'
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object pbEach: TProgressBar
        Left = 0
        Top = 0
        Width = 560
        Height = 17
        Align = alTop
        TabOrder = 2
      end
    end
    object vst: TVirtualStringTree
      Left = 0
      Top = 33
      Width = 560
      Height = 186
      Align = alClient
      Header.AutoSizeIndex = -1
      Header.DefaultHeight = 17
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
      IncrementalSearch = isAll
      NodeDataSize = 4
      TabOrder = 1
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowRoot, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect]
      Columns = <
        item
          Position = 0
          Width = 400
          WideText = #54028#51068#51060#47492
        end
        item
          Position = 1
          Width = 100
          WideText = #54028#51068#53356#44592
        end>
    end
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 560
      Height = 33
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 2
      object btnHttp: TButton
        Left = 400
        Top = 4
        Width = 75
        Height = 25
        Caption = 'HTTP '#51204#49569
        TabOrder = 0
        OnClick = btnHttpClick
      end
      object btnFtp: TButton
        Left = 481
        Top = 4
        Width = 75
        Height = 25
        Caption = 'FTP '#51204#49569
        TabOrder = 1
        OnClick = btnFtpClick
      end
      object btnOpenDialog: TButton
        Left = 4
        Top = 4
        Width = 75
        Height = 25
        Caption = #54028#51068#49440#53469
        TabOrder = 2
        OnClick = btnOpenDialogClick
      end
    end
  end
  object rs: TRscmRecordSet
    Duplicates = dupIgnore
    CaseSensitive = False
    Sorted = False
    ColumnDef = <
      item
        DataType = ctUnknown
        Alignment = taLeftJustify
        Name = 'NAME'
        Text = #54028#51068#51060#47492
        Width = 400
        Position = 1
        Hide = False
        Visible = True
        Filtered = True
        Tag = 0
      end
      item
        DataType = ctUnknown
        Alignment = taLeftJustify
        Name = 'SIZE'
        Text = #54028#51068#53356#44592
        Width = 100
        Position = 2
        Hide = False
        Visible = True
        Filtered = True
        Tag = 0
      end>
    Left = 8
    Top = 64
  end
  object db: TRscmDataBridge
    RecordSet = rs
    VTree = vst
    Connected = False
    KeepFocused = False
    AutoSort = False
    Left = 40
    Top = 64
  end
end
