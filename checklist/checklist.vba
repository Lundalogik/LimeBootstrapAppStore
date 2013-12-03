Option Explicit
Public Const AutoCreate As Boolean = False

Private Sub Install()
    Dim Warn As Boolean
    Warn = False
    'Is the appfolder there?
     Warn = AppInstaller.FileFolderExists(WebFolder + "apps\checklist2")
    ' Do we have a checklist table?
    Warn = AppInstaller.TableExists("checklist")
    If Not Warn Then
        'Title
        Warn = AppInstaller.FieldExists("checklist", "title")
        'mouseover
        Warn = AppInstaller.FieldExists("checklist", "mouseover")
        'order
        Warn = AppInstaller.FieldExists("checklist", "order")
        'origin
        Warn = AppInstaller.FieldExists("checklist", "origin")
    End If
    
    If Warn = False Then
        Debug.Print ("Everything looks good! You're good to go!")
    End If
End Sub

Private Sub CreateChecklist()
On Error GoTo ErrorHandler
Dim oRecs As New LDE.Records
Dim oRec As New LDE.Record
Dim oFilter As New LDE.Filter
Dim oView As New LDE.View

Dim XMLText As String

Call oView.Add("title")
Call oView.Add("idchecklist")
Call oView.Add("order", lkSortAscending)
Call oView.Add("mouseover")
Call oView.Add("origin")

 Select Case ActiveControls.Class.Name
    Case "business":
        Call oFilter.AddCondition("origin", lkOpEqual, "BusinessTest")
 End Select
 
Call oRecs.Open(Database.Classes("checklist"), oFilter, oView)

XMLText = "<xmlchecklist>"
For Each oRec In oRecs
    XMLText = XMLText + oRec.XMLText
Next oRec
XMLText = XMLText + "</xmlchecklist>"

Call Save(XMLText)

Exit Sub
ErrorHandler:
    UI.ShowError ("Checklist.CreateChecklist")
End Sub


Public Function PerfromAction(id As Long) As Boolean
    PerfromAction = True
End Function


Public Function Initialize() As String
On Error GoTo ErrorHandler
    If AutoCreate = True Then
        If ActiveControls.GetText("checklist") = "" Then
            Call CreateChecklist
        End If
    End If
    If ActiveControls.GetText("checklist") <> "" Then
        Initialize = ActiveControls.GetText("checklist")
    Else
        Initialize = "<xmlchecklist></xmlchecklist>"
    End If
Exit Function
ErrorHandler:
    UI.ShowError ("Checklist.Initialize")
End Function

Public Function Save(xmlString As String)
On Error GoTo ErrorHandler
    Call ActiveControls.SetValue("checklist", xmlString)
Exit Function
ErrorHandler:
     UI.ShowError ("Checklist.Initialize")
End Function
