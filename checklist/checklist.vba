Option Explicit
Private m_Controls As Lime.Controls
Public Const AutoCreate As Boolean = True
Public Const Source As String = "static" 'Can be "table", "static" or "custom"

'A model of a cheklist item. Create an array and serialize to get an nice XML
'This is bad VBA naming, but makes the JS better
Private Type ChecklistItem
    idchecklist As String
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
    
'Define your own static checklist here and how many items you have in your checklist

ElseIf Source = "static" Then

   
    If XmlField = "checklist" Then
        Dim Checklist(15) As ChecklistItem
        Checklist(0).idchecklist = Application.Classes("business").Fields("apartmentlist").Name
        Checklist(0).title = Application.Classes("business").Fields("apartmentlist").LocalName
        Checklist(0).mouseover = Application.Classes("business").Fields("apartmentlist").LocalName
        Checklist(0).order = 1
        Checklist(1).idchecklist = Application.Classes("business").Fields("contactinfocustomer").Name
        Checklist(1).title = Application.Classes("business").Fields("contactinfocustomer").LocalName
        Checklist(1).mouseover = Application.Classes("business").Fields("contactinfocustomer").LocalName
        Checklist(1).order = 2
        Checklist(2).idchecklist = Application.Classes("business").Fields("contactpersonue").Name
        Checklist(2).title = Application.Classes("business").Fields("contactpersonue").LocalName
        Checklist(2).mouseover = Application.Classes("business").Fields("contactpersonue").LocalName
        Checklist(2).order = 3
        Checklist(3).idchecklist = Application.Classes("business").Fields("invoiceadress").Name
        Checklist(3).title = Application.Classes("business").Fields("invoiceadress").LocalName
        Checklist(3).mouseover = Application.Classes("business").Fields("invoiceadress").LocalName
        Checklist(3).order = 4
        Checklist(4).idchecklist = Application.Classes("business").Fields("allstreetadresses").Name
        Checklist(4).title = Application.Classes("business").Fields("allstreetadresses").LocalName
        Checklist(4).mouseover = Application.Classes("business").Fields("allstreetadresses").LocalName
        Checklist(4).order = 5
        Checklist(5).idchecklist = Application.Classes("business").Fields("installationdescr").Name
        Checklist(5).title = Application.Classes("business").Fields("installationdescr").LocalName
        Checklist(5).mouseover = Application.Classes("business").Fields("installationdescr").LocalName
        Checklist(5).order = 6
        Checklist(6).idchecklist = Application.Classes("business").Fields("pictures").Name
        Checklist(6).title = Application.Classes("business").Fields("pictures").LocalName
        Checklist(6).mouseover = Application.Classes("business").Fields("pictures").LocalName
        Checklist(6).order = 7
        Checklist(7).idchecklist = Application.Classes("business").Fields("tssdoc").Name
        Checklist(7).title = Application.Classes("business").Fields("tssdoc").LocalName
        Checklist(7).mouseover = Application.Classes("business").Fields("tssdoc").LocalName
        Checklist(7).order = 8
        Checklist(8).idchecklist = Application.Classes("business").Fields("keysandcodes").Name
        Checklist(8).title = Application.Classes("business").Fields("keysandcodes").LocalName
        Checklist(8).mouseover = Application.Classes("business").Fields("keysandcodes").LocalName
        Checklist(8).order = 9
        Checklist(9).idchecklist = Application.Classes("business").Fields("inforoutine").Name
        Checklist(9).title = Application.Classes("business").Fields("inforoutine").LocalName
        Checklist(9).mouseover = Application.Classes("business").Fields("inforoutine").LocalName
        Checklist(9).order = 10
        Checklist(10).idchecklist = Application.Classes("business").Fields("firstalloc").Name
        Checklist(10).title = Application.Classes("business").Fields("firstalloc").LocalName
        Checklist(10).mouseover = Application.Classes("business").Fields("firstalloc").LocalName
        Checklist(10).order = 11
        Checklist(11).idchecklist = Application.Classes("business").Fields("administrator").Name
        Checklist(11).title = Application.Classes("business").Fields("administrator").LocalName
        Checklist(11).mouseover = Application.Classes("business").Fields("administrator").LocalName
        Checklist(11).order = 12
        Checklist(12).idchecklist = Application.Classes("business").Fields("contractdraft").Name
        Checklist(12).title = Application.Classes("business").Fields("contractdraft").LocalName
        Checklist(12).mouseover = Application.Classes("business").Fields("contractdraft").LocalName
        Checklist(12).order = 13
        Checklist(13).idchecklist = Application.Classes("business").Fields("duedate").Name
        Checklist(13).title = Application.Classes("business").Fields("duedate").LocalName
        Checklist(13).mouseover = Application.Classes("business").Fields("duedate").LocalName
        Checklist(13).order = 14
        Checklist(14).idchecklist = Application.Classes("business").Fields("compensationsmodel").Name
        Checklist(14).title = Application.Classes("business").Fields("compensationsmodel").LocalName
        Checklist(14).mouseover = Application.Classes("business").Fields("compensationsmodel").LocalName
        Checklist(14).order = 15
        Checklist(15).idchecklist = Application.Classes("business").Fields("alreadymeasures").Name
        Checklist(15).title = Application.Classes("business").Fields("alreadymeasures").LocalName
        Checklist(15).mouseover = Application.Classes("business").Fields("alreadymeasures").LocalName
        Checklist(15).order = 16
        XMLText = SerializeChecklistItems(Checklist)
        
    ElseIf XmlField = "checklistprojectmanager" Then
        Dim ChecklistProject(13) As ChecklistItem
        ChecklistProject(0).idchecklist = Application.Classes("business").Fields("limelinkalloc").Name
        ChecklistProject(0).title = Application.Classes("business").Fields("limelinkalloc").LocalName
        ChecklistProject(0).order = 1
        ChecklistProject(0).mouseover = Application.Classes("business").Fields("limelinkalloc").LocalName
        ChecklistProject(1).idchecklist = Application.Classes("business").Fields("prestocust").Name
        ChecklistProject(1).title = Application.Classes("business").Fields("prestocust").LocalName
        ChecklistProject(1).mouseover = Application.Classes("business").Fields("prestocust").LocalName
        ChecklistProject(1).order = 2
        ChecklistProject(2).idchecklist = Application.Classes("business").Fields("assigntech").Name
        ChecklistProject(2).title = Application.Classes("business").Fields("assigntech").LocalName
        ChecklistProject(2).mouseover = Application.Classes("business").Fields("assigntech").LocalName
        ChecklistProject(2).order = 3
        ChecklistProject(3).idchecklist = Application.Classes("business").Fields("testinst").Name
        ChecklistProject(3).title = Application.Classes("business").Fields("testinst").LocalName
        ChecklistProject(3).mouseover = Application.Classes("business").Fields("testinst").LocalName
        ChecklistProject(3).order = 4
        ChecklistProject(4).idchecklist = Application.Classes("business").Fields("planinst").Name
        ChecklistProject(4).title = Application.Classes("business").Fields("planinst").LocalName
        ChecklistProject(4).mouseover = Application.Classes("business").Fields("planinst").LocalName
        ChecklistProject(4).order = 5
        ChecklistProject(5).idchecklist = Application.Classes("business").Fields("planrest").Name
        ChecklistProject(5).title = Application.Classes("business").Fields("planrest").LocalName
        ChecklistProject(5).mouseover = Application.Classes("business").Fields("planrest").LocalName
        ChecklistProject(5).order = 6
        ChecklistProject(6).idchecklist = Application.Classes("business").Fields("prodinfo").Name
        ChecklistProject(6).title = Application.Classes("business").Fields("prodinfo").LocalName
        ChecklistProject(6).mouseover = Application.Classes("business").Fields("prodinfo").LocalName
        ChecklistProject(6).order = 7
        ChecklistProject(7).idchecklist = Application.Classes("business").Fields("sendinfo").Name
        ChecklistProject(7).title = Application.Classes("business").Fields("sendinfo").LocalName
        ChecklistProject(7).mouseover = Application.Classes("business").Fields("sendinfo").LocalName
        ChecklistProject(7).order = 8
        ChecklistProject(8).idchecklist = Application.Classes("business").Fields("fixprot").Name
        ChecklistProject(8).title = Application.Classes("business").Fields("fixprot").LocalName
        ChecklistProject(8).mouseover = Application.Classes("business").Fields("fixprot").LocalName
        ChecklistProject(8).order = 9
        ChecklistProject(9).idchecklist = Application.Classes("business").Fields("cleanprot").Name
        ChecklistProject(9).title = Application.Classes("business").Fields("cleanprot").LocalName
        ChecklistProject(9).mouseover = Application.Classes("business").Fields("cleanprot").LocalName
        ChecklistProject(9).order = 10
        ChecklistProject(10).idchecklist = Application.Classes("business").Fields("instreport").Name
        ChecklistProject(10).title = Application.Classes("business").Fields("instreport").LocalName
        ChecklistProject(10).mouseover = Application.Classes("business").Fields("instreport").LocalName
        ChecklistProject(10).order = 11
        ChecklistProject(11).idchecklist = Application.Classes("business").Fields("limelinkorder").Name
        ChecklistProject(11).title = Application.Classes("business").Fields("limelinkorder").LocalName
        ChecklistProject(11).mouseover = Application.Classes("business").Fields("limelinkorder").LocalName
        ChecklistProject(11).order = 12
        ChecklistProject(12).idchecklist = Application.Classes("business").Fields("readcheck").Name
        ChecklistProject(12).title = Application.Classes("business").Fields("readcheck").LocalName
        ChecklistProject(12).mouseover = Application.Classes("business").Fields("readcheck").LocalName
        ChecklistProject(12).order = 13
        ChecklistProject(13).idchecklist = Application.Classes("business").Fields("lastreport").Name
        ChecklistProject(13).title = Application.Classes("business").Fields("lastreport").LocalName
        ChecklistProject(13).mouseover = Application.Classes("business").Fields("lastreport").LocalName
        ChecklistProject(13).order = 14
        XMLText = SerializeChecklistItems(ChecklistProject)
    End If
    
