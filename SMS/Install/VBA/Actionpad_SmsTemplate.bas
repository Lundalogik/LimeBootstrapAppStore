Attribute VB_Name = "Actionpad_SmsTemplate"
Option Explicit

Public Function GetTemplateCodes() As String
On Error GoTo ErrorHandler
    Dim oTemplateCodes As Collection
    Dim oTemplaceCode As SmsTemplateCode
    Dim sTableOwner As String
    Dim sXml As String
    Dim oInspector As Lime.Inspector
    Set oInspector = Application.ActiveInspector
    
    sXml = "<templateCodes>"
    If Not oInspector Is Nothing Then
        sTableOwner = oInspector.Controls.GetValue("fortable")
        Set oTemplateCodes = SMS.GetTemplateCodes()
        For Each oTemplaceCode In oTemplateCodes
            Select Case oTemplaceCode.sReceiverTableName
                Case sTableOwner, SMS.sAllTablesConstant_dbName:
                    sXml = sXml & Lime.FormatString("<templateCode description=""%1"" code=""%2"" />", oTemplaceCode.sDescription, oTemplaceCode.sTemplateCode)
            End Select
        Next oTemplaceCode
    End If
    sXml = sXml & "</templateCodes>"
    
    GetTemplateCodes = sXml
Exit Function
ErrorHandler:
    Call UI.ShowError("Actionpad_SmsTemplate.GetTemplateCodes")
End Function

Public Sub InsertTextToMessage(ByVal sTextToInsert As String)
On Error GoTo ErrorHandler
    Dim oInspector As Lime.Inspector
    Set oInspector = Application.ActiveInspector
    If Globals.VerifyInspector("smstemplate", oInspector, True) Then
        If oInspector.Controls.Exists("message") Then
            Call oInspector.Controls.SetValue("message", oInspector.Controls.GetValue("message", "") & sTextToInsert)
        End If
    End If
Exit Sub
ErrorHandler:
    Call UI.ShowError("Actionpad_SmsTemplate.InsertTextToMessage")
End Sub
