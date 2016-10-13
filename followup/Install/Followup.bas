Attribute VB_Name = "Followup"
Option Explicit

Public Sub AddToPane()
On Error GoTo ErrorHandler
    Dim sPaneName As String
    sPaneName = "FollowUp"
    'For follow up app
    If Application.Panes.Exists(sPaneName) = True Then
        Call Application.Panes.Remove(sPaneName)
    End If
    
    Call Application.Panes.Add( _
        sPaneName, _
        Application.WebFolder & "apps\followup\Resources\followup.ico", _
        WebFolder & "lbs.html?ap=apps\followup\followup&type=tab", _
        lkPaneStyleNoToolBar _
    )
    Application.Panes.Visible = True
    If Not Application.Panes.ActivePane Is Application.Panes.Item(sPaneName) Then
        Set Application.Panes.ActivePane = Application.Panes.Item(sPaneName)
    End If
Exit Sub
ErrorHandler:
    Call UI.ShowError("Followup.AddToPane")
End Sub

Private Sub FillParentAndTranslationDic( _
    ByRef oTargetDataDic As Scripting.Dictionary, _
    ByRef oScoreToTargetTranslationDic As Scripting.Dictionary, _
    ByVal sGroupBy As String, _
    ByVal oCoworkerXml As MSXML2.DOMDocument60, _
    ByVal oTargetTypeXml As MSXML2.DOMDocument60, _
    ByVal sTargetTableName As String, _
    ByVal sTargetTypeFieldName As String, _
    ByVal sScoreTableName As String, _
    ByVal sScoreTypeFieldName As String _
)
On Error GoTo ErrorHandler
    ' For reading XML parameters
    Dim oCoworkerNodeList As MSXML2.IXMLDOMNodeList
    Dim oTargetTypeNodeList As MSXML2.IXMLDOMNodeList
    Dim oCoworkerNode As MSXML2.IXMLDOMNode
    Dim oTargetTypeNode As MSXML2.IXMLDOMNode
    
    Dim oTargettypeOption As LDE.Option
    Dim oScoreTypeOption As LDE.Option
    Dim oParentData As FollowupParentData
    Dim oChildData As FollowupChildData
    Dim key As Variant

    Set oCoworkerNodeList = oCoworkerXml.selectNodes("coworkers/coworker")
    Set oTargetTypeNodeList = oTargetTypeXml.selectNodes("targets/target")
    
    If sGroupBy = "coworker" Then ' Group on Coworker
        ' Add all coworkers as parents
        For Each oCoworkerNode In oCoworkerNodeList
            Set oParentData = New FollowupParentData
            oParentData.sId = oCoworkerNode.selectSingleNode("idcoworker").Text
            Set oParentData.oChildrenData = New Scripting.Dictionary
            Call oTargetDataDic.Add(oParentData.sId, oParentData)
        Next oCoworkerNode
    
        ' Add all targets as children
        For Each oTargetTypeNode In oTargetTypeNodeList
            Set oTargettypeOption = Application.Database.Classes(sTargetTableName).Fields(sTargetTypeFieldName).Options.Lookup(oTargetTypeNode.selectSingleNode("targetTypeKey").Text, lkLookupOptionByKey)
            Set oScoreTypeOption = Application.Database.Classes(sScoreTableName).Fields(sScoreTypeFieldName).Options.Lookup(oTargetTypeNode.selectSingleNode("scoreTypeKey").Text, lkLookupOptionByKey)
            
            Call oScoreToTargetTranslationDic.Add(oScoreTypeOption.Value, oTargettypeOption.Value)
            
            For Each key In oTargetDataDic.Keys
                Set oParentData = oTargetDataDic(key)
                Set oChildData = New FollowupChildData
                oChildData.sId = oTargettypeOption.key
                Call oParentData.oChildrenData.Add(VBA.CStr(oTargettypeOption.Value), oChildData)
            Next key
        Next oTargetTypeNode
        
    Else ' Group on Targettype
        ' Add all targets as parents
        For Each oTargetTypeNode In oTargetTypeNodeList
            Set oTargettypeOption = Application.Database.Classes(sTargetTableName).Fields(sTargetTypeFieldName).Options.Lookup(oTargetTypeNode.selectSingleNode("targetTypeKey").Text, lkLookupOptionByKey)
            Set oScoreTypeOption = Application.Database.Classes(sScoreTableName).Fields(sScoreTypeFieldName).Options.Lookup(oTargetTypeNode.selectSingleNode("scoreTypeKey").Text, lkLookupOptionByKey)
            
            Call oScoreToTargetTranslationDic.Add(oScoreTypeOption.Value, oTargettypeOption.Value)
            
            Set oParentData = New FollowupParentData
            oParentData.sId = oTargettypeOption.key
            Set oParentData.oChildrenData = New Scripting.Dictionary
            Call oTargetDataDic.Add(VBA.CStr(oTargettypeOption.Value), oParentData)
        Next oTargetTypeNode
        
        ' Add all coworkers as children
        For Each oCoworkerNode In oCoworkerNodeList
            For Each key In oTargetDataDic.Keys
                Set oChildData = New FollowupChildData
                oChildData.sId = oCoworkerNode.selectSingleNode("idcoworker").Text
            
                Set oParentData = oTargetDataDic(key)
                Call oParentData.oChildrenData.Add(oChildData.sId, oChildData)
            Next key
        Next oCoworkerNode
    End If
    
