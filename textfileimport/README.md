#Textfile import

The textfile import is a tool for importing... ehh... textfiles. It works (well, kind of) with any type of tab-seperated .txt-files. 

##Installation

As always, copy the app folder "textfileimport" to the "apps" folder in your webfolder

###VBA
- Create a classmodule 'XmlImport' and copy the code from 'install/XmlImport.txt'

- GetRandomNumber and GetXmlImportInstanc should be copied into the module "Globals"

```VBA
Public Function GetRandomNumber(ByVal Min As Integer, ByVal Max As Integer) As Integer
    On Error GoTo ErrorHandler
        Call Randomize
        GetRandomNumber = Int((Max * Rnd) + Min)
        Exit Function
    ErrorHandler:
    Call UI.ShowError("Globals.GetRandomNumber")
End Function

Public Function GetXmlImportInstance() As Object
    On Error Resume Next 'da shit!

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

###HTML
To launch the textfile import you use the "appInvoke" binding:

```html
<li data-bind="appInvoke: 'textfileimport', text: 'Importera textfil', icon:'fa-file'"></li>   
```

###Problems?
Try restaring LIME!

##Settings
The texfile import has a lot of setting. You can play with them in the ```textfileimport.ini``` file.
Good luck and happy importing!
