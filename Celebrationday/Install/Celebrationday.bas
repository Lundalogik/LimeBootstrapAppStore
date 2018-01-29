Attribute VB_Name = "Celebrationday"
Option Explicit

''' GET THE INITIALIZED DATA AND ALSO CALLED WHEN USER CHANGES THE ENDDATE FOR THE PERIOD
Public Function GetCelebrationsPeriodList(ByVal enddate As String, ByVal sp As String, ByVal tablename As String, ByVal celebrationtype As String) As String
    On Error GoTo Errorhandler
    
    Dim oProc As LDE.Procedure
    Dim sXml As String
    

'   In case you want to send to the sql from here if the user is admmin or not. (reset isadmin further down)
'    Dim isadmin As Integer
'    isadmin = 0
'    If ActiveUser.Administrator Then
'        isadmin = 1
'    End If

    Set oProc = Database.Procedures.Lookup(sp, lkLookupProcedureByName)
        
    If Not oProc Is Nothing Then
        oProc.Parameters("@@activecoworker").InputValue = ActiveUser.Record.id
        oProc.Parameters("@@enddate").InputValue = enddate
        oProc.Parameters("@@tablename").InputValue = tablename
        oProc.Parameters("@@type").InputValue = celebrationtype
        
        Call oProc.Execute(False)
        sXml = oProc.Parameters("@@xml").OutputValue
    End If
    
    GetCelebrationsPeriodList = sXml
'    isadmin = 0
    
    Exit Function
Errorhandler:
    Call UI.ShowError("Celebrationday.GetCelebrationsPeriodList")
End Function

''' WHEN THE USER PRESS A PERSON/COWORKER NAME IN THE TABLE
Public Sub OpenInspector(ByVal id As Integer, ByVal Class As String)
    On Error GoTo Errorhandler
    
    Dim oRecord As LDE.Record
    Set oRecord = New LDE.Record
    
    Call oRecord.Open(Database.Classes(Class), id)
    Call Application.OpenInspector(ActiveExplorer, oRecord, lkActivateExisting)
    
    
    Exit Sub
Errorhandler:
    Call UI.ShowError("Celebrationday.OpenPersoncard")
End Sub

''' WHEN THE USER PRESS THE "CREATE SELECTION" BUTTON IN THE ACTIONPAD
Public Sub OpenSelection(ByVal enddate As Date, ByVal tablename As String, ByVal sXml As String)
On Error GoTo Errorhandler

    Dim idcolumn As String
    idcolumn = "id" + tablename
    Dim idPool As New LDE.Pool
    
    Dim oXML As New MSXML2.DOMDocument60
    Dim oRoot As MSXML2.IXMLDOMNode
    Dim oNode As MSXML2.IXMLDOMNode
    Dim iCount As Integer
    

    'Loop through all filternames
    'Look for match. If there is a filtername that starts with "Celebrationday"
    'If there is none, create a new
    'If there is, update the name to "Celebrationday" + todays date + choosen enddate
    'Parse the XML
    If Not oXML.loadXML(sXml) Then
        UI.ShowError ("Celebrationday.OpenSelection")
        Exit Sub
    End If
    
    Set oRoot = oXML.firstChild
    iCount = 0
    For Each oNode In oXML.selectNodes(tablename + "s/" + tablename) 'To match the xml root that comes from the SQL procedure.
        Dim id As Integer
        id = oNode.selectSingleNode(idcolumn).nodeTypedValue
        Call idPool.Add(id)
    Next oNode
    
    Dim oFilters As New LDE.Filters
    Set oFilters = Application.Explorers(tablename).Filters
    Dim oFilterCheck As New LDE.Filter
    Dim oNewFilter As New LDE.Filter
    Dim exists As Boolean
    Dim count As Integer

    exists = False
    
    For Each oFilterCheck In oFilters
        'Update the found filters name
        If VBA.InStr(1, oFilterCheck.Name, "Celebrationday", vbTextCompare) <> 0 Then
            Call oFilterCheck.Clear
            Call oFilterCheck.AddCondition(idcolumn, lkOpIn, idPool)
            oFilterCheck.Name = "Celebrationday (" + VBA.CStr(VBA.Date) + " - " + VBA.CStr(enddate) + ")"
            
            'has to change filters before setting the new filter.
            'so that the name in the filter dropdown field is updated.
            Set Application.Explorers(tablename).ActiveFilter = Nothing
            Set Application.Explorers(tablename).ActiveFilter = Application.Explorers(tablename).Filters(oFilterCheck)
            
            exists = True
            Exit For
        End If
    Next oFilterCheck
    
    'Create a new Celebrationday filter
    If exists = False Then
        Call oNewFilter.AddCondition(idcolumn, lkOpIn, idPool)
        oNewFilter.Name = "Celebrationday (" + VBA.CStr(VBA.Date) + " - " + VBA.CStr(enddate) + ")"
        Call Application.Explorers(tablename).Filters.Add(oNewFilter)
        
        Set Application.Explorers(tablename).ActiveFilter = Application.Explorers(tablename).Filters(oNewFilter)
    End If
    
    'Set the explorer and refresh the page.
    Set Application.Explorers.ActiveExplorer = Application.Explorers(tablename)
    Call Application.Explorers(tablename).Requery
    Call Application.Explorers(tablename).Refresh
    
    Exit Sub
Errorhandler:
    Call UI.ShowError("Celebrationday.OpenSelection")
End Sub
