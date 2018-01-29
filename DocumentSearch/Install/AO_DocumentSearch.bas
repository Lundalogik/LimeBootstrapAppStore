Attribute VB_Name = "AO_DocumentSearch"
Option Explicit

' Called from the Bootstrap app.
' Finds documents using a stored procedure, builds a filter and shows the filter for the user.
Public Sub Search(ByVal sFind As String)
    On Error GoTo ErrorHandler
    
    Application.MousePointer = 11
    
    Debug.Print sFind
    
    ' Call the stored procedure that performs the full-text search.
    Dim oProc As LDE.Procedure
    Dim oXML As New MSXML2.DOMDocument60
    
    Set oProc = Database.Procedures.Lookup("csp_addon_documentsearch_finddocuments", lkLookupProcedureByName)
    oProc.Parameters("@@searchstring").InputValue = sFind
    Call oProc.Execute(False)
    Call oXML.loadXML(oProc.result)
    
    ' Loop over all found documents and add them to a pool
    Dim oPool As New LDE.Pool
    Dim oNode As MSXML2.IXMLDOMNode
    For Each oNode In oXML.selectNodes("//data/documents/d/id")
        Call oPool.Add(VBA.CLng(oNode.Text))
    Next
    
    ' Create a static filter from the pool of id:s
    Dim oFilter As New LDE.filter
    oFilter.Name = Localize.GetText("Addon_DocumentSearch", "i_filterName")
    Call oFilter.AddCondition("iddocument", lkOpIn, oPool, lkConditionTypePool)
    
    ' Load the static filter in the document tab
    Set Application.Explorers("document").ActiveFilter = oFilter
    Call Application.Explorers("document").Requery
    
    ' Show the document tab if not already shown
    Dim oExplorer As Lime.Explorer
    Set oExplorer = ActiveExplorer
    
    If Not oExplorer Is Nothing Then
        If Not oExplorer.Class.Name = "document" Then
            Set Application.Explorers.ActiveExplorer = Application.Explorers("document")
        End If
    End If
    
    Application.MousePointer = 0
    
    Exit Sub
ErrorHandler:
    Application.MousePointer = 0
    Call UI.ShowError(VBE.ActiveCodePane.CodeModule.Name & ".Search")
End Sub


