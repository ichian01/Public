VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "SQLColumn"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Name As String
Public ColumnType As String
Public Nullable As Boolean
Public Default As String
Public Extra As String
Public IsPKey As Boolean

Private Sub Class_Initialize()
    Nullable = True
    IsPKey = False
End Sub

Public Function ToString()
    Dim strResult As String
    strResult = Name & " " & ColumnType & " "
    If Not Nullable Then
        strResult = strResult & "NOT NULL "
    End If
    If Len(Default) > 0 Then
        strResult = strResult & "DEFAULT " & Default & " "
    End If
    If Len(Extra) > 0 Then
        strResult = strResult & Extra & " "
    End If
    ToString = strResult
End Function
