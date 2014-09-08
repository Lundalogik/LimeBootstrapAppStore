Attribute VB_Name = "Activityweb"
Public Function Initialize() As String
    On Error GoTo errorhandler

    ' Call on SQL Procedure getActivities with parameters, local language and idcoworker, XML is returned
    
    Dim activitiesXML As String

    Dim procGetActivities As LDE.Procedure
    Set procGetActivities = Application.Database.Procedures.Lookup("csp_getActivities", lkLookupProcedureByName)

    procGetActivities.Parameters("@@lang").InputValue = Database.Locale
    procGetActivities.Parameters("@@iduser").InputValue = ActiveInspector.Record.ID
    Call procGetActivities.Execute(False)

    activitiesXML = procGetActivities.result

    Initialize = activitiesXML

Exit Function
errorhandler:
    UI.ShowError ("Activityweb.Initialize")

End Function


Public Function getActivityTypes() As String
On Error GoTo errorhandler

    Dim activitytypesXML As String
    
    Dim procGetActivityTypes As LDE.Procedure
    Set procGetActivityTypes = Application.Database.Procedures.Lookup("csp_getActivityTypes", lkLookupProcedureByName)

    procGetActivityTypes.Parameters("@@lang").InputValue = Database.Locale
    Call procGetActivityTypes.Execute(False)

    activitytypesXML = procGetActivityTypes.result

    getActivityTypes = activitytypesXML

Exit Function
errorhandler:
UI.ShowError ("Activityweb.getActivityTypes")

End Function
