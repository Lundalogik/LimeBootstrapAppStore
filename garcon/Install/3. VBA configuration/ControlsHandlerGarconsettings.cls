VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ControlsHandlerGarconsettings"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
    
'This template includes controls event only. Controls events should always be used instead of inspector
'events if both hold the same event. Control events are used when editing lists.



    Private WithEvents m_Controls As Lime.Controls
Attribute m_Controls.VB_VarHelpID = -1
    
Private Sub Class_Initialize()
    On Error GoTo ErrorHandler
    Set m_Controls = Application.ActiveControls
    
    If Not m_Controls Is Nothing Then
        Call Setup
    End If
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerGarconsettings.Class_Initialize")
End Sub

Private Sub m_Controls_AfterCommand(ByVal Control As IControl, ByVal Command As ControlCommandEnum, ByVal Params As LDE.IProperties)
On Error GoTo ErrorHandler
    
    If Not ActiveInspector Is Nothing Then
        If Command = lkControlCommandValueChanged Then
            If Control.field.Name = "operator" Or Control.field.Name = "visiblefor" Then
                Call HideShowFields
                Call SetRequiredFields
            End If
        End If
    End If
    
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerGarconsettings.m_controls_AfterCommand")
End Sub

Private Sub m_controls_AfterRecordChanged()
    On Error GoTo ErrorHandler
    Call Setup
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerGarconsettings.m_controls_AfterRecordChanged")
End Sub

Private Sub m_Controls_BeforeCommand(ByVal Control As IControl, ByVal Command As ControlCommandEnum, ByVal Params As LDE.IProperties, Cancel As Boolean)
  On Error GoTo ErrorHandler
    Select Case Control.field.Name
        Case "coworker"
            If Command = lkControlCommandContextMenu Then
                Call Params.Put("style", lkLinkControlStyleDropDown)
            End If
        Case "department"
            If Command = lkControlCommandContextMenu Then
                Call Params.Put("style", lkLinkControlStyleDropDown)
            End If
        End Select
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerGarconsettings.m_Controls_BeforeCommand")
End Sub


Private Sub m_Controls_Refresh()
    On Error GoTo ErrorHandler
    Call Setup
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerGarconsettings.m_Controls_Refresh")
End Sub

Private Sub Setup()
'Setup may only be called from Class_Initialize and the CONTROL events
    On Error GoTo ErrorHandler
    If Not m_Controls.Record Is Nothing Then
        ' When new
        If (m_Controls.State And lkControlsStateNew) = lkControlsStateNew Then
            ' Add code here
        End If
    End If
    
    If Not ActiveInspector Is Nothing Then
        Call HideShowFields
        Call SetRequiredFields
        Call Garcon.SearchIcon
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerGarconsettings.Setup")
End Sub

Private Sub HideShowFields()
    On Error GoTo ErrorHandler
    
    Dim sVisiblefor As String
    
    If m_Controls.GetOptionKey("operator") = "sum" Then
        Call m_Controls.SetVisible("fieldname", True)
        Call m_Controls.SetVisible("fieldlocalname", True)
    Else
        Call m_Controls.SetVisible("fieldname", False)
        Call m_Controls.SetVisible("fieldlocalname", False)
    End If
    
    sVisiblefor = m_Controls.GetOptionKey("visiblefor")
    
    If sVisiblefor = "all" Then
        Call m_Controls.SetVisible("coworker", False)
        Call m_Controls.SetVisible("department", False)
    ElseIf sVisiblefor = "me" Then
        Call m_Controls.SetVisible("coworker", True)
        Call m_Controls.SetVisible("department", False)
    Else
        Call m_Controls.SetVisible("coworker", False)
        Call m_Controls.SetVisible("department", True)
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerGarconsettings.Setup")
End Sub
Private Sub SetRequiredFields()
    On Error GoTo ErrorHandler

    If m_Controls.GetOptionKey("operator") = "sum" Then
        Call m_Controls.SetRequired("fieldlocalname", True)
        Call m_Controls.SetRequired("classlocalname", True)
        Call m_Controls.SetRequired("fieldname", True)
    Else
        Call m_Controls.SetRequired("fieldlocalname", False)
        Call m_Controls.SetRequired("classlocalname", True)
        Call m_Controls.SetRequired("fieldname", False)
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerGarconsettings.Setup")
End Sub
