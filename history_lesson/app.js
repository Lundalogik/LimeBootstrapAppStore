lbs.apploader.register('history_lesson', function () {
    var self = this;

    /*Config 2.0
        
        nameOfHistoryTable: Usually the name of the history table is "history", but lets make it a setting, so other names can be used
        
        nameOfRelationField: The app should be usable on all objects with a relation to the 'history'-table. Specify the name of the relation to 
        object you like to show teh history on. Most likely 'Company', 'business' or 'helpdesk'

        idRelatedObject: Id of the relatedobject which history should be loaded
    */
    self.config = function(appConfig){
        this.nameOfHistoryTable = appConfig.nameOfHistoryTable || "history"; //default 'history' if nothing else is specified
        this.nameOfRelationField = appConfig.nameOfRelationField;
        this.idRelatedObject = appConfig.idRelatedObject;
        this.nbrOfRecords = appConfig.nbrOfRecords;
        this.icons = appConfig.icons || {
            noanswer:"fa-phone",
            sentemail:"fa-envelope",
            salescall:"fa-phone",
        }
        this.dataSources = [ //Load Records via the VBA function 'GetHistory' found in the 'HistoryLessonApp'-module
            {
                type:'records',
                source:'HistoryLessonApp.GetHistory,{0},{1},{2},{3}'.format(
                    this.nameOfHistoryTable, 
                    this.nameOfRelationField, 
                    this.idRelatedObject,
                    this.nbrOfRecords
                ),
                alias: 'history'
            }
        ];
        this.resources = {
            scripts: [], 
            styles: ['app.css'], 
            libs: [] 
        }
    };


    /*Initialize

    */
    self.initialize = function (node, viewModel) {
        
        viewModel.historyClicked = function($history){
            var limeLink = lbs.common.createLimeLink(self.config.nameOfHistoryTable, $history.idhistory.text);
            lbs.common.executeVba("shell, " + limeLink);
        }

        viewModel.getIcon = function(key){
            if(self.config.icons[key]){
                return self.config.icons[key];
            }else{
                return "fa-comment";
            }
        }
        $(document).ready(function(){
            $(".history-lesson").tinyscrollbar({axis: "y"});   
        })
         

        return viewModel;
    }
});
