Attribute VB_Name = "InfoTile"
'===================== SETTINGS ============================
'
'       Change constant below to true if you have activated
'       the "Department" option in the field "visiblefor" and thus
'       have a department table and relation in the InfoTile 
'       settings table. Othervise False.. ;)
'===================== SETTINGS ============================
Private Const bDepartmentoptionenabled As Boolean = True
Public Const sDepartmentFieldname As String = "department" ' This must be the same on InfoTile and coworker

Private Const c_IndexValueLocalName = "Huvudlista"
Private Const c_IndexValueName = "index"

Public Property Get VisibleOnIndexName() As String
    VisibleOnIndexName = c_IndexValueName
End Property
Public Property Get VisibleOnIndexLocalName() As String
    VisibleOnIndexLocalName = c_IndexValueLocalName
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
    Else
        Set oClass = Application.Database.Classes.Lookup(sActiveClass, lkLookupClassByName)
        If Not oClass Is Nothing Then
            Set oField = oClass.Fields.Lookup(className, lkLookupFieldByName)
            If Not oField Is Nothing Then
               If oField.Type = lkFieldTypeMultiLink Then
                    Set oFilters = InfoTile.GetInspectorExplorerFilters(sActiveClass, oField.LinkedField.Class.Name)
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
                        Call oFilter.AddCondition(oField.LinkedField.Name, lkOpEqual, lngIdRecord)
                        If oFilter.Count > 1 Then
                            Call oFilter.AddOperator(lkOpAnd)
                        End If
                        
                        GetHitCount = oFilter.HitCount(Database.Classes(oField.Name))
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
    Call UI.ShowError("InfoTile.GetHitCount")
End Function

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
                    If Not VBA.IsNull(oRecord.Value(fieldName)) Then
                        sum = sum + oRecord.Value(fieldName)
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
                    Set oFilters = InfoTile.GetInspectorExplorerFilters(sActiveClass, oField.LinkedField.Class.Name)
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
                        Call oFilter.AddCondition(oField.LinkedField.Name, lkOpEqual, lngIdRecord)
                        If oFilter.Count > 1 Then
                            Call oFilter.AddOperator(lkOpAnd)
                        End If
                        
                        Call oRecords.Open(Database.Classes(oField.Name), oFilter)
                        For Each oRecord In oRecords
                            If Not VBA.IsNull(oRecord.Value(fieldName)) Then
                                sum = sum + oRecord.Value(fieldName)
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
    Call UI.ShowError("InfoTile.GetHitCount")
End Function

Public Sub ShowFilter(ByVal lngidinfotile As Long)
    On Error GoTo ErrorHandler
    Dim oRecord As New LDE.Record
    Dim sVisibleOn As String
    Dim sExplorer As String
    Dim sFilterName As String
    
    Dim oExplorers As Lime.Explorers
    Dim oExplorer As Lime.Explorer
    
    
    Dim sWarning As String
    Dim sOperatorKey As String
    
    sWarning = "InfoTile served a filter not working!"
    
    Call oRecord.Open(Application.Database.Classes("infotile"), lngidinfotile)
    sOperatorKey = oRecord.Fields("operator").Options.Lookup(oRecord("operator"), lkLookupOptionByValue).Key
    If sOperatorKey <> "field" Then
    
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
                If Application.ActiveInspector.Class.Name = sVisibleOn Then
                    If Application.ActiveInspector.Explorers.Exists(sExplorer) Then
                        Set oExplorers = Application.ActiveInspector.Explorers
                        Set oExplorer = oExplorers(sExplorer)
                    End If
                End If
            End If
        End If
        
        If Not oExplorers Is Nothing Then
            If Not oExplorer Is Nothing Then
                If Not oExplorers.GetVisible(oExplorer.Name) Then
                    Call oExplorers.SetVisible(oExplorer.Name, True)
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
    Else ' Operator is field
        ' Do nothing?
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("InfoTile.SetFilter")
End Sub

