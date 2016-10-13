Attribute VB_Name = "app_Embrello"
Option Explicit

' Is set in sub setDataSource
Private m_dataSource As String

' Is set in sub setMaxNbrOfRecords.
Private m_maxNbrOfRecords As Long

' Used in field mappings dictionary to keep track of field names
Private Enum m_InformationTypeEnum
    sbBoardSummation = 1
    sbLaneTitle = 2
    sbCardTitle = 3
    sbCardPercent = 4
    sbCardValue = 5
    sbCardSorting = 6
    sbCardOwner = 7
    sbCardAdditionalInfo = 8
End Enum

' ##SUMMARY Opens Embrello in a pane
Public Sub openEmbrello()
    On Error GoTo ErrorHandler
    
    Dim url As String
    Dim p As Lime.Pane
    
    url = Application.WebFolder & "lbs.html?ap=apps/Embrello/embrello&type=inline"
    If Application.Panes.Exists("Embrello") Then
        Set p = Application.Panes("Embrello")
    End If
    If Not p Is Nothing Then
        p.url = url
    Else
        Set p = Application.Panes.Add("Embrello", , url, lkPaneStyleNoToolBar + lkPaneStylePersistentURL + lkPaneStyleRestrictedBrowsing)
    End If
    Set Application.Panes.ActivePane = p
    Application.Panes.Visible = True
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_Embrello.openEmbrello")
End Sub


' Ska även sätta en global m_explorer variabel o lite sånt gött. Byt sedan ut alla ActiveExplorers och lokala oExplorers till denna.
Public Function getBoardXML(boardConfigXML As String) As String
    On Error GoTo ErrorHandler
    
    'Debug.Print boardConfigXML
    
    ' Read board config from xml
    Dim oBoardXmlDoc As New MSXML2.DOMDocument60
    Call oBoardXmlDoc.loadXML(boardConfigXML)
    
    ' Use either VBA or SQL procedure. Determined in the app config
    If m_dataSource = "vba" Then
        getBoardXML = getBoardXMLUsingVBA(oBoardXmlDoc)
    ElseIf m_dataSource = "sql" Then
        getBoardXML = getBoardXMLUsingSQL(oBoardXmlDoc)
    End If
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.getBoardXML")
End Function

' ##SUMMARY Retrieves the board xml using a SQL stored procedure to fetch data from the database.
Private Function getBoardXMLUsingSQL(ByRef oBoardXmlDoc As MSXML2.DOMDocument60) As String
    On Error GoTo ErrorHandler
    
    Debug.Print "sql"
    
    ' Call procedure to get board data
    Dim oProc As LDE.Procedure
    Set oProc = Database.Procedures("csp_embrello_getboard")
    oProc.Parameters("@@tablename").InputValue = ActiveExplorer.Class.Name

    Call addSQLParameterFromXML(oProc, "@@lanefieldname", oBoardXmlDoc, "/board/lanes/optionField")
    Call addSQLParameterFromXML(oProc, "@@titlefieldname", oBoardXmlDoc, "/board/card/titleField")
    Call addSQLParameterFromXML(oProc, "@@completionfieldname", oBoardXmlDoc, "/board/card/percentField")
    Call addSQLParameterFromXML(oProc, "@@sumfieldname", oBoardXmlDoc, "/board/summation/field")
    Call addSQLParameterFromXML(oProc, "@@valuefieldname", oBoardXmlDoc, "/board/card/value/field")
    Call addSQLParameterFromXML(oProc, "@@sortfieldname", oBoardXmlDoc, "/board/card/sorting/field")
    Call addSQLParameterFromXML(oProc, "@@ownerfieldname", oBoardXmlDoc, "/board/card/owner/fieldName")
    Call addSQLParameterFromXML(oProc, "@@ownerrelatedtablename", oBoardXmlDoc, "/board/card/owner/relatedTableName")
    Call addSQLParameterFromXML(oProc, "@@ownerdescriptivefieldname", oBoardXmlDoc, "/board/card/owner/relatedTableFieldName")
    Call addSQLParameterFromXML(oProc, "@@additionalinfofieldname", oBoardXmlDoc, "/board/card/additionalInfo/fieldName")
    Call addSQLParameterFromXML(oProc, "@@additionalinforelatedtablename", oBoardXmlDoc, "/board/card/additionalInfo/relatedTableName")
    Call addSQLParameterFromXML(oProc, "@@additionalinfodescriptivefieldname", oBoardXmlDoc, "/board/card/additionalInfo/relatedTableFieldName")
    Call addSQLParameterFromXML(oProc, "@@additionalinfodateformat", oBoardXmlDoc, "/board/card/additionalInfo/dateFormat/sqlFormatCode")
    Call addSQLParameterFromXML(oProc, "@@additionalinfodatelength", oBoardXmlDoc, "/board/card/additionalInfo/dateFormat/length")
    
    oProc.Parameters("@@idrecords").InputValue = getIdsAsString()
    oProc.Parameters("@@lang").InputValue = Application.Locale
    oProc.Parameters("@@limeservername").InputValue = Database.RemoteServerName
    oProc.Parameters("@@limedbname").InputValue = Database.Name
    oProc.Parameters("@@iduser").InputValue = ActiveUser.ID

    Call oProc.Execute(False)
    Debug.Print oProc.result
    getBoardXMLUsingSQL = oProc.result

