var infotile = function(tileColor, filterName, displayText, className, icon, iconPosition, updateTimer){		
		var self = this;
		self.tileColor = tileColor;
        self.filterName = filterName;
        self.displayText = displayText || "" ;//Optional
        self.className = className;
        self.icon = icon;
        self.iconPosition = iconPosition || "right";
        self.updateTimer = updateTimer;

        var data = lbs.common.executeVba("infotile.GetInfo," + self.className + "," + self.filterName);

    }