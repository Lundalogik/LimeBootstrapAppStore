lbs.apploader.register('CreateCustomerBFUS', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig) {
            this.dataSources = [
                {type: 'activeInspector', source: '', alias: 'rec'}
            ];
            this.resources = {
                scripts: [], // <= External libs for your apps. Must be a file
                styles: ['app.css'], // <= Load styling for the app.
                libs: [] // <= Allready included libs, put not loaded per default. Example json2xml.js
            };

            this.baseURI = appConfig.baseURI;
            this.ewiKey = appConfig.ewiKey;
            this.crossDomainCall = appConfig.crossDomainCall;
            this.fieldMappings = appConfig.fieldMappings;
    };

    //initialize
    /*Initialize
        Initialize happens after the data and recources are loaded but before the view is rendered.
        Here it is your job to implement the logic of your app, by attaching data and functions to 'viewModel' and then returning it
        The data you requested along with localization are delivered in the variable viewModel.
        You may make any modifications you please to it or replace is with a entirely new one before returning it.
        The returned viewModel will be used to build your app.
        
        Node is a reference to the HTML-node where the app is being initalized form. Frankly we do not know when you'll ever need it,
        but, well, here you have it.
    */
    self.initialize = function (node, viewModel) {
        
        self.resourceURI = '';
        self.suppressPinCodeWarning = false;
        self.suppressAddressWarning = false;
        self.lastWarning = '';

        self.BFUSWarnings = {};
        self.BFUSWarnings.warningPinCode = 'Error.Customer.CustomerWithPinCodeAlreadyExists';
        self.BFUSWarnings.warningCompanyCode = 'Error.Customer.CustomerWithCompanyCodeAlreadyExists';
        self.BFUSWarnings.warningAddress = 'Error.Customer.##TODO';

        viewModel.warningText = ko.observable('');
        viewModel.isAlreadyInBFUS = ko.observable(false);   //##TODO: Ska gå på rec.xxxx
        viewModel.UIErrorText = ko.observable('');

        viewModel.isRecordSaved = ko.computed(function() {
            return lbs.common.executeVba('app_CreateCustomerBFUS.isRecordSaved,' + lbs.activeInspector.ID);
        }, this);

        viewModel.isEligibleForSendingToBFUS = ko.computed(function() {
            if (self.config.eligibleForBFUSSending !== undefined) {
                return lbs.common.executeVba('app_CreateCustomerBFUS.isEligibleForSendingToBFUS,' + lbs.activeInspector.ID + ','
                                                + self.config.eligibleForBFUSSending.limeField, + ','
                                                + self.config.eligibleForBFUSSending.validIdstrings);
            }
            else {
                return true;
            }
        }, this);

        //Enable cross domain calls if needed.
        $.support.cors = self.config.crossDomainCall;

        /**
            Returns a customer object to send when creating a new customer in BFUS.
        */
        function createCustomerJSON () {
            var c = this;
            var exp = '';
            
            c.Header = {};
            c.Header.ExternalId = lbs.activeInspector.Record.ID;
            c.Header.SuppressPinCodeWarning = self.suppressPinCodeWarning;
            c.Header.SuppressAddressWarning = self.suppressAddressWarning;
            
            c.Customer = {};
            c.Customer.IsProtectedIdentity = false;
            exp = exp + 'c.Customer.FirstName = viewModel.rec.' + self.config.fieldMappings.FirstName + '.text;\n';
            exp = exp + 'c.Customer.LastName = viewModel.rec.' + self.config.fieldMappings.LastName + '.text;\n';
            exp = exp + 'c.Customer.IsBusinessCustomer = (viewModel.rec.' + self.config.fieldMappings.IsBusinessCustomer + '.value === ' + self.config.fieldMappings.IsBusinessCustomerLIMEOptionId + ');\n';       //##TODO: gör till boolean
            exp = exp + 'c.Customer.PinCode = viewModel.rec.' + self.config.fieldMappings.PinCode + '.text;\n';
            exp = exp + 'c.Customer.CompanyCode = viewModel.rec.' + self.config.fieldMappings.CompanyCode + '.text;\n';
            
            c.Customer.EmailInformation = {};
            exp = exp + 'c.Customer.EmailInformation.AcceptEMail = viewModel.rec.' + self.config.fieldMappings.AcceptEMail + '.text;\n';
            if (self.config.fieldMappings.Email1 !== '') {
                exp = exp + 'c.Customer.EmailInformation.EMail1 = viewModel.rec.' + self.config.fieldMappings.EMail1 + '.text;\n';
            }
            if (self.config.fieldMappings.Email2 !== '') {
                exp = exp + 'c.Customer.EmailInformation.EMail2 = viewModel.rec.' + self.config.fieldMappings.EMail2 + '.text;\n';
            }
            if (self.config.fieldMappings.Email3 !== '') {
                exp = exp + 'c.Customer.EmailInformation.EMail3 = viewModel.rec.' + self.config.fieldMappings.EMail3 + '.text;\n';
            }
            
            c.Customer.SMSInformation = {};
            exp = exp + 'c.Customer.SMSInformation.AcceptSMS = viewModel.rec.' + self.config.fieldMappings.AcceptSMS + '.text;\n';
            
            c.Customer.Phones = [];
            $.each(self.config.fieldMappings.Phones, function (index, obj) {
                exp = exp + 'c.Customer.Phones.push({'
                exp = exp + 'PhoneTypeId : ' + obj.PhoneTypeId + ','
                exp = exp + 'Number : viewModel.rec.' + obj.Number + '.text,'
                exp = exp + '});'
            });
            
            c.Customer.Addresses = [];
            $.each(self.config.fieldMappings.Addresses, function (index, obj) {
                exp = exp + 'c.Customer.Addresses.push({'
                exp = exp + 'AddressTypeId : ' + obj.AddressTypeId + ','
                exp = exp + 'StreetName : viewModel.rec.' + obj.StreetName + '.text,'
                exp = exp + 'StreetQualifier : viewModel.rec.' + obj.StreetQualifier + '.text,'
                exp = exp + 'StreetNumberSuffix : viewModel.rec.' + obj.StreetNumberSuffix + '.text,'
                exp = exp + 'PostOfficeCode : viewModel.rec.' + obj.PostOfficeCode + '.text,'
                exp = exp + 'City : viewModel.rec.' + obj.City + '.text,'
                exp = exp + 'CountryCode : viewModel.rec.' + obj.CountryCode + '.text,'
                exp = exp + 'ApartmentNumber : viewModel.rec.' + obj.ApartmentNumber + '.text,'
                exp = exp + 'FloorNumber : viewModel.rec.' + obj.FloorNumber + '.text,'
                exp = exp + '});'
            });
            
            // Add all properties
            eval(exp);
            
            return c;
        }

        /**
            Returns a customer object to send when creating a new customer in BFUS.
        */
        function updateCustomerJSON () {
            var c = this;
            var exp = '';
            
            c.Header = {};
            c.Header.ExternalId = lbs.activeInspector.Record.ID;
            // c.Header.SuppressPinCodeWarning = self.suppressPinCodeWarning;
            c.Header.SuppressAddressWarning = self.suppressAddressWarning;

            //##TODO!

            // Add all properties
            eval(exp);

            return c;
        }

        function toggleLoader(showLoader) {
            toggleInfo(false);
            toggleError(false);
            if (showLoader) {
                $('div#loading').slideDown();
            }
            else {
                $('div#loading').slideUp();
            }
        }

        function toggleInfo(showInfo) {
            if (showInfo) {
                $('div#info').slideDown();
            }
            else {
                $('div#info').slideUp();
            }
        }

        function toggleWarning(showWarning) {
            if (showWarning) {
                $('div#warning').slideDown();
            }
            else {
                $('div#warning').slideUp();
            }
            $('button#createupdatebutton').prop('disabled', showWarning);
        }

        function toggleError(showError) {
            if (showError) {
                $('div#error').slideDown();
            }
            else {
                $('div#error').slideUp();
            }
        }

        /**
            Called when clicking on the create/update button.
        */
        viewModel.createOrUpdate = function() {
            
            if (!viewModel.isRecordSaved()) {
                treatError('', viewModel.localize.app_CreateCustomerBFUS.e_recordNotSaved);
                return;
            }
            toggleLoader(true);
            if (viewModel.isAlreadyInBFUS()) {
                self.resourceURI = 'Common/Customer/UpdateCustomer_v1';
                // viewModel.customerData = new updateCustomerJSON();   //##TODO: Implementera updateCustomer.
            }
            else {
                self.resourceURI = 'Common/Customer/CreateCustomer_v1';
                viewModel.customerData = new createCustomerJSON();
            }
            window.setTimeout(function() {sendToBFUS()}, 500);
        }

        sendToBFUS = function() {
            
            //alert(JSON.stringify(self.config));
            
            //##TODO: Loader hinner inte renderas innan anropet är klart om success...
            
            var json = 
                      "{" +
                        "Header: {" +
                          "'ExternalId':'FER_TESTAR'," +
                          "'SuppressPinCodeWarning':false," +
                          "'SuppressAdressWarning':true " +
                        "},"+
                        "Customer: {" +
                          "'IsProtectedIdentity':false," +
                          "'FirstName':'Kalle'," +
                          "'LastName':'Anka'," +
                          "'IsBusinessCustomer':false," +     // IsBusinessCustomer = false => PinCode (personal-code) must be set .
                          "'PinCode':'19-760619-4657'," +     // PinCode (Personal-code)
                          "'CompanyCode':null," +             // IsBusinessCustomer = true => CompanyCode must be set.
                          "EmailInformation: {" +
                            "'AcceptEMail':true," +
                            "'EMail1':'test@hotmail.com'," +
                            "'EMail2':'test2@hotmail.com'," +
                            "'EMail3':'test3@hotmail.com'" +
                          "},"+
                          "SMSInformation: {" +
                              "'AcceptSMS':false" +
                          "}," +
                          "Phones: [{" +
                            "'PhoneTypeId':'10980200'," +
                            "'Number':'070-5566778'" +
                          "}]," +
                          "Addresses:[{" +
                            "'AddressTypeId':'10090000',"+    // At least one postal adress!
                            "'StreetName':'Roskildevej',"+      
                            "'StreetQualifier':'38',"+       
                            "'StreetNumberSuffix':'C',"+    
                            "'PostOfficeCode':'2000',"+
                            "'City':'Frederiksberg',"+
                            "'CountryCode':'DK',"+            // If null => default will be 'SE' 
                            "'ApartmentNumber':'2',"+
                            "'FloorNumber':'3'" +
                          "}],"+
                        "}," +
                      "}";
            
            $.ajax({
                type: "POST",
                url: self.config.baseURI + self.resourceURI,
                data: json,     //JSON.stringify(viewModel.customerData),
                contentType: "application/json",        //; charset=utf-8",
                headers: {
                    'Authorization' : 'Basic ' + self.config.ewiKey,
                    'Accept-Language' : 'sv-SE'
                },
                success: function(data) {

                    // Check if warning for existing pin code
                    if (data !== undefined) {
                        if (data.Header !== undefined) {
                            if (data.Header.ErrorInformation !== null) {
                                var errorCode = data.Header.ErrorInformation.ErrorCode;
                                var msg = errorCode + '.   Complete JSON: ' + JSON.stringify(data);

                                // Take care of warnings.
                                if (errorCode === self.BFUSWarnings.warningPinCode
                                        || errorCode === self.BFUSWarnings.warningCompanyCode
                                        || errorCode === self.BFUSWarnings.warningAddress) {
// alert('warning');
                                    
                                    lbs.log.logToInfolog('warning', msg);
                                    self.lastWarning = data.Header.ErrorInformation.ErrorCode;
                                    
                                    if (errorCode === self.BFUSWarnings.warningPinCode) {
                                        viewModel.warningText(viewModel.localize.app_CreateCustomerBFUS.warningTextPinCode);
                                    }
                                    else if (errorCode === self.BFUSWarnings.warningCompanyCode) {
                                        viewModel.warningText(viewModel.localize.app_CreateCustomerBFUS.warningTextCompanyCode);
                                    }
                                    else if (data.Header.ErrorInformation.ErrorCode === self.BFUSWarnings.warningAddress) {
                                        if (viewModel.isAlreadyInBFUS()) {
                                            viewModel.warningText(viewModel.localize.app_CreateCustomerBFUS.warningTextAddressUpdate);
                                        }
                                        else {
                                            viewModel.warningText(viewModel.localize.app_CreateCustomerBFUS.warningTextAddressCreate);
                                        }
                                    }
                                    toggleLoader(false);
                                    toggleWarning(true);
                                }
                                // Not a warning but an actual error.
                                else {
                                    treatErrorResponse(msg);
                                }
                            }
                            else    //Customer created or updated in BFUS
                            {
                                toggleLoader(false);
                                toggleInfo(true);
                                viewModel.isAlreadyInBFUS(true);
                                lbs.common.executeVba('app_CreateCustomerBFUS.saveBFUSResponseData,' 
                                                        + lbs.activeInspector.ID + ',' 
                                                        + self.config.fieldMappings.CustomerId + ',' 
                                                        + data.Content.CustomerId + ',' 
                                                        + self.config.fieldMappings.CustomerCode + ',' 
                                                        + data.Content.CustomerCode);
                                window.setTimeout(function() {
                                        toggleInfo(false);
                                    }, 3000);
                            }
                        }
                    }
                },
                error: function(errMsg) {
                    treatError(JSON.stringify(errMsg), viewModel.localize.app_CreateCustomerBFUS.e_couldNotSend);
                }
            });
        }

        /**
            Called when clicking on the yes button that appears when a warning was returned from BFUS.
        */
        viewModel.warningYes = function() {
            
            if (self.lastWarning === self.BFUSWarnings.warningPinCode || self.lastWarning === self.BFUSWarnings.warningCompanyCode) {
                self.suppressPinCodeWarning = true;
            }
            else if (self.lastWarning === self.BFUSWarnings.warningAddress) {
                self.suppressAddressWarning = true;
            }
            toggleWarning(false);
            viewModel.createOrUpdate();
        }

        /**
            Called when clicking on the no button that appears when a warning was returned from BFUS.
        */
        viewModel.warningNo = function() {
            toggleWarning(false);
        }

        treatError = function(logMsg, UIMsg) {
            if (logMsg !== '') {
                lbs.log.logToInfolog('error', logMsg);
            }
            toggleLoader(false);
            viewModel.UIErrorText(UIMsg);
            toggleError(true);
            window.setTimeout(function() {
                    toggleError(false);
                }, 3000);
        }


        //Success-svar:
        // {"Header":{"ErrorInformation":null,"ObjectVersion":2,"Success":true,"PerformanceTime":"00:00:08.8608000","InParameters":null},"Content":{"CustomerId":1033974840,"CustomerCode":"281"}}
        //Kund-id är den ”interna identifikationen för kund medan kundnummret är den ”synliga” nummerkoden

        return viewModel;
    };
});
