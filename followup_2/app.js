lbs.apploader.register('followup', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig) {
        this.dataSources = [];
        this.resources = {
            scripts: [
                '/External Libs/Datetimepicker/moment-with-locales_tln_default_sv_.min.js', // OBS OBS Manually put in by TLN <-> Set default locale to 'sv' in end of file! OBS OBS
                '/External Libs/Datetimepicker/bootstrap-datetimepicker.min.js',
                '/app_datahandlingfunctions.js',
                '/app_helperfunctions.js',
                '/app_initializefunctions.js'
            	], // <= External libs for your apps. Must be a file
            styles: ['app.css','/External Libs/Datetimepicker/datepicker.css'], // <= Load styling for the app.
            libs: [] // <= Allready included libs, put not loaded per default. Example json2xml.js
        };

        this.choiceLimits = appConfig.choiceLimits || {};
		this.choiceLimits.totalMax = appConfig.choiceLimits.totalMax || 0;
		this.choiceLimits.targetMax = appConfig.choiceLimits.targetMax || 0;
		this.choiceLimits.coworkerMax = appConfig.choiceLimits.coworkerMax || 0;
		
		this.securityLevel = appConfig.securityLevel || 'user';

        this.coloring = appConfig.coloring || {};
        this.coloring.green = this.coloring.green || 1.0;
        this.coloring.yellow = this.coloring.yellow || 0.7;

		this.targetMapping = appConfig.targetMapping || [];

		this.structureMapping = appConfig.structureMapping || {};
		this.structureMapping.targetType = appConfig.structureMapping.targetType || 'count';

        this.structureMapping.targetTable = appConfig.structureMapping.targetTable || 'target';
        this.structureMapping.targetTypeField = appConfig.structureMapping.targetTypeField || 'targettype';
        this.structureMapping.targetValueField = appConfig.structureMapping.targetValueField || 'targetvalue';
        this.structureMapping.targetDateField = appConfig.structureMapping.targetDateField || 'targetdate';

        this.structureMapping.scoreTable = appConfig.structureMapping.scoreTable || 'history';
        this.structureMapping.scoreTypeField = appConfig.structureMapping.scoreTypeField || 'type';
        this.structureMapping.scoreValueField = appConfig.structureMapping.scoreValueField || '';
        this.structureMapping.scoreDateField = appConfig.structureMapping.scoreDateField || 'date';
    };

    //initialize
    self.initialize = function (node, viewModel) {
        var appConfig = self.config;

        // Initialize the app.
        initializeLib.initialize(viewModel, appConfig);

        return viewModel;
    };

});