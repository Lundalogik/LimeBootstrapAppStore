
var solrClient = solrClient || {}

solrClient.filterClass = function(name,selected){
	this.name = name;
	this.selected = ko.observable(selected);
	this.activeClass = ko.computed(function() {
        return this.selected() ? 'btn btn-success' : 'btn btn-default';
    }, this);

    this.toggle = function(){
    	this.selected(!this.selected());
    }
}

solrClient.viewModel = function(){
	var self = this;

	self.query = ko.observable("");
	self.endpoint = '';
	self.results = ko.observableArray();
	self.filterClasses = ko.observableArray([
		(new solrClient.filterClass('document',false)),
		(new solrClient.filterClass('person',false)),
		(new solrClient.filterClass('company',false)),
		]);
	self.rows = ko.observable(10000);
	self.start = ko.observable(0);

	self.activeQueryFilter = ko.computed(function() {
       	var fq = [];
	    ko.utils.arrayForEach(self.filterClasses(), function(item) {

	        if (item.selected() == true) {
	            fq.push(item.name);
	        }
	    });
	    return fq.length > 0 ? "ldeclass:("+fq.join(' ')+")" : "";
		 
    }, self);

	self.query.subscribe(function(newValue) {self.getData();});
	self.rows.subscribe(function(newValue) {self.getData();});
	self.start.subscribe(function(newValue) {self.getData();});
	self.activeQueryFilter.subscribe(function(newValue) {self.getData();});
	
	self.openRecord = function(record){
		lbs.common.executeVba("shell," + lbs.common.createLimeLink(record.ldeclass, record.idrecord));
	}

	self.getData = function(){

		$.ajax({ 
		 type: "GET",
		 url: self.endpoint+"/select",
		 data: {
			  	wt:'json',
			  	q:self.query,
			  	rows:self.rows,
			  	start:self.start,
			  	fq:self.activeQueryFilter(),
			  },
		  dataType: 'jsonp',
		  timeout: 10000,
		  jsonp: "json.wrf",
		  jsonpCallback: 'processData',
		  success: function(data){
		  	self.results(data.response.docs);
		  },

		});
	}

	self.searchCmd = function() {
   		self.query($("#searchbox").val());
    };

    self.searchKeyboardCmd = function (data, event) { 
        if (event.keyCode == 13) {
            self.searchCmd(); 

        }
        return true;
    }

}