Attribute VB_Name = "donutchart"
Public Function Initialize() As String
    On Error GoTo ErrorHandler

    ' Call on SQL Procedure getParticipants with parameters, local language and idcoworker, XML is returned
    
    Dim participantsXML As String

    Dim procGetCampaignParticipants As LDE.Procedure
    Set procGetCampaignParticipants = Application.Database.Procedures.Lookup("csp_getParticipants", lkLookupProcedureByName)

    procGetCampaignParticipants.Parameters("@@lang").InputValue = Database.Locale
    procGetCampaignParticipants.Parameters("@@idcampaign").InputValue = ActiveInspector.Record.ID
    Call procGetCampaignParticipants.Execute(False)

    participantsXML = procGetCampaignParticipants.result

    Initialize = participantsXML

Exit Function
ErrorHandler:
    UI.ShowError ("Donutchart.Initialize")

End Function

