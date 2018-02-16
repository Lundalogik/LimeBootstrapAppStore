Attribute VB_Name = "InfoTiles"
'===================== SETTINGS ============================
'
'       Change constant below to true if you have activated
'       the "Department" option in the field "visiblefor" and thus
'       have a department table and relation in the InfoTiles
'       settings table. Othervise False.. ;)
'===================== SETTINGS ============================
Private Const bDepartmentoptionenabled As Boolean = False
Public Const sDepartmentFieldname As String = "department" ' This must be the same on InfoTiles and coworker

Private Const c_IndexValueLocalName = "Huvudlista"
Private Const c_IndexValueName = "index"

Public Property Get VisibleOnIndexName() As String
    VisibleOnIndexName = c_IndexValueName
End Property
Public Property Get VisibleOnIndexLocalName() As String
    VisibleOnIndexLocalName = c_IndexValueLocalName
End Property
' ##SUMMARY Calculates the count for the infotiles based on the specified filter
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
                    Set oFilters = InfoTiles.GetInspectorExplorerFilters(sActiveClass, oField.LinkedField.Class.Name)
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
    Call UI.ShowError("InfoTiles.GetHitCount")
End Function
' ##SUMMARY Calculates the sum for the infotilesbased on the specified filter
Public Function GetSumField(ByVal className As String, ByVal filterName As String, ByVal fieldName As String, ByVal sActiveClass As String, ByVal lngIdRecord As Long) As String
On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Dim oFilters As LDE.Filters
    Dim oField As LDE.field
    Dim oClass As LDE.Class
    Dim oRecords As New LDE.Records
    Dim oRecord As LDE.record
    Dim vSum As Variant
    Dim sReturnValue As String
    
    vSum = 0
    If sActiveClass = VisibleOnIndexName Then
        If Application.Explorers.Exists(className) Then
            If Application.Explorers(className).Filters.Exists(filterName) Then
                Set oFilter = Application.Explorers(className).Filters(filterName).Clone
                Call oRecords.Open(Database.Classes(className), oFilter)
                For Each oRecord In oRecords
                    If Not VBA.IsNull(oRecord.Value(fieldName)) Then
                        vSum = vSum + oRecord.Value(fieldName)
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
                    Set oFilters = InfoTiles.GetInspectorExplorerFilters(sActiveClass, oField.LinkedField.Class.Name)
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
                                vSum = vSum + oRecord.Value(fieldName)
                            End If
                        Next oRecord
                    End If
                End If
            End If
        End If
    End If
        
    Select Case VBA.TypeName(vSum)
        Case "Double"
            If InfoTiles.GetFractionalPart(vSum) = 0 Then
                sReturnValue = VBA.CStr(VBA.FormatNumber(vSum, 0))
            Else
                sReturnValue = VBA.CStr(VBA.FormatNumber(vSum, 2))
            End If
        Case Else
            If VBA.IsNumeric(vSum) Then
                sReturnValue = VBA.CStr(VBA.FormatNumber(vSum, 0))
            Else
                sReturnValue = VBA.CStr(vSum)
            End If
    End Select
    
    GetSumField = sReturnValue

Exit Function
ErrorHandler:
    Call UI.ShowError("InfoTiles.GetSumField")
End Function

Private Function GetFractionalPart(ByVal vValue As Double) As Double
On Error GoTo ErrorHandler
    GetFractionalPart = vValue - VBA.Fix(vValue)
Exit Function
ErrorHandler:
    Call UI.ShowError("InfoTiles.GetFractionalPart")
End Function

' ##SUMMARY Is used to show the filter
Public Sub ShowFilter(ByVal lngidinfotiles As Long)
    On Error GoTo ErrorHandler
    Dim oRecord As New LDE.Record
    Dim sVisibleOn As String
    Dim sExplorer As String
    Dim sFiltername As String
    
    Dim oExplorers As Lime.Explorers
    Dim oExplorer As Lime.Explorer
    
    
    Dim sWarning As String
    Dim sOperatorKey As String
    
    sWarning = "InfoTiles served a filter not working!"
    
    Call oRecord.Open(Application.Database.Classes("infotiles"), lngidinfotiles)
    sOperatorKey = oRecord.Fields("operator").Options.Lookup(oRecord("operator"), lkLookupOptionByValue).key
    If sOperatorKey <> "field" Then
    
        sVisibleOn = oRecord.text("visibleon")
        sExplorer = oRecord.text("classname")
        sFiltername = oRecord.text("filtername")
        If sVisibleOn = VisibleOnIndexName Then
            If Application.Explorers.Exists(sExplorer) Then
                If Application.Explorers(sExplorer).Filters.Exists(sFiltername) Then
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
                If oExplorer.Filters.Exists(sFiltername) Then
                    Set oExplorer.ActiveFilter = oExplorer.Filters(sFiltername)
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
    Call UI.ShowError("InfoTiles.SetFilter")
