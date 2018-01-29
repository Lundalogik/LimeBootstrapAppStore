lbs.apploader.register('quicknote', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
            this.dataSources = [{type: 'xml', source:'QuickNote.GetInitializeData', alias:'types'}];
            this.resources = {
                scripts: ['bootstrap-select.min.js'], // <= External libs for your apps. Must be a file
                styles: ['app.css', 'bootstrap-select.min.css'], // <= Load styling for the app.
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

        $(document).keydown(function (e) {
            if (e.keyCode == 13) { // Enter pressed
                // stop the event propagate (if you want)
                return false;
            }
            else if (e.keyCode == 27) { // Escape pressed
                return false;
            }
            else {
                // Let other keys go
            }
        });

        viewModel.goToNext = function() {
            lbs.common.executeVba('QuickNote.GoToNextRecord, false, false');
        }

        viewModel.goToPrevious = function() {
            lbs.common.executeVba('QuickNote.GoToNextRecord, true, false');
        }

        viewModel.saveHistory = function() {
            var idstring = viewModel.chosenHistory();
            var noteText = viewModel.noteText().toString();
            if(idstring > 0) {
                viewModel.chosenHistory(-1);
                viewModel.noteText('');
                
                noteText = encodeURIComponent(noteText).replace(/'/g,'%27');

                lbs.common.executeVba('QuickNote.SaveHistory, ' + noteText + ', ' + idstring)
            }
            else {
                alert("Du måste välja historiktyp");
            }
        }

        viewModel.nextEnabled = ko.observable(lbs.common.executeVba('QuickNote.GoToNextRecord, false, true'));
        viewModel.prevEnabled = ko.observable(lbs.common.executeVba('QuickNote.GoToNextRecord, true, true'));


        viewModel.historyTypes = ko.observableArray([{
            id : -1,
            text : "<Välj historiktyp>"
        }]);
        var types = [];
        if(viewModel.types.data.type)
        {
            types = viewModel.types.data.type.length && viewModel.types.data.type || [viewModel.types.data.type];
            for (var i = 0; i < types.length; i++)
            {
                viewModel.historyTypes.push({
                    id : types[i].id,
                    text : types[i].text || " "
                });
            }
        }
        viewModel.chosenHistory = ko.observable(types[1].id);
        viewModel.noteText = ko.observable("");

        return viewModel;
    };
});
