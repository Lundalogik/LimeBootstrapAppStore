lbs.apploader.register('creditinfo', function () {
    var self = this;

    //config
    this.config = {
        orgnbr : "5563970465",
        dataSources: [
     
        ],
        resources: {
            scripts: [],
            styles: ['app.css','animate.min.css'],
            libs: []
        },
        businessCheck:{
            active:true,
            customerLoginName : "",
            password : "",
            packageName : ""
        },
        soliditet:{
            active:false,
            customerLoginName : "",
            password : "",
            packageName : ""
        }
    },

    //initialize
    this.initialize = function (node, viewModel) {
        
        viewModel.ratingValue = ko.observable();
        viewModel.ratingText = ko.observable();
        viewModel.refreshEnabled = ko.observable(false);
        viewModel.animation = ko.observable("");

        viewModel.getRating = function(){
            var ratingData = {};
            viewModel.ratingValue("animated shake");
            if (self.config.businessCheck.active){
                ratingData = lbs.loader.loadDataSources(ratingData, [{type: 'xml', source: 'CreditInfo.GetCompanyRating,556397-0465', alias:'creditdata'}], true);
                ratingData = ratingData.creditdata.DataImport2Result.Blocks.Block.Fields.Field
                viewModel.ratingValue(ratingData[0].Value)
                viewModel.ratingText(ratingData[1].Value)
            }

        }

        viewModel.ratingColor = ko.computed( function(){
           if (viewModel.ratingValue()){
                if (viewModel.ratingValue() >= 8 )  { 

                    return "good animated hinge  "
                } 
                else if (viewModel.ratingValue() <= 7 &&  viewModel.ratingValue() >= 4){
                    return "medium annimation" 
                }
                else if (viewModel.ratingValue() <= 3 &&  viewModel.ratingValue() >= 0){
                    return "bad annimation" 
                }

           }else{
                return ""
           }
        });



        return viewModel;
    }
});