VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ControlsHandlerInfoTiles"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
    
'This template includes controls event only. Controls events should always be used instead of inspector
'events if both hold the same event. Control events are used when editing lists.

    Private WithEvents m_Controls As Lime.Controls
Attribute m_Controls.VB_VarHelpID = -1
    Private WithEvents m_ControlExplorer As Lime.Control
Attribute m_ControlExplorer.VB_VarHelpID = -1
    Private WithEvents m_ControlField As Lime.Control
Attribute m_ControlField.VB_VarHelpID = -1
    Private WithEvents m_ControlVisibleOn As Lime.Control
Attribute m_ControlVisibleOn.VB_VarHelpID = -1

Private Sub Class_Initialize()
    On Error GoTo ErrorHandler
    Set m_Controls = Application.ActiveControls
    
    If Not m_Controls Is Nothing Then
        Set m_ControlExplorer = m_Controls.Lookup("classname", lkLookupControlByName)
        Set m_ControlVisibleOn = m_Controls.Lookup("visibleon", lkLookupControlByName)
        Set m_ControlField = m_Controls.Lookup("fieldname", lkLookupControlByName)
        Call Setup
    End If
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.Class_Initialize")
End Sub

Private Sub m_Controls_AfterCommand(ByVal Control As IControl, ByVal Command As ControlCommandEnum, ByVal Params As LDE.IProperties)
On Error GoTo ErrorHandler

    If Not ActiveInspector Is Nothing Then
        If Command = lkControlCommandValueChanged Then
            If Control.field.Name = "operator" Or Control.field.Name = "visiblefor" Then
                Call HideShowFields
                Call SetRequiredFields
                
                If Control.field.Name = "operator" And Control.OptionKey = "field" Then
                    If m_Controls.GetText("visibleon", "") = InfoTiles.VisibleOnIndexName Then
                        Call m_Controls.SetValue("visibleon", "")
                    End If
                End If
            End If
        End If
    End If

Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.m_controls_AfterCommand")
End Sub

Private Sub m_controls_AfterRecordChanged()
    On Error GoTo ErrorHandler
    Call Setup
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.m_controls_AfterRecordChanged")
End Sub

