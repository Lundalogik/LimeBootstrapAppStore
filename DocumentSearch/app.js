lbs.apploader.register('DocumentSearch', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            //this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
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
        
        var searchInput = $('#searchInput');
        viewModel.searchString = ko.observable(searchInput.val());              //This one is used for hover effects in the GUI
        viewModel.searchStringThrottled = ko.computed(viewModel.searchString).extend({throttle:1000});          //This one is used for automatic searches
        var lastManualSearchString = '';

        
        // Make the app perform an automatic search after the user has typed something in the search input.
        viewModel.searchStringThrottled.subscribe(function(newValue) {
            if(newValue.length > 1) {
                // Only perform automatic search if not a manual search was just done for the same string.
                if (newValue !== lastManualSearchString) {
                    lbs.common.executeVba('AO_DocumentSearch.Search,' + newValue);
                    window.focus();
                    searchInput.focus();
                }
            }
        });

        /* Called when clicking the helper button OR in the GUI.
            Adds the logical operator OR to the search string. */
        viewModel.addOperatorOr = function(i, event){
            if (searchInput.val().length > 0) {
                // Check the last four characters in the string
                if (searchInput.val().slice(-4) !== ' OR ') {
                    searchInput.val(searchInput.val() + ' OR ');
                }
            }
            searchInput.focus();        
        }

        /* Called when clicking the helper button BEGINS WITH in the GUI.
            Adds the wild card operator * to the search string. */
        viewModel.addOperatorBeginsWith = function(i, event){
            if (searchInput.val().length > 0) {
                // Check the last character in the string
                if (searchInput.val().slice(-1) !== ' ' && searchInput.val().slice(-1) !== '*') {
                    searchInput.val(searchInput.val() + '*');
                    searchInput.keydown();                      // Trigger an automatic search
                }
            }
            searchInput.focus();
        }

        // Called when clicking the search button in the GUI for a manual search.
        viewModel.manualSearch = function(i, event){
            lastManualSearchString = searchInput.val();
            lbs.common.executeVba('AO_DocumentSearch.Search,' + lastManualSearchString);
        }

        return viewModel;
    };
});