End If

Call Save(XMLText, XmlField)

Exit Sub
ErrorHandler:
    UI.ShowError ("Checklist.CreateChecklist")
End Sub

Public Function PerfromAction(ByVal bChecked As Boolean, ByVal sFieldName As String, Optional sTitle As String) As Boolean
    On Error GoTo ErrorHandler
    
  
    
    Dim oInspector As Lime.Inspector
    
    Set oInspector = ActiveInspector
    
      If m_Controls.GetValue("name") = "" Then
            Call MsgBox("Ett värde måste anges för fältet 'Namn'", vbInformation)
            m_Controls.SetFocus ("name")
            Exit Function
      End If
      
    If (oInspector.Record.State And lkRecordStateNew) = lkRecordStateNew Then
        Call MsgBox("Affären är ny och kommer nu att sparas. Du kommer bli tvungen att pricka av checklista-punkten igen.", vbInformation)
        PerfromAction = False
        Exit Function
    End If
      
    If bChecked = False Then
        Call m_Controls.SetValue(sFieldName, 1)
        
        Call CreateHistory(sTitle, True)
        PerfromAction = True
    Else
        Call m_Controls.SetValue(sFieldName, 0)
        
        Call CreateHistory(sTitle, False)
        PerfromAction = False
        
    End If
    
    oInspector.Save (False)
    
    Exit Function
