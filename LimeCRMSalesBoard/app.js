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
                scripts: ['script/numeraljs/numeral.min.js',
                    'script/limecrmsalesboard.colors.js'
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
        
        // Set up refresh buttons
        var refreshButtons = $('.limecrmsalesboard-refresh');
        refreshButtons.append(viewModel.localize.App_LimeCRMSalesBoard.btnRefresh);

        refreshButtons.hover(function() {
                $(this).children('i').addClass('fa-spin');
            },
            function() {
                $(this).children('i').removeClass('fa-spin');
            }
        );

        refreshButtons.click(function() {
            viewModel.board(initBoard());
        });

        /* Sets dynamic css property to use the current window size as board height (otherwise no scrollbar will appear). */
        resizeBoardHeight = function() {
            var bodyHeight = parseInt($('body').css('height').replace(/\D+/g, ''));     // replace all non-digits with nothing
            $('.limecrmsalesboard-board').css('height', bodyHeight - 20);
        }

        // Make sure that the board is resized whenever the window size is changed.
        $(window).resize(resizeBoardHeight);


        // Knockout handlers for completion donut chart
        ko.bindingHandlers.donut = {
            update : function(element, valueAccessor, bindingContext) {
                var options = ko.unwrap(valueAccessor());
                var degree = options.value;

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
                        .addClass('limecrmsalesboard-color-positive-background');
                }
            }
        };
        
        // Replace all SVG images with inline SVG
        $('img.svg').each(function() {
            var $img = $(this);
            var imgID = $img.attr('id');
            var imgClass = $img.attr('class');
            var imgDataBind = $img.attr('data-bind');
            var imgURL = $img.attr('src');

            $.get(imgURL, function(data) {
                // Get the SVG tag, ignore the rest
                var $svg = $(data).find('svg');

                // Add replaced image's ID to the new SVG
                if(typeof imgID !== 'undefined') {
                    $svg = $svg.attr('id', imgID);
                }
                
                // Add replaced image's classes to the new SVG
                if(typeof imgClass !== 'undefined') {
                    $svg = $svg.attr('class', imgClass+' replaced-svg');
                }

                // Add replaced image's data-binds to the new SVG
                if(typeof imgDataBind !== 'undefined') {
                    $svg = $svg.attr('data-bind', imgDataBind);
                }

                // Remove any invalid XML tags as per http://validator.w3.org
                $svg = $svg.removeAttr('xmlns:a');

                // Replace image with new SVG
                $img.replaceWith($svg);
            }, 'xml');
        });

        initBoard = function() {
            // Clear old board data
            self.b.name = '';
            self.b.lanes([]);
            self.b.sumPositive = 0;
            self.b.sumNegative = 0;
            self.b.sumUnit = '';
            self.b.sortFieldType = 'string';

            // Get config for active table
            self.activeTable = lbs.common.executeVba('App_LimeCRMSalesBoard.getActiveTable');
            var boardConfig = $.grep(self.config.boards, function(obj, i) {
                return obj.table === self.activeTable;
            });

            // Check if valid active table
            if (boardConfig.length !== 1) {
                $('.limecrmsalesboard-board').hide();
                $('.limecrmsalesboard-notactivated-container').show();
                return self.b;
            }
            else {
                $('.limecrmsalesboard-notactivated-container').hide();
                $('.limecrmsalesboard-board').show();
            }

            // Get the type of the sort values. Needed to be able to sort cards correctly.
            if (boardConfig[0].card.sorting) {
                self.b.sortFieldType = lbs.common.executeVba('App_LimeCRMSalesBoard.getSortFieldType,' + self.activeTable + ',' + boardConfig[0].card.sorting.field);
            }
        
            // Check if filter is applied
            self.b.filterApplied = lbs.common.executeVba('App_LimeCRMSalesBoard.getListFiltered');

            // Get JSON data and fill board variable
            var data = {};
            var boardForVBA = { board: boardConfig[0] };
            var vbaCommand = 'App_LimeCRMSalesBoard.getBoardXML, ' + json2xml(boardForVBA);
            lbs.loader.loadDataSource(data, { type: 'xml', source: vbaCommand, alias: 'board' }, false);
            self.b.name = lbs.common.executeVba('App_LimeCRMSalesBoard.getActiveBoardName') + ', ' + viewModel.localize.App_LimeCRMSalesBoard.boardtitleSumLabel + ':';
            self.b.localNameSingular = lbs.common.executeVba('App_LimeCRMSalesBoard.getActiveTableLocalNameSingular');
            self.b.localNamePlural = lbs.common.executeVba('App_LimeCRMSalesBoard.getActiveTableLocalNamePlural');
            self.b.sumUnit = boardConfig[0].summation.unit;
            self.b.cardValueUnit = boardConfig[0].card.value.unit;
            
            var boardSumPositive = 0;
            var boardSumNegative = 0;

            $.each(data.board.data.Lanes, function(i, laneObj) {
                var cardsArray = ko.observableArray();
                var laneSum = 0;

                // Get the individual lane settings from the config.
                var laneSettings = getLaneSettings(boardConfig[0].lanes, laneObj);
                
                if (laneObj.Cards !== undefined) {
                    if ($.isArray(laneObj.Cards)) {
                        $.each(laneObj.Cards, function(j, cardObj) {
                            cardsArray.push({ title: cardObj.title,
                                    additionalInfo: strMakePretty(cardObj.additionalInfo),
                                    completionRate: fixCompletionRate(cardObj.completionRate),
                                    angle: ko.observable(fixCompletionRate(cardObj.completionRate) * 3.6),
                                    sumValue: cardObj.sumValue,
                                    value: numericStringMakePretty(cardObj.value),
                                    icon: chooseCardIcon(laneSettings.cardIcon, cardObj.icon),
                                    sortValue: cardObj.sortValue,
                                    owner: strMakePretty(cardObj.owner),
                                    link: cardObj.link
                            });
                            laneSum = laneSum + parseFloat(cardObj.sumValue);
                        });

                        // Sort the cards
                        if (boardConfig[0].card.sorting) {
                            cardsArray.sort(function (left, right) {
                                if (self.b.sortFieldType === 'float') {
                                    var lsv = parseFloat(left.sortValue);
                                    var rsv = parseFloat(right.sortValue);
                                }
                                else {
                                    var lsv = left.sortValue;
                                    var rsv = right.sortValue;
                                }
                                
                                if (boardConfig[0].card.sorting.descending) {
                                    return lsv === rsv ? 0 : (lsv < rsv ? 1 : -1);
                                }
                                else {
                                    return lsv === rsv ? 0 : (lsv < rsv ? -1 : 1);
                                }
                            });
                        }
                    }
                    else
                    {
                        cardsArray.push({ title: laneObj.Cards.title,
                                additionalInfo: strMakePretty(laneObj.Cards.additionalInfo),
                                completionRate: fixCompletionRate(laneObj.Cards.completionRate),
                                angle: ko.observable(fixCompletionRate(laneObj.Cards.completionRate) * 3.6),
                                sumValue: laneObj.Cards.sumValue,
                                value: numericStringMakePretty(laneObj.Cards.value),
                                icon: chooseCardIcon(laneSettings.cardIcon, laneObj.Cards.icon),
                                sortValue: laneObj.Cards.sortValue,
                                owner: strMakePretty(laneObj.Cards.owner),
                                link: laneObj.Cards.link
                        });
                        laneSum = parseFloat(laneObj.Cards.sumValue);
                    }
                }

                // Add lane to board object.
                self.b.lanes.push({ name: laneObj.name,
                        color: laneSettings.color,
                        colorHex: self.limeCRMSalesBoardColors.getColorHex(laneSettings.color),
                        cards: cardsArray,
                        sum: numericStringMakePretty(laneSum.toString()),
                        positiveSummation: laneSettings.positiveSummation
                });

                // Add to board summation properties
                if (laneSettings.positiveSummation) {
                    boardSumPositive = boardSumPositive + laneSum;
                }
                else {
                    boardSumNegative = boardSumNegative + laneSum;
                }
            });
            
            self.b.sumPositive = numericStringMakePretty(boardSumPositive.toString());
            self.b.sumNegative = numericStringMakePretty(boardSumNegative.toString());

            // Set dynamic css property to make room for all lanes in width.
            var laneWidth = parseInt($('.limecrmsalesboard-lane-container').css('width').replace(/\D+/g, ''));     // replace all non-digits with nothing
            var laneMargins =  parseInt($('.limecrmsalesboard-lane-container').css('margin-left').replace(/\D+/g, ''))
                                + parseInt($('.limecrmsalesboard-lane-container').css('margin-right').replace(/\D+/g, ''));     // replace all non-digits with nothing
            $('.limecrmsalesboard-lanes-container').css('width', self.b.lanes().length * (laneWidth + laneMargins));
            
            resizeBoardHeight();

            return self.b;
        }

        /* Checks if the specified value is undefined. If so, returns -1 and otherwise returns the value times 100. */
        fixCompletionRate = function(val) {
            if (val) {
                return parseFloat(val * 100).toFixed(0);
            }
            else {
                return -1;
            }
        }

        /*  Returns the specified sum as a string either with two decimals or without decimals
            depending on if they are "00" or not. */
        numericStringMakePretty = function(str) {

            // Check if integer or float
            if (parseFloat(str).toFixed(2).toString().substr(-2) === "00") {
                return localizeNumber(numeral(str).format('0,0'));
            }
            else {
                return localizeNumber(numeral(str).format('0,0.00'));
            }
        }

        /*  Makes a string pretty depending on what kind of info it contains. */
        strMakePretty = function(str) {
            if (str === undefined) {
                str = '';
            }

            if (str === '' || isNaN(str)) {
                return str;
            }
            else {
                return numericStringMakePretty(str);
                //##TODO: Cover dates here as well (maybe relevant for additionalInfo on helpdesk table). Use moment?
            }
        }

        /*  Returns the string passed as a correctly formatted string according to the environment language.
            Only has support for sv or en-us (default) at the moment. */
        localizeNumber = function(str) {
            if (self.lang === 'sv') {
                return str.split(',').join(' ').replace('.', ',');      //Use split and join to replace ALL occurrencies of ','.
            }
            else return str;
        }

        /*  Returns an object with the settings for the specified lane. 
            Uses default values from app config if lane or some of the parameters are not present in individualLaneSettings object. */
        getLaneSettings = function(lanesConfig, lane) {

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
                if ($.grep(self.limeCRMSalesBoardColors.colors, function(obj) {
                        return obj.name === individualLaneSettings[0].color;
                    })[0] !== undefined) {
                    
                    laneSettings.color = individualLaneSettings[0].color;
                }
                else {
                    laneSettings.color = lanesConfig.defaultValues.laneColor;
                }

                // Determine the cardIcon settings for the lane.
                laneSettings.cardIcon = chooseCardIcon(individualLaneSettings[0].cardIcon, lanesConfig.defaultValues.cardIcon);
                
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
                laneSettings.cardIcon = lanesConfig.defaultValues.icon;
                laneSettings.cardIconField = lanesConfig.defaultValues.cardIconField;
            }

            return laneSettings;
        }

        /*  Returns the first valid icon name provided. If both are invalid undefined is returned. */
        chooseCardIcon = function(i1, i2) {
            if (isValidCardIcon(i1)) {
                return i1;                
            }
            else {
                if (isValidCardIcon(i2)) {
                    return i2;
                }
                else {
                    return undefined;
                }
            }
        }

        /*  Returns true if the specified iconName is a valid name for a card icon and otherwise false. */
        isValidCardIcon = function(iconName) {
            if (iconName === undefined
                    || (iconName !== 'completion' && iconName !== 'happy' && iconName !== 'sad' && iconName !== 'wait') ) {
                return false;
            }
            else {
                return true;
            }
        }

        /*  Called when clicking a card. */
        viewModel.openLIMERecord = function(link) {
            if (link !== '') {
                window.location.href = link;
            }
        }

        viewModel.board = ko.observable(initBoard());

        return viewModel;
    };
});
