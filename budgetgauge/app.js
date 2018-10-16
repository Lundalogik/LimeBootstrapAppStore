	lbs.apploader.register('budgetgauge', function () {
    var self = this;
    
    self.config =  function(appConfig){
           // this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
           this.appConfig = appConfig;
            this.appConfig.scorestatus = appConfig.scorestatus || '';
            this.appConfig.targettype= appConfig.targettype || '';
            //this.appConfig.datatype= appConfig.datatype || 'business';
            this.appConfig.divider= appConfig.divider || '';
            this.appConfig.percentyellow = appConfig.percentyellow || 0.85;

            this.appConfig.scoreClass = appConfig.scoreClass || 'deal';
            this.appConfig.scoreFieldValue = appConfig.scoreFieldValue || 'value';
            this.appConfig.scoreFieldDate = appConfig.scoreFieldDate || 'closeddate';
            this.appConfig.scoreFieldStatus = appConfig.scoreFieldStatus || 'dealstatus';
            this.appConfig.scoreFieldCoworker = appConfig.scoreFieldCoworker || 'coworker';


            this.appConfig.targetClass = appConfig.targetClass || 'target';
            this.appConfig.targetFieldValue = appConfig.targetFieldValue || 'targetvalue';
            this.appConfig.targetFieldDate = appConfig.targetFieldDate || 'targetdate';
            this.appConfig.targetFieldType = appConfig.targetFieldType || 'targettype';
            this.appConfig.targetFieldCoworker = appConfig.targetFieldCoworker || 'coworker';

            this.appConfig.divider= appConfig.divider || '';
            
            //alert(JSON.stringify(this.appConfig));

            this.dataSources = [];
            this.resources = {
                scripts: ['External scripts/justgage.js', 'External scripts/raphael.2.1.0.min.js'],
                styles: ['app.css'],
                libs: []
                
            };
    };
    
    self.initialize = function (node, viewModel) {
		//insert the datamodel into a variable
		var appConfig = self.config.appConfig; 
		var btype = appConfig.scorestatus;
		var ttype = appConfig.targettype;
		var divider = appConfig.divider;
		//var datatype = appConfig.datatype;
		var percentyellow = appConfig.percentyellow;

		//Scoreclass and fields
		var scoreClass = appConfig.scoreClass;
        var scoreFieldValue = appConfig.scoreFieldValue;
        var scoreFieldDate = appConfig.scoreFieldDate;
        var scoreFieldStatus = appConfig.scoreFieldStatus;
        var scoreFieldCoworker = appConfig.scoreFieldCoworker;

		//Targetclass and fields
		var targetClass = appConfig.targetClass;
		var targetFieldValue = appConfig.targetFieldValue;
        var targetFieldDate = appConfig.targetFieldDate;
        var targetFieldType = appConfig.targetFieldType;
        var targetFieldCoworker = appConfig.targetFieldCoworker;
		
		//viewModel.datatype = ko.observable(datatype);
		loadData();
		
		viewModel.targetnow=ko.observable("");

		//All goals
		var maxyearall
		var maxmonthall
		//My goals
		var maxyearmine
		var maxmonthmine
		
		//Get localization text
		var alltext = lbs.common.executeVba('Localize.GetText, budgetgauge,  all');
		var minetext = lbs.common.executeVba('Localize.GetText, budgetgauge,  mine');
		var thismonth = lbs.common.executeVba('Localize.GetText, budgetgauge,  thismonth');
		var thisyear = lbs.common.executeVba('Localize.GetText, budgetgauge,  thisyear');
		var valuenow = lbs.common.executeVba('Localize.GetText, budgetgauge, targetvaluenow')
		var titlename = lbs.common.executeVba('Localize.GetText, budgetgauge, title')

		//We start at All month
		viewModel.latestTab = ko.observable("all");
		
		viewModel.latestTabCalender = ko.observable("month");
		viewModel.dropdowntext = ko.observable(alltext);

		//Colors
		var lowcolor = "#ff0033" //RED
		var mediumcolor = "#ffe135" //YELOOW
		var highcolor =  "#33cc00" //GREEN

		if (divider === 'tkr') {
				var title = titlename + " Tkr"
			} else {
				var title = titlename
			}
		
		//Create config for the gauges
		var gageConfigyearall = {
							        id: "gyearall", 
							        value: 0,
							        min: 0,
					        		max: maxyearall,
							        titleFontColor :"#000000",
							        title: title,
							        label: thisyear,
							        gaugeWidthScale : 0.50,
							        levelColorsGradient: false,
							        levelColors: ["#000000"],
							        formatNumber: true  
					        	};
		var gageConfigmonthall = {
							        id: "gmonthall", 
							        value: 0,
							        min: 0,
							        max: maxmonthall,
						        	titleFontColor :"#000000",
							        title: title,
							        label: thismonth,
						          	gaugeWidthScale : 0.50,
							        levelColorsGradient: false,
							        levelColors: ["#000000"],
							        formatNumber: true  
					        	};
		var gageConfigyearmine = {
							        id: "gyearmine", 
							        value: 0,
							        min: 0,
							        max: maxyearmine,
					        		titleFontColor :"#000000",
							        title: title,
							        label: thisyear,
							        gaugeWidthScale : 0.50,
							        levelColorsGradient: false,
							        levelColors: ["#000000"],
							        formatNumber: true
							    };
		var gageConfigmonthmine = {
							        id: "gmonthmine", 
				        			value: 0,
							        min: 0,
							        max: maxmonthmine,
							        titleFontColor :"#000000",
							        title: title,
							        label: thismonth,
						          	gaugeWidthScale : 0.50,
							        levelColorsGradient: false,
							        levelColors: ["#000000"],
							        formatNumber: true,
							         
					        	};
		
		self.gyearall = new JustGage(gageConfigyearall);
		self.gmonthall = new JustGage(gageConfigmonthall);
		self.gyearmine = new JustGage(gageConfigyearmine);
		self.gmonthmine = new JustGage(gageConfigmonthmine);
	

		function loadData(){
			/*if (viewModel.datatype() === 'business'){
				//var xmlData = lbs.common.executeVba('AO_BudgetGauge.Initialize_business,'+ btype +','+ttype); 
				var xmlData = lbs.common.executeVba('AO_BudgetGauge.GetValues,'+ btype +','+ttype +','+ targetClass +','+ targetFieldValue +','+ targetFieldDate +','+ targetFieldType);
			}*/

			var xmlStructure = '<structure>';
								xmlStructure = xmlStructure + '<btype>' + btype + '</btype>';
								xmlStructure = xmlStructure + '<ttype>' + ttype + '</ttype>';
								xmlStructure = xmlStructure + '<scoreClass>' + scoreClass + '</scoreClass>';
								xmlStructure = xmlStructure + '<scoreFieldValue>' + scoreFieldValue + '</scoreFieldValue>';
								xmlStructure = xmlStructure + '<scoreFieldDate>' + scoreFieldDate + '</scoreFieldDate>';
								xmlStructure = xmlStructure + '<scoreFieldStatus>' + scoreFieldStatus + '</scoreFieldStatus>';
								xmlStructure = xmlStructure + '<scoreFieldCoworker>' + scoreFieldCoworker + '</scoreFieldCoworker>';
								xmlStructure = xmlStructure + '<targetClass>' + targetClass + '</targetClass>';
								xmlStructure = xmlStructure + '<targetFieldValue>' + targetFieldValue + '</targetFieldValue>';
								xmlStructure = xmlStructure + '<targetFieldDate>' + targetFieldDate + '</targetFieldDate>';
								xmlStructure = xmlStructure + '<targetFieldType>' + targetFieldType + '</targetFieldType>';
								xmlStructure = xmlStructure + '<targetFieldCoworker>' + targetFieldCoworker + '</targetFieldCoworker>';
								xmlStructure = xmlStructure + '</structure>';



			var sourceString = 'AO_BudgetGauge.GetValues, ' +
	    	xmlStructure;
/*alert(sourceString);
		var xmlData = lbs.loader.loadDataSources({}, [{
			type: 'xml',
			source: sourceString,
			PassInspectorParam: false,
			alias: 'xmlData'
		}], true);*/

var xmlData = lbs.common.executeVba(sourceString);



			/*else if(viewModel.datatype() === 'order'){
				var xmlData = lbs.common.executeVba('AO_BudgetGauge.Initialize_order,'+ btype +','+ttype); 	
			} */    
			var json = xml2json($.parseXML(xmlData),'');
			json = $.parseJSON(json);

        	viewModel.budgetgauge = json;
			self.data = viewModel.budgetgauge.data.goalxml;

			
			if (divider === 'tkr') {
				//All goals
			    maxyearall =  (parseInt(self.data.year.value["goalall"])/1000);
				maxmonthall =  (parseInt(self.data.month.value["goalall"])/1000);
				//My goals
				maxyearmine = (parseInt(self.data.year.value["goalmine"])/1000);
				maxmonthmine = (parseInt(self.data.month.value["goalmine"])/1000);
			} else {
				//All goals 
			    maxyearall =  (parseInt(self.data.year.value["goalall"]));
				maxmonthall =  (parseInt(self.data.month.value["goalall"]));
				//My goals
				maxyearmine = (parseInt(self.data.year.value["goalmine"]));
				maxmonthmine = (parseInt(self.data.month.value["goalmine"]));
			}
		 };

	//USED TO SET Month DATA
        viewModel.month = function(skipShowing){

        	if(!skipShowing)
        	{
        		viewModel.latestTabCalender("month");
        	}

        	var data = self.data;
			data = data.month;

        	if (viewModel.latestTab() === "all"){

				//var percent = (data.value["sumall"]/data.value["goalall"]);
				var percent = (data.value["sumall"]/data.value["targetnowall"]);
				
				if (percent < percentyellow){
					gageConfigmonthall.levelColors[0] = lowcolor;
				}
				if (percent > percentyellow && percent < 1 ){					
					gageConfigmonthall.levelColors[0] = mediumcolor;
				}
				if (percent >= 1){		
					gageConfigmonthall.levelColors[0] =  highcolor;
				}
				gageConfigmonthall.value =  parseInt(data.value["sumall"]);

				if (divider === 'tkr') {
				    gageConfigmonthall.value =  parseInt(data.value["sumall"])/1000; 
				} else { 
				    gageConfigmonthall.value =  parseInt(data.value["sumall"]); 
				}

				self.gmonthall.refresh(gageConfigmonthall.value, maxmonthall);
				if(viewModel.latestTabCalender()=="month")
				{
					viewModel.targetnow(valuenow + ": " + data.value["targetnowall"]);
				}

			}
			else if(viewModel.latestTab() === "mine"){

				//var percent = (data.value["summine"]/data.value["goalmine"]);
				var percent = (data.value["summine"]/data.value["targetnowmine"]);

				if (percent < percentyellow){
					gageConfigmonthmine.levelColors[0] = lowcolor;
				}
				if (percent > percentyellow && percent < 1 ){
					gageConfigmonthmine.levelColors[0] = mediumcolor;
				}
				if (percent >= 1){
					gageConfigmonthmine.levelColors[0] =  highcolor;
				}
				
				if (divider === 'tkr') {
				    gageConfigmonthmine.value =  parseInt(data.value["summine"])/1000; 
				} else { 
				    gageConfigmonthmine.value =  parseInt(data.value["summine"]);
				}
				self.gmonthmine.refresh(gageConfigmonthmine.value, maxmonthmine);
				if(viewModel.latestTabCalender()=="month")
				{
					viewModel.targetnow(valuenow + ": " + data.value["targetnowmine"]);
				}
			}
        };

        //USED TO SET Year DATA
        viewModel.year = function(skipShowing){
	   		if(!skipShowing)
        	{
        		viewModel.latestTabCalender("year");
			}
        	var data = self.data;
			data = data.year;

        	if (viewModel.latestTab() === "all"){

				//var percent = (data.value["sumall"]/data.value["goalall"]);
				var percent = (data.value["sumall"]/data.value["targetnowall"]);

				if (percent < percentyellow){
					gageConfigyearall.levelColors[0] = lowcolor;
				}
				if (percent> percentyellow && percent < 1 ){
					gageConfigyearall.levelColors[0] = mediumcolor;
				}
				if (percent >= 1){
					gageConfigyearall.levelColors[0] =  highcolor;
				}

				if (divider === 'tkr') {
				    gageConfigyearall.value =  parseInt(data.value["sumall"])/1000; 
				} else { 
				    gageConfigyearall.value =  parseInt(data.value["sumall"]); 
				}
				self.gyearall.refresh(gageConfigyearall.value, maxyearall);
				if(viewModel.latestTabCalender()=="year")
				{
					viewModel.targetnow(valuenow + ": " + data.value["targetnowall"]);
				}
			}
			else if(viewModel.latestTab() === "mine"){

				//var percent = (data.value["summine"]/data.value["goalmine"]);
				var percent = (data.value["summine"]/data.value["targetnowmine"]);

				if (percent < percentyellow){
					gageConfigyearmine.levelColors[0] = lowcolor;
				}
				if (percent > percentyellow && percent < 1 ){
					gageConfigyearmine.levelColors[0] = mediumcolor;
				}
				if (percent >= 1){
					gageConfigyearmine.levelColors[0] =  highcolor;
				}

				if (divider === 'tkr') {
				    gageConfigyearmine.value =  parseInt(data.value["summine"])/1000; 
				} else { 
				    gageConfigyearmine.value =  parseInt(data.value["summine"]);
				}
				self.gyearmine.refresh(gageConfigyearmine.value, maxyearmine);
				if(viewModel.latestTabCalender()=="year")
        		{
					viewModel.targetnow(valuenow + ": " + data.value["targetnowmine"]);
				}
			}
		};

		//Toogle to all
		viewModel.all = function(){  
			viewModel.latestTab("all");
			viewModel.dropdowntext(alltext);

			if(viewModel.latestTabCalender()=="month"){
				viewModel.month(false);
			}else if(viewModel.latestTabCalender()=="year"){
				viewModel.year(false);
			}

		};

		//Toogle to mine
		viewModel.mine = function(){  
			viewModel.latestTab("mine");
			viewModel.dropdowntext(minetext);

			if(viewModel.latestTabCalender()=="month"){
				viewModel.month(false);
			}else if(viewModel.latestTabCalender()=="year"){
				viewModel.year(false);
			}
		};

		viewModel.refresh= function(){
				
			//viewModel.latestRefreshMilli(TimeNow);
			loadData();
			viewModel.month(true);
			viewModel.year(true);
		};
	
		//Run Month as default
		viewModel.month(false);

		return viewModel;
    };
});
