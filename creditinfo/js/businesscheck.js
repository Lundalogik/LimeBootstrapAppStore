var businesscheck ={
	
	"getRating":function(viewModel, config) {
        var url = "https://www.businesscheck.se/service/dataimport2.asmx/DataImport2Company?CustomerLoginName=" + config.businessCheck.customerLoginName + "&UserLoginName=" + config.businessCheck.userLoginName + "&Password=" + config.businessCheck.password + "&Language=sv&PackageName=" + config.businessCheck.packageName + "&OrganizationNumber=" + config.orgnbr;
        var ratingData = lbs.loader.loadDataSources({}, [{ type: 'HTTPGetXml', source: url, alias: 'creditdata'}], true);
        //Check if everything is ok
        if (ratingData.creditdata.DataImport2Result.Error) {
            alert('Error from BusinessCheck:' + ratingData.creditdata.DataImport2Result.Error.ErrorMessage);
        } else {
            ratingData = ratingData.creditdata.DataImport2Result.Blocks.Block.Fields.Field //Shitty XML makes Jack a dull boy!
            // Rating can be 0 to 10. If rating < 0 a "!" is shown
            if (ratingData[0].Value >= 0) {
                viewModel.ratingValue(ratingData[0].Value);
            } else {
                viewModel.ratingValue("!");
            }
            viewModel.ratingText(ratingData[1].Value);
        }
		
	},

    setColor:function(viewModel) {
        viewModel.ratingIcon(viewModel.ratingValue());
        if (viewModel.ratingValue() >= 8) {
            viewModel.ratingColor("good");
        }
        else if (viewModel.ratingValue() <= 7 && viewModel.ratingValue() >= 4) {
            viewModel.ratingColor("medium");
        }
        else if ((viewModel.ratingValue() <= 3 && viewModel.ratingValue() >= 0) || viewModel.ratingValue() === "!") {
            viewModel.ratingColor("bad");
        }
    }


}