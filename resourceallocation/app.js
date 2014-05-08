lbs.apploader.register('resourceallocation', function () {
    var self = this;

    //config
    self.config = {
        dataSources: [

        ],
        resources: {
            scripts: [
                'js/vm.js',
                'js/entities.js',
                'js/utils.js'
                ],
            styles: [
                'app.css'
                ],
            libs: [
                'moment.min.js',
                'graphael/raphael-min.js',
                'graphael/g.raphael-min.js',
                'graphael/g.line-min.js',
                
                ]
        },
    },

    //initialize
    this.initialize = function (node,viewModel) {
        var m = new rac.Vm();
        //window.racVm = m;
        m.initialize();
        //console.log(m)
        return m;
    }


 });




