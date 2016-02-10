lbs.apploader.register('DrivingInfo', function () {
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
				
        viewModel.hello = "Driving time: ";
		viewModel.driveinginfo = ko.observableArray();
		//getData
			var newJson = "";
			newJson = JSON.parse(lbs.common.executeVba('Drivinginfo.getLatLong, address'));
			
			var myoffice = "";
			myoffice = JSON.parse(lbs.common.executeVba('Drivinginfo.getLatLong, office'));
			
			if(newJson != null && newJson.length > 1){
				var latlon = newJson[0].lat + ";" + newJson[0].lon
				var molon = myoffice[0].lat + ";" + myoffice[0].lon
							
				var sendcode = 'Drivinginfo.getLatLong, distance, ' + latlon + "," + molon;
				
				
				var myJson = "";
				myJson = JSON.parse(lbs.common.executeVba(sendcode));
				if(myJson.hasOwnProperty("route_summary")){
					var titime = (myJson.route_summary.total_time / 3600);
					viewModel.time = titime.toFixed(1);
					viewModel.startpoint = myJson.route_summary.start_point;
					viewModel.endpoint = myJson.route_summary.end_point;
					var driveDistance = (myJson.route_summary.total_distance / 1000).toFixed(2)
					viewModel.distance = driveDistance;
					viewModel.charge = driveDistance * 4,5;
				}
				
			} else {
				alert("Address not found");
					viewModel.time = " ";
					viewModel.startpoint = " ";
					viewModel.endpoint = " ";
					viewModel.distance = " ";
					viewModel.charge = " ";
			}
			
		
        return viewModel;
    };
});
