Attribute VB_Name = "Matrix"
'Custome methods for the Matrix AP

Option Explicit


Public Sub openMatrixPane()
    On Error GoTo ErrorHandler

        If Not Application.Panes.Exists("Matrix") Then
            Call ThisApplication.Panes.Add("Matrix", Database.Classes("company").Icon(lkIconSizeSmall), "file:///" + ThisApplication.WebFolder + "lbs.html?ap=apps/matrix_bs/matrix_bs&type=tab", lkPaneStyleNoToolBar)
        End If
        If Not Application.Panes.ActivePane Is Application.Panes.Item("Matrix") Then
            Set Application.Panes.ActivePane = Application.Panes.Item("Matrix")
        End If
        
        
    Exit Sub
ErrorHandler:
    Call UI.ShowError("Matrix.openMatrixPane")
End Sub



Public Function GetMatrix(Iduser As Long, startdate As Date, enddate As Date) As String
    On Error GoTo ErrorHandler
    
    Dim oProc As LDE.Procedure
    Dim sXml As String
    
    Set oProc = Database.Procedures.Lookup("csp_getmatrix", lkLookupProcedureByName)
    If Not oProc Is Nothing Then
        ' ÄNDRAR VILKEN MEDARBETARE VI KOLLAR PÅ.
        oProc.Parameters("@@idcoworker").InputValue = Iduser
        oProc.Parameters("@@startdate").InputValue = startdate
        oProc.Parameters("@@enddate").InputValue = enddate
        oProc.Execute (False)
        sXml = oProc.Parameters("@@xml").OutputValue
    End If
    
    GetMatrix = sXml
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("Matrix.GetMatrix")
End Function

Public Function GetCoworkers() As String
    On Error GoTo ErrorHandler
    
    Dim oProc As LDE.Procedure
    Dim sXml As String
    
    Set oProc = Database.Procedures.Lookup("csp_getcoworkers", lkLookupProcedureByName)
    If Not oProc Is Nothing Then
        oProc.Execute (False)
        sXml = oProc.Parameters("@@xml").OutputValue
    End If
    
    GetCoworkers = sXml
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("Matrix.GetCoworkers")
End Function


Public Sub SetMatrixFilter(User As Integer, startdate As Date, enddate As Date, classification As String, potential As String)
    On Error GoTo ErrorHandler
    
    Set Application.Explorers.ActiveExplorer = Application.Explorers("history")
    
    Dim oFilter As New LDE.Filter
    
    Call oFilter.AddCondition("coworker", lkOpEqual, User)
    Call oFilter.AddCondition("date", lkOpGreaterOrEqual, startdate)
    Call oFilter.AddOperator(lkOpAnd)
    Call oFilter.AddCondition("date", lkOpLessOrEqual, enddate)
    Call oFilter.AddOperator(lkOpAnd)
    Call oFilter.AddCondition("type", lkOpEqual, Database.Classes("history").Fields("type").Options.Lookup("customervisit", lkLookupOptionByKey))
    Call oFilter.AddOperator(lkOpAnd)
    Call oFilter.AddCondition("company.classification", lkOpEqual, classification)
    Call oFilter.AddOperator(lkOpAnd)
    Call oFilter.AddCondition("company.potential", lkOpEqual, potential)
    Call oFilter.AddOperator(lkOpAnd)
    
    oFilter.name = "Kundbesök för klassifikation " + classification + " och Potential " + potential
    Set Application.ActiveExplorer.ActiveFilter = oFilter
    Application.ActiveExplorer.Requery
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("Matrix.SetMatrixFilter")
End Sub
