lbs.apploader.register('AdminTools', function () {
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
                scripts: ['chart.js','jquery-ui.js'], // <= External libs for your apps. Must be a file
                styles: ['app.css','jquery-ui.css'], // <= Load styling for the app.
                libs: [] // <= Allready included libs, put not loaded per default. Example json2xml.js
            };
    };

    self.initialize = function (node, viewModel) {
     
        self.vm = function(){
            var self = this;
            

            self.hhLogins = ko.observableArray();
            self.Logins = ko.observableArray();
            selectedChart = ko.observable("logins");
            selectedTimeFrame = ko.observable("daily");
            self.UpdateLog = ko.observableArray();
            self.sqlTables = ko.observableArray();
            self.sqlFields = ko.observableArray();
            self.sqlJobs = ko.observableArray();
            self.dateIndex = ko.observable(100);//.extend({throttle: 350});
            self.selectedDate = ko.observable(moment().format("YYYY-MM-DD"));
            self.selectedTables = ko.observableArray();
            self.indices = ko.observableArray();
            self.dbInfo = ko.observableArray();
            self.selectedInfo = ko.observable("sql");

            self.goptions = {
                tooltipTemplate: "<%if (label){%><%=label%>: <%}%><%= value %><%if (datasetLabel == 'Transactiontimes'){%> ms<%}%>",
                multiTooltipTemplate: "<%if (datasetLabel){%><%=datasetLabel%>: <%}%><%= value %>",
                scaleBeginAtZero: true,
                bezierCurveTension : 0.3
            };

            self.selectedDate.subscribe(function(newValue){
                self.dateIndex(100-Math.floor(moment.duration(moment().diff(moment(self.selectedDate()))).asDays()));
            });

            self.dateIndex.subscribe(function(){
                var max = 100;
                var diff = max - self.dateIndex();
                self.selectedDate(moment().subtract('days',diff).format("YYYY-MM-DD"));
            });


            

            self.subtractDay = function(){
                self.dateIndex(self.dateIndex() - 1);
            }

            self.addDay = function(){
                self.dateIndex(self.dateIndex() + 1);
            }

            self.getDayLabels = function (type){
                var l = [];
                if(type == "logins"){
                    $.each(self.Logins(),function(i,v){
                        //l.push(moment(v.date).format("YYYY-MM-DD");
                        l.push(v.date.substring(0,10));    
                    });
                }
                else if(type == "updatelog"){
                     $.each(self.UpdateLog(),function(i,v){
                        //l.push(moment(v.date).format("YYYY-MM-DD");
                        l.push(v.date.substring(0,10));    
                    });   
                }
                return l;
            }

            self.getHourLabels = function (type){
                var l = [];
                if(type == "logins"){
                    $.each(self.Logins(),function(i,v){
                        l.push(v.hh+ ":00") ;
                    });
                }
                else if(type == "updatelog"){
                    $.each(self.UpdateLog(),function(i,v){
                        l.push(v.hh+ ":00") ;
                    });
                }
                return l;
            }

            self.getLoginData = function (){
                var d = [];
                $.each(self.Logins(),function(i,v){
                    d.push(v.Nbr);
                });
                return d;
            }

            self.getUpdateLogData = function (type){
                var d = [];
                $.each(self.UpdateLog(),function(i,v){
                    if(type == "deleted"){
                        d.push(v.deleted);
                    }
                    else if(type == "new"){
                        d.push(v.new);
                    }
                    else if(type == "updated"){
                        d.push(v.updated);
                    }
                    else if(type == "duration"){
                        d.push(v.duration);
                    }
                });
                return d;
            }

            self.toggleTimeFrame = function(c){
             

                if(self.selectedTimeFrame() != c){
                    self.selectedTimeFrame(c);
                    $("#btnchartgroup").children("button").toggleClass("selected");

                }
                
            }

            loadChartData = function(){


               // getLoginStats();

                // DAILY LOGINS LATEST WEEK

                var xmlData = {};
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetSessionStats, dd,' + self.selectedDate()},
                    true
                );
                self.Logins.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    var tmp = xmlData.xmlSource.sessions.s;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.Logins(tmp);
                    
                    var dayData = {
                        labels: getDayLabels("logins"),
                        datasets: [
                            {
                                label: "Number of logins",
                                fillColor: "rgba(151,187,205,0.4)",
                                strokeColor: "rgba(151,187,205,1)",
                                pointColor: "rgba(151,187,205,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(151,187,205,1)",
                                data: getLoginData()
                            }
                        ]
                    };
                    $("#dGraph").replaceWith('<canvas id="dGraph" class="chart" width="600" height="320"></canvas>');
                    var ctx = $("#dGraph").get(0).getContext("2d");
                    var loginLineChart = new Chart(ctx).Line(dayData, self.goptions);
                }



                // HOURLY LOGINS LATEST 24H
                
                var xmlData = {};
                
                
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetSessionStats, hh,' + self.selectedDate()},
                    true
                );
                self.Logins.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    var tmp = xmlData.xmlSource.sessions.s;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.Logins(tmp);

                    var hourData = {
                        labels: getHourLabels("logins"),
                        datasets: [
                            {
                                label: "Number of logins",
                                fillColor: "rgba(151,187,205,0.4)",
                                strokeColor: "rgba(151,187,205,1)",
                                pointColor: "rgba(151,187,205,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(151,187,205,1)",
                                data: getLoginData()
                            }
                        ]
                    };
                    $("#hGraph").replaceWith('<canvas id="hGraph" class="chart" width="600" height="320"></canvas>');
                    var ctx = $("#hGraph").get(0).getContext("2d");
                    var hloginLineChart = new Chart(ctx).Line(hourData, self.goptions);
                    
                }
        
                var xmlData = {};
                
                
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetLogStats, dd,' + self.selectedDate()},
                    true
                );
                self.UpdateLog.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    var tmp = xmlData.xmlSource.updates.u;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.UpdateLog(tmp);
                    
                    var dayUpdateLogData = {
                        labels: getDayLabels("updatelog"),
                        datasets: [
                            {
                                label: "Deleted",
                                fillColor: "rgba(220,20,20,0.4)",
                                strokeColor: "rgba(220,20,20,1)",
                                pointColor: "rgba(220,20,20,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(220,20,20,1)",
                                data: getUpdateLogData("deleted")
                            },
                            {
                                label: "Updated",
                                fillColor: "rgba(220,180,20,0.4)",
                                strokeColor: "rgba(220,180,20,1)",
                                pointColor: "rgba(220,180,20,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(220,180,20,1)",
                                data: getUpdateLogData("updated")
                            }
                            ,
                            {
                                label: "New",
                                fillColor: "rgba(20,220,20,0.4)",
                                strokeColor: "rgba(20,220,20,1)",
                                pointColor: "rgba(20,220,20,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(20,220,20,1)",
                                data: getUpdateLogData("new")
                            }
                        ]
                    };

                    $("#dLog").replaceWith('<canvas id="dLog" class="chart" width="600" height="320"></canvas>');
                    var ctx = $("#dLog").get(0).getContext("2d");
                    var dUpdateLogLineChart = new Chart(ctx).Line(dayUpdateLogData, self.goptions);

                    var dayAvgDurationData = {
                        labels: getDayLabels("updatelog"),
                        datasets: [
                            {
                                label: "Transactiontimes",
                                fillColor: "rgba(151,187,205,0.4)",
                                strokeColor: "rgba(151,187,205,1)",
                                pointColor: "rgba(151,187,205,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(151,187,205,1)",
                                data: getUpdateLogData("duration")
                            }
                        ]
                    };
                    $("#dDur").replaceWith('<canvas id="dDur" class="chart" width="600" height="320"></canvas>');
                    var ctx = $("#dDur").get(0).getContext("2d");
                    var dDurationLineChart = new Chart(ctx).Line(dayAvgDurationData, self.goptions);
                    //alert(dUpdateLogLineChart.generateLegend());
                    //$("#loglegend").html(dUpdateLogLineChart.generateLegend());
                }


                var xmlData = {};
                
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetLogStats, hh,' + self.selectedDate()},
                    true
                );
                self.UpdateLog.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    var tmp = xmlData.xmlSource.updates.u;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.UpdateLog(tmp);
                    
                    var hourUpdateLogData = {
                        labels: getHourLabels("updatelog"),
                        datasets: [
                            {
                                label: "Deleted",
                                fillColor: "rgba(220,20,20,0.4)",
                                strokeColor: "rgba(220,20,20,1)",
                                pointColor: "rgba(220,20,20,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(220,220,20,1)",
                                data: getUpdateLogData("deleted")
                            },
                            {
                                label: "Updated",
                                fillColor: "rgba(220,180,20,0.4)",
                                strokeColor: "rgba(220,180,20,1)",
                                pointColor: "rgba(220,180,20,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(220,180,20,1)",
                                data: getUpdateLogData("updated")
                            }
                            ,
                            {
                                label: "New",
                                fillColor: "rgba(20,220,20,0.4)",
                                strokeColor: "rgba(20,220,20,1)",
                                pointColor: "rgba(20,220,20,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(20,220,20,1)",
                                data: getUpdateLogData("new")
                            }
                        ]
                    };

                    $("#hLog").replaceWith('<canvas id="hLog" class="chart" width="600" height="320"></canvas>');
                    var ctx = $("#hLog").get(0).getContext("2d");
                    var hUpdateLogLineChart = new Chart(ctx).Line(hourUpdateLogData, self.goptions);

                  

                    var hourAvgDurationData = {
                        labels: getHourLabels("updatelog"),
                        datasets: [
                            {
                                label: "Transactiontimes",
                                fillColor: "rgba(151,187,205,0.4)",
                                strokeColor: "rgba(151,187,205,1)",
                                pointColor: "rgba(151,187,205,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(151,187,205,1)",
                                data: getUpdateLogData("duration")
                            }
                        ]
                    };
                    $("#hDur").replaceWith('<canvas id="hDur" class="chart" width="600" height="320"></canvas>');
                    var ctx = $("#hDur").get(0).getContext("2d");
                    var hDurationLineChart = new Chart(ctx).Line(hourAvgDurationData, self.goptions);
                    


                }
            }

            loadStaticData = function(){


                var xmlData = {};
                
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetSqlTables'},
                    true
                );
                self.sqlTables.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    var tmp = xmlData.xmlSource.tables.table;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.sqlTables(tmp);

                }

                var xmlData = {};
     
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetSqlFields'},
                    true
                );
                
                self.sqlFields.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    var tmp = xmlData.xmlSource.sqlfields.sqlfield;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.sqlFields(tmp);

                }

                var xmlData = {};
     
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetIndexInfo, 0'},
                    true
                );
                
                self.indices.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    var tmp = xmlData.xmlSource.indices.i;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.indices(tmp);

                }

                var xmlData = {};
     
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetDBInfo'},
                    true
                );
                
                self.dbInfo.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    var tmp = xmlData.xmlSource.dbinfo.DB;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.dbInfo(tmp);

                }

                var xmlData = {};
     
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetSqlJobs'},
                    true
                );
                
                self.sqlJobs.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    var tmp = xmlData.xmlSource.sqljobs.job;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.sqlJobs(tmp);

                }

            }

            showField = function(pName, name){
                if(pName == name){
                    return true;
                }
                return false;
            }

            showTable = function(tname){
                //alert(JSON.stringify(self.selectedTables()) + "     " + tname);
                
                if(self.selectedTables().indexOf(tname) >= 0){
                    return true;
                }
                return false;
       
                
            }

            toggleSQLFields = function(i,n,d,e){

                if(self.selectedTables().indexOf(n) < 0){
                    self.selectedTables.push(n);
                    $("#t" + i).addClass("selected");
                }
                else{   
                    self.remove(n);
                    $("#t" + i).removeClass("selected");
                }
            }

            self.remove = function (item) {
                var inItems = self.selectedTables().filter(function(elem){
                    return elem === item; // find the item with the same id
                })[0];
                self.selectedTables.remove(inItems);
                //item.isAdded(false);
            };

            toggleInfo = function(c){
                if(self.selectedInfo() != c){
                    self.selectedInfo(c);
                    $("#" + c).siblings().removeClass("selected");
                    $("#" + c).addClass("selected");
                }
            }  

            

            toggleChart = function(c){
                if(self.selectedChart() != c){
                    self.selectedChart(c);
                    $("#" + c).siblings().removeClass("selected");
                    $("#" + c).addClass("selected");
                }
            }      
        }
       

        return self.vm;
    };


});

