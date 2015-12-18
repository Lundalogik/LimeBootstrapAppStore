Attribute VB_Name = "app_Embrello"
Option Explicit

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


' ##SUMMARY Retrieves data for the board from the SQL database.
Public Function getBoardXML(boardConfigXML As String) As String
    On Error GoTo ErrorHandler
    
    ' Read board config from xml
    Dim oXmlDoc As New MSXML2.DOMDocument60
    Call oXmlDoc.loadXML(boardConfigXML)
    
    ' Call procedure to get board data
    Dim oProc As LDE.Procedure
    Set oProc = Database.Procedures("csp_embrello_getboard")
    oProc.Parameters("@@tablename").InputValue = ActiveExplorer.Class.Name
    
    Call addSQLParameterFromXML(oProc, "@@lanefieldname", oXmlDoc, "/board/laneOptionField")
    Call addSQLParameterFromXML(oProc, "@@titlefieldname", oXmlDoc, "/board/card/titleField")
    Call addSQLParameterFromXML(oProc, "@@additionalinfofieldname", oXmlDoc, "/board/card/additionalInfo/field")
    Call addSQLParameterFromXML(oProc, "@@completionfieldname", oXmlDoc, "/board/card/percentField")
    Call addSQLParameterFromXML(oProc, "@@valuefieldname", oXmlDoc, "/board/card/sumField")
    Call addSQLParameterFromXML(oProc, "@@sortfieldname", oXmlDoc, "/board/card/sorting/field")
    Call addSQLParameterFromXML(oProc, "@@ownerrelationfieldname", oXmlDoc, "/board/card/owner/fieldName")
    Call addSQLParameterFromXML(oProc, "@@ownerrelatedtablename", oXmlDoc, "/board/card/owner/relatedTableName")
    Call addSQLParameterFromXML(oProc, "@@ownerdescriptivefieldname", oXmlDoc, "/board/card/owner/relatedTableFieldName")
    
    oProc.Parameters("@@idrecords").InputValue = getIdsAsString()
    oProc.Parameters("@@lang").InputValue = Application.Locale
    oProc.Parameters("@@limeservername").InputValue = Database.RemoteServerName
    oProc.Parameters("@@limedbname").InputValue = Database.Name
    
    Call oProc.Execute(False)
    'Debug.Print oProc.result
    getBoardXML = oProc.result
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.getBoardXML")
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
    Call UI.ShowError("App_Embrello.getActiveBoardName")
End Function

' ##SUMMARY Builds and returns string containing ids for all items in the active explorer.
Private Function getIdsAsString() As String
    On Error GoTo ErrorHandler
    
    Dim ids As String
    
    If Not ActiveExplorer Is Nothing Then
        Dim item As Lime.ExplorerItem
        For Each item In ActiveExplorer.Items
            ids = ids & VBA.CStr(item.ID) & ";"
        Next item
    End If
    
    getIdsAsString = ids
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.getIdsAsString")
End Function


' ##SUMMARY Called by app. Returns the local field name of the field used as a sum field.
Public Function getSumLocalFieldName(tableName As String, sumFieldName As String) As String
    On Error GoTo ErrorHandler
    
    Dim retString As String
    retString = ""
    If Database.Classes.Exists(tableName) Then
        If Database.Classes(tableName).Fields.Exists(sumFieldName) Then
            retString = Database.Classes(tableName).Fields(sumFieldName).LocalName
        End If
    End If
    
    getSumLocalFieldName = retString
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("App_Embrello.getSumLocalFieldName")
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


