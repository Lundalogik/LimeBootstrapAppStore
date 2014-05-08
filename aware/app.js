lbs.apploader.register('info', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.icon1 = appConfig.icon1;          
            this.icon2 = appConfig.icon2;
            this.icon3 = appConfig.icon3;
            this.text1 = appConfig.text1;
            this.text2 = appConfig.text2;
            this.text3 = appConfig.text3;
            

            this.dataSources = [
                appConfig.dataSource
            ];
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

        switch(viewModel.aware.row.myvar){
            case '1':
                viewModel.icon = self.config.icon1;
                viewModel.issue = self.config.text1;
                viewModel.tileColor = "rgb(232, 89, 89)";
            break;
            case '2':
                viewModel.icon = self.config.icon2;
                viewModel.issue = self.config.text2;
                viewModel.tileColor =  "rgb(244, 187, 36)";
            break;
            case '3':
                viewModel.icon = self.config.icon3;
                viewModel.issue = self.config.text3;
                viewModel.tileColor =  "rgb(153, 216, 122)";
            break;
        }

        return viewModel;
    };
});
