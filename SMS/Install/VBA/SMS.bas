Attribute VB_Name = "SMS"
Option Explicit

Private m_TemplateCodes As Collection ' Filled With Class Modules: SmsTemplateCode
Public Const sAllTablesConstant_dbName As String = "all"

Public Function GetTemplateCodes() As Collection
On Error GoTo ErrorHandler
    If m_TemplateCodes Is Nothing Then
        Set m_TemplateCodes = New Collection
        
        ' Add template codes for person table
        Call m_TemplateCodes.Add(TemplateCode_Constructor("person", "%%firstname%%", "firstname", "Personens förnamn"))
        Call m_TemplateCodes.Add(TemplateCode_Constructor("person", "%%lastname%%", "lastname", "Personens efternamn"))
        Call m_TemplateCodes.Add(TemplateCode_Constructor("person", "%%fullname%%", "name", "Personens hela namn"))
    End If
    Set GetTemplateCodes = m_TemplateCodes
Exit Function
ErrorHandler:
    Call UI.ShowError("Sms.GetTemplateCodes")
End Function

Private Function FormatPhoneNr(ByVal sReceiverTableName As String, ByVal sPhoneNr As String) As String
On Error GoTo ErrorHandler
    Dim sNewNr As String
    
    Select Case sReceiverTableName
        'Case "person"
            'If on person do this
        Case Else
            sNewNr = FormatPhoneNrDefault(sPhoneNr)
    End Select
    FormatPhoneNr = sNewNr
Exit Function
ErrorHandler:
    Call UI.ShowError("Sms.FormatPhoneNr")
End Function

Public Sub OpenSMSModule(ByVal sGetReceiversFrom As String)
On Error GoTo ErrorHandler
    Dim oExplorer As Lime.Explorer
    Dim oInspector As Lime.Inspector
    
    Set oExplorer = Application.ActiveExplorer
    Set oInspector = Application.ActiveInspector

    Dim oDialog As New Lime.Dialog
    Dim sParameters As String
    sParameters = "&getReceiversFrom=" & sGetReceiversFrom
    Select Case sGetReceiversFrom
        Case "explorer"
            If oExplorer Is Nothing Then
                Call Lime.MessageBox("No explorer is active", vbCritical)
                Exit Sub
            End If
            sParameters = sParameters & "&classname=" & oExplorer.Class.Name
        Case "inspector"
            If oInspector Is Nothing Then
                Call Lime.MessageBox("No inspector is active", vbCritical)
                Exit Sub
            End If
            sParameters = sParameters & "&classname=" & oInspector.Class.Name
    End Select
    
    oDialog.Property("url") = ThisApplication.WebFolder & "lbs.html?ap=apps/SMS/sms" & sParameters
    oDialog.Property("width") = 800
    oDialog.Property("height") = 540
    Call oDialog.show(lkDialogHTML)

Exit Sub
ErrorHandler:
    Call UI.ShowError("SMS.OpenSMSModule")
End Sub

Public Function GetInitialData(ByVal sReceiverTable As String, ByVal sConfigXml As String) As String
On Error GoTo ErrorHandler
    Dim sXml As String
    Dim oActiveExplorer As Lime.Explorer
    
    Set oActiveExplorer = Application.ActiveExplorer ' Active Explorer in either Main list or in inspector
    sXml = "<root>"
    sXml = sXml & GetUsersXml()
    sXml = sXml & GetTemplatesXml(sConfigXml)
    sXml = sXml & GetReceiversXml(oActiveExplorer, Application.ActiveInspector, sConfigXml)
    sXml = sXml & GetTemplateCodesXml(sReceiverTable)
    sXml = sXml & "</root>"
    
    GetInitialData = sXml
    'Debug.Print sXml
Exit Function
ErrorHandler:
    Call UI.ShowError("Sms.GetInitialData")
End Function

Private Function GetTemplateCodesXml(ByVal sReceiverTable As String) As String
On Error GoTo ErrorHandler
    Dim oTemplateCodes As Collection
    Dim oTemplaceCode As SmsTemplateCode
    Dim sXml As String

    sXml = "<templateCodes>"
    Set oTemplateCodes = SMS.GetTemplateCodes()
    For Each oTemplaceCode In oTemplateCodes
        Select Case oTemplaceCode.sReceiverTableName
            Case sReceiverTable, SMS.sAllTablesConstant_dbName:
                sXml = sXml & Lime.FormatString("<templateCode description=""%1"" code=""%2"" />", oTemplaceCode.sDescription, oTemplaceCode.sTemplateCode)
        End Select
    Next oTemplaceCode
    sXml = sXml & "</templateCodes>"
    
    GetTemplateCodesXml = sXml
Exit Function
ErrorHandler:
    Call UI.ShowError("Sms.GetTemplateCodesXml")
End Function

