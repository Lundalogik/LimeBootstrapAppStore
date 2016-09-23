lbs.apploader.register('infotiles', function () {
    var self = this;

    //config
    self.config = function(appConfig){
        this.dataSources = [
        ];
        this.resources = {
            scripts: [],
            styles: ['app.css'],
            libs: []
        };

        appConfig = appConfig || {};
        this.showOnEmpty = appConfig.showOnEmpty == null && true || appConfig.showOnEmpty;
/*
        this.timer = appConfig.timer ? appConfig.timer*1000 : 60 * 1000; //s -> ms
        this.refreshtype = appConfig.refresh ? appConfig.refresh : "manual" || "manual";
*/
    },

    //initialize
    self.initialize = function (node,viewmodel) {
        var self = this;
        var myInfotilesModel = new infotilesModel(self.config);
        myInfotilesModel.localize = viewmodel.localize;
		return myInfotilesModel;
    }

});

function infotilesModel(appConfig) {
    var me = this;

    me.leftText = ko.observable('');
    me.height = ko.observable();
    me.infotiles = ko.observableArray();
/*
    me.refreshtype = appConfig.refresh;
    me.mstimer = ko.observable(0);
    me.continueTimer = ko.observable(true);
    me.timer = appConfig.timer;
*/    
    me.infotilesVisible = ko.observable(true);

    function populateInfotiles(rawInfotilesItems){
        // Because the XML->JSON a Infotiles with one item isn't parsed as an Array
        if ($.isArray(rawInfotilesItems)) {
            me.infotiles.push.apply(me.infotiles,
                rawInfotilesItems.map(function(rawInfotilesItem){
                  return createInfotilesItemFromRaw(rawInfotilesItem)  
                }) 
            );
        }
        else if(rawInfotilesItems) {
            me.infotiles.push(createInfotilesItemFromRaw(rawInfotilesItems));
        }
    }

    me.lineheight = function(item){
        switch(item.size){
            case 'small': 
                return 33;
            case 'large':
                return 65;
            default:
                return 45;
        }
    }
/*
    me.runTimer = function(){
        if(me.continueTimer()){
            me.mstimer(me.mstimer() + 100)
            setTimeout(me.runTimer, 100);
            if(me.mstimer() > me.timer) {
                if(me.refreshtype == "manual"){
                    me.continueTimer(false);
                }
                else{
                    me.refresh();
                }
            }
        }
    }
*/
    me.refresh = function(){
        try {
            var rawInfotilesData = getFilterData();
            me.infotiles([]);
            populateInfotiles(rawInfotilesData);
            if(appConfig.showOnEmpty == false && me.infotiles().length == 0) {
                me.infotilesVisible(false);
            }
            else {
                me.infotilesVisible(true);
            }
/*
            me.continueTimer(true);
            me.mstimer(0);
            me.runTimer();
*/
        }
        catch(e) {
            alert(e);
        }
    }
    me.refresh();
}

function getFilterData() {
    var data = {};    
    lbs.loader.loadDataSource(
        data,
        {type:'xml',source: 'Infotiles.FetchFiltersXML, ' + lbs.activeClass + ", " + (lbs.activeInspector && lbs.activeInspector.record.id || "-1")},
        true
    );
    var rawInfotilesData;
    if(data.xmlSource.filters != null) {
        rawInfotilesData = data.xmlSource.filters.filter;
    }

    return rawInfotilesData;
}


function InfotilesItem(label, color, value, icon, idinfotiles, size) {
    var me = this;

    me.label = label || "";
    me.color = color;
    me.value = value || "";
    me.icon = icon;
    me.idinfotiles = idinfotiles;
    me.size = size;
    me.styling = color + " " + me.size;
    me.clicked = function() {
        try {
            lbs.common.executeVba("infotiles.ShowFilter," + me.idinfotiles);
        } catch(e) {
            alert(e);
        }
    }
}

function createInfotilesItemFromRaw(rawInfotilesItem){
    return new InfotilesItem(
        rawInfotilesItem.label['#cdata'], 
        rawInfotilesItem.color['#cdata'],
        rawInfotilesItem.value['#cdata'],
        rawInfotilesItem.icon['#cdata'], 
        rawInfotilesItem.idinfotiles['#cdata'],
        rawInfotilesItem.size['#cdata'] ? rawInfotilesItem.size['#cdata'] : "medium"
    );
}

