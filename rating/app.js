lbs.apploader.register('rating', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
            this.dataSources = [{type: 'xml', source: 'Rating.Initialize', alias: 'rating'}];
            this.resources = {
                scripts: [], // <= External libs for your apps. Must be a file
                styles: ['app.css'], // <= Load styling for the app.
                libs: [] // <= Already included libs, put not loaded per default. Example json2xml.js
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
        //Initialize all viewmodel values in case we have null or some trash value that won't be accepted
        viewModel.fiverating = "0";
        viewModel.fivebar = "0%";

        viewModel.fourrating = "0";
        viewModel.fourbar = "0%";

        viewModel.threerating = "0";
        viewModel.threebar = "0%";

        viewModel.tworating = "0";
        viewModel.twobar = "0%";

        viewModel.onerating = "0";
        viewModel.onebar = "0%";

        viewModel.average = "0";

        var averageArray = ko.observableArray();
        var averageNegativeArray = ko.observableArray();

        //alert(JSON.stringify(viewModel.rating.data.rating.vote.value.avg[0]));

        //If data xml is not null then do all calculations
        //alert(viewModel.rating.data.rating.vote.value.totalvotes)

        if (viewModel.rating.data.rating.vote.value.totalvotes > 0) {
            var totalScore = 0;
            data = viewModel.rating.data;

            
            
            //alert(data.rating.vote.value.uniquevotes);
            //Set rating amount and amount bar width
            for (var i = 0; i < data.rating.vote.value.uniquevotes; i++) {
                //alert(JSON.stringify(data.rating.score.value.length));

                if(!(data.rating.score.value instanceof Array)) {
                    //alert("LOL");
                    data.rating.score.value = [data.rating.score.value];
                }
                //alert(JSON.stringify(data.rating.score.value[0].amount));
                
                //alert(JSON.stringify(data.rating.score.value.score));
                switch(data.rating.score.value[i].score) {
                    case "1":
                        viewModel.onerating = data.rating.score.value[i].amount;
                        viewModel.onebar = (data.rating.score.value[i].amount/data.rating.vote.value.totalvotes)*100 + "%";
                        //totalScore += data.rating.amount[i] * parseFloat(data.rating.score[i]);
                        break;
                    case "2":
                        viewModel.tworating = data.rating.score.value[i].amount;
                        viewModel.twobar = (data.rating.score.value[i].amount/data.rating.vote.value.totalvotes)*100 + "%";
                        //totalScore += data.rating.amount[i] * parseFloat(data.rating.score[i]);
                        break;
                    case "3":
                        viewModel.threerating = data.rating.score.value[i].amount;
                        viewModel.threebar = (data.rating.score.value[i].amount/data.rating.vote.value.totalvotes)*100 + "%";
                        //totalScore += data.rating.amount[i] * parseFloat(data.rating.score[i]);
                        break;
                    case "4":
                        viewModel.fourrating = data.rating.score.value[i].amount;
                        viewModel.fourbar = (data.rating.score.value[i].amount/data.rating.vote.value.totalvotes)*100 + "%";
                        //totalScore += data.rating.amount[i] * parseFloat(data.rating.score[i]);
                        break;
                    case "5":
                        viewModel.fiverating = data.rating.score.value[i].amount;
                        viewModel.fivebar = (data.rating.score.value[i].amount/data.rating.vote.value.totalvotes)*100 + "%";
                        //totalScore += data.rating.amount[i] * parseFloat(data.rating.score[i]);
                        break;
                }
            }
            
            //alert(viewModel.onebar);
            /*
            //Calculate average score
            //alert(totalScore);
            //alert(parseFloat(data.rating.amount.length));
            var averageScore = parseFloat(totalScore)/parseFloat(data.rating.amount.length);

            //Calculate amount of positive scores on average scale
            for (var k = averageScore; k >= 1; k--) {
                averageArray.push('200');
            }

            //Calculate amount of negative scores on average scale
            for (var y = 0; y < (5 - averageArray().length); y++) {
                averageNegativeArray.push('200');
            }

            //Push calculated data to viewmodel
            viewModel.average = averageScore.toFixed(1);
            viewModel.averagearray = averageArray();
            viewModel.averagenegativearray = averageNegativeArray();
            */

            viewModel.average = data.rating.vote.value.avg;
            
            //Calculate amount of positive scores on average scale
            for (var k = viewModel.average; k >= 1; k--) {
                averageArray.push('200');
            }

            //Calculate amount of negative scores on average scale
            for (var y = 0; y < (5 - viewModel.average); y++) {
                averageNegativeArray.push('200');
            }

            viewModel.averagearray = averageArray();
            viewModel.averagenegativearray = averageNegativeArray();

        } else {
            //alert("in");
            averageArray.push('404');

            averageNegativeArray.push('404');
            averageNegativeArray.push('404');
            averageNegativeArray.push('404');
            averageNegativeArray.push('404');
            averageNegativeArray.push('404');

            viewModel.averagearray = averageArray();
            viewModel.averagenegativearray = averageNegativeArray();
        }
        //alert(viewModel.averagenegativearray.length);

        //alert(viewModel.averagearray.length);

        //alert(totalScore);
        //alert(viewModel.average);

        return viewModel;
    };
});
