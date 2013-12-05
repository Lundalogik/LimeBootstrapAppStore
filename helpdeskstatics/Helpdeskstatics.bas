Attribute VB_Name = "Helpdeskstatics"
Public Function Initialize() As String

    ' Call on SQL Procedure getHelpdeskStatics with parameter idcoworker, XML is returned
    Dim helpdeskStaticsXML As String

    Dim procgetHelpdeskStatistics As LDE.Procedure
    Set procgetHelpdeskStatistics = Application.Database.Procedures.Lookup("csp_getHelpdeskStatistics", lkLookupProcedureByName)

    procgetHelpdeskStatistics.Parameters("@@idcoworker").InputValue = ActiveUser.Record.id
    Call procgetHelpdeskStatistics.Execute(False)

    helpdeskStaticsXML = procgetHelpdeskStatistics.Result
    
    Initialize = helpdeskStaticsXML

End Function

