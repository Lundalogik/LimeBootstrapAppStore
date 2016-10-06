lbs.apploader.register('Data flow', function () {
    var self = this;


    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig) {
        this.appConfig = {};

        this.appConfig.tableStructure = this.appConfig.tableStructure || {};

        this.appConfig.tableStructure.pageSize =  appConfig.tableStructure.pageSize || 5;
        this.appConfig.tableStructure.tableName =  appConfig.tableStructure.tableName || 'history';
        this.appConfig.tableStructure.titleFieldName =  appConfig.tableStructure.titleFieldName || 'type';
        this.appConfig.tableStructure.typeFieldName =  appConfig.tableStructure.typeFieldName || 'type';
        this.appConfig.tableStructure.dateFieldName =  appConfig.tableStructure.dateFieldName || 'date';
        this.appConfig.tableStructure.relationFieldName =  appConfig.tableStructure.relationFieldName || 'company';
        this.appConfig.tableStructure.noteFieldName =  appConfig.tableStructure.noteFieldName || 'note';
        this.appConfig.tableStructure.clickableRelationFieldName =  appConfig.tableStructure.clickableRelationFieldName || 'person';
        this.appConfig.filterKey =  appConfig.filterKey || '';
        this.appConfig.dateSortOrder = appConfig.dateSortOrder || 'descending';

        this.appConfig.defaultIcon = appConfig.defaultIcon || 'fa-comment-o';

        var defaultTypes = {
            'comment': 'fa-comment-o',
            'customervisit': 'fa-group',
            'noanswer': 'fa-thumbs-o-down',
            'receivedemail': 'fa-envelope-o',
            'salescall': 'fa-money',
            'sentemail': 'fa-paper-plane-o',
            'talkedto': 'fa-phone',
        };

        this.appConfig.typeMapping = appConfig.typeMapping || {};

        for (var type in defaultTypes) {
            if (!this.appConfig.typeMapping[type]) {
                this.appConfig.typeMapping[type] = defaultTypes[type];
            }
        }


        this.dataSources = [
        ];

        this.resources = {
            scripts: ['VerticalTimeline/js/modernizr.custom.js'], // <= External libs for your apps. Must be a file
            styles: ['app.css', 'VerticalTimeline/css/component.css', 'VerticalTimeline/css/default.css'], // <= Load styling for the app.
            libs: [] // <= Allready included libs, put not loaded per default. Example json2xml.js
        };
    };

    //initialize
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
        var appConfig = self.config.appConfig;
        
        viewModel.dataFlows = ko.observableArray();

        var xmlParam = '<xmlStructure>';
        xmlParam += '<dateSortOrder>' + appConfig.dateSortOrder.toString() + '</dateSortOrder>';
        xmlParam += '<pageSize>' + appConfig.tableStructure.pageSize.toString() + '</pageSize>';
        xmlParam += '<tableName>' + appConfig.tableStructure.tableName.toString() + '</tableName>';
        xmlParam += '<titleFieldName>' + appConfig.tableStructure.titleFieldName.toString() + '</titleFieldName>';
        xmlParam += '<typeFieldName>' + appConfig.tableStructure.typeFieldName.toString() + '</typeFieldName>';
        xmlParam += '<dateFieldName>' + appConfig.tableStructure.dateFieldName.toString() + '</dateFieldName>';
        xmlParam += '<relationFieldName>' + appConfig.tableStructure.relationFieldName.toString() + '</relationFieldName>';
        xmlParam += '<noteFieldName>' + appConfig.tableStructure.noteFieldName.toString() + '</noteFieldName>';
        xmlParam += '<clickableRelationFieldName>' + appConfig.tableStructure.clickableRelationFieldName.toString() + '</clickableRelationFieldName>';
        xmlParam += '</xmlStructure>';

        var sourceString = 'DataFlow.GetInitialData, ' + xmlParam + ', ' + appConfig.filterKey;

        var initialData = lbs.loader.loadDataSources({}, [{
            type: 'xml',
            source: sourceString,
            PassInspectorParam: false,
            alias: 'initialData'
        }], true);

        initialData = (initialData && initialData.initialData && initialData.initialData.initialData) || {};
        var dataFlows = (initialData && initialData.dataFlows && initialData.dataFlows.dataFlow) || null;
        if(dataFlows) {
            dataFlows = dataFlows.length && dataFlows || [dataFlows];
            for (var i = 0; i < dataFlows.length; i++) {
                var dataFlow = new DataFlow(dataFlows[i], appConfig);
                viewModel.dataFlows.push(dataFlow);
            };
        }
        
        return viewModel;
    };
});

function DataFlow(rawDataFlowObj, appConfig) {
    this.title = rawDataFlowObj.title && rawDataFlowObj.title['#cdata'] || '';
    this.type = rawDataFlowObj.type && rawDataFlowObj.type['#cdata'] || '';

    this.clickableRelation = rawDataFlowObj.clickableRelation_id && {
        id: rawDataFlowObj.clickableRelation_id['#cdata'],
        text: rawDataFlowObj.clickableRelation_text['#cdata']
    } || null;

    this.text = rawDataFlowObj.note && rawDataFlowObj.note['#cdata'] || '';
    this.date = rawDataFlowObj.date && rawDataFlowObj.date['#cdata'] || '';
    this.time = rawDataFlowObj.time && rawDataFlowObj.time['#cdata'] || '';
    this.limeid = rawDataFlowObj.limeid['#cdata'];
    
    this.icon = GetIconByType(this.type, appConfig);

    this.openDataFlowPost = function() {
        var limelink = lbs.common.createLimeLink(appConfig.tableStructure.tableName, this.limeid);
        document.location.href(limelink);
    };

    this.openClickableRelationPost = function(self, event) {
        event.stopPropagation();
        var limelink = lbs.common.createLimeLink(appConfig.tableStructure.clickableRelationFieldName, this.clickableRelation.id);
        document.location.href(limelink);
    };

    return this;
};

function GetIconByType(type, appConfig) {
    return appConfig.typeMapping[type] || appConfig.defaultIcon;
}