Public Function Initialize() As String

    
    'ropa på sql procedur och skicka med namnet på statusfält och värde fältet och få tillbaka en xml som liknar nedan
    Dim businessXML As String

    Dim procGetBusinessvalue As LDE.Procedure
    Set procGetBusinessvalue = Application.Database.Procedures.Lookup("csp_getBusinessValue", lkLookupProcedureByName)

    procGetBusinessvalue.Parameters("@@lang").InputValue = Database.Locale
    Call procGetBusinessvalue.Execute(False)

    businessXML = procGetBusinessvalue.Result
    
    Initialize = businessXML

End Function