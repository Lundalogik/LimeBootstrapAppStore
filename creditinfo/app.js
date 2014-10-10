lbs.apploader.register('creditinfo', function() {
    var self = this;

    //config
    self.config = {
        orgnbr: "",
        onlyAllowPublicCompanies: true,
        maxAge: 365,
        inline: true,
		country: "swe",
		showInField: false,
        dataSources: [

        ],
        resources: {
            scripts: ['js/businesscheck.js', 'js/creditsafe.js' , 'js/experian.js'],
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
        },
		experian: {
            customerLoginName: "",
			subuser: "",
            password: "",
            packageName: "",
            language: "",
			customerid: ""
        }
    },


    //initialize
    this.initialize = function(node, viewModel) {
        var me = this;
         viewModel.loading = ko.observable(false); //Active while loading
        //Rating data
        viewModel.ratingValue = ko.observable("");
        viewModel.ratingText = ko.observable("");
        viewModel.ratingDate = ko.observable("");
        viewModel.ratingIcon = ko.observable("");

        //GUI props
        viewModel.icon = ko.observable("fa fa-angle-double-down"); //Icon in the handle
        viewModel.loadText = ko.observable("Hämta rating"); // Text in the handle
        viewModel.ratingColor = ko.observable(""); //Color of the rating-app, dependent on the rating (Red, Yellow or Green)
        viewModel.inline = self.config.inline;

        //Is there exisisting data?
        var existingData;
        loadExistingData();

        /*
        ---------------Bindings---------------
        */
        //Get the rating from webservice
        viewModel.getRating = function() {
            //Refresh the data from the inspector to check if a unsaved registration number exists.
            if(!viewModel.inline){
                loadingTimer();
            }
			
            viewModel.activeInspector = lbs.loader.loadDataSources({}, [{ type: 'activeInspector', alias: 'activeInspector'}]).activeInspector;
            self.config.orgnbr = viewModel.activeInspector.registrationno.text

            //Let's check the company has a registration number
			if (self.config.country == 'swe') {
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
			}
			else if (self.config.country == 'nor') {
				if (!isPublicCompanyNorway(self.config.orgnbr)) {
					if (self.config.onlyAllowPublicCompanies) {
						alert("Du kan bare ta kredittsjekk på Aksjeselskap!") //TODO: Localize
						return;
					} else {
						var proceed = confirm("Det vil sende ut en omfrågekopia. Ønsker du å fortsette?") //TODO: Localize
						if (!proceed) {
							return;
						}
					}
				}
			}
            // => If we have made it this far we are good to go for performing the check
            var ratingData = {};

            //BusinessCheck Rating
            if (self.config.businessCheck.customerLoginName !== "") {
                businesscheck.getRating(viewModel, self.config);
            }

            //ToDo: Soliditet rating
            else if (self.config.soliditet.customerLoginName !== "") {

            }
            //Creditsafe
            else if (self.config.creditsafe.customerLoginName !== "") {
                creditsafe.getRating(viewModel,self.config);
            }
			//Experian
            else if (self.config.experian.customerLoginName !== "") {
                experian.getRating(viewModel,self.config);
            }
            
            //Implement your own here

            viewModel.ratingDate(moment().format("YYYY-MM-DD HH:mm:ss"));
            viewModel.save();

        }

        //Set the colors based on your rating value
        viewModel.setColor = ko.computed(function() {
            if (viewModel.ratingValue() && !viewModel.loading()) {
                //BusinessCheck
                if (self.config.businessCheck.customerLoginName !== "") {
                    businesscheck.setColor(viewModel);   
                }
                //ToDo: Soliditet rating
                else if (self.config.soliditet.customerLoginName !== "") {

                }
                //Creditsafe
                else if (self.config.creditsafe.customerLoginName !== "") {
                    creditsafe.setColor(viewModel);
                }
				//Experian
                else if (self.config.experian.customerLoginName !== "") {
                    experian.setColor(viewModel);
                }

                //Implement your own here
            }

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
            if(viewModel.inline){ //Inline mode
                viewModel.ratingIcon('<i class="fa fa-refresh fa-spin" ></i>');
            }else{
                $(".handle").stop().animate({ 'margin-top': '-0px' }, "slow");    
            }

            if (viewModel.ratingDate()) {
                $(".rating-date").fadeIn();
            }

        }, function() {
            if(viewModel.inline){
                 viewModel.ratingIcon(viewModel.ratingValue());
            }else{ 
                if(viewModel.ratingValue()){ // Only slide up if we have a rating
                    $(".handle").stop().animate({ 'margin-top': '-30px' }, "slow");
                }
            }
            if (viewModel.ratingDate() !== "") {
                    $(".rating-date").stop().fadeOut();
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
                if (moment().diff(existingData.creditdata.ratingData.ratingDate, 'days') < self.config.maxAge) {
                    viewModel.ratingValue(existingData.creditdata.ratingData.ratingValue);
                    viewModel.ratingText(existingData.creditdata.ratingData.ratingText);
                    viewModel.ratingDate(existingData.creditdata.ratingData.ratingDate);
                }
            }else if(viewModel.inline){
                    existingData = viewModel.inline;
                    viewModel.ratingValue('?');
                    viewModel.ratingText('Ingen kreditrating tagen');
                    viewModel.loadText('Ta kreditkontroll');
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
		
		function isPublicCompanyNorway(regNbr) {
            var isPublic = false;

            if (regNbr.length > 7) {
                //5 is equal to a Aktiebolag (this should always be true, but there are exeptions)
                if (regNbr.charAt(0) === '8' || regNbr.charAt(0) === '9') {
                        isPublic = true;
                }
            }
            return isPublic;
        }

        //Converts rating value, text and date to XML and saves in creditinfo-field in LIME
        viewModel.save = function() {
            var ratingData = {};
            ratingData.ratingValue = viewModel.ratingValue();
            ratingData.ratingText = viewModel.ratingText();
            ratingData.ratingDate = viewModel.ratingDate();
            ratingData = "<ratingData>" + json2xml($.parseJSON(JSON.stringify(ratingData)), '') + "</ratingData>";
            lbs.limeDataConnection.ActiveInspector.Controls.SetValue('creditinfo', ratingData);
			
			//Save data to field for extended usage (need the field ratingdata)
			if (self.config.showInField == true) {
				lbs.limeDataConnection.ActiveInspector.Controls.SetValue('ratingdata', viewModel.ratingValue());		
			}
			lbs.limeDataConnection.ActiveInspector.Record.Update();
        }


        return viewModel;
    }
});