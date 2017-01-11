Attribute VB_Name = "RelationMap"
Option Explicit

Dim iScreenHeight As Integer
Dim iScreenWidth As Integer
Dim sJsonCoworker As String
Dim sJsonCompany As String

' Function that the javascript of the app calls, to get data from Lime.
' The data is sent back as a hierarchical json string, with all the information about data and relations,
' that the app will display in an interactive tree map format.
' In the case that a solution has more than one relation map, there will be one function like this for each relation map.
' Name the function in the format: "GetJson" & relation architecture & "()". For example "GetJsonCoworker()".
' This is a template for coworkers. Adapt anything you want to use (if you need to), delete what you don't need, and add whatever extra data you want to display.
Public Function GetJsonCoworker() As String
    On Error GoTo ErrorHandler
    
    Dim oRecords As LDE.Records
    Dim oRecordDefault As LDE.Record
    Dim oFilter As LDE.filter
    Dim oView As LDE.view
    
    Set oRecords = New LDE.Records
    Set oRecordDefault = New LDE.Record
    Set oFilter = New LDE.filter
    Set oView = New LDE.view
    
    ' Add all data to the view that you will need to provide the app.
    Call oView.Add("firstname")
    Call oView.Add("lastname")
    Call oView.Add("reportsto")
    Call oView.Add("office.name")
    ' Call oView.Add("coworkergroup.name")
    ' Call oView.Add("employmentdate")
    Call oRecords.Open(Lime.Classes("coworker"), oFilter, oView)
    
    ' Add filter to find the default record to use as center of the tree map.
    Call oFilter.AddCondition("idcoworker", lkOpEqual, "RECORDID OF I.E. THE CEO")
    Call oRecordDefault.Open(Lime.Classes("coworker"), oFilter, oView)
    
    ' If the app is run for the first this Lime session, then the data that the app needs from the database will be loaded into a string in a hierarchical JSON format.
    ' If the app has already run, then the data has been cached.
    If sJsonCoworker = "" Then
        sJsonCoworker = GenerateJsonCoworker(sJsonCoworker, oRecordDefault, oView)
        sJsonCoworker = Left(sJsonCoworker, Len(sJsonCoworker) - 1)
    End If
    
    GetJsonCoworker = sJsonCoworker
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("RelationMap.GetJsonCoworker")
End Function

' Recursive json string creation function. One of these functions per GetJson function.
' Name the function bsed on the GetJson function, but switch Get with Generate, i.e.: "GenerateJsonCoworker".
' This is a template corresponding to the "GetJsonCoworker" function above. Adapt anything you want to use (if you need to), delete what you don't need, and add whatever extra data you want to display.
Private Function GenerateJsonCoworker(json As String, oRecord As LDE.Record, view As LDE.view) As String
    On Error GoTo ErrorHandler

    Dim oRecords As LDE.Records
    Dim oFilter As LDE.filter
    Dim oRecordChild As LDE.Record
    
    Set oRecords = New LDE.Records
    Set oFilter = New LDE.filter
    Set oRecordChild = New LDE.Record
    
    ' primaryText is the text that will be displayed on a node.
    ' secondaryText is the extra text that will be shown under nodes that have expanded children showing in the tree map.
    ' recordId is used when the SelectedRecordId function provides a different starting record than the default.
    ' tooltip is a string that will be rendered as html in a tooltip when you hover over the primary text of a node.
    json = json & "{" & _
        Chr(34) & "primaryText" & Chr(34) & ": " & Chr(34) & oRecord.Text("firstname") & " " & oRecord.Text("lastname") & Chr(34) & "," & _
        Chr(34) & "secondaryText" & Chr(34) & ": " & Chr(34) & oRecord.Text("office.name") & Chr(34) & "," & _
        Chr(34) & "recordId" & Chr(34) & ": " & Chr(34) & CStr(oRecord.ID) & Chr(34) & "," & _
        Chr(34) & "tooltip" & Chr(34) & ": " & Chr(34) & _
        "Name: " & oRecord.Text("firstname") & " " & oRecord.Text("lastname") & "<br/>" & _
        "Office: " & oRecord.Text("office.name") '& "<br/>"
