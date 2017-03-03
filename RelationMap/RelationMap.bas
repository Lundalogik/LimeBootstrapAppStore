Attribute VB_Name = "RelationMap"
Option Explicit

' ### COWORKER MAP ###
Private Const COWORKER_PARENT_TAB As String = "reportingcoworkers"
Private Const DEFAULT_COWORKER As Long = 1001 ' E.g. RECORDID OF I.E. THE CEO
Private Const FIRST_NAME As String = "firstname"
Private Const LAST_NAME As String = "lastname"
Private Const REPORTS_TO As String = "reportsto"
Private Const OFFICE_NAME As String = "office.name"
Private Const COWORKER_GROUP_NAME As String = "coworkergroup.name"
Private Const EMPLOYMENT_DATE As String = "employmentdate"

' ### CORPORATE STRUCTURE ###
Private Const COMPANY_PARENT_TAB As String = "subsidiary"
Private Const DEFAULT_COMPANY As Long = 1001 ' E.g. RECORDID OF I.E. THE MAIN HOLDING COMPANY
Private Const COMPANY_NAME As String = "name"
Private Const REGISTRATION_NO As String = "registrationno"
Private Const PARENT_COMPANY As String = "parentcompany.name"
Private Const COUNTRY As String = "country"
Private Const CITY As String = "postalcity"

Dim iScreenHeight As Integer
Dim iScreenWidth As Integer
Dim sJsonCoworker As String
Dim sJsonCompany As String
Dim oCoworkerParentsRecords As LDE.Records
Dim oCompanyParentsRecords As LDE.Records
Dim oSelectedCoworkerTopNode As New LDE.Record
Dim oSelectedCompanyTopNode As New LDE.Record

' Function that the javascript of the app calls, to get data from Lime.
' The data is sent back as a hierarchical json string, with all the information about data and relations,
' that the app will display in an interactive tree map format.
' In the case that a solution has more than one relation map, there will be one function like this for each relation map.
' Name the function in the format: "GetJson" & relation architecture & "()". For example "GetJsonCoworker()".
' This is a template for coworkers. Adapt anything you want to use (if you need to), delete what you don't need, and add whatever extra data you want to display.
Public Function GetJsonCoworker() As String
    On Error GoTo ErrorHandler
    
    Dim oRecords As LDE.Records
    Dim oRecord As LDE.Record
    Dim oFilter As LDE.Filter
    Dim oCoworkerParentsFilter As LDE.Filter
    Dim oView As LDE.view
    Dim pClass As LDE.Class
    Dim sRecordType As String
    Dim sParentFieldName As String
    
    Set oRecords = New LDE.Records
    Set oRecord = New LDE.Record
    Set oFilter = New LDE.Filter
    Set oCoworkerParentsFilter = New LDE.Filter
    sRecordType = "coworker"
    sParentFieldName = GetParentFieldName(sRecordType)
    Set oView = GetView(sRecordType)
    
    Call oRecords.Open(Lime.Classes(sRecordType), oFilter, oView)
    
    ' Find all coworkers that have someone reporting to them and save them in a Records object.
    Call oCoworkerParentsFilter.AddCondition(COWORKER_PARENT_TAB & ".id" & sRecordType, lkOpGreater, 0)
    If oCoworkerParentsRecords Is Nothing Then
        Set pClass = Application.Classes.Lookup(lkClassLabelCoWorker, lkLookupClassByLabel)

        If Not pClass Is Nothing Then
            Set oCoworkerParentsRecords = Application.CreateObject("LDE.Records")
            Call oCoworkerParentsRecords.Open(pClass, oCoworkerParentsFilter, oView)
        End If
    End If
    
    ' Find the top node of the selected or default record, to build the correct tree.
    If oSelectedCoworkerTopNode.ID = 0 Then
        Call oFilter.AddCondition("id" & sRecordType, lkOpEqual, DEFAULT_COWORKER)
        Call oRecord.Open(Lime.Classes(sRecordType), oFilter, oView)
    Else
        Call oFilter.AddCondition("id" & sRecordType, lkOpEqual, oSelectedCoworkerTopNode.ID)
        Call oSelectedCoworkerTopNode.Open(Lime.Classes(sRecordType), oFilter, oView)
        Set oRecord = oSelectedCoworkerTopNode
    End If
    
    ' If the app is run for the first this Lime session, then the data that the app needs from the database will be loaded into a string in a hierarchical JSON format.
    ' If the app has already run, then the data has been cached.
    If sJsonCoworker = "" Then
        Call GenerateJsonCoworker(sJsonCoworker, oRecord, oView, sRecordType, sParentFieldName)
        sJsonCoworker = Left(sJsonCoworker, Len(sJsonCoworker) - 1)
    End If
    
    GetJsonCoworker = sJsonCoworker
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("RelationMap.GetJsonCoworker")
End Function

