lbs.apploader.register('Embrello', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.maxNbrOfRecords = appConfig.maxNbrOfRecords;
            this.boards = appConfig.boards;
            this.dataSources = [];
            this.resources = {
                scripts: ['script/numeraljs/numeral.min.js',
                    'script/embrello.colors.js'
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
        self.embrelloColors = new embrelloColors();

        // Get current LIME Pro client language
        self.lang = lbs.common.executeVba('App_Embrello.getLocale');

        // Set the maximum number of records in VBA
        lbs.common.executeVba('App_Embrello.setMaxNbrOfRecords,' + self.config.maxNbrOfRecords)
        
        // Set up board variable to be filled later if table is activated.
        self.b = {};
        self.b.lanes = ko.observableArray();
        
        // Set event handlers
        var refreshButtons = $('.embrello-refresh');
        refreshButtons.append(viewModel.localize.App_Embrello.btnRefresh);

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

        ko.bindingHandlers.donut = {
            update : function(element, valueAccessor, bindingContext) {
                // lbs.log.debug('hej');
                var options = ko.unwrap(valueAccessor());
                // alert(JSON.stringify(options.value));
                var degree = options.value;

                $(element).children('.embrello-donut-slice').children('.embrello-donut-inner').css({
                    '-webkit-transform': 'rotate(' + degree + 'deg)',
                    '-moz-transform': 'rotate(' + degree + 'deg)',
                    '-o-transform': 'rotate(' + degree + 'deg)',
                    'transform': 'rotate(' + degree + 'deg)',
                });

                $(element).children('.embrello-donut-endmarker').css({
                    '-webkit-transform': 'rotate(' + degree + 'deg)',
                    '-moz-transform': 'rotate(' + degree + 'deg)',
                    '-o-transform': 'rotate(' + degree + 'deg)',
                    'transform': 'rotate(' + degree + 'deg)',
                });

                if (degree > 180) {
                    $(element).children('.embrello-donut-slice').css({
                        'clip': 'rect(0px, 15px, 30px, 0px)'
                    }).addClass('embrello-color-lessimportant-background');

                    $(element).children('.embrello-donut-master')
                        .removeClass('embrello-color-lessimportant-background')
                        .addClass('embrello-color-positive-background');
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

            // Get config for active table
            self.activeTable = lbs.common.executeVba('App_Embrello.getActiveTable');
            var boardConfig = $.grep(self.config.boards, function(obj, i) {
                return obj.table === self.activeTable;
            });

            // Check if valid active table
            if (boardConfig.length !== 1) {
                $('.embrello-board').hide();
                $('.embrello-notactivated-container').show();
                return self.b;
            }
            else {
                $('.embrello-notactivated-container').hide();
                $('.embrello-board').show();
            }

            // Check if filter is applied
            self.b.filterApplied = lbs.common.executeVba('App_Embrello.getListFiltered');

            // Get JSON data and fill board variable
            var data = {};

            var boardForVBA = { board: boardConfig[0] };
            var vbaCommand = 'App_Embrello.getBoardXML, ' + json2xml(boardForVBA);
            lbs.loader.loadDataSource(data, { type: 'xml', source: vbaCommand, alias: 'board' }, false);
            self.b.name = lbs.common.executeVba('App_Embrello.getActiveBoardName') + ', totalt:';
            self.b.localNameSingular = lbs.common.executeVba('App_Embrello.getActiveTableLocalNameSingular');
            self.b.localNamePlural = lbs.common.executeVba('App_Embrello.getActiveTableLocalNamePlural');
            self.b.sumUnit = boardConfig[0].summation.unit;
            self.b.cardValueUnit = boardConfig[0].card.value.unit;
            
            var boardSumPositive = 0;
            var boardSumNegative = 0;

            $.each(data.board.data.Lanes, function(i, laneObj) {
                var cardsArray = ko.observableArray();
                var laneSum = 0;
                // lbs.log.debug(laneObj.name);
                if (laneObj.Cards !== undefined) {
                    if ($.isArray(laneObj.Cards)) {
                        $.each(laneObj.Cards, function(j, cardObj) {
                            cardsArray.push({ title: cardObj.title,
                                    additionalInfo: strMakePretty(cardObj.additionalInfo),
                                    completionRate: cardObj.completionRate * 100,
                                    angle: ko.observable(cardObj.completionRate * 360),
                                    sumValue: cardObj.sumValue,
                                    value: numericStringMakePretty(cardObj.value),
                                    sortValue: cardObj.sortValue,
                                    owner: cardObj.owner,
                                    link: cardObj.link
                            });
                            laneSum = laneSum + parseFloat(cardObj.sumValue);
                        });

                        // Sort the cards
                        if (boardConfig[0].card.sorting) {
                            cardsArray.sort(function (left, right) {
                                if (boardConfig[0].card.sorting.descending) {
                                    return left.sortValue === right.sortValue ? 0 : (left.sortValue < right.sortValue ? 1 : -1);
                                }
                                else {
                                    return left.sortValue === right.sortValue ? 0 : (left.sortValue < right.sortValue ? -1 : 1);
                                }
                            });
                        }
                    }
                    else
                    {
                        cardsArray.push({ title: laneObj.Cards.title,
                                additionalInfo: strMakePretty(laneObj.Cards.additionalInfo),
                                completionRate: laneObj.Cards.completionRate * 100,
                                angle: ko.observable(laneObj.Cards.completionRate * 360),
                                sumValue: laneObj.Cards.sumValue,
                                value: numericStringMakePretty(laneObj.Cards.value),
                                sortValue: laneObj.Cards.sortValue,
                                owner: laneObj.Cards.owner,
                                link: laneObj.Cards.link
                        });
                        laneSum = parseFloat(laneObj.Cards.sumValue);
                    }
                }

                // Get the individual lane settings from the config.
                individualLaneSettings = $.grep(boardConfig[0].lanes.individualLaneSettings, function(obj, i) {
                    if (obj.key !== undefined) {
                        if (obj.key !== '') {
                            return obj.key === laneObj.key;
                        }
                    }
                    return obj.id.toString() === laneObj.id;
                });

                // Check if selected color is a valid color, otherwise use default color.
                if ($.grep(self.embrelloColors.colors, function(obj) {
                        return obj.name === individualLaneSettings[0].color;
                    })[0] === undefined) {
                    
                    individualLaneSettings[0].color = self.embrelloColors.defaultColor;
                }

                // Add lane to board object.
                self.b.lanes.push({ name: laneObj.name,
                        color: individualLaneSettings[0].color,
                        colorHex: self.embrelloColors.getColorHex(individualLaneSettings[0].color),
                        cards: cardsArray,
                        sum: numericStringMakePretty(laneSum.toString()),
                        positiveSummation: individualLaneSettings[0].positiveSummation,
                        cardIcon: individualLaneSettings[0].cardIcon
                });

                // Add to board summation properties
                if (individualLaneSettings[0].positiveSummation) {
                    boardSumPositive = boardSumPositive + laneSum;
                }
                else {
                    boardSumNegative = boardSumNegative + laneSum;
                }
            });
            
            self.b.sumPositive = numericStringMakePretty(boardSumPositive.toString());
            self.b.sumNegative = numericStringMakePretty(boardSumNegative.toString());

            // Set dynamic css property to make room for all lanes in width.
            var laneWidth = parseInt($('.embrello-lane-container').css('width').replace(/\D+/g, ''));     // replace all non-digits with nothing
            var laneMargins =  parseInt($('.embrello-lane-container').css('margin-left').replace(/\D+/g, ''))
                                + parseInt($('.embrello-lane-container').css('margin-right').replace(/\D+/g, ''));     // replace all non-digits with nothing
            $('.embrello-lanes-container').css('width', self.b.lanes().length * (laneWidth + laneMargins));
            
            // Set dynamic css property to use the whole body height.
            var bodyHeight = parseInt($('body').css('height').replace(/\D+/g, ''));     // replace all non-digits with nothing
            $('.embrello-board').css('height', bodyHeight - 20);
            
            return self.b;
        }

        /*  Returns the specified sum as a string either with two decimals or without decimals
            depending on if they are "00" or not. */
        numericStringMakePretty = function(str) {

            // Check if integer or float
            if (parseFloat(str).toFixed(2).toString().substr(-2) === "00") {
                // lbs.log.debug('int');
                return localizeNumber(numeral(str).format('0,0'));
            }
            else {
                // lbs.log.debug('float');
                return localizeNumber(numeral(str).format('0,0.00'));
            }
        }

        /* Makes a string pretty depending on what kind of info it contains. */
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

        /* Called when clicking a card. */
        viewModel.openLIMERecord = function(link) {
            if (link !== '') {
                window.location.href = link;
            }
        }

        viewModel.board = ko.observable(initBoard());

        return viewModel;
    };
});
