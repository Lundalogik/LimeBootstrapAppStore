Attribute VB_Name = "infotile"
Public Function GetInfo(ByVal className As String, ByVal filterName As String) As Integer
On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Set oFilter = Application.Explorers(className).Filters(filterName).Clone
    GetInfo = oFilter.HitCount(Database.Classes(className))
Exit Function
ErrorHandler:
    Call UI.ShowError("InfoTile.GetInfo")
End Function


Public Sub ShowFilter(ByVal className As String, ByVal filterName As String)
    On Error GoTo ErrorHandler
    
    Set Application.Explorers.ActiveExplorer = Application.Explorers(className)
    Set Application.ActiveExplorer.ActiveFilter = Application.Explorers(className).Filters(filterName)
    
    Application.ActiveExplorer.Requery
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("InfoTile.SetFilter")
End Sub

