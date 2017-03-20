lbs.apploader.register('OneFlow', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.mode = _.some(["actionpad","windowed","setAccount"],function(m){
                return m === appConfig.mode;
            }) ? appConfig.mode : 'actionpad';
            this.table = appConfig.table || 'deal';
            this.linkField = appConfig.linkField || 'documentlink';
            this.defaultCountry = appConfig.defaultCountry ||'SE';
            this.idField = appConfig.idField || 'oneflowid';
            this.endpoint = 'https://app.oneflow.com/api/';
            this.accounts = [
                // {
                //     'name': 'Gröna Lund',
                //     'token': 'ec437cd1572897b58d96e8b6837978495ce51ec3'//'e417398d71af8a03677d71560273bff76ce088d0'
                // },
                {
                    'name': 'Lundalogik',
                    'token': '46050eb43205dcb7f84519cd56db295960ef2bf9'
                },
                {
                    'name': 'Oneflow',
                    'token': 'c7ce6e4ee9e9a688ab42b179adae10708b057da9'
                }
            ];
            this.token = '581d1971d047c3c78812e14d0898969a56aa51d5';
            this.companyName = appConfig.companyName || 'Lundalogik';
            this.dataSources = [{type:'activeInspector', alias: "inspector"}, {type: 'activeUser', source: {}}];
            this.resources = {
                scripts: ['scripts/oneflow.js'], // <= External libs for your apps. Must be a file
                styles: ['app.css'], // <= Load styling for the app.
                libs: [] // <= Already included libs, put not loaded per default. Example json2xml.js
            };
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
		setup = function(){
            $('title').html('Lime CRM - Oneflow');
            viewModel.activeInspector = lbs.loader.loadDataSources({}, [{ type: 'activeInspector', alias: 'activeInspector'}]).activeInspector;
            viewModel.activeUser = lbs.loader.loadDataSources({}, [{ type: 'activeUser', source: {}}]).ActiveUser;
            viewModel.accounts(ko.utils.arrayMap(self.config.accounts, function(a){
                return a;
            }));
            
            var jsonData = {};
            lbs.loader.loadDataSource(
                jsonData,
                {type: 'record', source: 'OneFlow.GetDeal'},
                false
            );
            viewModel.deal = jsonData.deal;
            viewModel.token(jsonData.deal.oneflowtoken.text);
            if(viewModel.token() === ''){
                if(viewModel.accounts().length === 1){
                    viewModel.token(viewModel.accounts()[0].token);
                    lbs.common.executeVba('OneFlow.SaveToken, ' + viewModel.token());
                }
            }

            viewModel.mode = self.config.mode;
            viewModel.email = lbs.common.executeVba("OneFlow.GetUserEmail");
            
            // Sets up the Oneflow specific stuff.
            oneFlow.setup(self.config, viewModel);

            // Fetches the active user's position from the Oneflow API.
            if(!viewModel.position()){
                oneFlow.getPosition(viewModel.email, false, viewModel.position);
            }
            viewModel.loading(false);
            // If a position was returned - get stuff.
            if(viewModel.position()){
                switch(viewModel.mode){
                    case 'windowed':
                        oneFlow.getTags();
                        oneFlow.getTemplates();
                        viewModel.getPersons();
                        viewModel.getCoworkers();
                        viewModel.getAgreements();
                        viewModel.getExternalParty();
                        $("body").addClass("windowed");
                        break;
                    case 'setAccount':
                        viewModel.accountName(ko.utils.arrayFilter(viewModel.accounts(), function(item){
                            return item.token === viewModel.token();
                        })[0]);
                        viewModel.accountName(viewModel.accountName() ? viewModel.accountName().name : '-');
                        break;
                    case 'actionpad':
                        viewModel.getAgreements();
                        break;
                }
            }
        }
        
        
        viewModel.progressHeight = ko.observable(0);
        viewModel.sending = ko.observable(false);
        viewModel.placeholder = {fullname : 'Dra och släpp mottagare här...', placeholder: true, setType: function(){}};

        viewModel.accountName = ko.observable();
        viewModel.documentName = ko.observable('');
        viewModel.token = ko.observable('');
        viewModel.position = ko.observable();
        viewModel.loading = ko.observable(false);
        viewModel.templates = ko.observableArray();
        viewModel.selectedTemplate = ko.observable();
        viewModel.accounts = ko.observableArray();
        
        viewModel.persons = ko.observableArray();
        viewModel.filteredPersons = ko.observableArray();
        viewModel.personFilter = ko.observable('');
        viewModel.personFilter.subscribe(function(newValue){
            viewModel.filterPersons();
        });
        viewModel.numberPersonsText = ko.computed(function(){
            return 'Visar' + ' ' + viewModel.filteredPersons().length + '/' + viewModel.persons().length;
        });


        viewModel.coworkers = ko.observableArray(); 
        viewModel.filteredCoworkers = ko.observableArray();
        viewModel.coworkerFilter = ko.observable('');
        viewModel.coworkerFilter.subscribe(function(newValue){
            viewModel.filterCoworkers();
        });
        viewModel.numberCoworkersText = ko.computed(function(){
            return 'Visar' + ' ' + viewModel.filteredCoworkers().length + '/' + viewModel.coworkers().length;
        });

        viewModel.agreements = ko.observableArray();
        viewModel.selectedAgreement = ko.observable();
        viewModel.tags = ko.observable();
        viewModel.error = ko.observable(false);
        viewModel.positionError = ko.observable(false);
        viewModel.agreementError = ko.observable(false);
        viewModel.success = ko.observable(false);
        viewModel.innerException = ko.observable('');
        viewModel.externalParty = ko.observable(new oneFlow.Models.Party(null));

        viewModel.participantsAdded = ko.computed(function(){
            var length = ko.utils.arrayFilter(viewModel.coworkers(), function(item){
                return item.type().value >= 0;
            }).length

            length = length + ko.utils.arrayFilter(viewModel.persons(), function(item){
                return item.type().value >= 0;
            }).length

            return length > 1;
        });

        viewModel.getAgreements = function(){
            var xmlData = {};
            lbs.loader.loadDataSource(
                xmlData,
                {type: 'records', source: 'OneFlow.GetDocuments, ' + self.config.table + ', ' + self.config.linkField},
                true
            );

            if(xmlData.document){
                _.each(xmlData.document.records, function(item){
                    oneFlow.getAgreement(item.comment.text, item.updatedoneflow.text, item.oneflowid.value, true);
                });
            }
            viewModel.documentName(viewModel.activeInspector.name.text + ' Contract #' + (xmlData.document.records.length + 1));
        }

        viewModel.updateAgreement = function(){
            oneFlow.getAgreement(viewModel.selectedAgreement().name, viewModel.selectedAgreement().updated, viewModel.selectedAgreement().id, false);
        	oneFlow.updateAgreement(viewModel.selectedAgreement());
        }

        viewModel.getPersons = function(){
            var xmlData = {};
            lbs.loader.loadDataSource(
                xmlData,
                {type: 'records', source: 'OneFlow.GetPersons'},
                true
            );

            if(xmlData.person){
                var persons = xmlData.person.records;
                if(!(persons instanceof Array)){
                    persons = [persons];
                }
                viewModel.persons(ko.utils.arrayMap(persons, function(item){
                    return new oneFlow.Models.Person(item);
                }));
                viewModel.filterPersons();
            }

        }

        viewModel.getExternalParty = function(){
            var xmlData = {};
            lbs.loader.loadDataSource(
                xmlData,
                {type: 'record', source: 'OneFlow.getExternalParty'},
                true
            );
            var company = xmlData.company;
            if(xmlData.company){
                viewModel.externalParty().name = company.name.text;
                viewModel.externalParty().country = company.countrycode.text || self.defaultCountry;
                viewModel.externalParty().orgnr = company.registrationno.text;
                viewModel.externalParty().phone_number = company.phone.text;
            }
        }

        viewModel.getCoworkers = function(){
            var xmlData = {};
            lbs.loader.loadDataSource(
                xmlData,
                {type: 'records', source: 'OneFlow.GetCoworkers'},
                true
            );

            if(xmlData.coworker){
                var coworkers = xmlData.coworker.records;
                if(!(coworkers instanceof Array)){
                    coworkers = [coworkers];
                }

                viewModel.coworkers(ko.utils.arrayMap(coworkers, function(item){
                    return new oneFlow.Models.Coworker(item);
                }));

                _.each(viewModel.coworkers(), function(c){
                    oneFlow.getPosition(c.email,false,c.position);
                });
                viewModel.filterCoworkers();
            }
        }

        viewModel.createAgreement = function(){
            viewModel.sending(true);
            oneFlow.createAgreement();
        }

        viewModel.openWindowed = function(){
            lbs.common.executeVba("OneFlow.openWindowed");
        }

        viewModel.close = function(){
            lbs.common.executeVba('OneFlow.Refresh');
            window.open('','_parent','');
            window.close();
        }

        viewModel.chooseAccount = function(account){
            viewModel.token(account.token);
            
            oneFlow.getPosition(viewModel.email, false, viewModel.position);
          
            if(!viewModel.position()){
                viewModel.positionError(true);
                viewModel.token('');
                return;
            }
            viewModel.positionError(false);
            viewModel.loading(true);
            lbs.common.executeVba('OneFlow.SaveToken, ' + viewModel.token());
            setup();
        }
        viewModel.changeAccount = function(account){
            viewModel.token(account.token);
            viewModel.position(null);
            oneFlow.getPosition(viewModel.email, false, viewModel.position);
            if(!viewModel.position()){
                viewModel.positionError(true);
                viewModel.token('');
                return;
            }
            viewModel.positionError(false);
            viewModel.loading(true);
            lbs.common.executeVba('OneFlow.SaveToken, ' + viewModel.token());
            viewModel.close();
        }

        viewModel.filterPersons = function(){
            if(vm.personFilter() !== ''){
                vm.filteredPersons(ko.utils.arrayFilter(vm.persons(), function(item){
                    if(item.fullname.toLowerCase().indexOf(vm.personFilter().toLowerCase()) != -1){
                        return true;
                    }
                    return false;
                }));
            }
            else{
                vm.filteredPersons(vm.persons().slice());
            }
        }

        viewModel.filterCoworkers = function(){
            if(vm.coworkerFilter() !== ''){
                vm.filteredCoworkers(ko.utils.arrayFilter(vm.coworkers(), function(item){
                    if(item.fullname.toLowerCase().indexOf(vm.coworkerFilter().toLowerCase()) != -1){
                        return true;
                    }
                    return false;
                }).sort(function(left,right) {
                    return left.position() ? -1 : 1;
                }).slice(0,5));
            }
            else{
                vm.filteredCoworkers(vm.coworkers().sort(function(left,right) {
                    return left.position() ? -1 : 1;
                }).slice(0,5));
            }
        }
    
        setup();
        return viewModel;
    };
});