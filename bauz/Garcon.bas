Attribute VB_Name = "Garcon"
'===================== SETTINGS ============================
'
'       Change constant below to true if you have activated
'       the "Department" option in the field "visiblefor" and thus
'       have a department table and relation in the garcon-
'       settings table. Othervise False.. ;)
'
Private Const bDepartmentoptionenabled As Boolean = False
Private Const sDepartmentFieldname As String = "department"

Private Const c_IndexValueLocalName = "Huvudlista"
Private Const c_IndexValueName = "index"

Private Const c_OverviewValueLocalName = "Översikt"
Private Const c_OverviewValueName = "overview"

Public Property Get VisibleOnIndexName() As String
    VisibleOnIndexName = c_IndexValueName
End Property
Public Property Get VisibleOnIndexLocalName() As String
    VisibleOnIndexLocalName = c_IndexValueLocalName
End Property

Public Property Get VisibleOnOverviewName() As String
    VisibleOnOverviewName = c_OverviewValueName
End Property
Public Property Get VisibleOnOverviewLocalName() As String
    VisibleOnOverviewLocalName = c_OverviewValueLocalName
End Property

Public Function GetHitCount(ByVal className As String, ByVal filterName As String, ByVal sActiveClass, ByVal lngIdRecord As Long) As Long
On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Dim oFilters As LDE.Filters
    Dim oField As LDE.field
    Dim oClass As LDE.Class
    If sActiveClass = VisibleOnIndexName Then
        If Application.Explorers.Exists(className) Then
            If Application.Explorers(className).Filters.Exists(filterName) Then
                Set oFilter = Application.Explorers(className).Filters(filterName).Clone
                If Not oFilter Is Nothing Then
                    GetHitCount = oFilter.HitCount(Database.Classes(className))
                    Exit Function
                End If
            End If
        End If
    ElseIf sActiveClass = VisibleOnOverviewName Then
        If Application.Explorers(className).Filters.Exists(filterName) Then
            Set oFilter = Application.Explorers(className).Filters(filterName).Clone
            If Not oFilter Is Nothing Then
                GetHitCount = oFilter.HitCount(Database.Classes(className))
                Exit Function
            End If
        End If
    Else
        Set oClass = Application.Database.Classes.Lookup(sActiveClass, lkLookupClassByName)
        If Not oClass Is Nothing Then
            Set oField = oClass.Fields.Lookup(className, lkLookupFieldByName)
            If Not oField Is Nothing Then
               If oField.Type = lkFieldTypeMultiLink Then
                    Set oFilters = Garcon.GetInspectorExplorerFilters(sActiveClass, oField.LinkedField.Class.name)
                    If oFilters.Exists(filterName) Then
                        Set oFilter = oFilters(filterName).Clone
                    End If
               End If
            End If
        End If
        
        If Not oFilter Is Nothing Then
            If Application.Database.Classes.Exists(sActiveClass) Then
                If Application.Database.Classes(sActiveClass).Fields.Exists(className) Then
                    Set oField = Application.Database.Classes(sActiveClass).Fields(className)
                    If oField.Type = lkFieldTypeMultiLink Then
                        Call oFilter.AddCondition(oField.LinkedField.name, lkOpEqual, lngIdRecord)
                        If oFilter.Count > 1 Then
                            Call oFilter.AddOperator(lkOpAnd)
                        End If
                        
                        GetHitCount = oFilter.HitCount(Database.Classes(oField.name))
                        Exit Function
                    End If
                End If
            End If
        End If
    End If
    GetHitCount = -99
Exit Function
ErrorHandler:
    GetHitCount = -99
    Call UI.ShowError("Garcon.GetHitCount")
End Function

Public Sub RefreshWebBar(ByVal sActiveClass As String)
    On Error Resume Next
    If sActiveClass = Garcon.VisibleOnIndexName Then
        Application.WebBar.Refresh
    Else
        Dim oInspector As Lime.Inspector
        For Each oInspector In Application.Inspectors
            If oInspector.Class.name = sActiveClass Then
                If Not oInspector.WebBar Is Nothing Then
                    Call oInspector.WebBar.Refresh
                End If
            End If
        Next
    End If
