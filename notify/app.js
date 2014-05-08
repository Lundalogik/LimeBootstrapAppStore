lbs.apploader.register('subscriptions', function () {
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
        var vm = new subscription.viewModel();
        return vm;
    };



    var subscription = subscription || {}

    subscription.viewModel = function(){
        var self = this;
        this.items = ko.observableArray();
        var data = {};

        openLink = function(i){
            var idrecord = i.idrecord;
            var link = lbs.common.createLimeLink(i.tablename,idrecord);
            document.location.href(link);
            
        }
        
        getButtonText = function(i){
            var retval;
            switch(i.tablename)
            {
                case "helpesk":
                    retval = "Nytt ärende";
                case "history":
                    retval = "Ny historik";
            }
            return retval;

        }

        self.items.removeAll();
        lbs.loader.loadDataSource(
            data,
            {type: 'xml', source: 'Globals.GetSubscriptions'},
            true   
        );
        
        if(!jQuery.isEmptyObject(data)){

            var tmp = data.xmlSource.items.item;
            if(!(tmp instanceof Array)){
                tmp = [tmp];
            }

            self.items(tmp);

        }


        
    };

});
