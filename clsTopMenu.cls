VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsTopMenu"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
'�˵�����
Private m_MenuID As Long                '�˵���ID
Private m_Caption As String             '�˵������
Private m_width As Integer              '�˵������
Private m_height As Integer             '�˵���߶�
Private m_Picture As PictureBox         '�˵���ͼ��
Private m_Enabled As Boolean            '�˵����Ƿ����
Private m_Selected As Boolean           '�˵����Ƿ�ѡ
Private m_DrawStruct As DRAWITEMSTRUCT  '�˵���Ļ�ͼ��Ϣ

Private Const PS_SOLID = 0
Private Const TRANSPARENT = 1
Private Const DSS_DISABLED = &H20
Private Const DST_TEXT = &H1
Private Const ODS_SELECTED = &H1

Private Type RECT
        Left As Long
        Top As Long
        Right As Long
        Bottom As Long
End Type



Private Type DRAWITEMSTRUCT
     CtlType As Long     '�ؼ�����
     CtlID As Long       '�ؼ�id
     itemID As Long      '�˵���.�б������Ͽ���ĳһ�������ֵ
     itemAction As Long  '�ؼ���Ϊ
     itemState As Long   '�ؼ�״̬
     hwndItem As Long    '�����ھ����˵����
     hDC As Long         '�ؼ���Ӧ�Ļ�ͼ�豸���
     rcItem As RECT      '�ؼ���ռ�ݵľ�������
     ItemData As Long    '�б������Ͽ���ĳһ���ֵ
End Type

Private Declare Function ModifyMenu Lib "user32" Alias "ModifyMenuA" (ByVal hMenu As Long, ByVal nPosition As Long, ByVal wFlags As Long, ByVal wIDNewItem As Long, ByVal lpString As Any) As Long
Private Declare Function CreateSolidBrush Lib "gdi32" (ByVal crColor As Long) As Long
Private Declare Function FillRect Lib "user32" (ByVal hDC As Long, lpRect As RECT, ByVal hBrush As Long) As Long
Private Declare Function CreatePen Lib "gdi32" (ByVal nPenStyle As Long, ByVal nWidth As Long, ByVal crColor As Long) As Long
Private Declare Function SelectObject Lib "gdi32" (ByVal hDC As Long, ByVal hObject As Long) As Long
Private Declare Function MoveToEx Lib "gdi32" (ByVal hDC As Long, ByVal X As Long, ByVal Y As Long, ByVal lpPoint As Long) As Long
Private Declare Function LineTo Lib "gdi32" (ByVal hDC As Long, ByVal X As Long, ByVal Y As Long) As Long
Private Declare Function SetBkMode Lib "gdi32" (ByVal hDC As Long, ByVal nBkMode As Long) As Long
Private Declare Function SetTextColor Lib "gdi32" (ByVal hDC As Long, ByVal crColor As Long) As Long
Private Declare Function DrawState Lib "user32" Alias "DrawStateA" (ByVal hDC As Long, ByVal hBrush As Long, ByVal lpDrawStateProc As Long, ByVal lParam As String, ByVal wParam As Long, ByVal n1 As Long, ByVal n2 As Long, ByVal n3 As Long, ByVal n4 As Long, ByVal un As Long) As Long
Private Declare Function TextOut Lib "gdi32" Alias "TextOutA" (ByVal hDC As Long, ByVal X As Long, ByVal Y As Long, ByVal lpString As String, ByVal nCount As Long) As Long
Private Declare Function FrameRect Lib "user32" (ByVal hDC As Long, lpRect As RECT, ByVal hBrush As Long) As Long
Private Declare Function StretchBlt Lib "gdi32" (ByVal hDC As Long, ByVal X As Long, ByVal Y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal nSrcWidth As Long, ByVal nSrcHeight As Long, ByVal dwRop As Long) As Long
Private Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long


Public Property Get MenuID() As Long
  MenuID = m_MenuID
End Property

Public Property Get Caption() As String
  Caption = m_Caption
End Property

Public Property Get Width() As Integer
  Width = m_width
End Property

Public Property Get Height() As Integer
  Height = m_height
End Property

Public Property Get Enabled() As Boolean
  Enabled = m_Enabled
End Property

Public Property Let Enabled(ByVal flag As Boolean)
  m_Enabled = flag
End Property

Public Property Get Selected() As Boolean
  Selected = m_Selected
End Property

Public Property Let Selected(ByVal flag As Boolean)
  m_Selected = flag
End Property

'��ʼ���˵��������Ϣ
Public Sub InitMenu(ByVal nMenuID As Long, ByVal sCaption As String, ByVal nWidth As Integer, ByVal nHeight As Integer, ByVal obj As PictureBox)
  m_MenuID = nMenuID
  m_Caption = sCaption
  m_width = nWidth
  m_height = nHeight
  Set m_Picture = obj
End Sub

