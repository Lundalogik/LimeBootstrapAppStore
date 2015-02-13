var infoTilesEditViewModel = function () {
    var self = this;
    self.getTables = function(){
        var tables = lbs.common.executeVba("superinfotile.LoadClasses")
        self.tables = new ko.observableArray([]);
        self.tables = ko.ToJson(tables.split);
    }    

    self.getFields = function (){
        alert("getFields");
        //var fieldsJSON = lbs.common.executeVba("superinfotile.SaveInfotiles", infoTilesJSON))
        //self.fields = new ko.observableArray([]);
        //self.fields=
    }
}