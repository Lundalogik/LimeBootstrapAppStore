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


rac.Row = function(text, time, nbrOfWeeks){
    var self = this;

    self.text = ko.observable(text);

    self.weeks = ko.computed(function(){
        var d = ko.observableArray([]);
        var w = null;

        for (var i=0;i<nbrOfWeeks();i++){
            w = new rac.Week(time);
            time().inc(1);
            d.push(w);
        }

        return d;
    });
    
    self.months = ko.computed(function(){
        return "test";
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

rac.Month = function(date,amount){
    var self = this;

    self.amount = ko.observable(amount);

    
    self.name = ko.computed(function(){
        return self.date().format("MMMM");
    })

}


rac.Time = function(year,week){
    var self = this;

    self.year = year;
    self.week = week;

    self.inc = function(weeks){
        self.week = self.week+weeks > 52 ? self.week % 52 : self.week+weeks;
        self.year = self.week+weeks > 52 ? self.year + Math.floor(self.week / 52) : self.year;
    };

    self.dec = function(weeks){
        self.week = self.week-weeks < 0 ? self.week % 52 : self.week+weeks;
        self.year = self.week-weeks < 0 ? self.year + Math.floor(self.week / 52) : self.year;
    };

    self.startDate = ko.computed(function(){
        return 0;
    });

    self.endDate = ko.computed(function(){
        return 0;
    });

}