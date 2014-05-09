Attribute VB_Name = "Queue"
Public Function GetQueueLength() As String
On Error GoTo ErrorHandler

    Dim oProcedure As New LDE.Procedure
    
    Set oProcedure = Database.Procedures("csp_getQueueLength")
    
    oProcedure.Parameters("@@idcampaign").InputValue = ActiveInspector.Controls.GetValue("campaign")
    
    oProcedure.log = True
    
    'Run the procedure synchronously
    
    oProcedure.Execute False
    
    GetQueueLength = oProcedure.Result
    
    
Exit Function
ErrorHandler:
    UI.ShowError ("Queue.GetQueueLength")
End Function

Public Sub UpdateQueue()
On Error GoTo ErrorHandler

    Dim oProcedure As New LDE.Procedure
    
    Set oProcedure = Database.Procedures("csp_updateCampaignQueue")
    
    oProcedure.Parameters("@@idcampaign").InputValue = ActiveInspector.Controls.GetValue("campaign")
    
    oProcedure.log = True
    
    'Run the procedure asynchronously
    
    oProcedure.Execute True

    
Exit Sub
ErrorHandler:
    UI.ShowError ("Queue.UpdateQueue")
End Sub

    
Public Sub addToQueue()
On Error GoTo ErrorHandler:
    
    Dim oInspector As Lime.Inspector
    
    Set oInspector = Application.ActiveInspector
    Call oInspector.Controls.SetValue("queuetime", VBA.Now())
    
    Call UpdateQueue
    Call oInspector.Controls.RefreshField("queuepos")
    
Exit Sub
ErrorHandler:
    UI.ShowError ("Queue.addToQueue")
End Sub

Public Sub closeInspector()
On Error GoTo ErrorHandler
    
    Dim oInspector As Lime.Inspector
    
    Set oInspector = Application.ActiveInspector

    Call oInspector.ParentExplorer.Requery
    Call oInspector.Close
Exit Sub
ErrorHandler:
    UI.ShowError ("Queue.updateInspector")
End Sub

Public Sub RemoveFromQueue()
On Error GoTo ErrorHandler:

    Dim oInspector As Lime.Inspector
    
    Set oInspector = Application.ActiveInspector
    Call oInspector.Controls.SetValue("queuetime", Null)
    Call oInspector.Controls.SetValue("queuepos", Null)
    
    Call UpdateQueue
    
Exit Sub
ErrorHandler:
    UI.ShowError ("ActionPad_Contract.RemoveFromQueue")
End Sub
