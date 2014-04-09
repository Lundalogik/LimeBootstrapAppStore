var rac = rac || {};

rac.Entry = function(text,amount,year,week,limeid){
    var self = this;

    self.text = ko.observable(text);
    self.amount = ko.observable(amount);

    self.week = ko.observable();
    self.year = ko.observable();

    self.time = ko.computed(function(){
        return new rac.Time(self.year,self.week);
    });

    self.limeid = ko.observable(limeid);
    self.updated = ko.observable(false);
    self.deleted = ko.observable(false);
    self.new = ko.observable(false);
    self.primary = ko.observable(false);
}


rac.Row = function(text, startTime, nbrOfWeeks){
    var self = this;
    var time = new rac.Time(startTime.year,startTime.week);
    time.dec(1);

    self.text = ko.observable(text);

    self.weeks = ko.computed(function(){
        var d = ko.observableArray();
        var w = null;

        for (var i=0;i<nbrOfWeeks;i++){

            time = new rac.Time(time.year,time.week);
            time.inc(1);
            w = new rac.Week(time);

            d.push(w);
        }

        return d();
    });
    
    self.months = ko.computed(function(){
        var c = ko.observableArray();
        var m = null;

        ko.utils.arrayForEach(self.weeks(), function(w){

            //check if already exists
            m = ko.utils.arrayFirst(c(), function(item) {
                
                return item.time.month() == w.time.month();
            });

            //add month
            if(!m){
                m = new rac.Month(w.time);
                c.push(m);
            }

            m.weeks().push(w);

        });

        return c();
    });

}

rac.Week = function(time){
    var self = this;

    self.time = time;

    self.amount = ko.computed(function(){
        return 0;
    });

    self.name = ko.computed(function(){
        return self.time.week;
    });

}

rac.Month = function(time){
    var self = this;

    self.time = time;
    self.weeks = ko.observableArray();

    self.amount = ko.computed(function(){
        return 0;
    });

    self.name = ko.computed(function(){
        
        return self.time.date().format("MMMM");
    })

}


rac.Time = function(year,week){
    var self = this;

    self.year = year;
    self.week = week;

    self.inc = function(weeks){
        var week = self.week;
        var year = self.year;

        var newWeek = week+weeks > 52 ? ((week+weeks) % 52) : week+weeks;
        var newYear = week+weeks > 52 ? year + Math.abs(Math.floor(self.week / 52)+1) : year;
        self.week = (newWeek);
        self.year = (newYear);
        
    };

    self.dec = function(change){
        var week = self.week;
        var year = self.year;
        var newWeek = week-change < 1 ? (52 - Math.abs((week-change) % 52)) : week-change;
        var newYear = week-change < 1 ? year - (Math.floor(week-change / 52) +1) : year;
        
        self.week = (newWeek);
        self.year = (newYear);
    };

    self.date = ko.computed(function(){
        var date = moment(new Date());
        date.isoWeekday(1);
        date.year(self.year);
        date.week(self.week);
        //date.startOf('week');
        return date;
    });

    self.startDate = ko.computed(function(){
        return 0;
    });

    self.endDate = ko.computed(function(){
        return 0;
    });

    self.month = ko.computed(function(){
        return self.date().month();
    });
}