'        "Coworker group: " & oRecord.Text("coworkergroup.name") & "<br/>" & _
'        "Employment date: " & oRecord.Text("employmentdate") & "<br/>"
'    If oRecord.Text("employmentdate") <> "" Then
'        json = json & "Days employed: " & YearsMonthsDays(oRecord.Value("employmentdate"), VBA.Date)
'    Else
'        json = json & "Days employed:"
'    End If
    json = json & Chr(34) & ","

    ' Gets the child records of the current record.
    Call oFilter.AddCondition("reportsto", lkOpEqual, oRecord.ID)
    Call oRecords.Open(Lime.Classes("coworker"), oFilter, view)
    
    ' Recursive iteration over potential child records.
    If oRecords.Count > 0 Then
        json = json & Chr(34) & "children" & Chr(34) & ": ["
        For Each oRecordChild In oRecords
            If oRecordChild.ID <> oRecord.ID Then
                json = GenerateJsonCoworker(json, oRecordChild, view)
            End If
        Next oRecordChild
        json = Left(json, Len(json) - 1)
        json = json & "]"
    Else
        json = Left(json, Len(json) - 1)
    End If
    json = json & "},"
    
    GenerateJsonCoworker = json

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
    Dim oRecordDefault As LDE.Record
    Dim oFilter As LDE.filter
    Dim oView As LDE.view
    
    Set oRecords = New LDE.Records
    Set oRecordDefault = New LDE.Record
    Set oFilter = New LDE.filter
    Set oView = New LDE.view
    
    ' Add all data to the view that you will need to provide the app.
    Call oView.Add("name")
    Call oView.Add("registrationno")
    Call oView.Add("parentcompany.name")
    Call oView.Add("country")
    Call oView.Add("postalcity")
    Call oRecords.Open(Lime.Classes("company"), oFilter, oView)
    
    ' Add filter to find the default record to use as center of the tree map.
    Call oFilter.AddCondition("idcompany", lkOpEqual, "RECORDID OF MAIN HOLDING COMPANY")
    Call oRecordDefault.Open(Lime.Classes("company"), oFilter, oView)
    
    ' If the app is run for the first this Lime session, then the data that the app needs from the database will be loaded into a string in a hierarchical JSON format.
    ' If the app has already run, then the data has been cached.
    If sJsonCompany = "" Then
        sJsonCompany = GenerateJsonCompany(sJsonCompany, oRecordDefault, oView)
        sJsonCompany = Left(sJsonCompany, Len(sJsonCompany) - 1)
    End If
    
    GetJsonCompany = sJsonCompany
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("RelationMap.GetJsonCompany")
End Function

' Recursive json string creation function. One of these functions per GetJson function.
' Name the function bsed on the GetJson function, but switch Get with Generate, i.e.: "GenerateJsonCoworker".
' This is a template corresponding to the "GetJsonCompany" function above. Adapt anything you want to use (if you need to), delete what you don't need, and add whatever extra data you want to display.
Private Function GenerateJsonCompany(json As String, oRecord As LDE.Record, view As LDE.view) As String
    On Error GoTo ErrorHandler

    Dim oRecords As LDE.Records
    Dim oFilter As LDE.filter
    Dim oRecordChild As LDE.Record
    
    Set oRecords = New LDE.Records
    Set oFilter = New LDE.filter
    Set oRecordChild = New LDE.Record
    
    ' primaryText is the text that will be displayed on a node.
    ' secondaryText is the extra text that will be shown under nodes that have expanded children showing in the tree map.
    ' recordId is used when the SelectedRecordId function provides a different starting record than the default.
    ' tooltip is a string that will be rendered as html in a tooltip when you hover over the primary text of a node.
    json = json & "{" & _
        Chr(34) & "primaryText" & Chr(34) & ": " & Chr(34) & oRecord.Text("name") & Chr(34) & "," & _
        Chr(34) & "secondaryText" & Chr(34) & ": " & Chr(34) & oRecord.Text("country") & Chr(34) & "," & _
        Chr(34) & "recordId" & Chr(34) & ": " & Chr(34) & CStr(oRecord.ID) & Chr(34) & "," & _
        Chr(34) & "tooltip" & Chr(34) & ": " & Chr(34) & _
        "Name: " & oRecord.Text("name") & "<br/>" & _
        "Registration number: " & oRecord.Text("registrationno") & "<br/>" & _
        "Parent company: " & oRecord.Text("parentcompany.name") & "<br/>" & _
        "Country: " & oRecord.Text("country") & "<br/>" & _
        "City: " & oRecord.Text("postalcity") & "<br/>"
    json = json & Chr(34) & ","
    
    ' Gets the child records of the current record.
    Call oFilter.AddCondition("parentcompany", lkOpEqual, oRecord.ID)
    Call oRecords.Open(Lime.Classes("company"), oFilter, view)
    
    ' Recursive iteration over potential child records.
    If oRecords.Count > 0 Then
        json = json & Chr(34) & "children" & Chr(34) & ": ["
        For Each oRecordChild In oRecords
            If oRecordChild.ID <> oRecord.ID Then
                json = GenerateJsonCompany(json, oRecordChild, view)
            End If
        Next oRecordChild
        json = Left(json, Len(json) - 1)
        json = json & "]"
    Else
        json = Left(json, Len(json) - 1)
    End If
    json = json & "},"
    
    GenerateJsonCompany = json

    Exit Function
ErrorHandler:
    Call UI.ShowError("RelationMap.GenerateJsonCompany")
End Function

' Opens the app in a new HTML window. When the actionpad with the link for initializing the app loaded,
' it got the screen size for the computer screen it was at, and stored it in iScreenHeight andiScreenWidth.
' The HTML window will be a little bit smaller than the height of the screen, to be able to make the html elements as large as possible.
Public Sub InitializeApp(ByVal htmlFileName As String)
    On Error GoTo ErrorHandler
    
    Dim oDialog As New Lime.Dialog
    Dim oProc As New LDE.Procedure

    oDialog.Property("url") = ThisApplication.WebFolder & "lbs.html?ap=apps/RelationMap/" & htmlFileName & "&type=tab"
    oDialog.Property("height") = iScreenHeight - 35
    oDialog.Property("width") = iScreenHeight - 85
    oDialog.show lkDialogHTML
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("RelationMap.InitializeApp")
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

