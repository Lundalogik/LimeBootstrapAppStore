	lbs.apploader.register('donut', function () {
    var self = this;
    
    self.config =  function(appConfig){
           // this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
            this.dataSources = [{type: 'xml', source: 'Donutchart.Initialize', alias:"participants"}];
            this.resources = {
                scripts: ['morris.js', 'raphael-min.js'],
                styles: ['app.css'],
                libs: []
            };
    };
    
    self.initialize = function (node, viewModel) {
		//insert the datamodel into a variable
		var data = viewModel.participants.data.participants;
		
		//create an array where we set the label and value info that the donut chart needs
		var dataArray = [];
		
		//loop through dataArray and push all available participant statuses and values into it
		$.each(data.value, function(index, value){
			dataArray.push({label:value.participantstatus, value:value.counter})
		});
				
		//intialize the donut
        Morris.Donut({			
            element: 'donutchart',
            data: dataArray,
			colors: ['#FF0000','#F79646','#0F8B05','#0000FF']
        });
		
		return viewModel;
    };
});
