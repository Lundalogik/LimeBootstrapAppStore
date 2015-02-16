lbs.apploader.register('History flow', function () {
    var self = this;


    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.appConfig = appConfig;
            this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
            this.dataSources = [];
            this.resources = {
                scripts: ['VerticalTimeline/js/modernizr.custom.js'], // <= External libs for your apps. Must be a file
                styles: ['app.css', 'VerticalTimeline/css/component.css', 'VerticalTimeline/css/default.css'], // <= Load styling for the app.
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
        var appConfig = self.config.appConfig;      
        viewModel.histories = ko.observableArray();
        function History(
            title
            ,text
            ,date
            ,time
            ,icon
            ,idhistory
            ,person
            ){
                this.title = title;
                this.text = text;
                this.date = date;
                this.icon = icon;
                this.time = time;
                this.person = person;
                this.idhistory = idhistory;

                this.openpost = function(){
                    var limelink = lbs.common.createLimeLink('history', this.idhistory);                    
                    document.location.href(limelink);
                };            
            return this;
        };
        var xmlData = lbs.common.executeVba('HistoryFlow.GetHistories,' + appConfig.table + "," + appConfig.hitcount);        
        var json = xml2json($.parseXML(xmlData),'');
        json = $.parseJSON(json);
        viewModel.root = json;         
        if(Object.prototype.toString.call(viewModel.root.histories) != '[object Null]'){
            if(Object.prototype.toString.call(viewModel.root.histories.history) === '[object Array]'){
                if(viewModel.root.histories != null){
                    $.each(viewModel.root.histories.history, function(index, history){
                        var h = new History(history.title, history.text, history.date, history.time, history.icon, history.idhistory, history.person);           
                        viewModel.histories.push(h);
                    });            
                }
            }        
            else{
                var history = viewModel.root.histories.history
                var h = new History(history.title, history.text, history.date, history.time, history.icon, history.idhistory, history.person);           
                viewModel.histories.push(h);
            }      
        }  
        return viewModel;
    };
});
