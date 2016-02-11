Attribute VB_Name = "drivinginfo"
Option Explicit


Public Function getLatLong(sendtype As String, Optional latlonThere As String, Optional herelat As String)
On Error GoTo ErrorHandler
    Dim MyRequest As Object
    Dim search As String
    Dim xmlString As String
    Dim link As String
    Dim sAdress As String
    
    Dim oInspector As Lime.Inspector
    Set oInspector = Application.ActiveInspector

    If latlonThere <> "" And herelat <> "" Then
        Dim sLongLatHere As String
            sLongLatHere = Replace(herelat, ";", ",")
        Dim sLongLatThere As String
            sLongLatThere = Replace(latlonThere, ";", ",")
    End If
    
    Select Case sendtype
        Case "address":
            sAdress = Application.ActiveInspector.Controls.GetText("postaladdress1")
            sAdress = Replace(sAdress, " ", "+")
            link = "http://nominatim.openstreetmap.org/search?q=" + sAdress + "&format=json&polygon=1&addressdetails=1"
        Case "office"
            Dim oRecordMe As New LDE.Record
            Dim oView As New LDE.View
            Dim oRecordOffice As New LDE.Record
            Dim oViewOffice As New LDE.View
            
            Call oView.Add("office")
            Call oView.Add("idcowroker")
            Call oRecordMe.Open(Application.Classes("coworker"), Application.ActiveUser.Record.ID)
            
            Call oViewOffice.Add("address")
            Call oViewOffice.Add("idoffice")
            Call oRecordOffice.Open(Application.Classes("office"), oRecordMe("office"))
            sAdress = oRecordOffice("address")
            sAdress = Replace(sAdress, " ", "+")
            
            link = "http://nominatim.openstreetmap.org/search?q=" + sAdress + "&format=json&polygon=1&addressdetails=1"
            
        Case "distance":
            link = "http://router.project-osrm.org/viaroute?loc=" + sLongLatHere + "&loc=" + sLongLatThere + "&instructions=true"
    End Select
            
    xmlString = "<?xml version='1.0' encoding='ISO-8859-1' ?><search></search>"
    
                    Set MyRequest = CreateObject("WinHttp.WinHttpRequest.5.1")
                    MyRequest.Open "GET", _
                    link
                                        
                    ' Send Request.
                    MyRequest.Send
                    ' search = "<?xml version='1.0' encoding='ISO-8859-1' ?><search><qry>981 12 288</qry><resulthitLinesBeforeFilter='1' userID='2485'><hit line='1'><listing table='listing' id='2535474'><duplicates><duplicate number='0'><listing table='listing' id='2535474:0'><idlinje>E1AIUC6</idlinje><tlfnr>98112288</tlfnr><etternavn>Hermansson</etternavn><fornavn>Joakim</fornavn><veinavn>Herbergveien</veinavn><husnr>4</husnr><postnr>1710</postnr><virkkode>P</virkkode><apparattype>M</apparattype><kilde>E</kilde><prioritet>0</prioritet><kommunenr>105</kommunenr><poststed>Sarpsborg</poststed><kommune>Sarpsborg</kommune><fylke>Østfold</fylke><landsdel>Ø</landsdel></listing></duplicate></duplicates></listing></hit></result></search>"
                    xmlString = MyRequest.responseText
                    'getData =
                    
    
    getLatLong = xmlString
    
Exit Function
ErrorHandler:
UI.ShowError ("Actionpad_company.getLatLong")
End Function