Exit Sub
ErrorHandler:
    Call UI.ShowError("Followup.FillParentAndTranslationDic")
End Sub


Public Function GetTargetData( _
    ByVal sCoworkerXml As String, _
    ByVal sTargetTypeXml As String, _
    ByVal sGroupBy As String, _
    ByVal dGivenDate As Date, _
    ByVal sStructureXml As String _
) As String
'ByVal sTargetTableName As String, _
'ByVal sTargetTypeFieldName As String, _
'ByVal sTargetDateFieldName As String, _
'ByVal sTargetValueFieldName As String, _
'ByVal sScoreTableName As String, _
'ByVal sScoreTypeFieldName As String, _
'ByVal sScoreDateFieldName As String, _
'ByVal sScoreValueFieldName As String _

    On Error GoTo ErrorHandler
    
    ' Read from structureXml
    Dim sTargetTableName As String
    Dim sTargetTypeFieldName As String
    Dim sTargetDateFieldName As String
    Dim sTargetValueFieldName As String
    Dim sScoreTableName As String
    Dim sScoreTypeFieldName As String
    Dim sScoreDateFieldName As String
    Dim sScoreValueFieldName As String

    Dim oCoworkerXml As New MSXML2.DOMDocument60
    Dim oTargetTypeXml As New MSXML2.DOMDocument60
    Dim oStructureXml As New MSXML2.DOMDocument60
    Dim oParentData As FollowupParentData
    Dim oChildData As FollowupChildData
    
    ' For fetching data from Lime database
    Dim oTargetFilter As New LDE.Filter
    Dim oScoreFilter As New LDE.Filter
    Dim oTargetRecords As New LDE.Records
    Dim oScoreRecords As New LDE.Records
    Dim oTargetView As New LDE.View
    Dim oScoreView As New LDE.View
    Dim oRecord As LDE.Record
    Dim oCoworkerPool As LDE.Pool
    
    ' For storing data and pass it on to the app
    Dim oTargetDataDic As New Scripting.Dictionary
    Dim oScoreToTargetTranslationDic As New Scripting.Dictionary
    Dim keyParent As Variant
    Dim keyChild As Variant
    Dim sXml As String
    
    Application.MousePointer = MousePointerConstants.ccHourglass

    Dim sErrorMessage As String
    sErrorMessage = ""
    
    ' Read Xml strings to Xml objects
    If oCoworkerXml.loadXML(sCoworkerXml) And oTargetTypeXml.loadXML(sTargetTypeXml) And oStructureXml.loadXML(sStructureXml) Then
        
        ' Set value to Structure Variables
        sTargetTableName = oStructureXml.selectSingleNode("structure/targetTable").Text
        sTargetTypeFieldName = oStructureXml.selectSingleNode("structure/targetTypeField").Text
        sTargetDateFieldName = oStructureXml.selectSingleNode("structure/targetDateField").Text
        sTargetValueFieldName = oStructureXml.selectSingleNode("structure/targetValueField").Text
        sScoreTableName = oStructureXml.selectSingleNode("structure/scoreTable").Text
        sScoreTypeFieldName = oStructureXml.selectSingleNode("structure/scoreTypeField").Text
        sScoreDateFieldName = oStructureXml.selectSingleNode("structure/scoreDateField").Text
        sScoreValueFieldName = oStructureXml.selectSingleNode("structure/scoreValueField").Text
        
        
        
        Call FillParentAndTranslationDic( _
            oTargetDataDic, _
            oScoreToTargetTranslationDic, _
            sGroupBy, _
            oCoworkerXml, _
            oTargetTypeXml, _
            sTargetTableName, _
            sTargetTypeFieldName, _
            sScoreTableName, _
            sScoreTypeFieldName _
        )
        
        ' Add values to CoworkerPool and conditions to Target and ScoreFilter
        If sGroupBy = "coworker" Then ' Group on Coworker
            Set oCoworkerPool = New LDE.Pool
            For Each keyParent In oTargetDataDic.Keys
                Set oParentData = oTargetDataDic(keyParent)
                Call oCoworkerPool.Add(VBA.CLng(oParentData.sId))
            Next keyParent
        Else ' Group on Targettype
            Set oCoworkerPool = New LDE.Pool
            For Each keyParent In oTargetDataDic.Keys
                Set oParentData = oTargetDataDic(keyParent)
                For Each keyChild In oParentData.oChildrenData.Keys
                    Set oChildData = oParentData.oChildrenData(keyChild)
                    Call oCoworkerPool.Add(VBA.CLng(oChildData.sId))
                Next keyChild
                Exit For ' Only add coworkers once
            Next keyParent
        End If
        
        ' Adding all types to filters
        For Each keyChild In oScoreToTargetTranslationDic.Keys
            Call oTargetFilter.AddCondition(sTargetTypeFieldName, lkOpEqual, VBA.CLng(oScoreToTargetTranslationDic(VBA.CLng(keyChild))))
            Call oScoreFilter.AddCondition(sScoreTypeFieldName, lkOpEqual, VBA.CLng(keyChild))
            
            If oTargetFilter.count > 1 Then
                Call oTargetFilter.AddOperator(lkOpOr)
            End If
            If oScoreFilter.count > 1 Then
                Call oScoreFilter.AddOperator(lkOpOr)
            End If
        Next keyChild
        
        ' Add extra conditions for TargetFilter
        Call oTargetFilter.AddCondition("coworker", lkOpIn, oCoworkerPool)
        Call oTargetFilter.AddOperator(lkOpAnd)
        Call oTargetFilter.AddCondition(sTargetDateFieldName, lkOpEqual, VBA.Year(dGivenDate), lkConditionTypeUnspecified, lkFilterDecoratorYear)
        Call oTargetFilter.AddOperator(lkOpAnd)
        Call oTargetFilter.AddCondition(sTargetDateFieldName, lkOpEqual, VBA.Month(dGivenDate), lkConditionTypeUnspecified, lkFilterDecoratorMonth)
        Call oTargetFilter.AddOperator(lkOpAnd)
        
        ' Add extra conditions for ScoreFilter
        Call oScoreFilter.AddCondition("coworker", lkOpIn, oCoworkerPool)
        Call oScoreFilter.AddOperator(lkOpAnd)
        Call oScoreFilter.AddCondition(sScoreDateFieldName, lkOpEqual, VBA.Year(dGivenDate), lkConditionTypeUnspecified, lkFilterDecoratorYear)
        Call oScoreFilter.AddOperator(lkOpAnd)
        Call oScoreFilter.AddCondition(sScoreDateFieldName, lkOpEqual, VBA.Month(dGivenDate), lkConditionTypeUnspecified, lkFilterDecoratorMonth)
        Call oScoreFilter.AddOperator(lkOpAnd)
        
        ' Add fields to view
        Call oTargetView.Add("coworker")
        Call oTargetView.Add(sTargetTypeFieldName)
        Call oTargetView.Add(sTargetValueFieldName)
        
        Call oScoreView.Add("coworker")
        Call oScoreView.Add(sScoreTypeFieldName)
        If sScoreValueFieldName <> "" Then
            Call oScoreView.Add(sScoreValueFieldName)
        End If

        Call oTargetRecords.Open(Application.Database.Classes(sTargetTableName), oTargetFilter, oTargetView)
        Call oScoreRecords.Open(Application.Database.Classes(sScoreTableName), oScoreFilter, oScoreView)
        
        If sGroupBy = "coworker" Then ' Grouping on coworker
            ' Set target values
            For Each oRecord In oTargetRecords
                keyParent = VBA.CStr(oRecord.Value("coworker"))
                keyChild = VBA.CStr(oRecord.Value(sTargetTypeFieldName))
                If oTargetDataDic.Exists(keyParent) Then
                    Set oParentData = oTargetDataDic(keyParent)
                    If oParentData.oChildrenData.Exists(keyChild) Then
                        Set oChildData = oParentData.oChildrenData(keyChild)
                        oChildData.lngTargetValue = oChildData.lngTargetValue + oRecord.Value(sTargetValueFieldName)
                        Set oParentData.oChildrenData(keyChild) = oChildData
                    Else
                        sErrorMessage = Localize.GetText("Followup", "error_mapping")
                        Exit For
                    End If
                    Set oTargetDataDic(keyParent) = oParentData
                Else
                    sErrorMessage = Localize.GetText("Followup", "error_mapping")
                    Exit For
                End If
            Next oRecord
            
            ' Set actual values
            For Each oRecord In oScoreRecords
                keyParent = VBA.CStr(oRecord.Value("coworker"))
                keyChild = VBA.CStr(oScoreToTargetTranslationDic(oRecord.Value(sScoreTypeFieldName)))
                If oTargetDataDic.Exists(keyParent) Then
                    Set oParentData = oTargetDataDic(keyParent)
                    If oParentData.oChildrenData.Exists(keyChild) Then
                        Set oChildData = oParentData.oChildrenData(keyChild)
                        oChildData.lngCurrentValue = oChildData.lngCurrentValue + 1
                        Set oParentData.oChildrenData(keyChild) = oChildData
                    Else
                        sErrorMessage = Localize.GetText("Followup", "error_mapping")
                        Exit For
                    End If
                    Set oTargetDataDic(keyParent) = oParentData
                Else
                    sErrorMessage = Localize.GetText("Followup", "error_mapping")
                    Exit For
                End If
            Next oRecord
        Else ' Grouping on targettype
            ' Set target values
            For Each oRecord In oTargetRecords
                keyParent = VBA.CStr(oRecord.Value(sTargetTypeFieldName))
                keyChild = VBA.CStr(oRecord.Value("coworker"))
                If oTargetDataDic.Exists(keyParent) Then
                    Set oParentData = oTargetDataDic(keyParent)
                    If oParentData.oChildrenData.Exists(keyChild) Then
                        Set oChildData = oParentData.oChildrenData(keyChild)
                        oChildData.lngTargetValue = oChildData.lngTargetValue + oRecord.Value(sTargetValueFieldName)
                        Set oParentData.oChildrenData(keyChild) = oChildData
                    Else
                        sErrorMessage = Localize.GetText("Followup", "error_mapping")
                        Exit For
                    End If
                    Set oTargetDataDic(keyParent) = oParentData
                Else
                    sErrorMessage = Localize.GetText("Followup", "error_mapping")
                    Exit For
                End If
            Next oRecord
            
            ' Set actual values
            For Each oRecord In oScoreRecords
                keyParent = VBA.CStr(oScoreToTargetTranslationDic(oRecord.Value(sScoreTypeFieldName)))
                keyChild = VBA.CStr(oRecord.Value("coworker"))
                If oTargetDataDic.Exists(keyParent) Then
                    Set oParentData = oTargetDataDic(keyParent)
                    If oParentData.oChildrenData.Exists(keyChild) Then
                        Set oChildData = oParentData.oChildrenData(keyChild)
                        oChildData.lngCurrentValue = oChildData.lngCurrentValue + 1
                        Set oParentData.oChildrenData(keyChild) = oChildData
                    Else
                        sErrorMessage = Localize.GetText("Followup", "error_mapping")
                        Exit For
                    End If
                    Set oTargetDataDic(keyParent) = oParentData
                Else
                    sErrorMessage = Localize.GetText("Followup", "error_mapping")
                    Exit For
                End If
            Next oRecord
        End If
        
    Else
        sErrorMessage = "Failed to load data"
    End If
    
    If sErrorMessage = "" Then
        sXml = "<targetData>"
        
        sXml = sXml & "<parents>"
        For Each keyParent In oTargetDataDic.Keys
            Set oParentData = oTargetDataDic(keyParent)
            sXml = sXml & "<parent>"
            Call AddXmlElement(sXml, "id", VBA.CStr(oParentData.sId))
            sXml = sXml & "<children>"
            For Each keyChild In oParentData.oChildrenData.Keys
                Set oChildData = oParentData.oChildrenData(keyChild)
                If oChildData.lngTargetValue > 0 Then
                    sXml = sXml & "<child>"
                    Call AddXmlElement(sXml, "id", oChildData.sId)
                    Call AddXmlElement(sXml, "currentValue", VBA.CStr(oChildData.lngCurrentValue))
                    Call AddXmlElement(sXml, "monthToDateValue", VBA.CStr(oChildData.GetTargetMonthToDateValue(dGivenDate)))
                    Call AddXmlElement(sXml, "targetValue", VBA.CStr(oChildData.lngTargetValue))
                    sXml = sXml & "</child>"
                End If
            Next keyChild
            sXml = sXml & "</children>"
            sXml = sXml & "</parent>"
        Next keyParent
        sXml = sXml & "</parents>"
        
        sXml = sXml & "</targetData>"
    End If
    
    If sErrorMessage <> "" Then
        GoTo FailingLoad
    End If

    GetTargetData = sXml
    Application.MousePointer = MousePointerConstants.ccDefault
