lbs.apploader.register('LimeCalendar', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.locale = lbs.common.executeVba('LimeCalendar.GetLocale');
            this.tables = appConfig.tables || [
                 {
                    table: 'todo',
                    tableLocale: lbs.common.executeVba('LimeCalendar.GetTableLocale, todo'),
                    fields: 'subject;starttime;endtime;coworker;person;note;done',
                    view: 'coworker;person;note',
                    viewLocalizations: 'todoCoworker;todoPerson;todoNote',
                    title: 'subject',
                    start: 'starttime',
                    end: 'endtime',
                    options: {
                        dateformat: 'YYYY-MM-DD HH:mm',
                        color: '#fff',
                        backgroundColor: '#00A8CC',
                        borderColor: '#00A8CC'
                    }
                },
                {
                    table: 'campaign',
                    tableLocale: lbs.common.executeVba('LimeCalendar.GetTableLocale, campaign'),
                    fields: 'name;startdate;enddate;coworker;campaignstatus;purpose',
                    view: 'coworker;campaignstatus;purpose',
                    viewLocalizations: 'todoCoworker;campaignStatus;campaignPurpose',
                    title: 'name',
                    start: 'startdate',
                    end: 'enddate',
                    options: {
                        dateformat: 'YYYY-MM-DD',
                        color: '#fff',
                        backgroundColor: '#FF3296',
                        borderColor: '#FF3296'
                    }
                }
            ],
            this.nbrMonthsBack = appConfig.nbrMonthsBack || 2,
            this.defaultFilter = appConfig.defaultFilter || 'mine';
            this.dataSources = [];
            this.resources = {
                scripts: [
                    '/Scripts/moment.min.js',
                    '/Scripts/jquery-ui.min.js',
                    '/Scripts/fullcalendar.min.js', 
                    '/Scripts/ko.fullcalendar.js',
                    '/Scripts/locale-all.js',
                    'model.js'
                ], // <= External libs for your apps. Must be a file
                styles: ['app.css', '/Scripts/fullcalendar.min.css', '/Scripts/jquery-ui.theme.min.css'], // <= Load styling for the app.
                libs: [] // <= Already included libs, put not loaded per default. Example json2xml.js
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
        viewModel.selectedCoworker = ko.observable();
        viewModel.selectedDate = ko.observable();
        viewModel.personFilter = ko.observable();
        viewModel.selectedEvent = ko.observable();
        viewModel.changedEvents = ko.observableArray();
        viewModel.title = ko.observable('');
        viewModel.filter = ko.observable('');
        viewModel.coworkerFilter = ko.observable('');
        viewModel.coworkers = ko.observableArray();
        viewModel.filteredCoworkers = ko.observableArray();
        viewModel.tables = ko.observableArray();
        viewModel.events = ko.observableArray();

        viewModel.filter.subscribe(function(newValue){
            switch(newValue) {
                case "mine":
                    viewModel.selectedCoworker(null);
                    viewModel.title(viewModel.localize.LimeCalendar.mine);
                    viewModel.getItems();
                    break;
                case "all":
                    viewModel.selectedCoworker(null);
                    viewModel.title(viewModel.localize.LimeCalendar.all);
                    viewModel.getItems();
                    break;
                case "other":
                    $('#coworkerModal').modal('hide');
                    viewModel.title(viewModel.selectedCoworker().name);
                    viewModel.getItems();
                    break;
            }
        });
        viewModel.coworkerFilter.subscribe(function(newValue){
            viewModel.filterCoworkers();
        });

        viewModel.filterCoworkers = function() {
            if(vm.coworkerFilter() !== ''){
                vm.filteredCoworkers(ko.utils.arrayFilter(vm.coworkers(), function(item){
                    if(item.name.toLowerCase().indexOf(vm.coworkerFilter().toLowerCase()) != -1){
                        return true;
                    }
                    return false;
                }).splice(0,5));
            }
            else{
                vm.filteredCoworkers(vm.coworkers().splice(0,5));
            }
        }
        


        viewModel.pickFilter = function(newValue) {
            var oldValue = viewModel.filter();
            viewModel.filter(newValue);
            if(newValue === oldValue && newValue === 'other'){
                viewModel.filter.valueHasMutated();
            }
            
        }

        viewModel.save = function() {
            var changedEvents = ko.utils.arrayMap(viewModel.changedEvents(), function(event) {
                return {
                    id: event.id,
                    table: event.table.table,
                    start: moment(event.start).format(event.dateFormat),
                    startfield: event.startfield,
                    end: event.end ? moment(event.end).format(event.dateFormat) : null,
                    endfield: event.endfield
                }
            });
            lbs.common.executeVba('LimeCalendar.Save, ' + btoa(JSON.stringify(changedEvents)));
            viewModel.getItems();

        }

        viewModel.openRecord = function() {
            var link = lbs.common.createLimeLink(viewModel.selectedEvent().table.table, viewModel.selectedEvent().id);
            window.open('','_parent','');
            window.close();
            lbs.common.executeVba('LimeCalendar.OpenRecord, ' + link)
        }

        viewModel.getItems = function() {
            viewModel.selectedEvent(null);
            viewModel.changedEvents([]);
            var jsonData = {};
            var params = "";
            var allItems = [];
            
            $.each(self.config.tables, function(index, table) {
                jsonData = {};
                params = table.start + ', ' +
                         viewModel.filter() + ', ' + 
                         table.table + ', ' + 
                         table.fields + 
                         ((viewModel.selectedCoworker() && viewModel.filter() === 'other') ? ', ' + viewModel.selectedCoworker().id : '');
                lbs.loader.loadDataSource(
                    jsonData,
                    {type: 'records', source: 'LimeCalendar.GetItems, ' + params},
                    true
                );

                var items = ko.utils.arrayMap(jsonData[table.table].records, function(item) {
                    return new model.GenericModel(
                        viewModel, 
                        item, 
                        viewModel.tables()[index], 
                        table.view, 
                        table.viewLocalizations, 
                        table.title, 
                        table.start, 
                        table.end,
                        table.options
                    );
                });

                allItems = allItems.concat(items);
            });
            viewModel.events(allItems);
            viewModel.setItems();
        }

        viewModel.setItems = function() {
            var items = ko.utils.arrayFilter(viewModel.events(), function(event, index) {
                return !event.table.excluded();
            });
            viewModel.calendarModel.items(items);
        }

        viewModel.getCoworkers = function() {
            var jsonData = {};

            lbs.loader.loadDataSource(
                jsonData,
                {type: 'records', source: 'LimeCalendar.GetCoworkers'},
                true
            );
            viewModel.coworkers(ko.utils.arrayMap(jsonData.coworker.records, function(item) {
                return new model.Coworker(viewModel, item);
            }));
            
            viewModel.filteredCoworkers(viewModel.coworkers.splice(0,5));
        }

        viewModel.setup = function() {
            // Title of the page
            $('title').html('Lime Calendar');
            viewModel.calendarModel = {
                'items': ko.observableArray(),
                'viewDate': ko.observable(moment())
            };
            viewModel.tables(ko.utils.arrayMap(self.config.tables, function(table) {
                return new model.Table(viewModel, table);
            }));
            viewModel.getCoworkers();
            viewModel.pickFilter(self.config.defaultFilter);
            viewModel.calendarViewModel = new ko.fullCalendar.viewModel({
                events: viewModel.calendarModel.items,
                header: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'month,agendaWeek,agendaDay'
                },
                locale: self.config.locale,
                editable: true,
                appViewModel: viewModel,
                viewDate: viewModel.calendarModel.viewDate
            });
        }
        
        
        
        viewModel.setup();
        return viewModel;
    };
});
