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
            scripts: ['script/infotile.js', 'script/infoTilesViewModel.js' ],
            styles: ['app.css'],
            libs: []
        }
    };


    //initialize
    self.initialize = function (node,viewmodel) {

            viewmodel.infotileViewModel = new infoTilesViewModel();

            var tile1 = new infotile(
                self.config.tileColor,
                self.config.filterName, 
                self.config.displayText,
                self.config.className,
                self.config.icon,
                self.config.updateTimer
            );
            var tile2 = new infotile(
                self.config.tileColor,
                self.config.filterName, 
                self.config.displayText,
                self.config.className,
                self.config.icon,
                self.config.updateTimer
            );
            viewmodel.infotileViewModel.addInfoTile(tile1) ;
            viewmodel.infotileViewModel.addInfoTile(tile2) ;          
            
            return viewmodel;

    };

});