'Dim strFilename As String: strFilename = "D:\temp\embrelloexamplexml.txt"
'Dim strFileContent As String
'Dim iFile As Integer: iFile = FreeFile
'Open strFilename For Input As #iFile
'strFileContent = Input(LOF(iFile), iFile)
'Close #iFile
'Debug.Print strFileContent
'    getBoardXML = strFileContent
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.getBoardXMLUsingSQL")
End Function


' ##SUMMARY Adds the specified SQL parameter to the specified procedure object with an input value set to
' the text of the specified xPath.
Private Sub addSQLParameterFromXML(ByRef oProc As LDE.Procedure, parameterName As String _
                                    , ByRef oXmlDoc As MSXML2.DOMDocument60, xPath As String)
    On Error GoTo ErrorHandler
    
    Dim oNode As MSXML2.IXMLDOMNode
    Set oNode = oXmlDoc.selectSingleNode(xPath)
    If Not oNode Is Nothing Then
        oProc.Parameters(parameterName).InputValue = oNode.Text
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_Embrello.addSQLParameterFromXML")
End Sub


' ##SUMMARY Retrieves the board xml using VBA code to fetch data from the database.
Private Function getBoardXMLUsingVBA(ByRef oBoardXmlDoc As MSXML2.DOMDocument60) As String
    On Error GoTo ErrorHandler
    
    Debug.Print "vba"
    
    ' Cache ActiveExplorer
    Dim oExplorer As Lime.Explorer
    Set oExplorer = Application.ActiveExplorer
    If oExplorer Is Nothing Then
        Exit Function
    End If
    
    ' Set up field mappings
    Dim fieldMappings As Scripting.Dictionary
    Set fieldMappings = getFieldMappings(oBoardXmlDoc)
    
    ' Build data xml
    Dim oDataXml As New MSXML2.DOMDocument60
    Dim rootNode As MSXML2.IXMLDOMNode
    Set rootNode = oDataXml.appendChild(oDataXml.createElement("data"))
    
    ' Loop options to create Lanes elements
    Dim oOption As LDE.Option
    Dim oLaneElement As MSXML2.IXMLDOMElement
    For Each oOption In Database.Classes(oExplorer.Class.Name).Fields(fieldMappings(m_InformationTypeEnum.sbLaneTitle)).Options
        Set oLaneElement = oDataXml.createElement("Lanes")
        Call oLaneElement.SetAttribute("id", oOption.Value)
        Call oLaneElement.SetAttribute("key", oOption.key)
        Call oLaneElement.SetAttribute("name", oOption.Text)
        Call oLaneElement.SetAttribute("order", oOption.Attributes("stringorder"))
        Call rootNode.appendChild(oLaneElement)
    Next oOption
    
    ' Get records
    Dim oRecords As New LDE.Records
    Call oRecords.Open(Database.Classes(oExplorer.Class.Name), createFilter(oExplorer, fieldMappings(m_InformationTypeEnum.sbLaneTitle)), createView(fieldMappings), m_maxNbrOfRecords)
    
    ' Loop records and add to xml
    Dim oRecord As LDE.Record
    Dim oLaneNode As MSXML2.IXMLDOMNode
    Dim prevLaneId As Long
    Dim thisLaneId As Long
    prevLaneId = 0
    
    For Each oRecord In oRecords
        thisLaneId = oRecord.Value(fieldMappings(m_InformationTypeEnum.sbLaneTitle))
        If thisLaneId <> prevLaneId Then
            Set oLaneNode = oDataXml.selectSingleNode("/data/Lanes[@id=" & thisLaneId & "]")
        End If
        
        Call oLaneNode.appendChild(createCard(oDataXml, oRecord, fieldMappings))
        
        prevLaneId = thisLaneId
    Next oRecord
    
    Debug.Print oDataXml.XML
    getBoardXMLUsingVBA = oDataXml.XML

    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.getBoardXMLUsingVBA")