End Sub

Public Function GetSumField(ByVal className As String, ByVal filterName As String, ByVal fieldName As String, ByVal sActiveClass As String, ByVal lngIdRecord As Long) As String
On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Dim oFilters As LDE.Filters
    Dim oField As LDE.field
    Dim oClass As LDE.Class
    Dim oRecords As New LDE.Records
    Dim oRecord As LDE.Record
    Dim sum As Long
    
    sum = 0
    If sActiveClass = VisibleOnIndexName Then
        If Application.Explorers.Exists(className) Then
            If Application.Explorers(className).Filters.Exists(filterName) Then
                Set oFilter = Application.Explorers(className).Filters(filterName).Clone
                Call oRecords.Open(Database.Classes(className), oFilter)
                For Each oRecord In oRecords
                    If Not VBA.IsNull(oRecord.value(fieldName)) Then
                        sum = sum + oRecord.value(fieldName)
                    End If
                Next oRecord
            End If
        End If
    Else
        Set oClass = Application.Database.Classes.Lookup(sActiveClass, lkLookupClassByName)
        If Not oClass Is Nothing Then
            Set oField = oClass.Fields.Lookup(className, lkLookupFieldByName)
            If Not oField Is Nothing Then
               If oField.Type = lkFieldTypeMultiLink Then
                    Set oFilters = Garcon.GetInspectorExplorerFilters(sActiveClass, oField.LinkedField.Class.name)
                    If oFilters.Exists(filterName) Then
                        Set oFilter = oFilters(filterName).Clone
                    End If
               End If
            End If
        End If
        
        If Not oFilter Is Nothing Then
            Set oFilter = oFilter.Clone
            If Application.Database.Classes.Exists(sActiveClass) Then
                If Application.Database.Classes(sActiveClass).Fields.Exists(className) Then
                    Set oField = Application.Database.Classes(sActiveClass).Fields(className)
                    If oField.Type = lkFieldTypeMultiLink Then
                        Call oFilter.AddCondition(oField.LinkedField.name, lkOpEqual, lngIdRecord)
                        If oFilter.Count > 1 Then
                            Call oFilter.AddOperator(lkOpAnd)
                        End If
                        
                        Call oRecords.Open(Database.Classes(oField.name), oFilter)
                        For Each oRecord In oRecords
                            If Not VBA.IsNull(oRecord.value(fieldName)) Then
                                sum = sum + oRecord.value(fieldName)
                            End If
                        Next oRecord
                    End If
                End If
            End If
        End If
    End If
    GetSumField = CStr(VBA.Format(VBA.CDbl(sum), "#,0"))
Exit Function
ErrorHandler:
    Call UI.ShowError("Garcon.GetHitCount")
End Function

Public Sub ShowFilter(ByVal lngidgarcon_settings As Long)
    On Error GoTo ErrorHandler
    Dim oRecord As New LDE.Record
    Dim sVisibleOn As String
    Dim sExplorer As String
    Dim sFilterName As String
    
    Dim oExplorers As Lime.Explorers
    Dim oExplorer As Lime.Explorer
    
    
    Dim sWarning As String
    
    sWarning = "Garcon served a filter not working!"
    
    Call oRecord.Open(Application.Database.Classes("garconsettings"), lngidgarcon_settings)
    sVisibleOn = oRecord.Text("visibleon")
    sExplorer = oRecord.Text("classname")
    sFilterName = oRecord.Text("filtername")
    If sVisibleOn = VisibleOnIndexName Then
        If Application.Explorers.Exists(sExplorer) Then
            If Application.Explorers(sExplorer).Filters.Exists(sFilterName) Then
                Set oExplorers = Application.Explorers
                Set oExplorer = oExplorers(sExplorer)
            End If
        End If
    Else
        If Not Application.ActiveInspector Is Nothing Then
            If Application.ActiveInspector.Class.name = sVisibleOn Then
                If Application.ActiveInspector.Explorers.Exists(sExplorer) Then
                    Set oExplorers = Application.ActiveInspector.Explorers
                    Set oExplorer = oExplorers(sExplorer)
                End If
            End If
        End If
    End If
    
    If Not oExplorers Is Nothing Then
        If Not oExplorer Is Nothing Then
            If Not oExplorers.GetVisible(oExplorer.name) Then
                Call oExplorers.SetVisible(oExplorer.name, True)
            End If
            Set oExplorers.ActiveExplorer = oExplorer
            If oExplorer.Filters.Exists(sFilterName) Then
                Set oExplorer.ActiveFilter = oExplorer.Filters(sFilterName)
                Call oExplorer.Requery
            End If
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