'��ʼ���˵��ͼ��Ϣ
Public Sub InitStruct(ByVal hDC As Long, ByVal nAction As Long, ByVal nID As Long, ByVal nState As Long, ByVal nLeft As Long, ByVal nTop As Long, ByVal nBottom As Long, ByVal nRight As Long)
  m_DrawStruct.hDC = hDC
  m_DrawStruct.itemAction = nAction
  m_DrawStruct.itemID = nID
  m_DrawStruct.itemState = nState
  m_DrawStruct.rcItem.Left = nLeft
  m_DrawStruct.rcItem.Top = nTop
  m_DrawStruct.rcItem.Bottom = nBottom
  m_DrawStruct.rcItem.Right = nRight
End Sub

Private Sub SetMenuText(ByVal hDC As Long, ByVal clr As Long, Rc As RECT, ByVal PosX As Long)
  Dim OldColor As Long
  SetBkMode hDC, TRANSPARENT
  OldColor = SetTextColor(hDC, clr)
  If Not (m_Enabled) Then
    DrawState hDC, 0, 0, m_Caption, LenB(StrConv(m_Caption, vbFromUnicode)), _
                PosX, Rc.Top + 2, 0, 0, DSS_DISABLED Or DST_TEXT
  Else
    TextOut hDC, PosX, Rc.Top + 2, m_Caption, LenB(StrConv(m_Caption, vbFromUnicode))
  End If
  SetTextColor hDC, OldColor
End Sub

Public Sub DrawMenu()
  Dim DrawInfo As DRAWITEMSTRUCT
  Dim drawRect As RECT, Rc As RECT
  Dim IsSelected As Boolean, IsPicture As Boolean
  Dim OldColor As Long, TMP As Long
  Dim hPen As Long, hOldPen As Long
  
  DrawInfo = m_DrawStruct
  IsSelected = (DrawInfo.itemState And ODS_SELECTED)        '�Ƿ�ѡ�в˵���
  IsPicture = Not (m_Picture Is Nothing)                    '�Ƿ��ͼ��
  drawRect = DrawInfo.rcItem
  
  If IsSelected Then
  
    If m_Caption <> "" Then    '������Ƿָ���
    
      FillRect DrawInfo.hDC, drawRect, CreateSolidBrush(g_clrBkgSelect)
      FrameRect DrawInfo.hDC, drawRect, CreateSolidBrush(g_clrFrame)
      
      If m_Selected Then
        StretchBlt DrawInfo.hDC, 3, drawRect.Top + 1, 16, 16, Frmm.Pic(0).hDC, 0, 0, Frmm.Pic(0).ScaleWidth, Frmm.Pic(0).ScaleHeight, vbSrcCopy
      ElseIf IsPicture Then
        StretchBlt DrawInfo.hDC, 3, drawRect.Top + 1, 16, 16, m_Picture.hDC, 0, 0, m_Picture.ScaleWidth, m_Picture.ScaleHeight, vbSrcCopy
      End If
      
      '���ò˵��ı���ɫ������״̬�����˵��ı�
      SetMenuText DrawInfo.hDC, g_clrTxtSelect, drawRect, 30
      
    End If
    
  Else
    
    Rc = drawRect
    TMP = Rc.Right   '����벿��(��������Ǹ�����,������ʾͼ��)
    Rc.Right = 24
    FillRect DrawInfo.hDC, Rc, CreateSolidBrush(g_clrLeft)
    
    Rc.Left = 24     '���Ұ벿��(������ʾ����)
    Rc.Right = TMP
    FillRect DrawInfo.hDC, Rc, CreateSolidBrush(g_clrBkgNormal)
    
    If m_Caption = "" Then   '����Ƿָ���
    
      hPen = CreatePen(PS_SOLID, 1, g_clrSep)
      hOldPen = SelectObject(DrawInfo.hDC, hPen)
      MoveToEx DrawInfo.hDC, Rc.Left, Rc.Top + 2, 0
      LineTo DrawInfo.hDC, Rc.Right, Rc.Top + 2
      SelectObject DrawInfo.hDC, hOldPen
      DeleteObject hPen
      
    Else
    
      If m_Selected Then
        StretchBlt DrawInfo.hDC, 4, drawRect.Top + 2, 16, 16, Frmm.Pic(0).hDC, 0, 0, Frmm.Pic(0).ScaleWidth, Frmm.Pic(0).ScaleHeight, vbSrcCopy
      ElseIf IsPicture Then
        StretchBlt DrawInfo.hDC, 4, drawRect.Top + 2, 16, 16, m_Picture.hDC, 0, 0, m_Picture.ScaleWidth, m_Picture.ScaleHeight, vbSrcCopy
      End If
      
      '���ò˵��ı���ɫ������״̬�����˵��ı�
      SetMenuText DrawInfo.hDC, g_clrTxtNormal, drawRect, 30
      
    End If
    
  End If
  
End Sub

Private Sub Class_Initialize()
  m_Enabled = True
End Sub



