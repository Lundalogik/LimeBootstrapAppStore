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
        this.dataSources = [];
        this.resources = {
            scripts: ['script/infotile.js', 'script/infoTilesViewModel.js', 'script/infoTilesEditViewModel.js' ],
            styles: ['app.css'],
            libs: []
        };
    };


    //initialize
    self.initialize = function (node,viewmodel) {

        viewmodel.infotileViewModel = new infoTilesViewModel();
        viewmodel.infotileViewModel.loadInfoTiles();
        viewmodel.edit = ko.observable();
        viewmodel.add = function(){
            viewmodel.edit(new infoTilesEditViewModel( viewmodel.infotileViewModel));
        };

         return viewmodel;

         

    };



});

