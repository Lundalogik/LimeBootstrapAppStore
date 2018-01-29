lbs.apploader.register('JobStatus', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
			
			var source = 'SQLJobs.GetJobStatus,' + appConfig.JobNames;			
            this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
            this.dataSources = [{ type: 'xml', source: source, alias: 'JobData'}];
            this.resources = {
                scripts: [], // <= External libs for your apps. Must be a file
                styles: ['app.css'], // <= Load styling for the app.
                libs: [] // <= Allready included libs, put not loaded per default. Example json2xml.js
            };
			this.memberOfGroup = appConfig.Groups;
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
		
		var member = lbs.common.executeVba('SQLJobs.MemberOfGroup,' + self.config.memberOfGroup);	
		viewModel.isMember = ko.observable(member);	
		viewModel.hasError = ko.observable(false);		
		viewModel.many = ko.observable(false);
		
		if (Object.prototype.toString.call(viewModel.JobData.jobstatus.job) === '[object Array]'){
		viewModel.many(true);		
		$.each(viewModel.JobData.jobstatus.job, function(i,job){						
			if (job.run_status != 1){								
				viewModel.hasError(true);
				job.RunDateTime = moment(job.RunDateTime).format('YYYY-MM-DD, h:mm:ss');	
			}
				
		});
		}
		else{
			if (viewModel.JobData.jobstatus.job.run_status != 1){
				viewModel.hasError(true);
				viewModel.JobData.jobstatus.job.RunDateTime = moment(viewModel.JobData.jobstatus.job.RunDateTime).format('YYYY-MM-DD, h:mm:ss');	
			}
		}
			
        return viewModel;
    };
});
