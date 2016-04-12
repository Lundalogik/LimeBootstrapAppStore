Attribute VB_Name = "App_CreateCustomerBFUS"
Option Explicit

' This property contains the LIME Pro field names for the fields that are sent to BFUS when updating a customer.
' It is set by the app when the app is initialized.
Private m_updateableFields As String

' This property is set when the app is initialized. It contains the LIME Pro field name of the field for CustomerId.
' Is used to check if the customer is integrated with BFUS or not when the app starts.
Private m_fieldNameCustomerId As String

' This property is checked in the BeforeSave logics in the ControlsHandler class for the customer class.
' Used to decide whether to check if BFUS fields has been updated (this must be done if a manual save is made) or not.
Public m_savingFromApp As Boolean

' ##SUMMARY Returns true if the record is not updated and false if it is updated.
Public Function isRecordSaved(sInspectorGUID As String) As Boolean
    On Error GoTo ErrorHandler

    Dim isSaved As Boolean
    isSaved = False

    Dim oInspector As Lime.Inspector
    Set oInspector = Application.Inspectors.Lookup(sInspectorGUID)
    If Not oInspector Is Nothing Then
        isSaved = Not (oInspector.Controls.State And lkControlsStateModified) = lkControlsStateModified _
                    And Not (oInspector.Controls.State And lkControlsStateNew) = lkControlsStateNew
    End If
    isRecordSaved = isSaved

    Exit Function
ErrorHandler:
    Call UI.ShowError("App_CreateCustomerBFUS.isRecordSaved")
End Function


' ##SUMMARY Tries to save the customer. If successful it returns true, otherwise false.
Public Function saveRecord(sInspectorGUID As String) As Boolean
    On Error GoTo ErrorHandler
    
    ' Set default value
    saveRecord = False
    
    ' Get inspector its controls
    Dim oInspector As Lime.Inspector
    Set oInspector = Application.Inspectors.Lookup(sInspectorGUID)
    If Not oInspector Is Nothing Then
        If Not oInspector.Controls Is Nothing Then
            m_savingFromApp = True                  ' Make sure the BeforeSave code understands that this is the app trying to save the record.
            On Error GoTo SaveErrorHandler
            Call oInspector.Controls.Save
            On Error GoTo ErrorHandler
            m_savingFromApp = False                 ' Reset the flag so we don't interfere with "normal" manual saves done later.
            
            ' If we arrive here, the record was saved successfully
            saveRecord = True
        End If
    End If
    
    Exit Function
SaveErrorHandler:
    m_savingFromApp = False                 ' Reset the flag so we don't interfere with "normal" manual saves done later.
    Call Lime.MessageBox(Err.Description)
    Exit Function
ErrorHandler:
    m_savingFromApp = False                 ' Reset the flag so we don't interfere with "normal" manual saves done later.
    Call UI.ShowError("App_CreateCustomerBFUS.saveRecord")
End Function


' ##SUMMARY Returns true if the customer is eligible for sending to BFUS and otherwise false.
Public Function isEligibleForSendingToBFUS(sInspectorGUID As String, optionFieldName As String, validIdstrings As String) As Boolean
    On Error GoTo ErrorHandler
    
    Dim canSend As Boolean
    Dim oInspector As Lime.Inspector
    Set oInspector = Application.Inspectors.Lookup(sInspectorGUID)
    If Not oInspector Is Nothing Then
        canSend = (VBA.InStr(validIdstrings, ";" & VBA.CStr(oInspector.Controls.GetValue(optionFieldName, "FieldNotFound")) & ";") > 0)
    End If
    
    isEligibleForSendingToBFUS = canSend
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_CreateCustomerBFUS.isEligibleForSendingToBFUS")
End Function