Exit Function
FailingLoad:
    Application.MousePointer = MousePointerConstants.ccDefault
    sXml = "<targetData>"
    Call AddXmlElement(sXml, "error", sErrorMessage)
    sXml = sXml & "</targetData>"
    GetTargetData = sXml
Exit Function
ErrorHandler:
    Application.MousePointer = MousePointerConstants.ccDefault
    Call UI.ShowError("Followup.GetTargetData")
End Function


Public Function GetChoices( _
    ByVal sTargetTableName As String, _
    ByVal sTargetTypeFieldName As String, _
    ByVal sScoreTableName As String, _
    ByVal sScoreTypeFieldName As String, _
    ByVal sCoworkerNameFieldName As String _
) As String
    On Error GoTo ErrorHandler
    Dim sXml As String
    Dim sErrorMessage As String

    sXml = "<choiceData>"
    Dim oCoworkerRecords As LDE.Records
    Dim oRecord As LDE.Record
    Dim oOption As LDE.Option
    Set oCoworkerRecords = GetCoworkersWithTargets(sTargetTableName, sCoworkerNameFieldName)
    sXml = sXml & "<coworkers>"
    If Application.Database.Classes.Exists("coworker") Then
        If VBA.Len(sErrorMessage) = 0 Then
            For Each oRecord In oCoworkerRecords
                sXml = sXml & "<coworker>"
                Call AddXmlElement(sXml, "name", oRecord.Value(sCoworkerNameFieldName))
                Call AddXmlElement(sXml, "idcoworker", oRecord.Value("idcoworker"))
                sXml = sXml & "</coworker>"
            Next oRecord
        End If
    Else
        If VBA.Len(sErrorMessage) > 0 Then
            sErrorMessage = sErrorMessage & "%0"
        End If
        sErrorMessage = sErrorMessage & Localize.GetText("Followup", "error_noaccess_coworker")
    End If
    sXml = sXml & "</coworkers>"
    
    ' Get target types
    sXml = sXml & "<targettypes>"
    If Application.Database.Classes.Exists(sTargetTableName) Then
        If VBA.Len(sErrorMessage) = 0 Then
            For Each oOption In Application.Database.Classes(sTargetTableName).Fields(sTargetTypeFieldName).Options(lkFieldOptionsActive)
                If oOption.Text <> "" Then
                    sXml = sXml & "<targettype>"
                    Call AddXmlElement(sXml, "text", oOption.Text)
                    Call AddXmlElement(sXml, "key", oOption.key)
                    Call AddXmlElement(sXml, "value", oOption.Value)
                    
                    sXml = sXml & "</targettype>"
                End If
            Next oOption
        End If
    Else
        If VBA.Len(sErrorMessage) > 0 Then
            sErrorMessage = sErrorMessage & "%0"
        End If
        sErrorMessage = sErrorMessage & Lime.FormatString(Localize.GetText("Followup", "error_noaccess_target"), sTargetTableName)
    End If
    sXml = sXml & "</targettypes>"
    
    ' Get score types
    sXml = sXml & "<scoretypes>"
    If Application.Database.Classes.Exists(sScoreTableName) Then
        If VBA.Len(sErrorMessage) = 0 Then
            For Each oOption In Application.Database.Classes(sScoreTableName).Fields(sScoreTypeFieldName).Options(lkFieldOptionsActive)
                If oOption.Text <> "" Then
                    sXml = sXml & "<scoretype>"
                    Call AddXmlElement(sXml, "text", oOption.Text)
                    Call AddXmlElement(sXml, "key", oOption.key)
                    Call AddXmlElement(sXml, "value", oOption.Value)
                    
                    sXml = sXml & "</scoretype>"
                End If
            Next oOption
        End If
    Else
        If VBA.Len(sErrorMessage) > 0 Then
            sErrorMessage = sErrorMessage & "%0"
        End If
        sErrorMessage = sErrorMessage & Lime.FormatString(Localize.GetText("Followup", "error_noaccess_score"), sScoreTableName)
    End If
    sXml = sXml & "</scoretypes>"
    
    sXml = sXml & "</choiceData>"
    GetChoices = sXml

    If VBA.Len(sErrorMessage) > 0 Then
        Call Lime.MessageBox(sErrorMessage, vbCritical)
    End If

