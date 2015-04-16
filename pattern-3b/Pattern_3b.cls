VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Pattern_3b"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'OBSERVERA ATT KODEN I DENNA KLASS ÄR EN DEL AV GRUNDDATABASEN OCH FÅR INTE ÄNDRAS.
'ÄNDRINGAR OCH TILLÄGG I FUNKTIONALITET GÖRS I SEPARATA KLASSER OCH MODULER.
'OM DU TROTS DETTA VÄLJER ATT GÖRA ÄNDRINGAR I KODEN NEDAN GARANTERAS INTE LÄNGRE
'VERSIONS KOMPABILITET ELLER SUPPORT. //Projektgruppen LEAN
Option Explicit
    
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
    Call UI.ShowError("ControlsHandlerBusiness.Class_Initialize")
End Sub


Private Sub m_controls_AfterRecordChanged()
    On Error GoTo ErrorHandler
    Call Setup
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerBusiness.m_controls_AfterRecordChanged")
End Sub

Private Sub m_Controls_Refresh()
    On Error GoTo ErrorHandler
    Call Setup
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerBusiness.m_Controls_Refresh")
End Sub

Private Sub Setup()
    On Error GoTo ErrorHandler
    If Not m_Controls Is Nothing Then
        ' When new
        If (m_Controls.State And lkControlsStateNew) = lkControlsStateNew Then
            ' Add code here
        End If
        Call hideShowFields
        Call setRequiredFields
    End If

    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerBusiness.Setup")
End Sub
Private Sub setRequiredFields()
    On Error GoTo ErrorHandler

    Call m_Controls.SetRequired("wonlostreason", False)
    Select Case m_Controls.GetOptionKey("businesstatus")
        Case "agreement"
            Call m_Controls.SetRequired("wonlostreason", True)
        Case "rejection"
            Call m_Controls.SetRequired("wonlostreason", True)
    End Select
        
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerBusiness.setRequiredFields")
End Sub
Private Sub hideShowFields()
    On Error GoTo ErrorHandler
    
    'PATTERN: SPIN - show related fields if checked
    'END SPIN---------------------------------------------------------------------------------------------------------
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerBusiness.hideShowFields")
        
End Sub


Private Sub m_controls_BeforeCommand(ByVal Control As IControl, ByVal command As ControlCommandEnum, ByVal Params As LDE.IProperties, Cancel As Boolean)
    On Error GoTo ErrorHandler
    
    Select Case Control.Field.name
        Case "person"
            Select Case command
                Case lkControlCommandContextMenu:
                    Call Params.Put("style", lkLinkControlStyleDisableNew)
                Case lkControlCommandSearchDialog:
                    'Limit the search to the selected company
                    
                    Dim oFilter As New LDE.Filter
                    'oFilter.Clear
                    Call oFilter.AddCondition("company", lkOpEqual, m_Controls.GetValue("company", 0))
                    Call Params.Put("SearchFilter", oFilter)
                    Call Params.Put("AutoLoad", True)
                    Call Params.Put("DisableAdvanced", True)
            End Select
        Case "company":
            Select Case command
                Case lkControlCommandContextMenu:
                    Call Params.Put("style", lkLinkControlStyleDisableNew)
            End Select
            
        End Select
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerBusiness.m_Controls_BeforeCommand")

End Sub