$(document).ready(function () {
    loadStaticData();
    loadChartData();

});

ko.bindingHandlers.slider = {
  init: function (element, valueAccessor, allBindingsAccessor) {
    var options = allBindingsAccessor().sliderOptions || {};
    $(element).slider(options);
    ko.utils.registerEventHandler(element, "slidechange", function (event, ui) {
        var observable = valueAccessor();
        observable(ui.value);
    });
    ko.utils.domNodeDisposal.addDisposeCallback(element, function () {
        $(element).slider("destroy");
    });
    ko.utils.registerEventHandler(element, "slide", function (event, ui) {
        var observable = valueAccessor();
        observable(ui.value);
    });
  },
  update: function (element, valueAccessor) {
    var value = ko.utils.unwrapObservable(valueAccessor());
    if (isNaN(value)) value = 0;
    $(element).slider("value", value);

  }
};


ko.bindingHandlers.tooltipPro = {   
    init: function(element, valueAccessor, allBindings, viewModel, bindingContext) {

        if (typeof valueAccessor() ==='object'){
            $(element).attr({'data-toggle':'tooltip','white-space':'nowrap','data-original-title':valueAccessor().text,'data-placement':valueAccessor().placement, 'container':valueAccessor().container});        
            $(element).tooltip();    
        }
        else
        {
            //,'white-space':'nowrap'
            $(element).attr({'data-toggle':'tooltip','white-space':'pre-wrap','data-original-title':valueAccessor(),'data-placement':'top'});        
            $(element).tooltip();    
        }        
    },
    update: function(element, valueAccessor, allBindings, viewModel, bindingContext) {    
        if (typeof valueAccessor() ==='object'){
            $(element).attr({'data-toggle':'tooltip','white-space':'pre-wrap','data-original-title':valueAccessor().text,'data-placement':valueAccessor().placement});        
        }
        else
        {
            $(element).attr({'data-toggle':'tooltip','white-space':'pre-wrap','data-original-title':valueAccessor(),'data-placement':'top'});                    
        }
    }
};