' Recursive json string creation function. One of these functions per GetJson function.
' Name the function bsed on the GetJson function, but switch Get with Generate, i.e.: "GenerateJsonCoworker".
' This is a template corresponding to the "GetJsonCoworker" function above. Adapt anything you want to use (if you need to),
' delete what you don't need, and add whatever extra data you want to display.
Private Function GenerateJsonCoworker(ByRef sJson As String, _
                                    oRecord As LDE.Record, _
                                    oView As LDE.view, _
                                    ByRef sRecordType As String, _
                                    ByRef sParentFieldName As String _
                                    ) As String
    On Error GoTo ErrorHandler

    Dim oRecords As LDE.Records
    Dim oRecordIsParent As LDE.Record
    Dim oFilter As LDE.Filter
    Dim oRecordChild As LDE.Record
    Dim sQuery As String
    
    Set oRecords = New LDE.Records
    Set oRecordIsParent = New LDE.Record
    Set oFilter = New LDE.Filter
    Set oRecordChild = New LDE.Record

    ' primaryText is the text that will be displayed on a node.
    ' secondaryText is the extra text that will be shown under nodes that have expanded children showing in the tree map.
    ' recordId is used when the SelectedRecordId function provides a different starting record than the default.
    ' tooltip is a string that will be rendered as html in a tooltip when you hover over the primary text of a node.
    sJson = sJson & "{" & _
        Chr(34) & "primaryText" & Chr(34) & ": " & Chr(34) & oRecord.Text(FIRST_NAME) & " " & oRecord.Text(LAST_NAME) & Chr(34) & "," & _
        Chr(34) & "secondaryText" & Chr(34) & ": " & Chr(34) & oRecord.Text(OFFICE_NAME) & Chr(34) & "," & _
        Chr(34) & "recordId" & Chr(34) & ": " & Chr(34) & CStr(oRecord.ID) & Chr(34) & "," & _
        Chr(34) & "tooltip" & Chr(34) & ": " & Chr(34) & _
        "Name: " & oRecord.Text(FIRST_NAME) & " " & oRecord.Text(LAST_NAME) & "<br/>" & _
        "Office: " & oRecord.Text(OFFICE_NAME) '& "<br/>"
'        "Coworker group: " & oRecord.Text(COWORKER_GROUP_NAME) & "<br/>" & _
'        "Employment date: " & oRecord.Text(EMPLOYMENT_DATE) & "<br/>"
'    If oRecord.Text("employmentdate") <> "" Then
'        sJson = sJson & "Days employed: " & YearsMonthsDays(oRecord.Value(EMPLOYMENT_DATE), VBA.Date)
'    Else
'        sJson = sJson & "Days employed:"
'    End If
    sJson = sJson & Chr(34) & ","

    ' Gets the child records of the current record.
    sQuery = "[id" & sRecordType & "] = " & oRecord.ID
    Set oRecordIsParent = oCoworkerParentsRecords.Find(sQuery)
    If Not oRecordIsParent Is Nothing Then
        Call oFilter.AddCondition(sParentFieldName, lkOpEqual, oRecord.ID)
        Call oRecords.Open(Lime.Classes(sRecordType), oFilter, oView)
    End If
    
    ' Recursive iteration over potential child records.
    If oRecords.Count > 0 Then
        sJson = sJson & Chr(34) & "children" & Chr(34) & ": ["
        For Each oRecordChild In oRecords
            If oRecordChild.ID <> oRecord.ID Then
                sJson = GenerateJsonCoworker(sJson, oRecordChild, oView, sRecordType, sParentFieldName)
            End If
        Next oRecordChild
        sJson = Left(sJson, Len(sJson) - 1)
        sJson = sJson & "]"
    Else
        sJson = Left(sJson, Len(sJson) - 1)
    End If
    sJson = sJson & "},"
    
    GenerateJsonCoworker = sJson

    Exit Function
ErrorHandler:
    Call UI.ShowError("RelationMap.GenerateJsonCoworker")
End Function