Private Function GetReceiversXml(ByRef oExplorer As Lime.Explorer, ByRef oInspector As Lime.Inspector, ByVal sConfigXml As String) As String
On Error GoTo ErrorHandler

    Dim oPool As New LDE.Pool
    Dim oRecords As New LDE.Records
    Dim oRecord As New LDE.Record
    Dim oView As New LDE.View
    Dim sXml As String
    Dim sGetReceiversFrom As String
    Dim sNameFieldName As String
    Dim sReceiverTableName As String
    Dim sReceiverFromFields As String
    Dim sReceiverFromFieldsSplitted() As String
    Dim sReceiverFromField As String
    Dim sPhoneFieldName As String
    Dim sSelectionType As String
    Dim oClassToOpen As LDE.Class
    
    Dim i As Long
    
    Dim lngReceiversWithNoPhone As Long
    Dim sPhoneNr As String
    
    Dim oXml As New MSXML2.DOMDocument60
    
    sXml = "<receivers noPhone=""%%noPhone%%"">"
    'Debug.Print sConfigXml
    If oXml.loadXML(sConfigXml) Then
        If Not TryGetXmlValue(sGetReceiversFrom, oXml, "config/getReceiversFrom") _
            Or Not TryGetXmlValue(sNameFieldName, oXml, "config/receiverName") _
            Or Not TryGetXmlValue(sPhoneFieldName, oXml, "config/receiverMobilephone") _
            Or Not TryGetXmlValue(sSelectionType, oXml, "config/selectionType") _
            Or Not TryGetXmlValue(sReceiverTableName, oXml, "config/receiverTableName") _
            Or Not TryGetXmlValue(sReceiverFromFields, oXml, "config/receiverFromFields") _
        Then
            Call Lime.MessageBox("Error loading receivers")
        End If
        
        If VBA.Len(sReceiverFromFields) > 0 Then
            sReceiverFromFieldsSplitted = VBA.Split(sReceiverFromFields, ";")
        Else
            ReDim sReceiverFromFieldsSplitted(0)
            sReceiverFromFieldsSplitted(0) = ""
        End If
        
        For i = LBound(sReceiverFromFieldsSplitted) To UBound(sReceiverFromFieldsSplitted)
            sReceiverFromField = sReceiverFromFieldsSplitted(i)
            Call oView.Add(AddParentToStringIfExist(sReceiverFromField, sNameFieldName))
            Call oView.Add(AddParentToStringIfExist(sReceiverFromField, sPhoneFieldName))
            Call oView.Add(AddParentToStringIfExist(sReceiverFromField, "id" & sReceiverTableName))
        Next i
        
        If sGetReceiversFrom = "inspector" Then
            Set oClassToOpen = oInspector.Class
            Set oPool = New LDE.Pool
            Call oPool.Add(oInspector.Record.ID)
        ElseIf sGetReceiversFrom = "explorer" Then
            Set oClassToOpen = oExplorer.Class
            Select Case sSelectionType
                Case "selected"
                    Set oPool = oExplorer.Selection.Pool
                Case "all"
                    Set oPool = oExplorer.Items.Pool
            End Select
        End If
        Call oRecords.Open(oClassToOpen, oPool, oView)
            
        For Each oRecord In oRecords
            
            For i = LBound(sReceiverFromFieldsSplitted) To UBound(sReceiverFromFieldsSplitted)
                sReceiverFromField = sReceiverFromFieldsSplitted(i)
                
                sPhoneNr = FormatPhoneNr(sReceiverTableName, oRecord.text(AddParentToStringIfExist(sReceiverFromField, sPhoneFieldName)))
                If VBA.Len(sPhoneNr) > 0 Then
                    sXml = sXml & "<receiver>"
                    Call AddXmlElement(sXml, "id", VBA.CStr(oRecord.Value(AddParentToStringIfExist(sReceiverFromField, "id" & sReceiverTableName))))
                    Call AddXmlElement(sXml, "name", oRecord.text(AddParentToStringIfExist(sReceiverFromField, sNameFieldName)))
                    Call AddXmlElement(sXml, "phone", sPhoneNr)
                    sXml = sXml & "</receiver>"
                Else
                    If sReceiverFromField = "" Then
                        lngReceiversWithNoPhone = lngReceiversWithNoPhone + 1
                    Else
                        If VBA.IsNull(oRecord.Value(AddParentToStringIfExist(sReceiverFromField, "id" & sReceiverTableName))) = False Then
                            lngReceiversWithNoPhone = lngReceiversWithNoPhone + 1
                        End If
                    End If
                End If
            Next i
        Next oRecord
    End If
    sXml = sXml & "</receivers>"
    sXml = VBA.Replace(sXml, "%%noPhone%%", VBA.CStr(lngReceiversWithNoPhone))
    GetReceiversXml = sXml
Exit Function
ErrorHandler:
    Call UI.ShowError("SMS.GetReceiversXml")
End Function

