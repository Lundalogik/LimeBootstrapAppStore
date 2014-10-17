Attribute VB_Name = "AdminTools"
Public Function GetSessionStats(ByVal sGroupBy As String, ByVal sDate As String) As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim sessions As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_get_login_stats", lkLookupProcedureByName) 'csp_get_login_stats", lkLookupProcedureByName)
    oProc.Parameters("@@date").InputValue = sDate
    oProc.Parameters("@@groupby").InputValue = sGroupBy
    Call oProc.Execute(False)
    sessions = oProc.Parameters("@@sessionxml").OutputValue
    
    GetSessionStats = sessions
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("AdminTools.GetSessionStats")

End Function

Public Function GetLogStats(ByVal sGroupBy As String, ByVal sDate As String) As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_get_logstats", lkLookupProcedureByName) 'csp_get_login_stats", lkLookupProcedureByName)
    oProc.Parameters("@@date").InputValue = sDate
    oProc.Parameters("@@groupby").InputValue = sGroupBy
    Call oProc.Execute(False)
    ret = oProc.Parameters("@@retxml").OutputValue
   
    GetLogStats = ret
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("AdminTools.GetLogStats")
End Function


Public Function GetSqlFields() As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_get_sql_fields", lkLookupProcedureByName)
    Call oProc.Execute(False)
    ret = oProc.Parameters("@@retval").OutputValue
   
    GetSqlFields = ret
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("AdminTools.GetSqlFields")

End Function

Public Function GetSqlTables() As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_get_sql_field_tables", lkLookupProcedureByName)
    Call oProc.Execute(False)
    ret = oProc.Parameters("@@retval").OutputValue
   
    GetSqlTables = ret
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("AdminTools.GetSqlTables")

End Function


Public Function GetIndexInfo(ByVal iThresHold As Integer) As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_get_index_info", lkLookupProcedureByName)
    oProc.Parameters("@@defrag_threshold").InputValue = iThresHold
    Call oProc.Execute(False)
    ret = oProc.Parameters("@@retval").OutputValue
   
    GetIndexInfo = ret
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("AdminTools.GetIndexInfo")

End Function

Public Function GetNewIndices() As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_get_new_indices", lkLookupProcedureByName)
    Call oProc.Execute(False)
    ret = oProc.Parameters("@@retval").OutputValue
    GetNewIndices = ret
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("AdminTools.GetNewIndices")

End Function

Public Function GetDBInfo() As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_get_database_info", lkLookupProcedureByName)
    Call oProc.Execute(False)
    ret = oProc.Parameters("@@retval").OutputValue
   
    GetDBInfo = ret
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("AdminTools.GetDBInfo")

End Function


Public Function GetSqlJobs() As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_get_sql_job_status", lkLookupProcedureByName)
    Call oProc.Execute(False)
    ret = oProc.Parameters("@@retval").OutputValue
    ret = VBA.Replace(ret, "\", "\\")
    GetSqlJobs = ret
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("AdminTools.GetSqlJobs")

End Function

Public Function GetUsers(ByVal sDate As String, ByVal sFormat As String) As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_get_userlist", lkLookupProcedureByName)
    oProc.Parameters("@@date") = sDate
    oProc.Parameters("@@format") = sFormat
    Call oProc.Execute(False)
    ret = oProc.Parameters("@@retval").OutputValue
   
    GetUsers = ret
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("AdminTools.GetUsers")

End Function

Public Function GetInfoLog(ByVal sFormat As String, ByVal sDate As String) As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_get_infologstats", lkLookupProcedureByName)
    oProc.Parameters("@@date") = sDate
    oProc.Parameters("@@groupby") = sFormat
    Call oProc.Execute(False)
    ret = oProc.Parameters("@@retxml").OutputValue
   
    GetInfoLog = ret
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("AdminTools.GetInfoLog")

End Function


Public Function GetRecords(ByVal sDate As String, ByVal sFormat As String) As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_get_records", lkLookupProcedureByName)
    oProc.Parameters("@@date") = sDate
    oProc.Parameters("@@format") = sFormat
    Call oProc.Execute(False)
    ret = oProc.Parameters("@@retval").OutputValue
   
    GetRecords = ret
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("AdminTools.GetRecords")

End Function


Public Function GetSqlProgrammability() As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_get_procedures", lkLookupProcedureByName)
    Call oProc.Execute(False)
    ret = oProc.Parameters("@@retval").OutputValue
    GetSqlProgrammability = ret
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("AdminTools.GetSqlProgramability")

End Function

Public Function SearchProgrammability(ByVal sVal As String) As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_search_in_programmability", lkLookupProcedureByName)
    oProc.Parameters("@@searchval").InputValue = sVal
    Call oProc.Execute(False)
    ret = oProc.Parameters("@@retval").OutputValue
    SearchProgrammability = ret
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("AdminTools.SearchProgrammability")

End Function



Public Sub ExecuteSQLOnUpdate(ByVal sTableName As String)
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    
    Set oProc = Database.Procedures.Lookup("csp_admintools_trigger_sqlonupdate", lkLookupProcedureByName)
    oProc.Parameters("@@table") = sTableName
    Call oProc.Execute(False)
    Exit Sub
ErrorHandler:
    Call UI.ShowError("AdminTools.ExecuteSQL")
End Sub

Public Sub StartJob(ByVal jobName As String)
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim ret As String
    Dim sql As String
    
    sql = "EXECUTE msdb.dbo.sp_start_job @job_name = '" + jobName + "'"
    Set oProc = Database.Procedures.Lookup("csp_admintools_executesql", lkLookupProcedureByName)
    oProc.Parameters("@@sql") = sql
    Call oProc.Execute(False)
    Exit Sub
ErrorHandler:
    Call UI.ShowError("AdminTools.ExecuteSQL")
End Sub

Public Sub ExecuteSQL(ByVal sSQL As String)
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    If vbYes = Lime.MessageBox("Är du säker på att du vill göra detta?", vbYesNo) Then
    Set oProc = Database.Procedures.Lookup("csp_admintools_executesql", lkLookupProcedureByName)
    oProc.Parameters("@@sql") = sSQL
    Call oProc.Execute(False)
    End If
    Exit Sub
ErrorHandler:
    Call UI.ShowError("AdminTools.ExecuteSQL")
End Sub

