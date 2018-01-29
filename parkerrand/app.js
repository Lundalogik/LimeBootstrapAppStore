lbs.apploader.register('parkerrand', function () {
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
                scripts: ['bootstrap-datepicker.js'], // <= External libs for your apps. Must be a file
                styles: ['app.css','datepicker.css'], // <= Load styling for the app.
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
        viewModel.newValue = ko.observable('');
		viewModel.valueSubscriber = ko.observable();
		
		viewModel.valueSubscriber = ko.computed(function(){			
			if(viewModel.newValue() != ''){		
				var parkeddate =  moment(viewModel.newValue()).add(8,'hours').format('YYYY-MM-DD hh:mm');
				var deadlinedate = moment(viewModel.newValue()).add(3,'days').add(8,'hour').format('YYYY-MM-DD hh:mm');				
				lbs.common.executeVba('ActionPad_Helpdesk.ParkWithDatepicker,' + parkeddate + ',' + deadlinedate);
			}
			return viewModel.newValue();
		});
        return viewModel;
    };
});
ko.bindingHandlers.datepicker = {
    init: function(element, valueAccessor, allBindingsAccessor) {
      //initialize datepicker with some optional options
      var d = moment().format('YYYY-MM-DD');
      var options = allBindingsAccessor().datepickerOptions || {format: 'yyyy-mm-dd', autoclose: true,weekStart:1,todayHighlight:true,startDate:d,orientation:'left top'};
      $(element).datepicker(options);
      
      //when a user changes the date, update the view model
      ko.utils.registerEventHandler(element, "changeDate", function(event) {
             var value = valueAccessor();
             if (ko.isObservable(value)) {
                 value(event.date);
             }                
      });
    },
    update: function(element, valueAccessor)   {
        var value, widget = $(element).data("datepicker");
         //when the view model is updated, update the widget
        if (widget) {
            value = ko.utils.unwrapObservable(valueAccessor());
            
            if (!value) { 
               $(element).val("").change();
               return;
            }

            widget.setDate(_.isString(value) ? new Date(value) : value);
        }
    }
};