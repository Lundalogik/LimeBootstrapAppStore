Attribute VB_Name = "DataFlow"
Option Explicit

Private Function GetFilterByKey(ByVal sFilterKey As String) As LDE.Filter
On Error GoTo ErrorHandler
    Dim oFilter As LDE.Filter
    Select Case sFilterKey
        Case "exampleKey":
            ' Create the oFilter here. Don't forget to initialize the filter first. (Set oFilter = New LDE.Filter)
        Case Else
            Set oFilter = Nothing
    End Select
    
    Set GetFilterByKey = oFilter
Exit Function
ErrorHandler:
    Call UI.ShowError("DataFlow.GetFilterByKey")
End Function

Public Function GetInitialData(ByVal sStructureXml As String, ByVal sFilterKey As String) As String
On Error GoTo ErrorHandler
    Dim sXml As String
    Dim sErrorMessage As String
    Dim oFilter As New LDE.Filter
    Dim oView As New LDE.View
    Dim oRecords As New LDE.Records
    Dim oClass As LDE.Class
    Dim oRelationField As LDE.field
    Dim sRelatedClass As String
    Dim oRecord As LDE.Record
    Dim oInspector As Lime.Inspector
    
    Dim lngPageSize As Long
    Dim eSortOrder As LDE.SortOrderEnum
    Dim sTableName As String
    Dim sTitleFieldName As String
    Dim sTypeFieldName As String
    Dim sDateFieldName As String
    Dim sRelationFieldName As String
    Dim sNoteFieldName As String
    Dim sClickableRelationFieldName As String
    
    Dim oXml As New MSXML2.DOMDocument60
    
    If oXml.loadXML(sStructureXml) Then
        If VBA.LCase(oXml.firstChild.selectSingleNode("pageSize").Text) = "ascending" Then
            eSortOrder = lkSortAscending
        Else
            eSortOrder = lkSortDescending
        End If
        
        lngPageSize = VBA.CLng(oXml.firstChild.selectSingleNode("pageSize").Text)
        sTableName = oXml.firstChild.selectSingleNode("tableName").Text
        sTitleFieldName = oXml.firstChild.selectSingleNode("titleFieldName").Text
        sTypeFieldName = oXml.firstChild.selectSingleNode("typeFieldName").Text
        sDateFieldName = oXml.firstChild.selectSingleNode("dateFieldName").Text
        sRelationFieldName = oXml.firstChild.selectSingleNode("relationFieldName").Text
        sNoteFieldName = oXml.firstChild.selectSingleNode("noteFieldName").Text
        sClickableRelationFieldName = oXml.firstChild.selectSingleNode("clickableRelationFieldName").Text
    End If
    
    Set oInspector = Application.ActiveInspector
    
    sXml = "<initialData>"
    Set oClass = Database.Classes.Lookup(sTableName, lkLookupClassByName)
    If Not oClass Is Nothing Then
    
        Set oRelationField = oClass.Fields.Lookup(sRelationFieldName, lkLookupFieldByName)
        If Not oRelationField Is Nothing Then
            sRelatedClass = oRelationField.LinkedField.Class.Name
            If Globals.VerifyInspector(sRelatedClass, oInspector, True) Then
                Call oView.Add(sTitleFieldName)
                Call oView.Add(sTypeFieldName)
                Call oView.Add(sDateFieldName, eSortOrder)
                Call oView.Add(sRelationFieldName)
                Call oView.Add(sNoteFieldName)
                Call oView.Add(sClickableRelationFieldName)
                
                Set oFilter = GetFilterByKey(sFilterKey)
                
                Call oFilter.AddCondition(sRelationFieldName, lkOpEqual, oInspector.Record.ID)
                
                If oFilter.Count > 1 Then
                    Call oFilter.AddOperator(lkOpAnd)
                End If

                Call oRecords.Open(oClass, oFilter, oView, lngPageSize)
                sXml = sXml & "<dataFlows>"
                For Each oRecord In oRecords
                    sXml = sXml & "<dataFlow>"
                    
                    Dim sDate As String
                    Dim sTime As String
                    
                    sDate = VBA.Format(oRecord.Value(sDateFieldName), "YYYY-MM-DD")
                    sTime = VBA.Format(oRecord.Value(sDateFieldName), "HH:MM")
                    
                    Call AddXmlElement(sXml, "limeid", VBA.CStr(oRecord.ID))
                    Call AddXmlElement(sXml, "title", VBA.CStr(oRecord.Text(sTitleFieldName)))
                    Select Case oRecord.Fields(sTypeFieldName).Type
                        Case lkFieldTypeOption
                            Call AddXmlElement(sXml, "type", oRecord.GetOptionKey(sTypeFieldName))
                        Case Else
                            Call AddXmlElement(sXml, "type", oRecord.Text(sTypeFieldName))
                    End Select
                    
                    Call AddXmlElement(sXml, "date", sDate)
                    Call AddXmlElement(sXml, "time", sTime)
                    Call AddXmlElement(sXml, "note", VBA.Left(oRecord.Text(sNoteFieldName), 200))
                    
                    If VBA.IsNull(oRecord.Value(sClickableRelationFieldName)) = False Then
                        Call AddXmlElement(sXml, "clickableRelation_id", oRecord.Value(sClickableRelationFieldName))
                        Call AddXmlElement(sXml, "clickableRelation_text", oRecord.Text(sClickableRelationFieldName))
                    End If
                    
                    sXml = sXml & "</dataFlow>"
                Next oRecord
                sXml = sXml & "</dataFlows>"
            End If
        Else
            sErrorMessage = Lime.FormatString("Can not find the relation field: '%1' on table '%2'", sRelationFieldName, sTableName)
        End If
    Else
        sErrorMessage = Lime.FormatString("Can not find the table: '%1'", sTableName)
    End If
    
    
    sXml = sXml & "</initialData>"
    GetInitialData = sXml
Exit Function
ErrorHandler:
    Call UI.ShowError("DataFlow.GetInitialData")
End Function


Private Sub AddXmlElement(ByRef sXml As String, ByVal sElementName As String, ByVal sElementValue As String)
On Error GoTo ErrorHandler
    sXml = sXml & Lime.FormatString("<%1><![CDATA[%2]]></%1>", sElementName, sElementValue)
Exit Sub
ErrorHandler:
    Call UI.ShowError("DataFlow.AddXmlElement")
End Sub