End Function


' ##SUMMARY Creates and returns an xml element representing a card in Sales Board.
Private Function createCard(ByRef oDataXml As MSXML2.DOMDocument60, ByRef oRecord As LDE.Record, ByRef fm As Scripting.Dictionary) As MSXML2.IXMLDOMElement
    On Error GoTo ErrorHandler
    
    Dim oCardElement As MSXML2.IXMLDOMElement
    Set oCardElement = oDataXml.createElement("Cards")
    
    ' ##TODO: Use date formats given (must add object in config for VBA date formats similar to "/board/card/additionalInfo/dateFormat/sqlFormatCode" And "/board/card/additionalInfo/dateFormat/length")
    
    Call oCardElement.SetAttribute("link", Lime.CreateURL(oRecord))
    
    Call setCardAttribute(oCardElement, "additionalInfo", oRecord, fm(m_InformationTypeEnum.sbCardAdditionalInfo))
    Call setCardAttribute(oCardElement, "completionRate", oRecord, fm(m_InformationTypeEnum.sbCardPercent))
    Call setCardAttribute(oCardElement, "owner", oRecord, fm(m_InformationTypeEnum.sbCardOwner))
    Call setCardAttribute(oCardElement, "sortValue", oRecord, fm(m_InformationTypeEnum.sbCardSorting))
    Call setCardAttribute(oCardElement, "sumValue", oRecord, fm(m_InformationTypeEnum.sbBoardSummation))
    Call setCardAttribute(oCardElement, "title", oRecord, fm(m_InformationTypeEnum.sbCardTitle))
    Call setCardAttribute(oCardElement, "value", oRecord, fm(m_InformationTypeEnum.sbCardValue))
    
    Set createCard = oCardElement
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.createCard")
End Function


' ##SUMMARY Sets the specified attribute on the card if not null
Private Sub setCardAttribute(ByRef oCardElement As MSXML2.IXMLDOMElement, attributeName As String, ByRef oRecord As LDE.Record, fieldName As String)
    On Error GoTo ErrorHandler

    If Not VBA.IsNull(oRecord(fieldName)) Then
        If isFieldTypeDate(oRecord.field(fieldName).Type) Then
            Call oCardElement.SetAttribute(attributeName, CStr(oRecord(fieldName)))
        Else
            Call oCardElement.SetAttribute(attributeName, oRecord(fieldName))
        End If
    End If

    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_Embrello.setCardAttribute")
End Sub


' ##SUMMARY Sets the specified attribute on the card if not null
Private Function isFieldTypeDate(ft As LDE.FieldTypeEnum)
    On Error GoTo ErrorHandler

    If ft = lkFieldTypeDate _
            Or ft = lkFieldTypeDateFourMonths _
            Or ft = lkFieldTypeDateMonth _
            Or ft = lkFieldTypeDateQuarter _
            Or ft = lkFieldTypeDateSixMonths _
            Or ft = lkFieldTypeDateTime _
            Or ft = lkFieldTypeDateTimeSeconds _
            Or ft = lkFieldTypeDateWeek _
            Or ft = lkFieldTypeDateYear Then
        isFieldTypeDate = True
    Else
        isFieldTypeDate = False
    End If
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.isFieldTypeDate")
End Function


' ##SUMMARY Sets the field mappings based on the app config for the board.
Private Function getFieldMappings(ByRef oBoardXmlDoc As MSXML2.DOMDocument60) As Scripting.Dictionary
    On Error GoTo ErrorHandler

    Dim fieldMappings As New Scripting.Dictionary
    fieldMappings.CompareMode = VBA.vbTextCompare
    
    Call addFieldMapping(fieldMappings, oBoardXmlDoc, m_InformationTypeEnum.sbLaneTitle, "/board/lanes/optionField")
    Call addFieldMapping(fieldMappings, oBoardXmlDoc, m_InformationTypeEnum.sbCardTitle, "/board/card/titleField")
    Call addFieldMapping(fieldMappings, oBoardXmlDoc, m_InformationTypeEnum.sbCardPercent, "/board/card/percentField")
    Call addFieldMapping(fieldMappings, oBoardXmlDoc, m_InformationTypeEnum.sbBoardSummation, "/board/summation/field")
    Call addFieldMapping(fieldMappings, oBoardXmlDoc, m_InformationTypeEnum.sbCardValue, "/board/card/value/field")
    Call addFieldMapping(fieldMappings, oBoardXmlDoc, m_InformationTypeEnum.sbCardSorting, "/board/card/sorting/field")
    Call addFieldMapping(fieldMappings, oBoardXmlDoc, m_InformationTypeEnum.sbCardOwner, "/board/card/owner/fieldName", "/board/card/owner/relatedTableFieldName")
    Call addFieldMapping(fieldMappings, oBoardXmlDoc, m_InformationTypeEnum.sbCardAdditionalInfo, "/board/card/additionalInfo/fieldName", "/board/card/additionalInfo/relatedTableFieldName")
    
    Set getFieldMappings = fieldMappings

    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.getFieldMappings")
