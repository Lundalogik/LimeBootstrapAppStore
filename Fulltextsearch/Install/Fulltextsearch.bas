Attribute VB_Name = "Fulltextsearch"
Option Explicit

Public Sub Search(ByVal sFind As String)
On Error GoTo ErrorHandler
    Dim oProc As New LDE.Procedure
    Dim sXML As String
    Dim oXML As New MSXML2.DOMDocument60
    Dim oNode As MSXML2.IXMLDOMNode
    Dim oFilter As New LDE.Filter
    Dim oPool As New LDE.Pool
    
    Set oProc = Database.Procedures.Lookup("csp_finddocuments", lkLookupProcedureByName)
        oProc.Parameters("@@searchstring").InputValue = sFind
        Call oProc.Execute(False)
        sXML = oProc.result
        
        Call oXML.loadXML(sXML)
        Dim i As Integer
        i = 0
        For Each oNode In oXML.selectNodes("//data/documents/d/id")
            Call oPool.Add(VBA.CLng(oNode.Text))
            'lb_searchResult.AddItem
            'lb_searchResult.List(i, 0) = oNode.Text
            'i = i + 1
        Next
        
        
        oFilter.Name = "Sökt i dokument"
        Call oFilter.AddCondition("iddocument", lkOpIn, oPool, lkConditionTypePool)
        'Debug.Print oFilter.HitCount(Database.Classes("document"))
        Set ActiveExplorer.ActiveFilter = oFilter
        
        ActiveExplorer.Requery

    
    
    
    
    
Exit Sub
ErrorHandler:
UI.ShowError ("Fulltextsearch.Search")


End Sub

