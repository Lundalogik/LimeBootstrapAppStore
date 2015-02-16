Attribute VB_Name = "Superinfotile"
Public Function GetInfo(ByVal className As String, ByVal filterName As String) As Integer
On Error GoTo errorhandler
    Dim oFilter As New LDE.Filter
    Set oFilter = Application.Explorers(className).Filters(filterName).Clone
    GetInfo = oFilter.HitCount(Database.Classes(className))
Exit Function
errorhandler:
    MsgBox ("InfoTile.GetInfo: Filter or Class not found!")
End Function


Public Sub ShowFilter(ByVal className As String, ByVal filterName As String)
    On Error GoTo errorhandler
    
    Set Application.Explorers.ActiveExplorer = Application.Explorers(className)
    Set Application.ActiveExplorer.ActiveFilter = Application.Explorers(className).Filters(filterName)
    
    Application.ActiveExplorer.Requery
    
    Exit Sub
errorhandler:
    Call UI.ShowError("InfoTile.SetFilter")
End Sub

Public Function SaveInfotiles(infotileJson As String)
    On Error GoTo errorhandler
     Dim oRecord As New LDE.Record
     Dim oView As New LDE.View
     Dim oInspector As New Lime.Inspector
     
     Call oView.Add("coworker")
     Call oView.Add("superinfotiles")
     
     oRecord.Open Database.Classes("coworker"), ActiveUser.Record.ID, oView
     oRecord.Value("superinfotiles") = infotileJson
     oRecord.Update
     
    Exit Function
errorhandler:
    
    Call UI.ShowError("InfoTile.SaveInfotiles")
End Function

Public Function LoadInfoTiles() As String
    On Error GoTo errorhandler
     Dim oRecord As New LDE.Record
     Dim oView As New LDE.View
     Dim oInspector As New Lime.Inspector
     Dim sSettings As String
     
     Call oView.Add("coworker")
     Call oView.Add("superinfotiles")
     
     oRecord.Open Database.Classes("coworker"), ActiveUser.Record.ID, oView
     LoadInfoTiles = oRecord.Value("superinfotiles")
     
    Exit Function
errorhandler:
    
    Call UI.ShowError("InfoTile.LoadFromCoworker")
End Function

Public Function LoadClasses() As String
On Error GoTo errorhandler
Dim oClass As New LDE.Class
    Dim tmp As String
    
    
    For Each oClass In Database.Classes
        If tmp = "" Then
            tmp = oClass.Name
        Else
            tmp = tmp & ";" & oClass.Name
        End If
    Next oClass
 
    LoadClasses = tmp
    
Exit Function
errorhandler:
    Call UI.ShowError("infotiles.LoadClasses")
End Function

Public Function LoadFilters(ByVal Class As String) As String
On Error GoTo errorhandler
Dim oClass As New LDE.Class
Dim oFilter As New LDE.Filter

Dim tmp As String

For Each oFilter In Database.Classes(Class).Filters
    If tmp = "" Then
        tmp = oFilter.Name
    Else
        tmp = tmp & ";" & oFilter.Name
    End If
    
Next oFilter
    LoadFilters = tmp

Exit Function
errorhandler:
    Call UI.ShowError("infotiles.LoadFilters")
End Function