Private Function GetTemplatesXml(ByVal sConfigXml As String) As String
On Error GoTo ErrorHandler
    Dim sXml As String
    Dim oRecord As New LDE.Record
    Dim oRecords As New LDE.Records
    Dim oView As New LDE.View
    Dim oFilter As New LDE.Filter
    Dim oXml As New MSXML2.DOMDocument60
    Dim sReceiverTableName As String
    
    
    sXml = "<templates>"
    
    If oXml.loadXML(sConfigXml) Then
        
        If Not TryGetXmlValue(sReceiverTableName, oXml, "config/receiverTableName") Then
            Call Lime.MessageBox("Failed to load Templates")
        End If
        Call oView.Add("name")
        Call oView.Add("message")
        Call oView.Add("default")
        
        Call oFilter.AddCondition("fortable", lkOpEqual, SMS.sAllTablesConstant_dbName)
        Call oFilter.AddCondition("fortable", lkOpEqual, sReceiverTableName)
        Call oFilter.AddOperator(lkOpOr)

        Call oFilter.AddCondition("inactive", lkOpEqual, 0)
        Call oFilter.AddOperator(lkOpAnd)

        Call oRecords.Open(Database.Classes("smstemplate"), oFilter, oView)

        For Each oRecord In oRecords
            sXml = sXml & "<template>"
            Call AddXmlElement(sXml, "id", VBA.CStr(oRecord.ID))
            Call AddXmlElement(sXml, "default", VBA.CStr(oRecord.Value("default")))
            Call AddXmlElement(sXml, "name", oRecord.text("name"))
            Call AddXmlElement(sXml, "message", oRecord.text("message"))
            sXml = sXml & "</template>"
        Next oRecord
    End If
    
    sXml = sXml & "</templates>"
    
    GetTemplatesXml = sXml
    
Exit Function
ErrorHandler:
    Call UI.ShowError("SMS.GetTemplatesXml")
End Function

Private Function GetUsersXml() As String
On Error GoTo ErrorHandler
    Dim sXml As String
    Dim oRecord As New LDE.Record
    Dim oRecords As New LDE.Records
    Dim oView As New LDE.View
    Dim oFilter As New LDE.Filter
    
    Call oView.Add("displayname")
    Call oView.Add("coworker", lkSortAscending)
    Call oView.Add("username")
    Call oView.Add("password")
    Call oView.Add("sender")
    Call oView.Add("default")
    Call oView.Add("serviceid")
    Call oView.Add("platformid")
    Call oView.Add("platformpartnerid")
    Call oView.Add("gateid")


    Call oFilter.AddCondition("coworker", lkOpEqual, Null)
    If Not Application.ActiveUser.Record Is Nothing Then
        Call oFilter.AddCondition("coworker", lkOpEqual, Application.ActiveUser.Record.ID)
        Call oFilter.AddOperator(lkOpOr)
    End If
    Call oFilter.AddCondition("inactive", lkOpEqual, 0)
    Call oFilter.AddOperator(lkOpAnd)
    
    Call oRecords.Open(Database.Classes("smsuser"), oFilter, oView)
    
    sXml = "<users>"
    For Each oRecord In oRecords
        sXml = sXml & "<user>"
        Call AddXmlElement(sXml, "id", VBA.CStr(oRecord.ID))
        Call AddXmlElement(sXml, "name", oRecord.text("displayname"))
        Call AddXmlElement(sXml, "username", oRecord.text("username"))
        Call AddXmlElement(sXml, "password", oRecord.text("password"))
        Call AddXmlElement(sXml, "source", oRecord.text("sender"))
        Call AddXmlElement(sXml, "default", VBA.CStr(oRecord.Value("default")))
        Call AddXmlElement(sXml, "serviceid", oRecord.text("serviceid"))
        Call AddXmlElement(sXml, "platformid", oRecord.text("platformid"))
        Call AddXmlElement(sXml, "platformpartnerid", oRecord.text("platformpartnerid"))
        Call AddXmlElement(sXml, "gateid", oRecord.text("gateid"))
        
        sXml = sXml & "</user>"
    Next oRecord
    sXml = sXml & "</users>"
    
    GetUsersXml = sXml
Exit Function
ErrorHandler:
    Call UI.ShowError("SMS.GetUsersXml")
End Function

