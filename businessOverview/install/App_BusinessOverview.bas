Attribute VB_Name = "App_BusinessOverview"
Public Function Initialize() As String
 On Error GoTo errorhandler
    
    Dim BusinessOverviewXML As String
    Dim procGetBusinessOverview As LDE.Procedure
    Set procGetBusinessOverview = Application.Database.Procedures.Lookup("csp_getBusinessOverview", lkLookupProcedureByName)
    
    procGetBusinessOverview.Parameters("@@lang").InputValue = Database.Locale
    procGetBusinessOverview.Parameters("@@idcompany").InputValue = ActiveInspector.Record.ID
    'You can change the number format here
    'Go to https://msdn.microsoft.com/en-us/library/hh441729.aspx for a overview of the different land codes
    procGetBusinessOverview.Parameters("@@moneyFormat").InputValue = "nb"
    
    Call procGetBusinessOverview.Execute(False)
    
    BusinessOverviewXML = procGetBusinessOverview.result
    
    Initialize = BusinessOverviewXML

Exit Function
errorhandler:
    UI.ShowError ("app_BusinessOverview.Initialize")
End Function

Public Function openTab(tabName As String)
    On Error GoTo errorhandler
    Set Application.ActiveInspector.Explorers.ActiveExplorer = Application.ActiveInspector.Explorers(tabName)
    
    Exit Function
errorhandler:
    UI.ShowError ("app_BusinessOverview.openTabs")
End Function
