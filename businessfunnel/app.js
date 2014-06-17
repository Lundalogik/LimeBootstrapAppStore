lbs.apploader.register('businessfunnel', function () {
    var self = this;

    //config
    self.config = {
        dataSources: [
          {type: 'xml', source: 'Businessfunnel.Initialize', alias:"businessfunnel"}
        
        ],
        resources: {
            scripts: ["jquery.number.min.js"],
            styles: ['app.css'],
            libs: ["underscore-min.js"]
        }, 
        colors:[],
        currency:"",
        divider:"",
        decimals:"",
        name:"",
        removeStatus:[]

    },

    //initialize
    this.initialize = function (node,viewModel) {
        if (!self.config.currency){
            self.config.currency="tkr"
        }
        if (!self.config.divider){
            self.config.divider=1000
        }
        if (!self.config.decimals){
            self.config.decimals=0
        }
        if (!self.config.name){
            self.config.name="Pipeline"
        }
        $(".refreshData").addClass("active");

        var salesfunnel = {};

        var data = viewModel.businessfunnel.data.businessfunnel.all; 
        
        if (!Array.isArray(data.value)) {
            var arr = [data.value];
            data.value = arr;
        }
        
        salesfunnel.name = self.config.name;  
        
        // 0 = values for ALL coworkers, 1 = for ActiveUser pipe, used in setFilter
        salesfunnel.type = 0
        

        //FIND MAX TO BE USED AS 100% IN PROGRESS BAR
              
        getMaxAll = function(dataset){
			var maxAll = 0;
			for (var j = 0; j < dataset.value.length; j++) {
				if(!_.contains(self.config.removeStatus, dataset.value[j].key)){
					maxAll = maxAll + parseInt(dataset.value[j].businessvalue);
				}
			};

            return maxAll;
        }
        //CHECK IF COLOR IS SPECIFIED BY USER, IF NOT USED STANDARD COLORS        
        if(self.config.colors[0]) {
                // does exist
                colors = self.config.colors  
                                              
            }
            else {
                // does not exist
                 colors=['rgb(70, 116, 238)','rgb(244, 187, 36)','rgb(153, 216, 122)','rgb(243, 150, 206)','rgb(232, 89, 89)','rgb(176, 176, 176)']
                //rgb(70, 116, 238) -blue
                //rgb(176, 176, 176)  -darkgrey
                //rgb(232, 89, 89) -red
                //rgb(243, 150, 206); -pink
                //rgb(244, 187, 36) - orange
                //rgb(153, 216, 122)- green    
                          
            }
        
         salesfunnel.values = ko.observableArray();

         
        //FIX DATA IN FUNCTION
        fixData(data)
        

        function fixData(data){      
            
            for (var i = 0; i < data.value.length; i++) {    
                 
                //REMOVE UNWANTED STATUSES FROM AN ARRAY SET BY USER
                if(!_.contains(self.config.removeStatus, data.value[i].key)){    

                    //SET ALL BUSINESSVALUES TO INTEGERS
                    data.value[i].businessvalue = parseInt(data.value[i].businessvalue);  
                
                    data.value[i].percentText = (parseInt(data.value[i].businessvalue)/parseInt(getMaxAll(data)))*100 +'%';
                                        
                    data.value[i].percent = (parseInt(data.value[i].businessvalue)/parseInt(getMaxAll(data)))*100;
     
                    data.value[i].money = $.number(
                        (parseInt(data.value[i].businessvalue)/self.config.divider), self.config.decimals, ',', ' '
                    ) + ' ' +self.config.currency;
                            
                    data.value[i].color=colors[i%+colors.length];

                    salesfunnel.values.push(data.value[i])

                    // alert(JSON.stringify(ko.toJS(salesfunnel)))
                    // alert(JSON.stringify(data.all.value[i]))
                };
            };

        };
        
        //USED TO SET ALL DATA
        salesfunnel.refreshData = function(){
            $(".mineData").removeClass("active");
            $(".refreshData").addClass("active");
            salesfunnel.type = 0
            salesfunnel.values.removeAll();
           
            var newData={};            
            newData = lbs.loader.loadDataSources(newData, self.config.dataSources, true);
            newData = newData.businessfunnel.data.businessfunnel.all                    
            
            if (!Array.isArray(newData.value)) {
                var arr = [newData.value];
                newData.value = arr;
            }
        
            fixData(newData);
            
        }

        //USED TO SET MINE DATA
        salesfunnel.mineData = function(){
            $(".mineData").addClass("active");
            $(".refreshData").removeClass("active");
            salesfunnel.type = 1
            salesfunnel.values.removeAll();
            
            var newData={};            
            newData = lbs.loader.loadDataSources(newData, self.config.dataSources, true);
            newData = newData.businessfunnel.data.businessfunnel.coworker
            
            if (!Array.isArray(newData.value)) {
                var arr = [newData.value];
                newData.value = arr;
            }            
            
            fixData(newData);
            
        }

        salesfunnel.statusClicked = function(value){
            // alert(JSON.stringify(salesfunnel))
            
            lbs.common.executeVba("Businessfunnel.SetFilter,"+ value.key + ","+salesfunnel.type);
        }

        //add localixe in ordet to set language correct
        salesfunnel.localize = viewModel.localize;
  

         return salesfunnel;

     }
 });

