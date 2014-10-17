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
            self.searchVal = ko.observable("").extend({ throttle: 200 });
            self.progSearchResult = ko.observableArray();
            self.hhLogins = ko.observableArray();
            self.Logins = ko.observableArray();
            self.InfoLog = ko.observableArray();
            self.selectedProgrammabilityFrame = ko.observable("list");
            self.selectedTimeFrame = ko.observable("daily");
            self.selectedIndexFrame = ko.observable("existing");
            self.selectedIndex = ko.observable("");
            self.UpdateLog = ko.observableArray();
            self.sqlTables = ko.observableArray();
            self.sqlFields = ko.observableArray();
            self.programmability = ko.observableArray();
            self.sqlJobs = ko.observableArray();
            self.dateIndex = ko.observable(100);//.extend({throttle: 350});
            self.selectedDate = ko.observable(moment().format("YYYY-MM-DD"));
            self.currentDate = ko.observable(moment().format("YYYY-MM-DD"));
            self.selectedTables = ko.observableArray();
            self.indices = ko.observableArray();
            self.dbInfo = ko.observableArray();
            self.selectedInfo = ko.observable("logins");
            self.userList = ko.observableArray();
            self.showUserList = ko.observable(false);
            self.newRecords = ko.observableArray();
            self.updatedRecords = ko.observableArray();
            self.deletedRecords = ko.observableArray();
            self.showRecords = ko.observable(false);
            self.selectedRecords = ko.observableArray();
            self.nbrNewRecords = ko.observable(0);
            self.nbrUpdatedRecords = ko.observable(0);
            self.nbrDeletedRecords = ko.observable(0);
            self.recordDate = ko.observable("");
            self.userDate = ko.observable("");
            self.contextMenuVar = ko.observable("");
            self.newIndices = ko.observableArray();

            self.searchVal.subscribe(function(){self.searchProgrammability()});  

            self.expandAllSQL = function(i,n,d,e){
                ko.utils.arrayForEach(self.sqlTables(),function(sqlTable,i){
                    $("#t" + i).addClass("selected");
                    self.selectedTables.push(sqlTable.tname);

                });
            }

            self.collapseAllSQL = function(i,n,d,e){
                ko.utils.arrayForEach(self.sqlTables(),function(sqlTable,i){
                    $("#t" + i).removeClass("selected");
                    self.removeSQL(sqlTable.tname);
                });

            }

            self.executeSQLOnUpdate = function(i,e){
                lbs.common.executeVba("AdminTools.ExecuteSQLOnUpdate",self.contextMenuVar())
            }

            self.startJob = function(i,e){
                lbs.common.executeVba("AdminTools.StartJob",self.contextMenuVar())
            }

            self.createIndex = function(i,e){
                lbs.common.executeVba("AdminTools.ExecuteSQL",self.selectedIndex())
            }

            self.selectIndex = function(d,e,i){
                $(e.currentTarget).toggleClass("selected");
                if(self.selectedIndex() == i){
                    self.selectedIndex("");
                }
                else{
                    self.selectedIndex(i);
                }
            }


            
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

            var tmpData = {
                        labels: [],
                        datasets: [
                            {
 
                                data: []
                            }
                        ]
                    };
            
            var ctx = $("#dGraph").get(0).getContext("2d");
            var loginLineChart = new Chart(ctx).Line(tmpData, self.goptions);
            var hloginLineChart = new Chart(ctx).Line(tmpData, self.goptions);
            var dUpdateLogLineChart = new Chart(ctx).Line(tmpData, self.goptions);
            var dDurationLineChart = new Chart(ctx).Line(tmpData, self.goptions);
            var hDurationLineChart = new Chart(ctx).Line(tmpData, self.goptions);
            var hUpdateLogLineChart = new Chart(ctx).Line(tmpData, self.goptions);
            var dInfoLogLineChart = new Chart(ctx).Line(tmpData, self.goptions);
            var hInfoLogLineChart = new Chart(ctx).Line(tmpData, self.goptions);
            self.sqlContextMenu = function(d,e,tname){
                self.contextMenuVar(tname);
                $(e.currentTarget).contextMenu('#sqlContextMenu',$(e.currentTarget).attr("id"));            
            }

            self.jobContextMenu = function(d,e,name){
                self.contextMenuVar(name);
                $(e.currentTarget).contextMenu('#jobContextMenu',$(e.currentTarget).attr("id"));        
            }

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
                else if(type == "infolog"){
                     $.each(self.InfoLog(),function(i,v){
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
                else if(type == "infolog"){
                    $.each(self.InfoLog(),function(i,v){
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

            self.getInfoLogData = function (type){
                var d = [];
                $.each(self.InfoLog(),function(i,v){
                    if(type == "info"){
                        d.push(v.info);
                    }
                    else if(type == "warning"){
                        d.push(v.warning);
                    }
                    else if(type == "error"){
                        d.push(v.error);
                    }
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

            self.toggleIndexFrame = function(c){
            
                if(self.selectedIndexFrame() != c){
                    self.selectedIndexFrame(c);
                    $("#btnindexgroup").children("button").toggleClass("selected");

                }
                
            }

            self.toggleProgrammabilityFrame = function(c){
            
                if(self.selectedProgrammabilityFrame() != c){
                    self.selectedProgrammabilityFrame(c);
                    $("#btnprogrammabilitygroup").children("button").toggleClass("selected");

                }
                
            }

            loadChartData = function(){


               // getLoginStats();

                // DAILY LOGINS LATEST WEEK
                self.showUserList(false);
                self.showRecords(false);
                
                self.currentDate(self.selectedDate());

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
                    
                    dayData = {
                        labels: getDayLabels("logins"),
                        datasets: [
                            {
                                label: "Number of logins",
                                fillColor: "rgba(135,172,72,0.4)",
                                strokeColor: "rgba(135,172,72,1)",
                                pointColor: "rgba(135,172,72,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(135,172,72,1)",
                                data: getLoginData()
                            }
                        ]
                    };
                    
                    while(loginLineChart.datasets[0].points.length != 0){
                        loginLineChart.removeData();
                    }

                    ctx = $("#dGraph").get(0).getContext("2d");  
                    loginLineChart = new Chart(ctx).Line(dayData, self.goptions);
                    
                    
                }



                // HOURLY LOGINS LATEST 24H
                
                xmlData = {};
                
                
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetSessionStats, hh,' + self.selectedDate()},
                    true
                );
                self.Logins.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    tmp = xmlData.xmlSource.sessions.s;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.Logins(tmp);

                    hourData = {
                        labels: getHourLabels("logins"),
                        datasets: [
                            {
                                label: "Number of logins",
                                fillColor: "rgba(135,172,72,0.4)",
                                strokeColor: "rgba(135,172,72,1)",
                                pointColor: "rgba(135,172,72,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(135,172,72,1)",
                                data: getLoginData()
                            }
                        ]
                    };
                    
                    while(hloginLineChart.datasets[0].points.length != 0){
                        hloginLineChart.removeData();
                    }

                    ctx = $("#hGraph").get(0).getContext("2d");
                    hloginLineChart = new Chart(ctx).Line(hourData, self.goptions);

                    
                }

                xmlData = {};
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetInfoLog, dd,' + self.selectedDate()},
                    true
                );
                self.InfoLog.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    tmp = xmlData.xmlSource.errors.e;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.InfoLog(tmp);
                    
                    dayData = {
                        labels: getDayLabels("infolog"),
                        datasets: [
                            {
                                label: "Number of information logs",
                                fillColor: "rgba(151,187,205,0.4)",
                                strokeColor: "rgba(151,187,205,1)",
                                pointColor: "rgba(151,187,205,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(151,187,205,1)",
                                data: getInfoLogData('info')
                            },
                            {
                                label: "Number of warning logs",
                                fillColor: "rgba(220,180,20,0.4)",
                                strokeColor: "rgba(220,180,20,1)",
                                pointColor: "rgba(220,180,20,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(220,180,20,1)",
                                data: getInfoLogData('warning')
                            },
                            {
                                label: "Number of error logs",
                                fillColor: "rgba(220,20,20,0.4)",
                                strokeColor: "rgba(220,20,20,1)",
                                pointColor: "rgba(220,20,20,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(220,20,20,1)",
                                data: getInfoLogData('error')
                            }
                        ]
                    };
                    
                    
                    while(dInfoLogLineChart.datasets[0].points.length != 0){
                        dInfoLogLineChart.removeData();
                    }

                    ctx = $("#dInfo").get(0).getContext("2d");  
                    dInfoLogLineChart = new Chart(ctx).Line(dayData, self.goptions);
                    
                    
                }

                xmlData = {};
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetInfoLog, hh,' + self.selectedDate()},
                    true
                );
                self.InfoLog.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    tmp = xmlData.xmlSource.errors.e;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.InfoLog(tmp);
                    
                    hourData = {
                        labels: getHourLabels("infolog"),
                        datasets: [
                            {
                                label: "Number of information logs",
                                fillColor: "rgba(151,187,205,0.4)",
                                strokeColor: "rgba(151,187,205,1)",
                                pointColor: "rgba(151,187,205,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(151,187,205,1)",
                                data: getInfoLogData('info')
                            },
                            {
                                label: "Number of warning logs",
                                fillColor: "rgba(220,180,20,0.4)",
                                strokeColor: "rgba(220,180,20,1)",
                                pointColor: "rgba(220,180,20,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(220,180,20,1)",
                                data: getInfoLogData("warning")
                            },
                            {
                                label: "Number of error logs",
                                fillColor: "rgba(220,20,20,0.4)",
                                strokeColor: "rgba(220,20,20,1)",
                                pointColor: "rgba(220,20,20,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(220,20,20,1)",
                                data: getInfoLogData('error')
                            }
                        ]
                    };
                    
                    while(hInfoLogLineChart.datasets[0].points.length != 0){
                        hInfoLogLineChart.removeData();
                    }

                    ctx = $("#hInfo").get(0).getContext("2d");  
                    hInfoLogLineChart = new Chart(ctx).Line(hourData, self.goptions);
                    
                    
                }
        
                xmlData = {};
                
                
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetLogStats, dd,' + self.selectedDate()},
                    true
                );
                self.UpdateLog.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    tmp = xmlData.xmlSource.updates.u;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.UpdateLog(tmp);
                    
                    dayUpdateLogData = {
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

                   //$("#dLog").replaceWith('<canvas id="dLog" class="chart" width="600" height="320"></canvas>');

                    while(dUpdateLogLineChart.datasets[0].points.length != 0){
                        dUpdateLogLineChart.removeData();
                    }

                    ctx = $("#dLog").get(0).getContext("2d");
                    dUpdateLogLineChart = new Chart(ctx).Line(dayUpdateLogData, self.goptions);

                    dayAvgDurationData = {
                        labels: getDayLabels("updatelog"),
                        datasets: [
                            {
                                label: "Transactiontimes",
                                fillColor: "rgba(135,172,72,0.4)",
                                strokeColor: "rgba(135,172,72,1)",
                                pointColor: "rgba(135,172,72,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(135,172,72,1)",
                                data: getUpdateLogData("duration")
                            }
                        ]
                    };
                    while(dDurationLineChart.datasets[0].points.length != 0){
                        dDurationLineChart.removeData();
                    }

                    ctx = $("#dDur").get(0).getContext("2d");
                    dDurationLineChart = new Chart(ctx).Line(dayAvgDurationData, self.goptions);
                }


                xmlData = {};
                
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetLogStats, hh,' + self.selectedDate()},
                    true
                );
                self.UpdateLog.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    tmp = xmlData.xmlSource.updates.u;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.UpdateLog(tmp);
                    
                    hourUpdateLogData = {
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

                    while(hUpdateLogLineChart.datasets[0].points.length != 0){
                        hUpdateLogLineChart.removeData();
                    }
                    ctx = $("#hLog").get(0).getContext("2d");
                    hUpdateLogLineChart = new Chart(ctx).Line(hourUpdateLogData, self.goptions);

                  

                    hourAvgDurationData = {
                        labels: getHourLabels("updatelog"),
                        datasets: [
                            {
                                label: "Transactiontimes",
                                fillColor: "rgba(135,172,72,0.4)",
                                strokeColor: "rgba(135,172,72,1)",
                                pointColor: "rgba(135,172,72,1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba(135,172,72,1)",
                                data: getUpdateLogData("duration")
                            }
                        ]
                    };
                    while(hDurationLineChart.datasets[0].points.length != 0){
                        hDurationLineChart.removeData();
                    }
                    ctx = $("#hDur").get(0).getContext("2d");
                    hDurationLineChart = new Chart(ctx).Line(hourAvgDurationData, self.goptions);
                    


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
                    {type: 'xml', source: 'AdminTools.GetNewIndices'},
                    true
                );
                self.newIndices.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    var tmp = xmlData.xmlSource.indices.mid;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.newIndices(tmp);

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

                var xmlData = {};
     
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.GetSqlProgrammability'},
                    true
                );
                
                self.programmability.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                   
                    var tmp = xmlData.xmlSource.procedures.p;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
             
                    self.programmability(tmp);

                }

            }

            showField = function(pName, name){
                if(pName == name){
                    return true;
                }
                return false;
            }

            showTable = function(tname){
              

                if(self.selectedTables().indexOf(tname) >= 0){
                    return true;
                }
                return false;
       
                
            }

            showRecordList = function(tname){
                if(self.selectedRecords().indexOf(tname) >= 0){
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
                    self.removeSQL(n);
                    $("#t" + i).removeClass("selected");
                }
            }

            toggleRecords = function(i,e){
                
                var n = $(e.currentTarget).attr("id");
                if(self.selectedRecords().indexOf(n) < 0){
                    self.selectedRecords.push(n);
                    $("#" + n).addClass("selected");
                }
                else{   
                    self.removeRec(n);
                    $("#" + n).removeClass("selected");
                }
            }

            self.removeSQL = function (item) {
                var inItems = self.selectedTables().filter(function(elem){
                    return elem === item; // find the item with the same id
                })[0];
                self.selectedTables.remove(inItems);
                //item.isAdded(false);
            };

            self.removeRec = function (item) {
                var inItems = self.selectedRecords().filter(function(elem){
                    return elem === item; // find the item with the same id
                })[0];
                self.selectedRecords.remove(inItems);
                //item.isAdded(false);
            };

            self.searchProgrammability = function(){

                var xmlData = {};
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'xml', source: 'AdminTools.SearchProgrammability,' + self.searchVal()},
                    true
                );
  
                self.progSearchResult.removeAll();
                if(!jQuery.isEmptyObject(xmlData)){
                    var tmp = xmlData.xmlSource.searchresult.s;
                    if(!(tmp instanceof Array)){
                        tmp = [tmp];
                    }
                    self.progSearchResult(tmp);

                }


            }


            toggleMain = function(c){
               
                if(c == "logins"){
                    self.showUserList(true);
                    self.showRecords(false);
                }
                else if(c == "ulog"){
                    self.showRecords(true);
                    self.showUserList(false);
                }
                else{
                    self.showUserList(false);
                    self.showRecords(false);   
                }

                if(self.selectedInfo() != c){
                    self.selectedInfo(c);
                    $(".btn-main").removeClass("selected");
                    $("#" + c).addClass("selected");
                }
            }  

            openCoworker = function(i,e){
                var eid = $(e.currentTarget).attr("id")
                var idrecord = eid.substring(2,eid.length);
                var link = lbs.common.createLimeLink('coworker', idrecord);
                document.location.href(link);
            }

            openRecord = function(i,e){
                var eid = $(e.currentTarget).attr("id");
                var table = eid.split("_")[0];
                var idrecord = eid.split("_")[1];
                var removed = eid.split("_")[2];
                if(removed == 0){
                    var link = lbs.common.createLimeLink(table, idrecord);
                    document.location.href(link);
                }
            }

            loadRecords = function(i,e){

                var a;
                var t = $(e.currentTarget).attr("id");
                var c = "";
                var xmlData = {};
                var time = "";
                self.showRecords(true);
                
                if(t == "dLog"){
                    a = loginLineChart.getPointsAtEvent(e);
                    if(a.length > 0){
                        time = a[0].label;
                        c = 'AdminTools.GetRecords, ' + time + ', dd';
                    }
                }
                else if(t == "hLog"){
                    a = hloginLineChart.getPointsAtEvent(e);
                    if(a.length > 0){
                        
                        if(self.currentDate() == moment().format("YYYY-MM-DD")){
                            var t1 = moment(a[0].label,"h:mm").hour();
                            var t2 = moment().hour();
                            var diff = t2 - t1;
                            var time = "";
                            if(diff < 0){
                                time = moment().subtract('days',1).format("YYYY-MM-DD");
                                time = time + " " + a[0].label;
                               
                            }
                            else{
                                time = self.currentDate() + " " + a[0].label;
                            }
                        }
                        else{
                            time = self.currentDate() + " " + a[0].label;
                        }
                        c = 'AdminTools.GetRecords, ' + time + ', hh';
                    }
                }
                self.recordDate(time);
       
                self.newRecords.removeAll();
                self.updatedRecords.removeAll();
                self.deletedRecords.removeAll();
                if(a.length > 0){
                    lbs.loader.loadDataSource(
                        xmlData,
                        {type: 'xml', source: c},
                        true
                    );
                    
                    

                    if(!jQuery.isEmptyObject(xmlData)){
                        if(xmlData.xmlSource.records.new != null){
                            var tmp = xmlData.xmlSource.records.new.n;
                            
                            if(!(tmp instanceof Array)){
                                tmp = [tmp];
                            }
                            self.newRecords(tmp);
                        }
                    }
                    
                    
                    if(!jQuery.isEmptyObject(xmlData)){
                        if(xmlData.xmlSource.records.updated != null){
                            var tmp = xmlData.xmlSource.records.updated.u;
                            
                            if(!(tmp instanceof Array)){
                                tmp = [tmp];
                            }
                            self.updatedRecords(tmp);
                        }
                    }

                   
                    if(!jQuery.isEmptyObject(xmlData)){

                        if(xmlData.xmlSource.records.deleted != null){
                           
                            var tmp = xmlData.xmlSource.records.deleted.d;
                            if(!(tmp instanceof Array)){
                                tmp = [tmp];
                            }

                            self.deletedRecords(tmp);
                        }
                    }
                }
                self.nbrNewRecords(self.newRecords().length);
                self.nbrUpdatedRecords(self.updatedRecords().length);
                self.nbrDeletedRecords(self.deletedRecords().length);

            }
      
            loadUsers = function(i,e){
                var a;
                var t = $(e.currentTarget).attr("id");
                var c = "";
                var xmlData = {};
                var time = "";
                self.showUserList(true);
                
                if(t == "dGraph"){
                    a = loginLineChart.getPointsAtEvent(e);
                    if(a.length > 0){
                        time = a[0].label;
                        c = 'AdminTools.GetUsers, ' + time + ', dd';
                    }
                }
                else if(t == "hGraph"){
                    a = hloginLineChart.getPointsAtEvent(e);
                    if(a.length > 0){
                        
                        if(self.currentDate() == moment().format("YYYY-MM-DD")){
                            var t1 = moment(a[0].label,"h:mm").hour();
                            var t2 = moment().hour();
                            var diff = t2 - t1;
                            var time = "";
                            if(diff < 0){
                                time = moment().subtract('days',1).format("YYYY-MM-DD");
                                time = time + " " + a[0].label;
                               
                            }
                            else{
                                time = self.currentDate() + " " + a[0].label;
                            }
                        }
                        else{
                            time = self.currentDate() + " " + a[0].label;
                        }
                        c = 'AdminTools.GetUsers, ' + time + ', hh';
                    }
                }
                self.userDate(time);
                self.userList.removeAll();
                if(a.length > 0){
                    lbs.loader.loadDataSource(
                        xmlData,
                        {type: 'xml', source: c},
                        true
                    );
                    
                    
                    if(!jQuery.isEmptyObject(xmlData)){
                        var tmp = xmlData.xmlSource.users.u;
                        if(!(tmp instanceof Array)){
                            tmp = [tmp];
                        }
                        self.userList(tmp);

                    }
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
