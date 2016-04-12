'===================== SETTINGS ============================
'
'       Change constant below to true if you have activated
'       the "Department" option in the field "visiblefor" and thus
'       have a department table and relation in the garcon-
'       settings table. Othervise False.. ;)
'
Private Const bDepartmentoptionenabled As Boolean = True
Private Const sDepartmentFieldname As String = "department"

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
    
    Call oRecord.Open(Application.Database.Classes("garconsettings"), lngidgarcon_settings)
    sExplorer = oRecord.Text("classname")
    sFilterName = oRecord.Text("filtername")
    If Application.Explorers.Exists(sExplorer) Then
        If Application.Explorers(sExplorer).Filters.Exists(sFilterName) Then
            If Not Application.Explorers.GetVisible(sExplorer) Then
                Call Application.Explorers.SetVisible(sExplorer, True)
            End If
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


Public Function GetSumField(ByVal className As String, ByVal filterName As String, ByVal fieldName As String) As String
On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Dim oRecords As New LDE.Records
    Dim oRecord As LDE.Record
    Dim sum As Long
    
    sum = 0
    If Application.Explorers.Exists(className) Then
        If Application.Explorers(className).Filters.Exists(filterName) Then
            Set oFilter = Application.Explorers(className).Filters(filterName).Clone
            Call oRecords.Open(Database.Classes(className), oFilter)
            For Each oRecord In oRecords
                If Not VBA.IsNull(oRecord.Value(fieldName)) Then
                    sum = sum + oRecord.Value(fieldName)
                End If
            Next oRecord
        End If
    End If
    GetSumField = CStr(VBA.Format(VBA.CDbl(sum), "#,0"))
Exit Function
ErrorHandler:
    Call UI.ShowError("Garcon.GetHitCount")
End Function

Public Function FetchFiltersXML() As String
On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Dim oRecords As New LDE.Records
    Dim oRecord As New LDE.Record
    Dim oView As New LDE.View
    Dim lngValue As String
    
    If bDepartmentoptionenabled Then
            
        Dim lDepartmentRecordID As Long
        Dim oRecordActiveUser As New LDE.Record
        Dim oActiveUserView As New LDE.View
        
        Call oActiveUserView.Add(sDepartmentFieldname)
        Call oRecordActiveUser.Open(Application.Database.Classes("coworker"), ActiveUser.Record.ID, oActiveUserView)
        
        If IsNull(oRecordActiveUser.Value(sDepartmentFieldname)) = False Then
            lDepartmentRecordID = oRecordActiveUser.Value(sDepartmentFieldname)
        Else
            lDepartmentRecordID = 0
        End If
            
        'FILTER CREATION MADNESS
        Call oFilter.AddCondition("visiblefor", lkOpEqual, Database.Classes("garconsettings").Fields("visiblefor").Options.Lookup("all", lkLookupOptionByKey))
        Call oFilter.AddCondition("visiblefor", lkOpEqual, Database.Classes("garconsettings").Fields("visiblefor").Options.Lookup("me", lkLookupOptionByKey))
        Call oFilter.AddCondition("coworker", lkOpEqual, ActiveUser.Record.ID)
        Call oFilter.AddOperator(lkOpAnd)
        Call oFilter.AddOperator(lkOpOr)
        Call oFilter.AddCondition("visiblefor", lkOpEqual, Database.Classes("garconsettings").Fields("visiblefor").Options.Lookup("department", lkLookupOptionByKey))
        Call oFilter.AddCondition("department", lkOpEqual, lDepartmentRecordID)
        Call oFilter.AddOperator(lkOpAnd)
        Call oFilter.AddOperator(lkOpOr)
        Call oFilter.AddCondition("active", lkOpEqual, 1)
        Call oFilter.AddOperator(lkOpAnd)

