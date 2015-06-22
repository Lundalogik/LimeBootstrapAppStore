lbs.apploader.register('matrix_bs', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
            this.dataSources = [{ type: 'xml', source: 'Matrix.GetCoworkers', alias: 'coworkerdata' }];
            this.resources = {
                scripts: ['bootstrap-datepicker.js'], // <= External libs for your apps. Must be a file
                styles: ['app.css', 'datepicker.css'], // <= Load styling for the app.
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
        viewModel.startDate = ko.observable('');        
        viewModel.endDate = ko.observable('');        
        
        // ÄNDRA POTENTIAL & CLASSIFICATIOn till xcoordinates & ycoordinates
        viewModel.potentials = ko.observableArray(['A', 'B', 'C']);
        viewModel.classification = ko.observableArray([1, 2, 3]);
        viewModel.rowData = ko.observableArray();     
        viewModel.selectedcoworker = ko.observable('Välj medarbetare');
        viewModel.coworkerslist = ko.observableArray();
        viewModel.activeId = ko.observable(0);
        

        viewModel.showhistory = function(classification, potentials){                       
                var filter = 
                 viewModel.activeId() + ',' 
                + String((viewModel.startDate() == '' ? moment().subtract(3, 'months').calendar().format('YYYY-MM-DD') : viewModel.startDate())) + ',' 
                + String((viewModel.endDate() == '' ? moment().format('YYYY-MM-DD') : viewModel.endDate())) + ',' 
                + String(classification) + ','
                + String(potentials);
            
            lbs.common.executeVba('Matrix.SetMatrixFilter,' + filter);            
        }

        
        $.each(viewModel.coworkerdata.coworkers.coworker, function(index, co){
            var cowork = new coworker(co)
            viewModel.coworkerslist.push(cowork);
            
        });

        function coworker(coworkerdata) {            
            this.name = coworkerdata.name;
            this.id = coworkerdata.idcoworker;
            this.pick = function () {
                viewModel.selectedcoworker(this.name);
                viewModel.activeId(this.id);
            }
            return this;
        }           

        viewModel.click = function () {
            // LÄGG in en kontroll som kollar om värden har ändrats. Om nej kör ej. 

            $(function () {                
                $('.matrix').popover({
                    trigger: 'hover',
                    html:true
                })
            })
            
            $.each(viewModel.potentials(), function (i, p) {
                 $.each(viewModel.classification(), function (ins, esc) {
                    var id = '#'+ p+ '-' +esc
                    $(id).html('');                    
                    $(id).attr("data-content",'');                    
                 });
            });  
            
            var xmlData = lbs.common.executeVba('Matrix.GetMatrix,' + viewModel.activeId() + ',' + 
                (viewModel.startDate() == '' ? moment().subtract(3, 'months').calendar().format('YYYY-MM-DD') : viewModel.startDate()) + ',' + 
                (viewModel.endDate() == '' ? moment().format('YYYY-MM-DD') : viewModel.endDate()));        
            var json = xml2json($.parseXML(xmlData), '');
            json = $.parseJSON(json);
            viewModel.root = json    

            for (var i = 1, l = viewModel.classification().length; i <= l; i++) {
                var row = new createrow(i, viewModel.potentials()[i - 1]);
            }

            

            function createrow(potential, classification) {
                                
                var rowdata = new Array('rad' + row + ':' + []);
                var i = 0;
                var id;               
                $.each(viewModel.root.companies.company, function (index, company) {
                    if (company.classification == classification) {
                        if (company.potential = potential) {
                            i = i + 1;
                            id = '#' + company.id;
                            if ($(id).html() == ''){
                                $(id).html(1);                                
                                $(id).attr("data-content", company.name);
                                $(id).attr("data-toggle", "popover");                                                            
                            }
                            else {                                                                         
                                $(id).html(parseInt($(id).html()) + 1);
                                if($(id).html() < 10){
                                    var title = $(id).attr('data-content') + ' <br /> ' + company.name;
                                    $(id).attr("data-content", title);     

                                }
                                else if($(id).html() == 10){
                                    var title = $(id).attr('data-content') + ' <br /><br /> <b>Och många mer...</b>';
                                    $(id).attr("data-content", title);                                                                
                                }                                
                                
                            }
                            
                        }
                    }
                });
                if (id) {
                    
                }
                return rowdata;
            }
        }

        return viewModel;                
    };
});

ko.bindingHandlers.datepicker = {
    init: function (element, valueAccessor, allBindingsAccessor) {
        //initialize datepicker with some optional options
        var d = moment().format('YYYY-MM-DD');
        var options = allBindingsAccessor().datepickerOptions || { format: 'yyyy-mm-dd', autoclose: true, weekStart: 1, todayHighlight: true, orientation: 'left top' };
        $(element).datepicker(options);

        //when a user changes the date, update the view model
        ko.utils.registerEventHandler(element, "changeDate", function (event) {
            var value = valueAccessor();
            if (ko.isObservable(value)) {
                value(event.date);
            }
        });
    },
    update: function (element, valueAccessor) {
        var value, widget = $(element).data("datepicker");
        //when the view model is updated, update the widget
        if (widget) {
            value = ko.utils.unwrapObservable(valueAccessor());

            if (!value) {
                $(element).val("").change();
                return;
            }

            widget.setDate(_.isString(value) ? new Date(value) : value);
        }
    }
};
