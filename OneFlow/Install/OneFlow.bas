Attribute VB_Name = "OneFlow"
Declare Function GetSystemMetrics32 Lib "user32" _
    Alias "GetSystemMetrics" (ByVal nIndex As Long) As Long

Public Function GetUserEmail() As String
    On Error GoTo ErrorHandler
    GetUserEmail = ""
    If Not ActiveUser Is Nothing Then
        If Not ActiveUser.Record Is Nothing Then
            GetUserEmail = ActiveUser.Record.Value("email")
        End If
    End If
    Exit Function
ErrorHandler:
    Call UI.ShowError("OneFlow.GetUserEmail")
End Function

Public Function GetDeal() As LDE.Record
    On Error GoTo ErrorHandler
    
    Set GetDeal = ActiveInspector.Record
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("OneFlow.GetUserEmail")
End Function


Public Function GetDocuments(ByVal sTable As String, ByVal sLinkField As String) As LDE.Records
    On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Dim oRecords As New LDE.Records
    Dim oView As New LDE.View
    If Not ActiveInspector Is Nothing Then
        Call oView.Add(sLinkField)
        Call oView.Add("comment")
        Call oView.Add("oneflowid", lkSortAscending)
        Call oView.Add("updatedoneflow")
        
        Call oFilter.AddCondition(sTable, lkOpEqual, ActiveInspector.Record.ID)
        Call oFilter.AddCondition(sLinkField, lkOpNotEqual, "")
        Call oFilter.AddOperator(lkOpAnd)
        Call oFilter.AddCondition("oneflowtoken", lkOpEqual, ActiveControls.GetValue("oneflowtoken"))
        Call oFilter.AddOperator(lkOpAnd)
        Call oRecords.Open(Database.Classes("document"), oFilter, oView)
    End If
    
    
    Set GetDocuments = oRecords
    Exit Function
ErrorHandler:
    Call UI.ShowError("OneFlow.GetDocuments")
End Function

Public Function GetIdDeal() As Long
    On Error GoTo ErrorHandler
    If Not ActiveInspector Is Nothing Then
        GetIdDeal = ActiveInspector.Record.ID
    End If
    Exit Function
ErrorHandler:
    Call UI.ShowError("OneFlow.GetUserEmail")
End Function

Public Function GetExternalParty() As LDE.Record
    On Error GoTo ErrorHandler
    Dim oRecord As New LDE.Record
    Call oRecord.Open(Database.Classes("company"), ActiveControls.GetValue("company"))
    Set GetExternalParty = oRecord
    Exit Function
ErrorHandler:
    Call UI.ShowError("OneFlow.GetExternalPart")
End Function

Public Function GetPersons() As LDE.Records
    On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Dim oRecords As New LDE.Records
    Dim oView As New LDE.View
    Dim lCompany As Long
    If Not ActiveControls Is Nothing Then
        If Not VBA.IsNull(ActiveControls.GetValue("company")) Then
            lCompany = ActiveControls.GetValue("company")
            
            Call oView.Add("firstname")
            Call oView.Add("lastname")
            Call oView.Add("mobilephone")
            Call oView.Add("email")
            Call oView.Add("idperson")
            Call oView.Add("company")
            
            Call oFilter.AddCondition("company", lkOpEqual, lCompany)
            Call oFilter.AddCondition("email", lkOpNotEqual, "")
            Call oFilter.AddOperator(lkOpAnd)
            Call oFilter.AddCondition("firstname", lkOpNotEqual, "")
            Call oFilter.AddOperator(lkOpAnd)
            Call oFilter.AddCondition("lastname", lkOpNotEqual, "")
            Call oFilter.AddOperator(lkOpAnd)
            
            Call oRecords.Open(Database.Classes("person"), oFilter, oView)
        End If
    End If
    Set GetPersons = oRecords
    Exit Function
ErrorHandler:
    Call UI.ShowError("OneFlow.GetPersons")
End Function

Public Function GetCoworkers() As LDE.Records
    On Error GoTo ErrorHandler
    Dim oFilter As New LDE.Filter
    Dim oRecords As New LDE.Records
    Dim oView As New LDE.View
    Call oView.Add("firstname")
    Call oView.Add("lastname")
    Call oView.Add("mobilephone")
    Call oView.Add("email")
    Call oView.Add("username")
    Call oView.Add("idcoworker")

    Call oFilter.AddCondition("email", lkOpNotEqual, "")
    Call oFilter.AddCondition("firstname", lkOpNotEqual, "")
    Call oFilter.AddOperator(lkOpAnd)
    Call oFilter.AddCondition("lastname", lkOpNotEqual, "")
    Call oFilter.AddOperator(lkOpAnd)
    
    Call oRecords.Open(Database.Classes("coworker"), oFilter, oView)
    
    Set GetCoworkers = oRecords
    Exit Function
ErrorHandler:
    Call UI.ShowError("OneFlow.GetPersons")
End Function

Public Sub OpenWindowed()
    On Error GoTo ErrorHandler
    Dim oDialog As New Lime.Dialog
    Dim idpersons As String
    Dim oItem As Lime.ExplorerItem
    oDialog.Type = lkDialogHTML
    oDialog.Property("url") = Application.WebFolder & "lbs.html?ap=/apps/OneFlow/Views/windowed&type=tab"
    oDialog.Property("height") = 0.7 * GetSystemMetrics32(1)
    oDialog.Property("width") = 0.6 * GetSystemMetrics32(0)
    oDialog.show

    Exit Sub
