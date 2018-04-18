var models = {
	Lane : function(lane, settings, board) {
        var scope = this;
        scope.name = lane.name;
        scope.laneSettings = models.getLaneSettings(settings.lanes, lane, board)
        scope.color = scope.laneSettings.color;
        scope.colorHex = board.limeCRMSalesBoardColors.getColorHex(scope.laneSettings.color);

        // Make sure lanes with only one card works
        if (lane.Cards && !_.isArray(lane.Cards)) {
            lane.Cards = [lane.Cards];
        }
        
        scope.cards = ko.observableArray(ko.utils.arrayMap(lane.Cards, function(card) {
            return new models.Card(card, scope.laneSettings);
        }));
        if(settings.card.sorting){
            scope.cards.sort(function (left, right) {
                if (board.b.sortFieldType === 'float') {
                    var lsv = parseFloat(left.sortValue);
                    var rsv = parseFloat(right.sortValue);
                }
                else {
                    var lsv = left.sortValue;
                    var rsv = right.sortValue;
                }
                
                if (settings.card.sorting.descending) {
                    return lsv === rsv ? 0 : (lsv < rsv ? 1 : -1);
                }
                else {
                    return lsv === rsv ? 0 : (lsv < rsv ? -1 : 1);
                }
            });
        }
        
        scope.sumValue = ko.computed(function() {
            var sum = 0;
            $.each(scope.cards(), function(index, card) {
                sum += parseInt(card.sumValue);
            })
            return sum;
        });

        scope.sumDisplay = utils.numericStringMakePretty(scope.sumValue().toString())
        scope.positiveSummation = settings.positiveSummation;
    },

    Card: function(card, settings){
        var scope = this;

        scope.title = card.title;
        scope.additionalInfo = utils.strMakePretty(card.additionalInfo);
        scope.completionRate = utils.fixCompletionRate(card.completionRate);
        scope.angle = ko.observable(scope.completionRate * 3.6);
        scope.color = ko.computed(function() {
            switch(true) {
                case (scope.completionRate <= 33):
                    return '#ED028C';
                case (scope.completionRate > 33 && scope.completionRate <= 66):
                    return '#F46D22';
                case (scope.completionRate > 66 && scope.completionRate <= 99):
                    return '#75BE44';
                case (scope.completionRate == 100):
                    return '#01B2B1';
            }
        });
     
        scope.sumValue = card.sumValue || 0;
        scope.value = utils.numericStringMakePretty(card.value);
        scope.icon = utils.chooseCardIcon(settings.cardIcon, card.icon) ;

        scope.sortValue = card.sortValue;
        scope.owner = utils.strMakePretty(card.owner);
        scope.link = card.link;
    },
    /*  Returns an object with the settings for the specified lane. 
            Uses default values from app config if lane or some of the parameters are not present in individualLaneSettings object. */
    getLaneSettings: function(lanesConfig, lane, board) {

        // Create return object.
        var laneSettings = {};

        // Get the individual lane settings from the config.
        var individualLaneSettings = $.grep(lanesConfig.individualLaneSettings, function(obj, i) {
            if (obj.key !== undefined) {
                if (obj.key !== '') {
                    return obj.key === lane.key;
                }
            }
            return obj.id.toString() === lane.id;
        });


        // Check if a laneSetting was found
        if (individualLaneSettings.length === 1) {

            // If no specified color, then use default color.
            if ($.grep(board.limeCRMSalesBoardColors.colors, function(obj) {
                    return obj.name === individualLaneSettings[0].color;
                })[0] !== undefined) {
                
                laneSettings.color = individualLaneSettings[0].color;
            }
            else {
                laneSettings.color = lanesConfig.defaultValues.laneColor;
            }
            
            // Determine the cardIcon settings for the lane.
            laneSettings.cardIcon = utils.chooseCardIcon(individualLaneSettings[0].cardIcon, lanesConfig.defaultValues.cardIcon);
            
            // Check if summation boolean was specified for the lane, otherwise use the default
            if (individualLaneSettings[0].positiveSummation !== undefined) {
                laneSettings.positiveSummation = individualLaneSettings[0].positiveSummation;
            }
            else {
                laneSettings.positiveSummation = lanesConfig.defaultValues.positiveSummation;
            }
        }
        else {
            // Use defaults
            laneSettings.color = lanesConfig.defaultValues.laneColor;
            laneSettings.positiveSummation = lanesConfig.defaultValues.positiveSummation;
            laneSettings.cardIcon = lanesConfig.defaultValues.cardIcon;
            laneSettings.cardIconField = lanesConfig.defaultValues.cardIconField;
        }

        return laneSettings;
    }
}