lbs.apploader.register('garcon', function () {
    var self = this;
    //config
    self.config = {
        dataSources: [
           
        ],
        resources: {
            scripts: [],
            styles: ['app.css'],
            libs: []
        },
    },

    //initialize
    self.initialize = function (node,viewmodel) {

        var self = this;
        
		function garconItem(label, color, value, icon, idgarconsettings, size) {
            var me = this;
 
            me.label = label;
            me.color = color;
			me.value = value;
            me.icon = icon;
            me.idgarconsettings = idgarconsettings;
            me.size = size;
            me.styling = color + " " + me.size;
            me.clicked = function(){
                try{
					lbs.common.executeVba("Garcon.ShowFilter," + me.idgarconsettings);
                }catch(e){
                    alert(e);  
                }
            }

        }
		
		function createGarconItemFromRaw(rawGarconItem){
            return new garconItem(
                    rawGarconItem.label, 
                    rawGarconItem.color ,
					rawGarconItem.value ,
                    rawGarconItem.icon, 
                    rawGarconItem.idgarconsettings,
                    rawGarconItem.size ? rawGarconItem.size : "medium"
                    );     
					
        }
     
        //GarconModel
       
        function GarconModel(rawGarconItems) {
            var me = this;

            me.height = ko.observable();
            me.garcon = ko.observableArray()
            me.size = ko.observable(size = self.config.size ? self.config.size : "" || "");
            me.refreshtype = self.config.refresh ? self.config.refresh : "manual" || "manual";
            me.mstimer = ko.observable(0);
            me.continueTimer = ko.observable(true);
            me.refreshVisible = ko.observable(true); //var tidigare false
            me.spinVisible  = ko.observable(true); //var tidigare false
            me.timer = self.config.timer ? self.config.timer*1000 : 600000; //s -> ms
            me.refreshHeight;

            me.lineheight = function(item){
                switch(item.size){
                    case 'small': 
                        return 33;
                    case 'large':
                        return 65;
                    default:
                        return 45;
                }
            }

            me.runTimer = function(){
                if(me.continueTimer()){
                    me.mstimer(me.mstimer() + 100)
                    setTimeout(me.runTimer, 100);
                    if(me.mstimer() > me.timer){
                        if(me.refreshtype == "manual"){
                            me.refreshVisible(true);
                            me.continueTimer(false);   
                        }
                        else{
                            me.refresh();
                        }
                    }
                }
            }
            
            function populateGarcon(){
                var rawGarconItems = rawGarconData; 
                // Because the XML->JSON a garcon with one item isn't parsed as an Array
                if ($.isArray(rawGarconItems)){
                    me.garcon.push.apply(me.garcon,
                        rawGarconItems.map(function(rawGarconItem){
                          return createGarconItemFromRaw(rawGarconItem)  
                        }) 
                    );
                }else{
                    me.garcon.push(createGarconItemFromRaw(rawGarconItems));
                }
            }
    		
            me.refresh = function(){
                try{
                    me.refreshVisible(true); //var tidigare false
    				lbs.common.executeVba('Garcon.RefreshWebBar');
                    me.continueTimer(true);
                    me.mstimer(0);
                    me.runTimer();
                }catch(e){
                    alert(e);  
                }
            }

            if(rawGarconItems != null) {
                populateGarcon();
            }

            //me.refreshHeight = me.garcon()[0] ? me.lineheight(me.garcon()[0]) : 0;
            //me.refreshHeight = me.refreshHeight + (me.garcon()[1] ? me.lineheight(me.garcon()[1]) : 0);
            //$(".refresh").css('font-size', me.refreshHeight + 'px');
            
            me.runTimer();
        }

        
		
		var data ={};
		lbs.loader.loadDataSource(
				data,
				{type:'xml',source: 'Garcon.FetchFiltersXML'},
				true
			);
		var rawGarconData;

		if(data.xmlSource.filters != null){
			var rawGarconData = data.xmlSource.filters.filter;
	    }
    
        var garconModel = new GarconModel(rawGarconData);


		return garconModel
    }

});

