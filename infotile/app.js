lbs.apploader.register('infotile', function () {
    var self = this;
    //config
    self.config = {
        tileColor:"",
        filterName:"",
        displayText:"", //Optional
        className: "",
        icon:"",
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
            viewmodel.filterValue =  lbs.common.executeVba("InfoTile.GetInfo," + self.config.className + "," + self.config.filterName);
            if(self.config.displayText){
                viewmodel.displayText = self.config.displayText;
            }else{
                viewmodel.displayText = self.config.filterName;    
            }

            
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

            viewmodel.showFilter = function(){
                lbs.common.executeVba("InfoTile.ShowFilter," + self.config.className + "," + self.config.filterName)
            }
            return  viewmodel;

    }

});

