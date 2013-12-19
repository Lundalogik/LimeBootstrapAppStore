lbs.apploader.register('rsourceallocation', function () {
    var self = this;

    //config
    self.config = {
        dataSources: [
          {type: 'xml', source: 'Businessfunnel.Initialize', alias:"businessfunnel"}
        
        ],
        resources: {
            scripts: [""],
            styles: ['app.css'],
            libs: [""]
        }, 

    },

    //initialize
    this.initialize = function (node,viewModel) {
         
    }


 });

