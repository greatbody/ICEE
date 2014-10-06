VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDate"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Private Type SolarHolidayStruct
    Month As Long
    Day As Long
    Recess As Long
    HolidayName As String
End Type

Private Type LunarHolidayStruct
    Month As Long
    Day As Long
    Recess As Long
    HolidayName As String
End Type

Private Type WeekHolidayStruct
    Month As Long
    WeekAtMonth As Long
    WeekDay As Long
    HolidayName As String
End Type

'��������ֵ�ľֲ�����
Private mvarsYear As Long                                                       '�ֲ�����
Private mvarsMonth As Long                                                      '�ֲ�����
Private mvarsDay As Long                                                        '�ֲ�����
Private mvarlYear As Long                                                       '�ֲ�����
Private mvarlMonth As Long                                                      '�ֲ�����
Private mvarlDay As Long                                                        '�ֲ�����
Private mvarIsLeap As Boolean                                                   '�ֲ�����

'Private Declare Function BitRight32 Lib "Bit4VB.DLL" (ByVal x As Long, ByVal num As Long) As Long
'�˶����Ѳ�ʹ��
'�������ڲ��ù��ñ���

Private SolarMonth As Variant
Private Gan As Variant
Private Zhi As Variant
Private Animals As Variant
Private SolarTerm As Variant
Private sTermInfo As Variant
Private nStr1 As Variant
Private nStr2 As Variant
Private MonthName As Variant
Private LunarInfo(150) As Long
Private LunarYearDays(150) As Long
Private sHolidayInfo() As SolarHolidayStruct
Private lHolidayInfo() As LunarHolidayStruct
Private wHolidayInfo() As WeekHolidayStruct

Private mvarDate As Date                                                        '�ڲ�ʹ�ñ�׼�����ڱ���

Private BitPower(31) As Long                                                    '0-31

'λ���� ,����λΪ1 ������
Private Function mvarBitTest32(Number As Long, Bit As Long) As Boolean
    If Bit < 0 Or Bit > 31 Then '��������λ
        mvarBitTest32 = False
    Else
        If Number And BitPower(Bit) Then
          mvarBitTest32 = True
        Else
          mvarBitTest32 = False
        End If
    End If
End Function

