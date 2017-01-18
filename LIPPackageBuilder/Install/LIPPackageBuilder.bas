Attribute VB_Name = "LIPPackageBuilder"
Option Explicit

Private m_TemporaryFolder As String

Public Sub OpenPackageBuilder()
    On Error GoTo ErrorHandler
    Dim oDialog As New Lime.Dialog
    Dim idpersons As String
    Dim oItem As Lime.ExplorerItem
    oDialog.Type = lkDialogHTML
    oDialog.Property("url") = Application.WebFolder & "lbs.html?ap=apps/LIPPackageBuilder/packagebuilder&type=tab"
    oDialog.Property("height") = 900
    oDialog.Property("width") = 1600
    oDialog.show

    Exit Sub
ErrorHandler:
    Call UI.ShowError("Globals.OpenPackageBuilder")
End Sub

Public Function LoadDataStructure(strProcedureName As String) As String
On Error GoTo ErrorHandler
    Dim oProcedure As LDE.Procedure
    Dim sXml As String
    Set oProcedure = Database.Procedures.Lookup(strProcedureName, lkLookupProcedureByName)
    If Not oProcedure Is Nothing Then
        oProcedure.Parameters("@@lang").InputValue = Database.Locale
        oProcedure.Parameters("@@idcoworker").InputValue = ActiveUser.Record.ID
        Call oProcedure.Execute(False)
    Else
        Call Application.MessageBox("The procedure """ & strProcedureName & """ does not exist in the client metadata.")
    End If
    sXml = oProcedure.result
   sXml = XMLEncodeBase64(sXml)
    
    LoadDataStructure = sXml
    'MsgBox sXml
    'MsgBox StrConv(DecodeBase64(sXml), vbUnicode)
Exit Function
ErrorHandler:
Call UI.ShowError("LIPPackageBuilder.LoadDatastructure")
End Function

Public Function GetVBAComponents() As String
On Error GoTo ErrorHandler
    Dim oComp As Object
    Dim strComponents As String
    strComponents = "["
    For Each oComp In Application.VBE.ActiveVBProject.VBComponents
        'Only include modules, class modules and forms
        If oComp.Type <> 11 And oComp.Type <> 100 Then
            strComponents = strComponents & "{"
            strComponents = strComponents & """name"": """ & oComp.name & ""","
            strComponents = strComponents & """type"": """ & GetModuleTypeName(oComp.Type) & """},"
        End If
    Next
    
    strComponents = VBA.Left(strComponents, Len(strComponents) - 1)
    strComponents = strComponents + "]"
    
    GetVBAComponents = strComponents
Exit Function
ErrorHandler:
    Call UI.ShowError("LIPPackageBuilder.GetVBAComponents")
End Function

Private Function GetModuleTypeName(ModuleType As Long) As String
On Error GoTo ErrorHandler
    Dim strModuleTypeName As String
    strModuleTypeName = ""
    Select Case ModuleType
        Case 1:
            strModuleTypeName = "Module"
        Case 2:
            strModuleTypeName = "Class Module"
        Case 3:
            strModuleTypeName = "Form"
        Case Else
            strModuleTypeName = "Other"
    End Select
    GetModuleTypeName = strModuleTypeName
Exit Function
ErrorHandler:
Call UI.ShowError("LIPPackageBuilder.GetModuleTypeName")
End Function

Public Function XMLEncodeBase64(text As String) As String
     
    If text = "" Then XMLEncodeBase64 = "": Exit Function
     
    Dim arrData() As Byte
    arrData = StrConv(text, vbFromUnicode)
     
    Dim objXML As MSXML2.DOMDocument60
    Dim objNode As MSXML2.IXMLDOMElement
     
    Set objXML = New MSXML2.DOMDocument60
    Set objNode = objXML.createElement("b64")
     
    objNode.DataType = "bin.base64"
    objNode.nodeTypedValue = arrData
    XMLEncodeBase64 = objNode.text
     
    Set objNode = Nothing
    Set objXML = Nothing
     
End Function

Private Function DecodeBase64(ByVal strData As String) As Byte()
 
    Dim objXML As MSXML2.DOMDocument60
    Dim objNode As MSXML2.IXMLDOMElement
    
    ' help from MSXML
    Set objXML = New MSXML2.DOMDocument60
    Set objNode = objXML.createElement("b64")
    objNode.DataType = "bin.base64"
    objNode.text = strData
    DecodeBase64 = objNode.nodeTypedValue
    
    ' thanks, bye
    Set objNode = Nothing
    Set objXML = Nothing
 
End Function


Public Sub CreatePackage(strPackageJsonBase64 As String)
On Error GoTo ErrorHandler
    Dim strTempFolder As String
    Dim oPackage As Object
    Dim bResult As Boolean
    Dim strPackageJson As String
    Dim strOldTempFolder2 As String
    bResult = True
    strPackageJson = StrConv(DecodeBase64(strPackageJsonBase64), vbUnicode)
    'Create temporary folder
    strTempFolder = CreateTemporaryFolder()
    'Used for later
    strOldTempFolder2 = strTempFolder
    Set oPackage = JsonConverter.ParseJson(strPackageJson)
    
    'Export VBA modules
    If bResult And oPackage("install").Exists("vba") Then
        bResult = ExportVBA(oPackage, strTempFolder)
    End If
    If bResult = False Then
        Call Application.MessageBox("Couldn't export VBA Modules.")
        Exit Sub
    End If
    
    'Export SQL Procedures and functions
    If bResult And oPackage("install").Exists("sql") Then
        bResult = ExportSql(oPackage, strTempFolder)
        
    End If
    If bResult = False Then
        Call Application.MessageBox("Couldn't export SQL Procedures and functions")
        Exit Sub
    End If
    
    'Export Table icons
    If bResult Then
        bResult = SaveTableIcons(oPackage, strTempFolder)
    End If
    If bResult = False Then
        Call Application.MessageBox("Couldn't export table icons, will continue anyway...", vbInformation)
        bResult = True
    End If
    
    'Export option queries
    If bResult Then
        bResult = SaveOptionQueries(oPackage, strTempFolder)
    End If
    If bResult = False Then
        Call Application.MessageBox("Couldn't export the optionqueries, will continue anyway...", vbInformation)
        bResult = True
    End If
    
    ' Save SQL on update
     If bResult Then
        bResult = SaveSqlOnUpdate(oPackage, strTempFolder)
    End If
    If bResult = False Then
        Call Application.MessageBox("Couldn't export the sql on update, will continue anyway...", vbInformation)
        bResult = True
    End If
    
    ' Save SQL for new
     If bResult Then
        bResult = SaveSqlForNew(oPackage, strTempFolder)
    End If
    If bResult = False Then
        Call Application.MessageBox("Couldn't export the sql for new, will continue anyway...", vbInformation)
        bResult = True
    End If
    
    ' Save SQL Expressions
    If bResult Then
        bResult = SaveSqlExpressions(oPackage, strTempFolder)
    End If
    If bResult = False Then
        Call Application.MessageBox("Couldn't export the sql expressions, will continue anyway...", vbInformation)
        bResult = True
    End If
    
    ' Save SQL Descriptive
    If bResult Then
        bResult = SaveSqlDescriptive(oPackage, strTempFolder)
    End If
    If bResult = False Then
        Call Application.MessageBox("Couldn't export the sql descriptive expressions, will continue anyway...", vbInformation)
        bResult = True
    End If
    
    'LJE This is not yet implemented
    'If bResult Then
    '    bResult = CleanupPackageFile(oPackage)
    'End If
    'If bResult = False Then
    '    Call Application.MessageBox("Couldn't cleanup the package file, aborting...", vbError)
    '    bResult = False
    'End If
    
    'Save Package.json
    If bResult Then
        bResult = SavePackageFile(oPackage, strTempFolder)
    End If
    If bResult = False Then
        Call Application.MessageBox("Couldn't save the package.json file.")
        Exit Sub
    End If
    'Rename Temporary folder to package name
    Dim NewFolderName
    If bResult Then
        bResult = RenameTemporaryFolder(oPackage, strTempFolder)
    End If
    'save the new folder name
    Dim NewTempFolderName As String
    NewTempFolderName = strTempFolder
    
    If bResult = False Then
        Call Application.MessageBox("Couldn't Rename the temporary folder.")
        Exit Sub
    End If
    
    'Zip Temporary folder and save package
    Dim ZipPath As String
    If bResult Then
        bResult = ZipTemporaryFolder(oPackage.Item("name"), strTempFolder, ZipPath)
    End If
    
    If bResult = False Then
        Call Application.MessageBox("Couldn't save the package Zip file")
        Exit Sub
    End If
    
    'Open containing folder
    Call Application.Shell(ZipPath)
    
    'Delete Temporary folder
    If bResult Then
        bResult = DeleteTemporaryFolder(NewTempFolderName)
        bResult = DeleteTemporaryFolder(strOldTempFolder2)
    End If
    
    If Not bResult Then
        Call Application.MessageBox("Couldn't remove the temporary folder %1", vbExclamation, NewTempFolderName)
    End If
    
Exit Sub
ErrorHandler:
    Call UI.ShowError("LIPPackageBuilder.CreatePackage")
End Sub

Private Function SaveOptionQueries(oPackage As Object, strTempFolder As String) As Boolean
On Error GoTo ErrorHandler
    Dim bResult As Boolean
    Dim allOK As Boolean
    bResult = True
    allOK = True
    If oPackage.Exists("install") Then
        If oPackage("install").Exists("tables") Then
            Dim oTable As Object
            Dim strOptionQueryFolder As String
            Dim strFilePath As String
            strOptionQueryFolder = strTempFolder & "\" & "optionqueries"
    
            
            
            For Each oTable In oPackage.Item("install").Item("tables")
                If oTable.Exists("fields") Then
                    Dim oField As Object
                    For Each oField In oTable.Item("fields")
                        
                        If oField.Item("attributes").Item("optionquery") <> "" And oField.Item("attributes").Item("optionquery") <> "''" Then
                            bResult = SaveTextToDisk(oField.Item("attributes").Item("optionquery"), strOptionQueryFolder, oTable.Item("name") & "." & oField.Item("name") & ".txt")
                            
                            If bResult = False Then allOK = False
                            
                        End If
                        'Remove property from JSON object
                        If oField.Item("attributes").Exists("optionquery") Then
                            Call oField.Item("attributes").Remove("optionquery")
                        End If
                    Next
                End If
            Next
        End If
    End If
    SaveOptionQueries = allOK
Exit Function
ErrorHandler:
    Debug.Print Err.Description
    SaveOptionQueries = False
End Function

Private Function SaveSqlOnUpdate(oPackage As Object, strTempFolder As String) As Boolean
On Error GoTo ErrorHandler
    Dim bResult As Boolean
    Dim allOK As Boolean
    bResult = True
    allOK = True
    If oPackage.Exists("install") Then
        If oPackage("install").Exists("tables") Then
            Dim oTable As Object
            Dim strSqlOnUpdateFolder As String
            Dim strFilePath As String
            strSqlOnUpdateFolder = strTempFolder & "\" & "sql_on_update"
    
            
            
            For Each oTable In oPackage.Item("install").Item("tables")
                If oTable.Exists("fields") Then
                    Dim oField As Object
                    For Each oField In oTable.Item("fields")
                        
                        If oField.Item("attributes").Item("onsqlupdate") <> "" And oField.Item("attributes").Item("onsqlupdate") <> "''" Then
                            bResult = SaveTextToDisk(oField.Item("attributes").Item("onsqlupdate"), strSqlOnUpdateFolder, oTable.Item("name") & "." & oField.Item("name") & ".txt")
                            Call oField.Item("attributes").Remove("onsqlupdate")
                            If bResult = False Then allOK = False
                            
                        End If
                        'Remove property in JSON object
                        If oField.Item("attributes").Exists("onsqlupdate") Then
                            Call oField.Item("attributes").Remove("onsqlupdate")
                        End If
                    Next
                    
                End If
            Next
        End If
    End If
    SaveSqlOnUpdate = allOK
Exit Function
ErrorHandler:
    Debug.Print Err.Description
    SaveSqlOnUpdate = False
End Function

Private Function SaveSqlForNew(oPackage As Object, strTempFolder As String) As Boolean
On Error GoTo ErrorHandler
    Dim bResult As Boolean
    Dim allOK As Boolean
    bResult = True
    allOK = True
    If oPackage.Exists("install") Then
        If oPackage("install").Exists("tables") Then
            Dim oTable As Object
            Dim strSqlForNewFolder As String
            Dim strFilePath As String
            strSqlForNewFolder = strTempFolder & "\" & "sql_for_new"
    
            
            
            For Each oTable In oPackage.Item("install").Item("tables")
                If oTable.Exists("fields") Then
                    Dim oField As Object
                    For Each oField In oTable.Item("fields")
                        
                        If oField.Item("attributes").Item("onsqlinsert") <> "" And oField.Item("attributes").Item("onsqlinsert") <> "''" Then
                            bResult = SaveTextToDisk(oField.Item("attributes").Item("onsqlinsert"), strSqlForNewFolder, oTable.Item("name") & "." & oField.Item("name") & ".txt")
                            Call oField.Item("attributes").Remove("onsqlinsert")
                            If bResult = False Then allOK = False
                            
                        End If
                        'Remove property in JSON object
                        If oField.Item("attributes").Exists("onsqlinsert") Then
                            Call oField.Item("attributes").Remove("onsqlinsert")
                        End If
                    Next
                End If
            Next
        End If
    End If
    SaveSqlForNew = allOK
Exit Function
ErrorHandler:
    Debug.Print Err.Description
    SaveSqlForNew = False
End Function

Private Function SaveSqlExpressions(oPackage As Object, strTempFolder As String) As Boolean
On Error GoTo ErrorHandler
    Dim bResult As Boolean
    Dim allOK As Boolean
    bResult = True
    allOK = True
    If oPackage.Exists("install") Then
        If oPackage("install").Exists("tables") Then
            Dim oTable As Object
            Dim strSqlExpressionsFolder As String
            Dim strFilePath As String
            strSqlExpressionsFolder = strTempFolder & "\" & "sql_expressions"
    
            
            
            For Each oTable In oPackage.Item("install").Item("tables")
                If oTable.Exists("fields") Then
                    Dim oField As Object
                    For Each oField In oTable.Item("fields")
                        
                        If oField.Item("attributes").Item("sql") <> "" And oField.Item("attributes").Item("sql") <> "''" Then
                            bResult = SaveTextToDisk(oField.Item("attributes").Item("sql"), strSqlExpressionsFolder, oTable.Item("name") & "." & oField.Item("name") & ".txt")
                            Call oField.Item("attributes").Remove("sql")
                            If bResult = False Then allOK = False
                        End If
                        
                        'Remove property in JSON object
                        If oField.Item("attributes").Exists("sql") Then
                            Call oField.Item("attributes").Remove("sql")
                        End If
                    Next
                End If
            Next
        End If
    End If
    SaveSqlExpressions = allOK
Exit Function
ErrorHandler:
    Debug.Print Err.Description
    SaveSqlExpressions = False
End Function

Private Function SaveSqlDescriptive(oPackage As Object, strTempFolder As String) As Boolean
On Error GoTo ErrorHandler
    Dim bResult As Boolean
    Dim allOK As Boolean
    bResult = True
    allOK = True
    If oPackage.Exists("install") Then
        If oPackage("install").Exists("tables") Then
            Dim oTable As Object
            Dim strSqlDescriptiveFolder As String
            Dim strFilePath As String
            strSqlDescriptiveFolder = strTempFolder & "\" & "descriptive_expressions"
            
            For Each oTable In oPackage.Item("install").Item("tables")
                If oTable.Item("attributes").Item("descriptive") <> "" And oTable.Item("attributes").Item("descriptive") <> "''" Then
                    bResult = SaveTextToDisk(oTable.Item("attributes").Item("descriptive"), strSqlDescriptiveFolder, oTable.Item("name") & ".txt")
                    If bResult = False Then allOK = False
                            
                End If
                
                'Remove property from JSON object
                If oTable.Item("attributes").Exists("descriptive") Then
                    Call oTable.Item("attributes").Remove("descriptive")
                End If
            Next
        End If
    End If
    SaveSqlDescriptive = allOK
Exit Function
ErrorHandler:
    Debug.Print Err.Description
    SaveSqlDescriptive = False
End Function
Private Function SaveTextToDisk(strText As String, strFolderPath As String, strFilename As String)
On Error GoTo ErrorHandler
    Dim oStream
    
    Set oStream = CreateObject("ADODB.Stream")
    
    If VBA.Len(VBA.Dir(strFolderPath, vbDirectory)) = 0 Then
        Call VBA.MkDir(strFolderPath)
    End If
    
    strFilename = strFolderPath & "\" & strFilename
    
    If strText = "" Or strText = "''" Then
        Call Err.Raise(1, , "Empty text was supplied to the stream")
    End If
    
    oStream.Type = adTypeText
    
    oStream.Open
    
    On Error GoTo StreamError
    Call oStream.WriteText(strText)
    Call oStream.SaveToFile(strFilename, adSaveCreateNotExist)
    
    Call oStream.Close
    
    Set oStream = Nothing
    SaveTextToDisk = True
Exit Function
StreamError:
    If Not oStream Is Nothing Then
        If oStream.State = adStateOpen Then oStream.Close
    End If
    
    Set oStream = Nothing
    
    SaveTextToDisk = False
    Exit Function
ErrorHandler:
    Debug.Print "LIPPackageBuilder.SaveTextToDisk " & Err.Description
    SaveTextToDisk = False
End Function



Private Function SaveBinaryToDisk(strBinaryBase64Data As String, strFilename As String, strFolder As String) As Boolean
On Error GoTo ErrorHandler
    Dim binaryData() As Byte
    
    binaryData = DecodeBase64(strBinaryBase64Data)
    Dim strFilePath As String
    
    If VBA.Right(strFolder, 1) = "\" Then
        strFilePath = strFolder + strFilename
    Else
        strFilePath = strFolder + "\" + strFilename
    End If
    
    If VBA.Len(VBA.Dir(strFolder, vbDirectory)) = 0 Then
        Call VBA.MkDir(strFolder)
    End If
    
    Dim binaryStream
    Set binaryStream = CreateObject("ADODB.Stream")
    binaryStream.Type = adTypeBinary
    
    binaryStream.Open
    
    On Error GoTo StreamError
    binaryStream.Write binaryData
    
    binaryStream.SaveToFile strFilePath, adSaveCreateNotExist
    
    binaryStream.Close
    Set binaryStream = Nothing
    SaveBinaryToDisk = True
Exit Function
StreamError:
    binaryStream.Close
    Set binaryStream = Nothing
    SaveBinaryToDisk = False
    Exit Function
ErrorHandler:
    SaveBinaryToDisk = False
End Function

Private Function SaveTableIcons(oPackage As Object, strTempFolder As String) As Boolean
On Error GoTo ErrorHandler
    Dim bResult As Boolean
    Dim bAllOK As Boolean
    bResult = True
    bAllOK = True
    
    If oPackage.Exists("install") Then
        If oPackage("install").Exists("tables") Then
            Dim oTable As Object
            Dim strIconFolder As String
            strIconFolder = strTempFolder & "\" & "tableicons"
            For Each oTable In oPackage.Item("install").Item("tables")
                If oTable.Exists("attributes") Then
                    If oTable.Item("attributes").Exists("icon") Then
                        bResult = SaveBinaryToDisk(oTable.Item("attributes").Item("icon"), oTable("name") & ".ico", strIconFolder)
                        Call oTable.Item("attributes").Remove("icon")
                        If bResult = False Then bAllOK = False
                    End If
                End If
            Next
        End If
    End If
    SaveTableIcons = bAllOK
Exit Function
ErrorHandler:
    Call UI.ShowError("LIPPackageBuilder.SaveTableIcons")
End Function

Private Function ExportSql(oPackage As Object, strTempFolder As String) As Boolean
On Error GoTo ErrorHandler
    Dim bResult As Boolean
    If Not oPackage.Item("install") Is Nothing Then
        Dim oProcedure As Object
        
        If Not oPackage.Item("install").Item("sql") Is Nothing Then
            For Each oProcedure In oPackage.Item("install").Item("sql")
                bResult = ExportSqlObject(oProcedure.Item("name"), oProcedure.Item("definition"), strTempFolder)
                If bResult = False Then
                    ExportSql = False
                    Exit Function
                End If
                Call oProcedure.Remove("definition")
                Call oProcedure.Add("relPath", "sql\" & oProcedure.Item("name") & ".sql")
            Next
        End If
        
    End If
    
    ExportSql = True
Exit Function
ErrorHandler:
    Call UI.ShowError("LIPPackageBuilder.ExportSql")
End Function

Private Function ExportSqlObject(ProcedureName As String, Definition As String, strTempFolder As String) As Boolean
On Error GoTo ErrorHandler

    Dim strSqlFolder As String
    Dim strDefinition As String
    Dim strFilename As String
    strSqlFolder = strTempFolder & "\" & "sql"
    If VBA.Len(Dir(strSqlFolder, vbDirectory)) = 0 Then
        MkDir strSqlFolder
    End If
    
    strFilename = strSqlFolder & "\" & ProcedureName & ".sql"
    
    strDefinition = StrConv(DecodeBase64(Definition), vbUnicode)
    
    'Work-around: conversion adds nullchars since it's Unicode (2 bytes), second byte is always null.
    strDefinition = VBA.Replace(strDefinition, Chr(0), "")
    
    Dim intFileNum As Integer
    
    intFileNum = FreeFile
    ' change Output to Append if you want to add to an existing file
    ' rather than creating a new file each time
    Open strFilename For Output As intFileNum
    Print #intFileNum, strDefinition
    Close intFileNum
    
    ExportSqlObject = True

Exit Function
ErrorHandler:
    ExportSqlObject = False
End Function
Public Function ByteArrayToString(bytArray() As Byte) As String
    Dim sAns As String
    Dim iPos As String
    
    sAns = StrConv(bytArray, vbUnicode)
    iPos = InStr(sAns, Chr(0))
    If iPos > 0 Then sAns = Left(sAns, iPos - 1)
    
    ByteArrayToString = sAns
 
 End Function
Public Function GetFolder() As String
On Error GoTo ErrorHandler
    Dim fldr As New LCO.FolderDialog
    Dim sItem As String
    
    GetFolder = ""
        
    fldr.text = "Select a Folder to save the package file."
    If fldr.show = vbOK Then
        GetFolder = fldr.Folder
    End If
    Set fldr = Nothing
    Exit Function
    
ErrorHandler:
    GetFolder = ""
    Set fldr = Nothing
End Function

Private Function ZipTemporaryFolder(strPackageName As String, strTempFolder As String, ByRef ZipPath As String) As Boolean
On Error GoTo ErrorHandler
    Dim FileNameZip, FolderName
    Dim strDate As String, DefPath As String
    Dim oApp As Object
    Dim bResult As Boolean
    bResult = True
    DefPath = GetFolder()
    If DefPath = "" Then
        ZipTemporaryFolder = False
        Exit Function
    End If
    
    ZipPath = DefPath
    'Make sure the path format is as it's expected by the NewZip function
    If Right(DefPath, 1) <> "\" Then
        DefPath = DefPath & "\"
    End If

    

    FileNameZip = DefPath & strPackageName & ".zip"

    'Create empty Zip File
    Call NewZip(FileNameZip)
    Dim oZipFile As Object
    Dim oPackageFolder As Object
    Set oApp = CreateObject("Shell.Application")
    'Create folder object for the zip file
    Close
    Set oZipFile = oApp.Namespace(FileNameZip)
    
    If Not oZipFile Is Nothing Then
        
        
        'Create folder object for the package folder (different path format, which is messed up...)
        Set oPackageFolder = oApp.Namespace(strTempFolder & "\")
        If Not oPackageFolder Is Nothing Then
            'Move files from the package folder to the zip file
            oZipFile.CopyHere oPackageFolder.Items
        
            'Keep script waiting until Compressing is done
            On Error Resume Next
            Do Until oZipFile.Items.Count = _
               oPackageFolder.Items.Count
                Application.Wait (Now + TimeValue("0:00:01"))
            Loop
            On Error GoTo 0
        Else
            FileNameZip = ""
            bResult = False
        End If
    Else
        FileNameZip = ""
        bResult = False
    End If
    ZipTemporaryFolder = bResult
Exit Function
ErrorHandler:
    ZipTemporaryFolder = False
    
End Function

Private Function RenameTemporaryFolder(oPackage As Object, strTempFolder As String) As Boolean
On Error GoTo ErrorHandler
    Dim bResult As Boolean
    bResult = True
    'I am assuming that the Folder Exists

    Dim NewFolderName As String
    'Name the temporary folder the same as the Package name
    If Right(strTempFolder, 1) = "\" Then
        NewFolderName = Left(strTempFolder, Len(strTempFolder) - 1)
    Else
        NewFolderName = strTempFolder
    End If
    
        
    
    NewFolderName = VBA.Left(NewFolderName, InStrRev(NewFolderName, "\")) & oPackage.Item("name")
'    If Dir(NewFolderName, vbDirectory) = "" Then
'        Call Application.MessageBox("The folder """ & NewFolderName & """ already exists.")
'        RenameTemporaryFolder = False
'        Exit Function
'    End If
    '-- Rename them
    If VBA.Dir(NewFolderName, vbDirectory) <> "" Then
        DeleteTemporaryFolder (NewFolderName)
        
        bResult = True
    Else
    Name strTempFolder As NewFolderName
    End If
    
    strTempFolder = NewFolderName

    RenameTemporaryFolder = bResult
Exit Function
ErrorHandler:
    bResult = False
End Function

Sub NewZip(sPath)
'Create empty Zip File
'Changed by keepITcool Dec-12-2005
    Dim fNum As Integer
    fNum = FreeFile
    
    If Len(Dir(sPath)) > 0 Then Kill sPath
    Open sPath For Output As #fNum
    Print #fNum, Chr$(80) & Chr$(75) & Chr$(5) & Chr$(6) & String(18, 0)
    Close #fNum
End Sub

Public Function DeleteTemporaryFolder(strTempFolder As String) As Boolean
On Error GoTo ErrorHandler

    'Delete all files and subfolders
    'Be sure that no file is open in the folder
    Dim FSO As Object

    Set FSO = CreateObject("Scripting.FileSystemObject")
    
    If Right(strTempFolder, 1) = "\" Then
        strTempFolder = Left(strTempFolder, Len(strTempFolder) - 1)
    End If

    If FSO.FolderExists(strTempFolder) = False Then
        DeleteTemporaryFolder = True
        Exit Function
    End If

    On Error Resume Next
    'Delete files
    FSO.DeleteFile strTempFolder & "\*.*", True
    'Delete subfolders
    FSO.DeleteFolder strTempFolder & "\*.", True
    Call RmDir(strTempFolder)
    On Error GoTo 0
    
    DeleteTemporaryFolder = True
    
    Exit Function
ErrorHandler:
    DeleteTemporaryFolder = False
    Debug.Print Err.Number & vbCrLf & Err.Description
End Function

Public Function SavePackageFile(oPackage As Object, strTempPath As String) As Boolean
On Error GoTo ErrorHandler
    Dim bResult As Boolean
    Dim FSO As New FileSystemObject
    Dim filePath As String
    filePath = strTempPath & "\package.json"
    bResult = True
    'Set FSO = CreateObject("Scripting.FileSystemObject")
    
    Dim oFile As Object
    Set oFile = FSO.CreateTextFile(filePath, True, False)
    'Convert to a string and save
    Call oFile.WriteLine(JsonConverter.ConvertToJson(oPackage))
    oFile.Close
    Set FSO = Nothing
    Set oFile = Nothing
    
    
    SavePackageFile = bResult
Exit Function
ErrorHandler:
    bResult = False
End Function


'Exports all VBA-Modules marked in the Package JSON
Public Function ExportVBA(oPackage As Object, strTempFolder As String) As Boolean
On Error GoTo ErrorHandler
    Dim bResult As Boolean
    bResult = True
    If Not oPackage.Item("install") Is Nothing Then
        Dim oModule As Object
        
        If Not oPackage.Item("install").Item("vba") Is Nothing Then
            For Each oModule In oPackage.Item("install").Item("vba")
                bResult = ExportVBAModule(oModule.Item("name"), strTempFolder)
                If bResult = False Then
                    ExportVBA = False
                    Exit Function
                End If
            Next
        End If
    End If
    ExportVBA = bResult
Exit Function
ErrorHandler:
    bResult = False
End Function

'Exporterar alla VBA-objekt till fil
Public Function ExportVBAModule(ModuleName As String, Optional strTempFolder As String = "") As Boolean
On Error GoTo ErrorHandler
    Dim Component As Object
    Dim strInstallFolder As String
    
    Dim bResult As Boolean
    bResult = True
    Set Component = ThisApplication.VBE.ActiveVBProject.VBComponents(ModuleName)
    If VBA.Dir(strTempFolder & "\" & "Install", vbDirectory) = "" Then
        strInstallFolder = CreateTemporaryFolder(strTempFolder, "Install")
    Else
        strInstallFolder = strTempFolder & "\" & "Install"
    End If
    Dim strFilename As String
    
    If Not Component Is Nothing Then
        strFilename = Component.name
        Select Case Component.Type
            Case 1
                strFilename = strFilename & ".bas"
            Case 2
                strFilename = strFilename & ".cls"
            Case 3
                strFilename = strFilename & ".frm"
            
            Case Else
                bResult = False
                Exit Function
        End Select
        
        Call Component.Export(strInstallFolder & "\" & strFilename)
        bResult = True
    End If
    ExportVBAModule = bResult
Exit Function
ErrorHandler:
    bResult = False
End Function

Private Function CreateTemporaryFolder(Optional strTempFolder As String = "", Optional Subfolder As String = "") As String
On Error GoTo ErrorHandler
    'Kolla om s�kv�gen finns och skapar mappen
    Dim strTempPath As String
    
    strTempPath = IIf(strTempFolder = "", Application.WebFolder & "apps\LIPPackageBuilder\" & VBA.Replace(VBA.Replace(LCO.GenerateGUID, "{", ""), "}", ""), strTempFolder)
    
    Dim strExists As String
    strExists = VBA.Dir(strTempPath, vbDirectory)
    If strExists = "" Then
        Call MkDir(strTempPath)
    End If
    
    If Subfolder <> "" Then
        strTempPath = strTempPath & "\" & Subfolder
        strExists = VBA.Dir(strTempPath & Subfolder, vbDirectory)
        If strExists = "" Then
            Call MkDir(strTempPath)
        End If
    End If
    
    CreateTemporaryFolder = strTempPath
    
Exit Function
ErrorHandler:
    Call UI.ShowError("LIPPackageBuilder.CreateTemporaryFolder")
End Function

Public Function GetLocalizations(ByVal sOwner As String) As Records
    On Error GoTo ErrorHandler
    Dim oRecords As New LDE.Records
    Dim oFilter As New LDE.Filter
    Dim oView As New LDE.View
    
    Call oView.Add("owner", lkSortAscending)
    Call oView.Add("code")
    Call oView.Add("sv")
    Call oView.Add("en_us")
    Call oView.Add("no")
    Call oView.Add("fi")
    Call oView.Add("da")
    If sOwner <> "" Then
        Call oFilter.AddCondition("owner", lkOpEqual, sOwner)
    End If
    Call oRecords.Open(Database.Classes("localize"), oFilter, oView)
    Set GetLocalizations = oRecords
    Exit Function
ErrorHandler:
    Call UI.ShowError("LIPPackageBuilder.GetLocalizations")
End Function
'LJE This is not yet implemented
'Public Function OpenExistingPackage() As String
'On Error GoTo ErrorHandler
'    Dim o As New LCO.FileOpenDialog
'    Dim strFilePath As String
'    o.AllowMultiSelect = False
'    o.Caption = "Select Package file"
'    o.Filter = "Zipped Package files (*.zip) | *.zip"
'
'    o.DefaultFolder = LCO.GetDesktopPath
'    If o.show = vbOK Then
'        strFilePath = o.Filename
'    Else
'        Exit Function
'    End If
'
'    If LCO.ExtractFileExtension(strFilePath) = "zip" Then
'        Dim strTempFolderPath As String
'        strTempFolderPath = Application.TemporaryFolder & "\" & VBA.Replace(VBA.Replace(LCO.GenerateGUID, "{", ""), "}", "")
'        Dim FSO As New Scripting.FileSystemObject
'        If Not FSO.FolderExists(strTempFolderPath) Then
'            Call FSO.CreateFolder(strTempFolderPath)
'        End If
'
'
'        On Error GoTo UnzipError
'        Call UnZip(strTempFolderPath, strFilePath)
'
'        On Error GoTo ErrorHandler
'        Dim strJson As String
'        If LCO.FileExists(strTempFolderPath & "\" & "app.json") Then
'            strJson = ReadAllTextFromFile(strTempFolderPath & "\" & "app.json")
'        ElseIf LCO.FileExists(strTempFolderPath & "\" & "package.json") Then
'            strJson = ReadAllTextFromFile(strTempFolderPath & "\" & "package.json")
'        Else
'            Call Application.MessageBox("Could not find an app.json or a package.json in the extracted folder")
'            Exit Function
'        End If
'
'        Dim b64Json As String
'        b64Json = XMLEncodeBase64(strJson)
'
'        OpenExistingPackage = b64Json
'
'    End If
'
'
'Exit Function
'ErrorHandler:
'    Call UI.ShowError("LIPPackageBuilder.OpenExistingPackage")
'    Exit Function
'UnzipError:
'    Call Application.MessageBox("There was an error unzipping the zipped package file")
'End Function


Sub UnZip(strTargetPath As String, Fname As Variant)
    Dim oApp As Object, FSOobj As Object
    Dim FileNameFolder As Variant

    If Right(strTargetPath, 1) <> "\" Then
        strTargetPath = strTargetPath & "\"
    End If
    
    FileNameFolder = strTargetPath
    
    'create destination folder if it does not exist
    Set FSOobj = CreateObject("Scripting.FilesystemObject")
    If FSOobj.FolderExists(FileNameFolder) = False Then
        FSOobj.CreateFolder FileNameFolder
    End If
    
    Set oApp = CreateObject("Shell.Application")
    oApp.Namespace(FileNameFolder).CopyHere oApp.Namespace(CVar(Fname)).Items
    
    Set oApp = Nothing
    Set FSOobj = Nothing
    Set FileNameFolder = Nothing
    
End Sub

Private Function ReadAllTextFromFile(strFilePath As String) As String
On Error GoTo ErrorHandler
    Dim strText As String, Filenum As Integer, s As String
    
    Filenum = FreeFile
    
    Open strFilePath For Input As #Filenum

    While Not EOF(Filenum)
        Line Input #Filenum, s    ' read in data 1 line at a time

        strText = strText + s
    Wend
    
    Close #Filenum
    
    ReadAllTextFromFile = strText
Exit Function
ErrorHandler:
    Call UI.ShowError("LIPPackageBuilder.ReadAllTextFromFile")
End Function

Private Function CleanupPackageFile(oPackage As Object) As Boolean
On Error GoTo ErrorHandler
    'Remove related table
     If oPackage.Exists("install") Then
        If oPackage("install").Exists("tables") Then
            Dim oTable As Object
            Dim strIconFolder As String
            Dim oField As Object
            
            For Each oTable In oPackage.Item("install").Item("tables")
                If oTable.Exists("fields") Then
                    For Each oField In oTable.Item("fields")
                        If oField.Exists("attributes") Then
                            Call oField.Item("attributes").Remove("relatedtable")
                        End If
                    Next
                End If
            Next
        End If
    End If
    CleanupPackageFile = True
Exit Function
ErrorHandler:
    CleanupPackageFile = False
End Function
