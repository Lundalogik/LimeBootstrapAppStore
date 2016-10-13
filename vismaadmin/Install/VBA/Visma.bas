Attribute VB_Name = "Visma"
Public Function CheckValidate() As Boolean
On Error GoTo ErrorHandler
    Dim oInspector As Lime.Inspector
    Dim companyName As String
    
    Set oInspector = ActiveInspector
    
    If oInspector.Class.Name = "company" Then
        If Len(oInspector.Controls.GetText("name")) > 3 Then
            If Len(oInspector.Controls.GetText("phone")) < 20 Then
                If Len(oInspector.Controls.GetText("telefax")) < 20 Then
                    If Len(oInspector.Controls.GetText("postalzipcode")) < 12 Then
                        oInspector.Save
                        CheckValidate = True
                        Exit Function
                    Else
                        Lime.MessageBox (Localize.GetText("Actionpad_Company", "e_toolong_zip"))
                        CheckValidate = False
                    End If
                Else
                    Lime.MessageBox (Localize.GetText("Actionpad_Company", "e_toolong_fax"))
                    CheckValidate = False
                End If
            Else
                Lime.MessageBox (Localize.GetText("Actionpad_Company", "e_toolong_phoneno"))
                CheckValidate = False
            End If
        Else
            Lime.MessageBox (Localize.GetText("Actionpad_Company", "e_tooshort_company"))
            CheckValidate = False
        End If
    Else
    Lime.MessageBox (Localize.GetText("Actionpad_Company", "e_companyonly"))
    CheckValidate = False
    End If
    
Exit Function
ErrorHandler:
    UI.ShowError ("Visma.SendToVisma")
End Function