Public Function SendAndCreateSms(ByVal sSmsXml As String, ByVal sConfigXml As String, ByVal sRelationXml As String) As String
On Error GoTo ErrorHandler
    
    Dim oSmsXml As New MSXML2.DOMDocument60, _
        oConfigXml As New MSXML2.DOMDocument60, _
        oRelationXml As New MSXML2.DOMDocument60, _
        oXmlNodes As MSXML2.IXMLDOMNodeList, _
        oXmlNode As MSXML2.IXMLDOMNode, _
        oXmlRelationNodes As MSXML2.IXMLDOMNodeList, _
        oXmlRelationNode As MSXML2.IXMLDOMNode, _
        oView As LDE.View, _
        oPool As LDE.Pool, _
        oRecords As LDE.Records, _
        oRecord As LDE.Record, _
        oResponse As SmsWebsericeResponse, _
        oBatch As LDE.Batch, _
        oSmsRecord As LDE.Record, _
        oReceiverErrors As New Scripting.Dictionary

    Dim sXml As String, _
        sErrorMessage As String, _
        sKey As Variant, _
        sOrgMessage As String, _
        sMessage As String, _
        sPhoneNr As String, _
        sPlatformId As String, _
        sPlatformPartnerId As String, _
        sGateId As String, _
        sServiceid As String, _
        sUsername As String, _
        sPassword As String, _
        sSender As String, _
        sSmsUser As String, _
        sReceiverTableName As String, _
        sPhoneFieldName As String, _
        sNameFieldName As String, _
        sRelationFieldNameReceiver As String, _
        sRelationFieldNameSms As String, _
        sSmsSupplier As String
        
    sErrorMessage = ""
    If oSmsXml.loadXML(sSmsXml) And oConfigXml.loadXML(sConfigXml) And oRelationXml.loadXML(sRelationXml) Then
        Set oXmlNodes = oSmsXml.selectNodes("/smsData/receivers/receiver")

        If Not TryGetXmlValue(sOrgMessage, oSmsXml, "/smsData/message") _
            Or Not TryGetXmlValue(sSmsUser, oSmsXml, "/smsData/smsuser") _
        Then
            sErrorMessage = Lime.FormatString("Error in loading smsDataXml: %0%0%1", "Missing XML element in smsData XML")
            GoTo EndOfFunction
        End If

        If Not TryGetXmlValue(sReceiverTableName, oConfigXml, "/config/receiverTableName") _
            Or Not TryGetXmlValue(sPhoneFieldName, oConfigXml, "/config/receiverMobilephone") _
            Or Not TryGetXmlValue(sNameFieldName, oConfigXml, "/config/receiverName") _
            Or Not TryGetXmlValue(sSmsSupplier, oConfigXml, "/config/smsSupplier") _
        Then
            sErrorMessage = Lime.FormatString("Error in loading configXml: %0%0%1", "Missing XML Element in config XML")
            GoTo EndOfFunction
        End If

        Set oPool = New LDE.Pool
        For Each oXmlNode In oXmlNodes
            Call oPool.Add(VBA.CLng(oXmlNode.text))
        Next oXmlNode

        Set oView = New LDE.View
        Call FillViewWithTemplateCodes(oView, sReceiverTableName)
        Call FillViewWithExtraRelationFields(oView, oRelationXml)
        Call oView.Add(sPhoneFieldName)
        Call oView.Add(sNameFieldName)

        Set oRecords = New LDE.Records
        Call oRecords.Open(Database.Classes("smsuser"), VBA.CLng(sSmsUser), VBA.Array("platformpartnerid", "platformid", "gateid", "username", "password", "sender", "serviceid"), 1)
        If oRecords.Count = 1 Then
            Set oRecord = oRecords.Item(1)

            sPlatformPartnerId = oRecord.Value("platformpartnerid")
            sPlatformId = oRecord.Value("platformid")
            sGateId = oRecord.Value("gateid")
            sUsername = oRecord.Value("username")
            sPassword = oRecord.Value("password")
            sSender = oRecord.Value("sender")
            sServiceid = oRecord.Value("serviceid")
        Else
            sErrorMessage = Lime.FormatString("Error in loading SmsUser: %0%0%1", "Can't find the sms user selected")
            GoTo EndOfFunction
        End If

        Set oRecords = New LDE.Records
        Call oRecords.Open(Database.Classes(sReceiverTableName), oPool, oView)
        Set oBatch = New LDE.Batch
        Set oBatch.Database = Application.Database
        
        For Each oRecord In oRecords
            sMessage = sOrgMessage
            Call ApplyTemplateCodesToText(sMessage, oRecord, sReceiverTableName)
            sPhoneNr = FormatPhoneNr(sReceiverTableName, oRecord.Value(sPhoneFieldName))
            
            Dim oParameters As New SmsWebserviceParameters
            oParameters.sSmsSupplier = sSmsSupplier
            oParameters.sSender = sSender
            oParameters.sUsername = sUsername
            oParameters.sPassword = sPassword
            oParameters.sPhoneNr = sPhoneNr
            oParameters.sMessage = sMessage
            
            ' Link Mobility Soap Api
            oParameters.sServiceid = sServiceid
            
            ' Link Mobility Rest Api
            oParameters.sPlatformId = sPlatformId
            oParameters.sPlatformPartnerId = sPlatformPartnerId
            oParameters.sGateId = sGateId

            
            Set oResponse = WebRequest_SendSms_Master(oParameters)
            
            Set oSmsRecord = New LDE.Record
            Call oSmsRecord.Open(Database.Classes("sms"))
            oSmsRecord.Value("phone") = sPhoneNr
            oSmsRecord.Value("sent") = VBA.Now
            Call oSmsRecord.SelectOption("smsstatus", VBA.IIf(oResponse.bSuccess, "sent", "failure"))
            oSmsRecord.Value("smsuser") = VBA.CLng(sSmsUser)
            oSmsRecord.Value("message") = VBA.Replace(sMessage, "%0", VBA.vbNewLine)
            oSmsRecord.Value("messageid") = oResponse.sMessageId
            oSmsRecord.Value("resultcode") = oResponse.sCode
            oSmsRecord.Value("resultdescription") = oResponse.sMessage
            
            If oSmsRecord.Fields.Exists(sReceiverTableName) Then
                oSmsRecord.Value(sReceiverTableName) = oRecord.ID
            End If
            
            ' Set additional field relations given in app config (Relations on the active Inspector)
            Set oXmlRelationNodes = oRelationXml.selectNodes("/relationData/fieldRelations/fieldRelation")
            If Not oXmlRelationNodes Is Nothing Then
                For Each oXmlRelationNode In oXmlRelationNodes
                    If TryGetXmlValue(sRelationFieldNameReceiver, oXmlRelationNode, "fieldNameReceiver") And _
                        TryGetXmlValue(sRelationFieldNameSms, oXmlRelationNode, "fieldNameSms") _
                    Then
                        If oSmsRecord.Fields.Exists(sRelationFieldNameSms) And oRecord.Fields.Exists(sRelationFieldNameReceiver) Then
                            oSmsRecord.Value(sRelationFieldNameSms) = oRecord.Value(sRelationFieldNameReceiver)
                        End If
                    End If
                Next oXmlRelationNode
            End If
            
            
            Call oSmsRecord.Update(oBatch)
            
            If oBatch.Count > 200 Then
                Call oBatch.Execute
            End If
            
            If oResponse.bSuccess = False Then
                Call oReceiverErrors.Add(VBA.CStr(oRecord.ID), oResponse.sMessage)
            End If
        Next oRecord
        
        If oBatch.Count > 0 Then
            Call oBatch.Execute
        End If
    Else
        sErrorMessage = Lime.FormatString("Error in loading Xml: %0%0%1", "Invalid Xml in smsData or configXml")
        GoTo EndOfFunction
    End If
