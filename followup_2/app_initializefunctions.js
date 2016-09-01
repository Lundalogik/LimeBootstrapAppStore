var initializeLib = {
    pickerLoaded: false
};

initializeLib.initialize = function(viewModel, appConfig) {
	initializeLib.initializeViewModel(viewModel, appConfig);
	if(viewModel.activeCoworker) {
        dataHandlingLib.loadChoiceData(viewModel, appConfig);
        initializeLib.initializeDatepicker(viewModel, appConfig);

        // Get target date if all needed info is set
	    if(viewModel.canGetTargetData() && viewModel.errorMessage() == '') {
	    	viewModel.getTargetData();
	    }
    }
    else {
    	viewModel.errorMessage(viewModel.localize.Followup.no_coworker || 'No localize found for - Followup.no_coworker');
    }
}

initializeLib.initializeDatepicker = function(viewModel, appConfig) {
	// Initialize datepicker
	if (!initializeLib.pickerLoaded) {
        initializeLib.pickerLoaded = true;
        $('#datetimepicker').datetimepicker({
            inline: false,
        	showTodayButton: true,
            viewMode: 'months',
            format: 'YYYY - MMMM',
            toolbarPlacement: 'top',
            defaultDate: moment().format('YYYY-MM-DD'),
            locale: lbs.limeDataConnection.Database.Locale || 'en-us',
            icons: {
                time: 'fa fa-clock-o',
                date: 'fa fa-calendar',
                up: 'fa fa-arrow-circle-up',
                down: 'fa fa-arrow-circle-down',
                previous: 'fa fa-arrow-circle-left',
                next: 'fa fa-arrow-circle-right',
                today: 'fa fa-calendar',
                clear: 'fa fa-trash',
                close: 'fa fa-times-circle'
            },
            tooltips: {
				today: viewModel.localize.Followup.tooltip_today || 'No localize found for - Followup.tooltip_today'
			}
        });

        $("#datetimepicker").on("dp.change", function(e) {
        	viewModel.getTargetData();
        });
    }
}

initializeLib.initializeViewModel = function(viewModel, appConfig) {
	// Initial data setup
	viewModel.coloring = {
		green: appConfig.coloring.green,
		yellow: appConfig.coloring.yellow
	};

	viewModel.activeCoworker = null;
    if (lbs.limeDataConnection.ActiveUser.Record) {
    	viewModel.activeCoworker = lbs.limeDataConnection.ActiveUser.Record.ID;
    }

    viewModel.choices = {
    	coworkers : ko.observableArray(),
    	targettypes : ko.observableArray()
    };

    viewModel.grouping = {
    	selected: ko.observable('coworker'),
    	latestFetched: ko.observable('coworker'),
    	changeGrouping: function(pressedType) {
    		this.selected(pressedType);
    	}
    }
    viewModel.securityLevel = appConfig.securityLevel;

    viewModel.cookieName = viewModel.activeCoworker + "followupCookie";
    viewModel.cookieObj = dataHandlingLib.getCookie(viewModel);
	if (viewModel.securityLevel == 'user') {
		viewModel.grouping.selected('target');
	}
	else {
		viewModel.grouping.selected(viewModel.cookieObj.groupby);
	}

    viewModel.parents = ko.observableArray();
    viewModel.errorMessage = ko.observable('');

	viewModel.listSizeClass = ko.observable('');

    viewModel.goToNextMonth = helperLib.goToNextMonth;
    viewModel.getTargetData = function() {
        return dataHandlingLib.getTargetData(viewModel, appConfig);
    };
    viewModel.loadChoiceData = function() {
        dataHandlingLib.setCookie(viewModel);
        return dataHandlingLib.loadChoiceData(viewModel, appConfig);
    };
    
    viewModel.canGetTargetData = ko.computed(function() {
        return helperLib.canGetTargetData(viewModel);
    });
}