Private Sub m_Controls_AfterCommand(ByVal Control As IControl, ByVal command As ControlCommandEnum, ByVal Params As LDE.IProperties)
    On Error GoTo ErrorHandler
    
    If command = lkControlCommandValueChanged Then
        Select Case Control.Field.name
            Case "businesstatus"
                    If Control.Value <> Control.OriginalValue Then
                    
                
                    Select Case Control.OptionKey
                    'Select Case oOption.Key
                        Case "tender":
                            'Om ev. befintligt värde inte ska skrivas över kommentera fram if-satsen.
                            'If m_Controls.GetText("quotesent") = "" Then
                                Call m_Controls.SetValue("quotesent", VBA.Now())
                            'End If
                                             
                                             
                                             
                            If Lime.MessageBox(Localize.GetText("ControlsHandlerBusiness", "q_create_quotation"), VBA.vbQuestion Or VBA.vbYesNo, Database.Classes("todo").LocalName) = VBA.vbYes Then
                                Dim oInspector As Lime.Inspector
                                Dim oOption As LDE.Option
                                
                                'Save the new value for the option field to make sure it is saved
                                m_Controls.Record.Value("businesstatus") = Control.Value
                                
                                Set oInspector = ActionPadTools.NewInspectorFromInspector("todo", True)
                                If Not oInspector Is Nothing Then
                                    Set oOption = Database.Classes("todo").Fields("subject").Options.Lookup("followupquote", lkLookupOptionByKey)
                                    If Not oOption Is Nothing Then
                                        Call oInspector.Controls.SetValue("subject", oOption.Text)
                                    End If
                                    
                                    Call oInspector.Controls.SetValue("note", Localize.GetText("ControlsHandlerBusiness", "quotation_followup"))
                                    Call oInspector.Controls.SetValue("starttime", VBA.DateAdd(CustomSettings.QUOTATION_FOLLOWUP_UNIT, CustomSettings.QUOTATION_FOLLOWUP_NUMBER, VBA.Now()))
                                End If
                            End If
                     
                        Case "agreement"
                            'Om ev. befintligt värde inte ska skrivas över kommentera fram if-satsen.
                            'If m_controls.GetText("closeddate") = "" Then
                                Call m_Controls.SetValue("closeddate", VBA.Now())
                            'End If
                            
                            'Show field wonlostreason if it is hidden in lime
                            If m_Controls.GetVisible("wonlostreason") = False Then
                                Call m_Controls.SetVisible("wonlostreason", True)
                            End If
                            
                        Case "rejection"
                            'Om ev. befintligt värde inte ska skrivas över kommentera fram if-satsen.
                            'If m_controls.GetText("closeddate") = "" Then
                                Call m_Controls.SetValue("closeddate", VBA.Now())
                            'End If
                            
                            'Show field wonlostreason if it is hidden in lime
                            If m_Controls.GetVisible("wonlostreason") = False Then
                                Call m_Controls.SetVisible("wonlostreason", True)
                            End If
                        
                    End Select
                    
                End If
                
                'PATTERN: AFFÄRSPROGNOSTISERING---------------------------------------------------------------------------------------------------------
                'Call setProbabilityAccordingToBusinessStatus
                'END AFFÄRSPROGNOSTISERING---------------------------------------------------------------------------------------------------------
            
            'PATTERN: 3B---------------------------------------------------------------------------------------------------------
            Case "decisionmaker", "need":
                If command = lkControlCommandValueChanged Then
                    If Control.Value = 1 And Control.OriginalValue = 0 Then
                        Dim oInspector3B As Lime.Inspector
                        Set oInspector3B = ActionPadTools.NewInspectorFromInspector("history")
                        
                        Call oInspector3B.Controls.SelectOption("type", "comment")
                        Call oInspector3B.Controls.SetValue("note", Control.Field.LocalName + ": ")
                        Call oInspector3B.Controls.SetFocus("note")
                    End If
                End If
            
            'END 3B---------------------------------------------------------------------------------------------------------
            
            'PATTERN: MEDDIC---------------------------------------------------------------------------------------------------------
            'END MEDDIC---------------------------------------------------------------------------------------------------------
        
            'PATTERN: SPIN---------------------------------------------------------------------------------------------------------
            'END SPIN---------------------------------------------------------------------------------------------------------
        
        End Select
        
        Call hideShowFields
        Call setRequiredFields
    End If
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerBusiness.m_controls_AfterCommand")
End Sub


