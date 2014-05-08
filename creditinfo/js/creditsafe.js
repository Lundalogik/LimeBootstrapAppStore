var creditsafe ={
	
	"getRating":function(viewModel, config) {
         // build SOAP request
        var requestxml =
            '<soap:Envelope ' +
                'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
                'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ' +
                'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"> ' +
                '<soap:Body> ' +
                    '<CasCompanyService xmlns="https://webservice.creditsafe.se/CAS/"> ' +
                        '<cas_company> ' +
                            '<account> ' +
                                '<UserName>' + config.creditsafe.customerLoginName + '</UserName> ' +
                                '<Password>' + config.creditsafe.password + '</Password> ' +
                                '<TransactionId></TransactionId> ' +
                                '<Language>' + config.creditsafe.language + '</Language> ' +
                            '</account> ' +
                            '<SearchNumber>' + config.orgnbr + '</SearchNumber> ' +
                            '<Templates>' + config.creditsafe.packageName + '</Templates> ' +
                        '</cas_company> ' +
                    '</CasCompanyService> ' +
                '</soap:Body> ' +
            '</soap:Envelope>';
        var url = 'http://webservice.creditsafe.se/CAS/cas_service.asmx';
        var action = 'https://webservice.creditsafe.se/CAS/CasCompanyService';
        //alert(requestxml);
        ratingData = lbs.loader.loadDataSources({}, [{ type: 'SOAPGetXml', source: { url: url, action: action, xml: requestxml }, alias: 'creditdata'}], true);

        var errormessage = '';
        //alert(JSON.stringify(ratingData));
        if (JSON.stringify(ratingData.creditdata['soap:Envelope']['soap:Body'].CasCompanyServiceResponse.CasCompanyServiceResult.ErrorList) == 'null') {

            errormessage = '';
        } else {
            var error = ratingData.creditdata['soap:Envelope']['soap:Body'].CasCompanyServiceResponse.CasCompanyServiceResult.ErrorList.ERROR;

            if (error.length > 0) {
                // array of error string
                for (var i = 0; i < error.length; i++) {
                    if (isNaN(JSON.stringify(error[i].Cause_of_Reject)) == false) {
                        errormessage = errormessage + '\n' + JSON.stringify(error[i].Reject_text);
                    }
                }
            } else {
                // error string
                if (isNaN(JSON.stringify(error.Cause_of_Reject)) == false) {
                    errormessage = JSON.stringify(error.Reject_text);
                }
            }
        }
        // check if error exists
        if (errormessage != '') {
            alert(errormessage);
        } else {
            // no errors update and save :-)
            ratingData = ratingData.creditdata['soap:Envelope']['soap:Body'].CasCompanyServiceResponse.CasCompanyServiceResult;
            viewModel.ratingValue(ratingData.Status);
            viewModel.ratingText(ratingData.Status_Text)
        }
		
	},

    setColor:function(viewModel) {
        switch (viewModel.ratingValue()) {
            case '1':
                viewModel.ratingIcon("<i class='fa fa-thumbs-o-up'></i>"); //(ratingData.Status)
                viewModel.ratingColor("good");
                break;
            case '2':
                viewModel.ratingIcon("<i class='fa fa-thumbs-o-down'></i>"); //(ratingData.Status)
                viewModel.ratingColor("bad");
                break;
            case '4':
                viewModel.ratingIcon("<i class='fa fa-search'></i>"); //(ratingData.Status)
                viewModel.ratingColor("medium");
                break;
            default:
                viewModel.ratingIcon("<i class='fa fa-question'></i>"); //(ratingData.Status)
                viewModel.ratingColor("bad");
                break;
        }
    }


}