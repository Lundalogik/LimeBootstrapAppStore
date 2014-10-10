//Implement your own favorite credit solution here. 
//Remember to add it to the config and load the script aswell 

var experian ={

    
	/*
    Call your webservice by using a datasource.
    GET DATA -> ratingData = lbs.loader.loadDataSources({}, [{type: 'HTTPGetXml', source: url, alias:'creditdata'}], true);
    SET DATA ->
    viewModel.ratingValue() - The value of the rating.    
    viewModel.ratingtext() - The text seen to the right
    */
	"getRating":function(viewModel, config) {
		    //Show loading view
			viewModel.ratingText('Vennligst vent.');
			viewModel.ratingIcon('<i class="fa fa-spinner fa-spin" ></i>');
			
			//Wait 1 seconds for loading state to appear.
			setTimeout(function(){
			// build SOAP request
                var requestxml =
					'<soap:Envelope ' +
						'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
						'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ' +
						'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" ' +
						'xmlns:inf="https://www.creditinform.no/creditinform.standardwebservice.ws2005207/InfoXML"> ' +
						'<soap:Header>' + 
						'<inf:Header>' + 
						'<inf:UserName>'+ config.experian.customerLoginName + '</inf:UserName>' +
						' <inf:Password>' + config.experian.password + '</inf:Password>' + 
						' <inf:SubUser>'+ config.experian.subuser +'</inf:SubUser> ' + //For example user in LIME
						' <inf:CustomerId>' + config.experian.customerid + '</inf:CustomerId>' + 
						' <inf:Version>?</inf:Version>' +
						' </inf:Header>' + 
						'</soap:Header>' +
						'<soap:Body> ' +
							'<inf:ReportCompany>' + 
							'<inf:objectNr>?</inf:objectNr>' +
							'<inf:fnr>' + config.orgnbr + '</inf:fnr>' +
							'<inf:name>?</inf:name>' +
							'<inf:address>?</inf:address>' +
							'<inf:zipCode>?</inf:zipCode>' +
							'<inf:postalCode>?</inf:postalCode>' + 
							'<inf:additionalInfo></inf:additionalInfo>' +	
							'</inf:ReportCompany>' +
						'</soap:Body> ' +
					'</soap:Envelope>';
                var url = 'https://www.creditinform.biz/CreditInform.StandardWebservice.WS2005207/InfoXML.asmx?wsdl';
                var action = 'https://www.creditinform.no/creditinform.standardwebservice.ws2005207/InfoXML/ReportCompany';			

				ratingData = lbs.loader.loadDataSources({}, [{ type: 'SOAPGetXml', source: { url: url, action: action, xml: requestxml }, alias: 'creditdata'}], true);
				//alert(requestxml);
				//alert(JSON.stringify(ratingData));
				//If error; catch it.
				var errormessage = '';
				var status = ratingData.creditdata['soap:Envelope']['soap:Body']['ReportCompanyResponse']['ReportCompanyResult']['CREDITINFORM']['STATUSINFO']['STATUS'];
				
				//Function for checking if empty.
				function isEmpty(obj) {
					for(var prop in obj) {
						if(obj.hasOwnProperty(prop))
							return false;
					}
					return true;
				}
				
				//Check if empty.
				if (isEmpty(ratingData) == true) {
					errormessage = 'Error: Object was empty.';
				}

				if (ratingData.creditdata['soap:Envelope']['soap:Body']['ReportCompanyResponse']['ReportCompanyResult']['CREDITINFORM']['STATUSINFO']['STATUS'] != '1') {
                    errormessage = 'There was an error occuring when trying to get the credit information.\nStatus: ' + status;
                }
						
				else if (!ratingData.creditdata['soap:Envelope']['soap:Body']['ReportCompanyResponse']['ReportCompanyResult']['CREDITINFORM']['INTERPRETATION_SCORE']) {
					errormessage = 'There were no available data on this company. \nStatus: ' + status;
				}
				
				else if (!ratingData.creditdata['soap:Envelope']['soap:Body']['ReportCompanyResponse']['ReportCompanyResult']['CREDITINFORM']['INTERPRETATION_SCORE']['SCORE']) {
					errormessage = 'There were no available creditdata on this company.\nStatus: ' + status;
				}	
																		
							
                // check if error exists
                if (errormessage != '') {
                    alert(errormessage);
					viewModel.ratingText('Kredittutverdering ikke hentet.');
					viewModel.save();
                }
				else {										
					// no errors update and save :-)					
					var ratingvalue = ratingData.creditdata['soap:Envelope']['soap:Body']['ReportCompanyResponse']['ReportCompanyResult']['CREDITINFORM']['INTERPRETATION_SCORE']['SCORE'];
					viewModel.ratingValue(parseInt(ratingvalue));
				}


				//Set rating text.
				if (viewModel.ratingValue() >= 800) {
					viewModel.ratingText('Good');
				}
				else if (viewModel.ratingValue() <= 790 && viewModel.ratingValue() >= 400) {
					viewModel.ratingText('Medium');
				}
				else if ((viewModel.ratingValue() <= 300 && viewModel.ratingValue() >= 0) || viewModel.ratingValue() === "!") {
					viewModel.ratingText('Bad');
				}
				//An extra save to get the right values saved (the save in app.js saves before this function is done.
				viewModel.save();
                    
				
			}, 100);	
	},
    /*
    Set the colors based on your rating value or rating text. 
    SET DATA ->
    viewModel.ratingIcon() - Icon seen to the left. Can be a number (1-10) or maybe letters (AAA) or maybe a icon (<i class='fa fa-cog'></i>)}
    viewModel.ratingColor() - Color of the rating
        RATING COLORS ->
        "good" - Green
        "medium" - Yellow
        "bad" -Red
    */
    setColor:function(viewModel) {
        			//Experian
                    viewModel.ratingIcon(viewModel.ratingValue());
                    if (viewModel.ratingValue() >= 800) {
                        viewModel.ratingColor("good");
                    }
                    else if (viewModel.ratingValue() <= 790 && viewModel.ratingValue() >= 400) {
                        viewModel.ratingColor("medium");
                    }
                    else if ((viewModel.ratingValue() <= 390 && viewModel.ratingValue() >= 0) || viewModel.ratingValue() === "!") {
                        viewModel.ratingColor("bad");
                    }			

    }
}