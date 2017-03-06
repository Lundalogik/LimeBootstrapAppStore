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
                    fields: 'subject;starttime;endtime;coworker;person;note;done',
                    view: 'coworker;person;note;done',
                    viewLocalizations: 'todoCoworker;todoPerson;todoNote;todoDone',
                    title: 'subject',
                    start: 'starttime',
                    end: 'endtime',
                    options: {
                        statusFilter: 'subject',
                        initialField: 'coworker',
                        dateformat: 'YYYY-MM-DD HH:mm',
                        color: '#fff',
                        backgroundColor: '#00BEFF',
                        borderColor: '#00BEFF'
                    }
                },
                {
                    table: 'campaign',
                    fields: 'name;startdate;enddate;coworker;campaignstatus;purpose',
                    view: 'coworker;campaignstatus;purpose',
                    viewLocalizations: 'todoCoworker;campaignStatus;campaignPurpose',
                    title: 'name',
                    start: 'startdate',
                    end: 'enddate',
                    options: {
                        statusFilter: 'campaignstatus',
                        initialField: 'coworker',
                        dateformat: 'YYYY-MM-DD',
                        color: '#fff',
                        backgroundColor: '#FF3296',
                        borderColor: '#FF3296'
                    }
                }
            ];
            this.defaultFilter = appConfig.defaultFilter || 'mine';
            this.groupFilter = {
                table: 'office',
                title: 'name'
            };
            this.view = appConfig.view || 'windowed';
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
        viewModel.selectedDate = ko.observable();
        viewModel.personFilter = ko.observable();
        viewModel.selectedEvent = ko.observable();
        viewModel.changedEvents = ko.observableArray();
        viewModel.title = ko.observable('');
        viewModel.filter = ko.observable('');

        viewModel.coworkerFilter = ko.observable('');
        viewModel.coworkers = ko.observableArray();
        viewModel.filteredCoworkers = ko.observableArray();
        viewModel.selectedCoworker = ko.observable();

        viewModel.selectedGroup = ko.observable();
        viewModel.groups = ko.observableArray();
        viewModel.filteredGroups = ko.observableArray();
        viewModel.groupFilter = ko.observable('');

        viewModel.tables = ko.observableArray();
        viewModel.events = ko.observableArray();
        viewModel.view = ko.observable(self.config.view);

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
                case "coworker":
                    $('#coworkerModal').modal('hide');
                    viewModel.title(viewModel.selectedCoworker().name);
                    viewModel.getItems();
                    break;
                case "group":
                    $('#groupModal').modal('hide');
                    viewModel.title(viewModel.selectedGroup().name);
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
                }).slice(0,5));
            }
            else{
                vm.filteredCoworkers(vm.coworkers().slice(0,5));
            }
        }

        viewModel.groupFilter.subscribe(function(newValue){
            viewModel.filterGroups();
        });

        viewModel.filterGroups = function() {
            if(vm.groupFilter() !== ''){
                vm.filteredGroups(ko.utils.arrayFilter(vm.groups(), function(item){
                    if(item.name.toLowerCase().indexOf(vm.groupFilter().toLowerCase()) != -1){
                        return true;
                    }
                    return false;
                }).slice(0,5));
            }
            else{
                vm.filteredGroups(vm.groups().slice(0,5));
            }
        }
        


        viewModel.pickFilter = function(newValue) {
            var oldValue = viewModel.filter();
            viewModel.filter(newValue);
            if(newValue === oldValue && (newValue === 'coworker' || newValue === 'group')){
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
                var options = {
                    startfield: table.start,
                    filter: viewModel.filter(),
                    groupFilter: self.config.groupFilter.table,
                    table: table.table,
                    fields: table.fields,
                    statusFilter: table.statusFilter
                }

                if(viewModel.selectedCoworker()){
                    options['idcoworker'] = viewModel.selectedCoworker().id;
                }

                if(viewModel.selectedGroup()) {
                    options['idgroup'] = viewModel.selectedGroup().id;
                }

                params = JSON.stringify(options) +
                         ((viewModel.selectedCoworker() && viewModel.filter() === 'coworker') ? ', ' + viewModel.selectedCoworker().id : '');

                lbs.loader.loadDataSource(
                    jsonData,
                    {type: 'records', source: 'LimeCalendar.GetItems, ' + btoa(params)},
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
                return !event.table.excluded() && (event.table.filterOption() ? (event.statusFilter === event.table.filterOption().name) : true);
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
            
            viewModel.filteredCoworkers(viewModel.coworkers.slice(0,5));
        }

        viewModel.getGroups = function() {
            var jsonData = {};
            
            lbs.loader.loadDataSource(
                jsonData,
                {type: 'records', source: 'LimeCalendar.GetGroups, ' + btoa(JSON.stringify(self.config.groupFilter))},
                true
            );
            viewModel.groups(ko.utils.arrayMap(jsonData[self.config.groupFilter.table].records, function(item) {
                return new model.Group(viewModel, item, self.config.groupFilter);
            }));

            
            viewModel.filteredGroups(viewModel.groups.slice(0,5));
        }

        viewModel.setup = function() {
            // Title of the page
            $('title').html('Lime Calendar');
            if(viewModel.view() === 'overview'){
                $('body').addClass('overview');
            }
            viewModel.calendarModel = {
                'items': ko.observableArray(),
                'viewDate': ko.observable(moment())
            };
            viewModel.tables(ko.utils.arrayMap(self.config.tables, function(table) {
                return new model.Table(viewModel, table);
            }));
            viewModel.getCoworkers();
            viewModel.getGroups();
            viewModel.pickFilter(self.config.defaultFilter);
            viewModel.calendarViewModel = new ko.fullCalendar.viewModel({
                events: viewModel.calendarModel.items,
                header: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'month,agendaWeek,agendaDay,listWeek'
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