Private Sub m_Controls_BeforeCommand(ByVal Control As IControl, ByVal Command As ControlCommandEnum, ByVal Params As LDE.IProperties, Cancel As Boolean)
  On Error GoTo ErrorHandler
    Select Case Control.field.Name
        Case "coworker"
            If Command = lkControlCommandContextMenu Then
                Call Params.Put("style", lkLinkControlStyleDropDown)
            End If
        Case InfoTiles.sDepartmentFieldname
            If Command = lkControlCommandContextMenu Then
                Call Params.Put("style", lkLinkControlStyleDropDown)
            End If
    End Select
    
    
    Dim i As Integer
    Dim iIndex As Integer
    Dim tableOptions()
    Dim fieldOptions()
    Dim filterOptions()
    Dim oClass As LDE.Class
    Dim oField As LDE.field
    
    Select Case Command
        Case lkControlCommandContextMenu
                Select Case Control.field.Name
                    Case "coworker", InfoTiles.sDepartmentFieldname
                        Call Params.Put("style", lkLinkControlStyleDropDown)
                End Select
        Case ControlCommandEnum.lkControlCommandDropDown
            Select Case Control.field.Name
                Case "visibleon"
                    ' Adds all classes into the list.
                    
                    
                    If m_Controls.GetOptionKey("operator") <> "field" Then
                        ReDim tableOptions(Application.Classes.Count + 1)
                        tableOptions(0) = InfoTiles.VisibleOnIndexLocalName
                    Else
                        ReDim tableOptions(Application.Classes.Count)
                    End If
                    
                    For i = 1 To Application.Classes.Count
                        tableOptions(i) = Application.Classes.Item(i).LocalName
                    Next
                    
                    Call Params.Put("Options", tableOptions)
            
                Case "classname"
                    ' If visibleOn is indexValue show all explorers in main-list.
                    ' If visibleOn exists as a class show all MultiLink-field-classes on that class.
                    ' If visibleOn is empty or no match show NONE!
            
                    If m_ControlVisibleOn.Text = InfoTiles.VisibleOnIndexName Then
                        ' Lägger till alla flikar som alternativ
                        ReDim tableOptions(Application.Explorers.Count)
            
                        For i = 1 To Application.Explorers.Count
                            tableOptions(i - 1) = Application.Explorers.Item(i).Name
                        Next
                    ElseIf Application.Database.Classes.Exists(m_ControlVisibleOn.Text) Then
                        Dim oFields As Collection
                        
                        Set oFields = InfoTiles.FindExplorerFieldsByClass(Application.Database.Classes.Lookup(m_ControlVisibleOn.Text, lkLookupClassByName))
                        
                        ' Adds all Explorer-classes into the list.
                        ReDim tableOptions(oFields.Count)
                        For i = 1 To oFields.Count
                            Set oField = oFields.Item(i)
                            tableOptions(i - 1) = oField.LocalName
                        Next
                        
                    End If
    
                    Call Params.Put("Options", tableOptions)
                Case "fieldname"
                    Dim iFieldCount As Integer
                    Dim oDic As New Scripting.Dictionary
                    
                    Select Case m_Controls.GetOptionKey("operator")
                        Case "field"
                            Set oClass = Application.Database.Classes.Lookup(m_ControlVisibleOn.Text, lkLookupClassByName)
                        Case "sum"
                            Set oClass = Application.Database.Classes.Lookup(m_ControlExplorer.Text, lkLookupClassByName)
                            Call oDic.Add(FieldTypeEnum.lkFieldTypeDecimal, True)
                            Call oDic.Add(FieldTypeEnum.lkFieldTypeInteger, True)
                            Call oDic.Add(FieldTypeEnum.lkFieldTypePercent, True)
                            Call oDic.Add(FieldTypeEnum.lkFieldTypeCurrency, True)
                    End Select
                    
                    If Not oClass Is Nothing Then
                        

                        iFieldCount = InfoTiles.GetFieldCountByTypes(oClass.Fields, oDic)
                        
                        If iFieldCount > 0 Then
                            ReDim fieldOptions(iFieldCount - 1)
                        Else
                            ReDim fieldOptions(0)
                        End If
                        
                        iIndex = 0
                        For i = 1 To oClass.Fields.Count
                            Set oField = oClass.Fields.Item(i)
                            If oDic.Exists(oField.Type) Or oDic.Count = 0 Then
                                fieldOptions(iIndex) = oField.LocalName
                                iIndex = iIndex + 1
                            End If
                        Next
                    End If
                    
                    Call Params.Put("Options", fieldOptions)
                Case "filtername"
                    Dim sExplorer As String
                    Dim oFilter As LDE.Filter
                    Dim iFilterCount As Integer
                    Dim oFilters As LDE.Filters
                        
                    sExplorer = m_ControlExplorer.Text
                    If m_ControlVisibleOn.Text = InfoTiles.VisibleOnIndexName Then
                        If Application.Explorers.Exists(sExplorer) Then
                            ' Lägger till alla flikar som alternativ
                            
                            Set oFilters = Application.Explorers(sExplorer).Filters
                            iFilterCount = InfoTiles.GetFilterCountByType(oFilters)
                            If iFilterCount > 0 Then
                                ReDim filterOptions(iFilterCount - 1)
                            Else
                                ReDim filterOptions(0)
                            End If
                            
                            iIndex = 0
                            For i = 1 To oFilters.Count
                                Set oFilter = oFilters.Item(i)
                                If oFilter.Type = lkFilterTypeDynamic Then
                                    filterOptions(iIndex) = oFilter.Name
                                    iIndex = iIndex + 1
                                End If
                            Next
                        End If
                    Else ' Show filterts from an explorer(Go on class so not for individual tab) inside an inspector
                        Set oClass = Application.Database.Classes.Lookup(m_ControlVisibleOn.Text, lkLookupClassByName)
                        If Not oClass Is Nothing Then
                            Set oField = oClass.Fields.Lookup(m_ControlExplorer.Text, lkLookupFieldByName)
                            If Not oField Is Nothing Then
                               If oField.Type = lkFieldTypeMultiLink Then
                                    Set oFilters = InfoTiles.GetInspectorExplorerFilters(m_ControlVisibleOn.Text, oField.LinkedField.Class.Name)
                               End If
                            End If
                            If Not oFilters Is Nothing Then
                                iFilterCount = InfoTiles.GetFilterCountByType(oFilters)
                                If iFilterCount > 0 Then
                                    ReDim filterOptions(iFilterCount - 1)
                                Else
                                    ReDim filterOptions(0)
                                End If
                                
                                iIndex = 0
                                For i = 1 To oFilters.Count
                                    Set oFilter = oFilters.Item(i)
                                    If oFilter.Type = lkFilterTypeDynamic Then
                                        filterOptions(iIndex) = oFilter.Name
                                        iIndex = iIndex + 1
                                    End If
                                Next
                            End If
                        End If
                    End If
                    Call Params.Put("Options", filterOptions)
            
            End Select ' Control name
    End Select ' Command Type

    
    
    
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.m_Controls_BeforeCommand")
End Sub


Private Sub m_Controls_Refresh()
    On Error GoTo ErrorHandler
    Call Setup
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.m_Controls_Refresh")
End Sub