Public Function FetchFiltersXML(ByVal sActiveClass As String, ByVal lngIdRecord As Long) As String
On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Dim oRecords As New LDE.Records
    Dim oRecord As New LDE.Record
    Dim oView As New LDE.View
    Dim sValue As String
    Dim lngValue As Long
    Dim bShowInfoTileItem As Boolean
    Dim oActiveRecord As LDE.Record
    Dim lngActiveCoworkerId As Variant ' Long
    
    If Not ActiveUser.Record Is Nothing Then
        lngActiveCoworkerId = ActiveUser.Record.ID
    Else
        lngActiveCoworkerId = Null
    End If
    
    If bDepartmentoptionenabled Then
            
        Dim lDepartmentRecordID As Variant
        Dim oRecordActiveUser As New LDE.Record
        Dim oActiveUserView As New LDE.View
        
        If VBA.IsNull(lngActiveCoworkerId) = False Then
            Call oActiveUserView.Add(sDepartmentFieldname)
            Call oRecordActiveUser.Open(Application.Database.Classes("coworker"), lngActiveCoworkerId, oActiveUserView)
            lDepartmentRecordID = oRecordActiveUser.Value(sDepartmentFieldname)
        Else
            lDepartmentRecordID = Null
        End If
        
        'FILTER CREATION MADNESS
        Call oFilter.AddCondition("visiblefor", lkOpEqual, Database.Classes("infotile").Fields("visiblefor").Options.Lookup("all", lkLookupOptionByKey))
        Call oFilter.AddCondition("visiblefor", lkOpEqual, Database.Classes("infotile").Fields("visiblefor").Options.Lookup("me", lkLookupOptionByKey))
        Call oFilter.AddCondition("coworker", lkOpEqual, lngActiveCoworkerId)
        Call oFilter.AddOperator(lkOpAnd)
        Call oFilter.AddOperator(lkOpOr)
        Call oFilter.AddCondition("visiblefor", lkOpEqual, Database.Classes("infotile").Fields("visiblefor").Options.Lookup("department", lkLookupOptionByKey))
        Call oFilter.AddCondition(sDepartmentFieldname, lkOpEqual, lDepartmentRecordID)
        Call oFilter.AddOperator(lkOpAnd)
        Call oFilter.AddOperator(lkOpOr)
        Call oFilter.AddCondition("active", lkOpEqual, 1)
        Call oFilter.AddOperator(lkOpAnd)