Exit Function
ErrorHandler:
    Call UI.ShowError("Followup.GetChoices")
End Function


Private Function GetCoworkersWithTargets( _
    ByVal sTargetTableName As String, _
    ByVal sCoworkerNameFieldName As String _
) As LDE.Records
On Error GoTo ErrorHandler
    Dim oCoworkerRecords As New LDE.Records
    Dim oFilter As New LDE.Filter
    Dim oView As New LDE.View
    
    Call oView.Add("idcoworker")
    Call oView.Add(sCoworkerNameFieldName, lkSortAscending)

    Call oFilter.AddCondition(sTargetTableName, lkOpGreater, 0, lkConditionTypeUnspecified, lkFilterDecoratorCount)
    Call oCoworkerRecords.Open(Application.Database.Classes("coworker"), oFilter, oView)
    Set GetCoworkersWithTargets = oCoworkerRecords

Exit Function
ErrorHandler:
    Call UI.ShowError("Followup.GetCoworkersWithTargets")
End Function

Private Sub AddXmlElement(ByRef sXml As String, ByVal sName As String, ByVal sValue As String)
On Error GoTo ErrorHandler
    sXml = sXml & Lime.FormatString("<%1><![CDATA[%2]]></%1>", sName, sValue)
Exit Sub
ErrorHandler:
    Call UI.ShowError("Followup.AddXmlElement")
