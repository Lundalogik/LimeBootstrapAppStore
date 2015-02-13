lbs.apploader.register('newscarousel', function () {
    var self = this;

    this.config = {
        dataSources: [

        ],
        resources: {
            scripts: [],
            styles: ['app.css'],
            libs: ['json2xml.js']
        }
    };

    this.initialize = function(node, viewModel) {

        //Use this method to setup you app.
        //
        //The data you requested along with activeInspector are delivered in the variable viewModel.
        //You may make any modifications you please to it or replace is with a entirely new one before returning it.
        //The returned viewmodel will be used to build your app.

        viewModel.uniqueId = Math.random().toString(36).substring(10);
        viewModel.news = ko.observableArray([
            {
                heading: 'Nyheter i LIME Pro',
                text: 'Nu finns en fin liten nyhets-snurra i LIME Pros actionpad!'
            },
            {
                heading: 'Nyhetstorka 1',
                text: 'Så värst mycket mer kan jag inte komma på att skriva tyvärr…'
            },
            {
                heading: 'Nyhetstorka 2',
                text: 'Så värst mycket mer kan jag inte komma på att skriva tyvärr… Så värst mycket mer kan jag inte komma på att skriva tyvärr… Så värst mycket mer kan jag inte komma på att skriva tyvärr… Så värst mycket mer kan jag inte komma på att skriva tyvärr… Så värst mycket mer kan jag inte komma på att skriva tyvärr…'
            },
            {
                heading: 'Nyhetstorka 3',
                text: 'Så värst mycket mer kan jag inte komma på att skriva tyvärr…'
            }
        ]);

        return viewModel;
    };
});