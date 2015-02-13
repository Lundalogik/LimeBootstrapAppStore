var infoTilesEditViewModel = function () {
    var self = this;
    self.table = "table";
    self.field = "fält";
    self.type = "typ";
    self.fieldsenabledforedit = false;
    self.typeenabledforedit = false;
    self.getTables = function(){
        var tables = lbs.common.executeVba("superinfotile.LoadClasses");
        self.tables = new ko.observableArray([]);
        self.tables = ko.toJSON(tables.split());
        self.fieldsenabledforedit = true;
    }    

    self.getFields = function (){        
        var fieldsJSON = lbs.common.executeVba("superinfotile.SaveInfotiles," + self.table);
        self.fields = new ko.observableArray([]);
        self.fields = ko.toJSON(fieldsJSON.split());
        self.typeenabledforedit = true;
    }   
}