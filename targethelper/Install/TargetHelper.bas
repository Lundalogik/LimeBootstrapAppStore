Attribute VB_Name = "TargetHelper"
Public Function GetCoworker() As LDE.Record
    On Error GoTo errorhandler
    Dim oRecord As New LDE.Record
    If Not ActiveUser.Record Is Nothing Then
        Call oRecord.Open(Database.Classes("coworker"), ActiveUser.Record.ID)
    End If
    Set GetCoworker = oRecord
    Exit Function
errorhandler:
    Call UI.ShowError("TargetHelper.GetCoworker")
End Function


Public Sub OpenTargetHelper()
    On Error GoTo errorhandler
    Dim oDialog As New Lime.Dialog

    oDialog.Type = lkDialogHTML
    oDialog.Property("url") = Application.WebFolder & "lbs.html?ap=apps\targethelper\targethelper&type=tab"
    oDialog.Property("height") = 845
    oDialog.Property("width") = 605
    oDialog.show
    
    


    Exit Sub
errorhandler:
    Call UI.ShowError("TargetHelper.OpenTargetHelper")
End Sub

Public Function SaveTarget(sType As String, sTargets As String, iCoworker As Long, sYear As String) As String
    On Error GoTo errorhandler
    Dim splitTargets() As String
    Dim target As Long
    Dim i As Integer
    Dim oBatch As New LDE.Batch
    Dim oRecord As LDE.Record
    Dim oFilter As LDE.Filter
    
    Set oBatch.Database = Application.Database
    Lime.MousePointer = 11
    splitTargets = VBA.Split(sTargets, ";")
    For i = 0 To UBound(splitTargets) - 1
        
        Set oRecord = New LDE.Record
        Set oFilter = New LDE.Filter
        Call oFilter.AddCondition("targettype", lkOpEqual, Database.Classes("target").Fields("targettype").Options.Lookup(sType, lkLookupOptionByKey).value)
        Call oFilter.AddCondition("targetdate", lkOpEqual, VBA.CDate(sYear + "-" + VBA.CStr(i + 1) + "-01"))
        Call oFilter.AddOperator(lkOpAnd)
        Call oFilter.AddCondition("coworker", lkOpEqual, iCoworker)
        Call oFilter.AddOperator(lkOpAnd)
        If oFilter.HitCount(Database.Classes("target")) > 0 Then
            Call oRecord.Open(Database.Classes("target"), oFilter)
            SaveTarget = "update"
        Else
            Call oRecord.Open(Database.Classes("target"))
            SaveTarget = ""
        End If
    
        oRecord.value("coworker") = iCoworker
        oRecord.value("targettype") = oRecord.Fields("targettype").Options.Lookup(sType, lkLookupOptionByKey).value
        oRecord.value("targetvalue") = VBA.CInt(splitTargets(i))
        oRecord.value("targetdate") = VBA.CDate(sYear + "-" + VBA.CStr(i + 1) + "-01")
        Call oRecord.Update(oBatch)
        
    Next i
    
    Call oBatch.Execute
    Lime.MousePointer = 0
    
    Exit Function
errorhandler:
    SaveTarget = Err.Description
    Lime.MousePointer = 0
    Call UI.ShowError("TargetHelper.SaveTarget")

End Function

Public Function GetTargetTypes() As String
    On Error GoTo errorhandler
    Dim sOptions As String
    Dim oOption As LDE.Option
    
    For Each oOption In Database.Classes("target").Fields("targettype").Options
        sOptions = sOptions + oOption.Text + "," + oOption.Key + ";"
    Next oOption
    
    GetTargetTypes = sOptions
    Exit Function
errorhandler:
    Call UI.ShowError("TargetHelper.GetTargetTypes")
End Function


Public Function GetCoworkers() As String
    On Error GoTo errorhandler
    Dim oRecord As LDE.Record
    Dim oRecords As New LDE.Records
    Dim oFilter As New LDE.Filter
    Dim oView As New LDE.View
    Dim sCoworkers As String
    
    GetCoworkers = ""
    Call oView.Add("idcoworker")
    Call oView.Add("name")
    Call oFilter.AddCondition("active", lkOpEqual, 1)
    Call oRecords.Open(Database.Classes("coworker"), oFilter, oView)
    For Each oRecord In oRecords
        sCoworkers = sCoworkers & oRecord.value("name") & "," & oRecord.ID & ";"
    Next oRecord
    
    
    GetCoworkers = sCoworkers

    Exit Function
errorhandler:
GetCoworkers = ""
    Call UI.ShowError("TargetHelper.GetCoworkers")
End Function


