Attribute VB_Name = "App_LimeCRMSalesBoard"
Option Explicit

' Is set in sub setDataSource
Private m_dataSource As String

' Is set in sub setMaxNbrOfRecords.
Private m_maxNbrOfRecords As Long

' Is set in function getActiveTable.
Private m_explorer As Lime.Explorer

' Are set in sub setIgnoreOptionsLists
Private m_ignoreOptionsKeys As String
Private m_ignoreOptionsIds As String


' Used in field mappings dictionary to keep track of field names
Private Enum m_InformationTypeEnum
    sbBoardSummation = 1
    sbLaneTitle = 2
    sbCardTitle = 3
    sbCardPercent = 4
    sbCardValue = 5
    sbCardIcon = 6
    sbCardSorting = 7
    sbCardOwner = 8
    sbCardAdditionalInfo = 9
End Enum

' ##SUMMARY Opens LimeCRMSalesBoard in a pane
Public Sub openLimeCRMSalesBoard()
    On Error GoTo ErrorHandler
    
    Dim url As String
    Dim p As Lime.Pane
    
    url = Application.WebFolder & "lbs.html?ap=apps/LimeCRMSalesBoard/views/LimeCRMSalesBoard&type=inline"
    If Application.Panes.Exists("Lime CRM Sales Board") Then
        Set p = Application.Panes("Lime CRM Sales Board")
    End If
    If Not p Is Nothing Then
        p.url = url
    Else
        Set p = Application.Panes.Add("Lime CRM Sales Board", , url, lkPaneStyleNoToolBar + lkPaneStylePersistentURL + lkPaneStyleRestrictedBrowsing)
    End If
    Set Application.Panes.ActivePane = p
    Application.Panes.Visible = True
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.openLimeCRMSalesBoard")
End Sub


' ##SUMMARY Called from the app. Returns an xml with data for the board.
Public Function getBoardXML(boardConfigXML As String) As String
    On Error GoTo ErrorHandler
    
    'Debug.Print boardConfigXML
    
    ' Read board config from xml
    Dim oBoardXmlDoc As New MSXML2.DOMDocument60
    Call oBoardXmlDoc.loadXML(boardConfigXML)
    
    ' Set ignore options lists
    Call setIgnoreOptionsLists(oBoardXmlDoc)
    
    ' Use either VBA or SQL procedure. Determined in the app config
    If m_dataSource = "vba" Then
        getBoardXML = getBoardXMLUsingVBA(oBoardXmlDoc)
    ElseIf m_dataSource = "sql" Then
        getBoardXML = getBoardXMLUsingSQL(oBoardXmlDoc)
    End If
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.getBoardXML")
End Function

' ##SUMMARY Retrieves the board xml using a SQL stored procedure to fetch data from the database.
Private Function getBoardXMLUsingSQL(ByRef oBoardXmlDoc As MSXML2.DOMDocument60) As String
    On Error GoTo ErrorHandler
    
    'Debug.Print "sql"
    
    ' Call procedure to get board data
    Dim oProc As LDE.Procedure
    Set oProc = Database.Procedures("csp_limecrmsalesboard_getboard")
    oProc.Parameters("@@tablename").InputValue = m_explorer.Class.Name

    Call addSQLParameterFromXML(oProc, "@@lanefieldname", oBoardXmlDoc, "/board/lanes/optionField")
    Call addSQLParameterFromXML(oProc, "@@laneoptionsignorekeys", oBoardXmlDoc, "/board/lanes/ignoreOptions/keys")
    Call addSQLParameterFromXML(oProc, "@@laneoptionsignoreids", oBoardXmlDoc, "/board/lanes/ignoreOptions/ids")
    Call addSQLParameterFromXML(oProc, "@@titlefieldname", oBoardXmlDoc, "/board/card/titleField")
    Call addSQLParameterFromXML(oProc, "@@completionfieldname", oBoardXmlDoc, "/board/card/percentField")
    Call addSQLParameterFromXML(oProc, "@@sumfieldname", oBoardXmlDoc, "/board/summation/field")
    Call addSQLParameterFromXML(oProc, "@@valuefieldname", oBoardXmlDoc, "/board/card/value/field")
    Call addSQLParameterFromXML(oProc, "@@iconfieldname", oBoardXmlDoc, "/board/lanes/defaultValues/cardIconField")
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
    'Debug.Print oProc.result
    getBoardXMLUsingSQL = oProc.result