ErrorHandler:
    UI.ShowError ("Checklist.PerfromAction")
End Function


Public Function Initialize(XmlField As String) As String
On Error GoTo ErrorHandler
    Set m_Controls = ActiveControls
    If AutoCreate = True Then
        If ActiveControls.GetText(XmlField) = "" Then
            Call CreateChecklist(XmlField)
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
    Call m_Controls.SetValue(XmlField, xmlString)
    If m_Controls.GetValue("name") <> "" Then
        'm_Controls.Save
        If Not ActiveInspector Is Nothing Then
            ActiveInspector.Save (True)
        End If
    End If
Exit Function
ErrorHandler:
     UI.ShowError ("Checklist.Save")
End Function

Private Function CreateHistory(ByVal sNote As String, ByVal bChecked As Boolean)
    On Error GoTo ErrorHandler
    
    Dim oRecord As New LDE.Record
    Dim oNewInspector As Lime.Inspector
        
    oRecord.Open Database.Classes("history")
        
    oRecord.Value("type") = "checklist"
    oRecord.Value("business") = ActiveInspector.Record.ID
    
    If bChecked = True Then
        oRecord.Value("note") = sNote + " - Avprickad: "
    Else
        oRecord.Value("note") = sNote + " - Återupptagen: "
    End If
    
    Set oNewInspector = Lime.OpenInspector(ActiveInspector, oRecord, lkActivateExisting)
    
    'Set Focus to the correct field
    Set oNewInspector.Controls.ActiveControl = oNewInspector.Controls("note")
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("ControlsHandlerDocument.NewHistory")
End Function


Public Sub SaveInspector()
    On Error GoTo ErrorHandler
    
    Dim oInspector As Lime.Inspector
    
    If Not ActiveInspector Is Nothing Then
        Set oInspector = ActiveInspector
    End If
    
    If oInspector.Class.Name = "business" Then
        If m_Controls.GetValue("name") <> "" Then
            Call oInspector.Save(False)
        End If
    Else
        If Not oInspector.ParentInspector Is Nothing Then
            If oInspector.ParentInspector.Class.Name = "business" Then
                Call oInspector.ParentInspector.Save(False)
            End If
        End If
    End If
        
    Exit Sub
ErrorHandler:
    Call UI.ShowError("Checklist.SaveInspector")
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
