var infoTilesViewModel = function () {
    var self = this;
    self.infoTiles = ko.observableArray();
    self.saveInfoTiles = function () {
        ko.ToJson(infoTiles);
    };
    self.loadInfoTiles = function () {
        infoTiles(lbs.common.executeVba("superinfotile.LoadInfoTiles"));
    };
    self.addInfoTile = function (newTile) {
        self.infoTiles.push(newTile);
    };

};