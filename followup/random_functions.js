var functionLib = {
	viewModel: {},
	appConfig: {},
	pickerLoaded: false
};


// Initialize
functionLib.initialize = function(vm, ac) {
	functionLib.viewModel = vm;
	functionLib.appConfig = ac;

	functionLib.initializeCookies();
	functionLib.initializeViewModel();
	
	if(functionLib.viewModel.activeCoworker) {
    	functionLib.loadChoiceData();
    	functionLib.initializeDatepicker();
	    // Get target date if all needed info is set
	    if(functionLib.viewModel.canGetTargetData() && functionLib.viewModel.errorMessage() == '') {
	    	functionLib.viewModel.getTargetData();
	    }
    }
    else {
    	functionLib.viewModel.errorMessage(viewModel.localize.Followup.no_coworker || 'No localize found for - Followup.no_coworker');
    }
}

functionLib.initializeDatepicker = function() {
	// Initialize datepicker
	if (!functionLib.pickerLoaded) {
        functionLib.pickerLoaded = true;
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
				today: functionLib.viewModel.localize.Followup.tooltip_today || 'No localize found for - Followup.tooltip_today'
			}
        });

        $("#datetimepicker").on("dp.change", function(e) {
        	functionLib.viewModel.getTargetData();
        });
    }
}

functionLib.initializeViewModel = function() {
	functionLib.viewModel.goToNextMonth = functionLib.goToNextMonth;
	functionLib.viewModel.getTargetData = functionLib.getTargetData;
    functionLib.viewModel.canGetTargetData = ko.computed(functionLib.canGetTargetData);

	// Initial data setup
	functionLib.viewModel.coloring = {
		green: functionLib.appConfig.coloring.green,
		yellow: functionLib.appConfig.coloring.yellow
	};

	functionLib.viewModel.activeCoworker = null;
    if (lbs.limeDataConnection.ActiveUser.Record) {
    	functionLib.viewModel.activeCoworker = lbs.limeDataConnection.ActiveUser.Record.ID;
    }

    functionLib.viewModel.choices = {
    	coworkers : ko.observableArray(),
    	targettypes : ko.observableArray()
    };

    functionLib.viewModel.grouping = {
    	selected: ko.observable('coworker'),
    	latestFetched: ko.observable('coworker'),
    	changeGrouping: function(pressedType) {
    		this.selected(pressedType);
    	}
    }
    functionLib.viewModel.securityLevel = functionLib.appConfig.securityLevel;

	if (functionLib.viewModel.securityLevel == 'user') {
		functionLib.viewModel.grouping.selected('target');
	}
	else {
		functionLib.viewModel.grouping.selected(functionLib.cookieObj.groupby);
	}

    functionLib.viewModel.parents = ko.observableArray();
    functionLib.viewModel.errorMessage = ko.observable('');

	functionLib.viewModel.listSizeClass = ko.observable('');
}

functionLib.initializeCookies = function() {
	functionLib.cookieName = functionLib.viewModel.activeCoworker + "followupCookie";
	functionLib.cookieObj = null;


	functionLib.cookieObj = functionLib.getCookie();
	
    // Check if cookie exists
	var existingCookieValue = lbs.bakery.getCookie(functionLib.cookieName);
	if(existingCookieValue.length > 0) {
		functionLib.cookieObj = JSON.parse(existingCookieValue);
	}
	if (!functionLib.cookieObj){
		functionLib.setCookie();
		existingCookieValue = lbs.bakery.getCookie(functionLib.cookieName);
		if(existingCookieValue.length > 0) {
			functionLib.cookieObj = JSON.parse(existingCookieValue);
		}
	}
}