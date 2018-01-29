Attribute VB_Name = "businessfunnel"
Public Function Initialize() As String
    On Error GoTo ErrorHandler
    
    ' Call on SQL Procedure getDealValue with parameters, local language and idcoworker, XML is returned
    'ropa på sql procedur och skicka med namnet på statusfält och värde fältet och få tillbaka en xml som liknar nedan
    Dim businessXML As String

    Dim procGetDealvalue As LDE.Procedure
    Set procGetDealvalue = Application.Database.Procedures.Lookup("csp_getBusinessValue", lkLookupProcedureByName)

    procGetDealvalue.Parameters("@@lang").InputValue = Database.Locale
    procGetDealvalue.Parameters("@@idcoworker").InputValue = ActiveUser.record.id
    Call procGetDealvalue.Execute(False)

    businessXML = procGetDealvalue.result
    
    Initialize = businessXML

Exit Function
ErrorHandler:
    UI.ShowError ("Businessfunnel.Initialize")

End Function



Public Sub SetFilter(ByVal sOptionkey As String, ByVal bMine As Boolean)
    On Error GoTo ErrorHandler
    Dim oFilter As New LDE.filter
    Dim lOptionValue As Long
    
    lOptionValue = Application.Classes("deal").Fields("dealstatus").Options.Lookup(sOptionkey, lkLookupOptionByKey)
    Call oFilter.AddCondition("dealstatus", lkOpEqual, lOptionValue)
    If bMine = True Then
        Call oFilter.AddCondition("coworker", lkOpEqual, ActiveUser.record.id)
        Call oFilter.AddOperator(lkOpAnd)
    End If
    
    
    Set pExplorer = Application.Explorers("deal")
    
    'if explorer is not Visible it is set to Visible
    If pExplorer.Visible = False Then
        pExplorer.Visible = True
    End If
    
    Set Application.Explorers.ActiveExplorer = pExplorer
    
    oFilter.name = Application.Classes("deal").Fields("dealstatus").Options.Lookup(sOptionkey, lkLookupOptionByKey).Text
    Set Application.Explorers.ActiveExplorer.ActiveFilter = oFilter
    
    Application.ActiveExplorer.Requery
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("Businessfunnel.SetFilter")
End Sub


