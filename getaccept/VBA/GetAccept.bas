Attribute VB_Name = "GetAccept"
Option Explicit
Private GlobalPersonSourceTab As String
Private GlobalPersonSourceField As String

Declare Function GetSystemMetrics32 Lib "user32" _
    Alias "GetSystemMetrics" (ByVal nIndex As Long) As Long
Public TokenHandler As String

Public Sub SetTokens(strToken As String)
    On Error GoTo ErrorHandler
    
    'used to combine token between modal and parent actionpad
    TokenHandler = strToken
    If strToken = "-" Then
        TokenHandler = ""
    End If
    
    Exit Sub
ErrorHandler:
    UI.ShowError ("GetAccept.SetTokens")
End Sub

Public Function OpenGetAccept(className As String, personSourceTab As String, personSourceField As String) As String
    On Error GoTo ErrorHandler
    
    Dim oDialog As Lime.Dialog
    Dim oInspector As New Lime.Inspector
    Set oInspector = ThisApplication.ActiveInspector
    
    GlobalPersonSourceTab = personSourceTab
    GlobalPersonSourceField = personSourceField
        
    If Globals.VerifyInspector(className, oInspector) And GetAccept.SaveNew() Then
        If Not oInspector.ActiveExplorer Is Nothing Then
            If oInspector.ActiveExplorer.Class.Name = "document" Then
                If oInspector.ActiveExplorer.Selection.Count = 1 Then
                    Set oDialog = New Lime.Dialog
                    oDialog.Type = lkDialogHTML
                    oDialog.Property("url") = Application.WebFolder & "lbs.html?ap=apps/getaccept/getaccept&type=tab"
                    oDialog.Property("height") = 500
                    oDialog.Property("width") = 700
                    oDialog.show
                    OpenGetAccept = TokenHandler
                    Exit Function
                Else
                    Call Lime.MessageBox(Localize.GetText("GetAccept", "i_only_one_document"))
                    OpenGetAccept = "-1"
                    Exit Function
                End If
            Else
                Call Lime.MessageBox(Localize.GetText("GetAccept", "i_no_document_tab_selected"))
            End If
        End If
    End If
    
    GlobalPersonSourceTab = ""
    GlobalPersonSourceField = ""
    
    Exit Function
ErrorHandler:
    UI.ShowError ("GetAccept.OpenGetAccept")
End Function

Public Function GetContactList(className As String) As String
    'Get the contacts from the connected company
 
    On Error GoTo ErrorHandler
    
    Dim oRecords As LDE.Records
    Dim oRecord As LDE.Record
    Dim oView As LDE.View
    Dim oFilter As LDE.Filter
    Dim oInspector As Lime.Inspector
    Dim strJSON As String
    Dim i As Integer
    
    Set oInspector = Application.ActiveInspector
    If Globals.VerifyInspector(className, oInspector) And GetAccept.SaveNew() Then
        Set oView = New LDE.View
        Call oView.Add("firstname", lkSortAscending)
        Call oView.Add("lastname")
        Call oView.Add("email")
        Call oView.Add("mobilephone")
        
        If GlobalPersonSourceTab <> "" Then
            If oInspector.Explorers.Exists(GlobalPersonSourceTab) Then
                Set oFilter = New LDE.Filter
                Call oFilter.AddCondition(oInspector.Class.Name, lkOpEqual, oInspector.Record.ID)
                
                If oFilter.HitCount(Database.Classes(GlobalPersonSourceTab)) > 0 Then
                    Set oRecords = New LDE.Records
                    Call oRecords.Open(Database.Classes(GlobalPersonSourceTab), oFilter, oView)
                    strJSON = CreatePersonJSON(oRecords)
                End If
            Else
                Call Lime.MessageBox(Localize.GetText("GetAccept", "i_cant_get_person"))
                
            End If
        End If
        
        If GlobalPersonSourceField <> "" Then
            Set oFilter = New LDE.Filter
            Call oFilter.AddCondition(GlobalPersonSourceField, lkOpEqual, oInspector.Controls.GetValue(GlobalPersonSourceField))
            
            If oFilter.HitCount(Database.Classes("person")) > 0 Then
                Set oRecords = New LDE.Records
                Call oRecords.Open(Database.Classes("person"), oFilter, oView)
                strJSON = CreatePersonJSON(oRecords)
            End If
        End If
    End If
    GetContactList = strJSON

    Exit Function
