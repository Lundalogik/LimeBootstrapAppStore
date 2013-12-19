lbs.apploader.register('resourceallocation', function () {
    var self = this;

    //config
    self.config = {
        dataSources: [

        ],
        resources: {
            scripts: [],
            styles: ['app.css'],
            libs: [
                "graphael/raphael-min.js",
                "graphael/g.raphael-min.js",
                "graphael/g.line-min.js",
                ]
        }, 

    },

    //initialize
    this.initialize = function (node,viewModel) {
        
         
        var m = new resourceallocation();
        m.initialize();

        return viewModel;
    }


 });


var resourceallocation = function(){
    var self = this;

    self.initialize = function(){
        var r = Raphael("simpleExample");
        var chart = r.linechart(
            0, 0,      // top left anchor
            800, 200,    // bottom right anchor
            [
              [1, 2, 3, 4, 5, 6, 7],        // red line x-values
              [3.5, 4.5, 5.5, 6.5, 7, 8]    // blue line x-values
            ], 
            [
              [12, 32, 23, 15, 17, 27, 22], // red line y-values
              [10, 20, 30, 25, 15, 28]      // blue line y-values
            ],
            {
                axis: "0 0 1 1",

            }
        );


        $("#rac_datagrid tr td span").tooltip()
    }

}

var limeAllocationEntry = function(){
    var self = this;

    self.idcoworker = '';
    self.startdate = '';
    self.enddate = '';
    self.value = '',
    self.comment = ''
}