End Function


' ##SUMMARY Adds a specific field mapping to the referenced dictionary.
Private Sub addFieldMapping(ByRef fm As Scripting.Dictionary, ByRef oBoardXmlDoc As MSXML2.DOMDocument60, key As m_InformationTypeEnum, xPathField As String, Optional xPathRelatedTableField As String = "")
    On Error GoTo ErrorHandler
    
    Dim oNodeField As MSXML2.IXMLDOMNode
    Set oNodeField = oBoardXmlDoc.selectSingleNode(xPathField)
    
    If Not oNodeField Is Nothing Then
        Dim fullFieldName As String
        fullFieldName = oNodeField.Text
        
        ' If a relation, then add the fieldname on the related table
        If xPathRelatedTableField <> "" Then
            Dim oNodeRelatedTableField As MSXML2.IXMLDOMNode
            Set oNodeRelatedTableField = oBoardXmlDoc.selectSingleNode(xPathRelatedTableField)
            If Not oNodeRelatedTableField Is Nothing Then
                fullFieldName = fullFieldName & "." & oNodeRelatedTableField.Text
            End If
        End If
        
        ' Add to dictionary
        Call fm.Add(key, fullFieldName)
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_Embrello.addFieldMapping")
End Sub

' ##SUMMARY Adds all necessary fields from the board config and returns a new view object.
Private Function createView(ByRef fm As Scripting.Dictionary) As LDE.View
    On Error GoTo ErrorHandler

    Dim oView As New LDE.View
    Call oView.Add(fm(m_InformationTypeEnum.sbLaneTitle), lkSortAscending)
    Call oView.Add(fm(m_InformationTypeEnum.sbCardTitle))
    Call oView.Add(fm(m_InformationTypeEnum.sbCardPercent))
    Call oView.Add(fm(m_InformationTypeEnum.sbBoardSummation))
    Call oView.Add(fm(m_InformationTypeEnum.sbCardValue))
    Call oView.Add(fm(m_InformationTypeEnum.sbCardSorting))
    Call oView.Add(fm(m_InformationTypeEnum.sbCardOwner))
    Call oView.Add(fm(m_InformationTypeEnum.sbCardAdditionalInfo))
    
    Set createView = oView
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.createView")
End Function


' ##SUMMARY Creates a filter that will receive the correct records for the app.
Public Function createFilter(ByRef oExplorer As Lime.Explorer, optionFieldName As String) As LDE.Filter
    On Error GoTo ErrorHandler
    
    Dim oFilter As New LDE.Filter
    
    Call oFilter.AddCondition("", lkOpIn, oExplorer.Records.Pool, lkConditionTypePool)
    
    ' Loop over options to make sure no inactive records are included
    Dim oOption As LDE.Option
    Dim oOptions As LDE.Options
    Set oOptions = Database.Classes(oExplorer.Class.Name).Fields(optionFieldName).Options
    
    Dim counter As Long
    counter = 0
    For Each oOption In oOptions
        counter = counter + 1
        Call oFilter.AddCondition(optionFieldName, lkOpEqual, oOption.Value)
        If counter > 1 Then
            Call oFilter.AddOperator(lkOpOr)
        End If
    Next oOption
    
    Call oFilter.AddOperator(lkOpAnd)
    
'    Dim oDlg As New Lime.Dialog
'    oDlg.Property("class") = Database.Classes("business")
'    oDlg.Property("filter") = oFilter
'    Call oDlg.show(lkDialogFilter)
    
    Set createFilter = oFilter
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.createFilter")
End Function


' ##SUMMARY Returns the name of the active explorer.
Public Function getActiveTable() As String
    On Error GoTo ErrorHandler
    
    If Not ActiveExplorer Is Nothing Then
        getActiveTable = ActiveExplorer.Class.Name
    Else
        getActiveTable = "Error!"
    End If
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.getActiveTable")
End Function


' ##SUMMARY Returns the local singular name of the active explorer.
Public Function getActiveTableLocalNameSingular() As String
    On Error GoTo ErrorHandler
    
    If Not ActiveExplorer Is Nothing Then
        getActiveTableLocalNameSingular = ActiveExplorer.Class.LocalName
    Else
        getActiveTableLocalNameSingular = "Error!"
    End If
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.getActiveTableLocalNameSingular")
End Function


