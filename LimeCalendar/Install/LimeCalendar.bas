Attribute VB_Name = "LimeCalendar"
Const nbrofmonths As Integer = 2

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

Public Function GetItems(ByVal startDateField As String, ByVal sFilter As String, ByVal sTable As String, ByVal sFields As String, Optional ByVal lIdCoworker As Long = 0) As LDE.Records
    On Error GoTo ErrorHandler:
    Dim oRecords As New LDE.Records
    Dim oFilter As New LDE.filter
    Dim oView As New LDE.view
    Dim sFieldsArray() As String
    Dim sField As Variant
    sFieldsArray = VBA.Split(sFields, ";")
    
    For Each sField In sFieldsArray
        oView.Add (VBA.CStr(sField))
    Next sField
    oView.Add ("id" + sTable)
    
    Call oFilter.AddCondition(startDateField, lkOpGreater, VBA.DateAdd("m", -nbrofmonths, VBA.Now))
    If sFilter = "mine" Then
        Call oFilter.AddCondition("coworker", lkOpEqual, ActiveUser.record.id)
        Call oFilter.AddOperator(lkOpAnd)
    ElseIf sFilter = "other" Then
        If Not lIdCoworker = 0 Then
            Call oFilter.AddCondition("coworker", lkOpEqual, lIdCoworker)
            Call oFilter.AddOperator(lkOpAnd)
        End If
    End If
    
    
    Call oRecords.Open(Database.Classes(sTable), oFilter, oView)
    Set GetItems = oRecords
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("LimeCalendar.GetItems")
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
