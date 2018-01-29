lbs.apploader.register('infotile', function () {
    var self = this;
    //config
    self.config = {
        tileColor:"",
        filterName:"",
        displayText:"", //Optional
        className: "",
        icon:"",
        iconPosition:"right",
        updateTimer:"",
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
            var data = lbs.common.executeVba("infotile.GetInfo," + self.config.className + "," + self.config.filterName);            
            viewmodel.filterValue =  ko.observable(data);            
            if(self.config.displayText){
                viewmodel.displayText = self.config.displayText;
            }else{
                viewmodel.displayText = self.config.filterName;    
            }

            viewmodel.iconPosition=self.config.iconPosition;

            viewmodel.icon = self.config.icon;
            viewmodel.tileColor = function(){
                switch(self.config.tileColor){
                    case "blue":
                        return "rgb(38, 147, 255)";
                    break;
                    case "darkgrey":
                        return "rgb(70, 70, 70)";
                    break;
                    case "red":
                        return "rgb(191, 59, 38)";
                    break;
                    case "pink":
                        return "rgb(208, 23, 114)";
                    break;
                    case "orange":
                        return "rgb(229, 108, 25)";
                    break;
                    case "green":
                        return "rgb(131, 186, 31)";
                    break;
                    default:
                        return self.config.tileColor;
                    break;
                }

            }
            if(self.config.updateTimer){
            setInterval(function()
            {                                     
                // Får jag inte ut något värde try catch med felmeddelande i rutan. 
                viewmodel.filterValue(lbs.common.executeVba("infotile.GetInfo," + self.config.className + "," + self.config.filterName));                            
            },self.config.updateTimer);
            }

            viewmodel.showFilter = function(){
                lbs.common.executeVba("infotile.ShowFilter," + self.config.className + "," + self.config.filterName)
            }

            return  viewmodel;

    }

});

