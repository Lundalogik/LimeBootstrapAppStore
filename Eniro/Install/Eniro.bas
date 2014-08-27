Attribute VB_Name = "Eniro"
Option Explicit

Public Function getData()
On Error GoTo errorhandler
    Dim MyRequest As Object
    Dim search As String
    Dim xmlString As String
    
    xmlString = "<?xml version='1.0' encoding='ISO-8859-1' ?><search></search>"
    If Not ActiveInspector Is Nothing Then
    
        If ActiveInspector.Class.Name = "helpdesk" Then
             If ActiveInspector.Controls("phone") <> "" Then
                If ActiveInspector.Controls("postalcode") = "" Then
                    search = ActiveInspector.Controls("phone")
                    Set MyRequest = CreateObject("WinHttp.WinHttpRequest.5.1")
                    MyRequest.Open "GET", _
                    "http://live.intouch.no/tk/search.php?wsdl&username=USERNAME&password=PASSWORD=" & search & "&format=xml"
                    
                    ' USERNAME AND PASSWORD MUST BE CHANGED TO YOUR OWN.
                    
                    ' Send Request.
                    MyRequest.Send
                
                    search = "<?xml version='1.0' encoding='ISO-8859-1' ?><search><qry>981 12 288</qry><resulthitLinesBeforeFilter='1' userID='2485'><hit line='1'><listing table='listing' id='2535474'><duplicates><duplicate number='0'><listing table='listing' id='2535474:0'><idlinje>E1AIUC6</idlinje><tlfnr>98112288</tlfnr><etternavn>Hermansson</etternavn><fornavn>Joakim</fornavn><veinavn>Herbergveien</veinavn><husnr>4</husnr><postnr>1710</postnr><virkkode>P</virkkode><apparattype>M</apparattype><kilde>E</kilde><prioritet>0</prioritet><kommunenr>105</kommunenr><poststed>Sarpsborg</poststed><kommune>Sarpsborg</kommune><fylke>Østfold</fylke><landsdel>Ø</landsdel></listing></duplicate></duplicates></listing></hit></result></search>"
                    getData = search
                    xmlString = MyRequest.responseText
                    'getData =
                    
                    'And we get this response
                    'MsgBox MyRequest.responseText
                    'Debug.Print MyRequest.responseText
                End If
            End If
        End If
    End If
    
    getData = xmlString
    
    
Exit Function
errorhandler:
UI.ShowError ("Eniro.getData")
End Function


Public Sub setPostalCode(postalCode As String)
On Error GoTo errorhandler
    If Not ActiveInspector Is Nothing Then
        If ActiveInspector.Class.Name = "helpdesk" Then
            If postalCode <> "" Then
                Call ActiveInspector.Controls.SetValue("postalcode", postalCode)
            End If
        End If
    End If
Exit Sub
errorhandler:
UI.ShowError ("Eniro.setPostalCode")
End Sub



