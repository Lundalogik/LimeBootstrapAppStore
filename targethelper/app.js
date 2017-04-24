lbs.apploader.register('targethelper', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.appmode = appConfig.appmode || 'user';
            this.dataSources = [];
            this.resources = {
                scripts: ['/Datepicker/bootstrap-datepicker.js'], // <= External libs for your apps. Must be a file
                styles: ['app.css','/Datepicker/datepicker.css'], // <= Load styling for the app.
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
        var appConfig = self.config;
        viewModel.appmode = ko.observable(appConfig.appmode);

        function Coworker(c){
            var self = this;
            self.idcoworker = c.idcoworker.value;
            self.name = c.name.text;
        }

        function Month(m,i,v){
            
            var self = this;
            self.name = m;
            self.monthNumber = i;

            self.target = ko.observable(v);
        }

        function TargetType(t){
            var self = this;
            self.name = t.split(",")[0];
            self.key = t.split(",")[1];

            self.selected = ko.observable(false);
            self.select = function(item){
                self.selected(!self.selected());
                viewModel.targetType(self);
                viewModel.error("");
                viewModel.success("");

            }
        }
        if(appConfig.appmode === "admin"){
            function Coworker2(c2){
                var self = this;
                self.name2 = c2.split(",")[0];
                self.idcoworker2 = c2.split(",")[1];

                self.selectedcoworker = ko.observable(false);
                self.selectcoworker = function(item){
                    self.selectedcoworker(!self.selectedcoworker());
                    viewModel.coworker2(self);
                    viewModel.error("");
                    viewModel.success("");

                }
            }
        }



        viewModel.targetType = ko.observable(new TargetType(viewModel.localize.Targethelper.targettype+",null"));
        viewModel.coworker = ko.observable();
        viewModel.coworker2 = ko.observable(new Coworker2(viewModel.localize.Targethelper.coworker+",null"));
         viewModel.coworkers = ko.observableArray();
        viewModel.months = ko.observableArray();
        viewModel.targetTypes = ko.observableArray();
        viewModel.error = ko.observable("");
        viewModel.success = ko.observable("");
        viewModel.targetdefault = ko.observable("");
        viewModel.year = ko.observable(moment().format("YYYY"));

        //alert(0);
        var xmlData = {};

        lbs.loader.loadDataSource(
            xmlData,
            {type:'record', source: 'TargetHelper.GetCoworker'},
            true
        );

        //alert('0,1');
        //alert(JSON.stringify(xmlData));
        viewModel.SplitYearly = function(){
            
            var avg = viewModel.targetdefault(); //prompt("Ange månadsmål", 0);
            if(avg === null){
                return;
            }
            if(avg == parseInt(avg)){
                viewModel.error("");
                $.each(viewModel.months(),function(i,m){

                    m.target(avg);
                });
             
                viewModel.months()[0].target(viewModel.months()[0].target() + diff);
            }else{
                viewModel.error("Målvärde måste vara ett heltal!");
            }
            

        }

        viewModel.Save = function(){
            viewModel.error("");
            viewModel.success("");
            var targetType = viewModel.targetType().key;
            if(appConfig.appmode ==="user"){
                var coworkerID = viewModel.coworker().idcoworker;
            }
            if(appConfig.appmode ==="admin"){
                var coworkerID = viewModel.coworker2().idcoworker2;
            }
            var message;
            
            if(targetType != "null" && coworkerID != "null"){

                
       
                
                    var targets = "";
                    $.each(viewModel.months(),function(i,m){
                        
                        var targetvalue = m.target()
alert(targetvalue);
                        if(targetvalue === ""){
                            alert("f")
                          targetvalue = "0"
                        }
                        alert(targetvalue);
                        targets = targets + targetvalue + ";";
                    });


                    
                    message = lbs.common.executeVba("TargetHelper.SaveTarget," + targetType + ", " + targets + ", " + coworkerID + ", " + moment(viewModel.year()).format("YYYY"));
                if (message == "")
                    {
                        /*
                            if (confirm('Vill du lägga till fler mål')) {
                                // Do nothing!
                            } else {
                                // CLOSE
                                window.open('','_parent','');
                                window.close();
                            }
                            */
                            viewModel.success('Mål skapade!');
                    }
                    else if(message == "update")
                    {
                        viewModel.success('Mål uppdaterade!');
                    }
                    else
                    {
                        viewModel.error(message);
                    }
                
                
            }
            else{
                viewModel.error("Du måste ange en medarbetare och en måltyp");
            }

           

        }
        

        viewModel.GetMonths = function(){
            var months = [
                viewModel.localize.Targethelper.jan,
                viewModel.localize.Targethelper.feb,
                viewModel.localize.Targethelper.mar,
                viewModel.localize.Targethelper.april,
                viewModel.localize.Targethelper.may,
                viewModel.localize.Targethelper.jun,
                viewModel.localize.Targethelper.july,
                viewModel.localize.Targethelper.aug,
                viewModel.localize.Targethelper.sep,
                viewModel.localize.Targethelper.oct,
                viewModel.localize.Targethelper.nov,
                viewModel.localize.Targethelper.dec
            ];
            viewModel.months(ko.utils.arrayMap(months, function(m,i){
                return new Month(m,i,0);
            }));
        }

        viewModel.GetTargetTypes = function(){
            var targetTypes = lbs.common.executeVba("TargetHelper.GetTargetTypes");
            targetTypes = targetTypes.split(";");
            viewModel.targetTypes(ko.utils.arrayMap(targetTypes,function(t){
                return new TargetType(t);
            }));
        }

        viewModel.GetCoworkers = function(){
            var coworkers = lbs.common.executeVba("TargetHelper.GetCoworkers");
            coworkers = coworkers.split(";");
            viewModel.coworkers(ko.utils.arrayMap(coworkers,function(t){
                return new Coworker2(t);
            }));
        }
        

        //alert(1);
        viewModel.coworker(new Coworker(xmlData.coworker));
        //alert('hopp')
        //alert(2);
        viewModel.GetMonths();
        //alert(3);
        viewModel.GetTargetTypes();

        viewModel.GetCoworkers();
        //alert(4);
        $("title").html("Set targets");
        //alert(5);
       
        //viewModel.months()[0].target(6);
        return viewModel;
    };
});

ko.bindingHandlers.numeric = {
    init: function (element, valueAccessor) {
        $(element).on("keydown", function (event) {
            // Allow: backspace, delete, tab, escape, and enter
            if (event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 27 || event.keyCode == 13 ||
                // Allow: Ctrl+A
                (event.keyCode == 65 && event.ctrlKey === true) ||
                // Allow: . ,
                (event.keyCode == 188 || event.keyCode == 190 || event.keyCode == 110) ||
                // Allow: home, end, left, right
                (event.keyCode >= 35 && event.keyCode <= 39)) {
                // let it happen, don't do anything
                return;
            }
            else {
                // Ensure that it is a number and stop the keypress
                if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105)) {
                    event.preventDefault();
                }
            }
        });
    }
};

ko.bindingHandlers.yearpicker = {
    init: function(element, valueAccessor, allBindingsAccessor) {
      //initialize datepicker with some optional options
      var options = allBindingsAccessor().datepickerOptions || {format: 'yyyy', autoclose: true, weekStart: 1, todayHighlight: true, viewMode: "years", minViewMode: "years"};
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