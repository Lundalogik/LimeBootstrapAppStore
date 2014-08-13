Attribute VB_Name = "Timer"
Public Sub SaveTime(ByVal iVal As Integer)
    On Error GoTo ErrorHandler
    If Globals.VerifyInspector("helpdesk", ActiveInspector) Then
        Call ActiveInspector.Controls.SetValue("time", iVal)
        Call ActiveInspector.Save
        Call ActiveInspector.WebBar.Refresh
    End If
    Exit Sub
ErrorHandler:
    Call UI.ShowError("Timer.SaveTime")
End Sub
