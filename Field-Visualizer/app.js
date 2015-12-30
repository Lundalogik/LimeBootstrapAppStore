lbs.apploader.register('Visualizer', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.value = appConfig.Value;
			this.map = appConfig.Map;
			this.colorVar = appConfig.ColorVar;
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
		viewModel.Icon = ko.observable("");
		viewModel.Text = ko.observable("");
		
		var map = self.config.map;
		var index = 0;
		var found = 0;
		var entry;
		for (index = 0; index < map.length; ++index) {
			entry = map[index];	
			if (entry.id == self.config.value) {
				found = entry;
				break;
			}
		}
		
		if (found != 0) {
		
			viewModel.Icon = ko.observable(found.value)
			
			if (found.text.length != 0) {
				viewModel.Text = ko.observable(found.text);
			} else {
				viewModel.Text = ko.observable("");
			}
			
			viewModel.colorVar = ko.observable(found.colorVar);
		}
        return viewModel;
    };
});
