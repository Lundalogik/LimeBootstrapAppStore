Declare Function GetSystemMetrics32 Lib "user32" _
    Alias "GetSystemMetrics" (ByVal nIndex As Long) As Long

Public Function GetRecordID(ByVal sType As String) As Long
    On Error GoTo ErrorHandler
    GetRecordID = -1
    If Globals.VerifyInspector("company", ActiveInspector, False) Then
        If Globals.VerifyInspector("company", ActiveInspector) Then
            GetRecordID = ActiveInspector.Record.ID
        End If
    ElseIf ActiveExplorer.Class.Name = "company" Then
        If Not ActiveExplorer.Class.Name = "company" Then
            Exit Function
        End If
        If Not ActiveExplorer.Selection.Count = 1 Then
            Exit Function
        End If
        GetRecordID = ActiveExplorer.Selection(1).ID
    End If
    Exit Function
ErrorHandler:
    Call UI.ShowError("CompanyTree.GetRecordID")
End Function


Public Function GetHierarchy(ByVal idcompany As Long, ByVal includperson As Integer) As String
    On Error GoTo ErrorHandler
    Dim oProc As LDE.Procedure
    Dim retval As String
    
    Set oProc = Database.Procedures.Lookup("csp_get_company_hierarchy", lkLookupProcedureByName)
    If Not oProc Is Nothing Then
        oProc.Parameters("@@idcompany").InputValue = idcompany
        oProc.Parameters("@@includeperson").InputValue = includperson
        Call oProc.Execute(False)
        retval = oProc.Parameters("@@retval").OutputValue
    End If

    GetHierarchy = retval
  
    Exit Function
ErrorHandler:
    Call UI.ShowError("CompanyTree.GetHierarchy")
End Function


Public Sub OpenCompanyTree()
    On Error GoTo ErrorHandler
    Dim oDialog As New Lime.Dialog
    
    If Globals.VerifyInspector("company", ActiveInspector, False) Then
        oDialog.Type = lkDialogHTML
        oDialog.Property("url") = Application.WebFolder & "lbs.html?ap=companytree&type=tab"
        oDialog.Property("height") = 0.9 * GetSystemMetrics32(1)
        oDialog.Property("width") = 0.8 * GetSystemMetrics32(0)
        oDialog.show
        Exit Sub
    End If
    
    If ActiveExplorer.Class.Name = "company" Then
        If Not ActiveExplorer.Selection.Count = 1 Then
            Exit Sub
        End If
        oDialog.Type = lkDialogHTML
        oDialog.Property("url") = Application.WebFolder & "lbs.html?ap=companytree&type=tab"
        oDialog.Property("height") = 0.9 * GetSystemMetrics32(1)
        oDialog.Property("width") = 0.8 * GetSystemMetrics32(0)
        oDialog.show
        Exit Sub
    End If

    Exit Sub
ErrorHandler:
    UI.ShowError ("CompanyTree.OpenCompanyTree")
End Sub

Public Sub OpenCompanyRecord(ByVal sLimeLink As String)
    On Error GoTo ErrorHandler
    
    Call Application.Shell(sLimeLink)
    
    Exit Sub
ErrorHandler:
    UI.ShowError ("CompanyTree.OpenCompanyTree")
End Sub