' Function that the javascript of the app calls, to get data from Lime.
' The data is sent back as a hierarchical json string, with all the information about data and relations,
' that the app will display in an interactive tree map format.
' In the case that a solution has more than one relation map, there will be one function like this for each relation map.
' Name the function in the format: "GetJson" & relation architecture & "()". For example "GetJsonCoworker()".
' This is a template for companies. Adapt anything you want to use (if you need to), delete what you don't need, and add whatever extra data you want to display.
Public Function GetJsonCompany() As String
    On Error GoTo ErrorHandler
    
    Dim oRecords As LDE.Records
    Dim oRecord As LDE.Record
    Dim oFilter As LDE.Filter
    Dim oCompanyParentsFilter As LDE.Filter
    Dim oView As LDE.view
    Dim pClass As LDE.Class
    Dim sRecordType As String
    Dim sParentFieldName As String
    
    Set oRecords = New LDE.Records
    Set oRecord = New LDE.Record
    Set oFilter = New LDE.Filter
    Set oCompanyParentsFilter = New LDE.Filter
    sRecordType = "company"
    sParentFieldName = GetParentFieldName(sRecordType)
    Set oView = GetView(sRecordType)
    
    Call oRecords.Open(Lime.Classes(sRecordType), oFilter, oView)
    
    
    ' Find all companies that have daughter companies and save them in a Records object.
    Call oCompanyParentsFilter.AddCondition(COMPANY_PARENT_TAB & ".id" & sRecordType, lkOpGreater, 0)
    If oCompanyParentsRecords Is Nothing Then
        Set pClass = Application.Classes.Lookup(lkClassLabelCompany, lkLookupClassByLabel)

        If Not pClass Is Nothing Then
            Set oCompanyParentsRecords = Application.CreateObject("LDE.Records")
            Call oCompanyParentsRecords.Open(pClass, oCompanyParentsFilter, oView)
        End If
    End If
    
    ' Find the top node of the selected or default record, to build the correct tree.
    If oSelectedCompanyTopNode.ID = 0 Then
        Call oFilter.AddCondition("id" & sRecordType, lkOpEqual, DEFAULT_COMPANY)
        Call oRecord.Open(Lime.Classes(sRecordType), oFilter, oView)
    Else
        Call oFilter.AddCondition("id" & sRecordType, lkOpEqual, oSelectedCompanyTopNode.ID)
        Call oSelectedCompanyTopNode.Open(Lime.Classes(sRecordType), oFilter, oView)
        Set oRecord = oSelectedCompanyTopNode
    End If
    
    ' If the app is run for the first this Lime session, then the data that the app needs from the database will be loaded into a string in a hierarchical JSON format.
    ' If the app has already run, then the data has been cached.
    If sJsonCompany = "" Then
        Call GenerateJsonCompany(sJsonCompany, oRecord, oView, sRecordType, sParentFieldName)
        sJsonCompany = Left(sJsonCompany, Len(sJsonCompany) - 1)
    End If
    
    GetJsonCompany = sJsonCompany
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("RelationMap.GetJsonCompany")
End Function

