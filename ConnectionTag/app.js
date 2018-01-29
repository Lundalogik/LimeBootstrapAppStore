lbs.apploader.register('ConnectionTag', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */

    self.config =  function(appConfig){
            this.table = appConfig.table || 'history';
            this.field = appConfig.field || 'note';
            this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
            this.dataSources = [];
            this.resources = {
                scripts: [], // <= External libs for your apps. Must be a file
                styles: ['app.css'], // <= Load styling for the app.
                libs: [] // <= Already included libs, put not loaded per default. Example json2xml.js
            };
    };

    //initialize
    /*Initialize
        Initialize happens after the data and recources are loaded but before the view is rendered.
        Here it is your job to implement the logic of your app, by attaching data and functions to 'vm' and then returning it
        The data you requested along with localization are delivered in the variable vm.
        You may make any modifications you please to it or replace is with a entirely new one before returning it.
        The returned vm will be used to build your app.
        
        Node is a reference to the HTML-node where the app is being initalized form. Frankly we do not know when you'll ever need it,
        but, well, here you have it.
    */
    self.initialize = function (node, vm) {
        vm.contacts = ko.observableArray();
        vm.visibleContacts = ko.observableArray();
        vm.table = self.config.table;
        vm.field = self.config.field; 

        var xmlData = {};
        lbs.loader.loadDataSource(
            xmlData,
            {type: 'records', source: 'ConnectionTag.GetConnections,' +  vm.table},
            true
        );

        Contact = function(c){
            var self = this;
            self.name = c.name.text;
            self.setName = function(){
                lbs.common.executeVba("ConnectionTag.SetName, " + self.name + ", " + vm.table + ", " +  vm.field);
            }
        }

        if(xmlData.person.records != null){
            vm.contacts(ko.utils.arrayMap(xmlData.person.records, function(p){
                return new Contact(p);
            }));
        }
        
        vm.visibleContacts(vm.contacts());
        return vm;
    };
});