End Sub

' Returns nr of week days (Mon-Fri) In a given range
Private Function GetNrWorkingDaysInRange(dStartDate As Date, dEndDate As Date) As Long
On Error GoTo ErrorHandler
    Dim lngTotalDays As Long, lngTotalWeeks As Long, lngDaysPerWeekToSkip As Long, lngMinusFix As Long
    
    lngTotalDays = VBA.DateDiff("d", dStartDate, dEndDate)
    lngTotalWeeks = VBA.DateDiff("ww", dStartDate, dEndDate)
    lngDaysPerWeekToSkip = 2
    
    ' -1 for each True in the statement
    ' IF dStartDate = Sunday ( -1 ) ELSE 0
    ' +
    ' IF dEndDate <> Monday ( -1 ) ELSE 0
    ' =
    ' (Diff between 0 and -2)
    lngMinusFix = (VBA.Weekday(dEndDate) <> 7) + (VBA.Weekday(dStartDate) = 1)
    
    GetNrWorkingDaysInRange = lngTotalDays - (lngTotalWeeks * lngDaysPerWeekToSkip) - lngMinusFix

Exit Function
ErrorHandler:
    Call UI.ShowError("Followup.GetNrWorkingDaysInRange")
End Function


' Returns nr of week days (Mon-Fri) given month
Public Function GetNrWorkingDaysGivenMonth(ByVal dGivenDate As Date) As Long
On Error GoTo ErrorHandler
    Dim dFirstGivenMonth As Date, dLastGivenMonth As Date
    
    dFirstGivenMonth = VBA.DateAdd("d", -VBA.Day(dGivenDate) + 1, dGivenDate)
    dLastGivenMonth = VBA.DateSerial(VBA.Year(dGivenDate), VBA.Month(dGivenDate) + 1, 0)
    
    GetNrWorkingDaysGivenMonth = GetNrWorkingDaysInRange(dFirstGivenMonth, dLastGivenMonth)
