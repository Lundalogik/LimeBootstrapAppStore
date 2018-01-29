Attribute VB_Name = "QuickNote"
Option Explicit

Public Function GoToNextRecord(Optional ByVal bInverse As Boolean = False, Optional ByVal bJustCheck As Boolean) As Boolean
On Error GoTo ErrorHandler
    Dim oInspector As Lime.Inspector
    Dim oRecord As lde.Record
    Dim i As Long
    Dim oExplorer As Lime.Explorer
    Dim lngIdCurrentRecord As Long
    Dim lngIdNextRecord As Long
    Dim bExistNextOne As Boolean
    
    lngIdNextRecord = -1
    bExistNextOne = False
    Set oInspector = Application.ActiveInspector
    Set oExplorer = Application.Explorers.ActiveExplorer
    
    If Not oExplorer Is Nothing Then
        If Not oInspector Is Nothing Then
            lngIdCurrentRecord = oInspector.Record.ID
            For i = 1 To oExplorer.Records.Count
                If oExplorer.Records.Item(i).ID = lngIdCurrentRecord Then
                    
                    If bInverse Then
                        If i = 1 Then
                            bExistNextOne = False
                        Else
                            lngIdNextRecord = oExplorer.Records.Item(i - 1).ID
                            bExistNextOne = (1 <> i)
                        End If
                    Else
                        If oExplorer.Records.Count = i Then
                            bExistNextOne = False
                        Else
                            lngIdNextRecord = oExplorer.Records.Item(i + 1).ID
                            bExistNextOne = (i <> oExplorer.Records.Count)
                        End If
                    End If
                End If
            Next
            
            Set oRecord = New lde.Record
            If lngIdNextRecord > 0 And bJustCheck = False Then
                Call oRecord.Open(oExplorer.Class, lngIdNextRecord)
                Call oInspector.Close
                Call Application.OpenInspector(Application, oRecord, lkActivateExisting)
            End If
        End If
    End If
    GoToNextRecord = bExistNextOne
Exit Function
ErrorHandler:
    Call UI.ShowError("QuickNote.GoToNextRecord")
End Function


Public Function GetInitializeData() As String
    On Error GoTo ErrorHandler
    
    Dim oOption As lde.Option
    Dim sXml As String
    
    sXml = "<data>"
    For Each oOption In Application.Database.Classes("history").Fields("type").Options
        If oOption.Text <> "" Then
            sXml = sXml & "<type><id>" & oOption.Value & "</id>" & "<text>" & oOption.Text & "</text></type>"
        End If
    Next
    
    sXml = sXml & "</data>"
    
    GetInitializeData = sXml
    Exit Function
ErrorHandler:
    Call UI.ShowError("QuickNote.GetInitializeData")
End Function

Public Sub SaveHistory(sText As String, IDType As Long)
On Error GoTo ErrorHandler

    sText = URLDecode(sText)
    Dim oInspector As Lime.Inspector
    Dim oRecord As lde.Record
    Dim oField As lde.field

    Set oInspector = Application.ActiveInspector
    If Not oInspector Is Nothing Then
        For Each oField In Database.Classes("history").Fields
            If oField.Type = lkFieldTypeLink Then
                If oField.LinkedField.Class.Name = oInspector.Class.Name Then
                    
                    Set oRecord = New lde.Record
                    Call oRecord.Open(Database.Classes("history"))
                    oRecord.Value("type") = IDType
                    oRecord.Value("note") = sText
                    oRecord.Value(oField.Name) = oInspector.Record.ID
                    If Not Application.ActiveUser.Record Is Nothing Then
                        oRecord.Value("coworker") = Application.ActiveUser.Record.ID
                    End If
                    Call oRecord.Update
                    
                    Exit For
                End If
            End If
        Next oField
    End If

Exit Sub
ErrorHandler:
    Call UI.ShowError("QuickNote.SaveHistory")
End Sub

Public Function URLDecode(ByVal strEncodeURL As String) As String
On Error GoTo ErrorHandler
    Dim str As String
    str = strEncodeURL
    If Len(str) > 0 Then
        str = Replace(str, "&amp", " & ")
        str = Replace(str, "%27", VBA.Chr(39))
        str = Replace(str, "%22", VBA.Chr(34))
        str = Replace(str, "%20", " ")
        str = Replace(str, "%2A", "*")
        str = Replace(str, "%40", "@")
        str = Replace(str, "%2D", "-")
        str = Replace(str, "%5F", "_")
        str = Replace(str, "%2B", "+")
        str = Replace(str, "%2E", ".")
        str = Replace(str, "%2F", "/")
        str = Replace(str, "%2C", ",")
        str = Replace(str, "%C3%A5", "å")
        str = Replace(str, "%C3%85", "Å")
        str = Replace(str, "%C3%B6", "ö")
        str = Replace(str, "%C3%96", "Ö")
        str = Replace(str, "%C3%A4", "ä")
        str = Replace(str, "%C3%84", "Ä")
        str = Replace(str, "%5C", "\")
        str = Replace(str, "%0A", "" + vbCrLf + "")
        URLDecode = str
    End If
Exit Function
ErrorHandler:
    UI.ShowError ("QuickNote.URLDecode")
End Function