' Recursive json string creation function. One of these functions per GetJson function.
' Name the function bsed on the GetJson function, but switch Get with Generate, i.e.: "GenerateJsonCoworker".
' This is a template corresponding to the "GetJsonCompany" function above. Adapt anything you want to use (if you need to),
' delete what you don't need, and add whatever extra data you want to display.
Private Function GenerateJsonCompany(ByRef sJson As String, _
                                    oRecord As LDE.Record, _
                                    oView As LDE.view, _
                                    ByRef sRecordType As String, _
                                    ByRef sParentFieldName As String _
                                    ) As String
    On Error GoTo ErrorHandler

    Dim oRecords As LDE.Records
    Dim oRecordIsParent As LDE.Record
    Dim oFilter As LDE.Filter
    Dim oRecordChild As LDE.Record
    Dim sQuery As String
    
    Set oRecords = New LDE.Records
    Set oRecordIsParent = New LDE.Record
    Set oFilter = New LDE.Filter
    Set oRecordChild = New LDE.Record

    ' primaryText is the text that will be displayed on a node.
    ' secondaryText is the extra text that will be shown under nodes that have expanded children showing in the tree map.
    ' recordId is used when the SelectedRecordId function provides a different starting record than the default.
    ' tooltip is a string that will be rendered as html in a tooltip when you hover over the primary text of a node.
    sJson = sJson & "{" & _
        Chr(34) & "primaryText" & Chr(34) & ": " & Chr(34) & oRecord.Text(COMPANY_NAME) & Chr(34) & "," & _
        Chr(34) & "secondaryText" & Chr(34) & ": " & Chr(34) & oRecord.Text(COUNTRY) & Chr(34) & "," & _
        Chr(34) & "recordId" & Chr(34) & ": " & Chr(34) & CStr(oRecord.ID) & Chr(34) & "," & _
        Chr(34) & "tooltip" & Chr(34) & ": " & Chr(34) & _
        "Name: " & oRecord.Text("name") & "<br/>" & _
        "Registration number: " & oRecord.Text(REGISTRATION_NO) & "<br/>" & _
        "Parent company: " & oRecord.Text(PARENT_COMPANY) & "<br/>" & _
        "Country: " & oRecord.Text(COUNTRY) & "<br/>" & _
        "City: " & oRecord.Text(CITY) & "<br/>"
    sJson = sJson & Chr(34) & ","
    
    ' Gets the child records of the current record.
    sQuery = "[id" & sRecordType & "] = " & oRecord.ID
    Set oRecordIsParent = oCompanyParentsRecords.Find(sQuery)
    If Not oRecordIsParent Is Nothing Then
        Call oFilter.AddCondition(sParentFieldName, lkOpEqual, oRecord.ID)
        Call oRecords.Open(Lime.Classes(sRecordType), oFilter, oView)
    End If
    
    ' Recursive iteration over potential child records.
    If oRecords.Count > 0 Then
        sJson = sJson & Chr(34) & "children" & Chr(34) & ": ["
        For Each oRecordChild In oRecords
            If oRecordChild.ID <> oRecord.ID Then
                sJson = GenerateJsonCompany(sJson, oRecordChild, oView, sRecordType, sParentFieldName)
            End If
        Next oRecordChild
        sJson = Left(sJson, Len(sJson) - 1)
        sJson = sJson & "]"
    Else
        sJson = Left(sJson, Len(sJson) - 1)
    End If
    sJson = sJson & "},"
    
    GenerateJsonCompany = sJson

    Exit Function
ErrorHandler:
    Call UI.ShowError("RelationMap.GenerateJsonCompany")
End Function

' Opens the app in a new HTML window. When the actionpad with the link for initializing the app loaded,
' it got the screen size for the computer screen it was at, and stored it in iScreenHeight andiScreenWidth.
' The HTML window will be a little bit smaller than the height of the screen, to be able to make the html elements as large as possible.
Public Sub InitializeApp(ByRef htmlFileName As String)
    On Error GoTo ErrorHandler
    
    Dim oExplorer As Lime.Explorer
    Dim oSelectedRecord As LDE.Record
    Dim oSelectedTopNode As LDE.Record
    Dim oSelectedCoworkerTopNodeCopy As LDE.Record
    Dim oSelectedCompanyTopNodeCopy As LDE.Record
    Dim oFilter As LDE.Filter
    Dim oView As LDE.view
    Dim sRecordType As String
    
    Set oExplorer = ActiveExplorer
    Set oSelectedRecord = New LDE.Record
    Set oSelectedTopNode = New LDE.Record
    Set oFilter = New LDE.Filter
    Set oView = New LDE.view
    
    ' If you want the app to open from a selected record if possible, but otherwise open a specified default record,
    ' then make a corresponding check, as below, for every instance of the app that you would like to have this functionality.
    ' If the selected record belongs to a different tree than the last selected one, then the cached JSON string for this instantiation of the app is emptied.
    If htmlFileName = "relationMapCoworker" Then
        Set oSelectedCoworkerTopNodeCopy = oSelectedCoworkerTopNode
        Set oSelectedCoworkerTopNode = Nothing
        sRecordType = "coworker"
        Set oView = GetView(sRecordType)
        If Not oExplorer Is Nothing Then
            If oExplorer.Class.Name = sRecordType Then
                If oExplorer.Selection.Count = 1 Then
                    Call oFilter.AddCondition("id" & sRecordType, lkOpEqual, oExplorer.Selection(1).Record.ID)
                    Call oSelectedRecord.Open(Lime.Classes(sRecordType), oFilter, oView)
                    Set oSelectedTopNode = GetSelectedRecordTopNode(oSelectedRecord, oView, sRecordType, GetParentFieldName(sRecordType))
                    If oSelectedTopNode.ID <> oSelectedCoworkerTopNodeCopy.ID Then
                        sJsonCoworker = ""
                        Set oSelectedCoworkerTopNode = oSelectedTopNode
                    Else
                        Set oSelectedCoworkerTopNode = oSelectedCoworkerTopNodeCopy
                    End If
                End If
            End If
        End If
        ' The placement of this call decides if the app is opened when no record of the correct type is selected.
        Call OpenInHTMLWindow(htmlFileName)
    End If
    
    ' If you don't want the app to open unless the user has selected a record of the correct type in the list,
    ' then make a corresponding check, as below, for every instance of the app that you would like to have this restriction.
    ' If the selected record belongs to a different tree than the last selected one, then the cached JSON string for this instantiation of the app is emptied.
    If htmlFileName = "relationMapCompany" Then
        Set oSelectedCompanyTopNodeCopy = oSelectedCompanyTopNode
        Set oSelectedCompanyTopNode = Nothing
        sRecordType = "company"
        Set oView = GetView(sRecordType)
        If Not oExplorer Is Nothing Then
            If oExplorer.Class.Name = sRecordType Then
                If oExplorer.Selection.Count = 1 Then
                    Call oFilter.AddCondition("id" & sRecordType, lkOpEqual, oExplorer.Selection(1).Record.ID)
                    Call oSelectedRecord.Open(Lime.Classes(sRecordType), oFilter, oView)
                    Set oSelectedTopNode = GetSelectedRecordTopNode(oSelectedRecord, oView, sRecordType, GetParentFieldName(sRecordType))
                    If oSelectedTopNode.ID <> oSelectedCompanyTopNodeCopy.ID Then
                        sJsonCompany = ""
                        Set oSelectedCompanyTopNode = oSelectedTopNode
                    Else
                        Set oSelectedCompanyTopNode = oSelectedCompanyTopNodeCopy
                    End If
                    ' The placement of this call decides if the app is opened when no record of the correct type is selected.
                    Call OpenInHTMLWindow(htmlFileName)
                End If
            End If
        End If
    End If
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("RelationMap.InitializeApp")
End Sub

