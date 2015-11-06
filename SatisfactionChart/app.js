lbs.apploader.register('SatisfactionChart', function () {
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
                scripts: ['RGraph.common.core.js', 'RGraph.common.dynamic.js','RGraph.meter.js'], // <= External libs for your apps. Must be a file
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
        
        value = window.external.ActiveInspector.Controls.getValue("average_rating")


        var meter = new RGraph.Meter({
            id: 'cvs',
            min: 0,
            max: 4,
            value: value,
            options: {
                anglesStart: RGraph.PI + 0.5,
                anglesEnd: RGraph.TWOPI - 0.5,
                linewidthSegments: 10,
                textSize: 10,
                strokestyle: '#F1F6FF',
                segmentRadiusStart: 100,
                border: 0,
                tickmarksSmallNum: 0,
                tickmarksBigNum: 0,
                adjustable: true,
                needleRadius: 45,
                backgroundColor: '#F1F6FF',
                labelsCount: 4,                
                redEnd: 1.5,
                yellowStart: 1.5,
                yellowEnd: 3
            }
        }).on('beforedraw', function (obj) {
            RGraph.clear(obj.canvas, '#F1F6FF');

        }).draw();

        return viewModel;
    };
});
