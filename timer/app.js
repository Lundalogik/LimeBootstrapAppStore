lbs.apploader.register('timer', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
            this.dataSources = [{type:'activeInspector', alias:'activeInspector'}];
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
        var vm = function(){
            var self = this;
            self.activeInspector = lbs.loader.loadDataSources({},[ {type: 'activeInspector', alias: 'activeInspector'}]).activeInspector;
            self.startTime = ko.observable();
            self.mstimer = ko.observable(self.activeInspector.time.text * 1000 * 60);
            self.minutes = ko.computed(function(){
                var m = Math.floor(self.mstimer() / 60000);
                return m < 10 ? "0" + m : ""+ m;
            });
            self.seconds = ko.computed(function(){
                var m = Math.floor(self.mstimer() / 1000) - Math.floor(self.mstimer() / 60000)*60;
                
                return m < 10 ? "0" + m : "" + m;
            });
            self.continueTimer = ko.observable(false);
            self.startStopText = ko.computed(function(){
                return this.continueTimer() ? "Stop" : "Start";
            });

            self.runTimer = function(){

                if(self.continueTimer()){
                    self.mstimer(mstimer() + 100)
                    //self.currentTime(Math.floor(self.mstimer() / 1000));
                    setTimeout(self.runTimer, 100);
                }
            }
            self.test = ko.observable("hej");

            self.start = function(){
                self.continueTimer(!self.continueTimer());
                var m;

                if(self.continueTimer()){
                    if(self.startTime() === 'undefined'){
                        m = moment();
                    }
                    else{
                        m = self.startTime();
                    }
                    self.startTime(m);
                    setTimeout(self.runTimer, 100);
                }
            }
            self.clearTime = function(){
                self.mstimer(self.activeInspector.time.text * 1000 * 60);
            }
            self.stop = function(){
                self.continueTimer(false);
            }
            self.saveTime  = function(){
                lbs.common.executeVba("Timer.SaveTime, " + Math.ceil(self.mstimer()/60000));
            }

        }
        return vm;
    };
});
