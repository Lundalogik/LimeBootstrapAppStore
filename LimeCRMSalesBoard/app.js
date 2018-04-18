lbs.apploader.register('LimeCRMSalesBoard', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.maxNbrOfRecords = appConfig.maxNbrOfRecords;
            this.dataSource = appConfig.dataSource;
            this.boards = appConfig.boards;
            this.dataSources = [];
            this.resources = {
                scripts: [
                    'script/numeraljs/numeral.min.js',
                    'script/limecrmsalesboard.colors.js',
                    'script/limecrmsalesboard.models.js',
                    'script/limecrmsalesboard.utils.js'
                ], // <= External libs for your apps. Must be a file
                styles: ['app.css'], // <= Load styling for the app.
                libs: ['json2xml.js'] // <= Already included libs, put not loaded per default. Example json2xml.js
            };
    };

    /*Initialize
        Initialize happens after the data and recources are loaded but before the view is rendered.
        Here it is your job to implement the logic of your app, by attaching data and functions to 'viewModel' and then returning it
        The data you requested along with localization are delivered in the variable viewModel.
        You may make any modifications you please to it or replace is with a entirely new one before returning it.
        The returned viewModel will be used to build your app.
        
        Node is a reference to the HTML-node where the app is being initalized form. Frankly we do not know when you'll ever need it,
        but, well, here you have it.
    */
    self.initialize = function (node, viewModel) {
        viewModel.boardConfig = ko.observableArray();
        viewModel.board = ko.observable();
        viewModel.loading = ko.observable(true);
        viewModel.lanesContainerWidth = ko.observable('0px');

        // Get colors object
        self.limeCRMSalesBoardColors = new limeCRMSalesBoardColors();

        // Get current LIME Pro client language
        self.lang = lbs.common.executeVba('App_LimeCRMSalesBoard.getLocale');

        // Set the data retrieval method
        lbs.common.executeVba('App_LimeCRMSalesBoard.setDataSource,' + self.config.dataSource);
        
        // Set the maximum number of records in VBA
        lbs.common.executeVba('App_LimeCRMSalesBoard.setMaxNbrOfRecords,' + self.config.maxNbrOfRecords)

        // Set up board variable to be filled later if table is activated.
        self.b = {};
        self.b.lanes = ko.observableArray();


        /* Sets dynamic css property to use the current window size as board height (otherwise no scrollbar will appear). */
        resizeBoardHeight = function() {
            var bodyHeight = parseInt($('body').css('height').replace(/\D+/g, ''));     // replace all non-digits with nothing
            $('.limecrmsalesboard-board').css('height', bodyHeight - 20);
        }

        // Make sure that the board is resized whenever the window size is changed.
        $(window).resize(resizeBoardHeight);

        initBoard = function() {
            viewModel.loading(true);
            // Clear old board data
            self.b.name = '';
            self.b.lanes([]);
            self.b.sumPositive = 0;
            self.b.sumNegative = 0;
            self.b.sumUnit = '';
            self.b.sortFieldType = 'string';

            // Get config for active table
            self.activeTable = lbs.common.executeVba('App_LimeCRMSalesBoard.getActiveTable');
            viewModel.boardConfig($.grep(self.config.boards, function(obj, i) {
                return obj.table === self.activeTable;
            }));
            
            // Check if valid active table
            if (viewModel.boardConfig().length !== 1) {
                viewModel.loading(false);
                return self.b;
            }

            // Get the type of the sort values. Needed to be able to sort cards correctly.
            if (viewModel.boardConfig()[0].card.sorting) {
                self.b.sortFieldType = lbs.common.executeVba('App_LimeCRMSalesBoard.getSortFieldType,' + self.activeTable + ',' + viewModel.boardConfig()[0].card.sorting.field);
            }
        
            // Check if filter is applied
            self.b.filterApplied = lbs.common.executeVba('App_LimeCRMSalesBoard.getListFiltered');

            // Get JSON data and fill board variable
            var data = {};
            var boardForVBA = { board: viewModel.boardConfig()[0] };
            var vbaCommand = 'App_LimeCRMSalesBoard.getBoardXML, ' + json2xml(boardForVBA);
            lbs.loader.loadDataSource(data, { type: 'xml', source: vbaCommand, alias: 'board' }, false);
            // data = lbs.loader.loadDataSource({ type: 'xml', source: vbaCommand, alias: 'board' });           // Change to this instead in LBS 2.0

            self.b.name = lbs.common.executeVba('App_LimeCRMSalesBoard.getActiveBoardName') + ', ' + viewModel.localize.App_LimeCRMSalesBoard.boardtitleSumLabel + ':';
            self.b.localNameSingular = lbs.common.executeVba('App_LimeCRMSalesBoard.getActiveTableLocalNameSingular');
            self.b.localNamePlural = lbs.common.executeVba('App_LimeCRMSalesBoard.getActiveTableLocalNamePlural');
            self.b.sumUnit = viewModel.boardConfig()[0].summation.unit;
            self.b.cardValueUnit = viewModel.boardConfig()[0].card.value.unit;

            // Add lanes and cards
            self.b.lanes(ko.utils.arrayMap(data.board.data.Lanes, function(lane) {
                return new models.Lane(lane, viewModel.boardConfig()[0], self);
            }));
            
            // Set board sum
            var boardSumNegative = 0;
            var boardSumPositive = 0;

            $.each(self.b.lanes(), function(index, lane) {
                boardSumPositive = boardSumPositive + (lane.laneSettings.positiveSummation ? lane.sumValue() : 0);
                boardSumNegative = boardSumNegative + (lane.laneSettings.positiveSummation ? 0 : lane.sumValue());
            })
     
            self.b.sumPositive = utils.numericStringMakePretty(boardSumPositive.toString());
            self.b.sumNegative = utils.numericStringMakePretty(boardSumNegative.toString());

            // Set dynamic css property to make room for all lanes in width.
            var laneWidth = parseInt($('.limecrmsalesboard-lane').css('width').replace(/\D+/g, ''));     // replace all non-digits with nothing
            var laneMargins = parseInt($('.limecrmsalesboard-lane-container').css('margin-left').replace(/\D+/g, ''))
                                + parseInt($('.limecrmsalesboard-lane-container').css('margin-right').replace(/\D+/g, ''));     // replace all non-digits with nothing
            viewModel.lanesContainerWidth(self.b.lanes().length * (laneWidth + laneMargins) + 'px');

            resizeBoardHeight();
            viewModel.loading(false);
            return self.b;
        }


        /*  Called when clicking a card. */
        viewModel.openLIMERecord = function(link) {
            if (link !== '') {
                window.location.href = link;
            }
        }

        viewModel.initialize = function() {
            viewModel.board(initBoard());
        }

        viewModel.initialize();

        return viewModel;
    };
});
// Knockout handlers for completion donut chart
ko.bindingHandlers.donut = {
    update : function(element, valueAccessor, bindingContext) {
        var options = ko.unwrap(valueAccessor());
        var degree = options.value;
        var color = options.color;

        $(element).children('.limecrmsalesboard-donut-slice').children('.limecrmsalesboard-donut-inner').css({
            '-webkit-transform': 'rotate(' + degree + 'deg)',
            '-moz-transform': 'rotate(' + degree + 'deg)',
            '-o-transform': 'rotate(' + degree + 'deg)',
            'transform': 'rotate(' + degree + 'deg)',
        });

        $(element).children('.limecrmsalesboard-donut-endmarker').css({
            '-webkit-transform': 'rotate(' + degree + 'deg)',
            '-moz-transform': 'rotate(' + degree + 'deg)',
            '-o-transform': 'rotate(' + degree + 'deg)',
            'transform': 'rotate(' + degree + 'deg)',
        });

        if (degree > 180) {
            $(element).children('.limecrmsalesboard-donut-slice').css({
                'clip': 'rect(0px, 15px, 30px, 0px)'
            }).addClass('limecrmsalesboard-color-lessimportant-background');

            $(element).children('.limecrmsalesboard-donut-master')
                .removeClass('limecrmsalesboard-color-lessimportant-background')
                .css('background-color', color);
        }
    }
};