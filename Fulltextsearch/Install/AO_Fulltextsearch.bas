Attribute VB_Name = "AO_fulltextsearch"
Option Explicit

Public Sub Search(ByVal sFind As String)
    On Error GoTo ErrorHandler
    
    Application.MousePointer = 11
    
    Dim oProc As New LDE.Procedure
    'Dim sXML As String
    Dim oXML As New MSXML2.DOMDocument60
    Dim oNode As MSXML2.IXMLDOMNode
    Dim oFilter As New LDE.filter
    Dim oPool As New LDE.Pool
    
    Set oProc = Database.Procedures.Lookup("csp_addon_fulltextsearch_finddocuments", lkLookupProcedureByName)
    oProc.Parameters("@@searchstring").InputValue = sFind
    Call oProc.Execute(False)
    Call oXML.loadXML(oProc.result)
    
    For Each oNode In oXML.selectNodes("//data/documents/d/id")
        Call oPool.Add(VBA.CLng(oNode.Text))
    Next
    
    oFilter.name = "Sökt i dokument"
    Call oFilter.AddCondition("iddocument", lkOpIn, oPool, lkConditionTypePool)
    Set ActiveExplorer.ActiveFilter = oFilter
    Call ActiveExplorer.Requery
    
    Application.MousePointer = 0
    
    Exit Sub
ErrorHandler:
    Application.MousePointer = 0
    Call UI.ShowError(VBE.ActiveCodePane.CodeModule.name & ".Search")
End Sub

