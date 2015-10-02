lbs.apploader.register('helpdeskhelper', function () {
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

            this.className = appConfig.className;
            this.filterName = appConfig.filterName;
            this.timer = appConfig.timer;
            this.icon = appConfig.icon;
            this.bgcolor = appConfig.bgcolor;
            this.fontcolor = appConfig.fontcolor;
            this.text1 = appConfig.text1;            
            this.usergroup = appConfig.usergroup;
            this.colorlevels = appConfig.colorlevels;
            
        
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
        
        

        // Variables from config
        var className = (self.config.className === '' ? 'helpdesk' : self.config.className);
        var filterName = (self.config.filterName === '' ? '[Alla]' : self.config.filterName);
        var timer = (self.config.timer === '' ? 300000 : (self.config.timer * 60000));
        var userGroup = (self.config.userGroup === '' ? 'Användare' : self.config.userGroup);

        if (timer < 300000) {
            timer = 10000;
        }   
        //timer = 10000;     
        // Data from config
        viewModel.icon = ko.observable((self.config.icon === '' ? 'fa-ambulance' : self.config.icon));
        viewModel.bgcolor = ko.observable((self.config.bgcolor.low === '' ? '#e56c19' : self.config.bgcolor.low));
        viewModel.fontcolor = ko.observable((self.config.fontcolor === '' ? '#fff' : self.config.fontcolor));
        viewModel.text1 = ko.observable((self.config.text1 === '' ? '' : self.config.text1));        
        viewModel.showapp = ko.observable(lbs.common.executeVba('HelpdeskHelper.ShowApp,' + self.config.usergroup));
        var counterdata = lbs.common.executeVba('HelpdeskHelper.Count,' + className + ',' + filterName);
        counterdata = $.parseJSON(counterdata);
        viewModel.counter = ko.observable(counterdata.ActiveFilter);

        viewModel.newerrands = ko.observable(counterdata.HitCount - lbs.bakery.getCookie("helpdeskhelper123"));
        viewModel.showtext = ko.observable(true);

        var helpdeskhelperclass = lbs.bakery.getCookie("helpdeskhelperclass");
        if (helpdeskhelperclass === "small") {
            $('.helpdeskhelper').addClass("small");
            viewModel.showtext(false);
        }

        helpdeskcounter = function () {            
            counterdata = lbs.common.executeVba('HelpdeskHelper.Count,' + className + ',' + filterName);
            counterdata = $.parseJSON(counterdata);

            if (counterdata.ActiveFilter <= -1) {                
                viewModel.newerrands(counterdata.HitCount - lbs.bakery.getCookie("helpdeskhelper123"));                
                }
            else {                
                    viewModel.newerrands(counterdata.HitCount - counterdata.ActiveFilter);                    
                    lbs.bakery.setCookie("helpdeskhelper123", counterdata.ActiveFilter, 100);                    
            }
            changebackgroundcolor();
        }


        changebackgroundcolor = function () {            
            if (viewModel.newerrands() <= self.config.colorlevels.low) {
                viewModel.bgcolor((self.config.bgcolor.low === '' ? '#e56c19' : self.config.bgcolor.low));
            }
            else if ((viewModel.newerrands() > self.config.colorlevels.low && viewModel.newerrands() <= self.config.colorlevels.medium)) {
                viewModel.bgcolor((self.config.bgcolor.medium === '' ? '#e56c19' : self.config.bgcolor.medium));
            }
            else if (viewModel.newerrands() > self.config.colorlevels.medium) {
                viewModel.bgcolor((self.config.bgcolor.high === '' ? '#e56c19' : self.config.bgcolor.high));
            }            
        }

        viewModel.showfilter = function () {
            lbs.common.executeVba('HelpdeskHelper.SetFilter,' + className + ',' + filterName);
            viewModel.newerrands(0);
            changebackgroundcolor();
        }
        changebackgroundcolor();
        setInterval(function () {
            helpdeskcounter();
        }, timer);

        return viewModel;
    };
});

ko.bindingHandlers.doubleclick = {
    init: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
        $(element).on('dblclick', function (event) {
            if ($(element).hasClass("small")) {                
                lbs.bakery.setCookie("helpdeskhelperclass", "", 100);
                $(element).removeClass("small");
                viewModel.showtext(true);
            }
            else {
                viewModel.showtext(false);
                $(element).addClass("small");
                lbs.bakery.setCookie("helpdeskhelperclass", "small", 100);
                
            }
        });

    },
    update: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
        //$(element).attr({'data-toggle':'popover','data-container':'body','data-content':valueAccessor(),'data-placement':'top'});   
    }
};