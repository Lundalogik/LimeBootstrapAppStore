lbs.apploader.register('newscarousel', function () {
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

        viewModel.myappname = 'Nyheter';
        viewModel.myapptext = 'Blah blah blah';

        viewModel.news = ko.observableArray([
            {
                heading: 'Nyheter i LIME Pro',
                text: 'Nu finns en fin liten nyhets-snurra i LIME Pros actionpad!'
            },
            {
                heading: 'Nyhetstorka',
                text: 'Så värst mycket mer kan jag inte komma på att skriva tyvärr…'
            },
            {
                heading: 'Nyhetstorka',
                text: 'Så värst mycket mer kan jag inte komma på att skriva tyvärr…'
            }
        ]);

        return viewModel;
    }
});