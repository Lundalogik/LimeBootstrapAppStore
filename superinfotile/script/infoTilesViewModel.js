var infoTilesViewModel = function () {
    var self = this;
    self.infoTiles = ko.observableArray();
    self.saveInfoTiles = function () {
        var data = JSON.stringify(ko.toJSON(self.infoTiles));
    
        lbs.common.executeVba("Superinfotile.SaveInfotiles," + utf8_to_b64(data));
    };
    self.loadInfoTiles = function () {
        var data = lbs.common.executeVba("Superinfotile.LoadInfoTiles");
        var dataString = b64_to_utf8(data);
        if(data){
            var jsonData = $.parseJSON($.parseJSON(dataString));
            $.each(jsonData, function(i, jsonInfotile){
                self.infoTiles.push(
                    new infotile(
                        jsonInfotile.tileColor,
                        jsonInfotile.filterName,
                        jsonInfotile.displayText,
                        jsonInfotile.className,
                        jsonInfotile.icon,
                        jsonInfotile.iconPosition,
                        jsonInfotile.updateTimer
                    )
                );
            });
        }
    };
    self.addInfoTile = function (newTile) {
        alert("hepp")
        self.infoTiles.push(newTile);
    };

    function utf8_to_b64(str) {
    return window.btoa(unescape(encodeURIComponent(str)));
}

function b64_to_utf8(str) {
    return decodeURIComponent(escape(window.atob(str)));
}

};