Public Function SendToVisma(url As String, newCompany As Boolean) As String
    On Error GoTo ErrorHandler
    Dim oXHTTP As MSXML2.XMLHTTP60
    Dim str1 As String
    Dim str2 As String
    Dim str3 As String
    Dim str4 As String
    Dim str5 As String
    Dim str6 As String
    Dim JSON As String
    Dim VISMA_URL As String
    Dim sArray() As String
    Dim oInspector As Lime.Inspector
    Set oInspector = ActiveInspector
    Set oControls = oInspector.Controls
     
        'Check that we have an inspector and that it is a company
        If Not oInspector Is Nothing Then
                
                'Array with all values from html (see app.js for more information)
                'sArray = VBA.Split(Object, ";")
                VISMA_URL = url 'sArray(0)
                
                Set oXHTTP = New MSXML2.XMLHTTP60
                
                If newCompany = True Then
                    ' POST, used to new companies
                    Call oXHTTP.Open("POST", VISMA_URL, False)
                    
                    ' Content-Type
                    Call oXHTTP.setRequestHeader("Content-Type", "application/json")
                    Call oXHTTP.setRequestHeader("Accept", "application/json")
                              
                    ' JSON to create new company in visma. This is sent to VISMA API
                    
                    JSON = "{" _
                        & """Number"":""""," _
                        & """Name"":""" & oControls.GetText("name") & """," _
                        & """OrganisationNumber"":""" & oControls.GetText("registrationno") & """," _
                        & """Address1"":""" & oControls.GetText("postaladdress1") & """," _
                        & """Address2"":""" & oControls.GetText("postaladdress2") & """," _
                        & """Zipcode"":""" & oControls.GetText("postalzipcode") & """," _
                        & """City"":""" & oControls.GetText("postalcity") & """," _
                        & """Country"":""" & oControls.GetText("country") & """," _
                        & """Fax"":""" & oControls.GetText("telefax") & """," _
                        & """Telephone"":""" & oControls.GetText("phone") & """," _
                        & """Reference"":""" & oControls.GetText("coworker") & """," _
                        & """DeliveryName"":""" & oControls.GetText("name") & """," _
                        & """DeliveryAddress"":""" & oControls.GetText("visitingaddress1") & """," _
                        & """DeliveryAddress2"":""" & oControls.GetText("visitingaddress2") & """," _
                        & """DeliveryZipcode"":""" & oControls.GetText("visitingzipcode") & """," _
                        & """DeliveryCity"":""" & oControls.GetText("visitingcity") & """," _
                        & """DeliveryCountry"":""" & oControls.GetText("country") & """," _
                        & """DeliveryFax"":""""," _
                        & """DeliveryTelephone"":""""," _
                        & """DeliveryVisitingAddress"":""""," _
                        & """AccumulateTurnoverThisYear"":""""," _
                        & """AccumulateTurnoverLastYear"":""""" _
                        & "" _
                        & "}"
                    
                    Call oXHTTP.Send(JSON)
                    SendToVisma = oXHTTP.responseText
                    Exit Function
                Else
                    ' PUT used to update companies in VISMA
                    Call oXHTTP.Open("PUT", VISMA_URL, False)
                    
                    ' Content-Type
                    Call oXHTTP.setRequestHeader("Content-Type", "application/json")
                    Call oXHTTP.setRequestHeader("Accept", "application/json")
                              
                    ' JSON to update company information in VISMA. This is sent to VISMA API
                    ' Create substrings to not exceed line continuation in VBA
                        
                   JSON = "{" _
                        & """Number"":""" & oControls.GetText("vismaid") & """," _
                        & """Name"":""" & oControls.GetText("name") & """," _
                        & """OrganisationNumber"":""" & oControls.GetText("registrationno") & """," _
                        & """Address1"":""" & oControls.GetText("postaladdress1") & """," _
                        & """Address2"":""" & oControls.GetText("postaladdress2") & """," _
                        & """Zipcode"":""" & oControls.GetText("postalzipcode") & """," _
                        & """City"":""" & oControls.GetText("postalcity") & """," _
                        & """Country"":""" & oControls.GetText("country") & """," _
                        & """Fax"":""" & oControls.GetText("telefax") & """," _
                        & """Telephone"":""" & oControls.GetText("phone") & """," _
                        & """Reference"":""" & oControls.GetText("coworker") & """," _
                        & """DeliveryName"":""" & oControls.GetText("name") & """," _
                        & """DeliveryAddress"":""" & oControls.GetText("visitingaddress1") & """," _
                        & """DeliveryAddress2"":""" & oControls.GetText("visitingaddress2") & """," _
                        & """DeliveryZipcode"":""" & oControls.GetText("visitingzipcode") & """," _
                        & """DeliveryCity"":""" & oControls.GetText("visitingcity") & """," _
                        & """DeliveryCountry"":""" & oControls.GetText("country") & """," _
                        & """DeliveryFax"":""""," _
                        & """DeliveryTelephone"":""""," _
                        & """DeliveryVisitingAddress"":""""," _
                        & """AccumulateTurnoverThisYear"":""" & oControls.GetText("visma_turnover_yearnow") & """," _
                        & """AccumulateTurnoverLastYear"":""" & oControls.GetText("visma_turnover_lastyear") & """" _
                        & "" _
                        & "}"
                    
                    Call oXHTTP.Send(JSON)
                    SendToVisma = oXHTTP.responseText
                    Exit Function
                End If
        End If
        Lime.MessageBox ("There is no Object to send to VISMA, If this message appears again contact your system administrator")
        

    
Exit Function
ErrorHandler:
    UI.ShowError ("Visma.SendToVisma")
End Function

Public Function SyncFromVisma(url As String) As String
    On Error GoTo ErrorHandler
        Dim oXHTTP As MSXML2.XMLHTTP60
        Dim VISMA_SYNC_URL As String
        Dim JSON As String
         
        VISMA_SYNC_URL = url
        
        Set oXHTTP = New MSXML2.XMLHTTP60
        
        ' POST, used to start sync
        Call oXHTTP.Open("POST", VISMA_SYNC_URL, False)
        
        ' Content-Type
        Call oXHTTP.setRequestHeader("Content-Type", "application/json")
        Call oXHTTP.setRequestHeader("Accept", "application/json")
                  
        Call oXHTTP.Send(JSON)
        
        Call Application.MessageBox("Migration started...", VBA.vbInformation)
        
        SyncFromVisma = oXHTTP.responseText
    
Exit Function
ErrorHandler:
    UI.ShowError ("Visma.SyncFromVisma")
End Function