' ##SUMMARY Returns the local plural name of the active explorer.
Public Function getActiveTableLocalNamePlural() As String
    On Error GoTo ErrorHandler
    
    If Not ActiveExplorer Is Nothing Then
        getActiveTableLocalNamePlural = ActiveExplorer.Class.Attributes("localnameplural")
    Else
        getActiveTableLocalNamePlural = "Error!"
    End If
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.getActiveTableLocalNamePlural")
End Function


' ##SUMMARY Returns an intuitive name for the board that is being shown.
Public Function getActiveBoardName() As String
    On Error GoTo ErrorHandler
    
    Dim boardName As String
    Dim excludeFilterList As String
    excludeFilterList = ";[Snabbsökning];[Quick Search];[Hurtigsøk];[Hurtigsøgning];[Pikahaku];"
    excludeFilterList = excludeFilterList & "[Alla];[All];[Alle];[Kaikki];"
    
    ' Set a nice default value
    boardName = "My board"
    
    Dim oExplorer As Lime.Explorer
    Set oExplorer = ActiveExplorer
    If Not oExplorer Is Nothing Then
        ' Set board name to the tab name as a starter
        boardName = oExplorer.Class.Attributes("localnameplural")
        
        ' Try to get name from filter if possible and relevant
        Dim f As LDE.Filter
        Set f = oExplorer.ActiveFilter
        If Not f Is Nothing Then
            If f.Type <> lkFilterTypeMyFilter _
                    And f.Type <> lkFilterTypeUnspecified Then
                If VBA.InStr(excludeFilterList, ";" & f.Name & ";") = 0 Then
                    boardName = f.Name
                End If
            End If
        End If
    End If
    
    getActiveBoardName = boardName
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.getActiveBoardName")
End Function

' ##SUMMARY Builds and returns string containing ids for all items in the active explorer.
Private Function getIdsAsString() As String
    On Error GoTo ErrorHandler
    
    Dim ids As String
    
    If Not ActiveExplorer Is Nothing Then
        Dim nbrOfRecords As Long
        If ActiveExplorer.Items.Count > m_maxNbrOfRecords Then
            nbrOfRecords = m_maxNbrOfRecords
        Else
            nbrOfRecords = ActiveExplorer.Items.Count
        End If
        Dim i As Long
        For i = 1 To nbrOfRecords
            ids = ids & VBA.CStr(ActiveExplorer.Items(i).ID) & ";"
        Next i
    End If
    
    getIdsAsString = ids
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.getIdsAsString")
End Function


' ##SUMMARY Called from Embrello to find out which language the client is using
Public Function getLocale() As String
    On Error GoTo ErrorHandler
'getLocale = "en-us"
'getLocale = "sv"
    If Application.Locale = "en_us" Then
        getLocale = "en-us"
    Else
        getLocale = Application.Locale
    End If

    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.getLocale")
End Function


' ##SUMMARY Called from Embrello to set the config value of the maximum number of records that should be fetched from the database.
Public Sub setDataSource(source As String)
    On Error GoTo ErrorHandler
    
    If source = "vba" Or source = "sql" Then
        m_dataSource = source
    Else
        m_dataSource = "vba"
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_Embrello.setMaxNbrOfRecords")
End Sub


' ##SUMMARY Called from Embrello to set the config value of the maximum number of records that should be fetched from the database.
Public Sub setMaxNbrOfRecords(val As Long)
    On Error GoTo ErrorHandler
    
    m_maxNbrOfRecords = val
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_Embrello.setMaxNbrOfRecords")
End Sub


' ##SUMMARY Called from Embrello. Returns true if either a fast filter or column filters are applied on the current Explorer list.
Public Function getListFiltered() As Boolean
    On Error GoTo ErrorHandler

    ' Set default value
    getListFiltered = False
    
    
    If Not ActiveExplorer Is Nothing Then
        ' Check if any column filter is used
        If Not ActiveExplorer.ActiveView Is Nothing Then
            Dim i As Long
            For i = 1 To ActiveExplorer.ActiveView.Count
                If ActiveExplorer.ColumnFilterIsActive(i) Then
                    getListFiltered = True
                    Exit For
                End If
            Next i
        End If
        
        ' Check if a fast filter is applied
        If Not getListFiltered Then
            getListFiltered = (ActiveExplorer.TextFilter <> "")
        End If
    End If
    Exit Function
ErrorHandler:
    getListFiltered = False
    Call UI.ShowError("App_Embrello.getListFiltered")
End Function




