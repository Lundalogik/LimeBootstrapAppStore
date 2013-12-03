lbs.apploader.register('textfileimport', function () {
    var self = this;

    //config
    this.config = {
        dataSources: [

        ],
        resources: {
            scripts: [],
            styles: [],
            libs: ['appInvoker/appInvoker.js']
        }
    },

    //initialize
    this.initialize = function (viewModel,node) {

      
        return viewModel;
    }
});