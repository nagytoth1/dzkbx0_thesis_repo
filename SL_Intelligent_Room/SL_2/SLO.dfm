object SLF: TSLF
  Left = 1043
  Top = 86
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'SL'
  ClientHeight = 552
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Scaled = False
  ShowHint = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object SelDevGroup: TGroupBox
    Left = 8
    Top = 0
    Width = 361
    Height = 104
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    Visible = False
    object DevListBox: TListBox
      Left = 24
      Top = 24
      Width = 315
      Height = 17
      Hint = 'V�laszt�s t�bb csatlakoztatott eszk�zb�l.'
      Anchors = [akLeft, akTop, akRight]
      ExtendedSelect = False
      ItemHeight = 13
      TabOrder = 0
      OnDblClick = KivalasztButtonClick
      OnKeyDown = DevListBoxKeyDown
      OnMouseMove = DevListBoxMouseMove
    end
    object MegsemValasztButton: TButton
      Left = 231
      Top = 63
      Width = 69
      Height = 25
      Hint = 'V�laszt�s n�lk�li befejez�s.'
      Anchors = [akRight, akBottom]
      Caption = '&M�gsem'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = KilepClick
    end
    object KivalasztButton: TButton
      Left = 56
      Top = 63
      Width = 69
      Height = 25
      Hint = 'A list�ban kiv�lasztott eszk�z kiv�laszt�sa.'
      Anchors = [akLeft, akBottom]
      Caption = '&Kiv�laszt�s'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = KivalasztButtonClick
    end
  end
  object EEPmuvelet: TGroupBox
    Left = 8
    Top = 0
    Width = 401
    Height = 105
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Visible = False
    object Gauge: TGauge
      Left = 24
      Top = 40
      Width = 353
      Height = 25
      Hint = 'A friss�t�si folyamat �llapota'
      Anchors = [akLeft, akTop, akRight]
      ForeColor = clBlue
      MaxValue = 15872
      Progress = 0
    end
  end
  object NumEditBox: TGroupBox
    Left = 8
    Top = 0
    Width = 333
    Height = 137
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Visible = False
    object NOFejLabel: TLabel
      Left = 57
      Top = 24
      Width = 219
      Height = 17
      Hint = 
        'Az azonos�t� �rt�ke. Az �rt�ke nem lehet 0, �s'#13#10'kisebb kell hogy' +
        ' legyen 16383-n�l.'
      Alignment = taCenter
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Az aktu�lis azonos�t�'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
    end
    object AzonositoKilep: TButton
      Left = 234
      Top = 96
      Width = 69
      Height = 25
      Hint = 'Kil�p�s m�dos�t�s n�lk�l'
      Anchors = [akRight, akBottom]
      Caption = '&M�gsem'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = KilepClick
    end
    object NumEdit: TEdit
      Left = 136
      Top = 48
      Width = 61
      Height = 28
      Hint = 
        'Az azonos�t� �rt�ke. Az �rt�ke nem lehet 0, �s'#13#10'kisebb kell hogy' +
        ' legyen 16383-n�l.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      MaxLength = 5
      ParentFont = False
      TabOrder = 1
      OnChange = NumEditChange
      OnKeyPress = NumEditKeyPress
    end
    object AzonositoBeallit: TButton
      Left = 30
      Top = 96
      Width = 69
      Height = 25
      Hint = 'Az azonos�t� m�dos�t�s elind�t�sa'
      Anchors = [akLeft, akBottom]
      Caption = '&Be�ll�t'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = AzonositoBeallitClick
    end
  end
  object LEDLampaGroupBox: TGroupBox
    Left = 8
    Top = 0
    Width = 409
    Height = 457
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 3
    Visible = False
    object BeleptetoOraLabel: TLabel
      Left = 16
      Top = 40
      Width = 153
      Height = 17
      Alignment = taCenter
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
    end
    object LocTimeOraLabel: TLabel
      Left = 240
      Top = 40
      Width = 153
      Height = 17
      Cursor = crHandPoint
      Hint = 
        'Ha erre a r�szre katiintasz, akkor a PC aktu�lis'#13#10'ideje �tm�sol�' +
        'sra ker�l a bel�ptet� �r�j�ba.'
      Alignment = taCenter
      Anchors = [akTop, akRight]
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
    end
    object LEDLampaLabel: TLabel
      Left = 16
      Top = 376
      Width = 377
      Height = 13
      Alignment = taCenter
      Anchors = [akLeft, akRight, akBottom]
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object LEDLampaShape00: TShape
      Left = 188
      Top = 25
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape01: TShape
      Left = 188
      Top = 57
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape02: TShape
      Left = 188
      Top = 89
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape03: TShape
      Left = 188
      Top = 121
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape04: TShape
      Left = 188
      Top = 153
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape05: TShape
      Left = 215
      Top = 41
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape06: TShape
      Left = 215
      Top = 73
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape07: TShape
      Left = 215
      Top = 105
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape08: TShape
      Left = 215
      Top = 137
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape09: TShape
      Left = 159
      Top = 41
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape10: TShape
      Left = 159
      Top = 73
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape11: TShape
      Left = 159
      Top = 105
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape12: TShape
      Left = 159
      Top = 137
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape13: TShape
      Left = 242
      Top = 57
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape14: TShape
      Left = 242
      Top = 89
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape15: TShape
      Left = 242
      Top = 121
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape16: TShape
      Left = 132
      Top = 57
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape17: TShape
      Left = 132
      Top = 89
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaShape18: TShape
      Left = 132
      Top = 121
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDLampaRLabel: TLabel
      Left = 16
      Top = 224
      Width = 377
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object LEDLampaGLabel: TLabel
      Left = 16
      Top = 272
      Width = 377
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object LEDLampaBLabel: TLabel
      Left = 16
      Top = 320
      Width = 377
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object LEDLampaKilepButton: TButton
      Left = 170
      Top = 416
      Width = 69
      Height = 25
      Hint = 'Kil�p�s a LED l�mpa �rt�kek be�ll�t�s�b�l'
      Anchors = [akLeft, akBottom]
      Caption = '&Kil�p'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = KilepClick
    end
    object LEDLampaRTrackBar: TTrackBar
      Left = 4
      Top = 240
      Width = 401
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      Max = 255
      Orientation = trHorizontal
      Frequency = 1
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 1
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = LEDLampaTrackBarChange
    end
    object LEDLampaGTrackBar: TTrackBar
      Left = 4
      Top = 288
      Width = 401
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      Max = 255
      Orientation = trHorizontal
      Frequency = 1
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 2
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = LEDLampaTrackBarChange
    end
    object LEDLampaBTrackBar: TTrackBar
      Left = 4
      Top = 336
      Width = 401
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      Max = 255
      Orientation = trHorizontal
      Frequency = 1
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 3
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = LEDLampaTrackBarChange
    end
    object SzinaranyLEDCheckBox: TCheckBox
      Left = 132
      Top = 200
      Width = 145
      Height = 17
      Hint = 
        'A sz�nar�nyok meg�rz�s�hez haszn�ljuk ezt az elemet.'#13#10'Ha bejel�l' +
        'j�k, akkor az aktu�lis sz�nar�nyok meg�rz�sre'#13#10'ker�lnek a sz�n�s' +
        'szetev�k v�ltoztat�sakor.'
      Caption = 'A sz�nar�nyok meg�rz�se'
      TabOrder = 4
      OnClick = SzinaranyLEDCheckBoxClick
    end
  end
  object LEDNyilGroupBox: TGroupBox
    Left = 8
    Top = 0
    Width = 409
    Height = 457
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 4
    Visible = False
    object LEDNyilLabel: TLabel
      Left = 16
      Top = 376
      Width = 377
      Height = 13
      Alignment = taCenter
      Anchors = [akLeft, akRight, akBottom]
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object LEDNyilShape06: TShape
      Left = 205
      Top = 73
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape23: TShape
      Left = 205
      Top = 105
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilRLabel: TLabel
      Left = 16
      Top = 224
      Width = 377
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object LEDNyilGLabel: TLabel
      Left = 16
      Top = 272
      Width = 377
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object LEDNyilBLabel: TLabel
      Left = 16
      Top = 320
      Width = 377
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object LEDNyilShape07: TShape
      Left = 238
      Top = 73
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape22: TShape
      Left = 238
      Top = 105
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape08: TShape
      Left = 271
      Top = 73
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape21: TShape
      Left = 271
      Top = 105
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape11: TShape
      Left = 304
      Top = 73
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape15: TShape
      Left = 304
      Top = 105
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape24: TShape
      Left = 172
      Top = 105
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape05: TShape
      Left = 172
      Top = 73
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape04: TShape
      Left = 139
      Top = 73
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape25: TShape
      Left = 139
      Top = 105
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape16: TShape
      Left = 106
      Top = 105
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape03: TShape
      Left = 106
      Top = 73
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape02: TShape
      Left = 73
      Top = 73
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape19: TShape
      Left = 73
      Top = 105
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape12: TShape
      Left = 331
      Top = 89
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape20: TShape
      Left = 46
      Top = 89
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape18: TShape
      Left = 90
      Top = 132
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape13: TShape
      Left = 288
      Top = 132
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape10: TShape
      Left = 288
      Top = 46
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape01: TShape
      Left = 90
      Top = 46
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape09: TShape
      Left = 265
      Top = 23
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape14: TShape
      Left = 265
      Top = 156
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape17: TShape
      Left = 113
      Top = 156
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilShape00: TShape
      Left = 113
      Top = 23
      Width = 33
      Height = 33
      Cursor = crHandPoint
      Shape = stCircle
    end
    object LEDNyilKilepButton: TButton
      Left = 170
      Top = 416
      Width = 69
      Height = 25
      Hint = 'Kil�p�s a LED l�mpa �rt�kek be�ll�t�s�b�l'
      Anchors = [akLeft, akBottom]
      Caption = '&Kil�p'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = KilepClick
    end
    object LEDNyilRTrackBar: TTrackBar
      Left = 4
      Top = 240
      Width = 401
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      Max = 255
      Orientation = trHorizontal
      Frequency = 1
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 1
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = LEDNyilTrackBarChange
    end
    object LEDNyilGTrackBar: TTrackBar
      Left = 4
      Top = 288
      Width = 401
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      Max = 255
      Orientation = trHorizontal
      Frequency = 1
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 2
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = LEDNyilTrackBarChange
    end
    object LEDNyilBTrackBar: TTrackBar
      Left = 4
      Top = 336
      Width = 401
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      Max = 255
      Orientation = trHorizontal
      Frequency = 1
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 3
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = LEDNyilTrackBarChange
    end
    object BalraRadioButton: TRadioButton
      Left = 16
      Top = 176
      Width = 81
      Height = 17
      Hint = 'A nyil ir�ny�nak balra mutat�sa'
      Caption = 'Balra mutat'
      TabOrder = 4
      OnClick = LEDNyilTrackBarChange
    end
    object JobbraRadioButton: TRadioButton
      Left = 312
      Top = 176
      Width = 81
      Height = 17
      Hint = 'A nyil ir�ny�nak jobbra mutat�sa'
      Caption = 'Jobbra mutat'
      TabOrder = 5
      OnClick = LEDNyilTrackBarChange
    end
    object SzinaranyNyilCheckBox: TCheckBox
      Left = 132
      Top = 200
      Width = 145
      Height = 17
      Hint = 
        'A sz�nar�nyok meg�rz�s�hez haszn�ljuk ezt az elemet.'#13#10'Ha bejel�l' +
        'j�k, akkor az aktu�lis sz�nar�nyok meg�rz�sre'#13#10'ker�lnek a sz�n�s' +
        'szetev�k v�ltoztat�sakor.'
      Caption = 'A sz�nar�nyok meg�rz�se'
      TabOrder = 6
      OnClick = SzinaranyNyilCheckBoxClick
    end
  end
  object HangszoroGroupBox: TGroupBox
    Left = 8
    Top = 0
    Width = 559
    Height = 415
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 6
    Visible = False
    object HangmagassagLabel: TLabel
      Left = 350
      Top = 32
      Width = 195
      Height = 17
      Cursor = crHandPoint
      Hint = 'A hangmagass�g be�ll�t�sa'
      Alignment = taCenter
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Hangmagass�g'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
    end
    object HangszoroLabel: TLabel
      Left = 16
      Top = 334
      Width = 527
      Height = 13
      Alignment = taCenter
      Anchors = [akLeft, akRight, akBottom]
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object HangeroLabel: TLabel
      Left = 350
      Top = 212
      Width = 195
      Height = 13
      Hint = 'Az adott hang a be�ll�tott hanger�vel ker�l lej�tsz�sra'
      Alignment = taCenter
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Hanger�'
    end
    object HanglistaLabel: TLabel
      Left = 16
      Top = 16
      Width = 289
      Height = 13
      Hint = 
        'A hanglista elemeinek be�ll�t�sa, szerkeszt�se'#13#10't�rt�nhet ebben ' +
        'a list�ban. Jobb eg�rgombbal'#13#10'lehet kiseg�t� m�veleteket k�rni.'
      Alignment = taCenter
      AutoSize = False
      Caption = 'Hanglista'
    end
    object HanghosszLabel: TLabel
      Left = 350
      Top = 111
      Width = 195
      Height = 17
      Cursor = crHandPoint
      Hint = 
        'A hanghosszat lehet itt be�ll�tani.'#13#10'A felaj�nlott �rt�keket "k�' +
        'zzel" fel�l'#13#10'lehet �rni.'
      Alignment = taCenter
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Hanghossz (msec.)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
    end
    object HangszoroKilepButton: TButton
      Left = 245
      Top = 374
      Width = 69
      Height = 25
      Hint = 'Kil�p�s a hangszerkeszt�b�l'
      Anchors = [akLeft, akBottom]
      Caption = '&Kil�p'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = KilepClick
    end
    object HangeroTrackBar: TTrackBar
      Left = 350
      Top = 232
      Width = 195
      Height = 25
      Hint = 'Az adott hang a be�ll�tott hanger�vel ker�l lej�tsz�sra'
      Anchors = [akLeft, akTop, akRight]
      Max = 63
      Orientation = trHorizontal
      Frequency = 1
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 1
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = HangeroTrackBarChange
    end
    object HangListBox: TListBox
      Left = 16
      Top = 40
      Width = 319
      Height = 231
      Hint = 'A lej�tszang� hanglista elemei'
      Anchors = [akLeft, akTop, akBottom]
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ItemHeight = 14
      ParentFont = False
      PopupMenu = HangPopupMenu
      TabOrder = 2
      OnClick = HangListBoxClick
    end
    object LejatszasButton: TButton
      Left = 225
      Top = 286
      Width = 109
      Height = 25
      Hint = 'A megszerkesztett hanglista lej�tsz�s�nak elind�t�sa'
      Anchors = [akLeft, akBottom]
      Caption = '&Elk�ld�s lej�tsz�sra'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = LejatszasButtonClick
    end
    object HangmagassagComboBox: TComboBox
      Left = 350
      Top = 56
      Width = 195
      Height = 22
      Hint = 'A hangmagass�g be�ll�t�sa'
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ItemHeight = 14
      ParentFont = False
      TabOrder = 4
      OnChange = HangmagassagComboBoxChange
      Items.Strings = (
        'C'#39#39#39#39'   4186.0090 Hz'
        'H'#39#39#39'    3951.0664 Hz'
        'B'#39#39#39'    3729.3101 Hz'
        'A'#39#39#39'    3520.0000 Hz'
        'GISZ'#39#39#39' 3322.4376 Hz'
        'G'#39#39#39'    3135.9635 Hz'
        'FISZ'#39#39#39' 2959.9554 Hz'
        'F'#39#39#39'    2793.8259 Hz'
        'E'#39#39#39'    2637.0205 Hz'
        'DISZ'#39#39#39' 2489.0159 Hz'
        'D'#39#39#39'    2349.3181 Hz'
        'CISZ'#39#39#39' 2217.4610 Hz'
        'C'#39#39#39'    2093.0045 Hz'
        'H'#39#39'     1975.5332 Hz'
        'B'#39#39'     1864.6550 Hz'
        'A'#39#39'     1760.0000 Hz'
        'GISZ'#39#39'  1661.2188 Hz'
        'G'#39#39'     1567.9817 Hz'
        'FISZ'#39#39'  1479.9777 Hz'
        'F'#39#39'     1396.9129 Hz'
        'E'#39#39'     1318.5102 Hz'
        'DISZ'#39#39'  1244.5079 Hz'
        'D'#39#39'     1174.6591 Hz'
        'CISZ'#39#39'  1108.7305 Hz'
        'C'#39#39'  '#9'  1046.5023 Hz'
        'H'#39'       987.7666 Hz'
        'B'#39'       932.3275 Hz'
        'A'#39'       880.0000 Hz'
        'GISZ'#39'    830.6094 Hz'
        'G'#39'       783.9909 Hz'
        'FISZ'#39'    739.9888 Hz'
        'F'#39'       698.4565 Hz'
        'E'#39'       659.2551 Hz'
        'DISZ'#39'    622.2540 Hz'
        'D'#39' '#9'     587.3295 Hz'
        'CISZ'#39' '#9' 554.3653 Hz'
        'C'#39'       523.2511 Hz'
        'H     '#9' 493.8833 Hz'
        'B        466.1638 Hz'
        'A        440.0000 Hz'
        'GISZ     415.3047 Hz'
        'G '#9'     391.9954 Hz'
        'FISZ     369.9944 Hz'
        'F        349.2282 Hz'
        'E        329.6276 Hz'
        'DISZ     311.1270 Hz'
        'D        293.6648 Hz'
        'CISZ     277.1826 Hz'
        'C        261.6256 Hz'
        'Sz�net              ')
    end
    object HanghosszComboBox: TComboBox
      Left = 350
      Top = 135
      Width = 195
      Height = 21
      Hint = 
        'A hanghosszat lehet itt be�ll�tani.'#13#10'A felaj�nlott �rt�keket "k�' +
        'zzel" fel�l'#13#10'lehet �rni.'
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 5
      OnChange = HangmagassagComboBoxChange
      Items.Strings = (
        ' 100'
        ' 200'
        ' 300'
        ' 400'
        ' 500'
        ' 600'
        ' 700'
        ' 800'
        ' 900'
        '1000')
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 533
    Width = 628
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object Button1: TButton
    Left = 16
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 7
    OnClick = Button1Click
  end
  object MainMenu: TMainMenu
    Left = 8
    Top = 496
    object FileMenu: TMenuItem
      Caption = '&F�jl'
      object Ujrafelmeres: TMenuItem
        Caption = 'A felm�r�s �jra&ind�t�sa'
        ShortCut = 117
        OnClick = UjrafelmeresClick
      end
      object ExitMenuElem: TMenuItem
        Caption = '&Kil�p�s'
        ShortCut = 32856
        OnClick = ExitMenuElemClick
      end
    end
    object Teendok: TMenuItem
      Caption = '&Teend�k'
      Enabled = False
      object AzonositoBeallitasa: TMenuItem
        Caption = '&Azonos�t� be�ll�t�sa '
        ShortCut = 113
        OnClick = MenuinditClick
      end
      object LEDLampaKijelzo: TMenuItem
        Tag = 16384
        Caption = 'LED &l�mpa kijelz� param�terek'
        ShortCut = 114
        OnClick = MenuinditClick
      end
      object LEDNyilKijelzo: TMenuItem
        Tag = 32768
        Caption = 'LED &ny�l kijelz� param�terek'
        ShortCut = 115
        OnClick = MenuinditClick
      end
      object HangszoroPanelKezeles: TMenuItem
        Tag = 49152
        Caption = '&Hangsz�r� panel kezel�s'
        ShortCut = 116
        OnClick = MenuinditClick
      end
      object Programfrissites: TMenuItem
        Caption = '&Program friss�t�s'
        ShortCut = 119
        OnClick = MenuinditClick
      end
    end
  end
  object Timer: TTimer
    Interval = 100
    OnTimer = TimerTimer
    Left = 40
    Top = 496
  end
  object FirmwareUpdateDialog: TOpenDialog
    DefaultExt = 'BIN'
    Filter = 'BIN f�jlok (*.BIN)|*.BIN|Minden f�jl (*.*)|*.*'
    Left = 72
    Top = 496
  end
  object HangPopupMenu: TPopupMenu
    OnPopup = HangPopupMenuPopup
    Left = 104
    Top = 496
    object Torles: TMenuItem
      Caption = 'T�rl�s'
      OnClick = TorlesClick
    end
    object Folfele: TMenuItem
      Caption = 'F�lfele'
      OnClick = FolfeleClick
    end
    object Lefele: TMenuItem
      Caption = 'Lefele'
      OnClick = LefeleClick
    end
    object Ujhang: TMenuItem
      Caption = '�j hang'
      OnClick = UjhangClick
    end
  end
end
