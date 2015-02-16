Attribute VB_Name = "Top5"
'OPTION SETUP
'the option key of the preferred business status
Public Const sOptionkey As String = "agreement"
'the date range of how many days back you want to see results
Public Const dayRange As Integer = 30
'OPTION SETUP END


Public Function Initialize() As String
    On Error GoTo ErrorHandler
        
    Dim businessStatus As Long
    businessStatus = Application.Classes("business").Fields("businesstatus").Options.Lookup(sOptionkey, lkLookupOptionByKey)

    Dim sXMLresult As String

    Dim procGetTop5 As LDE.Procedure
    Set procGetTop5 = Application.Database.Procedures.Lookup("csp_getTop5", lkLookupProcedureByName)
    procGetTop5.Parameters("@@dayrange").InputValue = dayRange
    procGetTop5.Parameters("@@businessstatus").InputValue = businessStatus
    Call procGetTop5.Execute(False)

    sXMLresult = procGetTop5.result
    
    Initialize = sXMLresult

Exit Function
ErrorHandler:
    UI.ShowError ("Top5.Initialize")

End Function

Public Sub SetFilter(ByVal idcoworker As Long)
    On Error GoTo ErrorHandler
    If idcoworker = 999 Then
        Lime.MessageBox ("No contender found. Have all your sales reps do some business!")
        Exit Sub
    End If
    
    Dim oFilter As New LDE.Filter
    Dim lOptionValue As Long
    Dim oRecord As LDE.Record
    Set oRecord = New LDE.Record
    Call oRecord.Open(Database.Classes("coworker"), idcoworker)
    
    lOptionValue = Application.Classes("business").Fields("businesstatus").Options.Lookup(sOptionkey, lkLookupOptionByKey)
    Call oFilter.AddCondition("businesstatus", lkOpEqual, lOptionValue)
    Call oFilter.AddCondition("coworker", lkOpEqual, idcoworker)
    Call oFilter.AddOperator(lkOpAnd)
    Call oFilter.AddCondition("quotesent", lkOpGreaterOrEqual, DateAdd("d", -dayRange, Date))
    Call oFilter.AddOperator(lkOpAnd)
    
    Set pExplorer = Application.Explorers("business")
    
    'if explorer is not Visible it is set to Visible
    If pExplorer.Visible = False Then
        pExplorer.Visible = True
    End If
    
    Set Application.Explorers.ActiveExplorer = pExplorer
    
    oFilter.Name = oRecord.Value("name")
    Set Application.Explorers.ActiveExplorer.ActiveFilter = oFilter
    
    Application.ActiveExplorer.Requery
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("Top5.SetFilter")
End Sub