EndOfFunction:
    sXml = "<results>"
    If sErrorMessage <> "" Then
        Call AddXmlElement(sXml, "criticalError", sErrorMessage)
    Else
        sXml = sXml & "<receiverErrors>"
        For Each sKey In oReceiverErrors
            sXml = sXml & "<receiverError>"
            Call AddXmlElement(sXml, "id", sKey)
            Call AddXmlElement(sXml, "message", oReceiverErrors(sKey))
            sXml = sXml & "</receiverError>"
        Next sKey
        sXml = sXml & "</receiverErrors>"
    End If
    
    sXml = sXml & "</results>"
    
    SendAndCreateSms = sXml
Exit Function
ErrorHandler:
    sXml = "<results>"
    Call AddXmlElement(sXml, "criticalError", Lime.FormatString("Error in VBA: %0%0%1: %2", Err.Number, Err.Description))
    sXml = sXml & "</results>"
    SendAndCreateSms = sXml
End Function

Public Sub ShowReceivers(ByVal sReceiverXml As String, ByVal sReceiverTable As String)
On Error GoTo ErrorHandler
    Dim oXml As New MSXML2.DOMDocument60, _
        oXmlNodes As MSXML2.IXMLDOMNodeList, _
        oXmlNode As MSXML2.IXMLDOMNode, _
        sReceiverId As String, _
        oPool As New LDE.Pool, _
        oExplorer As Lime.Explorer, _
        oFilter As New LDE.Filter
    
    If oXml.loadXML(sReceiverXml) Then
        Set oXmlNodes = oXml.selectNodes("/receivers/receiver")
        For Each oXmlNode In oXmlNodes
            If TryGetXmlValue(sReceiverId, oXmlNode, ".") Then
                Call oPool.Add(VBA.CLng(sReceiverId))
            End If
        Next oXmlNode
    End If
    
    If Application.Explorers.Exists(sReceiverTable) Then
        Call oFilter.AddCondition("id" & sReceiverTable, lkOpIn, oPool)
        oFilter.Name = Localize.GetText("sms", "error_filtername")
        
        Set oExplorer = Application.Explorers(sReceiverTable)
        Set Application.Explorers.ActiveExplorer = oExplorer
        Set oExplorer.ActiveFilter = oFilter
        Call oExplorer.Requery
        
    End If
Exit Sub
ErrorHandler:
    Call UI.ShowError("Sms.ShowReceivers")
End Sub

Private Function WebRequest_SendSms_Master( _
    ByVal oParameters As SmsWebserviceParameters _
) As SmsWebsericeResponse
On Error GoTo ErrorHandler
    Dim oResponse As SmsWebsericeResponse
    
    Select Case oParameters.sSmsSupplier
        Case "link_mobility"
            Set oResponse = WebRequest_SendSms_LinkMobilityRest(oParameters)
    End Select
    
    Set WebRequest_SendSms_Master = oResponse
    
Exit Function
ErrorHandler:
    Call UI.ShowError("Sms.WebRequest_SendSms_Master")
End Function