Public Function FetchFiltersXML(ByVal sActiveClass As String, ByVal lngIdRecord As Long) As String
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
        Call oRecordActiveUser.Open(Application.Database.Classes("coworker"), ActiveUser.Record.id, oActiveUserView)
        lDepartmentRecordID = oRecordActiveUser.value(sDepartmentFieldname)
        
        'FILTER CREATION MADNESS
        Call oFilter.AddCondition("visiblefor", lkOpEqual, Database.Classes("garconsettings").Fields("visiblefor").Options.Lookup("all", lkLookupOptionByKey))
        Call oFilter.AddCondition("visiblefor", lkOpEqual, Database.Classes("garconsettings").Fields("visiblefor").Options.Lookup("me", lkLookupOptionByKey))
        Call oFilter.AddCondition("coworker", lkOpEqual, ActiveUser.Record.id)
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
        Call oFilter.AddCondition("coworker", lkOpEqual, ActiveUser.Record.id)
        Call oFilter.AddOperator(lkOpAnd)
        Call oFilter.AddOperator(lkOpOr)
        Call oFilter.AddCondition("active", lkOpEqual, 1)
        Call oFilter.AddOperator(lkOpAnd)
    End If
    
    Call oFilter.AddCondition("visibleon", lkOpEqual, sActiveClass)
    'Call oFilter.AddCondition("visibleon", lkOpEqual, "") 'If empty should show everywhere
    'Call oFilter.AddOperator(lkOpOr)
    Call oFilter.AddOperator(lkOpAnd)
    
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
                lngValue = VBA.CStr(GetHitCount(oRecord.Text("classname"), oRecord.Text("filtername"), sActiveClass, lngIdRecord))
            ElseIf oRecord.GetOptionKey("operator") = "sum" Then
                lngValue = GetSumField(oRecord.Text("classname"), oRecord.Text("filtername"), oRecord.Text("fieldname"), sActiveClass, lngIdRecord)
            ElseIf oRecord.GetOptionKey("operator") = "link" Then
                lngValue = 0 ' For Link type
            End If
            
            If lngValue >= 0 Then
                If ((lngValue = 0 And oRecord.value("visibleonzero") = 1 Or oRecord.GetOptionKey("operator") = "link") Or (lngValue > 0)) Then
                    Dim sColor As String
                    Dim sValue As String
                    If oRecord.GetOptionKey("operator") = "link" Then
                        sValue = ""
                    Else
                        sValue = VBA.CStr(lngValue)
                    End If
                    sColor = ""
                    Dim colorOption As LDE.Option
                    Set colorOption = oRecord.Options("color").Lookup(oRecord.GetOptionKey("color"), lkLookupOptionByKey)
                    If Not colorOption Is Nothing Then
                        'sColor = FixColorToHexString(colorOption.Attribute("color"))
                        sColor = colorOption.Key
                    End If
                
                    FetchFiltersXML = FetchFiltersXML + "<filter>" _
                        & "<idgarconsettings>" & VBA.CStr(oRecord.id) & "</idgarconsettings>" _
                        & "<explorer>" & oRecord.Text("classname") & "</explorer>" _
                        & "<name>" & oRecord.Text("filtername") & "</name>" _
                        & "<color>" & sColor & "</color>" _
                        & "<size>" & oRecord.GetOptionKey("size") & "</size>" _
                        & "<sortorder>" & VBA.CStr(oRecord.Text("sortorder")) & "</sortorder>" _
                        & "<value>" & sValue & "</value>" _
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

