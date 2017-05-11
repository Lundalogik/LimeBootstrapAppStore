Attribute VB_Name = "PUL_Handler"
Option Explicit


Public Sub ExportData()
On Error GoTo ErrorHandler

Dim oExplorer As Lime.Explorer
Set oExplorer = Application.ActiveExplorer

If Not oExplorer Is Nothing Then
    If oExplorer.Class.name = "company" Then
        If oExplorer.Selection.Count = 1 Then
            
            Dim oProcedure As LDE.Procedure
            Set oProcedure = Application.Database.Procedures.Lookup("csp_ExportSelected", lkLookupProcedureByName)
            oProcedure.Parameters("@@idrecord").InputValue = oExplorer.ActiveItem.ID
            oProcedure.Parameters("@@activeuser").InputValue = Application.ActiveUser.Record.ID
            Call oProcedure.Execute(False)
            
        Else
            Call Lime.MessageBox("Var god markera endast ett objekt vid användning av denna knapp.")
        End If
        
    Else
        Call Lime.MessageBox("Denna funktionen kan endast användas från kundfliken.")
    End If
    
End If

Exit Sub
    
ErrorHandler:
    Call UI.ShowError("PUL_Handler.ExportData")
End Sub

Public Function showPulButtons() As Boolean
On Error GoTo ErrorHandler
    Dim TABLE_COMPANY As String
    Dim TABLE_COWORKER As String
    TABLE_COMPANY = "company"
    TABLE_COWORKER = "coworker"
    
    If Not ActiveExplorer Is Nothing Then
    
        If ActiveExplorer.Class.name = TABLE_COMPANY Or ActiveExplorer.Class.name = TABLE_COWORKER Then
            showPulButtons = True
        Else
            showPulButtons = False
        End If
    End If
Exit Function
ErrorHandler:
    UI.ShowError ("PUL_Handler.showPulButtons")
End Function

Public Sub AnonymizeData()
On Error GoTo ErrorHandler


Dim oExplorer As Lime.Explorer
Set oExplorer = Application.ActiveExplorer

If Not oExplorer Is Nothing Then
    If ActiveUser.Administrator = True Then
        If oExplorer.Class.name = "company" Or oExplorer.Class.name = "coworker" Then
            If oExplorer.Selection.Count = 1 Then
                If Lime.MessageBox("Är du säker på att du vill anonymisera detta objekt? Detta går inte att ångra!", vbYesNo) = vbYes Then
                    Dim oProcedure As LDE.Procedure
                    Set oProcedure = Application.Database.Procedures.Lookup("csp_AnonymizeSelected", lkLookupProcedureByName)
                    oProcedure.Parameters("@@idrecord").InputValue = oExplorer.ActiveItem.ID
                    
                    If oExplorer.Class.name = "company" Then
                        oProcedure.Parameters("@@iscustomer").InputValue = "customer"
                    ElseIf oExplorer.Class.name = "coworker" Then
                        oProcedure.Parameters("@@iscustomer").InputValue = "coworker"
                    End If
                    oProcedure.Parameters("@@activeuser").InputValue = Application.ActiveUser.Record.ID
                    Call oProcedure.Execute(False)
                    Call oExplorer.Requery
                End If
            Else
                Call Lime.MessageBox("Var god markera endast ett objekt vid användning av denna knapp.")
                Exit Sub
            End If
            
        Else
            Call Lime.MessageBox("Denna funktionen kan endast användas från kund- eller medarbetar-fliken.")
            Exit Sub
        End If
    Else
         Call Lime.MessageBox("Admin?")
         Exit Sub
    End If
    
End If

Exit Sub
    
ErrorHandler:
    Call UI.ShowError("PUL_Handler.AnonymizeData")
End Sub