ErrorHandler:
    Call UI.ShowError("OpenWindowed.OpenWorkLoad")
End Sub

Public Sub OpenAgreement(ByVal sId As String)
    On Error GoTo ErrorHandler
    Dim sLink As String
    sLink = "https://app.oneflow.com/contracts/" + sId
    
    Call Application.Shell(sLink)
    Exit Sub
ErrorHandler:
    Call UI.ShowError("OneFlow.OpenAgreement")
End Sub

Public Sub openSetAccount()
    On Error GoTo ErrorHandler
    Dim oDialog As New Lime.Dialog
    Dim idpersons As String
    Dim oItem As Lime.ExplorerItem
    oDialog.Type = lkDialogHTML
    oDialog.Property("url") = Application.WebFolder & "lbs.html?ap=/apps/OneFlow/Views/setaccount&type=tab"
    oDialog.Property("height") = 0.7 * GetSystemMetrics32(1)
    oDialog.Property("width") = 0.6 * GetSystemMetrics32(0)
    oDialog.show
    Exit Sub
ErrorHandler:
    Call UI.ShowError("OneFlow.OpenAgreement")
End Sub

Public Function ParseCodes(ByVal sB64JSON As String) As String
    On Error GoTo ErrorHandler
    Dim sJSON As String
    Dim oJSON As Object
    Dim oItem As Object
    
    sJSON = DecodeBase64(sB64JSON)
    Set oJSON = JSON.parse(sJSON)
    
    For Each oItem In oJSON.Item("data")
        oItem("value") = ActiveInspector.Controls.GetText(oItem("lime_name"))
    Next oItem
    ParseCodes = JSON.toString(oJSON)
    Exit Function
ErrorHandler:
    Call UI.ShowError("OneFlow.ParseCodes")
End Function


Public Sub CreateAgreement(ByVal sName As String, ByVal sId As String, ByVal sTable As String)
    On Error GoTo ErrorHandler
    Dim sLink As String
    Dim oRecord As New LDE.Record
    
    sLink = "https://app.oneflow.com/contracts/" + sId
    Call oRecord.Open(Database.Classes("document"))
    oRecord.Value("comment") = DecodeBase64(sName)
    oRecord.Value("documentlink") = sLink
    oRecord.Value("oneflowid") = sId
    oRecord.Value("oneflowtoken") = ActiveControls.GetValue("oneflowtoken")
    oRecord.Value(sTable) = ActiveControls.Record.ID
    oRecord.Value("type") = oRecord.Fields("type").Options.Lookup("agreement", lkLookupOptionByKey).Value
    Call oRecord.Update
    
    ' KRÄÄÄÄK :(
    ' Måste ha servertid eftersom servertid kan skilja sig från klienttiden.
    oRecord.Value("updatedoneflow") = oRecord.ModifiedDate
    Call oRecord.Update
    Exit Sub
ErrorHandler:
    Call UI.ShowError("OneFlow.CreateAgreement")
End Sub



Public Sub Refresh()
    On Error GoTo ErrorHandler
    If Not ActiveInspector Is Nothing Then
        Call ActiveInspector.WebBar.Refresh
    End If
    Exit Sub
ErrorHandler:
    Call UI.ShowError("OneFlow.Refresh")
End Sub

Private Function DecodeBase64(ByVal strData As String) As String
 
    Dim objXML As MSXML2.DOMDocument60
    Dim objNode As MSXML2.IXMLDOMElement
    
    ' help from MSXML
    Set objXML = New MSXML2.DOMDocument60
    Set objNode = objXML.createElement("b64")
    objNode.DataType = "bin.base64"
    objNode.text = strData
    DecodeBase64 = VBA.StrConv(objNode.nodeTypedValue, vbUnicode)
    ' thanks, bye
    Set objNode = Nothing
    Set objXML = Nothing
 
End Function

Public Sub UpdateAgreement(ByVal sOneflowId As String)
    On Error GoTo ErrorHandler
    Dim oRecords As New LDE.Records
    Dim oRecord As New LDE.Record
    Dim oFilter As New LDE.Filter
    
    Call oFilter.AddCondition("oneflowid", lkOpEqual, sOneflowId)
    Call oRecords.Open(Database.Classes("document"), oFilter)
    Call oRecords(1).Update
    
    ' KRÄÄÄÄK :(
    ' Måste ha servertid eftersom servertid kan skilja sig från klienttiden.
    oRecords(1).Value("updatedoneflow") = oRecords(1).ModifiedDate
    Call oRecords(1).Update
    Exit Sub
ErrorHandler:
    Call UI.ShowError("OneFlow.UpdateAgreement")
End Sub

Public Sub SaveToken(ByVal sToken As String)
    On Error GoTo ErrorHandler
    If Globals.VerifyInspector("deal", ActiveInspector, False) Then
        Call ActiveControls.SetValue("oneflowtoken", sToken)
        Call ActiveControls.Save
        Call ActiveControls.Refresh
    End If
    Exit Sub
ErrorHandler:
    Call UI.ShowError("OneFlow.SaveToken")
End Sub