End Sub
' ##SUMMARY Gets the appropriate filter as xml
Public Function FetchFiltersXML(ByVal sActiveClass As String, ByVal lngIdRecord As Long) As String
On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Dim oRecords As New LDE.Records
    Dim oRecord As New LDE.Record
    Dim oView As New LDE.View
    Dim sValue As String
    Dim lngValue As Long
    Dim bShowInfoTilesItem As Boolean
    Dim oActiveRecord As LDE.Record
    Dim lngActiveCoworkerId As Variant ' Long
    
    Dim oVisibleForAllOption As LDE.Option
    Dim oVisibleForMeOption As LDE.Option
    Dim oVisibleForDepartmentOption As LDE.Option
    
    FetchFiltersXML = "<filters></filters>"
    
    Set oVisibleForAllOption = InfoTiles.GetOptionByKey("infotiles", "visiblefor", "all", True)
    If oVisibleForAllOption Is Nothing Then
        Exit Function
    End If
    
    Set oVisibleForMeOption = InfoTiles.GetOptionByKey("infotiles", "visiblefor", "me", True)
    If oVisibleForMeOption Is Nothing Then
        Exit Function
    End If

    If Not ActiveUser.Record Is Nothing Then
        lngActiveCoworkerId = ActiveUser.Record.ID
    Else
        lngActiveCoworkerId = Null
    End If
    
    If bDepartmentoptionenabled Then
        
        Set oVisibleForDepartmentOption = InfoTiles.GetOptionByKey("infotiles", "visiblefor", "department", True)
        If oVisibleForDepartmentOption Is Nothing Then
            Exit Function
        End If
            
        Dim lDepartmentRecordID As Variant
        Dim oRecordActiveUser As New LDE.Record
        Dim oActiveUserView As New LDE.View
        
        If VBA.IsNull(lngActiveCoworkerId) = False Then
            Call oActiveUserView.Add(sDepartmentFieldname)
            Call oRecordActiveUser.Open(Application.Database.Classes("coworker"), lngActiveCoworkerId, oActiveUserView)
            If oRecordActiveUser.Fields.Exists(sDepartmentFieldname) Then
                lDepartmentRecordID = oRecordActiveUser.Value(sDepartmentFieldname)
            Else
                Call Lime.MessageBox("InfoTiles: %0%0" & Localize.GetText("Infotiles", "coworker_department_missing"), vbExclamation, sDepartmentFieldname)
                Exit Function
            End If
        Else
            lDepartmentRecordID = Null
        End If
        
        'FILTER CREATION MADNESS
        Call oFilter.AddCondition("visiblefor", lkOpEqual, oVisibleForAllOption.Value)
        Call oFilter.AddCondition("visiblefor", lkOpEqual, oVisibleForMeOption.Value)
        Call oFilter.AddCondition("coworker", lkOpEqual, lngActiveCoworkerId)
        Call oFilter.AddOperator(lkOpAnd)
        Call oFilter.AddOperator(lkOpOr)
        Call oFilter.AddCondition("visiblefor", lkOpEqual, oVisibleForDepartmentOption.Value)
        Call oFilter.AddCondition(sDepartmentFieldname, lkOpEqual, lDepartmentRecordID)
        Call oFilter.AddOperator(lkOpAnd)
        Call oFilter.AddOperator(lkOpOr)
        Call oFilter.AddCondition("active", lkOpEqual, 1)
        Call oFilter.AddOperator(lkOpAnd)

