Attribute VB_Name = "PipelineModule"
Option Explicit

Private Function getKeyToAddBefore(oCollection As Collection, lngSortOrder As Long) As String
    On Error GoTo ErrorHandler
    Dim oPipelineClass As PipelineClass
    
    For Each oPipelineClass In oCollection
        If oPipelineClass.SortOrder >= lngSortOrder Then
            getKeyToAddBefore = oPipelineClass.idstring
            Exit Function
        End If
    Next oPipelineClass
    
    getKeyToAddBefore = ""
    
    Exit Function
ErrorHandler:
    getKeyToAddBefore = ""
'    Call UI.ShowError("PipelineModule.getKeyToAddBefore")
End Function

Private Function getPiplineClass(oCollection As Collection, idstring As String) As PipelineClass
    On Error GoTo ErrorHandler
    Dim oPipelineClass As PipelineClass
    
    For Each oPipelineClass In oCollection
        If oPipelineClass.idstring = idstring Then
            Set getPiplineClass = oPipelineClass
            Exit Function
        End If
    Next oPipelineClass
    
    Set getPiplineClass = Nothing
    
    Exit Function
ErrorHandler:
    Set getPiplineClass = Nothing
'    Call UI.ShowError("PipelineModule.getPiplineClass")
End Function

'Public Function getLocalizedLabel(sOwner As String, sCode As String) As String
'    getLocalizedLabel = Localize.GetText(sOwner, sCode)
'End Function

