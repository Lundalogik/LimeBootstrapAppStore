Attribute VB_Name = "SMS"
Option Explicit
Public Sub OpenSMSModul()
On Error GoTo ErrorHandler

Dim p As New Lime.Dialog
    If Not ActiveExplorer Is Nothing Then
        If ActiveExplorer.Class.Name = "person" Then
            If ActiveExplorer.Selection.Count > 0 Then
                'p.Property("url") = ThisApplication.WebFolder + "lbs.html?ap=apps/SMS/sms&type=tab"
                p.Property("url") = ThisApplication.WebFolder + "lbs.html?ap=apps/SMS/sms&type=tab"
                p.Property("width") = 900
                p.Property("height") = 520
                p.show lkDialogHTML
            End If
        End If
    End If
    
Exit Sub
ErrorHandler:
    Call UI.ShowError("SMS.OpenSMSModul")

End Sub


Public Function GetPersons() As String
On Error GoTo ErrorHandler

    Dim oPool As New LDE.Pool
    Dim oRecords As New LDE.Records
    Dim oRecord As New LDE.Record
    Dim oView As New LDE.View
    Dim sxml As String
    
    Call oView.Add("name")
    Call oView.Add("mobilephone")
    Call oView.Add("idperson")
    
    Set oPool = ActiveExplorer.Selection.Pool
            Call oRecords.Open(Database.Classes("person"), oPool, oView)
                    
            For Each oRecord In oRecords
                sxml = sxml + "<person><name>" + oRecord.Text("name") + "</name><phone>" + oRecord.Text("mobilephone") + "</phone><idperson>" + oRecord.Text("idperson") + "</idperson></person>"
            Next oRecord
            sxml = "<persons>" + sxml + "</persons>"
         GetPersons = sxml
Exit Function
ErrorHandler:
    Call UI.ShowError("SMS.GetPersons")
End Function


Public Function GetTemplates() As String
On Error GoTo ErrorHandler
    Dim sxml As String
    Dim oRecord As New LDE.Record
    Dim oRecords As New LDE.Records
    Dim oView As New LDE.View
    Dim oFilter As New LDE.Filter
    
    Call oView.Add("title")
    Call oView.Add("message")
    
    Call oFilter.AddCondition("active", lkOpEqual, 1)
    
    Call oRecords.Open(Database.Classes("smstemplate"), oFilter, oView)
    
    For Each oRecord In oRecords
        sxml = sxml + "<template><title>" + oRecord.Text("title") + "</title><message>" + oRecord.Text("message") + "</message></template>"
    Next oRecord
    
    GetTemplates = "<templates>" + sxml + "</templates>"
    
Exit Function
ErrorHandler:
    Call UI.ShowError("SMS.GetTemplates")
End Function

Public Function GetUsers() As String
On Error GoTo ErrorHandler
    Dim sxml As String
    Dim oRecord As New LDE.Record
    Dim oRecords As New LDE.Records
    Dim oView As New LDE.View
    Dim oFilter As New LDE.Filter
    
    Call oView.Add("default")
    Call oView.Add("username")
    Call oView.Add("idsmsuser")
    
    Call oFilter.AddCondition("active", lkOpEqual, 1)
    Call oRecords.Open(Database.Classes("smsuser"), oFilter, oView)
    
    For Each oRecord In oRecords
        sxml = sxml + "<user><default>" + oRecord.Text("default") + "</default><username>" + oRecord.Text("username") + "</username><idsmsuser>" + oRecord.Text("idsmsuser") + "</idsmsuser></user>"
    Next oRecord
    
    
    GetUsers = "<users>" + sxml + "</users>"
Exit Function
ErrorHandler:
    Call UI.ShowError("SMS.GetUsers")
End Function


Public Sub CreateSMS(smsdata As String)
On Error GoTo ErrorHandler
    Dim sParameters() As String
    Dim oRecord As New LDE.Record
    sParameters() = VBA.Split(smsdata, ":")
    
    Call oRecord.Open(Database.Classes("sms"))
    oRecord("person") = CInt(sParameters(0))
    oRecord("message") = CStr(ReplaceEncoding(sParameters(1)))
    oRecord("phone") = sParameters(2)
    oRecord("sendtime") = VBA.Now
    oRecord("smsuser") = CInt(sParameters(3))
    oRecord("smsstatus") = Database.Classes("sms").Fields("smsstatus").Options.Lookup("Ska skickas", lkLookupOptionByText)
    oRecord.Update
    
Exit Sub
ErrorHandler:
    Call UI.ShowError("SMS.CreateSMS")
End Sub

Public Function ReplaceEncoding(str As String) As String
On Error GoTo ErrorHandler
    str = VBA.Replace(str, "__%__", "'")
    str = VBA.Replace(str, "__$__", ",")
    str = VBA.Replace(str, "____", " ")
    str = VBA.Replace(str, "<br />", vbCrLf)
    
    ReplaceEncoding = str
Exit Function
ErrorHandler:
    Call UI.ShowError("SMS.ReplaceEncoding")
End Function


Public Function URLDecode(ByVal strEncodedURL As String) As String
   Dim str As String
   str = strEncodedURL
   If Len(str) > 0 Then
      str = Replace(str, "&amp", " & ")
      str = Replace(str, "&#03", Chr(39))
      str = Replace(str, "&quo", Chr(34))
      str = Replace(str, "+", " ")
      str = Replace(str, "%2A", "*")
      str = Replace(str, "%40", "@")
      str = Replace(str, "%2D", "-")
      str = Replace(str, "%5F", "_")
      str = Replace(str, "%2B", "+")
      str = Replace(str, "%2E", ".")
      str = Replace(str, "%2F", "/")

      URLDecode = str
  End If

End Function