'        Dim d As New Lime.Dialog
'        d.Type = lkDialogFilter                                        '===== > These 5 rows can be outcommented to test the filters!
'        d.Property("filter") = oFilter                               ' <---make sure you have "Dim oFilter as New LDE.Filter"
'        d.Property("class") = Classes("infotiles")               '  <---change the class "offer" to your table/class in question!
'        Call d.show

    Else
        Call oFilter.AddCondition("visiblefor", lkOpEqual, oVisibleForAllOption.Value)
        Call oFilter.AddCondition("visiblefor", lkOpEqual, oVisibleForMeOption.Value)
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
    
    Call oRecords.Open(Application.Database.Classes("infotiles"), oFilter, oView)
    
    FetchFiltersXML = "<filters>"
    
    If oRecords.Count > 0 Then
        For Each oRecord In oRecords
            Select Case oRecord.GetOptionKey("operator")
                Case "count"
                    sValue = VBA.CStr(GetHitCount(oRecord.text("classname"), oRecord.text("filtername"), sActiveClass, lngIdRecord))
                Case "sum"
                    sValue = GetSumField(oRecord.text("classname"), oRecord.text("filtername"), oRecord.text("fieldname"), sActiveClass, lngIdRecord)
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
                                If oActiveRecord.Fields.Exists(oRecord.text("fieldname")) Then
                                    sValue = oActiveRecord.text(oRecord.text("fieldname"))
                                Else
                                    Call Lime.MessageBox("field: """ & oRecord.text("fieldname") & """ does not exist on card: """ & sActiveClass & """")
                                End If
                            End If
                        End If

                    End If
            End Select

            bShowInfoTilesItem = False
            If VBA.IsNumeric(sValue) Then
                lngValue = VBA.CLng(sValue)
                If lngValue >= 0 Then
                    If ((lngValue = 0 And oRecord.Value("visibleonzero") = 1 Or oRecord.GetOptionKey("operator") = "link") Or (lngValue > 0)) Then
                        bShowInfoTilesItem = True
                    End If
                End If
            ElseIf oRecord.GetOptionKey("operator") = "field" Then
                bShowInfoTilesItem = True
            End If

            If bShowInfoTilesItem = True Then
                Dim sColor As String
                If oRecord.GetOptionKey("operator") = "link" Then
                    sValue = ""
                End If
                sColor = ""
                Dim colorOption As LDE.Option
                If oRecord.GetOptionKey("color") <> "" Then
                    Set colorOption = oRecord.Options("color").Lookup(oRecord.GetOptionKey("color"), lkLookupOptionByKey)
                End If
                If Not colorOption Is Nothing Then
                    'sColor = FixColorToHexString(colorOption.Attribute("color"))
                    sColor = colorOption.key
                End If
            
                FetchFiltersXML = FetchFiltersXML + "<filter>" _
                    & "<idinfotiles><![CDATA[" & VBA.CStr(oRecord.ID) & "]]></idinfotiles>" _
                    & "<explorer><![CDATA[" & oRecord.text("classname") & "]]></explorer>" _
                    & "<name><![CDATA[" & oRecord.text("filtername") & "]]></name>" _
                    & "<color><![CDATA[" & sColor & "]]></color>" _
                    & "<size><![CDATA[" & oRecord.GetOptionKey("size") & "]]></size>" _
                    & "<sortorder><![CDATA[" & VBA.CStr(oRecord.text("sortorder")) & "]]></sortorder>" _
                    & "<value><![CDATA[" & sValue & "]]></value>" _
                    & "<label><![CDATA[" & oRecord.text("label") & "]]></label>" _
                    & "<icon><![CDATA[" & oRecord.text("icon") & "]]></icon>" _
                    & "</filter>"
            End If
        Next oRecord
    End If

    FetchFiltersXML = FetchFiltersXML & "</filters>"

Exit Function
ErrorHandler:
    Select Case Err.Number
        Case -2146233079, -2147188732, -2130558070: ' Error codes to "ignore"
        Case Else
            Call UI.ShowError("InfoTiles.FetchFiltersXML")
    End Select
    
End Function

Private Function GetOptionByKey(ByVal sClassName As String, ByVal sFieldName As String, ByVal sOptionKey As String, Optional ByVal bVerbose As Boolean = False) As LDE.Option
On Error GoTo ErrorHandler
    Dim oClass As LDE.Class
    Dim oField As LDE.field
    Dim oOptions As LDE.Options
    Dim oOption As LDE.Option
    Dim oReturnOption As LDE.Option
    Dim sMessage As String
    
    Set GetOptionByKey = Nothing
    
    sMessage = ""
    
    Set oClass = Application.Database.Classes.Lookup(sClassName, lkLookupClassByName)
    If oClass Is Nothing Then
        If bVerbose Then
            sMessage = Lime.FormatString("InfoTiles: %0%0" & Localize.GetText("Infotiles", "class_missing"), sClassName)
            GoTo ShowErrorMessage
        End If
        Exit Function
    End If
    
    Set oField = oClass.Fields.Lookup(sFieldName, lkLookupFieldByName)
    If oField Is Nothing Then
        If bVerbose Then
            sMessage = Lime.FormatString("InfoTiles: %0%0" & Localize.GetText("Infotiles", "field_missing"), sClassName, sFieldName)
            GoTo ShowErrorMessage
        End If
        Exit Function
    End If
    
    Set oOptions = oField.Options
    If oOptions Is Nothing Then
        If bVerbose Then
            sMessage = Lime.FormatString("InfoTiles: %0%0" & Localize.GetText("Infotiles", "options_missing"), sClassName, sFieldName)
            GoTo ShowErrorMessage
        End If
        Exit Function
    End If
    
    If sOptionKey = "" Then
        For Each oOption In oOptions
            If oOption.key = sOptionKey Then
                Set oReturnOption = oOption
                Exit For
            End If
        Next oOption
    Else
        Set oReturnOption = oOptions.Lookup(sOptionKey, lkLookupOptionByKey)
    End If
    
    If oReturnOption Is Nothing Then
        If bVerbose Then
            sMessage = Lime.FormatString("InfoTiles: %0%0" & Localize.GetText("Infotiles", "option_missing"), sClassName, sFieldName, sOptionKey)
            GoTo ShowErrorMessage
        End If
    End If
    
    Set GetOptionByKey = oReturnOption
    
Exit Function
ShowErrorMessage:
    If sMessage <> "" Then
        Call Lime.MessageBox(sMessage, vbExclamation)
    End If
Exit Function
ErrorHandler:
    Call UI.ShowError("InfoTiles.GetOptionByKey")
End Function

' ##SUMMARY Sets the search icon
Public Sub SearchIcon()
    On Error GoTo ErrorHandler
    
    Call ActiveInspector.PaneControls.SetValue("searchicon", WebFolder & "lbs.html?ap=infotilessearchicon&type=inline")

    Exit Sub
ErrorHandler:
    Call UI.ShowError("InfoTiles.SearchIcon")
End Sub
' ##SUMMARY Filter count by type
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
    Call UI.ShowError("InfoTiles.GetFilterCountByType")
End Function

' ##SUMMARY fieldTypes as Keys will be checked
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
    Call UI.ShowError("InfoTiles.GetFieldCountByTypes")
End Function
' ##SUMMARY Get the explorer fields based on the class
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
    Call UI.ShowError("InfoTiles.FindExplorerFieldsByClass")
End Function
' ##SUMMARY Get the appropriate filters
Public Function GetInspectorExplorerFilters(ByVal InspectorClass As String, ByVal ExplorerClass As String) As LDE.Filters
On Error GoTo ErrorHandler
    Dim oFilters As New LDE.Filters
    Set oFilters.Database = Application.Database
    oFilters.Folder = "Filters\" & VBA.Right("00000000" & VBA.Hex(Application.Database.Classes(InspectorClass).ID), 8) & "." & VBA.Right("00000000" & VBA.Hex(Application.Database.Classes(ExplorerClass).ID), 8)
    Call oFilters.Refresh
    Set GetInspectorExplorerFilters = oFilters
Exit Function
ErrorHandler:
    Call UI.ShowError("InfoTiles.GetInspectorExplorerFilters")
End Function
' ##SUMMARY converts the color to hex string
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
    Call UI.ShowError("InfoTiles.ReverseHexString")
End Function

'------------------------------------------
'===============INSTALLER==================
'------------------------------------------
Public Sub Install()
On Error GoTo ErrorHandler
    Dim sOwner As String
    sOwner = "Infotiles"

    Call AddOrCheckLocalize( _
        sOwner, _
        "no_data", _
        "Translation for " & sOwner, _
        "No data for InfoTiles", _
        "Ingen data för InfoTiles", _
        "No data for InfoTiles", _
        "No data for InfoTiles" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "class_missing", _
        "Translation for " & sOwner, _
        "The table '%1' is not found", _
        "Kan inte hitta tabellen '%1'", _
        "The table '%1' is not found", _
        "The table '%1' is not found" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "field_missing", _
        "Translation for " & sOwner, _
        "The field '%2' in table '%1' is not found", _
        "Kan inte hitta fältet '%2' i tabellen '%1'", _
        "The field '%2' in table '%1' is not found", _
        "The field '%2' in table '%1' is not found" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "options_missing", _
        "Translation for " & sOwner, _
        "The field '%2' in table '%1' doesn't have any options", _
        "Kan inte hitta några alternativ i fältet '%2' i tabellen '%1'", _
        "The field '%2' in table '%1' doesn't have any options", _
        "The field '%2' in table '%1' doesn't have any options" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "option_missing", _
        "Translation for " & sOwner, _
        "The field '%2' in table '%1' doesn't have any option with key '%3'", _
        "Kan inte hitta något alternativ i fältet '%2' i tabellen '%1' med nyckel '%3'", _
        "The field '%2' in table '%1' doesn't have any option with key '%3'", _
        "The field '%2' in table '%1' doesn't have any option with key '%3'" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "coworker_department_missing", _
        "Translation for " & sOwner, _
        "The field '%1' in the coworker table", _
        "Kan inte hitta fältet '%1' Medarbetar-tabellen", _
        "The field '%1' in the coworker table", _
        "The field '%1' in the coworker table" _
    )
    
Exit Sub
ErrorHandler:
    Call UI.ShowError("InfoTiles.Install")
End Sub

' ##SUMMARY Check for localizations and add if found
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

