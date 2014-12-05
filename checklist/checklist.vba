Option Explicit
Public Const AutoCreate As Boolean = True
Public Const Source As String = "static" 'Can be "table", "static" or "custom"

'A model of a cheklist item. Create an array and serialize to get an nice XML
'This is bad VBA naming, but makes the JS better
Private Type ChecklistItem
    idchecklist As Long
    order As Integer
    title As String 'Displayed text
    mouseover As String 'Thext displayed on hover
    isChecked As Boolean
    checkedDate As String 'ISO formated string 2014-01-01 12:00:00
    checkedBy As String
End Type

Private Sub CreateChecklist(XmlField As String)
On Error GoTo ErrorHandler
Dim XMLText As String

'Load your own data from a table here
If Source = "table" Then
    Dim oRecs As New LDE.Records
    Dim oRec As New LDE.Record
    Dim oFilter As New LDE.Filter
    Dim oView As New LDE.View
    
    Call oView.Add("title")
    Call oView.Add("idchecklist")
    Call oView.Add("order", lkSortAscending)
    Call oView.Add("mouseover")
    Call oView.Add("origin")
    
     Select Case ActiveControls.Class.Name
        Case "helpdesk":
            Call oFilter.AddCondition("origin", lkOpEqual, "BusinessTest")
     End Select
     
    Call oRecs.Open(Database.Classes("checklist"), oFilter, oView)
    
    XMLText = "<xmlchecklist>"
    For Each oRec In oRecs
        XMLText = XMLText + oRec.XMLText
    Next oRec
    XMLText = XMLText + "</xmlchecklist>"
    
'Define your own static checklist here
ElseIf Source = "static" Then
    Dim Checklist(1) As ChecklistItem
    Checklist(0).title = "test"
    Checklist(1).title = "test2"
    XMLText = SerializeChecklistItems(Checklist)
End If

Call Save(XMLText, XmlField)

Exit Sub
ErrorHandler:
    UI.ShowError ("Checklist.CreateChecklist")
End Sub


Public Function PerfromAction(id As Long) As Boolean
    PerfromAction = True
End Function


Public Function Initialize(XmlField As String) As String
On Error GoTo ErrorHandler
    If AutoCreate = True Then
        If ActiveControls.GetText(XmlField) = "" Then
            Call CreateChecklist("checklist")
        End If
    End If
    If ActiveControls.GetText(XmlField) <> "" Then
        Initialize = ActiveControls.GetText(XmlField)
    Else
        Initialize = "<xmlchecklist></xmlchecklist>"
    End If
Exit Function
ErrorHandler:
    UI.ShowError ("Checklist.Initialize")
End Function

Public Function Save(xmlString As String, XmlField As String)
On Error GoTo ErrorHandler
    Call ActiveControls.SetValue(XmlField, xmlString)
Exit Function
ErrorHandler:
     UI.ShowError ("Checklist.Initialize")
End Function

Public Sub test()
    Dim Checklistitems(2) As ChecklistItem
    
    Checklistitems(1).title = "test123"
    Checklistitems(2).title = "test2213"
    
    Debug.Print (SerializeChecklistItems(Checklistitems))
    
End Sub

Private Function SerializeChecklistItems(ByRef Checklistitems() As ChecklistItem) As String
    Dim XML As String
    Dim i As Integer
    XML = "<xmlchecklist>"
    For i = LBound(Checklistitems) To UBound(Checklistitems)
        XML = XML + "<checklist>" _
        & "<idchecklist>" & CStr(Checklistitems(i).idchecklist) & "</idchecklist>" _
        & "<order>" & CStr(Checklistitems(i).order) & "</order>" _
        & "<title>" & Checklistitems(i).title & "</title>" _
        & "<mouseover>" & Checklistitems(i).mouseover & "</mouseover>" _
        & "<isChecked>" & CStr(Checklistitems(i).isChecked) & "</isChecked>" _
        & "<checkedDate>" & Checklistitems(i).checkedDate & "</checkedDate>" _
        & "<checkedBy>" & Checklistitems(i).checkedBy & "</checkedBy>" _
        & "</checklist>"
    Next
    
    XML = XML + "</xmlchecklist>"
    SerializeChecklistItems = XML

End Function
