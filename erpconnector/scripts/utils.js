var utils = {
	"colors": [
		{
			legendText: '#83AD09',
			legendBackground: '#E9F5C6',
			chartBackground: 'rgba(209,237,128,0.15)',//'#F7FCE9',
			chartBorder: '#D1ED80'
		},
		{
			legendText: '#2DAF93',
			legendBackground: '#C7F2E9',
			chartBackground: 'rgba(128,229,213,0.15)',//'#EAFBF8',
			chartBorder: '#80E5D5'
		},
		{
			legendText: '#4BA9D0',
			legendBackground: '#C9ECFA',
			chartBackground: 'rgba(127,223,255,0.15)',//'#EAFAFF',
			chartBorder: '#7FDFFF'
		},
		{
			legendText: '#CC78AD',
			legendBackground: '#FFCDE4',
			chartBackground: 'rgba(255,154,206,0.15)',//'#FFEEF7',
			chartBorder: '#FF9ACE'
		},
		{
			legendText: '#CC8F33',
			legendBackground: '#FFEED4',
			chartBackground: 'rgba(253,179,128,0.15)',//'#FEF2EB',
			chartBorder: '#FDB380'
		}	
	],

	"prettyNumber" : function(value, separator, currency) {
		var retval = value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, separator);
		if(currency){
			if("$£€".indexOf(currency) != -1) {
				retval = currency + retval;
			}
			else{
				retval = retval + ' ' + currency;
			}
		}
	    return retval;
	},

	"GroupOption" : function(option, viewModel) {
		var self = this;
		self.text = eval(option.text);
		self.value = option.value;

		self.selected = ko.computed(function() {
			return viewModel.groupBy() === self.value;
		});

		self.select = function() {
			viewModel.groupBy(self.value);
		}
	}
}