Private Sub Setup()
'Setup may only be called from Class_Initialize and the CONTROL events
    On Error GoTo ErrorHandler
    If Not m_Controls.Record Is Nothing Then
        ' When new
        If (m_Controls.State And lkControlsStateNew) = lkControlsStateNew Then
            Call m_Controls.SetValue("visibleon", InfoTiles.VisibleOnIndexName)
        End If
    End If
    
    If Not ActiveInspector Is Nothing Then
        Call HideShowFields
        Call SetRequiredFields
        Call InfoTiles.SearchIcon
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.Setup")
End Sub

Private Sub HideShowFields()
    On Error GoTo ErrorHandler
    
    Dim sVisiblefor As String
    Dim sOperator As String
    
    sOperator = m_Controls.GetOptionKey("operator")
    
    
    ' Initial Hide all affected fields
    Call m_Controls.SetVisible("fieldname", False)
    Call m_Controls.SetVisible("filtername", False)
    Call m_Controls.SetVisible("classname", False)
    
    ' Show relevant fields
    Select Case sOperator
        Case "sum"
            Call m_Controls.SetVisible("fieldname", True)
            Call m_Controls.SetVisible("filtername", True)
            Call m_Controls.SetVisible("classname", True)
        Case "count"
            Call m_Controls.SetVisible("filtername", True)
            Call m_Controls.SetVisible("classname", True)
        Case "link"
            Call m_Controls.SetVisible("filtername", True)
            Call m_Controls.SetVisible("classname", True)
        Case "field"
            Call m_Controls.SetVisible("fieldname", True)
    End Select
    
    sVisiblefor = m_Controls.GetOptionKey("visiblefor")
    
    Select Case sVisiblefor
        Case "all"
            Call m_Controls.SetVisible("coworker", False)
            Call m_Controls.SetVisible(InfoTiles.sDepartmentFieldname, False)
        Case "me"
            Call m_Controls.SetVisible("coworker", True)
            Call m_Controls.SetVisible(InfoTiles.sDepartmentFieldname, False)
        Case "department"
            Call m_Controls.SetVisible("coworker", False)
            Call m_Controls.SetVisible(InfoTiles.sDepartmentFieldname, True)
    End Select
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.Setup")
End Sub
Private Sub SetRequiredFields()
    On Error GoTo ErrorHandler

    ' Initial Required False all affected fields
    Call m_Controls.SetRequired("fieldname", False)
    Call m_Controls.SetRequired("classname", False)
    Call m_Controls.SetRequired("filtername", False)

    ' Set relevant fields required
    Select Case m_Controls.GetOptionKey("operator")
        Case "sum"
            Call m_Controls.SetRequired("fieldname", True)
            Call m_Controls.SetRequired("classname", True)
            Call m_Controls.SetRequired("filtername", True)
        Case "count"
            Call m_Controls.SetRequired("classname", True)
            Call m_Controls.SetRequired("filtername", True)
        Case "link"
            Call m_Controls.SetRequired("classname", True)
            Call m_Controls.SetRequired("filtername", True)
        Case "field"
            Call m_Controls.SetRequired("fieldname", True)
    End Select
     
    Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.Setup")
End Sub


Private Sub m_Controls_BeforeSave(Cancel As Boolean)
On Error GoTo ErrorHandler
    Call UpdateDatabaseNameVisibleOn
    Call UpdateDatabaseNameExplorer
    Call UpdateDatabaseNameField
    
    Dim sWarningMessage As String
    sWarningMessage = "" 'Changed by reference in function
    If m_Controls("filtername").Visible Then
        If VerifyFilterPublished(sWarningMessage) = False Then
            Cancel = Lime.MessageBox(sWarningMessage, vbYesNo) = vbNo
        End If
    End If
    If Cancel = False Then
        ' If operator is field and visibleon is "index" Then Cancel
        Cancel = m_ControlVisibleOn.Value = InfoTiles.VisibleOnIndexName And m_Controls.GetOptionKey("operator") = "field"
        If Cancel = True Then
            Call Lime.MessageBox("VisibleOn can't be ""index"" when operator is ""field value"".")
        End If
    End If
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.m_Controls_BeforeSave")
End Sub

Private Sub m_ControlVisibleOn_LostFocus()
On Error GoTo ErrorHandler
    Call UpdateDatabaseNameVisibleOn
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.m_ControlVisibleOn_LostFocus")
End Sub

Private Sub m_ControlExplorer_LostFocus()
On Error GoTo ErrorHandler
    Call UpdateDatabaseNameExplorer
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.m_ControlExplorer_LostFocus")
End Sub

