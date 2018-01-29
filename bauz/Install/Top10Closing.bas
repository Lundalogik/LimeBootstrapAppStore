Attribute VB_Name = "Top10Closing"
'Attribute VB_Name = "Top5"
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

    Dim procGetTop10closing As LDE.Procedure
    Set procGetTop10closing = Application.Database.Procedures.Lookup("csp_getTop10closing", lkLookupProcedureByName)
'    procGetTop10closing.Parameters("@@dayrange").InputValue = dayRange
'    procGetTop10closing.Parameters("@@businessstatus").InputValue = businessStatus
    Call procGetTop10closing.Execute(False)

    sXMLresult = procGetTop10closing.Result
    
    Initialize = sXMLresult

Exit Function
ErrorHandler:
    UI.ShowError ("procGetTop10closing.Initialize")

End Function

'Public Sub SetFilter(ByVal idcoworker As Long)
'    On Error GoTo ErrorHandler
'    If idcoworker = 999 Then
'        Lime.MessageBox ("No contender found. Have all your sales reps do some business!")
'        Exit Sub
'    End If
'
'    Dim oFilter As New LDE.Filter
'    Dim lOptionValue As Long
'    Dim oRecord As LDE.Record
'    Set oRecord = New LDE.Record
'    Call oRecord.Open(Database.Classes("coworker"), idcoworker)
'
'    lOptionValue = Application.Classes("business").Fields("businesstatus").Options.Lookup(sOptionkey, lkLookupOptionByKey)
'    Call oFilter.AddCondition("businesstatus", lkOpEqual, lOptionValue)
'    Call oFilter.AddCondition("coworker", lkOpEqual, idcoworker)
'    Call oFilter.AddOperator(lkOpAnd)
'    Call oFilter.AddCondition("quotesent", lkOpGreaterOrEqual, DateAdd("d", -dayRange, Date))
'    Call oFilter.AddOperator(lkOpAnd)
'
'    Set pExplorer = Application.Explorers("business")
'
'    'if explorer is not Visible it is set to Visible
'    If pExplorer.Visible = False Then
'        pExplorer.Visible = True
'    End If
'
'    Set Application.Explorers.ActiveExplorer = pExplorer
'
'    oFilter.name = oRecord.value("name")
'    Set Application.Explorers.ActiveExplorer.ActiveFilter = oFilter
'
'    Application.ActiveExplorer.Requery
'
'    Exit Sub
'ErrorHandler:
'    Call UI.ShowError("Top5.SetFilter")
'End Sub






