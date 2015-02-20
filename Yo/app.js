lbs.apploader.register('Yo', function () {
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
        var viewModel = {
            xmlQuestions : ko.observable(),
            text : ko.observable(""),
            qtype : ko.observable(""),
            id : ko.observable(""),
            answer : ko.observable("")
        };
        

        viewModel.SaveAnswer = function(suppliedAnswer, questionId){
            lbs.common.executeVba('Yo.SaveAnswer,'+ suppliedAnswer + ', ' + questionId);
            self.checkQuestions();
        };

        self.startTimer = function(){
            setInterval(self.checkQuestions(),60000);
        };
        
        self.checkQuestions= function() {
            viewModel.xmlQuestions(lbs.common.executeVba('Yo.GetQuestionsXML'));    
            var json = xml2json($.parseXML(viewModel.xmlQuestions()),''); 
            json = $.parseJSON(json);

            if(json.yo !== null){
                viewModel.text(json.yo.text);
                viewModel.qtype(json.yo.type);
                viewModel.id(json.yo.id);  
            }
            else{
                 viewModel.text("");
                viewModel.qtype("");
                viewModel.id("");  
            }
        };        
        self.startTimer();
        return viewModel;
    }
});