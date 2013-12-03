lbs.apploader.register('devtest', function () {
    var self = this;

    //config
    this.config = {
        dataSources: [
        	//{type: 'records', source: 'Globals.testrecords',alias: 'rcsource'}
            {type: 'record', source: 'LBSHelper.test',alias: 'rcsource'}
        ],
        resources: {
            scripts: [],
            styles: [],
            libs: []
        },
    },

    //initialize
    this.initialize = function (node, viewModel) {
        
        return {vm: JSON.stringify(viewModel.rcsource.company)}

    }
});