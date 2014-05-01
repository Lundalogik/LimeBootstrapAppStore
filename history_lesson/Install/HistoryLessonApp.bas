Attribute VB_Name = "HistoryLessonApp"
Public Function GetHistory(nameOfHistoryTable As String, nameOfRelationField As String, idRelatedObject As Long, nbrOfRecords As Integer) As lde.Records
On Error GoTo ErrorHandler
    Dim oRecs As New lde.Records
    Dim oFilter As New lde.Filter
    
    Call oFilter.AddCondition(nameOfRelationField, lkOpEqual, idRelatedObject)
    Call oRecs.Open(Database.Classes(nameOfHistoryTable), oFilter, , nbrOfRecords)
    
    Set GetHistory = oRecs
    
Exit Function
ErrorHandler:
Call UI.ShowError("HistoryLessonApp.GetHistory")
End Function

