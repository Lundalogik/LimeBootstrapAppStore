lbs.apploader.register('businessOverview', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config = {
        //language = "",
        dataSources: [
            {type: 'xml', source: 'app_BusinessOverview.Initialize', alias:'businessoverview'}
        ],
        resources: {
            scripts: ["jquery.number.min.js"],
            styles: ['app.css'],
            libs: ["underscore-min.js"]
        },
    },

    //Initialize
    this.initialize = function(node,viewModel) {
       // if(!self.config.dayssincelast) {
       //     self.config.dayssincelast = 0;
       // }
        
        var data = lbs.common.executeVba('app_BusinessOverview.Initialize');
        self.no = [
        { test: "Herro" }
        ];
        //     var data = self.config;//viewModel.FiftyShadesOfBusiness.data.FiftyShadesOfBusiness.all;
        //alert(JSON.stringify(data));
        //ko.applyBindings(viewModel);
        // calculateDays(data)

        // function calculateDays(data) {
        // }
   
        return viewModel;
    }
});