' Generates a view based on the information that is needed to find the records and generate the JSON that the app needs.
Private Function GetView(sRecordType As String) As LDE.view
    On Error GoTo ErrorHandler

    Dim oView As LDE.view
    Set oView = New LDE.view
    
    If sRecordType = "coworker" Then
    
        Call oView.Add(GetParentFieldName(sRecordType))
        Call oView.Add("id" & sRecordType)
        ' Add all data to the view that you will need to provide the app.
        Call oView.Add(FIRST_NAME)
        Call oView.Add(LAST_NAME)
        Call oView.Add(OFFICE_NAME)
        ' Call oView.Add(COWORKER_GROUP_NAME)
        ' Call oView.Add(EMPLOYMENT_DATE)
    
    ElseIf sRecordType = "company" Then
    
        Call oView.Add(GetParentFieldName(sRecordType))
        Call oView.Add("id" & sRecordType)
        ' Add all data to the view that you will need to provide the app.
        Call oView.Add(COMPANY_NAME)
        Call oView.Add(REGISTRATION_NO)
        Call oView.Add(PARENT_COMPANY)
        Call oView.Add(COUNTRY)
        Call oView.Add(CITY)
    
    End If

    Set GetView = oView
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("RelationMap.GetView")
End Function

' Returns the name of the relation field to the parent record.
Private Function GetParentFieldName(sRecordType As String) As String
    On Error GoTo ErrorHandler
    
    GetParentFieldName = ""

    If sRecordType = "coworker" Then
        GetParentFieldName = "reportsto"
    ElseIf sRecordType = "company" Then
        GetParentFieldName = "parentcompany"
    End If
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("RelationMap.GetParentFieldName")
End Function

' Opens the app in a new HTML window. When the actionpad with the link for initializing the app loaded,
' it got the screen size for the computer screen it was at, and stored it in iScreenHeight andiScreenWidth.
' The HTML window will be a little bit smaller than the height of the screen, to be able to make the html elements as large as possible.
Private Sub OpenInHTMLWindow(ByVal htmlFileName As String)
    On Error GoTo ErrorHandler
    
    Dim oDialog As New Lime.Dialog
    Dim oProc As New LDE.Procedure
  
    oDialog.Property("url") = ThisApplication.WebFolder & "lbs.html?ap=apps/RelationMap/" & htmlFileName & "&type=tab"
    oDialog.Property("height") = iScreenHeight - 35
    oDialog.Property("width") = iScreenHeight - 85
    oDialog.show lkDialogHTML
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("RelationMap.OpenInHTMLWindow")
End Sub