'        Dim d As New Lime.Dialog
'        d.Type = lkDialogFilter                                        '===== > Dessa 5 rader kan avkommenteras för att testa filtret.
'        d.Property("filter") = oFilter                               ' <---make sure you have "Dim oFilter as New LDE.Filter"
'        d.Property("class") = Classes("garconsettings")               '  <---change the class "offer" to your table/class in question!
'        Call d.show
        
    Else
        Call oFilter.AddCondition("visiblefor", lkOpEqual, Database.Classes("garconsettings").Fields("visiblefor").Options.Lookup("all", lkLookupOptionByKey))
        Call oFilter.AddCondition("visiblefor", lkOpEqual, Database.Classes("garconsettings").Fields("visiblefor").Options.Lookup("me", lkLookupOptionByKey))
        Call oFilter.AddCondition("coworker", lkOpEqual, ActiveUser.Record.ID)
        Call oFilter.AddOperator(lkOpAnd)
        Call oFilter.AddOperator(lkOpOr)
        Call oFilter.AddCondition("active", lkOpEqual, 1)
        Call oFilter.AddOperator(lkOpAnd)
    End If

    Call oView.Add("sortorder", lkSortAscending)
    Call oView.Add("classname")
    Call oView.Add("filtername")
    Call oView.Add("visibleonzero")
    Call oView.Add("color")
    Call oView.Add("label")
    Call oView.Add("icon")
    Call oView.Add("size")
    Call oView.Add("fieldname")
    Call oView.Add("operator")
    
    Call oRecords.Open(Application.Database.Classes("garconsettings"), oFilter, oView)
    
    FetchFiltersXML = "<filters>"
    
    If oRecords.Count > 0 Then
        For Each oRecord In oRecords
            If oRecord.GetOptionKey("operator") = "count" Then
                lngValue = VBA.CStr(GetHitCount(oRecord.Text("classname"), oRecord.Text("filtername")))
            ElseIf oRecord.GetOptionKey("operator") = "sum" Then
                lngValue = GetSumField(oRecord.Text("classname"), oRecord.Text("filtername"), oRecord.Text("fieldname"))
            End If
            If lngValue >= 0 Then
                If ((lngValue = 0 And oRecord.Value("visibleonzero") = 1) Or (lngValue > 0)) Then
                    FetchFiltersXML = FetchFiltersXML + "<filter>" _
                        & "<idgarconsettings>" & VBA.CStr(oRecord.ID) & "</idgarconsettings>" _
                        & "<explorer>" & oRecord.Text("classname") & "</explorer>" _
                        & "<name>" & oRecord.Text("filtername") & "</name>" _
                        & "<color>" & oRecord.GetOptionKey("color") & "</color>" _
                        & "<size>" & oRecord.GetOptionKey("size") & "</size>" _
                        & "<sortorder>" & VBA.CStr(oRecord.Text("sortorder")) & "</sortorder>" _
                        & "<value>" & lngValue & "</value>" _
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

Public Sub TranslateToDbClassname()
    On Error GoTo ErrorHandler
    
    Dim cResult As New LDE.Class
    Dim sClassname As String
    
    sClassname = VBA.Trim(ActiveControls.GetValue("classlocalname"))
    
    Set cResult = Application.Database.Classes.Lookup(sClassname, lkLookupClassByLocalName)
    
    If Not cResult Is Nothing Then
        Call ActiveControls.SetValue("classname", cResult.Name)
    Else
        Call Lime.MessageBox("Det finns ingen flik med det namnet, försök igen!", vbOKOnly)
    End If
        
    Set cResult = Nothing
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("Garcon.TranslateToDbClassname")
End Sub

Public Sub TranslateToDbFieldname()
    On Error GoTo ErrorHandler
    
    Dim fResult As New LDE.field
    Dim sFieldname As String
    
    sFieldname = VBA.Trim(ActiveControls.GetValue("fieldlocalname"))
    
    Set fResult = Application.Database.Classes(ActiveControls.GetText("classname")).Fields.Lookup(sFieldname, lkLookupFieldByLocalName)
    
    If Not fResult Is Nothing Then
        If Not fResult.Name = "" Then
            If (fResult.DataType = lkDataTypeDouble Or fResult.DataType = lkDataTypeCurrency Or fResult.DataType = lkDataTypeLong) Then
                Call ActiveControls.SetValue("fieldname", fResult.Name)
            Else
                Call Lime.MessageBox("Fältet du angivit är inte ett heltal- eller decimaltalsfält och går inte att använda för summering!", vbOKOnly)
            End If
        Else
            Call Lime.MessageBox("Det finns inget fält med det namnet på angivet objekt/flik, försök igen!", vbOKOnly)
        End If
    Else
        Call Lime.MessageBox("Det finns inget fält med det namnet på angivet objekt/flik, försök igen!", vbOKOnly)
    End If
        
        
    Set fResult = Nothing
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("Garcon.TranslateToDbFieldname")
End Sub
Public Sub SearchIcon()
    On Error GoTo ErrorHandler
    
    Call ActiveInspector.PaneControls.SetValue("searchicon", WebFolder & "lbs.html?ap=garconsearchicon&type=inline")

    Exit Sub
ErrorHandler:
    Call UI.ShowError("Garcon.SearchIcon")
End Sub
