lbs.apploader.register('checklist', function () {
    var self = this;
    //config
    self.config = {
        dataSources: [
            {type: 'xml', source: 'Checklist.Initialize', alias:'checklistdata'}
        ],
        resources: {
            scripts: ['placeholders.min.js'],
            styles: ['checklist.css'],
            libs: ['json2xml.js']
        },
        name: 'Checklista',
        canBeUnchecked: false,
        canAddTask: false,
        allowRemove: false
    },

    //initialize
    self.initialize = function (node,appData) {
        function task() {
            return {
                idchecklist: "",
                order: "",
                title: "",
                mouseover: "",
                isChecked : ko.observable(false),
                checkedDate : ko.observable(""),
                checkedBy : ko.observable("")
            }
        }

        self.registerHandlers();

        /**
        Checklistmodel
        */
        function ChecklistModel(xmlchecklist) {
            var me = this;

            me.tasks = ko.observableArray();
            //populate tasks
            if(xmlchecklist){
                if ($.isArray(xmlchecklist.checklist)){
                    var checklist = xmlchecklist.checklist;
                }else{
                    var checklist = [xmlchecklist.checklist];
                }
                for (var i = 0; i < checklist.length; i++) {

                    //When and who checked?
                    var tempTask = task();
                    tempTask.idchecklist = checklist[i].idchecklist;
                    tempTask.order = checklist[i].order;
                    tempTask.title = checklist[i].title;

                    tempTask.mouseover = checklist[i].mouseover;
                    if (checklist[i].isChecked === "true") {
                        tempTask.isChecked(true);
                        tempTask.checkedDate(checklist[i].checkedDate);
                        tempTask.checkedBy(checklist[i].checkedBy);
                    }
                    me.tasks.push(tempTask);
                };
            }

            //name
            me.name = self.config.name;
            me.canAddTask = self.config.canAddTask;
            me.allowRemove = self.config.allowRemove;

            //Nbr of checkedItems
            me.nbrOfChecked = ko.computed(function(){
                return ko.utils.arrayFilter(me.tasks(), function(task) {
                        return task.isChecked() == true;
                 }).length;
             });
            me.inputValue = ko.observable('');
            me.isSelected = ko.observable(false)

            //click event
            me.taskClicked = function(task){
                try{
                    if(!task.isChecked()){
                        task.checkedDate(moment().toISOString());
                        task.checkedBy(lbs.limeDataConnection.ActiveUser.Name);
                        if(task.idchecklist){
                            task.isChecked (lbs.common.executeVba("Checklist.PerfromAction," + task.idchecklist));
                        }else{
                            task.isChecked(true);
                        }
                    }else{

                        if(self.config.canBeUnchecked){
                            task.isChecked(false);
                            task.checkedDate("");
                            task.checkedBy("");
                        }
                    }
                    me.save();
                }catch(e){
                    task.isChecked(false);  
                }
            }
            //Create and add new Task
            me.addTask = function(){
                newTask = task();
                if(me.inputValue){
                    newTask.title = me.inputValue().trim(); 
                    newTask.mouseover = me.inputValue().trim();
                    newTask.order = me.tasks().length + 1; 
                
                    me.tasks.push(newTask);
                    me.inputValue(''); 
                    me.save();                   
                }
            }

            me.removeTask = function(task){
                if (confirm('Uppgiften kommer försvinna för evigt! Riktigt, riktigt säker?')) {
                me.tasks.remove(task);
                me.save();
                }
            }
            //Save change to LIME
            me.save = function(){
                        var tempJSON = JSON.stringify({checklist:ko.toJS(me.tasks)});
                        var tempXML = "<xmlchecklist>" + json2xml($.parseJSON(tempJSON),'') + "</xmlchecklist>";
                        lbs.common.executeVba("Checklist.Save," + tempXML) ;
            }
        }

        /**
        Dummy data
        */
        var dummyData =  {"checklist": [
                  {
                    "idchecklist": "1001",
                    "order": "1",
                    "title": "Beställ diarienummer",
                    "mouseover": "Kontakta diariet och beställ diarienummer med rubrik Avtal om tillträde järnvägsföretag",
                    "isChecked":true
                  },
                  {
                    "idchecklist": "1101",
                    "order": "2",
                    "title": "Justera avtal",
                    "mouseover": "Skriv i företagets kontaktuppgifter samt datum och dnr"
                  },
                  {
                    "idchecklist": "1201",
                    "order": "3",
                    "title": "Skicka avtal och Excelfil",
                    "mouseover": "Skicka avtal samt Excelfil för kontaktuppgifter till företagets kontaktperson"
                  }
                ]
            }

        /**
        Return view model
        */
            return new ChecklistModel(appData.checklistdata.xmlchecklist);


        
    },

    self.registerHandlers = function(){
        var ENTER_KEY = 13;
    // a custom binding to handle the enter key (could go in a separate library)
        ko.bindingHandlers.enterKey = {
            init: function (element, valueAccessor, allBindingsAccessor, data) {
                var wrappedHandler, newValueAccessor;
                // wrap the handler with a check for the enter key
                wrappedHandler = function (data, event) {
                    if (event.keyCode === ENTER_KEY) {
                        valueAccessor().call(this, data, event);
                    }
                };
                // create a valueAccessor with the options that we would want to pass to the event binding
                newValueAccessor = function () {
                    return {
                        keyup: wrappedHandler
                    };
                };
                // call the real event binding's init function
                ko.bindingHandlers.event.init(element, newValueAccessor, allBindingsAccessor, data);
            }
        };
    }
});

