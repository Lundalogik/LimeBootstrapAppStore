lbs.apploader.register('top5', function () {
    var self = this;

    //config
    this.config = {
        dataSources: [
          {type: 'xml', source: 'Top5.Initialize', alias:"top5"}
        ],
        resources: {
            scripts: ["jquery-ui-1.10.4.js"],
            styles: ['app.css'],
            libs: ['json2xml.js']
        }
    },
	$(document).ready(function() {
		$(".toggle").hide();
		$("#header").click(function() {
			$( ".toggle" ).toggle('slide',{direction:'left'},600);
	});
	});
	
			
	

    //initialize
    this.initialize = function (node, viewModel) {
		var data;
		if (!viewModel.top5.data) {
			data = [];
		}
		else {
			data = viewModel.top5.data.top5.value;
			if (!Array.isArray(data)) {
				var arr = [data];
				data = arr;
			}
		};
        //Use this method to setup you app. 
        //
        //The data you requested along with activeInspector are delivered in the variable viewModel.
        //You may make any modifications you please to it or replace is with a entirely new one before returning it.
        //The returned viewmodel will be used to build your app.

			viewModel.top1 = ((typeof(data[0]) == "undefined") ? "--" : data[0].name);
			viewModel.top2 = ((typeof(data[1]) == "undefined") ? "--" : data[1].name);
			viewModel.top3 = ((typeof(data[2]) == "undefined") ? "--" : data[2].name);
			viewModel.top4 = ((typeof(data[3]) == "undefined") ? "--" : data[3].name);
			viewModel.top5 = ((typeof(data[4]) == "undefined") ? "--" : data[4].name);
			
			viewModel.top1value = ((typeof(data[0]) == "undefined") ? "0" : data[0].businessvalue);
			viewModel.top2value = ((typeof(data[1]) == "undefined") ? "0" : data[1].businessvalue);
			viewModel.top3value = ((typeof(data[2]) == "undefined") ? "0" : data[2].businessvalue);
			viewModel.top4value = ((typeof(data[3]) == "undefined") ? "0" : data[3].businessvalue);
			viewModel.top5value = ((typeof(data[4]) == "undefined") ? "0" : data[4].businessvalue);
			
			viewModel.top1id = ((typeof(data[0]) == "undefined") ? 999 : data[0].idcoworker);
			viewModel.top2id = ((typeof(data[1]) == "undefined") ? 999 : data[1].idcoworker);
			viewModel.top3id = ((typeof(data[2]) == "undefined") ? 999 : data[2].idcoworker);
			viewModel.top4id = ((typeof(data[3]) == "undefined") ? 999 : data[3].idcoworker);
			viewModel.top5id = ((typeof(data[4]) == "undefined") ? 999 : data[4].idcoworker);
			
			
        return viewModel;
    }
});