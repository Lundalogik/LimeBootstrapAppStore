lbs.apploader.register('DynamicChecklist', function () {
    var self = this;
    //var dummy = lbs.loader.xmlToJSON('<checklist><checklistactivity><title>Felanmälan(1)</title><id>1001</id><done>0</done></checklistactivity><checklistactivity><title>Kontakta kund</title><id>1201</id><done>0</done></checklistactivity></checklist>');
    //alert(JSON.stringify(dummy));

    /*Config (version 2.0)
    This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
    App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
    The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config = function (appConfig) {
        this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
        this.dataSources = [{ type: 'xml', source: 'SosChecklist.XmlStructure', alias: 'checklistdata' }, { type: 'activeInspector'}],
            this.resources = {
                scripts: ['jquery.contextmenu.js'], // <= External libs for your apps. Must be a file
                styles: ['app.css', 'jquery-ui.css'], // <= Load styling for the app.
                libs: ['json2xml.js', 'xml2json.js'] // <= Allready included libs, put not loaded per default. Example json2xml.js
            };
    };
	//{ type: 'activeInspector', source:'', alias:'testar'},
	//, { type: 'activeInspector'}
    self.initialize = function (node, viewModel) {
        viewModel.activitys = ko.observableArray();
        viewModel.scrolldown = ko.observable(true);
        viewModel.scrollup = ko.observable(true);
        viewModel.coordinateY = ko.observable(200);
        var stopShowhasOp = 0;
        if (viewModel.checklistdata.checklistactivitys === null) {
            viewModel.showChecklist = ko.observable(false);
        }
        else {
            viewModel.showChecklist = ko.observable(true);

            $.each(viewModel.checklistdata.checklistactivitys.checklistactivity, function (i, activitys) {
                var done;

                viewModel.activitys.push(activitys);
				activitys.ischecked = ko.observable(activitys.done);
                activitys.isSpecial = ko.observable(activitys.activateadvance);
                activitys.ignoreActivity = ko.observable(activitys.ignore);
                activitys.isOngoing = ko.observable(activitys.ongoing);

                if ((activitys.showall == 1 && stopShowhasOp == 0)) {
                    activitys.isVisible = ko.observable(1);
					//activitys.visible = "1"; //AOC
                    if (activitys.hasoptions == 1) {
                        stopShowhasOp = 1
                    }
                }
                else {
                    stopShowhasOp = 1
                    activitys.isVisible = ko.observable(activitys.visible);
					//activitys.visible = "1";
                }

                activitys.showCheckbox = ko.observable(activitys.option);
                activitys.historyText = ko.observable(lastHistory(activitys));
                if (activitys.activateadvance == 1) {
                    if (activitys.document !== null) {
                        activitys.icon = ko.observable('fa-file-o');
                    }
                    else if (activitys.runvba !== null) {
                        activitys.icon = ko.observable('fa-magic');
                    }
                    else if (activitys.email !== null) {
                        activitys.icon = ko.observable('fa-envelope-o');
                    }
                    else if (activitys.externallink !== null) {
                        activitys.icon = ko.observable('fa-globe');
                    }
                    else if (activitys.cancelerrand == 1) {
                        activitys.icon = ko.observable('fa-check')
                    }
                    else {
                        activitys.icon = ko.observable('');
                    }
                }

                // activitys.runCode = function(run){

                // }

                activitys.special = function (event) {
                    if ((event.activateadvance == 1 && event.done == 0)) {
                        isAdvanced(event);
                    }
                }
                activitys.check = function (event) {
                    if (activitys.isOngoing() == 1 || activitys.ignoreActivity() == 0) {
                        activitys.isOngoing(0);
                        activitys.ongoing = 0;
                    }

                    if ((viewModel.helpdesk.enddate.value !== null)) {
                        alert("Du måste återuppta ärendet");
                        return false;
                    }
                    if ((event.option == 1 && event.ischecked() == 1)) {
                        return false;
                    }
                    var obj;
                    var choice = "";
                    viewModel.optionArray = ko.observableArray(); //AOC
                    if ((event.hasoptions == 1 && event.done == 0)) {

                        var choice = toXml(event.options);
                        if (choice !== '') {
                            $.each(event.options.option, function (i, v) {
                                //viewModel.optionArray.push(v.idchecklistactivity); //AOC
                                if (v.description == choice) {
                                    v.selected = 1;
                                    var stopHasOp = 0; //AOC

                                    var nextstep;
                                    $.each(viewModel.checklistdata.checklistactivitys.checklistactivity, function (c, opt) {

                                        // Aktivteter som har show all ska in i denna enorma tillbyggnad av AOC. || finns för att fånga de aktiviter med options som redan är utskrivna för deras attribut måste in arrayen
                                        if ((opt.showall == 1 && stopHasOp == 0 && opt.mark == 0) || (opt.showall == 1 && opt.hasoptions == 1 && opt.mark == 1)) {

                                            //AOC - Hoppa över de som är option, dessa placeras i optionArray när en aktivitet har options och konrolleras i match.
                                            var match = 0;
                                            match = ko.utils.arrayFirst(viewModel.optionArray(), function (item) {
                                                return opt.idchecklistactivity === item;
                                            });

                                            if (match) {

                                            }
                                            else {
                                                if (!nextstep) {
                                                    opt.visible = "1";
                                                    opt.isVisible(opt.visible);
                                                    choice = v.description;
                                                    if ((opt.hasoptions == 1)) {
                                                        stopHasOp = 1;
                                                        opt.mark = "1";

                                                        //AOC Aktivteten har options, sparar dem i en array                                                        
                                                        $.each(opt.options.option, function (index, option) {
                                                            viewModel.optionArray.push(option.idchecklistactivity);
                                                        });


                                                    }
                                                }
                                                else {
                                                    choice = v.description;
                                                    if ((opt.hasoptions == 1)) {
                                                        opt.mark = "1";

                                                        //AOC Aktivteten har options, sparar dem i en array                                                        
                                                        $.each(opt.options.option, function (index, option) {
                                                            viewModel.optionArray.push(option.idchecklistactivity);
                                                        });

                                                    }
                                                }

                                            }

                                            //Följande görs för att eventuellt tanda och släcka de som är specefika för just denna AOC
                                            if (opt.idchecklistactivity == nextstep) {

                                                opt.visible = "1";
                                                choice = v.description;
                                                opt.isVisible(opt.visible);
                                                //har aktiviteten options så ska den inte fortsätta
                                                if ((opt.hasoptions == 1)) { // !!!!
                                                    stopHasOp = 1;
                                                    nextstep = ""
                                                }
                                                else {

                                                    //Måste kontrollera om det finns någon nextstep för annars smäller sista checklistepunkten!
                                                    if (opt && opt.options && opt.options.option) {
                                                        if (opt.options.option.nextstep !== 0) {
                                                            nextstep = opt.options.option.idchecklistactivity;
                                                        }

                                                    }
                                                }
                                            }
                                            else {
                                                if (opt.isVisible() == "0") {
                                                    opt.isVisible("0");
													opt.mark = "0";
                                                }
                                            }


                                        }



                                        if ((opt.idchecklistactivity == v.nextstep && opt.showall == 0)) {
                                            opt.visible = "1";
                                            choice = v.description;
                                            opt.isVisible(opt.visible);

                                        }


                                        if (opt.idchecklistactivity == v.idchecklistactivity) {
                                            opt.showCheckbox(1);
                                            opt.option = 1;
                                            opt.isVisible("1");
                                            addNote(opt, "Valde alternativet:");
                                            if (opt.department != null) {
                                                setOffice(opt);
                                            }
                                            if (opt.comment == 1) {
                                                var result = writeComment();
                                                opt.ischecked(result);
                                                opt.done = result;
                                            }
                                            opt.visible = "1";
                                            if (opt.hasoptions == 0) {
                                                opt.ischecked("1");
                                                opt.done = "1";
                                                stopHasOp = 0; //AOC - För att fortsätta efter att en option är avprickad
                                                nextstep = opt.options.option.idchecklistactivity; //AOC, för att veta vilket som är nästa steg.

                                            }


                                        }


                                    });
                                }
                            });

                        }
                        else {
                            return false;
                        }

                    }
                    else if (event.done == 0) {
                        if (event.department != null) {
                            setOffice(event);
                        }
                        $.each(viewModel.checklistdata.checklistactivitys.checklistactivity, function (c, o) {
                            if (typeof (event.options) !== 'undefined') {
                                if (o.idchecklistactivity == event.options.option.idchecklistactivity) {
                                    o.visible = "1";
                                    o.isVisible(o.visible);
                                    addNote(event, "Godkände:");
                                    obj = o;
                                }
                            }
                        });
                    }
                    if (event.done == 1) {
                        var list = lbs.common.executeVba('SosChecklist.Uncheck,{0}'.format(event.idchecklistactivity
                        ));
                        if (list.length > 0 && (event.showall != 1 || event.hasoptions == 1)) {
                            list = xml2json($.parseXML(ko.toJS(list)), "");
                            list = $.parseJSON(list);
                            $.each(list.activities.activity, function (i, value) {
                                if (typeof (value) == 'object') {
                                    $.each(viewModel.checklistdata.checklistactivitys.checklistactivity, function (c, o) {
                                        if (o.idchecklistactivity == value.id) {
                                            o.visible = "0";
                                            o.done = 0;
                                            o.ischecked(0);
                                            o.isVisible(0);
											o.mark = "0";
                                            obj = o;
                                            o.histories = "";
                                            o.historyText("");
                                           
                                        }
                                    });
                                }
                                else {
                                    $.each(viewModel.checklistdata.checklistactivitys.checklistactivity, function (c, o) {
                                        if (o.idchecklistactivity == value) {
                                            o.visible = "0";
                                            o.done = 0;
                                            o.ischecked(0);
                                            o.isVisible(0);
											o.mark = "0";
                                            obj = o;
                                            o.histories = "";
                                            o.historyText("");
                                            
                                        }
                                    });
                                }
                            });
                        }
                        else {
                            
                            //event.done = 0;      // Denne var bortkommenterad, varför vet ej men den gjorde så att Nej svar på back men Ja fungerar ej om man slår på den.                      
                            event.histories = "";
                            event.historyText("");
                            
                        }
                    }

                    done = event.done == 1 ? 0 : 1;
                    
                    if ((activitys.comment == 1 && activitys.done == 0)) {
                        done = writeComment();
                        if (done === 0) {
                            obj.isVisible(done);
                            obj.done = done;
                            obj.visible = done;
                        }
                    }
                    event.done = done;
                    event.ischecked(done);

                    if (done == 0) {
                        event.histories = "";
                        event.historyText("");
                        addNote(event, "Backade till:");
                    }
                    else {
                        var newHistory;
                        newHistory = history(done);
                        newHistory.option = choice;
                        event.histories = newHistory;
                    }

                    if ((event.done == 1 && event.cancelerrand == 1)) {
                        save();
                        isAdvanced(event);
                    }
                    save();

                    // var historyNote = lastHistory(event);                
                    // event.historyText(historyNote);                                       
                    realoadTooltip();
                }
				
            });
			
            viewModel.up = function () {
                //var y = $("#container2")[0].scrollHeight;                
                var y = viewModel.coordinateY()
                if (y > 0) {
                    y = viewModel.coordinateY() - 50;
                    viewModel.coordinateY(y);
                    $("#container2").scrollTop(y);
                }
            };

            viewModel.down = function () {
                //v//ar y = $("#container2")[0].scrollHeight;                
                var y = viewModel.coordinateY();
                if (y < 200) {
                    y = viewModel.coordinateY() + 50;
                    viewModel.coordinateY(y);
                    $("#container2").scrollTop(y);
                }
            };

            function realoadTooltip() {

                $.each(viewModel.checklistdata.checklistactivitys.checklistactivity, function (i, activity) {
                    if ((activity.done == 0 && activity.histories == null)) {
                        //activitys.histories = null;
                        activity.historyText("");
                        //ko.refreshView();                   
                        //alert("kaktus");                          
                    }
                    else {
                        var te = lastHistory(activity);
                        //alert(JSON.stringify(activity));                     
                        activity.historyText(te);
                    }
                    // activitys.histories = null;                    
                });
            }
			
						
            function setOffice(event) {
                if (event.department != null) {
                    var action = event.department;
                    var typeOfaction = 'office';
                    lbs.common.executeVba('soschecklist.vbaFromChecklist,{0},{1},{2}'.format(action, typeOfaction, event.idchecklistactivity));
                }
            }

            function isAdvanced(event) {
                var action;
                var typeOfaction = '';
                if (event.runvba != null) {
                    action = event.runvba;
                    //typeOfaction = 'runvba';                        
                    lbs.common.executeVba(action);
                }
                if (event.document != null) {
                    action = event.document;
                    typeOfaction = 'document';
                }
                if (event.email != null) {
                    action = event.email;
                    typeOfaction = 'email';
                }
                if (event.externallink != null) {
                    lbs.common.executeVba('SosChecklist.openWindow,' + event.idchecklistactivity);
                }
                if (event.cancelerrand == 1) {
                    typeOfaction = 'cancelerrand';
                }

                if (typeOfaction !== '') {
                    lbs.common.executeVba('soschecklist.vbaFromChecklist,{0},{1},{2}'.format(action, typeOfaction, event.idchecklistactivity));
                }

            }

            function addNote(event, type) {
                var note = type + " " + event.description;
                lbs.common.executeVba('SosChecklist.addNote', note);
            }

            function writeComment() {
                var done = lbs.common.executeVba('soschecklist.writeComment');
                return done
            }

            function save() {
                setFocus();
                $.each(viewModel.checklistdata.checklistactivitys.checklistactivity, function (i, val) {
                    val.historyText('');
					
                });

                var tempJSON = ko.toJS(viewModel.checklistdata);
                tempJSON = JSON.stringify(tempJSON);
                var xml = json2xml($.parseJSON(tempJSON), '');
                lbs.common.executeVba('SosChecklist.SaveVba', xml);
				lbs.common.executeVba('SosChecklist.SaveOpenCLactivities'); //AOC
				//location.reload();   
            }
            function setFocus() {
				
                var y = $("#container2")[0].scrollHeight;
                $("#container2").scrollTop(y);

                c = $("#container2").offset();
                if (y > 350) {
                    //viewModel.down = ko.observable(false);                                                
                    viewModel.scrolldown(true);
                    viewModel.scrollup(true);
                }
                else {
                    viewModel.scrolldown(false);
                    viewModel.scrollup(false);
                }
            }
            function toXml(b) {
                var xml = JSON.stringify(ko.toJS(b));
                xml = json2xml($.parseJSON(xml), '');
                var b = lbs.common.executeVba('SosChecklist.OpenDialog', xml);
                return b;
            }
            function history(value) {
                var d = moment().format("YYYY-MM-D  HH:mm");
                d = d.toString();
                return {
                    timestamp: d,
                    done: value,
                    user: lbs.limeDataConnection.ActiveUser.Name
                }
            }
            function lastHistory(activity) {
                var hi = "";
                if ((activity.histories != null && activity.histories != "")) {
                    // var hi = activity.histories.length;                
                    // // hi = activity.histories[hi - 1];    
                    hi = activity.histories;
                    if ((hi.option != "" && hi.option != null)) {
                        hi = '<b>' + hi.option + '<br/></b><i>' + hi.user + '<br/>' + hi.timestamp; +'</i>';
                    }
                    else {
                        hi = '</b><i>' + hi.user + '<br/>' + hi.timestamp; +'</i>';
                    }
                    return hi;
                }
                else {
                    hi = "";
                    return "";
                }

            }
            viewModel.onLoadData = function (data) {
                setFocus();
            };
		
			
        }
		
		lbs.common.executeVba('SosChecklist.SaveOpenCLactivities'); //AOC
        return viewModel;
		

    };
});

   


    ko.bindingHandlers.tooltip = {   
    init: function(element, valueAccessor, allBindings, viewModel, bindingContext) {        
        if (typeof valueAccessor() ==='object'){
            $(element).attr({'data-toggle':'tooltip','white-space':'nowrap','data-original-title':valueAccessor().text,'data-placement':valueAccessor().placement});        
            $(element).tooltip();    
        }
        else
        {            
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

ko.bindingHandlers.popover = {
    init: function(element, valueAccessor, allBindings, viewModel, bindingContext) {        
        $(element).attr({'data-toggle':'popover','data-container':'body','data-content':valueAccessor(),'data-placement':'top'});   
        $(element).popover({ trigger: "hover", html:"true" })

    },
    update: function(element, valueAccessor, allBindings, viewModel, bindingContext) {
        $(element).attr({'data-toggle':'popover','data-container':'body','data-content':valueAccessor(),'data-placement':'top'});   
    }
};

ko.bindingHandlers.contextmenu = {
    init: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
    },
    update: function (element, valueAccessor, allBindings, viewModel, bindingContext) {        
        $(element).contextMenu('#contextMenu', viewModel);
    }
};
