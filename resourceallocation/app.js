lbs.apploader.register('resourceallocation', function () {
    var self = this;

    //config
    self.config = {
        dataSources: [

        ],
        resources: {
            scripts: [
                
                ],
            styles: [
                'app.css'
                ],
            libs: [
                "graphael/raphael-min.js",
                "graphael/g.raphael-min.js",
                "graphael/g.line-min.js",
                "moment.min.js"
                ]
        }, 

    },

    //initialize
    this.initialize = function (node,viewModel) {
        
         
        var m = new rac_vm();

        m.initialize();
        //console.log(m)
        return m;
    }


 });


var rac_vm = function(){
    var self = this;

    self.nbrOfMonths = ko.observable(12);
    self.startYear = ko.observable(2013);
    self.startMonth = ko.observable(10);
    self.data = ko.observableArray([]);

    self.nbrOfWeeks = ko.computed(function(){
        return self.nbrOfMonths()*4;
    })

    self.graph = null;

    self.createDefaultMomentTime = function(){
        var date = moment(new Date())
        date.isoWeekday(1)
        date.year(self.startYear())
        date.month(self.startMonth())
        date.startOf('month')
        return date;
    }
    
    self.months = ko.computed(function() {

        var d = ko.observableArray([])
        var date;

        for (var i=0;i<self.nbrOfMonths();i++){ 
            date = self.createDefaultMomentTime()
            date.add('M', i);
            a = new rac_monthEntry(date,0)
            d.push(a)
        }

        return d;
    });

    self.weeks = ko.computed(function() {
        var d = ko.observableArray([])
        var date;
        for (var i=0;i<self.nbrOfWeeks();i++){ 

            date = self.createDefaultMomentTime()
            date.add('w', i);
            date.startOf('week')
            a = new rac_weekEntry(date,38)

            d.push(a)
        }

        return d;
    });

    self.visibleData = ko.computed(function() {
        var item
        var entry
        var month
        var d = ko.observableArray([])
		
		//for each item in data
        for (var datanode in self.data()){ 
            item = new rac_item("Item")
            for (var sumMonthEntry in self.weeks){ 
                month = new rac_monthEntry(null,0)
                item.monthsEntries.push(month)
            }
			for (var sumWeekEntry in self.weeks){ 
				var amount = 0
				//todo check if node exists in data and set amount
                entry = new rac_weekEntry(sumWeekEntry.week,sumWeekEntry.year,amount)
                item.weekEntries.push(entry)
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

var rac_item = function(text){
    var self = this

    self.text = ko.observable(text)
    self.weekEntries = ko.observableArray([])
    self.monthsEntries = ko.observableArray([])
}

var rac_monthEntry = function(date,amount){
    var self = this

    self.date = ko.observable(date)

    self.amount = ko.observable(amount)
    
    self.year = ko.computed(function(){
        return self.date().year()
    })

    self.month = ko.computed(function(){
        return self.date().month()
    })
	
    self.startDate = ko.observable()
	
    self.endDate = ko.observable()
	
	self.name = ko.computed(function(){
        return self.date().format("MMMM")
	})
}

var rac_weekEntry = function(date,amount){
    var self = this

    self.startDate = ko.observable(date)
    self.endDate = ko.observable()
    self.startDateLime = ko.observable()
    self.endDateLime = ko.observable()
    self.amount = ko.observable(amount)
    
    self.year = ko.computed(function(){
        return self.startDate().year()
    })

    self.week = ko.computed(function(){
        return self.startDate().week()
    })

	

}