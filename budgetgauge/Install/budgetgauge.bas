Option Explicit


Public Function GetValues(ByVal Xml As String) As String
On Error GoTo errorhandler

    Dim dealstatus As String
    Dim targettype As String
    
    Dim scoreClass As String
    Dim scoreFieldValue As String
    Dim scoreFieldDate As String
    Dim scoreFieldStatus As String
    Dim scoreFieldCoworker As String
    
    Dim targetClass As String
    Dim targetFieldValue As String
    Dim targetFieldDate As String
    Dim targetFieldType As String
    Dim targetFieldCoworker As String


    Dim oScoreFilter As New LDE.Filter
    Dim oScoreRecords As New LDE.Records
    Dim oScoreRecord As LDE.Record
    Dim oScoreView As New LDE.View


    Dim oTargetFilter As New LDE.Filter
    Dim oTargetRecords As New LDE.Records
    Dim oTargetRecord As LDE.Record
    Dim oTargetView As New LDE.View

    Dim sumScoreMine As Long
    Dim sumTargetMine As Long
    Dim sumScoreAll As Long
    Dim sumTargetAll As Long

    Dim sumScoreMineMonth As Long
    Dim sumTargetMineMonth As Long
    Dim sumScoreAllMonth As Long
    Dim sumTargetAllMonth As Long

    Dim NetworkingMineMonth As Long
    Dim NetworkingMineYear As Long
    Dim NetworkingsAllMonth As Long
    Dim NetworkingAllYear As Long
    
    
    Dim oStructureXml As New MSXML2.DOMDocument60
    
    
    If oStructureXml.loadXML(Xml) Then
        
        ' Set value to Structure Variables
        dealstatus = oStructureXml.selectSingleNode("structure/btype").Text
        targettype = oStructureXml.selectSingleNode("structure/ttype").Text
        
        scoreClass = oStructureXml.selectSingleNode("structure/scoreClass").Text
        scoreFieldValue = oStructureXml.selectSingleNode("structure/scoreFieldValue").Text
        scoreFieldDate = oStructureXml.selectSingleNode("structure/scoreFieldDate").Text
        scoreFieldStatus = oStructureXml.selectSingleNode("structure/scoreFieldStatus").Text
        scoreFieldCoworker = oStructureXml.selectSingleNode("structure/scoreFieldCoworker").Text
        
        targetClass = oStructureXml.selectSingleNode("structure/targetClass").Text
        targetFieldValue = oStructureXml.selectSingleNode("structure/targetFieldValue").Text
        targetFieldDate = oStructureXml.selectSingleNode("structure/targetFieldDate").Text
        targetFieldType = oStructureXml.selectSingleNode("structure/targetFieldType").Text
        targetFieldCoworker = oStructureXml.selectSingleNode("structure/targetFieldCoworker").Text
    
    End If

    Dim sXml As String

    sumScoreMine = 0
    sumScoreAll = 0
    sumTargetMine = 0
    sumTargetAll = 0
'    Dim startdate As String
'    Dim enddate As String
'
'    If VBA.Date >= CStr(VBA.Year(VBA.Date)) & "-10-01 00:00:00" Then
'         startdate = CStr(VBA.Year(VBA.Date)) & "-10-01 00:00:00"
'         enddate = CStr(VBA.Year(DateAdd("yyyy", 1, VBA.Date))) & "-09-30 23:59:59"
'    Else
'         startdate = CStr(VBA.Year(DateAdd("yyyy", -1, VBA.Date))) & "-10-01 00:00:00"
'         enddate = CStr(VBA.Year(VBA.Date)) & "-09-30 23:59:59"
'    End If
'    Debug.Print startdate
'    Debug.Print enddate
    

    Call oScoreView.Add(scoreFieldValue)
    Call oScoreView.Add(scoreFieldCoworker)
    Call oScoreView.Add(scoreFieldDate)

    Call oScoreFilter.AddCondition(scoreFieldStatus, lkOpEqual, Database.Classes(scoreClass).Fields(scoreFieldStatus).Options.Lookup(dealstatus, lkLookupOptionByKey))
