Attribute VB_Name = "checkHistory"


Public Function call_checkHistory(interval1 As Integer, interval2 As Integer) As String
On Error GoTo errorhandler
Dim oProc As lde.Procedure

Set oProc = Database.Procedures.Lookup("csp_checkHistory", lkLookupProcedureByName)
oProc.Parameters("@idrecord").InputValue = ThisApplication.ActiveInspector.Record.ID
oProc.Parameters("@interval1").InputValue = interval1
oProc.Parameters("@interval2").InputValue = interval2
oProc.Execute (False)

call_checkHistory = oProc.Parameters("@result").OutputValue


Exit Function
errorhandler:
UI.ShowError ("checkHistory.call_checkHistory")
End Function





Public Function call_checkHelpdesk() As String
On Error GoTo errorhandler
Dim oProc As lde.Procedure

Set oProc = Database.Procedures.Lookup("csp_checkHelpdesk", lkLookupProcedureByName)
oProc.Parameters("@idrecord").InputValue = ThisApplication.ActiveInspector.Record.ID
oProc.Execute (False)

call_checkHelpdesk = oProc.Parameters("@xml").OutputValue


Exit Function
errorhandler:
UI.ShowError ("checkHistory.call_checkHelpdesk")
End Function

Public Function checkFields(values As String) As String
On Error GoTo errorhandler
    Dim fields As Variant
    fields = VBA.Split(values, ";", , vbTextCompare)
    Dim iMatch As Integer
    
    Dim i As Integer
    For i = 0 To UBound(fields)
        If fields(i) <> "" Then
            If ActiveInspector.Controls.Exists(fields(i)) = True Then
                If Trim(ActiveInspector.Controls.GetValue(fields(i), "")) = "" Then
                    iMatch = iMatch + 1
                End If
            End If
        End If
    Next i
    
    Dim lPercent As Double
    lPercent = iMatch / UBound(fields)
    If lPercent = 0 Then
        checkFields = "<row myvar=""3""/>"
        Exit Function
    ElseIf lPercent <= 0.5 Then
        checkFields = "<row myvar=""2""/>"
        Exit Function
    Else
        checkFields = "<row myvar=""1""/>"
        Exit Function
    End If
    
Exit Function
errorhandler:
UI.ShowError ("checkHistory.checkFields")
End Function
