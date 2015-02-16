Attribute VB_Name = "Garcon"
Public Function GetHitCount(ByVal className As String, ByVal filterName As String) As Long
On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    If Application.Explorers.Exists(className) Then
        If Application.Explorers(className).Filters.Exists(filterName) Then
            Set oFilter = Application.Explorers(className).Filters(filterName).Clone
            If Not oFilter Is Nothing Then
                GetHitCount = oFilter.HitCount(Database.Classes(className))
                Exit Function
            End If
        End If
    End If
    GetHitCount = -99
Exit Function
ErrorHandler:
    GetHitCount = -99
    Call UI.ShowError("Garcon.GetHitCount")
End Function

Public Sub RefreshWebBar()
    On Error Resume Next
    Application.WebBar.Refresh
End Sub

Public Sub ShowFilter(ByVal lngidgarcon_settings As Long)
    On Error GoTo ErrorHandler
    Dim oRecord As New LDE.Record
    Dim sExplorer As String
    Dim sFilterName As String
    
    Dim sWarning As String
    
    sWarning = "Garcon served a filter not working!"
    
    Call oRecord.Open(Application.Database.Classes("garcon_settings"), lngidgarcon_settings)
    sExplorer = oRecord.Text("explorer")
    sFilterName = oRecord.Text("name")
    If Application.Explorers.Exists(sExplorer) Then
        If Application.Explorers(sExplorer).Filters.Exists(sFilterName) Then
            Set Application.Explorers.ActiveExplorer = Application.Explorers(sExplorer)
            Set Application.ActiveExplorer.ActiveFilter = Application.Explorers(sExplorer).Filters(sFilterName)
            Application.ActiveExplorer.Requery
            sWarning = ""
        End If
    End If
    
    If sWarning <> "" Then
        Call Lime.MessageBox(sWarning, VBA.vbExclamation)
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("Garcon.SetFilter")
End Sub


Public Function FetchFiltersXML() As String
On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Dim oRecords As New LDE.Records
    Dim oRecord As New LDE.Record
    Dim oView As New LDE.View
    Dim lngHitcount As Long
    
    Call oFilter.AddCondition("coworker", lkOpEqual, ActiveUser.Record.ID)
    
    Call oRecords.Open(Application.Database.Classes("garcon_settings"), oFilter)
    
    FetchFiltersXML = "<filters>"
    
    If oRecords.Count > 0 Then
        For Each oRecord In oRecords
            lngHitcount = GetHitCount(oRecord.Text("explorer"), oRecord.Text("name"))
            If lngHitcount >= 0 Then
                If ((lngHitcount = 0 And oRecord.Value("visibleonzero") = 1) Or (lngHitcount > 0)) Then
                    FetchFiltersXML = FetchFiltersXML + "<filter>" _
                        & "<idgarcon_settings>" & VBA.CStr(oRecord.ID) & "</idgarcon_settings>" _
                        & "<explorer>" & oRecord.Text("explorer") & "</explorer>" _
                        & "<name>" & oRecord.Text("name") & "</name>" _
                        & "<color>" & oRecord.Text("color") & "</color>" _
                        & "<sortorder>" & VBA.CStr(oRecord.Text("sortorder")) & "</sortorder>" _
                        & "<hitcount>" & VBA.CStr(lngHitcount) & "</hitcount>" _
                        & "<label>" & oRecord.Text("label") & "</label>" _
                        & "<icon>" & oRecord.Text("icon") & "</icon>" _
                        & "</filter>"
                End If
            End If
        Next oRecord
    End If

    FetchFiltersXML = FetchFiltersXML & "</filters>"

Exit Function
ErrorHandler:
    Call UI.ShowError("Garcon.FetchFiltersXML")
End Function

