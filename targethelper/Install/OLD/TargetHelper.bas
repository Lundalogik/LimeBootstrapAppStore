Attribute VB_Name = "TargetHelper"
Public Function GetCoworker() As LDE.Record
    On Error GoTo ErrorHandler
    Dim oRecord As New LDE.Record
    
    If Not ActiveExplorer Is Nothing Then
        If ActiveExplorer.Class.Name = "coworker" Then
            If ActiveExplorer.Selection.Count = 1 Then
                Call oRecord.Open(Database.Classes("coworker"), ActiveExplorer.Selection(1).Record.ID)
                
            End If
        End If
    End If
    If oRecord.Class Is Nothing Then
        If Globals.VerifyInspector("coworker", ActiveInspector, False) Then
            Call oRecord.Open(Database.Classes("coworker"), ActiveInspector.Record.ID)
        End If
    End If
    If oRecord.Class Is Nothing Then
        Call oRecord.Open(Database.Classes("coworker"), ActiveUser.Record.ID)
    End If
    Set GetCoworker = oRecord
    Exit Function
ErrorHandler:
    Call UI.ShowError("TargetHelper.GetCoworker")
End Function


Public Sub OpenTargetHelper()
    On Error GoTo ErrorHandler
    Dim oDialog As New Lime.Dialog

    oDialog.Type = lkDialogHTML
    oDialog.Property("url") = Application.WebFolder & "lbs.html?ap=targethelper&type=tab"
    oDialog.Property("height") = 845
    oDialog.Property("width") = 605
    oDialog.show

    Exit Sub
ErrorHandler:
    Call UI.ShowError("TargetHelper.OpenTargetHelper")
End Sub

Public Sub SaveTarget(sType As String, sTargets As String, iCoworker As Long, sYear As String)
    On Error GoTo ErrorHandler
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
        Call oFilter.AddCondition("targettype", lkOpEqual, Database.Classes("target").Fields("targettype").Options.Lookup(sType, lkLookupOptionByKey).Value)
        Call oFilter.AddCondition("targetdate", lkOpEqual, VBA.CDate(sYear + "-" + VBA.CStr(i + 1) + "-01"))
        Call oFilter.AddOperator(lkOpAnd)
        Call oFilter.AddCondition("coworker", lkOpEqual, iCoworker)
        Call oFilter.AddOperator(lkOpAnd)
        If oFilter.HitCount(Database.Classes("target")) > 0 Then
            Call oRecord.Open(Database.Classes("target"), oFilter)
        Else
            Call oRecord.Open(Database.Classes("target"))
        End If
    
        oRecord.Value("coworker") = iCoworker
        oRecord.Value("targettype") = oRecord.Fields("targettype").Options.Lookup(sType, lkLookupOptionByKey).Value
        oRecord.Value("targetvalue") = VBA.CInt(splitTargets(i))
        oRecord.Value("targetdate") = VBA.CDate(sYear + "-" + VBA.CStr(i + 1) + "-01")
        Call oRecord.Update(oBatch)
        
    Next i
    
    Call oBatch.Execute
    Lime.MousePointer = 0
    Exit Sub
ErrorHandler:
    Lime.MousePointer = 0
    Call UI.ShowError("TargetHelper.SaveTarget")

End Sub

Public Function GetTargetTypes() As String
    On Error GoTo ErrorHandler
    Dim sOptions As String
    Dim oOption As LDE.Option
    
    For Each oOption In Database.Classes("target").Fields("targettype").Options
        sOptions = sOptions + oOption.Text + "," + oOption.key + ";"
    Next oOption
    
    
    GetTargetTypes = sOptions
    Exit Function
ErrorHandler:
    Call UI.ShowError("TargetHelper.GetTargetTypes")
End Function
