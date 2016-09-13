lbs.apploader.register('garcon', function () {
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
        var garconModel = new GarconModel(self.config);

        garconModel.localize = viewmodel.localize;
		return garconModel;
    }

});

function GarconModel(appConfig) {
    var me = this;

    me.leftText = ko.observable('');
    me.height = ko.observable();
    me.garcon = ko.observableArray();
/*
    me.refreshtype = appConfig.refresh;
    me.mstimer = ko.observable(0);
    me.continueTimer = ko.observable(true);
    me.timer = appConfig.timer;
*/    
    me.garconVisible = ko.observable(true);

    function populateGarcon(rawGarconItems){
        // Because the XML->JSON a garcon with one item isn't parsed as an Array
        if ($.isArray(rawGarconItems)) {
            me.garcon.push.apply(me.garcon,
                rawGarconItems.map(function(rawGarconItem){
                  return createGarconItemFromRaw(rawGarconItem)  
                }) 
            );
        }
        else if(rawGarconItems) {
            me.garcon.push(createGarconItemFromRaw(rawGarconItems));
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
            var rawGarconData = getFilterData();
            me.garcon([]);
            populateGarcon(rawGarconData);
            if(appConfig.showOnEmpty == false && me.garcon().length == 0) {
                me.garconVisible(false);
            }
            else {
                me.garconVisible(true);
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
        {type:'xml',source: 'Garcon.FetchFiltersXML, ' + lbs.activeClass + ", " + (lbs.activeInspector && lbs.activeInspector.record.id || "-1")},
        true
    );
    var rawGarconData;
    if(data.xmlSource.filters != null) {
        rawGarconData = data.xmlSource.filters.filter;
    }

    return rawGarconData;
}


function garconItem(label, color, value, icon, idgarconsettings, size) {
    var me = this;

    me.label = label || "";
    me.color = color;
    me.value = value || "";
    me.icon = icon;
    me.idgarconsettings = idgarconsettings;
    me.size = size;
    me.styling = color + " " + me.size;
    me.clicked = function() {
        try {
            lbs.common.executeVba("Garcon.ShowFilter," + me.idgarconsettings);
        } catch(e) {
            alert(e);
        }
    }
}

function createGarconItemFromRaw(rawGarconItem){
    return new garconItem(
        rawGarconItem.label['#cdata'], 
        rawGarconItem.color['#cdata'],
        rawGarconItem.value['#cdata'],
        rawGarconItem.icon['#cdata'], 
        rawGarconItem.idgarconsettings['#cdata'],
        rawGarconItem.size['#cdata'] ? rawGarconItem.size['#cdata'] : "medium"
    );
}