' Returns the Id of the selected record if it is of the provided record type.
' If the relation map is based on coworkers, and you want the tree to start centered on a selected record,
' then it will return the Id of the selected record, but only if it is a coworker.
' The app will then search for it among the records it loaded on startup, and if it is included there,
' it will start centered on it, otherwise it will start centered on the default record.
Public Function GetSelectedRecordId(ByVal sRecordType As String) As String
    On Error GoTo ErrorHandler

    GetSelectedRecordId = ""
    If Not ActiveExplorer Is Nothing Then
        If ActiveExplorer.Class.Name = sRecordType Then
            If ActiveExplorer.Selection.Count = 1 Then
                GetSelectedRecordId = CStr(ActiveExplorer.Selection(1).ID)
                Exit Function
            End If
        End If
    End If

    Exit Function
ErrorHandler:
    Call UI.ShowError("RelationMap.GetSelectedRecordId")
End Function

' Gets the top node in the tree of the selected record.
Private Function GetSelectedRecordTopNode(oRecord As LDE.Record, _
                                        oView As LDE.view, _
                                        ByRef sRecordType As String, _
                                        ByRef sParentFieldName As String _
                                        ) As LDE.Record
    On Error GoTo ErrorHandler

    Dim oRecordParent As LDE.Record
    Dim oFilter As LDE.Filter
    
    Set oRecordParent = New LDE.Record
    Set oFilter = New LDE.Filter
    
    If IsNull(oRecord.Value(sParentFieldName)) Then
        Set GetSelectedRecordTopNode = oRecord
    Else
        Call oFilter.AddCondition("id" & sRecordType, lkOpEqual, oRecord.Value(sParentFieldName))
        Call oRecordParent.Open(Lime.Classes(sRecordType), oFilter, oView)
        Set GetSelectedRecordTopNode = GetSelectedRecordTopNode(oRecordParent, oView, sRecordType, sParentFieldName)
    End If
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("RelationMap.GetSelectedRecordTopNode")
End Function

' Sets screen size variables when the app's actionpad is loaded.
' Called by the RelationMapHelper app.
Public Sub SetScreenSize(iHeight As Variant, iWidth As Variant)
    On Error Resume Next
    
    iScreenHeight = iHeight
    iScreenWidth = iWidth
    
    If Not IsNumeric(iScreenHeight) Then
        iScreenHeight = 768
    End If
    
    If Not IsNumeric(iScreenWidth) Then
        iScreenWidth = 1360
    End If

End Sub

' Creates and formats a string with information about how many years, months, and days there are between two dates.
Private Function YearsMonthsDays(Date1 As Date, _
                     Date2 As Date, _
                     Optional Grammar As Boolean = True _
                     ) As String
    On Error Resume Next
    
    Dim dTempDate As Date
    Dim iYears As Integer
    Dim iMonths As Integer
    Dim iDays As Integer
    Dim sYears As String
    Dim sMonths As String
    Dim sDays As String
    Dim sGrammar(-1 To 0) As String
    
    If Grammar = True Then
        sGrammar(0) = "s"
    End If
    
    
    If Date1 > Date2 Then
        dTempDate = Date1
        Date1 = Date2
        Date2 = dTempDate
    End If
    
    iYears = DateDiff("yyyy", Date1, Date2)
    Date1 = DateAdd("yyyy", iYears, Date1)
    If Date1 > Date2 Then
        iYears = iYears - 1
        Date1 = DateAdd("yyyy", -1, Date1)
    End If
    
    iMonths = DateDiff("M", Date1, Date2)
    Date1 = DateAdd("M", iMonths, Date1)
    If Date1 > Date2 Then
        iMonths = iMonths - 1
        Date1 = DateAdd("m", -1, Date1)
    End If
    
    iDays = DateDiff("d", Date1, Date2)
    
    If iYears > 0 Then
        sYears = iYears & " year" & sGrammar((iYears = 1)) & ", "
    End If
    If iYears > 0 Or iMonths > 0 Then
        sMonths = iMonths & " month" & sGrammar((iMonths = 1)) & ", "
    End If
    sDays = iDays & " day" & sGrammar((iDays = 1))
    
    YearsMonthsDays = sYears & sMonths & sDays
End Function

