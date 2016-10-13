Attribute VB_Name = "App_LimeCRMSalesBoard"
Option Explicit

' Is set in sub setMaxNbrOfRecords.
Private m_maxNbrOfRecords As Long

' ##SUMMARY Opens Lime CRM Sales Board in a pane
Public Sub openLimeCRMSalesBoard()
    On Error GoTo ErrorHandler
    
    Dim url As String
    Dim p As Lime.Pane
    
    url = Application.WebFolder & "lbs.html?ap=apps/LimeCRMSalesBoard/LimeCRMSalesBoard&type=inline"
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


' ##SUMMARY Retrieves data for the board from the SQL database.
Public Function getBoardXML(boardConfigXML As String) As String
    On Error GoTo ErrorHandler
    
    ' Read board config from xml
    Dim oXmlDoc As New MSXML2.DOMDocument60
    Call oXmlDoc.loadXML(boardConfigXML)
    
    ' Call procedure to get board data
    Dim oProc As LDE.Procedure
    Set oProc = Database.Procedures("csp_limecrmsalesboard_getboard")
    oProc.Parameters("@@tablename").InputValue = ActiveExplorer.Class.Name

    Call addSQLParameterFromXML(oProc, "@@lanefieldname", oXmlDoc, "/board/lanes/optionField")
    Call addSQLParameterFromXML(oProc, "@@titlefieldname", oXmlDoc, "/board/card/titleField")
    Call addSQLParameterFromXML(oProc, "@@completionfieldname", oXmlDoc, "/board/card/percentField")
    Call addSQLParameterFromXML(oProc, "@@sumfieldname", oXmlDoc, "/board/summation/field")
    Call addSQLParameterFromXML(oProc, "@@valuefieldname", oXmlDoc, "/board/card/value/field")
    Call addSQLParameterFromXML(oProc, "@@sortfieldname", oXmlDoc, "/board/card/sorting/field")
    Call addSQLParameterFromXML(oProc, "@@ownerfieldname", oXmlDoc, "/board/card/owner/fieldName")
    Call addSQLParameterFromXML(oProc, "@@ownerrelatedtablename", oXmlDoc, "/board/card/owner/relatedTableName")
    Call addSQLParameterFromXML(oProc, "@@ownerdescriptivefieldname", oXmlDoc, "/board/card/owner/relatedTableFieldName")
    Call addSQLParameterFromXML(oProc, "@@additionalinfofieldname", oXmlDoc, "/board/card/additionalInfo/fieldName")
    Call addSQLParameterFromXML(oProc, "@@additionalinforelatedtablename", oXmlDoc, "/board/card/additionalInfo/relatedTableName")
    Call addSQLParameterFromXML(oProc, "@@additionalinfodescriptivefieldname", oXmlDoc, "/board/card/additionalInfo/relatedTableFieldName")
    Call addSQLParameterFromXML(oProc, "@@additionalinfodateformat", oXmlDoc, "/board/card/additionalInfo/dateFormat/sqlFormatCode")
    Call addSQLParameterFromXML(oProc, "@@additionalinfodatelength", oXmlDoc, "/board/card/additionalInfo/dateFormat/length")
    
    oProc.Parameters("@@idrecords").InputValue = getIdsAsString()
    oProc.Parameters("@@lang").InputValue = Application.Locale
    oProc.Parameters("@@limeservername").InputValue = Database.RemoteServerName
    oProc.Parameters("@@limedbname").InputValue = Database.Name
    oProc.Parameters("@@iduser").InputValue = ActiveUser.ID

    Call oProc.Execute(False)
    'Debug.Print oProc.result
    getBoardXML = oProc.result

'Dim strFilename As String: strFilename = "D:\temp\LimeCRMSalesBoardExamplexml.txt"
'Dim strFileContent As String
'Dim iFile As Integer: iFile = FreeFile
'Open strFilename For Input As #iFile
'strFileContent = Input(LOF(iFile), iFile)
'Close #iFile
'Debug.Print strFileContent
'    getBoardXML = strFileContent
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.getBoardXML")
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
    Call UI.ShowError("App_LimeCRMSalesBoard.addSQLParameterFromXML")
End Sub

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
    Call UI.ShowError("App_LimeCRMSalesBoard.getActiveTable")
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
    Call UI.ShowError("App_LimeCRMSalesBoard.getActiveTableLocalNameSingular")
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
    
    If Not ActiveExplorer Is Nothing Then
        ' Set board name to the tab name as a starter
        boardName = ActiveExplorer.Class.Attributes("localnameplural")
        
        ' Try to get name from filter if possible and relevant
        Dim f As LDE.Filter
        Set f = ActiveExplorer.ActiveFilter
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
    Call UI.ShowError("App_LimeCRMSalesBoard.getIdsAsString")
End Function


' ##SUMMARY Called from Lime CRM Sales Board to find out which language the client is using
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


' ##SUMMARY Called from Lime CRM Sales Board to set the config value of the maximum number of records that should be fetched from the database.
Public Sub setMaxNbrOfRecords(val As Long)
    On Error GoTo ErrorHandler
    
    m_maxNbrOfRecords = val
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("App_LimeCRMSalesBoard.setMaxNbrOfRecords")
End Sub


' ##SUMMARY Called from Lime CRM Sales Board. Returns true if either a fast filter or column filters are applied on the current Explorer list.
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
    Call UI.ShowError("App_LimeCRMSalesBoard.getListFiltered")
End Function

