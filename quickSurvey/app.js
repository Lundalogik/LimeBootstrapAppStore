lbs.apploader.register('quickSurvey', function () {
    var self = this;

    //config
    this.config = {
        dataSources: [

        ],
        resources: {
            scripts: [],
            styles: ['app.css'],
            libs: ['json2xml.js']
        }
    },

    //initialize
    this.initialize = function (node, viewModel) {

        //Use this method to setup you app. 
        //
        //The data you requested along with activeInspector are delivered in the variable viewModel.
        //You may make any modifications you please to it or replace is with a entirely new one before returning it.
        //The returned viewmodel will be used to build your app.


        /*
        - Timer som pollar
        - anropa vba funktion som:
            - går igenom surveytabellen
            - hämtar alla aktiva frågor
            - kortast deadline först


        */


        //viewModel.myappname = 'This is an example app';
        //viewModel.myapptext = 'The JS solution whould work nicely as <br />a template you know ;)';

        viewModel.xmlQuestions = ko.observable();
        viewModel.text = ko.observable();
        viewModel.qtype = ko.observable();
        viewModel.id = ko.observable();

        viewModel.answer = ko.observable();
        viewModel.SaveAnswer = function(){
            var answer = $("#answer").val();
            lbs.common.executeVba('Yo.SaveAnswer,'+ answer + ', ' + viewModel.id());
            self.checkQuestions();
        };
        self.startTimer = function(){
            setInterval(function() {self.checkQuestions();
            },5000);
        };

        //Kör var 300e millisekund. Hämtar senaste frågan 
        self.checkQuestions= function() {            
            viewModel.xmlQuestions(lbs.common.executeVba('Yo.GetQuestionsXML'));
    
//            var xmlData = lbs.common.executeVba('HistoryFlow.GetHistories,' + appConfig.table + "," + appConfig.hitcount); 
            var json = xml2json($.parseXML(viewModel.xmlQuestions()),''); 
            json = $.parseJSON(json); 
            viewModel.text(json.yo.text);
            viewModel.qtype(json.yo.type);
            viewModel.id(json.yo.id);  
        };

        self.startTimer();
        return viewModel;
    }
});