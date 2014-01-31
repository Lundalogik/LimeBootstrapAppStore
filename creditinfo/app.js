lbs.apploader.register('creditinfo', function() {
    var self = this;

    //config
    self.config = {
        orgnbr: "",
        onlyAllowPublicCompanies: true,
        maxAge: 365,
        dataSources: [
            { type: 'activeInspector', alias: 'activeInspector' }
        ],
        resources: {
            scripts: [],
            styles: ['app.css'],
            libs: ['json2xml.js']
        },
        businessCheck: {
            customerLoginName: "",
            userLoginName: "",
            password: "",
            packageName: ""
        },
        soliditet: {
            customerLoginName: "",
            password: "",
            packageName: ""
        },
        creditsafe: {
            customerLoginName: "",
            password: "",
            packageName: "",
            language: ""
        }
    },


    //initialize
    this.initialize = function(node, viewModel) {
        var me = this;

        //Rating data
        viewModel.ratingValue = ko.observable("");
        viewModel.ratingText = ko.observable("");
        viewModel.ratingDate = ko.observable("");
        viewModel.ratingIcon = ko.observable("");

        //GUI props
        viewModel.icon = ko.observable("fa fa-angle-double-down"); //Icon in the handle
        viewModel.loadText = ko.observable("Hämta rating"); // Text in the handle
        viewModel.ratingColor = ko.observable(""); //Color of the rating-app, dependent on the rating (Red, Yellow or Green)
        viewModel.loading = ko.observable(false); //Active while loading

        //Is there exisisting data?
        var existingData;
        loadExistingData();

        /*
        ---------------Bindings---------------
        */
        //Get the rating from webservice
        viewModel.getRating = function() {
            //Refresh the data from the inspector to check if a unsaved registration number exists.
            loadingTimer();

            viewModel.activeInspector = lbs.loader.loadDataSources({}, [{ type: 'activeInspector', alias: 'activeInspector'}]).activeInspector;
            self.config.orgnbr = viewModel.activeInspector.registrationno.text

            //Let's check the company has a registration number
            if (!isPublicCompany(self.config.orgnbr)) {
                if (self.config.onlyAllowPublicCompanies) {
                    alert("App app app! Du får bara ta kreditkontroll på Aktiebolag!") //TODO: Localize
                    return;
                } else {
                    var proceed = confirm("Det kommer skickas ut en omfrågekopia. Vill du fortsätta?") //TODO: Localize
                    if (!proceed) {
                        return;
                    }
                }
            }

            // => If we have made it this far we are good to go for performing the check
            var ratingData = {};

            //BusinessCheck Rating
            if (self.config.businessCheck.customerLoginName !== "") {
                var url = "https://www.businesscheck.se/service/dataimport2.asmx/DataImport2Company?CustomerLoginName=" + self.config.businessCheck.customerLoginName + "&UserLoginName=" + self.config.businessCheck.userLoginName + "&Password=" + self.config.businessCheck.password + "&Language=sv&PackageName=" + self.config.businessCheck.packageName + "&OrganizationNumber=" + self.config.orgnbr
                ratingData = lbs.loader.loadDataSources({}, [{ type: 'HTTPGetXml', source: url, alias: 'creditdata'}], true);
                //Check if everything is ok
                if (ratingData.creditdata.DataImport2Result.Error) {
                    alert('Error from BusinessCheck:' + ratingData.creditdata.DataImport2Result.Error.ErrorMessage);
                } else {
                    ratingData = ratingData.creditdata.DataImport2Result.Blocks.Block.Fields.Field //Shitty XML makes Jack a dull boy!
                    // Rating can be 0 to 10. If rating < 0 a "!" is shown
                    if (ratingData[0].Value >= 0) {
                        viewModel.ratingValue(ratingData[0].Value)
                    } else {
                        viewModel.ratingValue("!")
                    }
                    viewModel.ratingText(ratingData[1].Value)
                }
            }

            //ToDo: Soliditet rating
            else if (self.config.soliditet.customerLoginName !== "") {

            }
            else if (self.config.creditsafe.customerLoginName !== "") {

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
										'<UserName>' + self.config.creditsafe.customerLoginName + '</UserName> ' +
										'<Password>' + self.config.creditsafe.password + '</Password> ' +
										'<TransactionId></TransactionId> ' +
										'<Language>' + self.config.creditsafe.language + '</Language> ' +
									'</account> ' +
									'<SearchNumber>' + self.config.orgnbr + '</SearchNumber> ' +
									'<Templates>' + self.config.creditsafe.packageName + '</Templates> ' +
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
                    viewModel.ratingDate(moment().format("YYYY-MM-DD HH:mm:ss"));
                    save();
                }
            }

            /* Implement your own favorite credit solution here. Remember to add it to the config aswell: 
                          
            else if (self.config.[Your service here].customerLoginName !== ""){
            GET DATA -> ratingData = lbs.loader.loadDataSources({}, [{type: 'HTTPGetXml', source: url, alias:'creditdata'}], true);

               SET DATA ->
            viewModel.ratingValue() - The value seen to the left. Can be a number (1-10) or maybe letters (AAA) or maybe a icon (<i class='fa fa-cog'></i>)
            }   viewModel.ratingtext() - The text seen to the right
            */

            viewModel.ratingDate(moment().format("YYYY-MM-DD HH:mm:ss"));
            save();

        }

        //Set the colors based on your rating value
        viewModel.setColor = ko.computed(function() {
            if (viewModel.ratingValue() && !viewModel.loading()) {
                if (self.config.businessCheck.customerLoginName !== "") {
                    viewModel.ratingIcon(viewModel.ratingValue());
                    if (viewModel.ratingValue() >= 8) {
                        viewModel.ratingColor("good");
                    }
                    else if (viewModel.ratingValue() <= 7 && viewModel.ratingValue() >= 4) {
                        viewModel.ratingColor("medium");
                    }
                    else if ((viewModel.ratingValue() <= 3 && viewModel.ratingValue() >= 0) || viewModel.ratingValue() === "!") {
                        viewModel.ratingColor("bad");
                    }
                }
                //ToDo: Soliditet rating
                else if (self.config.soliditet.customerLoginName !== "") {

                }
                else if (self.config.creditsafe.customerLoginName !== "") {

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
            /* Implement your own favorite credit solution here. Remember to add it to the config aswell: 
            
            Set the colors based on your rating value or rating text. 
            RATING COLORS ->
            "Good" - Green
            "medium" - Yellow
            "bad" - red
            example:
            else if (self.config.[Your service here].customerLoginName !== ""){
            if (viewModel.ratingText() === 'Godkänd' )  { 
            viewModel.ratingColor("good");
            } 
            else if (viewModel.ratingText() ==='Sådär' ){
            viewModel.ratingColor("medium"); 
            }
            */

        });

        viewModel.showRating = ko.computed(function() {
            if (viewModel.ratingValue()) {
                if (existingData) {
                    $(".creditinfo").css('margin-top', '-10px');
                    $(".handle").css('margin-top', '-30px');
                } else {
                    setTimeout(function() {
                        $(".creditinfo").animate({ 'margin-top': '-10px' }, "slow");
                    }, 1000
                    );
                }
            }

        });

        //Rating is fading with age.
        viewModel.age = ko.computed(function() {
            if (viewModel.ratingDate()) {
                var age = moment().diff(viewModel.ratingDate(), 'days');
                return (1.2 - age / self.config.maxAge).toString();
            } else {
                return '1';
            }
        });

        //Text for the handel while loading data
        viewModel.showLoadText = ko.computed(function() {
            if (viewModel.loading()) {
                viewModel.loadText("Laddar");
            } else {
                if (viewModel.ratingValue()) {
                    viewModel.loadText("Uppdatera");
                } else {
                    viewModel.loadText("Hämta rating");
                }
            }
        });

        //Shows spinning icon when loading
        viewModel.loadIcon = ko.computed(function() {
            if (viewModel.loading()) {
                viewModel.icon('fa fa-spinner fa-spin');
            } else {
                if (viewModel.ratingValue()) {
                    viewModel.icon('fa fa-refresh');
                } else {
                    viewModel.icon("fa fa-angle-double-down");
                }
            }
        });

        viewModel.relDate = ko.computed(function() {
            if (viewModel.ratingDate()) {
                return moment(viewModel.ratingDate()).fromNow();
            } else {
                return "";
            }
        });

        /*

            ---------------UI haxs--------------
        */

        //Knockout hover is a bit quirky, so using jQuery here
        $(".creditinfo").hover(function() {
            if (viewModel.ratingValue()) {
                $(".rating-date").fadeIn();
                $(".handle").stop().animate({ 'margin-top': '-0px' }, "slow");
            }
        }, function() {
            if (viewModel.ratingValue() !== "") {
                $(".rating-date").stop().fadeOut();
                $(".handle").stop().animate({ 'margin-top': '-30px' }, "slow");
            }

        });

        /*
        ---------------Helper functions---------------
        */

        //Loads data from the field 'creditinfo' from the active inspector 
        function loadExistingData() {
            existingData = lbs.limeDataConnection.ActiveInspector.Controls.GetValue('creditinfo')
            if (existingData) {
                existingData = lbs.loader.xmlToJSON(existingData, 'creditdata');
            }
            if (existingData) {
                if (moment().diff(existingData.creditdata.ratingData.ratingDate, 'days') < self.config.maxAge) {
                    viewModel.ratingValue(existingData.creditdata.ratingData.ratingValue);
                    viewModel.ratingText(existingData.creditdata.ratingData.ratingText);
                    viewModel.ratingDate(existingData.creditdata.ratingData.ratingDate);

                }
            }
        }

        function loadingTimer() {
            viewModel.loading(true);
            setTimeout(function() {
                viewModel.loading(false);
            }, 1000);

        }

        // Credit check is only allowed on public companies. This can be determined by the registration number.
        function isPublicCompany(regNbr) {
            var isPublic = false;

            if (regNbr.length > 9) {
                //5 is equal to a Aktiebolag (this should always be true, but there are exeptions)
                if (regNbr.charAt(0) === '5') {

                    //The third and forth char should form a number larger than 20
                    var controlNbr = parseInt(regNbr.charAt(2) + regNbr.charAt(3))
                    if (controlNbr > 20) {
                        isPublic = true;
                    }
                }
            }
            return isPublic;
        }

        //Converts rating value, text and date to XML and saves in creditinfo-field in LIME
        function save() {
            var ratingData = {};
            ratingData.ratingValue = viewModel.ratingValue();
            ratingData.ratingText = viewModel.ratingText();
            ratingData.ratingDate = viewModel.ratingDate();
            ratingData = "<ratingData>" + json2xml($.parseJSON(JSON.stringify(ratingData)), '') + "</ratingData>";
            lbs.limeDataConnection.ActiveInspector.Controls.SetValue('creditinfo', ratingData);
        }


        return viewModel;
    }
});