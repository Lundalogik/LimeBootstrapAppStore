lbs.apploader.register('template', function () {
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

        viewModel.myappname = 'This is an example app';
        viewModel.myapptext = 'The JS solution whould work nicely as <br />a template you know ;)';


        return viewModel;
    }
});