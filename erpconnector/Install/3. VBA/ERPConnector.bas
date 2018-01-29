Attribute VB_Name = "ERPConnector"
Public Function CheckValidate() As Boolean
On Error GoTo ErrorHandler
    Dim oInspector As Lime.Inspector
    Dim companyName As String
    
    Set oInspector = ActiveInspector
    
    If oInspector.Class.Name = "company" Then
        If Len(oInspector.Controls.GetText("name")) > 3 Then
            If Len(oInspector.Controls.GetText("phone")) < 20 Then
                If Len(oInspector.Controls.GetText("postalzipcode")) < 12 Then
                    oInspector.Save
                    CheckValidate = True
                    Exit Function
                Else
                    Lime.MessageBox (Localize.GetText("ERPConnector", "e_toolong_zip"))
                    CheckValidate = False
                End If
            Else
                Lime.MessageBox (Localize.GetText("ERPConnector", "e_toolong_phoneno"))
                CheckValidate = False
            End If
        Else
            Lime.MessageBox (Localize.GetText("ERPConnector", "e_tooshort_company"))
            CheckValidate = False
        End If
    Else
    Lime.MessageBox (Localize.GetText("ERPConnector", "e_companyonly"))
    CheckValidate = False
    End If
    
Exit Function
ErrorHandler:
    UI.ShowError ("ERPConnector.CheckValidate")
End Function


Public Function SendToERP(url As String, newCompany As Boolean) As String
    On Error GoTo ErrorHandler
    Dim oXHTTP As MSXML2.XMLHTTP60
    Dim str1 As String
    Dim str2 As String
    Dim str3 As String
    Dim str4 As String
    Dim str5 As String
    Dim str6 As String
    Dim JSON As String
    Dim ERP_URL As String
    Dim sArray() As String
    Dim oInspector As Lime.Inspector
    Set oInspector = ActiveInspector
    Set oControls = oInspector.Controls
     
        'Check that we have an inspector and that it is a company
        If Not oInspector Is Nothing Then
                
                'Array with all values from html (see app.js for more information)
                'sArray = VBA.Split(Object, ";")
                ERP_URL = url 'sArray(0)
                
                Set oXHTTP = New MSXML2.XMLHTTP60
                
                If newCompany = True Then
                    ' POST, used to new companies
                    Call oXHTTP.Open("POST", ERP_URL, False)
                    
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
                        & """Telephone"":""" & oControls.GetText("phone") & """," _
                        & """Reference"":""""," _
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
                    SendToERP = oXHTTP.responseText
                    Exit Function
                Else
                    ' PUT used to update companies in VISMA
                    Call oXHTTP.Open("PUT", ERP_URL, False)
                    
                    ' Content-Type
                    Call oXHTTP.setRequestHeader("Content-Type", "application/json")
                    Call oXHTTP.setRequestHeader("Accept", "application/json")
                              
                    ' JSON to update company information in VISMA. This is sent to VISMA API
                    ' Create substrings to not exceed line continuation in VBA
                        
                   JSON = "{" _
                        & """Number"":""" & oControls.GetText("erpid") & """," _
                        & """Name"":""" & oControls.GetText("name") & """," _
                        & """OrganisationNumber"":""" & oControls.GetText("registrationno") & """," _
                        & """Address1"":""" & oControls.GetText("postaladdress1") & """," _
                        & """Address2"":""" & oControls.GetText("postaladdress2") & """," _
                        & """Zipcode"":""" & oControls.GetText("postalzipcode") & """," _
                        & """City"":""" & oControls.GetText("postalcity") & """," _
                        & """Country"":""" & oControls.GetText("country") & """," _
                        & """Telephone"":""" & oControls.GetText("phone") & """," _
                        & """Reference"":""""," _
                        & """DeliveryName"":""" & oControls.GetText("name") & """," _
                        & """DeliveryAddress"":""" & oControls.GetText("visitingaddress1") & """," _
                        & """DeliveryAddress2"":""" & oControls.GetText("visitingaddress2") & """," _
                        & """DeliveryZipcode"":""" & oControls.GetText("visitingzipcode") & """," _
                        & """DeliveryCity"":""" & oControls.GetText("visitingcity") & """," _
                        & """DeliveryCountry"":""" & oControls.GetText("country") & """," _
                        & """DeliveryFax"":""""," _
                        & """DeliveryTelephone"":""""," _
                        & """DeliveryVisitingAddress"":""""," _
                        & """AccumulateTurnoverThisYear"":""" & oControls.GetText("erp_turnover_yearnow") & """," _
                        & """AccumulateTurnoverLastYear"":""" & oControls.GetText("erp_turnover_lastyear") & """" _
                        & "" _
                        & "}"
                    
                    Call oXHTTP.Send(JSON)
                    SendToERP = oXHTTP.responseText
                    Exit Function
                End If
        End If
        Lime.MessageBox ("There is no company to send to ERP. If this message appears again contact your system administrator")
        

    
Exit Function
ErrorHandler:
    UI.ShowError ("ERPConnector.SendToERP")
End Function

Public Function SyncFromERP(url As String) As String
    On Error GoTo ErrorHandler
        Dim oXHTTP As MSXML2.XMLHTTP60
        Dim ERP_SYNC_URL As String
        Dim JSON As String
         
        ERP_SYNC_URL = url
        
        Set oXHTTP = New MSXML2.XMLHTTP60
        
        ' POST, used to start sync
        Call oXHTTP.Open("POST", ERP_SYNC_URL, False)
        
        ' Content-Type
        Call oXHTTP.setRequestHeader("Content-Type", "application/json")
        Call oXHTTP.setRequestHeader("Accept", "application/json")
                  
        Call oXHTTP.Send(JSON)
        
        Call Application.MessageBox("Migration started...", VBA.vbInformation)
        
        SyncFromERP = oXHTTP.responseText
    
Exit Function
ErrorHandler:
    UI.ShowError ("ERPConnector.SyncFromERP")
End Function


Public Function GetInvoiceData() As LDE.Records
    On Error GoTo ErrorHandler
    Dim oView As New LDE.View
    Dim oFilter As New LDE.Filter
    Dim oRecords As New LDE.Records
    Call oFilter.AddCondition("company", lkOpEqual, ActiveControls.Record.ID)
    Call oFilter.AddCondition("paid", lkOpEqual, 1)
    Call oFilter.AddOperator(lkOpAnd)
    
    Call oView.Add("invoice_total_sum")
    Call oView.Add("paid_date", lkSortDescending)
    
    Call oRecords.Open(Database.Classes("invoice"), oFilter, oView)
    Set GetInvoiceData = oRecords
    Exit Function
ErrorHandler:
    Call UI.ShowError("ERPConnector.GetInvoiceData")
End Function
