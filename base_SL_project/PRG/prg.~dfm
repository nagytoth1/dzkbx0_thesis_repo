object Form1: TForm1
  Left = 251
  Top = 125
  Width = 955
  Height = 567
  Caption = 'HealtStart'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 939
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 4
      Width = 74
      Height = 13
      Caption = 'Inform'#225'ci'#243's s'#225'v'
    end
    object Panel2: TPanel
      Left = 259
      Top = 3
      Width = 81
      Height = 30
      Caption = 'mainPanel'
      TabOrder = 0
      Visible = False
      OnClick = Panel2Click
      OnMouseDown = Panel2MouseDown
    end
    object TrackBar1: TTrackBar
      Left = 360
      Top = 8
      Width = 441
      Height = 45
      Max = 10000
      Min = 100
      Frequency = 100
      Position = 100
      TabOrder = 1
      OnChange = TrackBar1Change
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 41
    Width = 939
    Height = 467
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = #220'temek be'#225'll'#237't'#225'sa'
      object ScrollBox1: TScrollBox
        Left = 0
        Top = 0
        Width = 931
        Height = 439
        VertScrollBar.Smooth = True
        Align = alClient
        DragMode = dmAutomatic
        Color = clWhite
        ParentColor = False
        TabOrder = 0
        object Image1: TImage
          Left = 0
          Top = 0
          Width = 927
          Height = 435
          Align = alClient
          Stretch = True
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Programsz'#246'veg'
      ImageIndex = 1
      object ListBox1: TListBox
        Left = 0
        Top = 0
        Width = 931
        Height = 439
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 88
    Top = 1
    object Program1: TMenuItem
      Caption = 'Program'
      object Inicializls1: TMenuItem
        Caption = 'Eszk'#246'z'#246'k felm'#233'r'#233'se'
        OnClick = Inicializls1Click
      end
      object Start1: TMenuItem
        Caption = 'Eszk'#246'z'#246'k inicializ'#225'l'#225'sa'
        OnClick = Start1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Kilps1: TMenuItem
        Caption = 'Kil'#233'p'#233's a programb'#243'l'
        OnClick = Kilps1Click
      end
    end
    object esztek1: TMenuItem
      Caption = 'Tesztek'
      Enabled = False
      Visible = False
      object Csoportkldstesztelse1: TMenuItem
        Caption = 'Csoportk'#252'ld'#233's tesztel'#233'se'
        OnClick = Csoportkldstesztelse1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
    end
    object Eszkzlista1: TMenuItem
      Caption = 'Program k'#233'sz'#237't'#233'se'
      object jsorozathozzadsa1: TMenuItem
        Caption = #220'tem hozz'#225'ad'#225'sa'
        OnClick = jsorozathozzadsa1Click
      end
    end
    object Programok1: TMenuItem
      Caption = 'Programok kezel'#233'se'
      object Programbetltse1: TMenuItem
        Caption = 'Feladatsor bet'#246'lt'#233'se'
        OnClick = Programbetltse1Click
      end
      object Programmentse1: TMenuItem
        Caption = 'Feladatsor ment'#233'se'
        OnClick = Programmentse1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Feladatsorszerkesztse1: TMenuItem
        Caption = 'Feladatsor szerkeszt'#233'se'
        OnClick = Feladatsorszerkesztse1Click
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Programindtsa1: TMenuItem
        Caption = 'Feladatsor futtat'#225'sa'
        OnClick = Programindtsa1Click
      end
    end
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 120
    Top = 1
  end
  object PopupMenu1: TPopupMenu
    Left = 217
    Top = 2
    object Belltsok1: TMenuItem
      Caption = 'Elem be'#225'll'#237't'#225'sai'
      OnClick = Belltsok1Click
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 152
  end
  object OpenDialog1: TOpenDialog
    Left = 184
  end
end
