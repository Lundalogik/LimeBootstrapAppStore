
var rac = rac || {};

rac.Vm = function(){
    var self = this;

    self.nbrOfWeeks = ko.observable(20);
    self.entries = ko.observableArray([]);
    self.startTimer = ko.observable();

    self.graph = null;

    self.setTimer = function(){
        console.log(moment().week())
        var t = new rac.Time(moment().year(),moment().week());
        t.dec(4);
        self.startTimer(t);
    }

    self.prevWeek = function(){
        
        self.startTimer().dec(1);
        self.startTimer(self.startTimer());

    }
    self.nextWeek = function(){
      
        self.startTimer().inc(1);
        self.startTimer(self.startTimer());
    }

    self.load = function(){
        var dataEntry = null;

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

    self.initialize = function(){
       
        self.setTimer();
        //self.load();

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

    // **********************************
    // ROWS
    // **********************************
    self.startTimer.subscribe(function(newValue) {
        console.log("Timer changed ");
    });

    self.headerRow =  ko.computed(function() {
        if(self.startTimer())
            return new rac.Row('headers',self.startTimer(),self.nbrOfWeeks());
    });

    self.sumRow =  ko.computed(function() {
        //console.log("rows recalculated");
        if(self.startTimer())
            return new rac.Row('SUM',self.startTimer(),self.nbrOfWeeks());
    });

    self.rows =  ko.computed(function() {
        
        if(!self.startTimer()){
            return null;
        }

        var d = ko.observableArray([]);
        var search = null;
        var a = null;
        
        ko.utils.arrayForEach(self.entries(), function(o){
            
            //check if already exists
            search = ko.utils.arrayFirst(d(), function(item) {
                return item.text == o.text;
            });

            //add
            if(!search){
                a = new rac.Row(o.text,self.startTimer(),self.nbrOfWeeks());
                d.push(a);
            };

        });

        return d();
    }).extend({ notify: 'always' });

    
}