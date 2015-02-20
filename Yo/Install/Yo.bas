Attribute VB_Name = "Yo"
Option Explicit
Public Function GetQuestionsXML() As String
    On Error GoTo ErrorHandler
    'Get XML for 3 questions to show. Exclude questions already answered by active user.
    'Show 'active' questions, order by 1. type = info, 2. showfrom, 3. showto
    Dim questionXML As String
    Dim oQuestionExcludeRecords As New LDE.Records
    Dim oQuestionExcludeFilter As New LDE.Filter
    
    Dim oQuestionFilter As New LDE.Filter
    Dim oRecords As New LDE.Records
    Dim oRecord As LDE.Record
    Dim oView As New LDE.View
    Dim oCreatedCoworker As New LDE.Record
    
    'get idquestion for the coworkers answers
    Call oQuestionExcludeFilter.AddCondition("answer.coworker", lkOpEqual, ActiveUser.Record.ID)
    Call oQuestionExcludeRecords.Open(Database.Classes("question"), oQuestionExcludeFilter)
    
    Call oQuestionFilter.AddCondition("showfrom", lkOpLessOrEqual, Now)
    Call oQuestionFilter.AddCondition("showto", lkOpGreaterOrEqual, Now)
    Call oQuestionFilter.AddCondition("idquestion", lkOpNotIn, oQuestionExcludeRecords.Pool, lkConditionTypePool) 'exclude questions already answered
    oQuestionFilter.AddOperator lkOpAnd
    oQuestionFilter.AddOperator lkOpAnd
    
    Call oView.Add("text")
    Call oView.Add("type")
    Call oView.Add("urgent", lkSortDescending)
    Call oView.Add("showfrom", lkSortDescending)
    Call oView.Add("showto", lkSortAscending)
    Call oView.Add("range")
    
    
    
    Call oRecords.Open(Database.Classes("question"), oQuestionFilter, oView, 1)
    questionXML = "<yo>"
    
    For Each oRecord In oRecords
        'Build XML...
        Call oCreatedCoworker.Open(Database.Classes("coworker"), oRecord.CreatedBy, "office")
        If (oRecord.GetOptionKey("range") = "my" And oCreatedCoworker.Value("office") = ActiveUser.Record.Value("office")) Or oRecord.GetOptionKey("range") = "all" Then
            questionXML = questionXML & "<id>"
            questionXML = questionXML & oRecord.ID
            questionXML = questionXML & "</id>"
            questionXML = questionXML & "<text>"
            questionXML = questionXML & oRecord.Text("text")
            questionXML = questionXML & "</text>"
            questionXML = questionXML & "<type>"
            questionXML = questionXML & oRecord.GetOptionKey("type")
            questionXML = questionXML & "</type>"
        End If
    Next oRecord
    
    questionXML = questionXML & "</yo>"
    
    
    GetQuestionsXML = questionXML
    
    Exit Function
ErrorHandler:
    GetQuestionsXML = "<xml/>"
    Call UI.ShowError("Yo.GetQuestionsXML")
End Function


Public Sub SaveAnswer(ByVal sAnswer As String, ByVal sIdQuestion As String)
    On Error GoTo ErrorHandler
    'Save answer to question, set text and coworker
    
    Dim oRecord As New LDE.Record
    
    Call oRecord.Open(Database.Classes("answer"))
    oRecord.Value("coworker") = ActiveUser.Record.ID
    oRecord.Value("question") = CLng(sIdQuestion)
    oRecord.Value("answer") = sAnswer
    oRecord.Update
    Exit Sub
ErrorHandler:
    Call UI.ShowError("Yo.SaveAnswer")
End Sub
