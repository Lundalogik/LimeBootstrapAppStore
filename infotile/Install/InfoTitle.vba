Public Function GetInfo(ByVal className As String, ByVal filterName As String) As Integer
On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Set oFilter = Application.Explorers(className).Filters(filterName).Clone
    GetInfo = oFilter.HitCount(Database.Classes(className))
Exit Function
ErrorHandler:
    MsgBox ("Infotile.GetInfo: Filter or Class not found!")
End Function


Public Sub ShowFilter(ByVal className As String, ByVal filterName As String)
    On Error GoTo ErrorHandler
    
    Set Application.Explorers.ActiveExplorer = Application.Explorers(className)
    Set Application.ActiveExplorer.ActiveFilter = Application.Explorers(className).Filters(filterName)
    
    Application.ActiveExplorer.Requery
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("InfoTitle.SetFilter")
End Sub