Exit Function
ErrorHandler:
    Call UI.ShowError("Followup.GetNrWorkingDaysGivenMonth")
End Function

' Returns nr of week days (Mon-Fri) given month so far
Public Function GetNrWorkingDaysGivenMonthSoFar(ByVal dGivenDate As Date) As Long
On Error GoTo ErrorHandler
    Dim dFirstGivenMonth As Date
    
    dFirstGivenMonth = VBA.DateAdd("d", -VBA.Day(dGivenDate) + 1, dGivenDate)
    
    GetNrWorkingDaysGivenMonthSoFar = GetNrWorkingDaysInRange(dFirstGivenMonth, dGivenDate)
Exit Function
ErrorHandler:
    Call UI.ShowError("Followup.GetNrWorkingDaysGivenMonthSoFar")
End Function



Private Sub Install()
    Dim sOwner As String
    sOwner = "Followup"

    Call AddOrCheckLocalize( _
        sOwner, _
        "tooltip_today", _
        "Used for the followup app", _
        "Go to current month", _
        "Gå till nuvarande månad", _
        "Go to current month", _
        "Go to current month", _
        "Go to current month" _
    )

    Call AddOrCheckLocalize( _
        sOwner, _
        "validate_missingInput", _
        "Used for the followup app", _
        "You have to at least a coworker and a goaltypes", _
        "Du måste välja minst en medarbetare och en måltyp", _
        "You have to at least a coworker and a goaltypes", _
        "You have to at least a coworker and a goaltypes", _
        "You have to at least a coworker and a goaltypes" _
    )

    Call AddOrCheckLocalize( _
        sOwner, _
        "settings_title", _
        "Used for the followup app", _
        "Settings", _
        "Inställningar", _
        "Settings", _
        "Settings", _
        "Settings" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "settings_openbutton", _
        "Used for the followup app", _
        "Open settings", _
        "Öppna inställningar", _
        "Open settings", _
        "Open settings", _
        "Open settings" _
    )
   Call AddOrCheckLocalize( _
        sOwner, _
        "settings_coworkers", _
        "Used for the followup app", _
        "Coworkers", _
        "Medarbetare", _
        "Coworkers", _
        "Coworkers", _
        "Coworkers" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "settings_targettypes", _
        "Used for the followup app", _
        "Goal types", _
        "Måltyper", _
        "Goal types", _
        "Goal types", _
        "Goal types" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "settings_fetchdata", _
        "Used for the followup app", _
        "Show data", _
        "Visa data", _
        "Show data", _
        "Show data", _
        "Show data" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "settings_grouping", _
        "Used for the followup app", _
        "Grouping", _
        "Gruppering", _
        "Grouping", _
        "Grouping", _
        "Grouping" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "settings_targettype", _
        "Used for the followup app", _
        "Goal type", _
        "Måltyp", _
        "Goal type", _
        "Goal type", _
        "Goal type" _
    )
     Call AddOrCheckLocalize( _
        sOwner, _
        "settings_coworker", _
        "Used for the followup app", _
        "Coworker", _
        "Medarbetare", _
        "Coworker", _
        "Coworker", _
        "Coworker" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "no_goals", _
        "Used for the followup app", _
        "No goals is set for you!", _
        "Inga målvärden är satta för dig!", _
        "No goals is set for you", _
        "No goals is set for you", _
        "No goals is set for you" _
    )
     Call AddOrCheckLocalize( _
        sOwner, _
        "validate_maxcoworkers", _
        "Used for the followup app", _
        "You have reached the maximum number of selected coworkers!", _
        "Du har nått maxgränsen för valda medarbetare!", _
        "You have reached the maximum number of selected coworkers", _
        "You have reached the maximum number of selected coworkers", _
        "You have reached the maximum number of selected coworkers" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "validate_maxobjects", _
        "Used for the followup app", _
        "You have reached the maximum number of selected objects!", _
        "Du har nått maxgränsen för markerade objekt!", _
        "You have reached the maximum number of selected objects", _
        "You have reached the maximum number of selected objects", _
        "You have reached the maximum number of selected objects" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "validate_maxtarget", _
        "Used for the followup app", _
        "You have reached the maximum number of selected target types!", _
        "Du har nått maxgränsen för valda måltyper!", _
        "You have reached the maximum number of selected target types", _
        "You have reached the maximum number of selected target types", _
        "You have reached the maximum number of selected target types" _
    )
     Call AddOrCheckLocalize( _
        sOwner, _
        "no_goals_month", _
        "Used for the followup app", _
        "No goals set for this month", _
        "Inga målvärden denna månad", _
        "No goals set for this month", _
        "No goals set for this month", _
        "No goals set for this month" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "no_coworker", _
        "Used for the followup app", _
        "You have no user!", _
        "Du har ingen användare!", _
        "You have no user", _
        "You have no user", _
        "You have no user" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "error_mapping", _
        "Used for the followup app", _
        "Something went wrong with the mapping of types", _
        "Något gick fel vid mappningen av typer", _
        "Something went wrong with the mapping of types", _
        "Something went wrong with the mapping of types", _
        "Something went wrong with the mapping of types" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "error_noaccess_coworker", _
        "Used for the followup app", _
        "You have no access to the Coworker table", _
        "Du har inte access till tabellen Medarbetare", _
        "You have no access to the Coworker table", _
        "You have no access to the Coworker table", _
        "You have no access to the Coworker table" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "error_noaccess_target", _
        "Used for the followup app", _
        "You have no access to the '%1' table", _
        "Du har inte access till tabellen '%1'", _
        "You have no access to the '%1' table", _
        "You have no access to the '%1' table", _
        "You have no access to the '%1' table" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "error_noaccess_score", _
        "Used for the followup app", _
        "You have no access to the '%1' table", _
        "Du har inte access till tabellen '%1'", _
        "You have no access to the '%1' table", _
        "You have no access to the '%1' table", _
        "You have no access to the '%1' table" _
    )
    'nya
    Call AddOrCheckLocalize( _
        sOwner, _
        "coworker_notargetdata", _
        "Used for the followup app", _
        "Can't find any coworkers with targets.", _
        "Hittar inga medarbetare med uppsatta mål.", _
        "Can't find any coworkers with targets", _
        "Can't find any coworkers with targets", _
        "Can't find any coworkers with targets" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "error_no_scoretypes", _
        "Used for the followup app", _
        "There is no score types mapped", _
        "Finns inga score types mappade", _
        "There is no score types mapped", _
        "There is no score types mapped", _
        "There is no score types mapped" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "error_no_targettypes", _
        "Used for the followup app", _
        "There is no target types", _
        "Finns inga måltyper", _
        "There is no target types", _
        "There is no target types", _
        "There is no target types" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "error_nomatch_score", _
        "Used for the followup app", _
        "No match on score type %1 in table %2", _
        "Ingen match på score-typen %1 i tabellen %2", _
        "No match on score type %1 in table %2", _
        "No match on score type %1 in table %2", _
        "No match on score type %1 in table %2" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "error_nomatch_target", _
        "Used for the followup app", _
        "No match on target type %1 in table %2", _
        "Ingen match på måltyp %1 i tabellen %2", _
        "No match on target type %1 in table %2", _
        "No match on target type %1 in table %2", _
        "No match on target type %1 in table %2" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "settings_reload", _
        "Used for the followup app", _
        "Reload setting data", _
        "Ladda om inställningsdata", _
        "Reload setting data", _
        "Reload setting data", _
        "Reload setting data" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "old_lbsVersion", _
        "Used for the followup app", _
        "Your LBS version is too old (%1), you'll need at least version %2", _
        "Din LBS-version är för gammal (%1), Du behöver åtminstone version %2", _
        "Your LBS version is too old (%1), you'll need at least version %2", _
        "Your LBS version is too old (%1), you'll need at least version %2", _
        "Your LBS version is too old (%1), you'll need at least version %2" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "open_followup", _
        "Used for the followup app", _
        "Open followup", _
        "Öppna followup", _
        "Open followup", _
        "Open followup", _
        "Open followup" _
    )
    
    
    
    
