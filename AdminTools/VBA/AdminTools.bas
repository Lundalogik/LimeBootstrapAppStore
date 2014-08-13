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
