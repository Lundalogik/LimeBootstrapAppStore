
var rac = rac || {};

rac.Vm = function(){
    var self = this;

    self.nbrOfWeeks = ko.observable(52);
    self.startYear = ko.observable(2013);
    self.startWeek = ko.observable(50);
    self.entries = ko.observableArray([]);
    
    self.startTimer = ko.computed(function(){
        return new rac.Time(self.startYear,self.startWeek);
    });


    self.graph = null;

    self.load = function(){
        var dataEntry = null;

        //TODO: get data;
        //TODO: convert to internal object type
        self.entries.removeAll();

        var dummy = [
            {
                text : 'test1',
                amount : 5,
                startdate : '2014-01-01',
                enddate : '2014-01-03',
                limeid : 101
            },
            {
                text : 'test2',
                amount : 8,
                startdate : '2014-02-05',
                enddate : '2014-02-10',
                limeid : 102
            }   
        ];

        $(dummy).each(function(i, o){
            dataEntry = new rac.Entry(o.text, o.amount, 2014, 2, o.limeid);
            self.entries.push(dataEntry);
        });
    };

    // self.createDefaultMomentTime = function(){
    //     var date = moment(new Date());
    //     date.isoWeekday(1);
    //     date.year(self.startYear());
    //     date.month(self.startMonth());
    //     date.startOf('month');
    //     return date;
    // }

    // self.findByText = function(arr,text){
    //     return $.grep(arr, function(e){ return e.text == text; });
    // };

    // **********************************
    // ROWS
    // **********************************
    self.rows =  ko.computed(function() {
        var d = ko.observableArray([]);
        var search = null;
        
        ko.utils.arrayForEach(self.entries(), function(o){
            
            //check if already exists
            search = ko.utils.arrayFirst(d(), function(item) {
                return item.text == o.text;
            });

            //add
            if(!search){
                a = new rac.Row(o.text,self.startTimer,self.nbrOfWeeks);
                d.push(a);
            };

        });

        return d();
    });

    self.initialize = function(){
        self.load();
		
        console.log(self.entries());
        console.log(self.rows()[0].weeks());

        self.redraw_graph();
        $("#rac_datagrid tr td span").tooltip();
    };

	
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