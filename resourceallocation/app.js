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
        
         
        var m = new rac_vm();

        m.initialize();
        console.log(m)
        return m;
    }


 });


var rac_vm = function(){
    var self = this;

    self.nbrOfMonths = ko.observable(6);
    self.startyear = ko.observable(2013);
    self.startMonth = ko.observable(2);
    self.data = ko.observableArray([]);

    self.nbrOfWeeks = ko.computed(function(){
        return self.nbrOfMonths()*4;
    })

    self.graph = null;
    
    self.months = ko.computed(function() {
    
        var d = ko.observableArray([])
        for (var i=0;i<self.nbrOfWeeks();i=i+4){ 
            a = new rac_month('Jan',1,2013)
            d.push(a)
        }

        return d;
    });

    self.weeks = ko.computed(function() {
      
        var d = ko.observableArray([])

        for (var i=0;i<self.nbrOfWeeks();i=i+1){ 
            a = new rac_week(1,2013)
            d.push(a)
        }

        return d;
    });

    self.visibleData = ko.computed(function() {
        var item
        var entry
        var month
        var d = ko.observableArray([])
        for (var p=0;p<3;p++){ 
            item = new rac_item("Item"+p)
            for (var i=0;i<self.nbrOfWeeks();i++){ 
                entry = new rac_entry(1,2013)
                item.entries.push(entry)
            }
            for (var i=0;i<self.nbrOfWeeks();i=i+4){ 
                month = new rac_month('Jan',1,2013)
                item.months.push(month)
            }
            d.push(item)
        }

        return d;
    });

    self.initialize = function(){
        
        self.redraw_graph();

        $("#rac_datagrid tr td span").tooltip()
    }

    self.getMockData = function(){
        
    }

    self.redraw_graph = function(){
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
    }
}


var rac_entry = function(week,year){
    var self = this

    self.startdate = ''
    self.enddate = ''
    self.value = 0
    self.week = week
    self.year = year
}

var rac_item = function(comment){
    var self = this

    self.comment = comment
    self.entries = ko.observableArray([])
    self.months = ko.observableArray([])
}

var rac_month = function(name,number,year){
    var self = this

    self.amount = 0
    self.name = name
    self.year = year
    self.nbr = 1
}

var rac_week = function(number,year){
    var self = this

    self.amount = 0
    self.year = year
    self.nbr = 1
}