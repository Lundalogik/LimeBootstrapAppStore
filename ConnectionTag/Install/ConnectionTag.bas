Attribute VB_Name = "ConnectionTag"
Public Function GetConnections(sTable As String) As LDE.Records
    On Error GoTo ErrorHandler
    Dim oRecords As New LDE.Records
    Dim oFilter As New LDE.filter
    Dim oView As New LDE.view
    
    If Globals.VerifyInspector(sTable, ActiveInspector, False) Then
        If Not IsNull(ActiveInspector.Controls.GetValue("company")) Then
            Call oFilter.AddCondition("company", lkOpEqual, ActiveInspector.Controls.GetValue("company"))
            Call oView.Add("name", lkSortAscending)
            
            Call oRecords.Open(Database.Classes("person"), oFilter, oView)
            
        End If
    End If
    Set GetConnections = oRecords
    Exit Function
ErrorHandler:
    Call UI.ShowError("ConnectionTag.GetConnections")
End Function


Public Sub SetName(sName As String, sTable As String, sField As String)
    On Error GoTo ErrorHandler
    If Globals.VerifyInspector(sTable, ActiveInspector, False) Then
        
        Call ActiveInspector.Controls.SetValue(sField, ActiveInspector.Controls.GetValue(sField, "") & sName)
        Call ActiveInspector.Controls.SetFocus(sField)
        SendKeys "{END}", True
        
    End If
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ConnectionTag.SetName")
End Sub
