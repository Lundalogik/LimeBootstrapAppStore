lbs.apploader.register('Fulltextsearch', function () {
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
        
        viewModel.searchValue = ko.observable($('#searchValue').val()).extend({throttle:1000});
        viewModel.searchString = ko.observable('');
        var lastManualSearchValue = "";
        
        viewModel.searchValue.subscribe(function(newValue){
            if(newValue.length > 1) {
                if (newValue !== lastManualSearchValue) {
                    lbs.common.executeVba('Fulltextsearch.Search,' + newValue);
                    window.focus();
                    $('#searchValue').focus();
                }
            }
        });

        viewModel.or = function(i, event){
            if ($('#searchValue').val().length > 0){
                viewModel.searchString(viewModel.searchString() + $('#searchValue').val() + ' [--OR--]');                                
                $('#searchValue').val($('#searchValue').val() + ' OR ');
                $('#searchValue').keydown();
                window.focus();
                $('#searchValue').focus();
            }            
        }

        viewModel.and = function(i, event){
            if ($('#searchValue').val().length > 0){
                viewModel.searchString(viewModel.searchString() + $('#searchValue').val() + ' [--AND--]');                                
                $('#searchValue').val($('#searchValue').val() + ' AND ');
                $('#searchValue').keydown();
                $('#searchValue').focus();
            }            
        }

        viewModel.like = function(i, event){
            if ($('#searchValue').val().length > 0){
                //viewModel.searchString(viewModel.searchString() + $('#searchValue').val() + ' [--LIKE--]');                                
                lbs.common.executeVba('Fulltextsearch.Search,' + $('#searchValue').val() + '*');
                $('#searchValue').val($('#searchValue').val() + '*');
                $('#searchValue').keydown();
                $('#searchValue').focus();
            }
        }
        viewModel.showString = function(i,event){
            lastManualSearchValue = $('#searchValue').val();
            lbs.common.executeVba('Fulltextsearch.Search,' + $('#searchValue').val());
        }
        return viewModel;
    };
});