'        Dim d As New Lime.Dialog
'        d.Type = lkDialogFilter                                        '===== > Dessa 5 rader kan avkommenteras för att testa filtret.
'        d.Property("filter") = oFilter                               ' <---make sure you have "Dim oFilter as New LDE.Filter"
'        d.Property("class") = Classes("infotile")               '  <---change the class "offer" to your table/class in question!
'        Call d.show

    Else
        Call oFilter.AddCondition("visiblefor", lkOpEqual, Database.Classes("infotile").Fields("visiblefor").Options.Lookup("all", lkLookupOptionByKey))
        Call oFilter.AddCondition("visiblefor", lkOpEqual, Database.Classes("infotile").Fields("visiblefor").Options.Lookup("me", lkLookupOptionByKey))
        Call oFilter.AddCondition("coworker", lkOpEqual, lngActiveCoworkerId)
        Call oFilter.AddOperator(lkOpAnd)
        Call oFilter.AddOperator(lkOpOr)
        Call oFilter.AddCondition("active", lkOpEqual, 1)
        Call oFilter.AddOperator(lkOpAnd)
    End If
    
    Call oFilter.AddCondition("visibleon", lkOpEqual, sActiveClass)
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
    
    Call oRecords.Open(Application.Database.Classes("infotile"), oFilter, oView)
    
    FetchFiltersXML = "<filters>"
    
    If oRecords.Count > 0 Then
        For Each oRecord In oRecords
            Select Case oRecord.GetOptionKey("operator")
                Case "count"
                    sValue = VBA.CStr(GetHitCount(oRecord.Text("classname"), oRecord.Text("filtername"), sActiveClass, lngIdRecord))
                Case "sum"
                    sValue = GetSumField(oRecord.Text("classname"), oRecord.Text("filtername"), oRecord.Text("fieldname"), sActiveClass, lngIdRecord)
                Case "link"
                    sValue = 0 ' For Link type
                Case "field"
                    If lngIdRecord > 0 Then
                        If oActiveRecord Is Nothing Then
                            If Not Application.ActiveInspector Is Nothing Then
                                Set oActiveRecord = Application.ActiveInspector.Record
                            End If
                        End If

                        If oActiveRecord Is Nothing Then
                            Set oActiveRecord = New LDE.Record
                            Call oActiveRecord.Open(Application.Database.Classes(sActiveClass), lngIdRecord)
                        End If

                        If Not oActiveRecord Is Nothing Then
                            If oActiveRecord.Class.Name = sActiveClass And oActiveRecord.ID = lngIdRecord Then
                                If oActiveRecord.Fields.Exists(oRecord.Text("fieldname")) Then
                                    sValue = oActiveRecord.Text(oRecord.Text("fieldname"))
                                Else
                                    Call Lime.MessageBox("field: """ & oRecord.Text("fieldname") & """ does not exist on card: """ & sActiveClass & """")
                                End If
                            End If
                        End If

                    End If
            End Select

            bShowInfoTileItem = False
            If VBA.IsNumeric(sValue) Then
                lngValue = VBA.CLng(sValue)
                If lngValue >= 0 Then
                    If ((lngValue = 0 And oRecord.Value("visibleonzero") = 1 Or oRecord.GetOptionKey("operator") = "link") Or (lngValue > 0)) Then
                        bShowInfoTileItem = True
                    End If
                End If
            ElseIf oRecord.GetOptionKey("operator") = "field" Then
                bShowInfoTileItem = True
            End If

            If bShowInfoTileItem = True Then
                Dim sColor As String
                If oRecord.GetOptionKey("operator") = "link" Then
                    sValue = ""
                End If
                sColor = ""
                Dim colorOption As LDE.Option
                Set colorOption = oRecord.Options("color").Lookup(oRecord.GetOptionKey("color"), lkLookupOptionByKey)
                If Not colorOption Is Nothing Then
                    'sColor = FixColorToHexString(colorOption.Attribute("color"))
                    sColor = colorOption.Key
                End If
            
                FetchFiltersXML = FetchFiltersXML + "<filter>" _
                    & "<idinfotile><![CDATA[" & VBA.CStr(oRecord.ID) & "]]></idinfotile>" _
                    & "<explorer><![CDATA[" & oRecord.Text("classname") & "]]></explorer>" _
                    & "<name><![CDATA[" & oRecord.Text("filtername") & "]]></name>" _
                    & "<color><![CDATA[" & sColor & "]]></color>" _
                    & "<size><![CDATA[" & oRecord.GetOptionKey("size") & "]]></size>" _
                    & "<sortorder><![CDATA[" & VBA.CStr(oRecord.Text("sortorder")) & "]]></sortorder>" _
                    & "<value><![CDATA[" & sValue & "]]></value>" _
                    & "<label><![CDATA[" & oRecord.Text("label") & "]]></label>" _
                    & "<icon><![CDATA[" & oRecord.Text("icon") & "]]></icon>" _
                    & "</filter>"
            End If
        Next oRecord
    End If

    FetchFiltersXML = FetchFiltersXML & "</filters>"

Exit Function
ErrorHandler:
    Call UI.ShowError("InfoTile.FetchFiltersXML")
End Function

Public Sub SearchIcon()
    On Error GoTo ErrorHandler
    
    Call ActiveInspector.PaneControls.SetValue("searchicon", WebFolder & "lbs.html?ap=infotilesearchicon&type=inline")

    Exit Sub
ErrorHandler:
    Call UI.ShowError("InfoTile.SearchIcon")
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
    Call UI.ShowError("InfoTile.GetFilterCountByType")
End Function

'fieldTypes as Keys will be checked
Public Function GetFieldCountByTypes(ByVal oFields As LDE.Fields, ByVal fieldTypes As Scripting.Dictionary) As Integer
On Error GoTo ErrorHandler
    GetFieldCountByTypes = 0
    Dim oField As LDE.field
    For Each oField In oFields
        If fieldTypes.Exists(oField.Type) Or fieldTypes.Count = 0 Then
            GetFieldCountByTypes = GetFieldCountByTypes + 1
        End If
    Next
Exit Function
ErrorHandler:
    Call UI.ShowError("InfoTile.GetFieldCountByTypes")
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
    Call UI.ShowError("InfoTile.FindExplorerFieldsByClass")
End Function

Public Function GetInspectorExplorerFilters(ByVal InspectorClass As String, ByVal ExplorerClass As String) As LDE.Filters
On Error GoTo ErrorHandler
    Dim oFilters As New LDE.Filters
    Set oFilters.Database = Application.Database
    oFilters.Folder = "Filters\" & VBA.Right("00000000" & VBA.Hex(Application.Database.Classes(InspectorClass).ID), 8) & "." & VBA.Right("00000000" & VBA.Hex(Application.Database.Classes(ExplorerClass).ID), 8)
    Call oFilters.Refresh
    Set GetInspectorExplorerFilters = oFilters
Exit Function
ErrorHandler:
    Call UI.ShowError("InfoTile.GetInspectorExplorerFilters")
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
    Call UI.ShowError("InfoTile.ReverseHexString")
End Function

'------------------------------------------
'===============INSTALLER==================
'------------------------------------------
Public Sub Install()
On Error GoTo ErrorHandler
    Dim sOwner As String
    sOwner = "InfoTile"

    Call AddOrCheckLocalize( _
        sOwner, _
        "no_data", _
        "Translation for " & sOwner, _
        "No data for InfoTile", _
        "Ingen data för InfoTile", _
        "No data for InfoTile", _
        "No data for InfoTile" _
    )
    
Exit Sub
ErrorHandler:
    Call UI.ShowError("InfoTile.Install")
End Sub


Private Function AddOrCheckLocalize(sOwner As String, sCode As String, sDescription As String, sEN_US As String, sSV As String, sNO As String, sFI As String) As Boolean
    On Error GoTo ErrorHandler:
    Dim oFilter As New LDE.Filter
    Dim oRecs As New LDE.Records
    
    Call oFilter.AddCondition("owner", lkOpEqual, sOwner)
    Call oFilter.AddCondition("code", lkOpEqual, sCode)
    oFilter.AddOperator lkOpAnd
    
    If oFilter.HitCount(Database.Classes("localize")) = 0 Then
        Debug.Print ("Localization " & sOwner & "." & sCode & " not found, creating new!")
        Dim oRec As New LDE.Record
        Call oRec.Open(Database.Classes("localize"))
        oRec.Value("owner") = sOwner
        oRec.Value("code") = sCode
        oRec.Value("context") = sDescription
        oRec.Value("sv") = sSV
        oRec.Value("en_us") = sEN_US
        oRec.Value("no") = sNO
        oRec.Value("fi") = sFI
        Call oRec.Update
    ElseIf oFilter.HitCount(Database.Classes("localize")) = 1 Then
    Debug.Print ("Updating localization " & sOwner & "." & sCode)
        Call oRecs.Open(Database.Classes("localize"), oFilter)
        oRecs(1).Value("owner") = sOwner
        oRecs(1).Value("code") = sCode
        oRecs(1).Value("context") = sDescription
        oRecs(1).Value("sv") = sSV
        oRecs(1).Value("en_us") = sEN_US
        oRecs(1).Value("no") = sNO
        oRecs(1).Value("fi") = sFI
        Call oRecs.Update
        
    Else
        Call MsgBox("There are multiple copies of " & sOwner & "." & sCode & "  which is bad! Fix it", vbCritical, "To many translations makes Jack a dull boy")
    End If
    
    Set Localize.dicLookup = Nothing
    AddOrCheckLocalize = True
    Exit Function
ErrorHandler:
    Debug.Print ("Error while validating or adding Localize")
    AddOrCheckLocalize = False
End Function

