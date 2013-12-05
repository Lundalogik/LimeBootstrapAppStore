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


        var salesfunnel = {};

        var data = viewModel.businessfunnel.data.businessfunnel.all; 
        
        
        salesfunnel.name = self.config.name;  
        
        // 0 = values for ALL coworkers, 1 = for ActiveUser pipe, used in setFilter
        salesfunnel.type = 0
        

        //FIND MAX TO BE USED AS 100% IN PROGRESS BAR
              
        var maxAll = _.max(data.value, function(value){return parseInt(value.businessvalue)}).businessvalue;
 
        //CHECK IF COLOR IS SPECIFIED BY USER, IF NOT USED STANDARD COLORS        
        if(self.config.colors[0]) {
                // does exist
                colors = self.config.colors  
                                              
            }
            else {
                // does not exist
                 colors=['#2693FF','#D39D09','#E56C19','#83BA1F','#BF3B26','#464646']
                //#2693FF -blue
                //#464646  -darkgrey
                //#BF3B26 -red
                //#D39D09 -yellow
                //#E56C19 - orange
                //#83BA1F- green    
                          
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
                
                    data.value[i].percentText = (parseInt(data.value[i].businessvalue)/parseInt(maxAll))*100 +'%';
                                        
                    data.value[i].percent = (parseInt(data.value[i].businessvalue)/parseInt(maxAll))*100;
     
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
            salesfunnel.type = 0
            salesfunnel.values.removeAll();
           
            var newData={};            
            newData = lbs.loader.loadDataSources(newData, self.config.dataSources, true);
            newData = newData.businessfunnel.data.businessfunnel.all                    
            //FIND NEW MAX
            maxAll = _.max(newData.value, function(value){return parseInt(value.businessvalue)}).businessvalue;
            
            fixData(newData);
            
        }

        //USED TO SET MINE DATA
        salesfunnel.mineData = function(){
            salesfunnel.type = 1
            salesfunnel.values.removeAll();
            
            var newData={};            
            newData = lbs.loader.loadDataSources(newData, self.config.dataSources, true);
            newData = newData.businessfunnel.data.businessfunnel.coworker
            
            //FIND NEW MAX
            maxAll = _.max(newData.value, function(value){return parseInt(value.businessvalue)}).businessvalue;
            
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