Private Sub Install()
    Dim sOwner As String
    sOwner = "Targethelper"

    Call AddOrCheckLocalize( _
        sOwner, _
        "standard_value", _
        "Used for the targethelper app", _
        "Enter standard value", _
        "Ange standardvärde", _
        "Enter standard value", _
        "Enter standard value", _
        "Enter standard value" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "monthly_value", _
        "Used for the targethelper app", _
        "Enter montly value", _
        "Ange månadsvärde", _
        "Enter montly value", _
        "Enter montly value", _
        "Enter montly value" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "save", _
        "Used for the targethelper app", _
        "Save", _
        "Spara", _
        "Save", _
        "Save", _
        "Save" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "update", _
        "Used for the targethelper app", _
        "Update", _
        "Uppdatera", _
        "Update", _
        "Update", _
        "Update" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "targettype", _
        "Used for the targethelper app", _
        "Target type", _
        "Måltyp", _
        "Target type", _
        "Target type", _
        "Target type" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "coworker", _
        "Used for the targethelper app", _
        "Coworker", _
        "Medarbetare", _
        "Coworker", _
        "Coworker", _
        "Coworker" _
    )
 Call AddOrCheckLocalize( _
        sOwner, _
        "integer_error", _
        "Used for the targethelper app", _
        "The value has to be a integer!", _
        "Värdet måste vara ett heltal!", _
        "The value has to be a integer!", _
        "The value has to be a integer!", _
        "The value has to be a integer!" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "created", _
        "Used for the targethelper app", _
        "Targets created", _
        "Mål skapade", _
        "Targets created", _
        "Targets created", _
        "Targets created" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "updated", _
        "Used for the targethelper app", _
        "Targets updated", _
        "Mål uppdaterade", _
        "Targets updated", _
        "Targets updated", _
        "Targets updated" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "must_have", _
        "Used for the targethelper app", _
        "You must choose a coworker and target type", _
        "Du måste ange en medarbetare och en måltyp", _
        "You must choose a coworker and target type", _
        "You must choose a coworker and target type", _
        "You must choose a coworker and target type" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "open_targethelper", _
        "Used for the targethelper app", _
        "Create targets", _
        "Skapa mål", _
        "Create targets", _
        "Create targets", _
        "Create targets" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "jan", _
        "Used for the targethelper app", _
        "January", _
        "Januari", _
        "Januar", _
        "Tammikuu", _
        "Januar" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "feb", _
        "Used for the targethelper app", _
        "February", _
        "Februari", _
        "Februar", _
        "helmikuu", _
        "Februar" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "mar", _
        "Used for the targethelper app", _
        "March", _
        "Mars", _
        "Mars", _
        "Maaliskuu", _
        "Marts" _
    )

    Call AddOrCheckLocalize( _
        sOwner, _
        "april", _
        "Used for the targethelper app", _
        "April", _
        "April", _
        "April", _
        "Huhtikuu", _
        "April" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "may", _
        "Used for the targethelper app", _
        "May", _
        "Maj", _
        "Maj", _
        "Toukokuu", _
        "Maj" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "jun", _
        "Used for the targethelper app", _
        "June", _
        "Juni", _
        "Juni", _
        "Kesäkuu", _
        "Juni" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "july", _
        "Used for the targethelper app", _
        "July", _
        "Juli", _
        "Juli", _
        "Heinäkuu", _
        "Juli" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "aug", _
        "Used for the targethelper app", _
        "August", _
        "Augusti", _
        "August", _
        "Elokuu", _
        "August" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "sep", _
        "Used for the targethelper app", _
        "September", _
        "September", _
        "September", _
        "Syyskuu", _
        "September" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "oct", _
        "Used for the targethelper app", _
        "October", _
        "Oktober", _
        "Oktober", _
        "Lokakuu", _
        "Oktober" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "nov", _
        "Used for the targethelper app", _
        "November", _
        "November", _
        "November", _
        "Marraskuu", _
        "November" _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "dec", _
        "Used for the targethelper app", _
        "December", _
        "December", _
        "December", _
        "Joulukuu", _
        "December" _
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
    On Error GoTo errorhandler:
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
        oRec.value("owner") = sOwner
        oRec.value("code") = sCode
        oRec.value("context") = sDescription
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
        oRec.value("owner") = sOwner
        oRec.value("code") = sCode
        oRec.value("context") = sDescription
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
errorhandler:
    Debug.Print ("Error while validating or adding Localize")
    AddOrCheckLocalize = False
End Function

Private Sub AddLocaleToRecord(ByRef oRec As LDE.Record, ByVal sLocaleCode As String, ByVal sLocaleValue As String)
On Error GoTo errorhandler
    If oRec.Fields.Exists(sLocaleCode) Then
        oRec.value(sLocaleCode) = sLocaleValue
    End If
Exit Sub
errorhandler:
    Call UI.ShowError("TargetHelper.AddLocaleToRecord")
End Sub

Public Function TargethelperMemberOfGroup(ByVal sSepareatedGroups As String, Optional ByVal bMustBeMemberOfAll As Boolean = False) As Boolean
On Error GoTo errorhandler
    Dim sGroupNames() As String
    Dim sGroupName As String
    Dim i As Long
    Dim lngGroupCount As Long
    Dim bReturnValue As Boolean
   
    sGroupNames = VBA.Split(sSepareatedGroups, ";")
   
    If bMustBeMemberOfAll = True Then
        bReturnValue = True
    Else
        bReturnValue = False
    End If
   
    lngGroupCount = 0
   
    For i = LBound(sGroupNames) To UBound(sGroupNames)
        sGroupName = sGroupNames(i)
        If VBA.Len(sGroupName) > 0 Then
            lngGroupCount = lngGroupCount + 1
            If Not ActiveUser.MemberOfGroups.Lookup(sGroupName, lkLookupGroupByName) Is Nothing Then
                ' Is member of group
                If bMustBeMemberOfAll = False Then
                    bReturnValue = True
                    Exit For
                End If
            Else
                ' Is NOT member of group
                If bMustBeMemberOfAll = True Then
                    bReturnValue = False
                    Exit For
                End If
            End If
        End If
    Next i
    If lngGroupCount = 0 Then
        bReturnValue = True
    End If
   
    TargethelperMemberOfGroup = bReturnValue
Exit Function
errorhandler:
    Call UI.ShowError("TargetHelper.TargethelperMemberOfGroup")
End Function