'    Call oScoreFilter.AddCondition(scoreFieldDate, lkOpGreaterOrEqual, startdate)
'    Call oScoreFilter.AddCondition(scoreFieldDate, lkOpLessOrEqual, enddate)
'    Call oScoreFilter.AddOperator(lkOpAnd)
'    Call oScoreFilter.AddOperator(lkOpAnd)
    
    Call oScoreFilter.AddCondition(scoreFieldDate, lkOpEqual, VBA.Year(Now()), , lkFilterDecoratorYear)



'    If month Then
'        Call oScoreFilter.AddCondition("closeddate", lkOpEqual, VBA.month(Now()), , lkFilterDecoratorMonth)
'        Call oScoreFilter.AddOperator(lkOpAnd)
'    End If
    Call oScoreFilter.AddOperator(lkOpAnd)

    Call oScoreRecords.Open(Database.Classes(scoreClass), oScoreFilter, oScoreView)
     For Each oScoreRecord In oScoreRecords
         If Not VBA.IsNull(oScoreRecord.value(scoreFieldValue)) Then
            sumScoreAll = sumScoreAll + oScoreRecord.value(scoreFieldValue)
            If VBA.month(oScoreRecord.value(scoreFieldDate)) = VBA.month(Now()) Then
                sumScoreAllMonth = sumScoreAllMonth + oScoreRecord.value(scoreFieldValue)
            End If
             If oScoreRecord.value(scoreFieldCoworker) = ActiveUser.Record.ID Then
                 sumScoreMine = sumScoreMine + oScoreRecord.value(scoreFieldValue)
                 If VBA.month(oScoreRecord.value(scoreFieldDate)) = VBA.month(Now()) Then
                    sumScoreMineMonth = sumScoreMineMonth + oScoreRecord.value(scoreFieldValue)
                End If
             End If
         End If
    Next oScoreRecord


    Call oTargetView.Add(targetFieldValue)
    Call oTargetView.Add(targetFieldCoworker)
    Call oTargetView.Add(targetFieldDate)

    Call oTargetFilter.AddCondition(targetFieldType, lkOpEqual, Database.Classes(targetClass).Fields(targetFieldType).Options.Lookup(targettype, lkLookupOptionByKey))
    Call oTargetFilter.AddCondition(targetFieldDate, lkOpEqual, VBA.Year(Now()), , lkFilterDecoratorYear)
    Call oTargetFilter.AddOperator(lkOpAnd)

    Call oTargetRecords.Open(Database.Classes(targetClass), oTargetFilter, oTargetView)
     For Each oTargetRecord In oTargetRecords
         If Not VBA.IsNull(oTargetRecord.value(targetFieldValue)) Then
            sumTargetAll = sumTargetAll + oTargetRecord.value(targetFieldValue)
            If VBA.month(oTargetRecord.value(targetFieldDate)) = VBA.month(Now()) Then
                sumTargetAllMonth = sumTargetAllMonth + oTargetRecord.value(targetFieldValue)
            End If
            If oTargetRecord.value(targetFieldCoworker) = ActiveUser.Record.ID Then
                 sumTargetMine = sumTargetMine + oTargetRecord.value(targetFieldValue)
                 If VBA.month(oTargetRecord.value(targetFieldDate)) = VBA.month(Now()) Then
                    sumTargetMineMonth = sumTargetMineMonth + oTargetRecord.value(targetFieldValue)
                End If
            End If
         End If
    Next oTargetRecord

    'If month Then


    'Else
    sXml = "<?xml version=""1.0"" encoding=""UTF-16"" ?><data><goalxml>"
        NetworkingAllYear = lngTargetYearToDateValue(sumTargetAll)
        NetworkingMineYear = lngTargetYearToDateValue(sumTargetMine)

        sXml = sXml + "<year><value summine=""" + VBA.CStr(sumScoreMine) + """"
        sXml = sXml + " goalmine=""" + VBA.CStr(sumTargetMine) + """"
        sXml = sXml + " sumall=""" + VBA.CStr(sumScoreAll) + """"
        sXml = sXml + " goalall=""" + VBA.CStr(sumTargetAll) + """"
        sXml = sXml + " targetnowmine=""" + VBA.CStr(NetworkingMineYear) + """"
        sXml = sXml + " targetnowall=""" + VBA.CStr(NetworkingAllYear) + """"
        sXml = sXml + "/></year>"

        NetworkingsAllMonth = lngTargetMonthToDateValue(sumTargetAllMonth)
        NetworkingMineMonth = lngTargetMonthToDateValue(sumTargetMineMonth)

        sXml = sXml + "<month><value summine=""" + VBA.CStr(sumScoreMineMonth) + """"
        sXml = sXml + " goalmine=""" + VBA.CStr(sumTargetMineMonth) + """"
        sXml = sXml + " sumall=""" + VBA.CStr(sumScoreAllMonth) + """"
        sXml = sXml + " goalall=""" + VBA.CStr(sumTargetAllMonth) + """"
        sXml = sXml + " targetnowmine=""" + VBA.CStr(NetworkingMineMonth) + """"
        sXml = sXml + " targetnowall=""" + VBA.CStr(NetworkingsAllMonth) + """"
        sXml = sXml + "/></month>"
    'End If
sXml = sXml + "</goalxml></data>"
    GetValues = sXml
Exit Function
errorhandler:
    Call UI.ShowError("budgetgauge.GetValues")
End Function

'HELP FUNCTIONS
Public Function lngTargetMonthToDateValue(targetvalue As Long) As Long
On Error GoTo errorhandler
    Dim dblMonthToDatePercentage As Double
    dblMonthToDatePercentage = CWDnowMonth(VBA.Date) / CWDMonth(VBA.Date)
    lngTargetMonthToDateValue = VBA.Round(targetvalue * dblMonthToDatePercentage, 0)
Exit Function
errorhandler:
    Call UI.ShowError("budgetgauge.lngTargetMonthToDateValue")
End Function

Public Function lngTargetYearToDateValue(targetvalue As Long) As Long
On Error GoTo errorhandler
    Dim dblYearToDatePercentage As Double
    dblYearToDatePercentage = CWDnowYear(VBA.Date) / CWDYear(VBA.Date)
    lngTargetYearToDateValue = VBA.Round(targetvalue * dblYearToDatePercentage, 0)
Exit Function
errorhandler:
    Call UI.ShowError("budgetgauge.lngTargetYearToDateValue")
End Function

Function CWDMonth(myDate As Date) As Long
On Error GoTo errorhandler
  Dim startdate As Date, enddate As Date
  startdate = myDate - Day(myDate) + 1
  enddate = DateSerial(Year(myDate), month(myDate) + 1, 0)
  CWDMonth = DateDiff("d", startdate, enddate) - DateDiff("ww", startdate, enddate) * 2 - (Weekday(enddate) <> 7) + (Weekday(startdate) = 1)
Exit Function
errorhandler:
    Call UI.ShowError("budgetgauge.CWDMonth")
End Function

Function CWDnowMonth(myDate As Date) As Long
On Error GoTo errorhandler
  Dim startdate As Date, enddate As Date
  startdate = myDate - Day(myDate) + 1
  enddate = myDate
  CWDnowMonth = DateDiff("d", startdate, enddate) - DateDiff("ww", startdate, enddate) * 2 - (Weekday(enddate) <> 7) + (Weekday(startdate) = 1)
Exit Function
errorhandler:
    Call UI.ShowError("budgetgauge.CWDnowMonth")
End Function

Function CWDYear(myDate As Date) As Long
On Error GoTo errorhandler
  Dim startdate As Date, enddate As Date
  startdate = DateSerial(Year(myDate), 1, 1)
  enddate = DateSerial(Year(myDate), 12, 31)
  CWDYear = DateDiff("d", startdate, enddate) - DateDiff("ww", startdate, enddate) * 2 - (Weekday(enddate) <> 7) + (Weekday(startdate) = 1)
Exit Function
errorhandler:
    Call UI.ShowError("budgetgauge.CWDYear")
End Function

Function CWDnowYear(myDate As Date) As Long
On Error GoTo errorhandler
  Dim startdate As Date, enddate As Date
  startdate = DateSerial(Year(myDate), 1, 1)
  enddate = myDate
  CWDnowYear = DateDiff("d", startdate, enddate) - DateDiff("ww", startdate, enddate) * 2 - (Weekday(enddate) <> 7) + (Weekday(startdate) = 1)
Exit Function
errorhandler:
    Call UI.ShowError("budgetgauge.CWDnowYear")
End Function


'
'Public Function SalesOrConsultant() As Boolean
'On Error GoTo errorhandler
'    If Not ActiveUser.Record Is Nothing Then
'        If ActiveUser.Record.GetOptionKey("salesorconsultant") = "sales" Then
'            SalesOrConsultant = True
'        Else
'            SalesOrConsultant = False
'        End If
'    End If
'Exit Function
'errorhandler:
'Call UI.ShowError("budgetgauge.SalesOrConsultatnt")
'End Function





Private Sub Install()
    Dim sOwner As String
    sOwner = "budgetgauge"


Call AddOrCheckLocalize( _
        sOwner, _
        "month", _
        "Used for the goalapp app", _
        "Month", _
        "Månad", _
        "Måned", _
        " ", _
        " " _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "year", _
        "Used for the goalapp app", _
        "Year", _
        "År", _
        "År", _
        " ", _
        " " _
    )

        
Call AddOrCheckLocalize( _
        sOwner, _
        "mine", _
        "Used for the goalapp app", _
        "Mine", _
        "Mina", _
        "Mine", _
        " ", _
        " " _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "all", _
        "Used for the goalapp app", _
        "All", _
        "Alla", _
        "Alle", _
        " ", _
        " " _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "thisyear", _
        "Used for the goalapp app", _
        "This year", _
        "I år", _
        "I år", _
        " ", _
        " " _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "thismonth", _
        "Used for the goalapp app", _
        "This month", _
        "Denna månad", _
        "Denne måneden", _
        " ", _
        " " _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "targetvaluenow", _
        "Used for the goalapp app", _
        "Target value now", _
        "Önskat nuvärde", _
        "Ønsket nåverdi", _
        " ", _
        " " _
    )
    Call AddOrCheckLocalize( _
        sOwner, _
        "title", _
        "Used for the goalapp app", _
        "Order intake", _
        "Order intake", _
        "Order intake", _
        "Order intake", _
        "Order intake" _
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
    Call UI.ShowError("Followup.AddLocaleToRecord")
End Sub


'OLD ADD LOCAL

'Private Function AddOrCheckLocalize(sOwner As String, sCode As String, sDescription As String, sEN_US As String, sSV As String, sNO As String, sFI As String) As Boolean
'    On Error GoTo errorhandler:
'    Dim oFilter As New LDE.Filter
'    Dim oRecs As New LDE.Records
'
'    Call oFilter.AddCondition("owner", lkOpEqual, sOwner)
'    Call oFilter.AddCondition("code", lkOpEqual, sCode)
'    oFilter.AddOperator lkOpAnd
'
'    If oFilter.HitCount(Database.Classes("localize")) = 0 Then
'        Debug.Print ("Localization " & sOwner & "." & sCode & " not found, creating new!")
'        Dim oRec As New LDE.Record
'        Call oRec.Open(Database.Classes("localize"))
'        oRec.Value("owner") = sOwner
'        oRec.Value("code") = sCode
'        oRec.Value("context") = sDescription
'        oRec.Value("sv") = sSV
'        oRec.Value("en_us") = sEN_US
'        oRec.Value("no") = sNO
'        oRec.Value("fi") = sFI
'        Call oRec.Update
'    ElseIf oFilter.HitCount(Database.Classes("localize")) = 1 Then
'    Debug.Print ("Updating localization " & sOwner & "." & sCode)
'        Call oRecs.Open(Database.Classes("localize"), oFilter)
'        oRecs(1).Value("owner") = sOwner
'        oRecs(1).Value("code") = sCode
'        oRecs(1).Value("context") = sDescription
'        oRecs(1).Value("sv") = sSV
'        oRecs(1).Value("en_us") = sEN_US
'        oRecs(1).Value("no") = sNO
'        oRecs(1).Value("fi") = sFI
'        Call oRecs.Update
'
'    Else
'        Call MsgBox("There are multiple copies of " & sOwner & "." & sCode & "  which is bad! Fix it", vbCritical, "To many translations makes Jack a dull boy")
'    End If
'
'    Set Localize.dicLookup = Nothing
'    AddOrCheckLocalize = True
'    Exit Function
'errorhandler:
'    Debug.Print ("Error while validating or adding Localize")
'    AddOrCheckLocalize = False
'End Function