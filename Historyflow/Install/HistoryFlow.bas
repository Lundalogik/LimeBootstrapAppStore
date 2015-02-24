Attribute VB_Name = "HistoryFlow"
Option Explicit

Public Function GetHistories(ByVal sTable As String, ByVal sHitCount As String) As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim retval As String
    
    If Globals.VerifyInspector(sTable, ActiveInspector, True) Then
        Set oProc = Database.Procedures.Lookup("csp_get_historyflow", lkLookupProcedureByName)
        If Not oProc Is Nothing Then
            oProc.Parameters("@@table").InputValue = sTable
            oProc.Parameters("@@hitcount").InputValue = sHitCount
            oProc.Parameters("@@idrecord").InputValue = CStr(ActiveInspector.Record.ID)
            oProc.Parameters("@@lang").InputValue = Lime.Locale
            Call oProc.Execute(False)
            retval = oProc.Parameters("@@retval").OutputValue
        End If
    End If
    
    GetHistories = retval
    
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("HistoryFlow.GetHistories")
End Function
