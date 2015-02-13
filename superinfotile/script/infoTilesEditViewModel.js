var infoTilesEditViewModel = function (vm) {
    var self = this;
    self.vm = vm;
    self.table = "table";
    self.field = "fält";
    self.type = "typ";
    self.fieldsenabledforedit = false;
    self.typeenabledforedit = false;
    self.tables = function(){
        var tables = lbs.common.executeVba("Superinfotile.LoadClasses");
        alert(tables);
        self.tables = new ko.observableArray([]);
        self.tables = ko.toJSON(tables.split());
        self.fieldsenabledforedit = true;
    }    

    getFields = function (){ 
        var a = self.table || "company"   ;    
        var fieldsJSON = lbs.common.executeVba("Superinfotile.SaveInfotiles," + a);
        self.fields = new ko.observableArray([]);
        self.fields = ko.toJSON(fieldsJSON.split());
        self.typeenabledforedit = true;
    }   

    self.add = function(){
            alert(self.vm)
            self.vm.addInfoTile(
                new infotile(
                    "blue",
                    "Mina aktiva ärenden", 
                    "",
                    "helpdesk",
                    "fa-user",
                    100000
                )
            );
            self.vm.saveInfoTiles();


    }
}