Private Sub Class_Initialize()
   Dim tempArray As Variant
   Dim i As Long
   Dim b As Long
   Dim sFtv As Variant
   Dim lFtv As Variant
   Dim wFtv As Variant
   
    
   '����VB��λ�����ص�,������ԭ�е�����λ,������32λ
   tempArray = Array( _
        &H104BD8, &H104AE0, &H10A570, &H1054D5, &H10D260, &H10D950, &H116554, &H1056A0, &H109AD0, &H1055D2, _
        &H104AE0, &H10A5B6, &H10A4D0, &H10D250, &H11D255, &H10B540, &H10D6A0, &H10ADA2, &H1095B0, &H114977, _
        &H104970, &H10A4B0, &H10B4B5, &H106A50, &H106D40, &H11AB54, &H102B60, &H109570, &H1052F2, &H104970, _
        &H106566, &H10D4A0, &H10EA50, &H106E95, &H105AD0, &H102B60, &H1186E3, &H1092E0, &H11C8D7, &H10C950, _
        &H10D4A0, &H11D8A6, &H10B550, &H1056A0, &H11A5B4, &H1025D0, &H1092D0, &H10D2B2, &H10A950, &H10B557, _
        &H106CA0, &H10B550, &H115355, &H104DA0, &H10A5D0, &H114573, &H1052D0, &H10A9A8, &H10E950, &H106AA0, _
        &H10AEA6, &H10AB50, &H104B60, &H10AAE4, &H10A570, &H105260, &H10F263, &H10D950, &H105B57, &H1056A0, _
        &H1096D0, &H104DD5, &H104AD0, &H10A4D0, &H10D4D4, &H10D250, &H10D558, &H10B540, &H10B5A0, &H1195A6, _
        &H1095B0, &H1049B0, &H10A974, &H10A4B0, &H10B27A, &H106A50, &H106D40, &H10AF46, &H10AB60, &H109570, _
        &H104AF5, &H104970, &H1064B0, &H1074A3, &H10EA50, &H106B58, &H1055C0, &H10AB60, &H1096D5, &H1092E0, _
        &H10C960, &H10D954, &H10D4A0, &H10DA50, &H107552, &H1056A0, &H10ABB7, &H1025D0, &H1092D0, &H10CAB5, _
        &H10A950, &H10B4A0, &H10BAA4, &H10AD50, &H1055D9, &H104BA0, &H10A5B0, &H115176, &H1052B0, &H10A930, _
        &H107954, &H106AA0, &H10AD50, &H105B52, &H104B60, &H10A6E6, &H10A4E0, &H10D260, &H10EA65, &H10D530, _
        &H105AA0, &H1076A3, &H1096D0, &H104BD7, &H104AD0, &H10A4D0, &H11D0B6, &H10D250, &H10D520, &H10DD45, _
        &H10B5A0, &H1056D0, &H1055B2, &H1049B0, &H10A577, &H10A4B0, &H10AA50, &H11B255, &H106D20, &H10ADA0)
   For i = 0 To 149
     LunarInfo(i) = tempArray(i)
   Next
   
   tempArray = Array( _
                384, 354, 355, 383, 354, 355, 384, 354, 355, 384, _
                354, 384, 354, 354, 384, 354, 355, 384, 355, 384, _
                354, 354, 384, 354, 354, 385, 354, 355, 384, 354, _
                383, 354, 355, 384, 355, 354, 384, 354, 384, 354, _
                354, 384, 355, 354, 385, 354, 354, 384, 354, 384, _
                354, 355, 384, 354, 355, 384, 354, 383, 355, 354, _
                384, 355, 354, 384, 355, 353, 384, 355, 384, 354, _
                355, 384, 354, 354, 384, 354, 384, 354, 355, 384, _
                355, 354, 384, 354, 384, 354, 354, 384, 355, 355, _
                384, 354, 354, 383, 355, 384, 354, 355, 384, 354, _
                354, 384, 354, 355, 384, 354, 385, 354, 354, 384, _
                354, 354, 384, 355, 384, 354, 355, 384, 354, 354, _
                384, 354, 355, 384, 354, 384, 354, 354, 384, 355, _
                354, 384, 355, 384, 354, 354, 384, 354, 354, 384, _
                355, 355, 384, 354, 384, 354, 354, 384, 354, 355)
   
   For i = 0 To 149
     LunarYearDays(i) = tempArray(i)
   Next
   
   SolarMonth = Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
   Gan = Array("��", "��", "��", "��", "��", "��", "��", "��", "��", "��")
   Zhi = Array("��", "��", "��", "î", "��", "��", "��", "δ", "��", "��", "��", "��")
   Animals = Array("��", "ţ", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��")
   SolarTerm = Array("С��", "��", "����", "��ˮ", "����", "����", "����", "����", "����", "С��", "â��", "����", "С��", "����", "����", "����", "��¶", "���", "��¶", "˪��", "����", "Сѩ", "��ѩ", "����")
   sTermInfo = Array(0, 21208, 42467, 63836, 85337, 107014, 128867, 150921, 173149, 195551, 218072, 240693, 263343, 285989, 308563, 331033, 353350, 375494, 397447, 419210, 440795, 462224, 483532, 504758)
   nStr1 = Array("��", "һ", "��", "��", "��", "��", "��", "��", "��", "��", "ʮ")
   nStr2 = Array("��", "ʮ", "إ", "ئ", "��")
   MonthName = Array("JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC")
   
   '�������� *��ʾ�ż���
   sFtv = Array( _
        1, 1, 1, "Ԫ��", _
        2, 2, 0, "����ʪ����", 2, 14, 0, "���˽�", 2, 10, 0, "���������", _
        3, 1, 0, "���ʺ�����", 3, 5, 0, "ѧ�׷������", 3, 8, 0, "��Ů��", 3, 12, 0, "ֲ���� ����ɽ����������", 3, 14, 0, "���ʾ�����", 3, 15, 0, "������Ȩ����", 3, 17, 0, "�й���ҽ�� ���ʺ�����", 3, 21, 0, "����ɭ���� �����������ӹ����� ���������", 3, 22, 0, "����ˮ��", 3, 24, 0, "������ν�˲���", _
        4, 1, 0, "���˽�", 4, 28, 0, "08'������·����ײ", 4, 7, 0, "����������", 4, 22, 0, "���������", _
        5, 1, 1, "�Ͷ���", 5, 4, 0, "�����", 5, 12, 0, "08'�봨���� ��ʿ��", 5, 31, 0, "����������", 5, 8, 0, "�����ʮ����", 5, 12, 0, "���ʻ�ʿ��", _
        6, 1, 0, "��ͯ��", 6, 5, 0, "���绷��������", 6, 26, 0, "���ʽ�����", _
        7, 1, 0, "������ ��ۻع���� ���罨����", 7, 11, 0, "�����˿���", _
        8, 1, 0, "������", 8, 8, 0, "�й����ӽ� ���׽�", 8, 15, 0, "����ս��ʤ������", _
        9, 9, 0, "ë����������", 9, 10, 0, "��ʦ��", 9, 18, 0, "�š�һ���±������", 9, 28, 0, "���ӵ���", 9, 20, 0, "���ʰ�����", 9, 27, 0, "����������", _
        10, 1, 0, "����� ����������", 10, 2, 1, "����ڼ���", 10, 3, 1, "����ڼ���", 10, 6, 0, "���˽�", 10, 24, 0, "���Ϲ���", _
        11, 12, 0, "����ɽ��������", 11, 3, 0, "", 11, 1, 0, "�������ε�Ӱ��", 11, 8, 0, "�й�������", 11, 10, 0, "����������", 11, 14, 0, "����������", 11, 17, 0, "����ѧ����", _
        12, 1, 0, "���簬�̲���", 12, 3, 0, "����м�����", 12, 20, 0, "���Żع����", 12, 24, 0, "ƽ��ҹ", 12, 25, 0, "ʥ����", 12, 26, 0, "ë�󶫵�������", 12, 9, 0, "����������", 12, 10, 0, "������Ȩ��", 12, 13, 0, "�Ͼ�����ɱ������", _
        9, 3, 0, "����ս��ʤ����", 9, 17, 0, "���ʺ�ƽ��", 9, 20, 0, "ȫ��������", 10, 8, 0, "ȫ����Ѫѹ��", 10, 15, 0, "����ä�˽�(��������)", 10, 16, 0, "������ʳ��", 10, 31, 0, "��ʥ��")
        
   b = UBound(sFtv) + 1
   ReDim sHolidayInfo(b / 4)
   For i = 0 To (b / 4) - 1
       sHolidayInfo(i).Month = sFtv(i * 4)
       sHolidayInfo(i).Day = sFtv(i * 4 + 1)
       sHolidayInfo(i).Recess = sFtv(i * 4 + 2)
       sHolidayInfo(i).HolidayName = sFtv(i * 4 + 3)
   Next
   
   'ũ������ *��ʾ�ż���
   lFtv = Array( _
        1, 1, 1, "����", _
        1, 15, 0, "Ԫ����", _
        5, 5, 1, "�����", _
        7, 7, 0, "��Ϧ���˽�", _
        7, 15, 0, "��Ԫ�� �������", _
        8, 15, 1, "�����", _
        9, 9, 0, "������", _
        12, 8, 0, "���˽�", _
        12, 24, 0, "С��")
        '12, 31, 0, "��Ϧ")  'ע���Ϧ��Ҫ�����������м���
   
   b = UBound(lFtv) + 1
   ReDim lHolidayInfo(b / 4)
   For i = 0 To (b / 4) - 1
       lHolidayInfo(i).Month = lFtv(i * 4)
       lHolidayInfo(i).Day = lFtv(i * 4 + 1)
       lHolidayInfo(i).Recess = lFtv(i * 4 + 2)
       lHolidayInfo(i).HolidayName = lFtv(i * 4 + 3)
   Next
   
   'ĳ�µĵڼ������ڼ�
   wFtv = Array( _
       5, 2, 1, "����ĸ�׽�", _
       5, 3, 1, "ȫ��������", _
       6, 3, 1, "���׽�", _
       9, 3, 3, "���ʺ�ƽ��", _
       9, 4, 1, "�������˽�", _
       10, 1, 2, "����ס����", _
       10, 1, 4, "���ʼ�����Ȼ�ֺ���", _
       11, 4, 5, "�ж���")
   b = UBound(wFtv) + 1
   ReDim wHolidayInfo(b / 4)
   For i = 0 To (b / 4) - 1
       wHolidayInfo(i).Month = wFtv(i * 4)
       wHolidayInfo(i).WeekAtMonth = wFtv(i * 4 + 1)
       wHolidayInfo(i).WeekDay = wFtv(i * 4 + 2) '1 ����������
       wHolidayInfo(i).HolidayName = wFtv(i * 4 + 3)
   Next


   'λ������ʹ��ģ�麯�� modBit4VB�ж���
   For i = 0 To 30
      BitPower(i) = 2 ^ i
   Next
   BitPower(31) = &H80000000
End Sub

'/////////////////////////////////////////////////////////////////////////////////////////////////////////////

'����ũ���ϵĽ���
Public Property Get lSolarTerm() As String

    '//===== ĳ��ĵ�n������Ϊ����(��0С������)
    'function sTerm(y,n) {
    '   var offDate = new Date( ( 31556925974.7*(y-1900) + sTermInfo[n]*60000  ) + Date.UTC(1900,0,6,2,5) )
    '   return(offDate.getUTCDate())

    '//����
    '   tmp1 = sTerm(y, m * 2) - 1
    
    Dim baseDateAndTime As Date
    Dim newdate As Date
    Dim num As Double
    Dim Y As Long
    Dim TempStr As String
    
    baseDateAndTime = #1/6/1900 2:05:00 AM#
    Y = mvarsYear
    TempStr = ""
    
    Dim i As Long
    For i = 1 To 24
       num = 525948.76 * (Y - 1900) + sTermInfo(i - 1)
       newdate = DateAdd("n", num, baseDateAndTime)  '�����Ӽ���,֮���Բ������Ӽ��㣬����Ϊ�����
       If Abs(DateDiff("d", newdate, mvarDate)) = 0 Then
          TempStr = SolarTerm(i - 1)
          Exit For
       End If
    Next
  
    lSolarTerm = TempStr
End Property
'���㰴�ڼ������ڼ�����Ľ���
Public Property Get wHoliday() As String
    Dim w As Long
    Dim i As Long
    Dim b As Long
    Dim FirstDay As Date
    Dim TempStr As String
    TempStr = ""
    b = UBound(wHolidayInfo)
    For i = 0 To b
      If wHolidayInfo(i).Month = mvarsMonth Then  '���·��൱ʱ
         w = WeekDay(mvarDate)
         If wHolidayInfo(i).WeekDay = w Then  '�������ڼ�Ҳ���ʱ
            FirstDay = mvarsMonth & "/" & 1 & "/" & mvarsYear 'ȡ���µ�һ��
            If (DateDiff("ww", FirstDay, mvarDate) = wHolidayInfo(i).WeekAtMonth) Then
                TempStr = wHolidayInfo(i).HolidayName
            End If
         End If
      End If
    Next
    
    
    wHoliday = TempStr
End Property

Public Property Get lHoliday() As String
    Dim i As Long
    Dim b As Long
    Dim TempStr As String
    Dim oy As Long
    Dim odate As Date
    Dim ndate As Date
    TempStr = ""
    b = UBound(lHolidayInfo)
    If mvarlMonth = 12 And (mvarlDay = 29 Or mvarlDay = 30) Then
       '��
       oy = mvarlYear '����ũ������
       odate = mvarDate
       ndate = mvarDate + 1
       Call sInitDate(Year(ndate), Month(ndate), Day(ndate)) '����ڶ��������
       If oy = mvarlYear - 1 Then '���ũ������������1
          TempStr = "��Ϧ"
          Call sInitDate(Year(odate), Month(odate), Day(odate)) '�ָ�������ԭ������
          
       End If
    Else
        For i = 0 To b
           If (lHolidayInfo(i).Month = mvarlMonth) And _
              (lHolidayInfo(i).Day = mvarlDay) Then
               TempStr = lHolidayInfo(i).HolidayName
               Exit For
           End If
        Next
    End If
    lHoliday = TempStr
End Property
'��������
Public Property Get sHoliday() As String
    Dim i As Long
    Dim b As Long
    Dim TempStr As String
    
    TempStr = ""
    b = UBound(sHolidayInfo)
    For i = 0 To b
       If (sHolidayInfo(i).Month = mvarsMonth) And _
          (sHolidayInfo(i).Day = mvarsDay) Then
           TempStr = sHolidayInfo(i).HolidayName
           Exit For
       End If
    Next
    sHoliday = TempStr
End Property
Public Property Get sHolidayRecess() As Boolean
    Dim i As Long
    Dim b As Long
    Dim TempStr As Boolean
    
    TempStr = False
    b = UBound(sHolidayInfo)
    For i = 0 To b
       If (sHolidayInfo(i).Month = mvarsMonth) And _
          (sHolidayInfo(i).Day = mvarsDay) Then
           TempStr = sHolidayInfo(i).Recess = 1
           Exit For
       End If
    Next
    sHolidayRecess = TempStr
End Property
'�Ƿ���ũ��������

Public Property Get IsLeap() As Boolean
    IsLeap = mvarIsLeap
End Property

Public Property Get lDay() As Long
    lDay = mvarlDay
End Property

Public Property Get lMonth() As Long
    lMonth = mvarlMonth
End Property

Public Property Get lYear() As Long
    lYear = mvarlYear
End Property
Public Property Get sWeekDay() As Long
    sWeekDay = WeekDay(mvarDate)
End Property

'�������ڼ������ִ�
Public Property Get sWeekDayStr() As String
   Select Case WeekDay(mvarDate)
     Case vbSunday
        sWeekDayStr = "������"
     Case vbMonday
        sWeekDayStr = "����һ"
     Case vbTuesday
        sWeekDayStr = "���ڶ�"
     Case vbWednesday
        sWeekDayStr = "������"
     Case vbThursday
        sWeekDayStr = "������"
     Case vbFriday
        sWeekDayStr = "������"
     Case vbSaturday
        sWeekDayStr = "������"
   End Select
End Property

Public Function Constellation2(m As Long, d As Long) As String
   Dim Y As Long
   Dim tempDate As Date
   Dim ConstellName As String
 
   Y = 2000
   tempDate = m & "/" & d & "/" & Y

   Select Case tempDate
      Case #3/21/2000# To #4/19/2000#
            ConstellName = "����.�����������ػ�����:����"
      Case #4/20/2000# To #5/20/2000#
            ConstellName = "����.�����������ػ�����:����"
      Case #5/21/2000# To #6/21/2000#
            ConstellName = "����.�����������ػ�����:ˮ��"
      Case #6/22/2000# To #7/22/2000#
            ConstellName = "����.ˮ�������ػ�����:����"
      Case #7/23/2000# To #8/22/2000#
            ConstellName = "����.�����������ػ�����:̫��"
      Case #8/23/2000# To #9/22/2000#
            ConstellName = "����.�����������ػ�����:ˮ��"
      Case #9/23/2000# To #10/23/2000#
            ConstellName = "����.�����������ػ�����:����"
      Case #10/24/2000# To #11/21/2000#
            ConstellName = "����.ˮ���������ػ�����:ڤ����(��ͳ��Ϊ����)"
      Case #11/22/2000# To #12/21/2000#
            ConstellName = "����.�����������ػ�����:ľ��"
      Case #12/22/2000# To #12/31/2000#
            ConstellName = "����.�����������ػ�����:����"
      Case #1/1/2000# To #1/19/2000#
            ConstellName = "����.�����������ػ�����:����"
      Case #1/20/2000# To #2/18/2000#
            ConstellName = "����.��������,�ػ�����:������(��ͳ��Ϊ����)"
      Case #2/19/2000# To #3/20/2000#
            ConstellName = "����.ˮ���������ػ�����:������"
      Case Else
            ConstellName = ""
   End Select
   Constellation2 = ConstellName
End Function

Public Property Get sDay() As Long
    sDay = mvarsDay
End Property

Public Property Get sMonth() As Long
    sMonth = mvarsMonth
End Property

Public Property Get sYear() As Long
    sYear = mvarsYear
End Property

'////////////////////////////////////////////////////////////////////////////////////////////////////////
Public Function IsToday(Y As Long, m As Long, d As Long) As Boolean
   
    If (Year(Date) = Y) And _
       (Month(Date) = m) And _
       (Day(Date) = d) Then
        IsToday = True
    Else
        IsToday = False
    End If
    
End Function


'������ݲ�ͬ���㵱������ʲô����
Public Function Era(Y As Long) As String
   Dim TempStr As String
   
   If Y < 1874 Then
       TempStr = "δ֪"
   Else
       If Y <= 1908 Then
          TempStr = "�峯����"
          If Y = 1874 Then
            TempStr = TempStr & "Ԫ��"
          Else
            TempStr = TempStr & UpNumber(CStr(Y - 1874)) & "��"
          End If
       Else
          If Y <= 1910 Then
             TempStr = "�峯��ͳ"
             If Y = 1909 Then
                TempStr = TempStr & "Ԫ��"
             Else
                TempStr = TempStr & UpNumber(CStr(Y - 1909 + 1)) & "��"
             End If
          Else
             If Y < 1949 Then
                TempStr = "�л����"
                If Y = 1912 Then
                   TempStr = TempStr & "Ԫ��"
                Else
                   TempStr = TempStr & UpNumber(CStr(Y - 1912 + 1)) & "��"
                End If
             Else
                TempStr = "�л����񹲺͹�����"
                If Y = 1949 Then
                   TempStr = TempStr & "��"
                Else
                   Select Case Y
                      Case 2000
                         TempStr = "ǧ����"
                      Case Else
                         TempStr = TempStr & UpNumber(CStr(Y - 1949)) & "����"
                   End Select
                End If
             End If
          End If
       End If
   End If
   
   Era = TempStr
End Function

' ���� num ���ظ�֧, 0=����
Public Function GanZhi(num As Long) As String
    Dim TempStr As String
    Dim i As Long
    i = (num - 1864) Mod 60 '�����֧
    TempStr = Gan(i Mod 10) & Zhi(i Mod 12)
    GanZhi = TempStr
End Function

'������������ִ�
Public Function YearAttribute(Y As Long) As String
    YearAttribute = Animals((Y - 1900) Mod 12)
End Function

'�����ֺ���
Public Function UpNumber(Dxs As String) As String

 '���Ϊ��ʱ
 If Trim(Dxs) = "" Then
    UpNumber = ""
    Exit Function
 End If
  
 Dim Sw As Integer, SzUp As Integer, TempStr As String, DXStr As String
    Sw = Len(Trim(Dxs))
     
     Dim i As Integer
     For i = 1 To Sw
         TempStr = Right(Trim(Dxs), i)
         TempStr = Left(TempStr, 1)
         TempStr = Converts(TempStr)
         Select Case i
           Case 1
               If TempStr = "��" Then
                  TempStr = ""
                   Else
                  TempStr = TempStr + ""
               End If
           Case 2
               If TempStr = "��" Then
                  TempStr = "��"
                Else
                  TempStr = TempStr + "ʮ"
               End If
           Case 3
               If TempStr = "��" Then
                  TempStr = "��"
                   Else
                  TempStr = TempStr + "��"
               End If
            Case 4
               If TempStr = "��" Then
                  TempStr = "��"
                   Else
                  TempStr = TempStr + "ǧ"
               End If
            Case 5
               If TempStr = "��" Then
                  TempStr = "��"
                   Else
                  TempStr = TempStr + "��"
               End If
            Case 6
               If TempStr = "��" Then
                  TempStr = "��"
                   Else
                  TempStr = TempStr + "ʮ"
               End If
            Case 7
               If TempStr = "��" Then
                  TempStr = "��"
                   Else
                  TempStr = TempStr + "��"
               End If
            Case 8
               If TempStr = "��" Then
                  TempStr = "��"
                   Else
                  TempStr = TempStr + "ǧ"
               End If
            Case 9
               If TempStr = "��" Then
                  TempStr = "��"
                   Else
                  TempStr = TempStr + "��"
               End If
         End Select
    Dim TempA As String
        TempA = Left(Trim(DXStr), 1)
    If TempStr = "��" Then
      Select Case TempA
       Case "��"
            DXStr = DXStr
       Case "��"
            DXStr = DXStr
       Case "��"
            DXStr = DXStr
       Case Else
            DXStr = TempStr + DXStr
      End Select
      Else
       DXStr = TempStr + DXStr
    End If
     Next
  
    UpNumber = DXStr
End Function
Private Function Converts(NumStr As String) As String
    Select Case Val(NumStr)
      Case 0
        Converts = "��"
      Case 1
        Converts = "һ"
      Case 2
        Converts = "��"
      Case 3
        Converts = "��"
      Case 4
        Converts = "��"
      Case 5
        Converts = "��"
      Case 6
         Converts = "��"
      Case 7
         Converts = "��"
      Case 8
         Converts = "��"
      Case 9
         Converts = "��"
    End Select
End Function
'��������
Public Function CDayStr(d As Long) As String
   Dim s As String
   Select Case d
      Case 0
        s = ""
      Case 10
        s = "��ʮ"
      Case 20
        s = "��ʮ"
      Case 30
        s = "��ʮ"
      Case Else
        s = nStr2(d \ 10)  '��������
        s = s & nStr1(d Mod 10)
   End Select
   CDayStr = s
End Function
'������������
Public Function Constellation(m As Long, d As Long) As String
   Dim Y As Long
   Dim tempDate As Date
   Dim ConstellName As String
 
   Y = 2000
   tempDate = m & "/" & d & "/" & Y

   Select Case tempDate
      Case #3/21/2000# To #4/19/2000#
            ConstellName = "ɽ��"
      Case #4/20/2000# To #5/20/2000#
            ConstellName = "��ţ"
      Case #5/21/2000# To #6/21/2000#
            ConstellName = "˫��"
      Case #6/22/2000# To #7/22/2000#
            ConstellName = "��з"
      Case #7/23/2000# To #8/22/2000#
            ConstellName = "ʨ��"
      Case #8/23/2000# To #9/22/2000#
            ConstellName = "��Ů"
      Case #9/23/2000# To #10/23/2000#
            ConstellName = "��ƽ"
      Case #10/24/2000# To #11/21/2000#
            ConstellName = "��Ы"
      Case #11/22/2000# To #12/21/2000#
            ConstellName = "����"
      Case #12/22/2000# To #12/31/2000#
            ConstellName = "ĦЫ"
      Case #1/1/2000# To #1/19/2000#
            ConstellName = "ĦЫ"
      Case #1/20/2000# To #2/18/2000#
            ConstellName = "ˮƿ"
      Case #2/19/2000# To #3/20/2000#
            ConstellName = "˫��"
      Case Else
            ConstellName = ""
   End Select
   Constellation = ConstellName
End Function
'/////////////////////////////////////////////////////////////////////////////////////////////////////////
'����Ϊ���ڲ�ʹ�õ�һЩ����
'����ũ�� y���������
Private Function lYearDays(ByVal Y As Long) As Long
   
'   Dim i As Long
'   Dim f As Long
'   Dim sumDay As Long
'   Dim info As Long
   
'   sumDay = 348
'   i = &H8000
'   info = LunarInfo(y - 1900) And &H1000FFFF  '���θ�λ,
'   Do
'     f = info And i
'     If f <> 0 Then
'       sumDay = sumDay + 1
'     End If
'     i = BitRight16(i, 1)
'   Loop Until i < &H10
'   lYearDays = sumDay + leapDays(y)
    
    lYearDays = LunarYearDays(Y - 1900)  '�ȼ����ÿ�������,���γ�����,�Լ����Ժ������ʱ��
End Function

'����ũ�� y��m�µ�������
Private Function lMonthDays(ByVal Y As Long, ByVal m As Long) As Long
  'If (LunarInfo(y - 1900) And &H1000FFFF) And BitRight32(&H10000, m) Then
  
  If mvarBitTest32((LunarInfo(Y - 1900) And &H1000FFFF), 16 - m) Then
     lMonthDays = 30
  Else
     lMonthDays = 29
  End If
End Function

'����ũ�� y�����µ�����
Private Function leapDays(Y As Long) As Long
  If leapMonth(Y) Then
    If LunarInfo(Y - 1900) And &H10000 Then
      leapDays = 30
    Else
      leapDays = 29
    End If
  Else
    leapDays = 0
  End If
End Function

'����ũ�� y�����ĸ��� 1-12 , û�򴫻� 0
Private Function leapMonth(Y As Long) As Long
  Dim i As Long
  i = LunarInfo(Y - 1900) And &HF
  If i > 12 Then
    Debug.Print Y
  End If
  leapMonth = i
End Function

'���㹫�����µ�����
Private Function SolarDays(Y As Long, m As Long) As Long
   Dim d As Long
   
   If (Y Mod 4) = 0 Then   '����
      If m = 2 Then
        d = 29
      Else
        d = SolarMonth(m - 1)
      End If
   Else
      If m = 2 Then
        d = 28
      Else
        d = SolarMonth(m - 1)
      End If
   End If
   
   SolarDays = d
End Function


'//////////////////////////////////////////////////////////////////////////////////////////////////
'
'��Ҫ�ĺ���,�ù��������ն����ڶ�����г�ʹ��,�ڴ˺����ڲ���ɶ�˽�ж������Ե�����
'
'//////////////////////////////////////////////////////////////////////////////////////////////////
Public Sub sInitDate(ByVal Y As Long, ByVal m As Long, ByVal d As Long)
    Dim i As Long
    Dim leap As Long
    Dim temp As Long
    Dim offset As Long
    
    mvarDate = DateSerial(Y, m, d)
    mvarsYear = Y
    mvarsMonth = m
    mvarsDay = d
    
    'ũ�����ڼ��㲿��
    leap = 0
    temp = 0
    
    offset = mvarDate - #1/30/1900#  '��������Ļ������
    
    For i = 1900 To 2049
        temp = lYearDays(i)  '����ũ��������
        
        offset = offset - temp
        If offset < 1 Then Exit For
    Next
    
    offset = offset + temp
    mvarlYear = i
    
    leap = leapMonth(i) '���ĸ���
    
    mvarIsLeap = False
    For i = 1 To 12
        '����
        If leap > 0 And i = (leap + 1) And mvarIsLeap = False Then
           mvarIsLeap = True
           i = i - 1
           temp = leapDays(mvarlYear)   '������������
        Else
           mvarIsLeap = False
           temp = lMonthDays(mvarlYear, i) '�������������
        End If
    
        offset = offset - temp
        If offset <= 0 Then Exit For
    Next
    
    offset = offset + temp
    mvarlMonth = i
    mvarlDay = offset
        
End Sub

'//////////////////////////////////////////////////////////////////////////////////////////////////
'
'��Ҫ�ĺ���,��ũ�������ն����ڶ�����г�ʹ��,�ڴ˺����ڲ���ɶ�˽�ж������Ե�����
'
'//////////////////////////////////////////////////////////////////////////////////////////////////
Public Sub lInitDate(ByVal Y As Long, ByVal m As Long, ByVal d As Long, Optional LeapFlag As Boolean = False)
    Dim i As Long
    Dim leap As Long
    Dim temp As Long
    Dim offset As Long

    mvarlYear = Y
    mvarlMonth = m
    mvarlDay = d
    
    offset = 0
    
    For i = 1900 To Y - 1
       temp = LunarYearDays(i - 1900) '����ũ��������
       offset = offset + temp
    Next
    
    leap = leapMonth(Y) '���ĸ���
    If m <> leap Then
       mvarIsLeap = False  '��ǰ���ڲ�������
    Else
       mvarIsLeap = LeapFlag  'ʹ���û�������Ƿ������·�
    End If
    
    If (m < leap) Or (leap = 0) Then   '�������ڵ�ǰ���ں�
        For i = 1 To m - 1
           temp = lMonthDays(Y, i) '�������������
           offset = offset + temp
        Next
    Else   '�����º�
        If mvarIsLeap = False Then  '�û�Ҫ��������µ��·�
             For i = 1 To m - 1
                temp = lMonthDays(Y, i) '�������������
                offset = offset + temp
             Next
             If m > leap Then
                temp = leapDays(Y)   '������������
                offset = offset + temp
             End If
             
        Else  '��ʱֻ��mvarisleap=ture,
               For i = 1 To m
                 temp = lMonthDays(Y, i) '�������������
                 offset = offset + temp
               Next
        End If
    End If
    
    offset = offset + d '���ϵ��µ�����
    mvarDate = DateAdd("d", offset, #1/30/1900#)
    mvarsYear = Year(mvarDate)
    mvarsMonth = Month(mvarDate)
    mvarsDay = Day(mvarDate)

End Sub


