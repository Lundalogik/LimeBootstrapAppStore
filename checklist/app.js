lbs.apploader.register('checklist', function () {
    var self = this;
    //config
    self.config = function(appConfig){
        this.name = appConfig.name || 'Checklista';
        this.xmlFieldName = appConfig.xmlFieldName || 'checklist';
        this.canBeUnchecked = appConfig.canBeUnchecked || false;
        this.canAddTask = appConfig.canAddTask || false;
        this.allowRemove = appConfig.allowRemove || false;
        this.collapsed = appConfig.collapsed || false;
        this.autoCreate = appConfig.autoCreate || true;
        this.createChecklistFunction = appConfig.createChecklistFunction || "Checklist.CreateChecklist";
        this.performActionFunction = appConfig.performActionFunction || "Checklist.PerformAction";
        this.dataSources = [
                            {type: 'xml', source: 'Checklist.Initialize,' + this.xmlFieldName, alias:'checklistdata'},
                            {type: 'localization', source: '' }
                            ];
        this.resources = {
            scripts: [],
            styles: ['checklist.css'],
            libs: ['json2xml.js']
        };
    },

    //initialize
    self.initialize = function (node,appData) {

        /**
        Describes a checklistitem and its actions
        */
        function checklistItem(title, description, order, isChecked, checkedDate, checkedBy, idchecklist) {
            var me = this;
            me.order = order;
            me.title = title;
            me.description = description;
            me.isChecked = ko.observable(parseBoolean(isChecked));
            me.checkedDate = ko.observable(checkedDate || "");
            me.checkedBy = ko.observable(checkedBy || "");
            
            me.idchecklist = idchecklist || "";

            
            me.clicked = function(){
                try{
                    if(!me.isChecked()){
                        check();
                    }else{
                        if(self.config.canBeUnchecked){
                            check();
                        }
                    }
                }catch(e){
                    me.isChecked(false);  
                }
            }

            function parseBoolean(isChecked){
                if(!isChecked){
                   return false;
                }else if(isChecked.toLowerCase() === "true"){
                    return true;
                }else{
                    return false;
                } 

            }

            function check(){
                var success = lbs.common.executeVba(self.config.performActionFunction +"," + me.isChecked() +"," + me.idchecklist + "," + me.title);
                if(success){
                    me.checkedDate(moment().toISOString());
                    me.checkedBy(lbs.limeDataConnection.ActiveUser.Name);
                    me.isChecked(!me.isChecked());
                    checklistModel.save();
                }
            }

        }

        function createChecklistItemFromRaw(rawChecklistItem){
            return new checklistItem(
                    rawChecklistItem.title, 
                    rawChecklistItem.description || rawChecklistItem.mouseover, // fix for old format of naming 
                    rawChecklistItem.order, 
                    rawChecklistItem.isChecked,
                    rawChecklistItem.checkedDate,
                    rawChecklistItem.checkedBy,
                    rawChecklistItem.idchecklist
                    );     
        }

        /**
        Checklistmodel
        */
        function ChecklistModel(rawChecklistItems, localize) {
            var me = this;

            me.checklist = ko.observableArray();
            me.name = self.config.name;
            me.canAddTask = self.config.canAddTask;
            me.allowRemove = self.config.allowRemove;
            me.inputValue = ko.observable('');
            me.isSelected = ko.observable(false)
            me.collapsed = self.config.collapsed;
            me.localize = localize.Checklist

            populateChecklist();

            //Nbr of checkedItems
            me.nbrOfChecked = ko.computed(function(){
                return ko.utils.arrayFilter(me.checklist(), function(checklistItem) {
                        return checklistItem.isChecked() == true;
                 }).length;
             });
            
            //populate checklist
            function populateChecklist(){
                    var rawChecklistItems = rawChecklistData.checklistItem || rawChecklistData.checklist; // fix for old naming
                    // Because the XML->JSON a checklist with one item isn't parsed as an Array
                    if ($.isArray(rawChecklistItems)){
                        me.checklist.push.apply(me.checklist,
                            rawChecklistItems.map(function(rawChecklistItem){
                              return createChecklistItemFromRaw(rawChecklistItem)  
                            }
                            ) 
                        );
                    }else{
                        me.checklist.push(createChecklistItemFromRaw(rawChecklistItems));
                    }
            }
            //Create and add new Task
            me.addTask = function(){
                if(me.inputValue){
                    var order =  me.checklist().length + 1;
                    me.checklist.push(new checklistItem(me.inputValue().trim(), me.inputValue().trim(), order));
                    me.inputValue(''); 
                    me.save();                   
                }
            }

            me.removeTask = function(checklistItem){
                if (confirm(me.localize.remove_warning)) {
                    me.checklist.remove(checklistItem);
                    me.save();
                }
            }
            //Save change to LIME
            me.save = function(){
                var tempJSON = JSON.stringify({checklistItem:ko.toJS(me.checklist)});
                var tempXML = "<checklist>" + json2xml($.parseJSON(tempJSON),'') + "</checklist>";
                lbs.common.executeVba("Checklist.Save," + tempXML + "," + self.config.xmlFieldName);
            }
        }

        /**
        Check the data and 
        */
        var rawChecklistData = appData.checklistdata.checklist || appData.checklistdata.xmlchecklist; //fix for old format

        if(!rawChecklistData){
            if(self.config.autoCreate){
                var checklistDataString = lbs.common.executeVba(self.config.createChecklistFunction);
                rawChecklistData = lbs.loader.xmlToJSON(checklistDataString, "checklistdata").checklistdata.checklist;
            }
            else if(!self.config.canAddTask){
                alert("Your config of the checklist is bad and you should feel bad \n You supply no data to the checklist and you don't allow the user to create new items. Please check the config for 'autoCreate' and 'canAddTask' ")
            }
        }

        if(!appData.localize.Checklist){
            alert("No Checklist translations found. Please run 'Checklist.Install' in LIME")
            return {}
        }

        var checklistModel = new ChecklistModel(rawChecklistData, appData.localize);
        return checklistModel
  
    }
});