Public Function getPipeline(sClass As String, sFieldStatus As String, sFieldValue As String, sFieldShadowValue As String, sFiltername As String) As String ', sExcludeStatuses As String) As String
On Error GoTo ErrorHandler
    Dim oFilter As LDE.Filter
    Dim oView As LDE.View
    Dim oRecords As LDE.Records
    Dim oRecord As LDE.Record
    Dim sXml As String
    Dim sColor As String
    Dim SAttributeColor As String
    Dim oPipeline As PipelineClass
    Dim sBefore As String
    Dim sKey As String
    
    Dim sErrorMessage As String
    Dim oCollection As New Collection
    sXml = ""
    
    
    If Application.Database.Classes.Exists(sClass) Then
        If sFieldShadowValue = "" Or Application.Database.Classes(sClass).Fields.Exists(sFieldShadowValue) Then
            If Application.Database.Classes(sClass).Fields.Exists(sFieldStatus) Then
                If Application.Database.Classes(sClass).Fields.Exists(sFieldValue) Then
                    If Application.Database.Classes(sClass).Filters.Exists(sFiltername) Then
                        Set oFilter = Application.Database.Classes(sClass).Filters(sFiltername).Clone
                        Set oView = New LDE.View
                        Call oView.Add(sFieldStatus)
                        Call oView.Add(sFieldValue)
                        If sFieldShadowValue <> "" Then
                            Call oView.Add(sFieldShadowValue)
                        End If
                        
                        Set oRecords = New LDE.Records
                        Call oRecords.Open(Application.Database.Classes(sClass), oFilter, oView)
                        
                        For Each oRecord In oRecords
                            Set oPipeline = New PipelineClass
                            Set oPipeline = getPiplineClass(oCollection, VBA.CStr(oRecord.value(sFieldStatus)))
                            If oPipeline Is Nothing Then
                                sKey = oRecord.GetOptionKey(sFieldStatus)
                                
                                'If VBA.InStr(sExcludeStatuses, sKey) > 0 Then
                                    Set oPipeline = New PipelineClass
                                    oPipeline.Name = oRecord.Text(sFieldStatus)
                                    oPipeline.idstring = VBA.CStr(oRecord.value(sFieldStatus))
                                    oPipeline.TotalValue = VBA.CDbl(oRecord.value(sFieldValue))
                                    If sFieldShadowValue <> "" Then
                                        oPipeline.ShadowValue = VBA.CDbl(oRecord.value(sFieldShadowValue))
                                    End If
                                    oPipeline.SortOrder = Application.Database.Classes(sClass).Fields(sFieldStatus).Options.Lookup(oRecord.value(sFieldStatus), lkLookupOptionByValue).Attribute("stringorder")
                                    oPipeline.SetColor (Application.Database.Classes(sClass).Fields(sFieldStatus).Options.Lookup(oRecord.value(sFieldStatus), lkLookupOptionByValue).Attribute("color"))
                                    sBefore = getKeyToAddBefore(oCollection, oPipeline.SortOrder)
                                    If sBefore <> "" Then
                                        Call oCollection.Add(oPipeline, oPipeline.idstring, sBefore)
                                    Else
                                        Call oCollection.Add(oPipeline, oPipeline.idstring)
                                    End If
                                'End If
                            Else
                                If sFieldShadowValue <> "" Then
                                    Call oPipeline.AddToTotal(VBA.CDbl(oRecord.value(sFieldValue)), VBA.CDbl(oRecord.value(sFieldShadowValue)))
                                Else
                                    Call oPipeline.AddToTotal(VBA.CDbl(oRecord.value(sFieldValue)), Null)
                                End If
                            End If
                        Next oRecord
                    Else
                        sErrorMessage = Lime.FormatString(Localize.GetText("Pipeline", "filter_missing"), sFiltername, sClass)
                    End If
                Else
                    sErrorMessage = Lime.FormatString(Localize.GetText("Pipeline", "valuefield_missing"), sFieldValue, sClass)
                End If
            Else
                sErrorMessage = Lime.FormatString(Localize.GetText("Pipeline", "statusfield_missing"), sFieldStatus, sClass)
            End If
        Else
            sErrorMessage = Lime.FormatString(Localize.GetText("Pipeline", "shadowfield_missing"), sFieldShadowValue, sClass)
        End If
    Else
        sErrorMessage = Lime.FormatString(Localize.GetText("Pipeline", "table_missing"), sClass)
    End If

    If oCollection.Count > 0 Then
        sXml = "<pipeline>"
        For Each oPipeline In oCollection
            sXml = sXml + Lime.FormatString("<pipelinestatus name=""%1"" value=""%2"" shadowValue=""%3"" color=""%4"" nodata=""0"" idstring=""%5""/>", oPipeline.Name, VBA.Replace(VBA.CStr(oPipeline.TotalValue), ",", "."), VBA.Replace(VBA.CStr(oPipeline.ShadowValue), ",", "."), oPipeline.color, oPipeline.idstring)
        Next oPipeline
        sXml = sXml + "</pipeline>"
    Else
        If sErrorMessage = "" Then
            sErrorMessage = Localize.GetText("Pipeline", "nodata")
        End If
    End If
    
    If VBA.Len(sXml) > 0 Then
        getPipeline = sXml
    Else
        getPipeline = Lime.FormatString("<pipeline><pipelinestatus name=""%1"" value=""0"" color="""" nodata=""1""></pipelinestatus></pipeline>", sErrorMessage)
    End If
Exit Function
ErrorHandler:
    getPipeline = ""
    Call UI.ShowError("PipelineModule.getPipeline")
End Function


Public Sub GoToFilter(ByVal sClass As String, ByVal sFieldStatus As String, ByVal sFiltername As String, ByVal lngIdStatus As Long)
On Error GoTo ErrorHandler
    Dim oOrgFilter As LDE.Filter
    Dim oNewFilter As LDE.Filter
    Dim sErrorMessage As String
    sErrorMessage = ""
    
    If Application.Database.Classes.Exists(sClass) Then
        If Application.Database.Classes(sClass).Fields.Exists(sFieldStatus) Then
            If Application.Database.Classes(sClass).Filters.Exists(sFiltername) Then
                Set oOrgFilter = Application.Database.Classes(sClass).Filters(sFiltername)
                
                If Application.Explorers.Exists(sClass) Then
                    If Application.Explorers.GetVisible(sClass) = False Then
                        Call Application.Explorers.SetVisible(sClass, True)
                    End If
                    
                    Set Application.Explorers.ActiveExplorer = Application.Explorers(sClass)
                    
                    If lngIdStatus > 0 Then
                        
                        Set oNewFilter = oOrgFilter.Clone
                        Call oNewFilter.AddCondition(sFieldStatus, lkOpEqual, lngIdStatus)
                        If oNewFilter.Count > 1 Then
                            Call oNewFilter.AddOperator(lkOpAnd)
                        End If
                        
                        oNewFilter.Name = oOrgFilter.Name & " - " & Application.Database.Classes(sClass).Fields(sFieldStatus).Options.Lookup(lngIdStatus, lkLookupOptionByValue).Text
                    Else
                        Set oNewFilter = oOrgFilter
                    End If
                    
                    Set Application.Explorers.ActiveExplorer.ActiveFilter = oNewFilter
                    Call Application.Explorers.ActiveExplorer.Requery
                Else
                    sErrorMessage = Lime.FormatString(Localize.GetText("Pipeline", "table_missing"), sClass)
                End If
            Else
                sErrorMessage = Lime.FormatString(Localize.GetText("Pipeline", "filter_missing"), sFiltername, sClass)
            End If
        Else
            sErrorMessage = Lime.FormatString(Localize.GetText("Pipeline", "statusfield_missing"), sFieldStatus, sClass)
        End If
    Else
        sErrorMessage = Lime.FormatString(Localize.GetText("Pipeline", "table_missing"), sClass)
    End If
    
    If sErrorMessage <> "" Then
        Call Lime.MessageBox(sErrorMessage, vbCritical)
        Exit Sub
    End If
    
Exit Sub
ErrorHandler:
    Call UI.ShowError("PipelineModule.GoToFilter")
End Sub


'------------------------------------------
'===============INSTALLER==================
'------------------------------------------
Public Sub Install()
On Error GoTo ErrorHandler
    Dim sOwner As String
    sOwner = "Pipeline"

    Call AddOrCheckLocalize( _
        sOwner, _
        "header", _
        "Translation for PipelineApp", _
        "Business funnel", _
        "Business funnel", _
        "Business funnel", _
        "Business funnel" _
    )

    Call AddOrCheckLocalize( _
        sOwner, _
        "nodata", _
        "Translation for PipelineApp", _
        "No Data", _
        "Ingen data hittades", _
        "No Data", _
        "No Data" _
    )

    Call AddOrCheckLocalize( _
        sOwner, _
        "filter_missing", _
        "Translation for PipelineApp", _
        "There's no filter with the name '%1' for the table '%2'", _
        "Det finns inget filter med namnet '%1' för tabellen '%2'", _
        "There's no filter with the name '%1' for the table '%2'", _
        "There's no filter with the name '%1' for the table '%2'" _
    )

    Call AddOrCheckLocalize( _
        sOwner, _
        "valuefield_missing", _
        "Translation for PipelineApp", _
        "There's no field with the name '%1' for table '%2'", _
        "Det finns inget fält med namnet '%1' för tabellen '%2'", _
        "There's no field with the name '%1' for table '%2'", _
        "There's no field with the name '%1' for table '%2'" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "shadowfield_missing", _
        "Translation for PipelineApp", _
        "There's no field with the name '%1' for table '%2'", _
        "Det finns inget fält med namnet '%1' för tabellen '%2'", _
        "There's no field with the name '%1' for table '%2'", _
        "There's no field with the name '%1' for table '%2'" _
    )

    Call AddOrCheckLocalize( _
        sOwner, _
        "statusfield_misssing", _
        "Translation for PipelineApp", _
        "There's no field with the name '%1' for table '%2'", _
        "Det finns inget fält med namnet '%1' för tabellen '%2'", _
        "There's no field with the name '%1' for table '%2'", _
        "There's no field with the name '%1' for table '%2'" _
    )

    Call AddOrCheckLocalize( _
        sOwner, _
        "table_missing", _
        "Translation for PipelineApp", _
        "There's no table with the name '%1'", _
        "Det finns ingen tabell med namnet '%1'", _
        "There's no table with the name '%1'", _
        "There's no table with the name '%1'" _
    )
    
    
Exit Sub
ErrorHandler:
    Call UI.ShowError("PipelineModule.Install")
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
        oRec.value("owner") = sOwner
        oRec.value("code") = sCode
        oRec.value("context") = sDescription
        oRec.value("sv") = sSV
        oRec.value("en_us") = sEN_US
        oRec.value("no") = sNO
        oRec.value("fi") = sFI
        Call oRec.Update
    ElseIf oFilter.HitCount(Database.Classes("localize")) = 1 Then
    Debug.Print ("Updating localization " & sOwner & "." & sCode)
        Call oRecs.Open(Database.Classes("localize"), oFilter)
        oRecs(1).value("owner") = sOwner
        oRecs(1).value("code") = sCode
        oRecs(1).value("context") = sDescription
        oRecs(1).value("sv") = sSV
        oRecs(1).value("en_us") = sEN_US
        oRecs(1).value("no") = sNO
        oRecs(1).value("fi") = sFI
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
