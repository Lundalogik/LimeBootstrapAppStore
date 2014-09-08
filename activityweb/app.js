lbs.apploader.register('activityweb', function () {
    var self = this;

    //config
    this.config = {
        dataSources: [
			{type: 'xml', source: 'Activityweb.Initialize', alias:"activities"},
			{type: 'xml', source: 'Activityweb.getActivityTypes', alias:"activitytypes"}
		],
        resources: {
            scripts: ['Chart.js'],
            styles: ['app.css'],
            libs: ['json2xml.js']
        }
    },

    //initialize
    this.initialize = function (node, viewModel) {
		
		//fix context from app.html
		var ctx = document.getElementById("webchart").getContext("2d");
		
        //insert the datamodels into a variables
		var typedata = viewModel.activitytypes.data.activitytypes;
		var data = viewModel.activities.data.activityweb.activities;
		var dataAll = viewModel.activities.data.activityweb.activitiesall;
		
		//populate activity names
		var activityNames = []
		$.each(typedata.typename, function(index, typename){
			activityNames[index] = typename.activityname;
			//alert(activityNames[index]);
		});
		
		//populate activity values
		var activityValues = []
		for (var i = 0; i < activityNames.length; i++) {
			activityValues.push(0);
		};
		
		var activityValuesAll = []
		for (var i = 0; i < activityNames.length; i++) {
			activityValuesAll.push(0);
		};
		
		$.each(data.value, function(index, value){
		
			activityValues[activityNames.indexOf(value.activitytype)] = value.amount;
			//alert(activityNames.indexOf(value.activitytype));
			//alert(value.activitytype);
			//alert(value.amount);

		});
		
		$.each(dataAll.value, function(index, value){
		
			activityValuesAll[activityNames.indexOf(value.activitytype)] = value.amount;
			//alert(activityNames.indexOf(value.activitytype));
			//alert(value.activitytype);
			//alert(value.amount);

		});
		
		
		//create an array where we set the label and value info that the activity chart needs
		var dataArray = {
    labels: activityNames,
    datasets: [
        {
            label: "My First dataset",
            fillColor: "rgba(151,187,205,0.2)",
            strokeColor: "rgba(151,187,205,1)",
            pointColor: "rgba(151,187,205,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(151,187,205,1)",
            data: activityValues
        },
        {
            label: "My First dataset",
            fillColor: "rgba(220,220,220,0.2)",
            strokeColor: "rgba(220,220,220,1)",
            pointColor: "rgba(220,220,220,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: activityValuesAll
        }
    ]
};
		
		//loop through dataArray and push all available activities and values into it
		//$.each(data.value, function(index, value){
		//	dataArray.push({label:value.activitytype, value:value.amount})
		//});
				
		//intialize the donut
        new Chart(ctx).Radar(dataArray);
		
		return viewModel;
    }
});