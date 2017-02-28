(function() {

    ko.fullCalendar = {
        // Defines a view model class you can use to populate a calendar
        viewModel: function(configuration) {
            this.appViewModel = configuration.appViewModel;
            this.events = configuration.events;
            this.header = configuration.header;
            this.editable = configuration.editable;
            this.locale = configuration.locale || 'en';
            this.viewDate = configuration.viewDate || ko.observable(new Date());
        }
    };

    // The "fullCalendar" binding
    ko.bindingHandlers.fullCalendar = {
        // This method is called to initialize the node, and will also be called again if you change what the grid is bound to
        update: function(element, viewModelAccessor) {
            var viewModel = viewModelAccessor();
            var appViewModel = viewModel.appViewModel;
            $(element).fullCalendar('destroy');
            element.innerHTML = "";
            
            $(element).fullCalendar({
                events: ko.utils.unwrapObservable(viewModel.events),
                header: viewModel.header,
                droppable: true,
                editable: viewModel.editable,
                locale: viewModel.locale,
                dayClick: function(date, jsEvent, view) {
                    // $(element).fullCalendar('gotoDate', date);
                    appViewModel.selectedDate(date);
                },
                eventClick: function(event) {
                    if(appViewModel.selectedEvent()){
                        if(appViewModel.selectedEvent().id === event.id)
                            appViewModel.selectedEvent(null);
                        else{
                            appViewModel.selectedEvent(event);
                            $(element).fullCalendar('gotoDate', event.start);
                        }
                    }
                    else{
                        appViewModel.selectedEvent(event);    
                        $(element).fullCalendar('gotoDate', event.start);
                    }
                    
                },
                eventDrop: function(event) {
                    appViewModel.selectedEvent(event);
                    $(element).fullCalendar('gotoDate', event.start);
                    var existing = ko.utils.arrayFirst(appViewModel.changedEvents(), function(_event) {
                        return _event.id === event.id;
                    });
                    if(existing){
                        existing = event;    
                    }
                    else{
                        appViewModel.changedEvents.push(event);
                    }
                },
                eventResize: function(event) {
                    appViewModel.selectedEvent(event);
                    $(element).fullCalendar('gotoDate', event.start);
                    var existing = ko.utils.arrayFirst(appViewModel.changedEvents(), function(_event) {
                        return _event.id === event.id;
                    });
                    if(existing){
                        existing = event;    
                    }
                    else{
                        appViewModel.changedEvents.push(event);
                    }
                }
            });
            
            $(element).fullCalendar('gotoDate', ko.utils.unwrapObservable(viewModel.viewDate));
        }

    };
})();