End Sub


Private Function AddOrCheckLocalize( _
    sOwner As String, _
    sCode As String, _
    sDescription As String, _
    sEN_US As String, _
    sSV As String, _
    sNO As String, _
    sFI As String, _
    sDA As String _
) As Boolean
    On Error GoTo ErrorHandler:
    Dim oFilter As New LDE.Filter
    Dim oRecs As New LDE.Records
    Dim oRec As LDE.Record
    
    Call oFilter.AddCondition("owner", lkOpEqual, sOwner)
    Call oFilter.AddCondition("code", lkOpEqual, sCode)
    oFilter.AddOperator lkOpAnd
    
    If oFilter.HitCount(Database.Classes("localize")) = 0 Then
        Debug.Print ("Localization " & sOwner & "." & sCode & " not found, creating new!")
        Set oRec = New LDE.Record
        Call oRec.Open(Database.Classes("localize"))
        oRec.Value("owner") = sOwner
        oRec.Value("code") = sCode
        oRec.Value("context") = sDescription
        Call AddLocaleToRecord(oRec, "sv", sSV)
        Call AddLocaleToRecord(oRec, "en_us", sEN_US)
        Call AddLocaleToRecord(oRec, "no", sNO)
        Call AddLocaleToRecord(oRec, "fi", sFI)
        Call AddLocaleToRecord(oRec, "da", sDA)
        
        Call oRec.Update
    ElseIf oFilter.HitCount(Database.Classes("localize")) = 1 Then
    Debug.Print ("Updating localization " & sOwner & "." & sCode)
        Call oRecs.Open(Database.Classes("localize"), oFilter)
        Set oRec = oRecs(1)
        oRec.Value("owner") = sOwner
        oRec.Value("code") = sCode
        oRec.Value("context") = sDescription
        Call AddLocaleToRecord(oRec, "sv", sSV)
        Call AddLocaleToRecord(oRec, "en_us", sEN_US)
        Call AddLocaleToRecord(oRec, "no", sNO)
        Call AddLocaleToRecord(oRec, "fi", sFI)
        Call AddLocaleToRecord(oRec, "da", sDA)
        Call oRec.Update
        
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

Private Sub AddLocaleToRecord(ByRef oRec As LDE.Record, ByVal sLocaleCode As String, ByVal sLocaleValue As String)
On Error GoTo ErrorHandler
    If oRec.Fields.Exists(sLocaleCode) Then
        oRec.Value(sLocaleCode) = sLocaleValue
    End If
Exit Sub
ErrorHandler:
    Call UI.ShowError("Followup.AddLocaleToRecord")
End Sub

