Attribute VB_Name = "Checklist"
Option Explicit
Private m_Controls As Lime.Controls
Private m_Inspector As Lime.Inspector

'A model of a cheklist item. Create an array and serialize to get an nice XML
'This is bad VBA naming, but makes the JS better
Private Type ChecklistItem
    idchecklist As String
    Order As Integer
    Title As String 'Displayed text
    Description As String 'Thext displayed on hover
    IsChecked As Boolean
    checkedDate As String 'ISO formated string 2014-01-01 12:00:00
    checkedBy As String
End Type

'This function is always called by the checklist and supplies the data
Public Function Initialize(XmlField As String) As String
On Error GoTo ErrorHandler
    Set m_Controls = ActiveControls
    Set m_Inspector = ActiveInspector
    If m_Controls.GetText(XmlField) = "" Then
        Initialize = "<checklist></checklist>"
    Else
        Initialize = ActiveControls.GetText(XmlField)
    End If
        
Exit Function
ErrorHandler:
    UI.ShowError ("Checklist.Initialize")
End Function


'This functions creates a checklist and is the default function to be called for creation
'You can specify any other funciton in the app config as well, config - createChecklistFunction
Public Function CreateChecklist() As String
On Error GoTo ErrorHandler
  
    'Insert your creation code here
    
    'Example of creating a static Checklist
    Dim Checklist(1 To 2) As ChecklistItem
    Checklist(1) = CreateChecklistItem("test", "Mega Test", 1)
    Checklist(2) = CreateChecklistItem("test2", "Mega Test 2", 2)
    CreateChecklist = SerializeChecklistItems(Checklist)

Exit Function
ErrorHandler:
    UI.ShowError ("Checklist.CreateChecklist")
End Function

' This function is called any time a checklistitem is checked or unchecked
' You should implement any logic you whant here. Return True if your action was succesfull and False to abort the checking
' It is possible to call any other function aswell: config - performActionFunction
Public Function PerformAction(ByVal bChecked As Boolean, ByVal idchecklist As String, Optional sTitle As String) As Boolean
    On Error GoTo ErrorHandler
      
    If bChecked = False Then
        'Insert your code for a checked item here
        Call NewHistoryNote(sTitle, bChecked)
        PerformAction = True
    Else
        'Insert your code for a unchecked item here
        
        PerformAction = True
    End If
    
    
    Exit Function
ErrorHandler:
    UI.ShowError ("Checklist.PerfromAction")
End Function


Public Function Save(xmlString As String, XmlField As String)
On Error GoTo ErrorHandler
    
    If (ActiveInspector.Record.State And lkRecordStateNew) = lkRecordStateNew Then
        'Lets not make anything just yet
    Else
        If Not ActiveInspector Is Nothing Then
            Call m_Controls.SetValue(XmlField, xmlString)
        End If
    End If

Exit Function
ErrorHandler:
     UI.ShowError ("Checklist.Save")
End Function


'------------------------------------------
'===============Helper functions===========
'------------------------------------------

Private Function CreateChecklistItem(Title As String, Description As String, Order As Integer, Optional IsChecked As Boolean, Optional checkedDate As String, Optional checkedBy As String, Optional idchecklist As String) As ChecklistItem
On Error GoTo ErrorHandler
    Dim Item As ChecklistItem
    Item.Title = Title
    Item.Description = Description
    Item.Order = Order
    Item.IsChecked = IsChecked
    Item.checkedDate = checkedDate
    Item.checkedBy = checkedBy
    Item.idchecklist = idchecklist
    CreateChecklistItem = Item
    Exit Function
ErrorHandler:
    Call UI.ShowError("Checklist.CreateChecklistItem")
End Function

Private Function SerializeChecklistItems(ByRef Checklistitems() As ChecklistItem) As String
On Error GoTo ErrorHandler
    Dim XML As String
    Dim i As Integer
    XML = "<checklist>"
    For i = LBound(Checklistitems) To UBound(Checklistitems)
        XML = XML + "<checklistItem>" _
        & "<idchecklist>" & CStr(Checklistitems(i).idchecklist) & "</idchecklist>" _
        & "<order>" & CStr(Checklistitems(i).Order) & "</order>" _
        & "<title>" & Checklistitems(i).Title & "</title>" _
        & "<description>" & Checklistitems(i).Description & "</description>" _
        & "<isChecked>" & LCase(CStr(Checklistitems(i).IsChecked)) & "</isChecked>" _
        & "<checkedDate>" & Checklistitems(i).checkedDate & "</checkedDate>" _
        & "<checkedBy>" & Checklistitems(i).checkedBy & "</checkedBy>" _
        & "</checklistItem>"
    Next
    
    XML = XML + "</checklist>"
    SerializeChecklistItems = XML
    Exit Function
ErrorHandler:
    Call UI.ShowError("Checklist.SerializeChecklistItems")
End Function


Private Function NewHistoryNote(ByVal sNote As String, ByVal bChecked As Boolean)
On Error GoTo ErrorHandler

    'Is it a brand new record?
    If (ActiveInspector.Record.State And lkRecordStateNew) = lkRecordStateNew Then
        Call MsgBox("This is a brand new card. You must give it a name and save it before checking of stuff!", vbOKOnly, "Hold your horses!")
        Exit Function
    End If
    
    Dim oRecord As New LDE.Record
    Dim oNewInspector As Lime.Inspector
        
    oRecord.Open Database.Classes("history")
    oRecord.value("type") = "comment"
    oRecord.value("business") = m_Controls.Record.id
    
    If bChecked = True Then
        oRecord.value("note") = sNote + " - Avprickad: "
    Else
        oRecord.value("note") = sNote + " - Återupptagen: "
    End If
    
    Set oNewInspector = Lime.OpenInspector(ActiveInspector, oRecord, lkActivateExisting)
    
    'Set Focus to the correct field
    Set oNewInspector.Controls.ActiveControl = oNewInspector.Controls("note")
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("Checklist.CreateHistory")
End Function