'Dim strFilename As String: strFilename = "D:\temp\LimeCRMSalesBoardexamplexml.txt"
'Dim strFileContent As String
'Dim iFile As Integer: iFile = FreeFile
'Open strFilename For Input As #iFile
'strFileContent = Input(LOF(iFile), iFile)
'Close #iFile
'Debug.Print strFileContent
'    getBoardXML = strFileContent
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.getBoardXMLUsingSQL")
End Function


' ##SUMMARY Adds the specified SQL parameter to the specified procedure object with an input value set to
' the text of the specified xPath.
Private Sub addSQLParameterFromXML(ByRef oProc As LDE.Procedure, parameterName As String _
                                    , ByRef oXmlDoc As MSXML2.DOMDocument60, xPath As String)
    On Error GoTo ErrorHandler
    
    Dim oNode As MSXML2.IXMLDOMNode
    Set oNode = oXmlDoc.selectSingleNode(xPath)
    If Not oNode Is Nothing Then
        oProc.Parameters(parameterName).InputValue = oNode.text
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.addSQLParameterFromXML")
End Sub


' ##SUMMARY Retrieves the board xml using VBA code to fetch data from the database.
Private Function getBoardXMLUsingVBA(ByRef oBoardXmlDoc As MSXML2.DOMDocument60) As String
    On Error GoTo ErrorHandler
    
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
    
    For Each oOption In Database.Classes(m_explorer.Class.Name).Fields(fieldMappings(m_InformationTypeEnum.sbLaneTitle)).Options
        If isValidOption(oOption) Then           ' Check that it is not an ignored option
            Set oLaneElement = oDataXml.createElement("Lanes")
            Call oLaneElement.SetAttribute("id", oOption.Value)
            Call oLaneElement.SetAttribute("key", oOption.key)
            Call oLaneElement.SetAttribute("name", oOption.text)
            Call oLaneElement.SetAttribute("order", oOption.Attributes("stringorder"))
            Call rootNode.appendChild(oLaneElement)
        End If
    Next oOption
    
    ' Get records
    Dim oRecords As New LDE.Records
    Call oRecords.Open(Database.Classes(m_explorer.Class.Name) _
                        , createFilter(fieldMappings(m_InformationTypeEnum.sbLaneTitle)) _
                        , createView(fieldMappings) _
                        , m_maxNbrOfRecords)
    
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
    
    getBoardXMLUsingVBA = oDataXml.XML
Debug.Print getBoardXMLUsingVBA
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.getBoardXMLUsingVBA")
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
    Call setCardAttribute(oCardElement, "icon", oRecord, fm(m_InformationTypeEnum.sbCardIcon))
    
    Set createCard = oCardElement
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.createCard")
End Function