Public Sub SearchIcon()
    On Error GoTo ErrorHandler
    
    Call ActiveInspector.PaneControls.SetValue("searchicon", WebFolder & "lbs.html?ap=garconsearchicon&type=inline")

    Exit Sub
ErrorHandler:
    Call UI.ShowError("Garcon.SearchIcon")
End Sub

Public Function GetFilterCountByType(ByVal oFilters As LDE.Filters, Optional ByVal filterType As FilterTypeEnum = lkFilterTypeDynamic) As Integer
On Error GoTo ErrorHandler
    GetFilterCountByType = 0
    Dim oFilter As LDE.Filter
    For Each oFilter In oFilters
        If oFilter.Type = filterType Then
            GetFilterCountByType = GetFilterCountByType + 1
        End If
    Next
Exit Function
ErrorHandler:
    Call UI.ShowError("Garcon.GetFilterCountByType")
End Function

'fieldTypes as Keys will be checked
Public Function GetFieldCountByTypes(ByVal oFields As LDE.Fields, ByVal fieldTypes As Scripting.Dictionary) As Integer
On Error GoTo ErrorHandler
    GetFieldCountByTypes = 0
    Dim oField As LDE.field
    For Each oField In oFields
        If fieldTypes.Exists(oField.Type) Then
            GetFieldCountByTypes = GetFieldCountByTypes + 1
        End If
    Next
Exit Function
ErrorHandler:
    Call UI.ShowError("Garcon.GetFieldCountByTypes")
End Function

Public Function FindExplorerFieldsByClass(ByVal oClass As LDE.Class) As Collection
On Error GoTo ErrorHandler
    Dim oField As LDE.field
    Dim oFields As New Collection
    
    If Not oClass Is Nothing Then
        For Each oField In oClass.Fields
            If oField.Invisible = lkFieldInvisibleNo Or oField.Invisible = lkFieldInvisibleExplorer Then
                If oField.Type = lkFieldTypeMultiLink Then
                    Call oFields.Add(oField)
                End If
            End If
        Next
    End If
    
    Set FindExplorerFieldsByClass = oFields
Exit Function
ErrorHandler:
    Call UI.ShowError("Garcon.FindExplorerFieldsByClass")
End Function

Public Function GetInspectorExplorerFilters(ByVal InspectorClass As String, ByVal ExplorerClass As String) As LDE.Filters
On Error GoTo ErrorHandler
    Dim oFilters As New LDE.Filters
    Set oFilters.Database = Application.Database
    oFilters.Folder = "Filters\" & VBA.Right("00000000" & VBA.Hex(Application.Database.Classes(InspectorClass).id), 8) & "." & VBA.Right("00000000" & VBA.Hex(Application.Database.Classes(ExplorerClass).id), 8)
    Call oFilters.Refresh
    Set GetInspectorExplorerFilters = oFilters
Exit Function
ErrorHandler:
    Call UI.ShowError("Garcon.GetInspectorExplorerFilters")
End Function

Private Function FixColorToHexString(ByVal colorNr As Long) As String
On Error GoTo ErrorHandler
    Dim str As String
    str = VBA.Hex(colorNr)
    If VBA.Len(str) = 6 Then
        str = VBA.Right(str, 2) & VBA.Mid(str, 3, 2) & VBA.Left(str, 2)
    End If
    FixColorToHexString = str
Exit Function
ErrorHandler:
    Call UI.ShowError("Garcon.ReverseHexString")
End Function


