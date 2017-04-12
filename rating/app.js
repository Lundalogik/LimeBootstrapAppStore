lbs.apploader.register('rating', function () {
    var self = this;

    self.config =  function(appConfig){
            this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
            this.dataSources = [{type: 'xml', source: 'Rating.Initialize', alias: 'rating'}];
            this.resources = {
                scripts: [], 
                styles: ['app.css'], 
                libs: [] 
            };
    };

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
        
        //If data xml is not null then do all calculations
        if (viewModel.rating.data.rating.vote.value.totalvotes > 0) {
            var totalScore = 0;
            data = viewModel.rating.data;

            //Set rating amount and amount bar width
            for (var i = 0; i < data.rating.vote.value.uniquevotes; i++) {
                
                //If value is not an array then force it to be one
                if(!(data.rating.score.value instanceof Array)) {
                    data.rating.score.value = [data.rating.score.value];
                }

                switch(data.rating.score.value[i].score) {
                    case "1":
                        viewModel.onerating = data.rating.score.value[i].amount;
                        viewModel.onebar = (data.rating.score.value[i].amount/data.rating.vote.value.totalvotes)*100 + "%";
                        break;
                    case "2":
                        viewModel.tworating = data.rating.score.value[i].amount;
                        viewModel.twobar = (data.rating.score.value[i].amount/data.rating.vote.value.totalvotes)*100 + "%";
                        break;
                    case "3":
                        viewModel.threerating = data.rating.score.value[i].amount;
                        viewModel.threebar = (data.rating.score.value[i].amount/data.rating.vote.value.totalvotes)*100 + "%";
                        break;
                    case "4":
                        viewModel.fourrating = data.rating.score.value[i].amount;
                        viewModel.fourbar = (data.rating.score.value[i].amount/data.rating.vote.value.totalvotes)*100 + "%";
                        break;
                    case "5":
                        viewModel.fiverating = data.rating.score.value[i].amount;
                        viewModel.fivebar = (data.rating.score.value[i].amount/data.rating.vote.value.totalvotes)*100 + "%";
                        break;
                }
            }
            
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
            //Else if no values are present then add a bunch of empty arrays to not crash the app and to create silver star ratings
            averageArray.push('404');

            averageNegativeArray.push('404');
            averageNegativeArray.push('404');
            averageNegativeArray.push('404');
            averageNegativeArray.push('404');
            averageNegativeArray.push('404');

            viewModel.averagearray = averageArray();
            viewModel.averagenegativearray = averageNegativeArray();
        }
        
        return viewModel;
    };
});
