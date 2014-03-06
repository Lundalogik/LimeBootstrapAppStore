//Implement your own favorite credit solution here. 
//Remember to add it to the config and load the script aswell 

var template ={

    /*
    Call your webservice by using a datasource.
    GET DATA -> ratingData = lbs.loader.loadDataSources({}, [{type: 'HTTPGetXml', source: url, alias:'creditdata'}], true);
    SET DATA ->
    viewModel.ratingValue() - The value of the rating.    
    viewModel.ratingtext() - The text seen to the right
    */
	"getRating":function(viewModel, config) {
		       
		
	},

    /*
    Set the colors based on your rating value or rating text. 
    SET DATA ->
    viewModel.ratingIcon() - Icon seen to the left. Can be a number (1-10) or maybe letters (AAA) or maybe a icon (<i class='fa fa-cog'></i>)}
    viewModel.ratingColor() - Color of the rating
        RATING COLORS ->
        "good" - Green
        "medium" - Yellow
        "bad" -Red
    */
    setColor:function(viewModel) {
        
    }


}