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

		function garconItem(label, color,hitcount, icon, idgarcon_settings) {
            var me = this;
 
            me.label = label;
            me.color = color;
			me.hitcount = hitcount;
            me.icon = icon;
            me.idgarcon_settings = idgarcon_settings;// || "";

            
            me.clicked = function(){
                try{
					lbs.common.executeVba("Garcon.ShowFilter," + me.idgarcon_settings);
                }catch(e){
                    alert(e);  
                }
            }
			
			 me.tileColor = function(n){
				
                switch(n){
                    case "blue":
                        return "rgb(70, 116, 238)";
                    break;
                    case "darkgrey":
                        return "rgb(176, 176, 176)";
                    break;
                    case "red":
                        return "rgb(232, 89, 89)";
                    break;
                    case "pink":
                        return "rgb(243, 150, 206)";
                    break;
                    case "orange":
                        return "rgb(244, 187, 36)";
                    break;
                    case "green":
                        return "rgb(153, 216, 122)";
                    break;
                    default:
                        return self.config.tileColor;
                    break;
                }

            }

         
			

        }
		
		function createGarconItemFromRaw(rawGarconItem){
            return new garconItem(
                    rawGarconItem.label, 
                    rawGarconItem.color ,
					rawGarconItem.hitcount ,
                    rawGarconItem.icon, 
                    rawGarconItem.idgarcon_settings
                    );     
					
        }

     
        //GarconModel
       
        function GarconModel(rawGarconItems) {
            var me = this;

            me.garcon = ko.observableArray()

			if(rawGarconItems != null) {
            populateGarcon();
}
            function populateGarcon(){
                    var rawGarconItems = rawGarconData; 
                    // Because the XML->JSON a garcon with one item isn't parsed as an Array
                    if ($.isArray(rawGarconItems)){
                        me.garcon.push.apply(me.garcon,
                            rawGarconItems.map(function(rawGarconItem){
                              return createGarconItemFromRaw(rawGarconItem)  
                            }
                            ) 
                        );
                    }else{
                        me.garcon.push(createGarconItemFromRaw(rawGarconItems));
                    }
            }
			me.refresh = function(){
                try{
					lbs.common.executeVba('Garcon.RefreshWebBar');
                }catch(e){
                    alert(e);  
                }
            }
           
        }
		
		//----------------------------------------------------------
		
		var data ={};
		lbs.loader.loadDataSource(
				data,
				{type:'xml',source: 'Garcon.FetchFiltersXML'},
				true
			);
            
           //alert(data);
			//alert(JSON.stringify(data));
		//alert(data.xmlSource.filters);
		//alert('ddd');
		
		var rawGarconData;
		if(data.xmlSource.filters != null){
			var rawGarconData = data.xmlSource.filters.filter;
	}
		

        var garconModel = new GarconModel(rawGarconData);
		
	
		return garconModel
 
		
		//----------------------------------------------------------
		
	

    }

});

