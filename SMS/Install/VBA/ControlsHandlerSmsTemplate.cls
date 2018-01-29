VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ControlsHandlerSmsTemplate"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
    
'This template includes controls events only. Controls events should always be used instead of inspector
'events if both hold the same event. Control events are used when editing lists.

    Private WithEvents m_Controls As Lime.Controls
Attribute m_Controls.VB_VarHelpID = -1
    
Private Sub Class_Initialize()
    On Error GoTo ErrorHandler
    Set m_Controls = Application.ActiveControls
    
    If Not m_Controls Is Nothing Then
        If Not m_Controls.Record Is Nothing Then
            Call Setup
        End If
    End If
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerSmsTemplate.Class_Initialize")
End Sub

Private Sub m_controls_AfterRecordChanged()
    On Error GoTo ErrorHandler
    
    If Not m_Controls.Record Is Nothing Then
        Call Setup
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerSmsTemplate.m_controls_AfterRecordChanged")
End Sub

Private Sub m_Controls_BeforeActiveControlChanged(ByVal NextControl As IControl)
On Error GoTo ErrorHandler
    If Not m_Controls.ActiveControl Is Nothing Then
        If m_Controls.ActiveControl.field.Name = "fortable" Then
            Call UpdateDatabaseNameForTable
            If Not m_Controls.ParentInspector Is Nothing Then
                Call m_Controls.ParentInspector.WebBar.Refresh
            End If
        End If
    End If
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerSmsTemplate.m_Controls_BeforeSave")
End Sub

Private Sub m_Controls_BeforeSave(Cancel As Boolean)
On Error GoTo ErrorHandler
    Call UpdateDatabaseNameForTable
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerSmsTemplate.m_Controls_BeforeSave")
End Sub

Private Sub m_Controls_Refresh()
    On Error GoTo ErrorHandler
    
    If Not m_Controls.Record Is Nothing Then
        Call Setup
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerSmsTemplate.m_Controls_Refresh")
End Sub

'Setup may only be called from Class_Initialize and the CONTROL events
Private Sub Setup()
    On Error GoTo ErrorHandler
    If Not m_Controls.Record Is Nothing Then
        ' When new
        If (m_Controls.State And lkControlsStateNew) = lkControlsStateNew Then
            ' Add code to run for new records here...
        End If
        
        ' Add code to run for all records (old and new) here...
    End If

    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerSmsTemplate.Setup")
End Sub


Private Sub m_Controls_BeforeCommand(ByVal Control As IControl, ByVal Command As ControlCommandEnum, ByVal Params As LDE.IProperties, Cancel As Boolean)
On Error GoTo ErrorHandler
    Dim i As Integer
    Dim tableOptions()
    
    Select Case Command
        Case ControlCommandEnum.lkControlCommandDropDown
            Select Case Control.field.Name
                Case "fortable"
                    ' Adds all classes into the list.
                    ReDim tableOptions(Application.Classes.Count + 1)
                    tableOptions(0) = Localize.GetText("sms", "fortable_all")

                    For i = 1 To Application.Classes.Count
                        tableOptions(i) = Application.Classes.Item(i).LocalName
                    Next
                    
                    Call Params.Put("Options", tableOptions)
            End Select ' Control name
    End Select ' Command Type
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerSmsTemplate.m_Controls_BeforeCommand")
End Sub




Private Sub UpdateDatabaseNameForTable()
On Error GoTo ErrorHandler
    Dim oClass As LDE.Class, _
        sClassName As Variant

    Set oClass = Application.Database.Classes.Lookup(m_Controls.GetText("fortable"), lkLookupClassByLocalName)
    sClassName = Null
    If Not oClass Is Nothing Then
        sClassName = oClass.Name
    ElseIf Localize.GetText("sms", "fortable_all") = m_Controls.GetText("fortable") Then
        sClassName = SMS.sAllTablesConstant_dbName
    End If
    
    If VBA.IsNull(sClassName) = False Then
        Call m_Controls.SetValue("fortable", sClassName)
    End If
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerSmsTemplate.UpdateDatabaseNameForTable")
End Sub

