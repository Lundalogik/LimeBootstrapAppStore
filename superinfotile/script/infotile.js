var infotile = function(tileColor, filterName, displayText, className, icon, iconPosition, updateTimer){		
		var self = this;
		self.tileColor = tileColor;
        self.filterName = filterName;
        self.className = className;
        self.icon = icon;
        self.iconPosition = iconPosition || "right";

        var data = lbs.common.executeVba("infotile.GetInfo," + className + "," + filterName);
        self.filterValue =  ko.observable(data);            
        if(displayText){
            self.displayText = displayText;
        }else{
            self.displayText = filterName;    
        }

        self.tileColor = function(){
                switch(tileColor){
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
                        return tileColor;
                    break;
                }

            }

            if(updateTimer){
            	setInterval(function()
            {                                     
                // Får jag inte ut något värde try catch med felmeddelande i rutan. 
             	self.filterValue(lbs.common.executeVba("infotile.GetInfo," + className + "," + filterName));                            
            },updateTimer);
            }

            self.showFilter = function(){
                lbs.common.executeVba("infotile.ShowFilter," + className + "," + filterName)
            }

    }