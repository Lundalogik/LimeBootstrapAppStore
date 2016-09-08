lbs.apploader.register('followup', function () {
    var self = this;

    //config
var self = this;


    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.appConfig = appConfig;
			//this.defaultfilter = '';
            this.historytype = '';
			this.tagettype = '';
			this.displayText = '';
			this.yellow = 0.75;
            this.dataSources = [];
            this.resources = {
                scripts: [], // <= External libs for your apps. Must be a file
                styles: ['app.css'], // <= Load styling for the app.
                libs: [] // <= Allready included libs, put not loaded per default. Example json2xml.js
            };
    };

    //initialize

    self.initialize = function (node, viewModel) {
        var appConfig = self.config.appConfig; 

		// Get localization text
		var minutes = lbs.common.executeVba('Localize.GetText, Followup,  minutes');
		var seconds = lbs.common.executeVba('Localize.GetText, Followup,  seconds');
		var lastupdated = lbs.common.executeVba('Localize.GetText, Followup,  lastupdate');
		var refreshmessage = lbs.common.executeVba('Localize.GetText, Followup,  refresh_message');
		
		viewModel.outcome = ko.observable("");
		viewModel.targetnow = ko.observable("");
		viewModel.target = ko.observable("");
		viewModel.tileColor= ko.observable("rgb(232, 89, 89)");
		viewModel.latestTab= ko.observable(appConfig.defaultfilter);
			
		viewModel.root =load(appConfig.historytype, appConfig.tagettype);
		viewModel.displayText = viewModel.root.data.followup.displaytext.value["displaytext"];
		
		 
		var date = new Date();
		var TimeStamp = date.toLocaleString();
		
		viewModel.latestRefreshMilli = ko.observable(date);
		viewModel.latestRefreshString = ko.observable(lastupdated + " " + TimeStamp);

		// Loads the data trough the vba
		function load(htype, ttype){
            var xmlData = lbs.common.executeVba('FollowUp.Initialize,' + htype + "," + ttype);        
		 var json = xml2json($.parseXML(xmlData),'');
         json = $.parseJSON(json);
         return json;
		 };
		 
		 //Show all data
		viewModel.all = function(){  
			viewModel.latestTab("all");
			viewModel.outcome(viewModel.root.data.followup.all.value["outcome"]);
			viewModel.targetnow(viewModel.root.data.followup.all.value["targetnow"]);
			viewModel.target(viewModel.root.data.followup.all.value["target"]);
			if (viewModel.root.data.followup.all.value["target"] == 0){
				percent = 0
			}
			else if(viewModel.root.data.followup.all.value["target"] == 0 && viewModel.root.data.followup.all.value["outcome"] > 0){
				percent = 1;
			}
			else{
				percent = (viewModel.root.data.followup.all.value["outcome"]/viewModel.root.data.followup.all.value["targetnow"]);
			}
				if (percent < appConfig.yellow){
					viewModel.tileColor("rgb(232, 89, 89)");
					};
				if (percent >= appConfig.yellow && percent < 1){
					viewModel.tileColor("rgb(244, 187, 36");
					};
				if (percent >= 1){
					viewModel.tileColor("rgb(153, 216, 122)");
					};
		};
		
		//Show coworker data
		viewModel.coworker = function(){
			viewModel.latestTab("mine");
			viewModel.outcome(viewModel.root.data.followup.coworker.value["outcome"]);
			viewModel.targetnow(viewModel.root.data.followup.coworker.value["targetnow"]);
			viewModel.target(viewModel.root.data.followup.coworker.value["target"]);
			var percent
			if (viewModel.root.data.followup.coworker.value["target"] == 0){
				percent = 0;
			}
			else if(viewModel.root.data.followup.coworker.value["target"] == 0 && viewModel.root.data.followup.coworker.value["outcome"] > 0){
				percent = 1;
			}
			else{
				percent = (viewModel.root.data.followup.coworker.value["outcome"]/viewModel.root.data.followup.coworker.value["targetnow"]);
			}
			if (percent < appConfig.yellow){
				viewModel.tileColor("rgb(232, 89, 89)");
				};
			if (percent >= appConfig.yellow && percent < 1){
				viewModel.tileColor("rgb(244, 187, 36");
				};
			if (percent >= 1){
				viewModel.tileColor("rgb(153, 216, 122)");
				};

		};
		
		//Runs when you press the refresh button. The user is allowed to refresh each 5 minutes 
		viewModel.refresh= function(){
				var TimeNow = new Date();
				var lastRefresh = viewModel.latestRefreshMilli();
				var diffS = ((TimeNow-lastRefresh)/1000);
				if(diffS > 300){
					viewModel.latestRefreshMilli(TimeNow);
					viewModel.root =load(appConfig.historytype, appConfig.tagettype);
					if (viewModel.latestTab() == 'all') {
					 viewModel.all();
					} else if(viewModel.latestTab() == 'mine'){
					 viewModel.coworker();
					}
					viewModel.latestRefreshString (lastupdated + " "  + TimeNow.toLocaleString());
				}else{
					var mins = (~~((300 - diffS) / 60));
					var secs = (Math.round(300 - diffS) % 60);
					alert( refreshmessage + " " + mins + " " + minutes + " " + secs + " " + seconds);
					
				};
				
		};
		
		//if (appConfig.defaultfilter == 'all') {
				 //viewModel.all();
		// } else if(appConfig.defaultfilter == 'mine'){
				 viewModel.coworker();
			 //}
		
        return viewModel;
    };

});