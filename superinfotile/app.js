lbs.apploader.register('superinfotile', function () {
    var self = this;
    //config
    self.config = function(appConfig){
        this.tileColor = appConfig.tileColor;
        this.filterName = appConfig.filterName;
        this.displayText = appConfig.displayText || "" ;//Optional
        this.className = appConfig.className;
        this.icon = appConfig.icon;
        this.iconPosition = appConfig.iconPosition || "right";
        this.updateTimer = appConfig.updateTimer;
        this.dataSources = [
           
        ],
        this.resources = {
            scripts: ['script/infotile.js'],
            styles: ['app.css'],
            libs: []
        }
    },


    //initialize
    self.initialize = function (node,viewmodel) {
            var tile =                
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