ErrorHandler:
    Call UI.ShowError("GetAccept.GetContactList")
    GetContactList = ""
End Function

Public Function CreatePersonJSON(oRecords As LDE.Records) As String
    On Error GoTo ErrorHandler
    
    Dim i As Integer
    Dim oRecord As LDE.Record
    Dim strJSON As String
    i = 0
    strJSON = "{" + """Persons"":[{" _
    
    'loop through the persons and build up a JSON
    For Each oRecord In oRecords
        i = i + 1
        strJSON = strJSON + """firstname"":""" & oRecord("firstname") & """," _
        & """lastname"":""" & oRecord("lastname") & """," _
        & """mobilephone"":""" & oRecord("mobilephone") & """," _
        & """email"":""" & oRecord("email") & """" _
    
        If i < oRecords.Count Then
            strJSON = strJSON + "},{"
        Else
            strJSON = strJSON + "}"
        End If
        
    Next oRecord
    strJSON = strJSON + "]}"
    
    CreatePersonJSON = strJSON
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("GetAccept.CreatePersonJSON")
End Function

Public Function CheckDocuments(activeRecordId As Long, activeClass As String) As String
    On Error GoTo ErrorHandler
    'Check if there are any documents sent with GetAccept connected to the inspector
    Dim oRecords As New LDE.Records
    Dim oRecord As LDE.Record
    Dim oView As New LDE.View
    Dim oFilter As New LDE.Filter
    Dim retval As String
    Dim i As Integer
    i = 0
    
    Call oView.Add("iddocument")
    
    Call oFilter.AddCondition("sent_with_ga", lkOpEqual, 1)
    Call oFilter.AddCondition(activeClass, lkOpEqual, activeRecordId)
    Call oFilter.AddOperator(lkOpAnd)
    
    If oFilter.HitCount(Application.Classes("document")) > 0 Then
        Call oRecords.Open(Database.Classes("document"), oFilter, oView)
        For Each oRecord In oRecords
            i = i + 1
            retval = retval & oRecord.ID
            
            If i < oRecords.Count Then
                retval = retval & ","
            End If
        Next oRecord
        
        CheckDocuments = retval
        Exit Function
    Else
        CheckDocuments = False
        Exit Function
    End If
    
    Exit Function
ErrorHandler:
    UI.ShowError ("GetAccept.CheckDocuments")
    CheckDocuments = False
End Function

Public Function showList(sType As String) As Boolean
    On Error GoTo ErrorHandler
    'Check if there are any documents sent with GetAccept connected to the inspector
    Dim oFilter As New LDE.Filter
    Call oFilter.AddCondition("sent_with_ga", lkOpEqual, 1)
    Call oFilter.AddCondition(sType, lkOpEqual, ActiveInspector.Record.ID)
    Call oFilter.AddOperator(lkOpAnd)
    
    If oFilter.HitCount(Application.Classes("document")) > 0 Then
        showList = True
        Exit Function
    Else
        showList = False
        Exit Function
    End If
    
    Exit Function
ErrorHandler:
    UI.ShowError ("GetAccept.CheckDocuments")
    showList = False
End Function

Public Function GetDocumentData(className As String) As String
    'Collects the document data from the selected document in the table document
    On Error GoTo ErrorHandler
    
    Dim retval As String
    Dim oRecord As LDE.Record
    Dim oView As LDE.View
    Dim oInspector As New Lime.Inspector
    Set oInspector = ThisApplication.ActiveInspector
    
    If Globals.VerifyInspector(className, oInspector) And GetAccept.SaveNew() Then
        If Not oInspector.ActiveExplorer Is Nothing Then
            
            If oInspector.ActiveExplorer.Class.Name = "document" Then
                Set oRecord = New LDE.Record
                Set oView = New LDE.View
                Call oView.Add("document")
                Call oRecord.Open(Database.Classes("document"), oInspector.ActiveExplorer.Selection.Item(1).Record.ID, oView)
                retval = retval & EncodeBase64(oRecord.Document("document").Contents)
            Else
                Lime.MessageBox (Localize.GetText("GetAccept", "i_no_document_tab_selected"))
            End If
        End If
    End If
    
    GetDocumentData = retval
    
    Exit Function
ErrorHandler:
    UI.ShowError ("GetAccept.GetDocumentData")
    GetDocumentData = ""
End Function

Public Function GetDocumentDescription(className As String) As String
    'returns the document name and file extension
    On Error GoTo ErrorHandler
    
    Dim retval As String
    Dim oRecord As LDE.Record
    Dim oView As LDE.View
    Dim oInspector As New Lime.Inspector
    Set oInspector = ThisApplication.ActiveInspector
    ' The user has selected an document
    If Globals.VerifyInspector(className, oInspector) And GetAccept.SaveNew() Then
        If Not oInspector.ActiveExplorer Is Nothing Then
            If oInspector.ActiveExplorer.Class.Name = "document" Then
                Set oRecord = New LDE.Record
                Set oView = New LDE.View
                Call oView.Add("document")
                Call oView.Add("comment")
                
                Call oRecord.Open(Database.Classes("document"), oInspector.ActiveExplorer.Selection.Item(1).Record.ID, oView)
                retval = retval & oRecord.Value("comment")
                retval = retval & "."
                retval = retval & oRecord.Document("document").Extension
                
            End If
        End If
    End If
    
    GetDocumentDescription = retval
    Exit Function
ErrorHandler:
    UI.ShowError ("GetAccept.GetDocumentDescription")
End Function

Public Function GetDocumentId(className As String) As String
    'returns the document id
    On Error GoTo ErrorHandler
    
    Dim retval As String
    Dim oInspector As New Lime.Inspector
    Set oInspector = ThisApplication.ActiveInspector
    ' The user has selected an document
    If Globals.VerifyInspector(className, oInspector) And GetAccept.SaveNew() Then
        If Not oInspector.ActiveExplorer Is Nothing Then
            If oInspector.ActiveExplorer.Class.Name = "document" Then
                GetDocumentId = oInspector.ActiveExplorer.Selection.Item(1).Record.ID
            End If
        End If
    End If
    
    Exit Function
ErrorHandler:
    UI.ShowError ("GetAccept.GetDocumentId")
End Function

Public Sub SetDocumentStatus(sStatus As String, className As String)
    'set document sent_with_ga parameter
    On Error GoTo ErrorHandler
    
    Dim retval As String
    Dim oInspector As New Lime.Inspector
    Dim oRecordDocument As LDE.Record
    Set oInspector = ThisApplication.ActiveInspector
    
    ' The user has selected an document
    If Globals.VerifyInspector(className, oInspector) And GetAccept.SaveNew() Then
        If Not oInspector.ActiveExplorer Is Nothing Then
            If oInspector.ActiveExplorer.Class.Name = "document" Then
                
                If oInspector.ActiveExplorer.Selection.Count = 1 Then
                    ' Set sent_with_ga status
                    Set oRecordDocument = New LDE.Record
                    oRecordDocument.Open Classes("document"), oInspector.ActiveExplorer.Selection.Item(1).Record.ID
                    oRecordDocument.Value("sent_with_ga") = sStatus
                    Call oRecordDocument.Update
                    
                    ' Create historynote
                    Dim oRecordHistory As New LDE.Record
                    oRecordHistory.Open Classes("history")
                    ' Check that the field with same class name exist on the document which should be connected
                    If oRecordHistory.Fields.Exists(oInspector.Class.Name) Then
                        oRecordHistory.Value(oInspector.Class.Name) = oInspector.Record.ID
                    End If
                    oRecordHistory.Value("type") = Database.Classes("history").Fields("type").Options.Lookup("sentemail", lkLookupOptionByKey).Value
                    oRecordHistory.Value("note") = "Sent with GetAccept"
                    oRecordHistory.Value("date") = VBA.Now
                    oRecordHistory.Value("document") = oInspector.ActiveExplorer.Selection.Item(1).Record.ID
                    Call oRecordHistory.Update
                    
                Else
                    Lime.MessageBox (Localize.GetText("GetAccept", "i_only_one_document"))
                End If
                
            End If
        End If
    End If
    
    Exit Sub
ErrorHandler:
    UI.ShowError ("GetAccept.SetDocumentStatus")
End Sub

Public Sub OpenGALink(ByVal sLink As String)

    Call Application.Shell(sLink)
    
    Exit Sub
ErrorHandler:
    UI.ShowError ("GetAccept.OpenGALink")
End Sub

Private Function EncodeBase64(ByRef arrData() As Byte) As String
    On Error GoTo ErrorHandler
    
    Dim objXML As Object
    Dim objNode As Object
    
    Set objXML = CreateObject("MSXML2.DOMDocument")
    Set objNode = objXML.createElement("b64")
    objNode.DataType = "bin.base64"
    objNode.nodeTypedValue = arrData
    EncodeBase64 = objNode.text
 
    Set objNode = Nothing
    Set objXML = Nothing
    
    Exit Function
ErrorHandler:
        UI.ShowError ("GetAccept.EncodeBase64")
End Function

' ##SUMMARY Saves changes made in actionpad.
Public Function SaveNew() As Boolean
    On Error GoTo ErrorHandler
    
    Dim oInspector As Lime.Inspector
    
    Set oInspector = Application.ActiveInspector
    
    On Error GoTo ErrorSave
        If (oInspector.Record.State And lkRecordStateNew) = lkRecordStateNew Then
            Call oInspector.Save(True)
        End If
        GoTo SaveOK
ErrorSave:
        Lime.MessageBox (Err.Description)
        SaveNew = False
        Exit Function
SaveOK:
    SaveNew = True

    Exit Function
ErrorHandler:
    Call UI.ShowError("GetAccept.TrySave")
    SaveNew = False
End Function


Public Sub DownloadFile(sLink As String, sFileName As String, className As String, commentField As String)
    On Error GoTo ErrorHandler
    
    ThisApplication.MousePointer = 11
    Dim myURL As String
    myURL = sLink
    
    Dim oInspector As Lime.Inspector
    
    Set oInspector = Application.ActiveInspector
    
    Dim WinHttpReq As Object
    Dim oStream As Object
    Dim sFileLocation As String
    Dim sMapLocation As String
    Dim oRecord As New LDE.Record
    Dim pDocument As New LDE.Document
    
    
    sMapLocation = ThisApplication.TemporaryFolder & "\GetAccept\"
    sFileLocation = sMapLocation & sFileName & ".pdf"
    
    If Len(Dir(sMapLocation, vbDirectory)) = 0 Then
        MkDir sMapLocation
    End If
    
    Set WinHttpReq = CreateObject("WinHttp.WinHttpRequest.5.1")
    WinHttpReq.Open "GET", myURL, False
    WinHttpReq.Send
    
    myURL = WinHttpReq.responseBody
    If WinHttpReq.Status = 200 Then
        Set oStream = CreateObject("ADODB.Stream")
        oStream.Open
        oStream.Type = 1
        oStream.Write WinHttpReq.responseBody
        oStream.SaveToFile sFileLocation, 2 ' 1 = no overwrite, 2 = overwrite
        oStream.Close
        
        Call pDocument.Load(sFileLocation)
        Call oRecord.Open(Database.Classes("document"))
        oRecord.Value("document") = pDocument
        If oRecord.Fields.Exists("type") Then
            oRecord("type") = Database.Classes("document").Fields("type").Options.Lookup("agreement", lkLookupOptionByKey)
        End If
        If oRecord.Fields.Exists(className) Then
            oRecord(className) = oInspector.Record.ID
        End If
        'connect company if a company field exists on the parent card and the document card.
        If className <> "company" Then 'only done if the parent isnt alreaady the company
            If oRecord.Fields.Exists("company") Then
                If oInspector.Record.Fields.Exists("company") Then
                    oRecord("company") = oInspector.Controls.GetValue("company")
                End If
            End If
        End If
        
        oRecord(commentField) = sFileName & " (" & (Localize.GetText("GetAccept", "ga_signed")) & ")"
        oRecord("sent_with_ga") = 1
        oRecord.Update
         
    Else
        Call Lime.MessageBox(Localize.GetText("GetAccept", "i_download_failed"))
    End If
    
    VBA.Kill (sFileLocation)
    
    ThisApplication.MousePointer = 1
    Exit Sub
ErrorHandler:
    Call UI.ShowError("GetAccept.DownloadFile")
    ThisApplication.MousePointer = 1
End Sub

'Run Installation to get all transalations installed
'Only translated to Swedish and English
Public Sub Install()
    Dim sOwner As String
    sOwner = "GetAccept"
    
    'Login button
    Call AddOrCheckLocalize( _
        sOwner, _
        "login_button", _
        "Login button", _
        "Log in", _
        "Logga in", _
        "Log in", _
        "Log in" _
    )
    'Log out button
    Call AddOrCheckLocalize( _
        sOwner, _
        "logout_button", _
        "logout button", _
        "Log out", _
        "Logga ut", _
        "Log out", _
        "Log out" _
    )
    'Send document button
    Call AddOrCheckLocalize( _
        sOwner, _
        "send_document_button", _
        "Send document button", _
        "Send document", _
        "Skicka dokument", _
        "sende dokument", _
        "Lähetä dokumentti" _
    )
    'Send with GetAccept
    Call AddOrCheckLocalize( _
        sOwner, _
        "send_with_ga", _
        "Send with ga", _
        "Send with GetAccept", _
        "Skicka med GetAccept", _
        "Sende med GetAccept", _
        "Send with GetAccept" _
    )
    'Send with GetAccept
    Call AddOrCheckLocalize( _
        sOwner, _
        "open_in_ga", _
        "Open in GetAccept", _
        "Open in GetAccept", _
        "Öppna med GetAccept", _
        "Åpne med GetAccept", _
        "Avaa kanssa GetAccept" _
    )
    'Login to your GetAccept account
    Call AddOrCheckLocalize( _
        sOwner, _
        "login_to_ga", _
        "Login to your GetAccept", _
        "Login to your GetAccept", _
        "Logga in i GetAccept", _
        "Login to your GetAccept", _
        "Login to your GetAccept" _
    )
    'select_ga_entity
    Call AddOrCheckLocalize( _
        sOwner, _
        "select_ga_entity", _
        "Select Entity", _
        "Select Entity", _
        "Välj företagsenhet", _
        "Select Entity", _
        "Select Entity" _
    )
    'Signer
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_signer", _
        "Signer in GetAccept", _
        "Signer", _
        "Signerare", _
        "Signer", _
        "Signer" _
    )
    'ga_recipient
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_recipient", _
        "Recipient in GetAccept", _
        "Only Recipient (CC)", _
        "Mottagare (CC)", _
        "Only Recipient (CC)", _
        "Only Recipient (CC)" _
    )
    'You must select a document
    Call AddOrCheckLocalize( _
        sOwner, _
        "i_no_selected_document", _
        "No selected document", _
        "You must select a document to send", _
        "Du måste välja ett dokument att skicka", _
        "You must select a document to send", _
        "You must select a document to send" _
    )
    'You must select the document tab and select a document
    Call AddOrCheckLocalize( _
        sOwner, _
        "i_no_document_tab_selected", _
        "Document tab not selected", _
        "You must activate the Document tab and choose a document to send", _
        "Aktivera dokumentfliken och välj ett dokument att skicka", _
        "You must activate the Document tab and choose a document to send", _
        "You must activate the Document tab and choose a document to send" _
    )
    'i_cant_get_person
    Call AddOrCheckLocalize( _
        sOwner, _
        "i_cant_get_person", _
        "Cant get Person", _
        "Can't get persons from the tab configured, contact your administrator", _
        "Kan inte hämta personer från fliken som angivits, kontakta din administratör.", _
        "Can't get persons from the tab configured, contact your administrator", _
        "Can't get persons from the tab configured, contact your administrator" _
    )
    'i_download_failed
    Call AddOrCheckLocalize( _
        sOwner, _
        "i_download_failed", _
        "Download failed", _
        "The download of the document failed. Check you internet connection and try again. Contact your administrator if it still doesn't work", _
        "Nedladdningen av dokumentet misslyckades. Konrtollera din internetuppkoppling och försök igen. Kontakta din administratör om felet kvarstår", _
        "The download of the document failed. Check you internet connection and try again. Contact your administrator if it still doesn't work", _
        "The download of the document failed. Check you internet connection and try again. Contact your administrator if it still doesn't work" _
    )
    'This window will automatically be closed after the document has been processed
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_modal_closed", _
        "Modal closed", _
        "This window will automatically be closed after the document has been processed", _
        "Detta fönster kommer att stängas automatiskt när dokumentet bearbetats", _
        "This window will automatically be closed after the document has been processed", _
        "This window will automatically be closed after the document has been processed" _
    )
    'Download document
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_download", _
        "Download document", _
        "Download document", _
        "Ladda ner dokument", _
        "Download document", _
        "Download document" _
    )
    'Refresh list document
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_refresh", _
        "Refresh list", _
        "Refresh list", _
        "Uppdatera lista", _
        "Refresh list", _
        "Refresh list" _
    )
    'i_only_one_document
    Call AddOrCheckLocalize( _
        sOwner, _
        "i_only_one_document", _
        "Only one document", _
        "You can only send one document, select one document in the doucment list", _
        "Du kan endast skicka ett dokument i taget, markera ETT dokument i dokumentlistan", _
        "You can only send one document, select one document in the doucment list", _
        "You can only send one document, select one document in the doucment list" _
    )
    'Search
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_search", _
        "Status Search", _
        "Search", _
        "Sök", _
        "Search", _
        "Search" _
    )
    'Document name
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_document_name", _
        "Document name", _
        "Document name", _
        "Dokumentnamn", _
        "Document name", _
        "Document name" _
    )
    'At least one recipient
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_least_one_recipient", _
        "You must select at least one recipient", _
        "You must select at least one recipient", _
        "Du måste välja minst en mottagare", _
        "You must select at least one recipient", _
        "You must select at least one recipient" _
    )
    'At least one contact
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_least_one_contact", _
        "You must have at least one contact", _
        "You must have at least one contact", _
        "Du måste ha minst en kontakt", _
        "You must have at least one contact", _
        "You must have at least one contact" _
    )
    'Creating your document
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_creating_document", _
        "Creating your document", _
        "Creating your document", _
        "Skapar dokument", _
        "Creating your document", _
        "Creating your document" _
    )
    'Creating your document
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_uploading_document", _
        "Uploading document", _
        "Uploading document", _
        "Laddar upp dokument", _
        "Uploading document", _
        "Uploading document" _
    )
    'Sending document
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_sending_document", _
        "Sending document", _
        "Sendingdocument", _
        "Skickar dokument", _
        "Sending document", _
        "Sending document" _
    )
    'Sent
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_sent", _
        "Sent", _
        "Sent", _
        "Skickat", _
        "Sent", _
        "Sent" _
    )
    'Viewed
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_viewed", _
        "Viewed", _
        "Viewed", _
        "Öppnat", _
        "Viewed", _
        "Viewed" _
    )
    'Signed
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_signed", _
        "Signed", _
        "Signed", _
        "Signerat", _
        "Signed", _
        "Signed" _
    )
    'Reviewed
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_reviewed", _
        "Reviewed", _
        "Reviewed", _
        "Genomläst", _
        "Reviewed", _
        "Reviewed" _
    )
    'Rejected
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_rejected", _
        "Rejected", _
        "Rejected", _
        "Avvisat", _
        "Rejected", _
        "Rejected" _
    )
    'Recalled
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_recalled", _
        "Recalled", _
        "Recalled", _
        "Återkallat", _
        "Recalled", _
        "Recalled" _
    )
    'Draft
    Call AddOrCheckLocalize( _
        sOwner, _
        "ga_draft", _
        "Draft", _
        "Draft", _
        "Utkast", _
        "Draft", _
        "Draft" _
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
        oRec.Value("en_us") = sEN_US
        oRec.Value("sv") = sSV
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

