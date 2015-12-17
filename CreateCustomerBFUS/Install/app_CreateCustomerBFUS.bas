Attribute VB_Name = "App_CreateCustomerBFUS"
Option Explicit

' Returns true if the record is not updated and false if it is updated.
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
    Call UI.ShowError("app_CreateCustomerBFUS.isRecordSaved")
End Function

' Returns true if the customer is eligible for sending to BFUS and otherwise false.
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
    Call UI.ShowError("app_CreateCustomerBFUS.isEligibleForSendingToBFUS")
End Function

' Called when a successful call to BFUS has been made.
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
                Call oInspector.Controls.Save
            End If
        End If
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("app_CreateCustomerBFUS.saveBFUSResponseData")
End Sub