' ##SUMMARY Sets the specified attribute on the card if not null
Private Sub setCardAttribute(ByRef oCardElement As MSXML2.IXMLDOMElement, attributeName As String, ByRef oRecord As LDE.Record, fieldName As String)
    On Error GoTo ErrorHandler

    If fieldName <> "" Then
        If Not VBA.IsNull(oRecord(fieldName)) Then
            If isFieldTypeDate(oRecord.field(fieldName).Type) Then
                Call oCardElement.SetAttribute(attributeName, CStr(oRecord(fieldName)))
            ElseIf isFieldTypeDecimal(oRecord.field(fieldName).Type) Then
                Call oCardElement.SetAttribute(attributeName, VBA.Replace(oRecord(fieldName), ",", "."))
            Else
                Call oCardElement.SetAttribute(attributeName, VBA.Replace(oRecord(fieldName), """", "\"""))
            End If
        End If
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.setCardAttribute")
End Sub


' ##SUMMARY Returns true if it is any kind of field containing a date or time.
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
            Or ft = lkFieldTypeDateYear _
            Or ft = lkFieldTypeTime _
            Or ft = lkFieldTypeTimeStamp Then
        isFieldTypeDate = True
    Else
        isFieldTypeDate = False
    End If
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.isFieldTypeDate")
End Function


' ##SUMMARY Returns true if it is any kind of field containing a decimal value
Private Function isFieldTypeDecimal(ft As LDE.FieldTypeEnum)
    On Error GoTo ErrorHandler

    If ft = lkFieldTypeDecimal _
            Or ft = lkFieldTypePercent _
            Or ft = lkFieldTypeCurrency Then
        isFieldTypeDecimal = True
    Else
        isFieldTypeDecimal = False
    End If
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.isFieldTypeDecimal")
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
    Call addFieldMapping(fieldMappings, oBoardXmlDoc, m_InformationTypeEnum.sbCardIcon, "/board/lanes/defaultValues/cardIconField")
    Call addFieldMapping(fieldMappings, oBoardXmlDoc, m_InformationTypeEnum.sbCardSorting, "/board/card/sorting/field")
    Call addFieldMapping(fieldMappings, oBoardXmlDoc, m_InformationTypeEnum.sbCardOwner, "/board/card/owner/fieldName", "/board/card/owner/relatedTableFieldName")
    Call addFieldMapping(fieldMappings, oBoardXmlDoc, m_InformationTypeEnum.sbCardAdditionalInfo, "/board/card/additionalInfo/fieldName", "/board/card/additionalInfo/relatedTableFieldName")
    
    Set getFieldMappings = fieldMappings

    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.getFieldMappings")
End Function


' ##SUMMARY Adds a specific field mapping to the referenced dictionary.
Private Sub addFieldMapping(ByRef fm As Scripting.Dictionary, ByRef oBoardXmlDoc As MSXML2.DOMDocument60, key As m_InformationTypeEnum, xPathField As String, Optional xPathRelatedTableField As String = "")
    On Error GoTo ErrorHandler
    
    Dim oNodeField As MSXML2.IXMLDOMNode
    Set oNodeField = oBoardXmlDoc.selectSingleNode(xPathField)
    
    If Not oNodeField Is Nothing Then
        Dim fullFieldName As String
        fullFieldName = oNodeField.text
        
        ' If a relation, then add the fieldname on the related table
        If xPathRelatedTableField <> "" Then
            Dim oNodeRelatedTableField As MSXML2.IXMLDOMNode
            Set oNodeRelatedTableField = oBoardXmlDoc.selectSingleNode(xPathRelatedTableField)
            If Not oNodeRelatedTableField Is Nothing Then
                fullFieldName = fullFieldName & "." & oNodeRelatedTableField.text
            End If
        End If
        
        ' Add to dictionary
        Call fm.Add(key, fullFieldName)
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.addFieldMapping")
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
    Call oView.Add(fm(m_InformationTypeEnum.sbCardIcon))
    Call oView.Add(fm(m_InformationTypeEnum.sbCardSorting))
    Call oView.Add(fm(m_InformationTypeEnum.sbCardOwner))
    Call oView.Add(fm(m_InformationTypeEnum.sbCardAdditionalInfo))
    
    Set createView = oView
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.createView")
End Function


' ##SUMMARY Creates a filter that will extract the correct records for the app.
Public Function createFilter(optionFieldName As String) As LDE.Filter
    On Error GoTo ErrorHandler
    
    Dim oFilter As New LDE.Filter
    
    Call oFilter.AddCondition("", lkOpIn, m_explorer.Items.Pool, lkConditionTypePool)
    
    ' Loop over options to make sure no records with inactive options or explicitly ignored options (in app config) are included
    Dim oOption As LDE.Option
    Dim oOptions As LDE.Options
    Set oOptions = Database.Classes(m_explorer.Class.Name).Fields(optionFieldName).Options
    
    Dim counter As Long
    counter = 0
    For Each oOption In oOptions
        If isValidOption(oOption) Then
            counter = counter + 1
            Call oFilter.AddCondition(optionFieldName, lkOpEqual, oOption.Value)
            If counter > 1 Then
                Call oFilter.AddOperator(lkOpOr)
            End If
        End If
    Next oOption
    
    Call oFilter.AddOperator(lkOpAnd)
    
'    Dim oDlg As New Lime.Dialog
'    oDlg.Property("class") = Database.Classes("deal")
'    oDlg.Property("filter") = oFilter
'    Call oDlg.show(lkDialogFilter)
    
    Set createFilter = oFilter
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.createFilter")
End Function


' ##SUMMARY Returns the name of the active explorer.
Public Function getActiveTable() As String
    On Error GoTo ErrorHandler
    
    ' Cache the ActiveExplorer
    Set m_explorer = ActiveExplorer
    
    If Not m_explorer Is Nothing Then
        getActiveTable = m_explorer.Class.Name
    Else
        getActiveTable = "Error!"
    End If
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.getActiveTable")
End Function


' ##SUMMARY Returns the local singular name of the active explorer.
Public Function getActiveTableLocalNameSingular() As String
    On Error GoTo ErrorHandler
    
    If Not m_explorer Is Nothing Then
        getActiveTableLocalNameSingular = m_explorer.Class.LocalName
    Else
        getActiveTableLocalNameSingular = "Error!"
    End If
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.getActiveTableLocalNameSingular")
End Function


' ##SUMMARY Returns the local plural name of the active explorer.
Public Function getActiveTableLocalNamePlural() As String
    On Error GoTo ErrorHandler
    
    If Not m_explorer Is Nothing Then
        getActiveTableLocalNamePlural = m_explorer.Class.Attributes("localnameplural")
    Else
        getActiveTableLocalNamePlural = "Error!"
    End If
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.getActiveTableLocalNamePlural")
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
    
    If Not m_explorer Is Nothing Then
        ' Set board name to the tab name as a starter
        boardName = m_explorer.Class.Attributes("localnameplural")
        
        ' Try to get name from filter if possible and relevant
        Dim f As LDE.Filter
        Set f = m_explorer.ActiveFilter
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
    Call UI.ShowError("App_LimeCRMSalesBoard.getActiveBoardName")
End Function

' ##SUMMARY Builds and returns string containing ids for all items in the active explorer.
Private Function getIdsAsString() As String
    On Error GoTo ErrorHandler
    
    Dim ids As String
    
    If Not m_explorer Is Nothing Then
        Dim nbrOfRecords As Long
        If m_explorer.Items.Count > m_maxNbrOfRecords Then
            nbrOfRecords = m_maxNbrOfRecords
        Else
            nbrOfRecords = m_explorer.Items.Count
        End If
        Dim i As Long
        For i = 1 To nbrOfRecords
            ids = ids & VBA.CStr(m_explorer.Items(i).ID) & ";"
        Next i
    End If
    
    getIdsAsString = ids
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.getIdsAsString")
End Function


' ##SUMMARY Called from LimeCRMSalesBoard to find out which language the client is using
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
    Call UI.ShowError("App_LimeCRMSalesBoard.getLocale")
End Function


' ##SUMMARY Called from LimeCRMSalesBoard to set the config value of the maximum number of records that should be fetched from the database.
Public Sub setDataSource(source As String)
    On Error GoTo ErrorHandler
    
    If source = "vba" Or source = "sql" Then
        m_dataSource = source
    Else
        m_dataSource = "vba"
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.setDataSource")
End Sub


' ##SUMMARY Called from LimeCRMSalesBoard to set the config value of the maximum number of records that should be fetched from the database.
Public Sub setMaxNbrOfRecords(val As Long)
    On Error GoTo ErrorHandler
    
    m_maxNbrOfRecords = val
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.setMaxNbrOfRecords")
End Sub


' ##SUMMARY Called from LimeCRMSalesBoard. Returns a string describing which type of value the sorting algorithm should treat the sorting values as.
Public Function getSortFieldType(tableName As String, fieldName As String) As String
    On Error GoTo ErrorHandler

    If Database.Classes(tableName).Fields.Exists(fieldName) Then
        If isFieldTypeDate(Database.Classes(tableName).Fields(fieldName).Type) Then
            getSortFieldType = "string"
        Else
            Select Case Database.Classes(tableName).Fields(fieldName).Type
                Case lkFieldTypeDecimal, lkFieldTypeInteger, lkFieldTypeYesNo:
                    getSortFieldType = "float"
                Case Else:
                    getSortFieldType = "string"
            End Select
        End If
    Else
        getSortFieldType = "string"
    End If

    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.getSortFieldType")
End Function


' ##SUMMARY Called from LimeCRMSalesBoard. Returns true if either a fast filter or column filters are applied on the current Explorer list.
Public Function getListFiltered() As Boolean
    On Error GoTo ErrorHandler

    ' Set default value
    getListFiltered = False
    
    If Not m_explorer Is Nothing Then
        ' Check if any column filter is used
        If Not m_explorer.ActiveView Is Nothing Then
            Dim i As Long
            For i = 1 To m_explorer.ActiveView.Count
                If m_explorer.ColumnFilterIsActive(i) Then
                    getListFiltered = True
                    Exit For
                End If
            Next i
        End If
        
        ' Check if a fast filter is applied
        If Not getListFiltered Then
            getListFiltered = (m_explorer.TextFilter <> "")
        End If
    End If
    Exit Function
ErrorHandler:
    getListFiltered = False
    Call UI.ShowError("App_LimeCRMSalesBoard.getListFiltered")
End Function


' ##SUMMARY Initiates the global variables holding the possible ignore options lists (one for keys and one for idstrings).
' If there is a list specified for keys, then the ids are ignored.
Private Sub setIgnoreOptionsLists(ByRef oBoardXmlDoc As MSXML2.DOMDocument60)
    On Error GoTo ErrorHandler
    
    ' Set default as empty
    m_ignoreOptionsKeys = ""
    m_ignoreOptionsIds = ""

    ' Get possible list of options to ignore
    If Not oBoardXmlDoc.selectSingleNode("/board/lanes/ignoreOptions/keys") Is Nothing Then
        m_ignoreOptionsKeys = oBoardXmlDoc.selectSingleNode("/board/lanes/ignoreOptions/keys").text
    ElseIf Not oBoardXmlDoc.selectSingleNode("/board/lanes/ignoreOptions/ids") Is Nothing Then
        m_ignoreOptionsIds = oBoardXmlDoc.selectSingleNode("/board/lanes/ignoreOptions/ids").text
    End If

    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.setIgnoreOptionsLists")
End Sub


' ##SUMMARY Returns true if the specifed option is a valid option for the Lanes to use.
Private Function isValidOption(ByRef oOption As LDE.Option) As Boolean
    On Error GoTo ErrorHandler

    isValidOption = True
    If m_ignoreOptionsKeys <> "" Then
        isValidOption = (VBA.InStr(m_ignoreOptionsKeys, ";" & oOption.key & ";") = 0)
    ElseIf m_ignoreOptionsIds <> "" Then
        isValidOption = (VBA.InStr(m_ignoreOptionsIds, ";" & VBA.CStr(oOption.Value) & ";") = 0)
    End If

    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.isValidOption")
End Function