'------------------------------------------
'===============EXAMPLES===================
'------------------------------------------

'Loads the checklist from the table called "Checklist"
Public Function CreateChecklistFromTable() As String
    Dim oRecs As New LDE.Records
    Dim oRec As New LDE.Record
    Dim oFilter As New LDE.Filter
    Dim oView As New LDE.View
    Dim i As Integer
    Dim Checklist() As ChecklistItem
    
    Call oView.Add("title")
    Call oView.Add("idchecklist")
    Call oView.Add("order", lkSortAscending)
    Call oView.Add("mouseover")
    Call oView.Add("origin")
    
    Call oFilter.AddCondition("origin", lkOpEqual, "BusinessTest")
    Call oRecs.Open(Database.Classes("checklist"), oFilter, oView)
    
    ReDim Checklist(1 To oRecs.Count) 'YAY! Well spent 2h of my life...
    
    i = 1
    For Each oRec In oRecs
        Checklist(i) = CreateChecklistItem(oRec.value("title"), oRec.value("mouseover"), oRec.value("order"), , , , oRec.value("idchecklist"))
        i = i + 1
    Next oRec
    
    CreateChecklistFromTable = SerializeChecklistItems(Checklist)

End Function

'A hardcoded checklist
Public Function CreateStaticChecklist() As String
On Error GoTo ErrorHandler
  
    'Example of creating a static Checklist
    Dim Checklist(1 To 2) As ChecklistItem 'Create an array of two checklistitem
    Checklist(1) = CreateChecklistItem("test", "Mega Test", 1)
    Checklist(2) = CreateChecklistItem("test2", "Mega Test 2", 2)
    CreateStaticChecklist = SerializeChecklistItems(Checklist) 'Turn the checklistitem array into a nice xml string

Exit Function
ErrorHandler:
    UI.ShowError ("Checklist.CreateChecklist")
End Function


'Create a checklist from a option or set field.
Public Function CreateChecklistFromSetField() As String
On Error GoTo ErrorHandler
    Dim opt As LDE.Option
    Dim Checklist() As ChecklistItem
    Dim optionFieldName As String
    Dim i As Integer
    
    optionFieldName = "businesstatus"
    ReDim Checklist(1 To m_Controls("businesstatus").field.Options.Count)
  
    i = 1
    For Each opt In m_Controls("businesstatus").field.Options
        Checklist(i) = CreateChecklistItem(opt.Text, opt.Text, i, , , , opt.Key)
        i = i + 1
    Next opt
    'Example of creating a static Checklist

    CreateChecklistFromSetField = SerializeChecklistItems(Checklist) 'Turn the checklistitem array into a nice xml string

Exit Function
ErrorHandler:
    UI.ShowError ("Checklist.CreateChecklist")
End Function

'------------------------------------------
'===============INSTALLER==================
'------------------------------------------
Public Sub Install()
    Dim sOwner As String
    sOwner = "Checklist"

    Call AddOrCheckLocalize( _
        sOwner, _
        "remove_warning", _
        "Gives the user a warning before removing a checklist item", _
        "You are about to remove this item. You won't be able to undo this action. Proceeed?", _
        "Du är på väg att ta bort uppgiften för gott. Du kommer inte kunna återställa uppgiften. Fortsätta?", _
        " ", _
        " " _
    )

End Sub


Private Function AddOrCheckLocalize(sOwner As String, sCode As String, sDescription As String, sEN_US As String, sSV As String, sNO As String, sFI As String) As Boolean
    On Error GoTo ErrorHandler:
    Dim oFilter As New LDE.Filter
    Dim oRecs As New LDE.Records
    
    Call oFilter.AddCondition("owner", lkOpEqual, sOwner)
    Call oFilter.AddCondition("code", lkOpEqual, sCode)
    oFilter.AddOperator lkOpAnd
    
    If oFilter.HitCount(Database.Classes("localize")) = 0 Then
        Debug.Print ("Localization " & sOwner & "." & sCode & " not found, creating new!")
        Dim oRec As New LDE.Record
        Call oRec.Open(Database.Classes("localize"))
        oRec.value("owner") = sOwner
        oRec.value("code") = sCode
        oRec.value("context") = sDescription
        oRec.value("sv") = sSV
        oRec.value("en_us") = sEN_US
        oRec.value("no") = sNO
        oRec.value("fi") = sFI
        Call oRec.Update
    ElseIf oFilter.HitCount(Database.Classes("localize")) = 1 Then
    Debug.Print ("Updating localization " & sOwner & "." & sCode)
        Call oRecs.Open(Database.Classes("localize"), oFilter)
        oRecs(1).value("owner") = sOwner
        oRecs(1).value("code") = sCode
        oRecs(1).value("context") = sDescription
        oRecs(1).value("sv") = sSV
        oRecs(1).value("en_us") = sEN_US
        oRecs(1).value("no") = sNO
        oRecs(1).value("fi") = sFI
        Call oRecs.Update
        
    Else
        Call MsgBox("There are multiple copies of " & sOwner & "." & sCode & "  which is bad! Fix it", vbCritical, "To many translations makes Jack a dull boy")
    End If
    
    Set Localize.dicLookup = Nothing
    AddOrCheckLocalize = True
    Exit Function
ErrorHandler:
    Debug.Print ("Error while validating or adding Localize")
    AddOrCheckLocalize = False
End Function