Private Function WebRequest_SendSms_LinkMobilityRest( _
    ByVal oParameters As SmsWebserviceParameters _
) As SmsWebsericeResponse
On Error GoTo ErrorHandler
    Dim oHttp As New MSXML2.ServerXMLHTTP60, _
        sPayload As String, _
        oJsonObj As Dictionary, _
        oResponse As New SmsWebsericeResponse
    
    Call oHttp.Open("Post", "https://wsx.sp247.net/sms/send", False, oParameters.sUsername, oParameters.sPassword)
    Call oHttp.setRequestHeader("Content-type", "application/json")
    
    sPayload = "{" & _
        Lime.FormatString("""source"": ""%1"",", oParameters.sSender) & _
        Lime.FormatString("""destination"": ""%1"",", oParameters.sPhoneNr) & _
        Lime.FormatString("""userData"": ""%1"",", VBA.Replace(VBA.Replace(oParameters.sMessage, """", "\"""), "%0", "\n")) & _
        Lime.FormatString("""platformId"": ""%1"",", oParameters.sPlatformId) & _
        Lime.FormatString("""platformPartnerId"": ""%1"",", oParameters.sPlatformPartnerId) & _
        Lime.FormatString("""useDeliveryReport"": ""%1""", "false") & _
    "}"
    Call oHttp.Send(sPayload)
    
    If oHttp.Status = 200 Then
        oResponse.bSuccess = True
        Set oJsonObj = JsonConverter.ParseJson(oHttp.responseText)
        oResponse.sCode = oJsonObj("resultCode")
        oResponse.sMessage = oJsonObj("description")
        oResponse.sMessageId = oJsonObj("messageId")
    Else
        oResponse.bSuccess = False
        Set oJsonObj = JsonConverter.ParseJson(oHttp.responseText)
        oResponse.sCode = oJsonObj("status")
        oResponse.sMessage = oJsonObj("description")
    End If
    
    Set WebRequest_SendSms_LinkMobilityRest = oResponse
Exit Function
ErrorHandler:
    Call UI.ShowError("WebRequest_SendSms_LinkMobilityRest")
End Function

'''''''''''''''''''
'' START: Helperfunctions
'''''''''''''''''''
Private Sub AddXmlElement(ByRef sXml As String, ByVal sElementName As String, ByVal sElementValue As String)
On Error GoTo ErrorHandler
    sXml = sXml & Lime.FormatString("<%1><![CDATA[%2]]></%1>", sElementName, sElementValue)
Exit Sub
ErrorHandler:
    Call UI.ShowError("DataFlow.AddXmlElement")
End Sub

Private Function FormatPhoneNrDefault(ByVal sPhoneNr As String) As String
On Error GoTo ErrorHandler
    Dim sNewNr As String, i As Long, sChar As String
    If VBA.Len(sPhoneNr) >= 9 And VBA.InStr(sPhoneNr, 0) = 1 Then
        sPhoneNr = VBA.Replace(sPhoneNr, "0", "+46", , 1)
    End If
    
    For i = 1 To VBA.Len(sPhoneNr)
        sChar = VBA.Mid(sPhoneNr, i, 1)
        Select Case sChar
            Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+"
            Case Else
                sChar = ""
        End Select
        sNewNr = sNewNr & sChar
    Next i
    
    FormatPhoneNrDefault = sNewNr
Exit Function
ErrorHandler:
    Call UI.ShowError("Sms.FormatPhoneNrDefault")
End Function

Private Function TemplateCode_Constructor( _
    ByVal sReceiverTableName As String, _
    ByVal sTemplateCode As String, _
    ByVal sFieldName As String, _
    ByVal sDescription As String _
) As SmsTemplateCode
On Error GoTo ErrorHandler
    Dim oSmsTemplateCode As New SmsTemplateCode
    oSmsTemplateCode.sReceiverTableName = sReceiverTableName
    oSmsTemplateCode.sTemplateCode = sTemplateCode
    oSmsTemplateCode.sFieldName = sFieldName
    oSmsTemplateCode.sDescription = sDescription
    Set TemplateCode_Constructor = oSmsTemplateCode
Exit Function
ErrorHandler:
    Call UI.ShowError("Sms.TemplateCode_Constructor")
End Function

Private Sub FillViewWithTemplateCodes(ByRef oView As LDE.View, ByVal sReceiverTableName As String)
On Error GoTo ErrorHandler
    Dim oTemplateCodes As Collection, _
        oTemplateCode As SmsTemplateCode
        
    Set oTemplateCodes = GetTemplateCodes
    For Each oTemplateCode In oTemplateCodes
        Select Case oTemplateCode.sReceiverTableName
            Case sReceiverTableName, SMS.sAllTablesConstant_dbName:
                Call oView.Add(oTemplateCode.sFieldName, lkSortNone, True, oTemplateCode.sTemplateCode)
        End Select
    Next oTemplateCode
Exit Sub
ErrorHandler:
    Call UI.ShowError("Sms.FillViewWithTemplateCodes")
End Sub

Private Sub ApplyTemplateCodesToText(ByRef sMessage As String, ByVal oRecord As LDE.Record, ByVal sReceiverTableName As String)
On Error GoTo ErrorHandler
    Dim oTemplateCodes As Collection, _
        oTemplateCode As SmsTemplateCode
        
    Set oTemplateCodes = GetTemplateCodes
    For Each oTemplateCode In oTemplateCodes
        Select Case oTemplateCode.sReceiverTableName
            Case sReceiverTableName, SMS.sAllTablesConstant_dbName:
                If Not oRecord.Fields.Lookup(oTemplateCode.sFieldName, lkLookupFieldByName) Is Nothing Then
                    sMessage = VBA.Replace(sMessage, oTemplateCode.sTemplateCode, oRecord.Value(oTemplateCode.sFieldName))
                End If
        End Select
    Next oTemplateCode
Exit Sub
ErrorHandler:
    Call UI.ShowError("Sms.ApplyTemplateCodesToText")
End Sub

Private Sub FillViewWithExtraRelationFields(ByRef oView As LDE.View, ByVal oRelationXml As MSXML2.DOMDocument60)
On Error GoTo ErrorHandler
    Dim oXmlNodes As MSXML2.IXMLDOMNodeList, _
        oXmlNode As MSXML2.IXMLDOMNode, _
        sFieldName As String
        
    Set oXmlNodes = oRelationXml.selectNodes("/relationData/fieldRelations/fieldRelation")
    For Each oXmlNode In oXmlNodes
        If TryGetXmlValue(sFieldName, oXmlNode, "fieldNameReceiver") Then
            Call oView.Add(sFieldName)
        End If
    Next oXmlNode
Exit Sub
ErrorHandler:
    Call UI.ShowError("Sms.FillViewWithExtraRelationFields")
End Sub

Private Function AddParentToStringIfExist(ByVal sParent As String, ByVal sField As String) As String
On Error GoTo ErrorHandler
    Dim sPrefix As String
    sPrefix = ""
    If sParent <> "" Then
        sPrefix = sParent & "."
    End If
    
    AddParentToStringIfExist = sPrefix & sField
Exit Function
ErrorHandler:
    Call UI.ShowError("SMS.AddParentToStringIfExist")
End Function

Private Function TryGetXmlValue(ByRef sValue As String, ByRef oXml As MSXML2.IXMLDOMNode, ByVal sXPath As String) As Boolean
On Error GoTo ErrorHandler
    Dim bRetVal As Boolean
    Dim oXmlNode As MSXML2.IXMLDOMNode
    bRetVal = False
    
    Set oXmlNode = oXml.selectSingleNode(sXPath)
    
    If Not oXmlNode Is Nothing Then
        sValue = oXmlNode.text
        bRetVal = True
    End If
    
    TryGetXmlValue = bRetVal
Exit Function
ErrorHandler:
    sValue = ""
    TryGetXmlValue = False
    Call UI.ShowError("Sms.TryGetXmlValue")
End Function

'''''''''''''''''''
'' End: Helperfunctions
'''''''''''''''''''


'''''''''''''''''''
'' START: Install functions
'''''''''''''''''''
Public Sub Install()
On Error GoTo ErrorHandler
    Dim sOwner As String
    sOwner = "sms"

    
    Call AddOrCheckLocalize( _
        sOwner, _
        "fortable_all", _
        "Used for the Sms app", _
        "All", _
        "Alla", _
        "All", _
        "All", _
        "All" _
    )

    Call AddOrCheckLocalize( _
        sOwner, _
        "formHeader", _
        "Used for the Sms app", _
        "SMS", _
        "SMS", _
        "SMS", _
        "SMS", _
        "SMS" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_headLine", _
        "Used for the Sms app", _
        "Message", _
        "Meddelande", _
        "Message", _
        "Message", _
        "Message" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_advancedSettings", _
        "Used for the Sms app", _
        "Advanced settings", _
        "Avancerade inställningar", _
        "Advanced settings", _
        "Advanced settings", _
        "Advanced settings" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_radio_free", _
        "Used for the Sms app", _
        "Free text", _
        "Fritext", _
        "Free text", _
        "Free text", _
        "Free text" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_radio_template", _
        "Used for the Sms app", _
        "Template", _
        "Mall", _
        "Template", _
        "Template", _
        "Template" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_templates_novalue", _
        "Used for the Sms app", _
        "<No template>", _
        "<Ingen mall>", _
        "<No template>", _
        "<No template>", _
        "<No template>" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_users_novalue", _
        "Used for the Sms app", _
        "<No user>", _
        "<Ingen användare>", _
        "<No user>", _
        "<No user>", _
        "<No user>" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_user_label", _
        "Used for the Sms app", _
        "SMS user", _
        "SMS-användare", _
        "SMS user", _
        "SMS user", _
        "SMS user" _
    )
    
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_message_placeholder", _
        "Used for the Sms app", _
        "Message text...", _
        "Meddelandetext...", _
        "Message text...", _
        "Message text...", _
        "Message text..." _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_receiver_header", _
        "Used for the Sms app", _
        "Receivers (%1)", _
        "Mottagare (%1)", _
        "Receivers (%1)", _
        "Receivers (%1)", _
        "Receivers (%1)" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_receiver_nophone", _
        "Used for the Sms app", _
        "%1 receivers was removed due to no phone number", _
        "%1 mottagare togs bort för att de/n inte har något nummer", _
        "%1 receivers was removed due to no phone number", _
        "%1 receivers was removed due to no phone number", _
        "%1 receivers was removed due to no phone number" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_receiver_header_name", _
        "Used for the Sms app", _
        "Name", _
        "Namn", _
        "Name", _
        "Name", _
        "Name" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_receiver_header_number", _
        "Used for the Sms app", _
        "Phone", _
        "Telefon", _
        "Phone", _
        "Phone", _
        "Phone" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_button_close", _
        "Used for the Sms app", _
        "Close", _
        "Stäng", _
        "Close", _
        "Close", _
        "Close" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_button_send", _
        "Used for the Sms app", _
        "Send", _
        "Skicka", _
        "Send", _
        "Send", _
        "Send" _
    )

    Call AddOrCheckLocalize( _
        sOwner, _
        "form_button_close", _
        "Used for the Sms app", _
        "Close", _
        "Stäng", _
        "Close", _
        "Close", _
        "Close" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "templatecodesHeader", _
        "Used for the Sms app", _
        "Template codes", _
        "Styrkoder", _
        "Template codes", _
        "Template codes", _
        "Template codes" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "codeTooltip", _
        "Used for the Sms app", _
        "Click to insert in message text", _
        "Klicka för att infoga i meddelandetexten", _
        "Click to insert in message text", _
        "Click to insert in message text", _
        "Click to insert in message text" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_loadingText", _
        "Used for the Sms app", _
        "Sending SMS...", _
        "Skickar SMS...", _
        "Sending SMS...", _
        "Sending SMS...", _
        "Sending SMS..." _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_successText", _
        "Used for the Sms app", _
        "SMS are sent to the SMS supplier", _
        "SMS är skickade till SMS-leverantören", _
        "SMS are sent to the SMS supplier", _
        "SMS are sent to the SMS supplier", _
        "SMS are sent to the SMS supplier" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_criticalErrorText", _
        "Used for the Sms app", _
        "Something went wrong, see below for more information", _
        "Något gick fel, se nedan för mer information", _
        "Something went wrong, see below for more information", _
        "Something went wrong, see below for more information", _
        "Something went wrong, see below for more information" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_failedPersons_Title", _
        "Used for the Sms app", _
        "The following receivers didn't get a SMS (See sms tab for more info)", _
        "Följande mottagare fick inte SMS (Se sms-flik för mer info)", _
        "The following receivers didn't get a SMS (See sms tab for more info)", _
        "The following receivers didn't get a SMS (See sms tab for more info)", _
        "The following receivers didn't get a SMS (See sms tab for more info)" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_moreInfoText", _
        "Used for the Sms app", _
        "See sms tab for more info", _
        "Se sms-flik för mer info", _
        "See sms tab for more info", _
        "See sms tab for more info", _
        "See sms tab for more info" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_errorCountFormat", _
        "Used for the Sms app %1 is failed, %2 is succeeded and %3 is total number receivers", _
        "%1 receivers failed out of %3", _
        "%1 misslyckades utav %3", _
        "%1 receivers failed out of %3", _
        "%1 receivers failed out of %3", _
        "%1 receivers failed out of %3" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "form_clickForReceiver", _
        "Used for the Sms app", _
        "Click here to see failed receivers in the main list", _
        "Klicka här för att se misslyckade mottagare i huvudlistan", _
        "Click here to see failed receivers in the main list", _
        "Click here to see failed receivers in the main list", _
        "Click here to see failed receivers in the main list" _
    )
    
    Call AddOrCheckLocalize( _
        sOwner, _
        "error_filtername", _
        "Used for the Sms app", _
        "Failed receivers", _
        "Misslyckade mottagare", _
        "Failed receivers", _
        "Failed receivers", _
        "Failed receivers" _
    )
    
Exit Sub
ErrorHandler:
    Call UI.ShowError("Sms.Install")
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
    On Error GoTo ErrorHandler
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
        oRec.Value("owner") = sOwner
        oRec.Value("code") = sCode
        oRec.Value("context") = sDescription
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
        oRec.Value("owner") = sOwner
        oRec.Value("code") = sCode
        oRec.Value("context") = sDescription
        Call AddLocaleToRecord(oRec, "sv", sSV)
        Call AddLocaleToRecord(oRec, "en_us", sEN_US)
        Call AddLocaleToRecord(oRec, "no", sNO)
        Call AddLocaleToRecord(oRec, "fi", sFI)
        Call AddLocaleToRecord(oRec, "da", sDA)
        Call oRec.Update
        
    Else
        Call Lime.MessageBox("There are multiple copies of " & sOwner & "." & sCode & "  which is bad! Fix it", vbCritical, "To many translations makes Jack a dull boy")
    End If
    
    Set Localize.dicLookup = Nothing
    AddOrCheckLocalize = True
    Exit Function
ErrorHandler:
    Debug.Print ("Error while validating or adding Localize: " & Err.Description)
    AddOrCheckLocalize = False
End Function

Private Sub AddLocaleToRecord(ByRef oRec As LDE.Record, ByVal sLocaleCode As String, ByVal sLocaleValue As String)
On Error GoTo ErrorHandler
    If oRec.Fields.Exists(sLocaleCode) Then
        oRec.Value(sLocaleCode) = sLocaleValue
    End If
Exit Sub
ErrorHandler:
    Call UI.ShowError("Sms.AddLocaleToRecord")
End Sub

'''''''''''''''''''
'' End: Install functions
'''''''''''''''''''




