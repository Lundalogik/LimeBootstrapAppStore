Attribute VB_Name = "Fulltextsearch"
Option Explicit

Public Sub Search(ByVal sFind As String)
    On Error GoTo ErrorHandler
    
    Application.MousePointer = 11
    
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
    Next
    
    oFilter.Name = "Sökt i dokument"
    Call oFilter.AddCondition("iddocument", lkOpIn, oPool, lkConditionTypePool)
    Set ActiveExplorer.ActiveFilter = oFilter
    Call ActiveExplorer.Requery
    
    Application.MousePointer = 0
    
    Exit Sub
ErrorHandler:
    Application.MousePointer = 0
    Call UI.ShowError ("Fulltextsearch.Search")
End Sub

