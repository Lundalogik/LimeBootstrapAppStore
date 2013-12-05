lbs.apploader.register('helpdeskstatics', function () {
    var self = this;
    self.helpdeskstatics = {};
    
    //config
    self.config = {
        dataSources: [
          {type: 'xml', source: 'helpdeskStatics.Initialize', alias:"helpdeskstatics"}
        
        ],
        resources: {
            scripts: [],
            styles: ['app.css'],
            libs: []
        },
        updateTimer:""

   
    },
   

    //initialize
    self.initialize = function (node,viewModel) {


        

        // SET UPDATE INTERVAL TO 15 MINUTES (IN SECONDS)
        if (!self.config.updateTimer){
            self.config.updateTimer=900
        }

        // MAKE SECONDS TO MILLISECONDS
        self.config.updateTimer = self.config.updateTimer*1000;

        // MAKE DATA MORE NICE TO WORK WITH
        self.helpdeskstatics=viewModel.helpdeskstatics.data.helpdeskstatics;

        // MAKE ALL DATA TO OBSERVALBLES IN ORDER TO BE ABLE TO BE UPDATED IN BACKGROUND WITHOUT REFRESH
        self.helpdeskstatics.general.open = ko.observable(self.helpdeskstatics.general.value.open);   
        self.helpdeskstatics.coworker.open = ko.observable(self.helpdeskstatics.coworker.value.open);
        
        self.helpdeskstatics.general.notInitiated = ko.observable(self.helpdeskstatics.general.value.notInitiated);   
        self.helpdeskstatics.coworker.notInitiated = ko.observable(self.helpdeskstatics.coworker.value.notInitiated);
        
        self.helpdeskstatics.general.delayed = ko.observable(self.helpdeskstatics.general.value.delayed);   
        self.helpdeskstatics.coworker.delayed = ko.observable(self.helpdeskstatics.coworker.value.delayed);

        self.helpdeskstatics.incomming.today = ko.observable(self.helpdeskstatics.incomming.value.today);   
        self.helpdeskstatics.incomming.week = ko.observable(self.helpdeskstatics.incomming.value.week); 
        self.helpdeskstatics.incomming.month = ko.observable(self.helpdeskstatics.incomming.value.month); 

        self.helpdeskstatics.closed.today = ko.observable(self.helpdeskstatics.closed.value.today);   
        self.helpdeskstatics.closed.week = ko.observable(self.helpdeskstatics.closed.value.week); 
        self.helpdeskstatics.closed.month = ko.observable(self.helpdeskstatics.closed.value.month); 

        self.helpdeskstatics.localize = viewModel.localize       


        self.setTimer();
		
		//REFRESH FUNCTION USED TO MANUALLY REFRESH DATA
		self.helpdeskstatics.refreshData = function(){
        
			var newData={};            
            newData = lbs.loader.loadDataSources(newData, self.config.dataSources, true);
            newData=newData.helpdeskstatics.data.helpdeskstatics
            // alert(JSON.stringify(newData))
            self.helpdeskstatics.general.open(newData.general.value.open)
            self.helpdeskstatics.coworker.open(newData.coworker.value.open)
            self.helpdeskstatics.general.open(newData.general.value.open)
            self.helpdeskstatics.coworker.open(newData.coworker.value.open)

            self.helpdeskstatics.general.notInitiated(newData.general.value.notInitiated);   
            self.helpdeskstatics.coworker.notInitiated(newData.coworker.value.notInitiated);
            
            self.helpdeskstatics.general.delayed(newData.general.value.delayed);   
            self.helpdeskstatics.coworker.delayed(newData.coworker.value.delayed);

            self.helpdeskstatics.incomming.today(newData.incomming.value.today);   
            self.helpdeskstatics.incomming.week(newData.incomming.value.week); 
            self.helpdeskstatics.incomming.month(newData.incomming.value.month); 

            self.helpdeskstatics.closed.today(newData.closed.value.today);   
            self.helpdeskstatics.closed.week(newData.closed.value.week); 
            self.helpdeskstatics.closed.month(newData.closed.value.month); 

            
        }

        // 
        self.helpdeskstatics.setFilter = function(flag){
            alert(flag)
            alert('hej');
        }
       
        return self.helpdeskstatics;
     }
   
     // TIMER FUNCTION
     self.setTimer = function(){
        setInterval(function(){
              
            var newData={};            
            newData = lbs.loader.loadDataSources(newData, self.config.dataSources, true);
            newData=newData.helpdeskstatics.data.helpdeskstatics
           
            self.helpdeskstatics.general.open(newData.general.value.open)
            self.helpdeskstatics.coworker.open(newData.coworker.value.open)
            self.helpdeskstatics.general.open(newData.general.value.open)
            self.helpdeskstatics.coworker.open(newData.coworker.value.open)

            self.helpdeskstatics.general.notInitiated(newData.general.value.notInitiated);   
            self.helpdeskstatics.coworker.notInitiated(newData.coworker.value.notInitiated);
            
            self.helpdeskstatics.general.delayed(newData.general.value.delayed);   
            self.helpdeskstatics.coworker.delayed(newData.coworker.value.delayed);

            self.helpdeskstatics.incomming.today(newData.incomming.value.today);   
            self.helpdeskstatics.incomming.week(newData.incomming.value.week); 
            self.helpdeskstatics.incomming.month(newData.incomming.value.month); 

            self.helpdeskstatics.closed.today(newData.closed.value.today);   
            self.helpdeskstatics.closed.week(newData.closed.value.week); 
            self.helpdeskstatics.closed.month(newData.closed.value.month); 

             },self.config.updateTimer);
        }

        


 });



 

