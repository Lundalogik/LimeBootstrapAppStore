Attribute VB_Name = "Followup"
Option Explicit


Public Function Initialize(historytype As String, targettype As String) As String
    On Error GoTo ErrorHandler
    Dim followupXML As String

    Dim procGetFollowUp As LDE.Procedure
    Set procGetFollowUp = Application.Database.Procedures.Lookup("csp_vba_getfigures", lkLookupProcedureByName)
    
    procGetFollowUp.Parameters("@@historytype").InputValue = historytype
    procGetFollowUp.Parameters("@@targettype").InputValue = targettype
    procGetFollowUp.Parameters("@@idcoworker").InputValue = ActiveUser.Record.id
    procGetFollowUp.Parameters("@@lang").InputValue = Database.Locale
    Call procGetFollowUp.Execute(False)

    followupXML = procGetFollowUp.result
    Initialize = followupXML

Exit Function
ErrorHandler:
    UI.ShowError ("Followup.Initialize")

End Function

Private Sub Install()
    Dim sOwner As String
    sOwner = "Followup"

    Call AddOrCheckLocalize( _
        sOwner, _
        "lastupdate", _
        "Used for the followup app", _
        "Last updated", _
        "Senast uppdaterad", _
        " ", _
        " " _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "refresh_message", _
        "Used for the followup app", _
        "Can be refreshed each 5 minutes, wait", _
        "Kan uppdateras var 5e minut, vänta", _
        " ", _
        " " _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "minutes", _
        "Used for the followup app", _
        "minutes", _
        "minuter", _
        " ", _
        " " _
    )
Call AddOrCheckLocalize( _
        sOwner, _
        "seconds", _
        "Used for the followup app", _
        "seconds", _
        "sekunder", _
        " ", _
        " " _
    )
Call AddOrCheckLocalize( _
        sOwner, _
        "mine", _
        "Used for the followup app", _
        "Mine", _
        "Mina", _
        " ", _
        " " _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "all", _
        "Used for the followup app", _
        "All", _
        "Alla", _
        " ", _
        " " _
    )
    

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

