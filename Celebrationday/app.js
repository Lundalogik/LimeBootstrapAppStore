

lbs.apploader.register('Celebrationday', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
            this.dataSources = [];
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

        viewModel.personlist = ko.observableArray();
        viewModel.coworkeremployeedatelist = ko.observableArray();
        viewModel.coworkerbirthdaylist = ko.observableArray();
        viewModel.idlist = ko.observableArray();
        viewModel.empty = ko.observable(true);
        viewModel.header = ko.observable("Time to celebrate!");
        viewModel.firsttime = true;               
        
        viewModel.newValue = ko.observable(moment().format('YYYY-MM-DD'));
        viewModel.valueSubscriber = ko.observable();
        

        viewModel.valueSubscriber = ko.computed(function(){         
            if(viewModel.newValue() != ""){   
                var enddate =  moment(viewModel.newValue()).format('YYYY-MM-DD');
                //alert(enddate)
                var xmlDataPersonsPeriod = lbs.common.executeVba('Celebrationday.GetCelebrationsPeriodList,' + enddate +',' + "csp_get_celebrationdays" +',' + "person" +',' + "dob");
                var xmlDataCoworkersEmployeedatePeriod = lbs.common.executeVba('Celebrationday.GetCelebrationsPeriodList,' + enddate + ',' + "csp_get_celebrationdays" +',' + "coworker" +',' + "employmentdate");
                var xmlDataCoworkersBirthdayPeriod = lbs.common.executeVba('Celebrationday.GetCelebrationsPeriodList,' + enddate + ',' + "csp_get_celebrationdays" +',' + "coworker" +',' + "dob");
                

                //alert(xmlDataPersonsPeriod)
                //alert(xmlDataCoworkersEmployeedatePeriod)
                //alert(xmlDataCoworkersBirthdayPeriod)
                if(viewModel.firsttime!=true){

                 $("li.celebrationlist").remove()
                }
               
                if(xmlDataPersonsPeriod != "") {
                 /*Creates a person object*/

                    viewModel.empty = false;
                    function personPeriod(persondata){

                        this.id = persondata.idperson;
                        this.name = persondata.name;
                        this.age = persondata.age;
                        this.date = persondata.date;
                        this.class = "person"
                        this.pick = function () {

                            lbs.common.executeVba('Celebrationday.OpenInspector,' + this.id +', ' + this.class)

                        }

                        return this;
                    }

                    /*get and transform the xmldata collected from the vba - sql sp.*/
                    /*xmlData now has the output from  the SP*/
                    
                    /*some kind of parse from xml to json code*/
                    var json = xml2json($.parseXML(xmlDataPersonsPeriod), '');
                    json = $.parseJSON(json);
                    viewModel.root = json
                    ///alert(JSON.stringify(viewModel.root))
                    //alert(viewModel.companies.company[1])
                    //alert(JSON.stringify(viewModel.root.companies.company))
                    var personPeriodArray = viewModel.root.persons.person;
                    if (!(personPeriodArray instanceof Array)) {
                        personPeriodArray = [personPeriodArray];
                    }

                    $.each(personPeriodArray, function (index, co) {

                        /*Adds each row to a person object that is added to the list*/
                        var pers = new personPeriod(co)//.idcompany, copmany.name, company.coworker) 
                        viewModel.personlist.push(pers);

                    });
                }



                if(xmlDataCoworkersEmployeedatePeriod != "") {
                 /*Creates a coworker object*/

                    viewModel.empty = false;
                    function coworkerEmployeedatePeriod(coworkerdata){

                        this.id = coworkerdata.idcoworker;
                        this.name = coworkerdata.name;
                        this.years = coworkerdata.age;
                        this.date = coworkerdata.date;
                        this.class = "coworker"
                        this.pick = function () {

                            lbs.common.executeVba('Celebrationday.OpenInspector,' + this.id +', ' + this.class)

                        }

                        return this;
                    }


                    /*get and transform the xmldata collected from the vba - sql sp.*/
                    /*xmlData now has the output from  the SP*/
                    
                    /*some kind of parse from xml to json code*/
                    var json = xml2json($.parseXML(xmlDataCoworkersEmployeedatePeriod), '');
                    json = $.parseJSON(json);
                    viewModel.root = json
                    ///alert(JSON.stringify(viewModel.root))
                    //alert(viewModel.companies.company[1])
                    //alert(JSON.stringify(viewModel.root.companies.company))
                    var coworkerPeriodArray = viewModel.root.coworkers.coworker;
                    if (!(coworkerPeriodArray instanceof Array)) {
                        coworkerPeriodArray = [coworkerPeriodArray];
                    }

                    $.each(coworkerPeriodArray, function (index, co) {

                        /*Adds each row to a coworker object that is added to the list*/
                        var coworkEmpl = new coworkerEmployeedatePeriod(co)
                        viewModel.coworkeremployeedatelist.push(coworkEmpl);

                    });
                }


                if(xmlDataCoworkersBirthdayPeriod != "") {
                 /*Creates a coworker object*/
                    viewModel.empty = false;
                    function coworkerBirthdayPeriod(coworkerdata){

                        this.id = coworkerdata.idcoworker;
                        this.name = coworkerdata.name;
                        this.age = coworkerdata.age;
                        this.date = coworkerdata.date;
                        this.class = "coworker"
                        this.pick = function () {

                            lbs.common.executeVba('Celebrationday.OpenInspector,' + this.id +', ' + this.class)

                        }

                        return this;
                    }

                    /*get and transform the xmldata collected from the vba - sql sp.*/
                    /*xmlData now has the output from  the SP*/
                                 
                    /*some kind of parse from xml to json code*/
                    var json = xml2json($.parseXML(xmlDataCoworkersBirthdayPeriod), '');
                    json = $.parseJSON(json);
                    viewModel.root = json
                    ///alert(JSON.stringify(viewModel.root))
                    //alert(viewModel.companies.company[1])
                    //alert(JSON.stringify(viewModel.root.companies.company))
                    var coworkerPeriodArray = viewModel.root.coworkers.coworker;
                    if (!(coworkerPeriodArray instanceof Array)) {
                        coworkerPeriodArray = [coworkerPeriodArray];
                    }

                    $.each(coworkerPeriodArray, function (index, co) {

                        /*Adds each row to a coworker object that is added to the list*/
                        //alert(JSON.stringify(co))
                        var coworkBirth = new coworkerBirthdayPeriod(co)
                        viewModel.coworkerbirthdaylist.push(coworkBirth);
                        //alert(JSON.stringify(coworkBirth))

                    });
                }

            }
            viewModel.firsttime = false;
            return viewModel.newValue();
        });

        viewModel.openselection = function (){

            var idlist = ko.observableArray()
            var endofperiod = ko.observable()
            endofperiod = moment(viewModel.newValue()).format('YYYY-MM-DD')
            
            //alert($("li.active").attr("id"))
            //alert($("li.active").hasClass("person"))
            //alert($("li").find(".active").attr("id"))
            // $('.nav-tabs li').on('shown.bs.tab', function(event){
            //     var activetab = $(event.target).attr("id");
            //     alert(activetab + "hejsan")
            // });
            // alert($('.child li.active').attr("id") + "tjoo")
            // alert(endofperiod)

            if ($('.parent li.active').attr("id") === "person") {
                //viewModel.idlist = viewModel.personlist;
                xmlSelected = lbs.common.executeVba('Celebrationday.GetCelebrationsPeriodList,' + endofperiod +',' + "csp_get_celebrationdays" +',' + "person" +',' + "dob");
            }

            if ($('.parent li.active').attr("id") === "coworker") {

                if ($('.child li.active').attr("id") === "employment") {
                xmlSelected = lbs.common.executeVba('Celebrationday.GetCelebrationsPeriodList,' + endofperiod + ',' + "csp_get_celebrationdays" +',' + "coworker" +',' + "employmentdate");
                }
                if ($('.child li.active').attr("id") === "birthday") {
                xmlSelected = lbs.common.executeVba('Celebrationday.GetCelebrationsPeriodList,' + endofperiod + ',' + "csp_get_celebrationdays" +',' + "coworker" +',' + "dob");
                }
            }


            lbs.common.executeVba('Celebrationday.OpenSelection,' + endofperiod + ', ' + $("li.active").attr("id") + ', ' + xmlSelected)
             //alert(xmlSelected)
            // var test = ko.toJS(viewModel.idlist);
            // alert(test.length);
            // alert('length: ' + viewModel.idlist.length);
            // for (var i in viewModel.personlist())
            // {
            //     alert()
            // }
            // CREATE XML string
            // var xmlSelected = "<data>";
            // for(var i = 0; i < viewModel.personlist.length; i++)
            // {
            //     alert("loopie")
            //     // Create a node for each id in the selectedproductdata list. xml structure
            //     xmlSelected = xmlSelected + "<object>"
            //     xmlSelected = xmlSelected + "<id>" + viewModel.personlist[i].id.toString() + "</id>"
            //     xmlSelected = xmlSelected + "</object>"
                
            // }
            // xmlSelected = xmlSelected + "</data>";
            // END CREATE XML

            return this;
        };

        return viewModel;
    };
});



ko.bindingHandlers.datepicker = {
    init: function(element, valueAccessor, allBindingsAccessor) {
      //initialize datepicker with some optional options
      var d = moment().format('YYYY-MM-DD');
      var options = allBindingsAccessor().datepickerOptions || {format: 'yyyy-mm-dd', autoclose: true,weekStart:1,todayHighlight:true,startDate:d,orientation:'left top'};
      $(element).datepicker(options);
      
      //when a user changes the date, update the view model
      ko.utils.registerEventHandler(element, "changeDate", function(event) {
             var value = valueAccessor();
             if (ko.isObservable(value)) {
                 value(event.date);
             }                
      });
    },
    update: function(element, valueAccessor)   {
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