' ##SUMMARY Called when a successful call to BFUS has been made.
Public Sub saveBFUSResponseData(sInspectorGUID As String, fieldNameCustomerId As String, customerId As String _
                                , fieldNameCustomerCode As String, customerCode As String)
    On Error GoTo ErrorHandler
    
    Dim oInspector As Lime.Inspector
    Set oInspector = Application.Inspectors.Lookup(sInspectorGUID)
    If Not oInspector Is Nothing Then
        If Not oInspector.Controls Is Nothing Then
            If customerId <> "" And customerCode <> "" Then
                If oInspector.Controls.GetValue(fieldNameCustomerId) = "" Then
                    Call oInspector.Controls.SetValue(fieldNameCustomerId, customerId)
                End If
                If oInspector.Controls.GetValue(fieldNameCustomerCode) = "" Then
                    Call oInspector.Controls.SetValue(fieldNameCustomerCode, customerCode)
                End If
                Call oInspector.Controls.SetValue("lastsenttobfus", VBA.Now)
                Call oInspector.Controls.SelectOption("senttobfusstatus", "ok")
                
                m_savingFromApp = True      ' Make sure the BeforeSave code understands that this is the app trying to save the record.
                On Error GoTo SaveErrorHandler
                Call oInspector.Controls.Save
                On Error GoTo ErrorHandler
                m_savingFromApp = False     ' Reset the flag so we don't interfere with "normal" manual saves done later.
            End If
        End If
    End If
    
    Exit Sub
SaveErrorHandler:
    m_savingFromApp = False                 ' Reset the flag so we don't interfere with "normal" manual saves done later.
    Call Lime.MessageBox(Err.Description)
    Exit Sub
ErrorHandler:
    m_savingFromApp = False                 ' Reset the flag so we don't interfere with "normal" manual saves done later.
    Call UI.ShowError("App_CreateCustomerBFUS.saveBFUSResponseData")
End Sub


' ##SUMMARY Called from app. Saves error status and last sent timestamp
Public Sub saveErrorInfo(sInspectorGUID As String)
    On Error GoTo ErrorHandler
    
    Dim oInspector As Lime.Inspector
    Set oInspector = Application.Inspectors.Lookup(sInspectorGUID)
    If Not oInspector Is Nothing Then
        If Not oInspector.Controls Is Nothing Then
            Call oInspector.Controls.SetValue("lastsenttobfus", VBA.Now)
            Call oInspector.Controls.SelectOption("senttobfusstatus", "failed")
            m_savingFromApp = True      ' Make sure the BeforeSave code understands that this is the app trying to save the record.
            On Error GoTo SaveErrorHandler
            Call oInspector.Controls.Save
            On Error GoTo ErrorHandler
            m_savingFromApp = False     ' Reset the flag so we don't interfere with "normal" manual saves done later.
        End If
    End If
    
    Exit Sub
SaveErrorHandler:
    m_savingFromApp = False                 ' Reset the flag so we don't interfere with "normal" manual saves done later.
    Call Lime.MessageBox(Err.Description)
    Exit Sub
ErrorHandler:
    m_savingFromApp = False                 ' Reset the flag so we don't interfere with "normal" manual saves done later.
    Call UI.ShowError("App_CreateCustomerBFUS.saveErrorInfo")
End Sub


' ##SUMMARY Sets property m_updateableFields. Called from app Javascript code when app is initialized.
Public Sub setUpdateableFields(fieldNames As String)
    On Error GoTo ErrorHandler

    m_updateableFields = fieldNames

    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_CreateCustomerBFUS.setUpdateableFields")
End Sub


' ##SUMMARY Sets property m_fieldNameCustomerId. Called from app Javascript code when app is initialized.
Public Sub setFieldNameCustomerId(fieldName As String)
    On Error GoTo ErrorHandler

    m_fieldNameCustomerId = fieldName

    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_CreateCustomerBFUS.setFieldNameCustomerId")
End Sub


' ##SUMMARY Should be called from the BeforeSave code on the controls object.
' Returns true if any of the fields in m_updateableFields has been updated and otherwise false.
' If it is a customer that is not yet integrated with BFUS, false is always returned.
Public Function hasUpdatedBFUSFields(ByRef oControls As Lime.Controls)
    On Error GoTo ErrorHandler
    
    ' Set default value
    hasUpdatedBFUSFields = False
    
    If oControls.GetValue(m_fieldNameCustomerId, "") <> "" Then
        ' Get updateable fields as Array and loop over it
        Dim fieldsArray() As String
        fieldsArray = VBA.Split(m_updateableFields, ";")
        Dim i As Long
        For i = LBound(fieldsArray) To UBound(fieldsArray)
            If fieldsArray(i) <> "" Then
                If oControls.GetOriginalValue(fieldsArray(i)) <> oControls.GetValue(fieldsArray(i)) Then
                    hasUpdatedBFUSFields = True
                    Exit For
                End If
            End If
        Next i
    End If
    
    Exit Function
ErrorHandler:
    hasUpdatedBFUSFields = False
    Call UI.ShowError("App_CreateCustomerBFUS.hasUpdatedBFUSFields")
End Function


