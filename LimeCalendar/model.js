var model = {
	GenericModel: function(viewModel, item, table, view, locales, title, start, end, options) {
		var self = this;
		self.view = ko.observableArray(view.split(';'));
		self.locales = ko.observableArray(locales.split(';'));
		self.table = table;
		self.id = item['id' + table.table].value;
		self.initials = ko.utils.arrayMap(item[options.initialField].text.split(' '), function(name) {
			return name.substring(0,1);
		}).join('').toUpperCase();
		self.title = item[title].text + ' (' + self.initials + ')';
		self.detailsTitle = item[title].text;
		self.startfield = start;
		self.endfield = end;
		self.start = moment(item[start].text).format(options.dateformat);
		self.end = moment(item[end].text).format(options.dateformat);
		self.fields = ko.observableArray(ko.utils.arrayMap(self.view(), function(field, index) {
			return {
				name: eval('viewModel.localize.LimeCalendar.' + self.locales()[index]),
				value: item[field].value,
				text: item[field].text
			}
		}));
		self.dateFormat = options.dateformat;
		self.backgroundColor = options.backgroundColor;
		self.color = options.color;
		self.borderColor = options.borderColor;
	},

	Coworker: function(viewModel, item){
		var self = this;
		self.name = item.name.text;
		self.id = item.idcoworker.value;

		self.selected = ko.computed(function() {
			if(!viewModel.selectedCoworker()){
				return false;
			}
			return self.id === viewModel.selectedCoworker().id;
		});
		
		self.select = function(){
			if(!viewModel.selectedCoworker()){
				viewModel.selectedCoworker(self);
			}
			else {
				viewModel.selectedCoworker(viewModel.selectedCoworker().id === self.id ? null : self);
			}
		}
	},

	Table: function(viewModel, item) {
		var self = this;
		self.options = item.options;
		self.table = item.table;
        self.name = item.tableLocale;
        self.excluded = ko.observable(false);
        self.backgroundColor = ko.computed(function() {
        	return self.excluded() ? '#FFF' : self.options.backgroundColor;
        });
        self.textColor = ko.computed(function() {
        	return self.excluded() ? self.options.backgroundColor : '#FFF';
        });
        self.exclude = function() {
        	self.excluded(!self.excluded());
        	viewModel.setItems();
        }
	}
}
