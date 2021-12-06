Attribute VB_Name = "DataAccess"
Option Explicit

'Related articles:
'https://docs.microsoft.com/en-us/sql/ado/reference/ado-api/execute-requery-and-clear-methods-example-vb?view=sql-server-ver15
'https://docs.microsoft.com/en-us/previous-versions/office/troubleshoot/office-developer/transfer-excel-data-from-ado-recordset
'https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/set-statement
'https://dev.mysql.com/doc/connector-odbc/en/connector-odbc-examples-programming-vb-ado.html
'When working with mysql make sure RecordSet CursorLocation is UseClient since MySQL doesn't return a Rowcount
'Also Use RecordSet.Open instead of Command.Execute for this very reason
'https://excelmacromastery.com/vba-error-handling/
'https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/implements-statement
Public Sub GetDataFromQuery(pstrQuery As String, pOutRange As Range, Optional pIncludeHeader As Boolean = True)
    On Error GoTo Catch
Try:
    Dim oConn As New ADODB.Connection
    Dim oCmd As New ADODB.Command
    Dim oRS As New ADODB.Recordset
    
    oConn.ConnectionString = glblConnString
    Call oConn.Open
    oCmd.ActiveConnection = oConn
    oCmd.CommandText = pstrQuery
    oRS.CursorLocation = adUseClient 'important for mysql

    Call oRS.Open(oCmd, CursorType:=adOpenStatic, LockType:=adLockReadOnly)
        
    If Not oRS Is Nothing Then
        If pIncludeHeader Then
            Dim iCols As Long
            For iCols = 0 To oRS.Fields.Count - 1
                pOutRange.Offset(0, iCols).Value = oRS.Fields(iCols).Name
            Next
            Call pOutRange.Offset(1, 0).CopyFromRecordset(oRS)
        Else
            Call pOutRange.CopyFromRecordset(oRS)
        End If
    End If
    
    GoTo Finally

Catch:
    pOutRange.Value = Err.Description
    pOutRange.Offset(1, 0).Value = Err.Source

Finally:
    If Not (oRS Is Nothing) Then
        If (oRS.State And adStateOpen) = adStateOpen Then oRS.Close
        Set oRS = Nothing
    End If
    
    Set oCmd = Nothing
    
    If Not (oConn Is Nothing) Then
        If (oConn.State And adStateOpen) = adStateOpen Then oConn.Close
        Set oConn = Nothing
    End If
End Sub

Public Sub ExecuteNoDataQuery(pstrQuery As String, pOutRange As Range)
    On Error GoTo Catch
Try:
    pOutRange.Clear
    Dim oConn As New ADODB.Connection
    Dim oCmd As New ADODB.Command
    Dim oRS As Recordset
    oConn.ConnectionString = glblConnString
    Call oConn.Open
    oCmd.ActiveConnection = oConn
    oCmd.CommandText = pstrQuery
    Set oRS = oCmd.Execute
    
    GoTo Finally
    
Catch:
    pOutRange.Value = Err.Description
    pOutRange.Offset(1, 0).Value = Err.Source

Finally:
    If Not (oRS Is Nothing) Then
        If (oRS.State And adStateOpen) = adStateOpen Then oRS.Close
        Set oRS = Nothing
    End If
    
    Set oCmd = Nothing
    
    If Not (oConn Is Nothing) Then
        If (oConn.State And adStateOpen) = adStateOpen Then oConn.Close
        Set oConn = Nothing
    End If
End Sub

'Redundant Code, clone of GetDataFromQuery, prefer to change
'To Inversion of Control, using with interfaces/implements keyword.
'VBA isn't a pure OO language
Public Function BuildTable(pTableName As String, pDB As String) As SQLTable
    'On Error GoTo Catch
Try:
    Dim oConn As New ADODB.Connection
    Dim oCmd As New ADODB.Command
    Dim oRS As New ADODB.Recordset
    Dim oTable As New SQLTable
    Call oTable.Init(pDB, pTableName)
    
    oConn.ConnectionString = glblConnString
    Call oConn.Open
    oConn.DefaultDatabase = pDB
    oCmd.ActiveConnection = oConn
    oCmd.CommandText = "describe " & pDB & "." & pTableName
    oRS.CursorLocation = adUseClient 'important for mysql
    
    Call oRS.Open(oCmd, CursorType:=adOpenStatic, LockType:=adLockReadOnly)
    Dim strTable As String, strType As String, strNullable As String, strKey As String, strDefault As String, strExtra As String
    
    If Not oRS Is Nothing Then
        Do Until oRS.EOF
            strTable = oRS(0)
            strType = oRS(1)
            strNullable = oRS(2)
            strKey = IsNullCstr(oRS(3))
            strDefault = IsNullCstr(oRS(4))
            strExtra = IsNullCstr(oRS(5))
            Call oTable.AddColumn(strTable, strType, strNullable = "YES", strDefault, strExtra, strKey = "PRI")
            oRS.MoveNext
        Loop
    End If
    
    GoTo Finally

Catch:
    Set oTable = Nothing

Finally:
    If Not (oRS Is Nothing) Then
        If (oRS.State And adStateOpen) = adStateOpen Then oRS.Close
        Set oRS = Nothing
    End If
    
    Set oCmd = Nothing
    
    If Not (oConn Is Nothing) Then
        If (oConn.State And adStateOpen) = adStateOpen Then oConn.Close
        Set oConn = Nothing
    End If
    
    
    Set BuildTable = oTable
End Function

Private Function IsNullCstr(pInput As Variant, Optional pReplacement As String = "") As String
    If IsNull(pInput) Then
        IsNullCstr = pReplacement
    Else
        IsNullCstr = CStr(pInput)
    End If
End Function