Private Sub m_ControlField_LostFocus()
On Error GoTo ErrorHandler
    Call UpdateDatabaseNameField
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.m_ControlField_LostFocus")
End Sub

Private Sub UpdateDatabaseNameVisibleOn()
On Error GoTo ErrorHandler
    Dim oClass As LDE.Class
    Set oClass = Application.Database.Classes.Lookup(m_ControlVisibleOn.Text, lkLookupClassByLocalName)
    
    If m_ControlVisibleOn.Text = InfoTiles.VisibleOnIndexLocalName Then
        m_ControlVisibleOn.Value = InfoTiles.VisibleOnIndexName
    ElseIf Not oClass Is Nothing Then
        m_ControlVisibleOn.Value = oClass.Name
    End If
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.UpdateDatabaseNameVisibleOn")
End Sub

Private Sub UpdateDatabaseNameExplorer()
On Error GoTo ErrorHandler
    Dim oFields As Collection
    Dim sExplorerName As String
    sExplorerName = ""
    If m_ControlVisibleOn.Text = InfoTiles.VisibleOnIndexName Then
        If Application.Explorers.Exists(m_ControlExplorer.Text) Then
            sExplorerName = Application.Explorers(m_ControlExplorer.Text).Class.Name
        End If
    ElseIf Application.Classes.Exists(m_ControlVisibleOn.Text) Then
        Set oFields = InfoTiles.FindExplorerFieldsByClass(Application.Classes(m_ControlVisibleOn.Text))
        Dim i As Integer
        Dim oField As LDE.field
        For i = 1 To oFields.Count
            Set oField = oFields.Item(i)
            If oField.LocalName = m_ControlExplorer.Text Then
                m_ControlExplorer.Value = oField.Name
                Exit For
            End If
        Next
    End If
    
    If sExplorerName <> "" Then
        m_ControlExplorer.Value = sExplorerName
    End If

Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.UpdateDatabaseNameExplorer")
End Sub

Private Sub UpdateDatabaseNameField()
On Error GoTo ErrorHandler
    Dim oClass As LDE.Class
    Dim oField As LDE.field
    Select Case m_Controls.GetOptionKey("operator")
        Case "sum"
            Set oClass = Application.Database.Classes.Lookup(m_ControlExplorer.Text, lkLookupClassByName)
        Case "field"
            Set oClass = Application.Database.Classes.Lookup(m_ControlVisibleOn.Text, lkLookupClassByName)
    End Select
    
    
    If Not oClass Is Nothing Then
        Set oField = oClass.Fields.Lookup(m_ControlField.Text, lkLookupFieldByLocalName)
        If Not oField Is Nothing Then
            m_ControlField.Value = oField.Name
        End If
    End If
Exit Sub
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.UpdateDatabaseNameField")
End Sub

Private Function VerifyFilterPublished(ByRef sWarningMessage As String) As Boolean
On Error GoTo ErrorHandler
    Dim oFilter As LDE.Filter
    Dim oFilters As LDE.Filters
    Dim oClass As LDE.Class
    Dim oField As LDE.field
    
    VerifyFilterPublished = True
    If m_ControlVisibleOn.Text = InfoTiles.VisibleOnIndexName Then
        If Application.Explorers.Exists(m_ControlExplorer.Text) Then
            Set oFilter = Application.Explorers(m_ControlExplorer.Text).Filters.Lookup(m_Controls("filtername").Text, lkLookupFilterByName)
        End If
    Else ' Find Filter on Inspector Explorer.
        Set oClass = Application.Database.Classes.Lookup(m_ControlVisibleOn.Text, lkLookupClassByName)
        If Not oClass Is Nothing Then
            Set oField = oClass.Fields.Lookup(m_ControlExplorer.Text, lkLookupFieldByName)
            If Not oField Is Nothing Then
               If oField.Type = lkFieldTypeMultiLink Then
                    Set oFilters = InfoTiles.GetInspectorExplorerFilters(m_ControlVisibleOn.Text, oField.LinkedField.Class.Name)
                    Set oFilter = oFilters.Lookup(m_Controls("filtername").Text, lkLookupFilterByName)
               End If
            End If
        End If
    End If
    
    If Not oFilter Is Nothing Then
        If oFilter.Policy <> PolicyEnum.lkPolicyAll Then
            If m_Controls.GetOptionKey("visiblefor") <> "me" Then
                sWarningMessage = "This filter is not visible for everyone.%0%0Are you sure you want to save?"
                VerifyFilterPublished = False
            End If
        End If
    Else
        VerifyFilterPublished = False
        sWarningMessage = "Can't find filter.%0%0Are you sure you want to save?"
    End If
Exit Function
ErrorHandler:
    Call UI.ShowError("ControlsHandlerInfoTiles.VerifyFilterPublished")
End Function

