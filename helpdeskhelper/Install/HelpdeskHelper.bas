Attribute VB_Name = "HelpdeskHelper"
Public Function Count(className As String, filterName As String) As String
    On Error GoTo ErrorHandler
    
    Dim oFilter As New LDE.Filter
    Dim ActiveFilterCount As Integer
    ActiveFilterCount = -1
    
    If Application.Explorers.Exists(className) Then
        If Application.Explorers(className).Filters.Exists(filterName) Then
            Set oFilter = Application.Explorers(className).Filters.Lookup(filterName, lkLookupFilterByName)
            If Not oFilter Is Nothing Then
                Count = oFilter.HitCount(Database.Classes(className))
                If ActiveExplorer.Class.Name = className Then
                    If ActiveExplorer.ActiveFilter.Name = filterName Then
                        ActiveFilterCount = ActiveExplorer.Items.Count
                    'Lime.MessageBox (ActiveFilterCount)
                    End If
                End If
                Count = "{""ActiveFilter"":" + CStr(ActiveFilterCount) + " , ""HitCount"" : " + CStr(Count) + "}"
                Exit Function
            End If
        End If
    End If
    Count = 0
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("HelpdeskHelper.Count")
End Function


Public Sub SetFilter(className As String, filterName As String)
On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    If Application.Explorers.Exists(className) Then
        If Application.Explorers(className).Filters.Exists(filterName) Then
            If Application.Explorers(className).Visible = False Then
                Application.Explorers(className).Visible = True
            End If
            Set oFilter = Application.Explorers(className).Filters.Lookup(filterName, lkLookupFilterByName)
            If Not oFilter Is Nothing Then
                Set Application.Explorers.ActiveExplorer = Application.Explorers(className)
                Set Application.Explorers.ActiveExplorer.ActiveFilter = oFilter
                Call Application.Explorers.ActiveExplorer.Requery
            End If
        End If
    End If
Exit Sub
ErrorHandler:
    Call UI.ShowError("HelpdeskHelper.SetFilter")
End Sub

Public Function ShowApp(groupName As String) As Boolean
On Error GoTo ErrorHandler:
    If Application.ActiveUser.MemberOfGroups.Lookup(groupName, lkLookupGroupByName) Is Nothing Then
        ShowApp = False
    Else
        ShowApp = True
    End If
Exit Function
ErrorHandler:
    Call UI.ShowError("HelpdeskHelper.ShowApp")
End Function
