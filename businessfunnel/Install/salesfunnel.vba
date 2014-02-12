Public Function Initialize() As String
    On Error GoTo ErrorHandler
    
    ' Call on SQL Procedure getBusinessValue with parameters, local language and idcoworker, XML is returned
    'ropa på sql procedur och skicka med namnet på statusfält och värde fältet och få tillbaka en xml som liknar nedan
    Dim businessXML As String

    Dim procGetBusinessvalue As LDE.Procedure
    Set procGetBusinessvalue = Application.Database.Procedures.Lookup("csp_getBusinessValue", lkLookupProcedureByName)

    procGetBusinessvalue.Parameters("@@lang").InputValue = Database.Locale
    procGetBusinessvalue.Parameters("@@idcoworker").InputValue = ActiveUser.Record.id
    Call procGetBusinessvalue.Execute(False)

    businessXML = procGetBusinessvalue.Result
    
    Initialize = businessXML

Exit Function
ErrorHandler:
    UI.ShowError ("Businessfunnel.Initialize")

End Function



Public Sub SetFilter(ByVal sOptionkey As String, ByVal bMine As Boolean)
    On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Dim lOptionValue As Long
    
    lOptionValue = Application.Classes("business").Fields("businesstatus").Options.Lookup(sOptionkey, lkLookupOptionByKey)
    Call oFilter.AddCondition("businesstatus", lkOpEqual, lOptionValue)
    If bMine = True Then
        Call oFilter.AddCondition("coworker", lkOpEqual, ActiveUser.Record.id)
        Call oFilter.AddOperator(lkOpAnd)
    End If
    
    
    Set pExplorer = Application.Explorers("business")
    
    'if explorer is not Visible it is set to Visible
    If pExplorer.Visible = False Then
        pExplorer.Visible = True
    End If
    
    Set Application.Explorers.ActiveExplorer = pExplorer
    
    oFilter.Name = Application.Classes("business").Fields("businesstatus").Options.Lookup(sOptionkey, lkLookupOptionByKey).Text
    Set Application.Explorers.ActiveExplorer.ActiveFilter = oFilter
    
    Application.ActiveExplorer.Requery
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("Businessfunnel.SetFilter")
End Sub


