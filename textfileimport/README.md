#Textfile import

The textfile import is a tool for importing... ehh... textfiles. It works (well, kind of) with any type of tab-seperated .txt-files. 

###Installation
- XmlImport is a classmodule that should be imported, found in the folder "install"

- GetRandomNumber should be copied into the module "Globals"

```vb
Public Function GetRandomNumber(ByVal Min As Integer, ByVal Max As Integer) As Integer
On Error GoTo ErrorHandler
    
    Call Randomize
    GetRandomNumber = Int((Max * Rnd) + Min)

    Exit Function
ErrorHandler:
    Call UI.ShowError("Globals.GetRandomNumber")
End Function
```

- GetXmlImportInstance should be copied into the module "Globals":

```vb
Public Function GetXmlImportInstance() As Object
    On Error Resume Next

    Dim pObject As Object
    
    If IsObject(Application.Tag("XmlImportInstance")) Then
        Set pObject = Application.Tag("XmlImportInstance")
    End If
        
    If Not pObject Is Nothing Then
        If Not TypeOf pObject Is XmlImport Then
            Set pObject = Nothing
        End If
    End If
    
    If pObject Is Nothing Then
        Set pObject = New XmlImport
        
        Application.Tag("XmlImportInstance") = pObject
    End If
    
    Set GetXmlImportInstance = pObject
End Function
```