lbs.apploader.register('Pipeline', function () {
	var self = this;

	/*Config (version 2.0)
		This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
		App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
		The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
	*/
	self.config =  function(appConfig){
		   
			// Set default values from config
			this.table               = appConfig.table || 'business';
			this.statusfield         = appConfig.statusfield || 'businesstatus';
			this.valuefield          = appConfig.valuefield || 'businessvalue';
			this.shadowValuefield    = appConfig.shadowValuefield || '';
			this.Filters             = appConfig.Filters || [];
			this.currency            = appConfig.currency || 'tkr';
			this.divider             = appConfig.divider || 1000;
			this.decimals            = appConfig.decimals || 0;
			this.delimiterChar       = appConfig.delimiterChar || ' ';
			this.excludeStatuses       = appConfig.excludeStatuses || '';

			this.dataSources = [];
			this.resources = {
			   scripts: ['jquery.number.min.js'], // <= External libs for your apps. Must be a file
			styles: ['app.css'], // <= Load styling for the app.
				libs: ['underscore-min.js'] // <= Allready included libs, put not loaded per default. Example json2xml.js
			};
	};

	//initialize
	/*Initialize
		Initialize happens after the data and recources are loaded but before the view is rendered.
		Here it is your job to implement the logic of your app, by attaching data and functions to 'viewModel' and then returning it
		The data you requested along with localization are delivered in the variable viewModel.
		You may make any modifications you please to it or replace is with a entirely new one before returning it.
		The returned viewModel will be used to build your app.
		
		Node is a reference to the HTML-node where the app is being initalized form. Frankly we do not know when you'll ever need it,
		but, well, here you have it.
	*/
	self.initialize = function (node, viewModel) {
		
		viewModel.lastupdate = ko.observable();
		viewModel.filterIndex = ko.observable();
		viewModel.filterText = ko.observable("");
		
		viewModel.values = ko.observableArray();

		// Fetching localize or give error-text
		getLocalizedlabel = function(owner, code)
		{
			if (viewModel.localize && viewModel.localize[owner] && viewModel.localize[owner][code])
			{
				return viewModel.localize[owner][code];
			}
			else
			{
				return "Localize not found [" + owner + "].[" + code + "]";
			}
		}

		getMaxAll = function(dataset){
			var maxAll = 0;
			for (var j = 0; j < dataset.length; j++) {
				
					maxAll = maxAll + parseFloat(parseFloat(dataset[j].value));
				
			};
			return maxAll;
		}

		formatMoney = function(originalValue) {
			return $.number(
						(parseFloat(originalValue)/self.config.divider), self.config.decimals, ',', self.config.delimiterChar
					) + ' ' + self.config.currency
		}

		// Reload data if user press refresh use selected filter
		refresh = function(){
			try{
				var index = viewModel.filterIndex();
				var entry = viewModel.filters[index];
				loadData(entry.filter);
			}catch(e){
				alert(e);
			}
		}

		goToFilter = function () {
			try{
				var index = viewModel.filterIndex();
				var entry = viewModel.filters[index];
				lbs.common.executeVba("PipelineModule.GoToFilter," + self.config.table + ", " + self.config.statusfield + ", " + entry.filter + ", -1");
			}catch(e){
				alert(e);
			}
		}

		// Reload data if user change filter
		viewModel.filterChanged = function(filterObject) {
			var index = filterObject.id;
			viewModel.filterText(filterObject.text);
			viewModel.filterIndex(index);
			var entry = viewModel.filters[index];
			loadData(entry.filter);
		}

		// Load all data from filter
		function loadData(filter) {
			
			viewModel.values.removeAll();
			// Update last update
			viewModel.lastupdate(moment().format('YYYY-MM-DD HH:mm:ss'));

			//alert(self.config.excludeStatuses);
			var test = 'PipelineModule.getPipeline,' + self.config.table + ',' + self.config.statusfield + ',' + self.config.valuefield + ',' + self.config.shadowValuefield + ',' + filter;// + ',test';
			//alert(test);
			var pipeData = {};
			lbs.loader.loadDataSource(
				pipeData,
				{type:'xml', alias : 'xmlResult', source: test },
				true
			);
			var pipeline = pipeData.xmlResult.pipeline;

			if(pipeline.pipelinestatus)
			{
				var pipelineData = pipeline.pipelinestatus.length && pipeline.pipelinestatus || [pipeline.pipelinestatus];

				for (var i = 0; i < pipelineData.length; i++)
				{
					var maxValue = parseFloat(getMaxAll(pipelineData));
					var valueObj = {
						businesstatus : pipelineData[i].name,
						businessvalue : parseFloat(pipelineData[i].value),
						percentText : parseFloat(pipelineData[i].value)/maxValue*100 + '%',
						percent : parseFloat(pipelineData[i].value)/maxValue*100,
						color : pipelineData[i].color,
						idstring : pipelineData[i].idstring,
						money : formatMoney(pipelineData[i].value),
						shadowMoney : self.config.shadowValuefield != '' && formatMoney(pipelineData[i].shadowValue) || '',
						nodata : pipelineData[i].nodata,
						statusClicked : function(myData) {
							lbs.common.executeVba("PipelineModule.GoToFilter," + self.config.table + ", " + self.config.statusfield + ", " + filter + ", " + myData.idstring);
						}
					};
					var shadowPercent = ((pipelineData[i].shadowValue/pipelineData[i].value) * (valueObj.percent / 100));

					valueObj.shadowPercentText = self.config.shadowValuefield != '' && (shadowPercent * 100 + '%') || '',
					viewModel.values.push(valueObj);
				}
			}
		}

		// Handle all filters to option
		var filters = self.config.Filters;
		if(filters)
		{
			var filterData = filters.length && filters || [filters];

			viewModel.filters= [];
			for (var i = 0; i < filterData.length; i++)
			{
				// Get localized text
				var localizedtext;
				if(filterData[i].localize instanceof Object)
				{
					localizedtext = getLocalizedlabel(filterData[i].localize.owner, filterData[i].localize.code);
				}
				else
				{
					localizedtext = filterData[i].filter;
				}

				viewModel.filters.push({
					text : localizedtext,
					id : i,
					filter : filterData[i].filter
				});
			}
		}
	   
		// Load first filter since it is selected
		var initIndex = 0;
		viewModel.filterIndex(initIndex);
		viewModel.filterText(viewModel.filters[initIndex].text);
		loadData(viewModel.filters[initIndex].filter);

		return viewModel;
	};
});
