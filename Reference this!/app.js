lbs.apploader.register('Reference this!', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
            this.dataSources = [];
            this.resources = {
                scripts: [], // <= External libs for your apps. Must be a file
                styles: ['app.css'], // <= Load styling for the app.
                libs: [] // <= Allready included libs, put not loaded per default. Example json2xml.js
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
        
        function Company(c){
            var self = this;
            self.idcompany = c.idcompany;
            self.name = ko.observable(c.name);

            self.open = function(){
                var link = lbs.common.createLimeLink('company', self.idcompany);
                alert(link);
            }
        }
        viewModel.noCompanies = ko.observable(false);
        viewModel.errorText = ko.observable("");
        viewModel.companies = ko.observableArray();
        viewModel.getReferences = function(){
            


            var xmlData = lbs.common.executeVba('ReferenceThis.GetReferences');    
              
            if(xmlData !== ""){
                var json = xml2json($.parseXML(xmlData),'');
                json = $.parseJSON(json);

                if(json !== null){
                    
                    if(!(json.companies.company instanceof Array)){
                        json.companies.company = [json.companies.company];
                    }
                    
                    viewModel.companies(ko.utils.arrayMap(json.companies.company, function(c){
                        return new Company(c);
                    }));

                }
            }
            else{
                viewModel.noCompanies(true);
                viewModel.errorText("No references found!");
            }
            
        }

        return viewModel;
    };
});
