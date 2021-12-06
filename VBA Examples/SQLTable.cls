VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "SQLTable"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'https://excelmacromastery.com/vba-class-modules/
Option Explicit

Private m_DB As String
Private m_Table As String
Private m_Columns As New Collection 'column name,column object

Public Property Get Database() As String
    Database = m_DB
End Property

Public Property Get Table() As String
    Table = m_Table
End Property

Public Property Get FullTable() As String
    FullTable = m_DB & "." & m_Table
End Property

Public Property Get Columns() As Collection
    Set Columns = m_Columns
End Property

Public Property Get ColumnCount() As Long
    ColumnCount = m_Columns.Count
End Property

Public Sub Init(pDB, pTable)
    m_DB = pDB
    m_Table = pTable
End Sub

Private Sub Class_Initialize()
    'MsgBox "Class is being initialized"
End Sub

Private Sub Class_Terminate()
    'MsgBox "Class is being terminated"
    Set m_Columns = Nothing
End Sub

Public Sub AddColumn(pName As String, pType As String, pNullable As Boolean, pDefault As String, pExtra As String, Optional pIsPKey As Boolean = False)
    Dim oColumn As New SQLColumn
    oColumn.Name = pName
    oColumn.ColumnType = pType
    oColumn.Nullable = pNullable
    oColumn.Default = pDefault
    oColumn.Extra = pExtra
    oColumn.IsPKey = pIsPKey
    Call m_Columns.Add(oColumn, pName)
End Sub

Public Sub RemoveColumn(pName As String)
    Call m_Columns.Remove(pName)
End Sub

Public Function ToCreateString(Optional pSurrogateKey As Boolean = False, Optional pTimeStamp As Boolean = False) As String
    Dim strQuery As String
    Dim oSQLColumn As SQLColumn
    strQuery = "CREATE TABLE " & m_DB & "." & m_Table & " ("
    If pSurrogateKey Then
        strQuery = strQuery & "id bigint identity(1,1) primary key,"
    End If
    If pTimeStamp Then
        strQuery = strQuery & "entry_datetime datetime not null DEFAULT CURRENT_TIMESTAMP,"
        strQuery = strQuery & "last_update_datetime datetime not null DEFAULT CURRENT_TIMESTAMP,"
    End If
    For Each oSQLColumn In m_Columns
        strQuery = strQuery & oSQLColumn.ToString & ","
    Next
    strQuery = Left(strQuery, Len(strQuery) - 1)
    strQuery = strQuery & ")"
    ToCreateString = strQuery
End Function

Public Function ToAlterString() As String
    Dim strQuery As String
    Dim oSQLColumn As SQLColumn
    strQuery = "ALTER TABLE " & m_DB & "." & m_Table & " "

    For Each oSQLColumn In m_Columns
        strQuery = strQuery & "ADD COLUMN " & oSQLColumn.ToString & ","
    Next
    strQuery = Left(strQuery, Len(strQuery) - 1)
    ToAlterString = strQuery
End Function
