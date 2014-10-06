VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CByteStream"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'ģ��:�ֽ���������
Option Explicit

Private Declare Sub CopyMemory Lib "kernel32.dll" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)

Private mData() As Byte
Private mCount As Long
Private mSpaceSize As Long

Public Tag As Variant

Private Sub Class_Initialize()
    '
End Sub

Private Sub Class_Terminate()
    Call Clear
    
End Sub


'ȡ�������ֽ���
Public Property Get Count() As Long
    Count = mCount
End Property

'ȡ��/��������
Public Property Get Data() As Byte()
    Data = mData
End Property

Public Property Let Data(ByRef RHS() As Byte)
    Dim L As Long, U As Long
    
    On Error Resume Next
    L = LBound(RHS)
    If ERR.Number Then Exit Property
    On Error GoTo 0
    U = UBound(RHS)
    
    mCount = (U - L + 1)
    mSpaceSize = mCount
    If L = 0 Then
        mData = RHS
    Else
        ReDim mData(0 To mSpaceSize - 1)
        CopyMemory mData(0), RHS(L), mCount * 1
    End If
    
End Property

'ȡ���ڲ����ݵ�ָ��
Public Property Get DataPtr() As Long
    If mCount <= 0 Then
        DataPtr = 0
    Else
        DataPtr = VarPtr(mData(0))
    End If
End Property

'��ջ�����
Public Function Clear() As Boolean
    If mCount <= 0 Then Exit Function
    
    mCount = 0
    Erase mData
    mSpaceSize = 0
    
    Clear = True
    
End Function

'ȡ������
Public Function GetData(ByRef BytArr() As Byte, Optional ByVal cbData As Long = -1) As Long
    If (cbData > mCount) Or (cbData = -1) Then
        cbData = mCount
    End If
    
    If cbData > 0 Then
        ReDim BytArr(0 To cbData - 1)
        CopyMemory BytArr(0), mData(0), cbData
        
        If cbData < mCount Then
            CopyMemory mData(0), mData(cbData), mCount - cbData
        End If
        mCount = mCount - cbData
        
    End If
    
    GetData = cbData
    
End Function

'ȡ�����ݣ�ʹ�õ�ַ��
Public Function GetData4Ptr(ByVal BufPtr As Long, Optional ByVal cbData As Long = -1) As Long
    If (BufPtr And &HFFF&) = 0 Then '��4K�Ǽ����Чָ�������
        Exit Function
    End If
    
    If (cbData > mCount) Or (cbData = -1) Then
        cbData = mCount
    End If
    
    If cbData > 0 Then
        CopyMemory ByVal BufPtr, mData(0), cbData
        
        If cbData < mCount Then
            CopyMemory mData(0), mData(cbData), mCount - cbData
        End If
        mCount = mCount - cbData
        
    End If
    
    GetData4Ptr = cbData
    
End Function

'�鿴����
Public Function PeekData(ByRef BytArr() As Byte, Optional ByVal START As Long = 0, Optional ByVal cbData As Long = -1) As Long
    If START < 0 Then
        cbData = cbData + START
        START = 0
    End If
    
    If (START + cbData > mCount) Or (cbData = -1) Then
        cbData = mCount - START
    End If
    
    If cbData > 0 Then
        ReDim BytArr(0 To cbData - 1)
        CopyMemory BytArr(0), mData(START), cbData
    End If
    
    PeekData = cbData
    
End Function

'�鿴���ݣ�ʹ�õ�ַ��
Public Function PeekData4Ptr(ByVal BufPtr As Long, Optional ByVal START As Long = 0, Optional ByVal cbData As Long = -1) As Long
    If (BufPtr And &HFFF&) = 0 Then '��4K�Ǽ����Чָ�������
        Exit Function
    End If
    
    If START < 0 Then
        cbData = cbData + START
        START = 0
    End If
    
    If (START + cbData > mCount) Or (cbData = -1) Then
        cbData = mCount - START
    End If
    
    If cbData > 0 Then
        CopyMemory ByVal BufPtr, mData(START), cbData
    End If
    
    PeekData4Ptr = cbData
    
End Function

'��������
Public Function AddData(ByRef BytArr() As Byte) As Long
    Dim L As Long, U As Long
    Dim cbData As Long
    
    On Error Resume Next
    L = LBound(BytArr)
    If ERR.Number Then Exit Function
    On Error GoTo 0
    U = UBound(BytArr)
    cbData = U - L + 1
    If cbData <= 0 Then
        Exit Function
    End If
    
    If cbData > 0 Then
        mCount = mCount + cbData
        If mSpaceSize < mCount Then  '����ռ�
            mSpaceSize = mCount
            ReDim Preserve mData(0 To mSpaceSize - 1)
        End If
        
        CopyMemory mData(mCount - cbData), BytArr(0), cbData
    End If
    
    AddData = cbData
    
End Function

'�������ݣ�ʹ�õ�ַ��
Public Function AddData4Ptr(ByVal BufPtr As Long, ByVal cbData As Long) As Long
    If (BufPtr And &HFFF&) = 0 Then '��4K�Ǽ����Чָ�������
        Exit Function
    End If
    
    If cbData > 0 Then
        mCount = mCount + cbData
        If mSpaceSize < mCount Then  '����ռ�
            mSpaceSize = mCount
            ReDim Preserve mData(0 To mSpaceSize - 1)
        End If
        
        CopyMemory mData(mCount - cbData), ByVal BufPtr, cbData
        
    End If
    
    AddData4Ptr = cbData
    
End Function

'ɾ������
Public Function DeleteData(Optional ByVal START As Long = 0, Optional ByVal cbData As Long = -1) As Long
    If START < 0 Then
        cbData = cbData + START
        START = 0
    End If
    
    If (START + cbData > mCount) Or (cbData = -1) Then
        cbData = mCount - START
    End If
    
    If cbData > 0 Then
        If cbData < mCount Then
            CopyMemory mData(START), mData(START + cbData), mCount - cbData
        End If
        mCount = mCount - cbData
        
    End If
    
    DeleteData = cbData
    
End Function

'��¡����
Public Function Clone() As CByteStream
    Dim Item As CByteStream
    
    Set Item = New CByteStream
    Call Item.Clear
    Call Item.AddData4Ptr(Me.DataPtr, Me.Count)
    
    Set Clone = Item
    
End Function

'�ӱ𴦿�¡
Public Function CloneFrom(ByVal Source As CByteStream) As Long
    If (Source.DataPtr And &HFFF&) = 0 Then '��4K�Ǽ����Чָ�������
        Exit Function
    End If
    
    mCount = Source.Count
    If mSpaceSize < mCount Then '����ռ�
        mSpaceSize = mCount
        ReDim Preserve mData(0 To mSpaceSize - 1)
    End If
    
    CopyMemory mData(0), ByVal Source.DataPtr, mCount
    
    CloneFrom = mCount
    
End Function
