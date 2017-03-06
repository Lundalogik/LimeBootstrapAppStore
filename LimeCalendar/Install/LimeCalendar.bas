Attribute VB_Name = "LimeCalendar"
Const NBR_OF_MONTHS As Integer = 2

Public Sub OpenCalendar()
    On Error GoTo ErrorHandler
    Dim oDialog As New Lime.Dialog
    Dim idpersons As String
    Dim oItem As Lime.ExplorerItem
    oDialog.Type = lkDialogHTML
    oDialog.Property("url") = Application.WebFolder & "lbs.html?ap=/apps/LimeCalendar/Views/view&type=tab"
    oDialog.Property("height") = 860
    oDialog.Property("width") = 1040
    oDialog.show
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("LimeCalendar.OpenCalendar")
End Sub

'ByVal startDateField As String, ByVal sOptions As String, ByVal sTable As String, ByVal sFields As String
Public Function GetItems(ByVal sOptions As String) As LDE.Records
    On Error GoTo ErrorHandler:
    Dim oRecords As New LDE.Records
    Dim oFilter As New LDE.filter
    Dim oView As New LDE.view
    Dim sFieldsArray() As String
    Dim sField As Variant
    Dim sJSON As String
    Dim oJSON As Object
    Dim oItem As Object
    
    sJSON = DecodeBase64(sOptions)
    Set oJSON = JSON.parse(sJSON)
    
    sFieldsArray = VBA.Split(oJSON.Item("fields"), ";")
    
    For Each sField In sFieldsArray
        oView.Add (VBA.CStr(sField))
    Next sField
    oView.Add ("id" + oJSON.Item("table"))
    
    Call oFilter.AddCondition(oJSON.Item("startfield"), lkOpGreater, VBA.DateAdd("m", -NBR_OF_MONTHS, VBA.Now))
    If oJSON.Item("filter") = "mine" Then
        Call oFilter.AddCondition("coworker", lkOpEqual, ActiveUser.record.id)
        Call oFilter.AddOperator(lkOpAnd)
    ElseIf oJSON.Item("filter") = "coworker" Then
        Call oFilter.AddCondition("coworker", lkOpEqual, oJSON.Item("idcoworker"))
        Call oFilter.AddOperator(lkOpAnd)
    ElseIf oJSON.Item("filter") = "group" Then
        Call oFilter.AddCondition("coworker." & oJSON.Item("groupFilter"), lkOpEqual, oJSON.Item("idgroup"))
        Call oFilter.AddOperator(lkOpAnd)
    End If
    
    
    Call oRecords.Open(Database.Classes(oJSON.Item("table")), oFilter, oView)
    Set GetItems = oRecords
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("LimeCalendar.GetItems")
End Function

Public Function GetFilterOptions(ByVal sClass As String, ByVal sField As String) As String
    On Error GoTo ErrorHandler
    Dim sRet As String
    Dim oOption As LDE.Option
    sRet = "<options>"
    For Each oOption In Database.Classes(sClass).Fields(sField).Options
        If oOption.text <> "" Then
            sRet = sRet & "<option><name>" & oOption.text & "</name><id>" & oOption.Value & "</id></option>"
        End If
    Next oOption
    sRet = sRet & "</options>"
    GetFilterOptions = sRet
    Exit Function
ErrorHandler:
    Call UI.ShowError("LimeCalendar.GetFilterOptions")
End Function

Public Function GetCoworkers() As LDE.Records
    On Error GoTo ErrorHandler
    Dim oRecords As New LDE.Records
    Dim oView As New LDE.view
    Call oView.Add("name", lkSortAscending)
    Call oView.Add("idcoworker")
    Call oRecords.Open(Database.Classes("coworker"), , oView)
    Set GetCoworkers = oRecords
    Exit Function
ErrorHandler:
    Call UI.ShowError("LimeCalendar.GetCoworkers")
End Function

Public Function GetGroups(ByVal sGroup As String) As LDE.Records
    On Error GoTo ErrorHandler
    Dim oRecords As New LDE.Records
    Dim oView As New LDE.view
    Dim sJSON As String
    Dim oJSON As Object
    Dim oItem As Object
    
    sJSON = DecodeBase64(sGroup)
    Set oJSON = JSON.parse(sJSON)
    
    Call oView.Add(oJSON.Item("title"), lkSortAscending)
    Call oView.Add("id" & oJSON.Item("table"))
    Call oRecords.Open(Database.Classes(oJSON.Item("table")), , oView)
    Set GetGroups = oRecords
    Exit Function
ErrorHandler:
    Call UI.ShowError("LimeCalendar.GetGroups")
End Function

Public Sub Save(ByVal sB64JSON As String)
    On Error GoTo ErrorHandler
    
    Dim sJSON As String
    Dim oJSON As Object
    Dim oItem As Object
    Dim oRecord As LDE.record
    Dim oFilter As LDE.filter
    Dim oBatch As New LDE.Batch
    
    sJSON = DecodeBase64(sB64JSON)
    Set oJSON = JSON.parse(sJSON)
    Set oBatch.Database = Application.Database
    
    For Each oItem In oJSON
        Set oRecord = New LDE.record
        Call oRecord.Open(Database.Classes(oItem("table")), oItem("id"))
        oRecord.Value(oItem("startfield")) = oItem("start")
        oRecord.Value(oItem("endfield")) = oItem("end")
        Call oRecord.Update(oBatch)
    Next oItem
    
    Call oBatch.Execute
    Exit Sub
ErrorHandler:
    Call UI.ShowError("LimeCalendar.Save")
End Sub

Public Sub OpenRecord(ByVal sLink As String)
    On Error GoTo ErrorHandler
    Call Application.Shell(sLink)
    Exit Sub
ErrorHandler:
    Call UI.ShowError("LimeCalendar.OpenRecord")
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

Public Function GetLocale() As String
    On Error GoTo ErrorHandler
    GetLocale = Application.Locale
    Exit Function
ErrorHandler:
    Call UI.ShowError("LimeCalendar.GetLocale")
End Function

Public Function GetTableLocale(ByVal sClass As String) As String
    On Error GoTo ErrorHandler
    GetTableLocale = Application.Database.Classes(sClass).LocalName
    Exit Function
ErrorHandler:
    Call UI.ShowError("LimeCalendar.GetTableLocale")
End Function

