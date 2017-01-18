lbs.apploader.register('LIPPackageBuilder', function () {
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
                scripts: ['model.js', 'enums.js', 'packagebuilder.js'], // <= External libs for your apps. Must be a file
                styles: ['app.css'], // <= Load styling for the app.
                libs: ['json2xml.js'] // <= Allready included libs, put not loaded per default. Example json2xml.js
            };
    };

    //initialize
    self.initialize = function (node, vm) {

        $('title').html('LIP Package builder');

        enums.initialize(vm);
        packagebuilder.initialize(vm);
        
        vm.lastSelectedField = ko.observable({});
        
        // Checkbox to select all tables
        vm.selectTables = ko.observable(false);
        


        vm.selectTables.subscribe(function(newValue){
            ko.utils.arrayForEach(vm.filteredTables(),function(item){
                item.select();
            });
        });        
        


        //Checkbox to select all VBA Modules
        vm.selectAllVbaComponents = ko.observable(false);
        
        vm.selectAllVbaComponents.subscribe(function(newValue){
            ko.utils.arrayForEach(vm.filteredComponents(),function(component){
                component.selected(newValue);
            });
        });
        
        //Checkbox to select all SQL procedures and functions
        vm.selectAllSql = ko.observable(false);
        
        vm.selectAllSql.subscribe(function(newValue){
            ko.utils.arrayForEach(vm.filteredSql(),function(procFunc){
                procFunc.selected(newValue);
            });
        });
        
        //Checkbox to select all Localizations and functions
        vm.selectAllLocalizations = ko.observable(false);
        
        vm.selectAllLocalizations.subscribe(function(newValue){
            ko.utils.arrayForEach(vm.filteredLocalizations(),function(l){
                l.checked(newValue);
            });
        });
        
        
        vm.getVbaComponents = function(){
            try{
                var components = lbs.common.executeVba('LIPPackageBuilder.GetVBAComponents');
                components = $.parseJSON(components);
            
                vm.vbaComponents(ko.utils.arrayMap(components,function(c){
                    //Thisapplication is not supported
                    if (c.type !== '100'){
                        return new VbaComponent(c);
                    }
                }));
            
            vm.vbaComponents.sort(function(left,right){
                return left.type == right.type ? 0 : (left.type < right.type ? -1 : 1);
            });
            }catch(e){alert(e);}
            vm.componentFilter("");
            vm.filteredComponents(vm.vbaComponents());
            vm.showComponents(true);
        }

        vm.getLocalizations = function(){
            try{
                var xmlData = {};
                lbs.loader.loadDataSource(
                    xmlData,
                    {type: 'records', source: 'LIPPackageBuilder.GetLocalizations, ' },
                    true
                );

                vm.localizations(ko.utils.arrayMap(xmlData.localize.records, function(l){
                    return new Localize(l);
                }));
            }
            catch(e){
                alert(e);
            }
            vm.localizationFilter("");
            vm.filteredLocalizations(vm.localizations());
            vm.showLocalizations(true);
        }


        var checkIfVbaLoaded = false;
        var checkIfLocalizationsLoaded = false;
        // Navbar function to change tab
        vm.showTab = function(t){
            try{
                if (t == 'vba' && checkIfVbaLoaded == false){
                    vm.getVbaComponents();
                    checkIfVbaLoaded = true;
                }else if (t == 'localize' && !checkIfLocalizationsLoaded){
                    vm.getLocalizations();
                    checkIfLocalizationsLoaded = true;
                }

                vm.activeTab(t);
            }
                catch(e){alert(e);}

        };
        
        vm.existingPackage = null;
        
        function clearExistingPackage(){
            $.each(vm.tables(),function(index,table){
                $.each(table.guiFields(), function(index,field){
                    field.inExistingPackage(false);
                });
            });
        }
        //Select all tables that exist in the opened package
        function parseExistingPackage(){
            try{
                vm.author(vm.existingPackage.author)
                vm.comment(vm.existingPackage.comment);
                vm.description(vm.existingPackage.description);
                vm.versionNumber(vm.existingPackage.versionNumber);
                vm.name(vm.existingPackage.name);
                vm.status(vm.existingPackage.status);
                
               
            }
            catch(e){alert("Error parsing package: " + e);}
            try{
                var existingPackageTables = vm.existingPackage.install.tables;
                //find all mutual tables
                $.each(existingPackageTables, function(i,et){
                   ko.utils.arrayForEach(vm.tables(), function(table){
                       if(!table.guiFields()){
                           alert(ko.toJSON(table));
                       }
                       else{
                       ko.utils.arrayForEach(table.guiFields(),function(field){
                           
                           $.each(et.fields,function(l,ef){
                               if(ef.name == field.name && et.name == table.name){
                                   field.inExistingPackage(true);
                                   field.selected(true);
                                   table.inExistingPackage(true);
                               }
                           });
                       });
                       }
                    //set selected or partially selected
                    table.indeterminate(table.getIndeterminate());
                   });
                   
                });
            }
            catch(e){alert("Error parsing package: " + e);}
        }
        
        vm.openExistingPackage = function(){
            
            try
            {
                var b64Json = window.external.run('LIPPackageBuilder.OpenExistingPackage');
                b64Json = b64Json.replace(/\r?\n|\r/g,"");
                b64Json = b64_to_utf8(b64Json);
            
                vm.existingPackage =  JSON.parse(b64Json);
                
            }
            catch(e){alert("Error opening existing package:\n" + e);}
            if (vm.existingPackage){
                parseExistingPackage();
            }
            
        }
      
        vm.downloadExistingPackage = function(){
            alert("Not implemented");
        }
      
        // Set default tab to details
        vm.activeTab = ko.observable("details");
        
        // Array with VBA components
        vm.vbaComponents = ko.observableArray();
        vm.showComponents = ko.observable(false);
        
        //Store the icons
        vm.tableIcons = ko.observableArray();
        
        //Store the optionQueries
        vm.optionQueries = ko.observableArray();
        
        //Relation container
        vm.relations = ko.observableArray();
        
        // Descriptive expressions
        vm.descriptives = ko.observableArray();

        //SQL Procedures and functions
        vm.sql = ko.observableArray();

        vm.localizations = ko.observableArray();
        vm.showLocalizations = ko.observable();
        
        vm.filterComponents = function(){
            if(vm.componentFilter() != ""){
                

                // Filter on the three visible columns (name, localname, timestamp)
                vm.filteredComponents(ko.utils.arrayFilter(vm.vbaComponents(), function(item) {
                    if(item.name.toLowerCase().indexOf(vm.componentFilter().toLowerCase()) != -1){
                        return true;
                    }
                    if(item.type.toLowerCase().indexOf(vm.componentFilter().toLowerCase()) != -1){
                        return true;
                    }
                    return false;
                }));
            }else{  
                vm.filteredComponents(vm.vbaComponents().slice());
            }
        }

        vm.filterLocalizations = function(){
            if(vm.localizationFilter() != ""){
                

                // Filter on the three visible columns (name, localname, timestamp)
                vm.filteredLocalizations(ko.utils.arrayFilter(vm.localizations(), function(item) {
                    if(item.owner.toLowerCase().indexOf(vm.localizationFilter().toLowerCase()) != -1){
                        return true;
                    }
                    if(item.code.toLowerCase().indexOf(vm.localizationFilter().toLowerCase()) != -1){
                        return true;
                    }
                    if(item.sv.toLowerCase().indexOf(vm.localizationFilter().toLowerCase()) != -1){
                        return true;
                    }
                    if(item.en_us.toLowerCase().indexOf(vm.localizationFilter().toLowerCase()) != -1){
                        return true;
                    }
                    if(item.da.toLowerCase().indexOf(vm.localizationFilter().toLowerCase()) != -1){
                        return true;
                    }
                    if(item.no.toLowerCase().indexOf(vm.localizationFilter().toLowerCase()) != -1){
                        return true;
                    }
                    if(item.fi.toLowerCase().indexOf(vm.localizationFilter().toLowerCase()) != -1){
                        return true;
                    }
                    return false;
                }));
            }else{  
                vm.filteredLocalizations(vm.localizations().slice());
            }
        }
    
         vm.filterSql = function(){
            if(vm.sqlFilter() != ""){
                vm.filteredSql.removeAll(); 

                // Filter on the three visible columns (name, localname, timestamp)
                vm.filteredSql(ko.utils.arrayFilter(vm.sql(), function(item) {
                    if(item.name.toLowerCase().indexOf(vm.sqlFilter().toLowerCase()) != -1){
                        return true;
                    }
                    
                    return false;
                }));
            }else{  
                vm.filteredSql(vm.sql().slice());
            }
        }
        
        vm.serializePackage = function(){
            packagebuilder.serializePackage();
        }
        
        // Function to filter tables
        vm.filterTables = function(){
            if(vm.tableFilter() != ""){
                vm.filteredTables.removeAll(); 

                // Filter on the three visible columns (name, localname, timestamp)
                vm.filteredTables(ko.utils.arrayFilter(vm.tables(), function(item) {
                    if(item.name.toLowerCase().indexOf(vm.tableFilter().toLowerCase()) != -1){
                        return true;
                    }
                    if(item.localname.toLowerCase().indexOf(vm.tableFilter().toLowerCase()) != -1){
                        return true;
                    }
                    if(item.timestamp().toLowerCase().indexOf(vm.tableFilter().toLowerCase()) != -1){
                        return true;
                    }
                    return false;
                }));
            }else{  
                vm.filteredTables(vm.tables().slice());
            }
        }

        // Filter observables
        vm.tableFilter = ko.observable("");
        vm.fieldFilter = ko.observable("");
        vm.componentFilter = ko.observable("");
        vm.localizationFilter = ko.observable("");
        vm.sqlFilter = ko.observable("");
        
        function b64_to_utf8(str) {
            return unescape(window.atob(str));
        }
    
        
        
        // Load databas structure
        try{
            var db = {};
            //lbs.loader.loadDataSource(db, { type: 'storedProcedure', source: 'csp_lip_getxmldatabase_wrapper', alias: 'structure' }, false);
            db = window.external.run('LIPPackageBuilder.LoadDataStructure', 'csp_lip_getxmldatabase_wrapper');
            db = db.replace(/\r?\n|\r/g,"");
            db = b64_to_utf8(db);
            
            var json = xml2json($.parseXML(db),''); 
            
            json = $.parseJSON(json);
            
            vm.datastructure = json.data.database.tables;
            
            //Create tableicon Array
            vm.tableIcons(ko.utils.arrayMap(json.data.database.tableicons.tableicon, function(t){
                return new TableIcon(t);
                
            }));
            
            vm.optionQueries(ko.utils.arrayMap(json.data.database.optionqueries.optionquery, function(o){
                return new OptionQuery(o);
            }));
            
            vm.sql(ko.utils.arrayMap(json.data.database.sql.ProcedureOrFunction, function(t){
                return new SqlComponent(t);
            }));
            

            vm.descriptives(ko.utils.arrayMap(json.data.database.descriptives.descriptive, function(d){
                return new Descriptive(d);
            }));


            
            
            var sqlDefinitions =  {};
            var def;
            $.each(json.data.database.sql.ProcedureOrFunction, function(i, s){
                def = s.definition.replace(/\r?\n|\r/g,"");
                sqlDefinitions[s.name] = def;
                
            });
            
            vm.sqlDefinitions = ko.observable();
            vm.sqlDefinitions(sqlDefinitions);
            
        }
        catch(err){
            alert(err)
        }
        // Data from details
        vm.author = ko.observable("");
        vm.comment = ko.observable("");
        vm.description = ko.observable("");
        vm.versionNumber = ko.observable("");
        vm.name = ko.observable("");
        // Set default status to development
        vm.status = ko.observable("Development");

        // Set status options 
        vm.statusOptions = ko.observableArray([
            new StatusOption('Development'), new StatusOption('Beta'), new StatusOption('Release')
        ]);
        
        // Load localization data
        try{
            
            var localData = "";
            localData = lbs.common.executeVba('LIPPackageBuilder.LoadDataStructure, csp_lip_getlocalnames');
            localData = localData.replace(/\r?\n|\r/g,"");
            localData = b64_to_utf8(localData);
            
            var json = xml2json($.parseXML(localData),''); 
            json = json.replace(/\\/g,"\\\\");
            
            json = $.parseJSON(json);
            vm.localNames = json.data;
        }
        catch(err){
            alert(err)
        }
        // Table for which fields are shown
        vm.shownTable = ko.observable();
        // All tables loaded
        vm.tables = ko.observableArray();
        // Filtered tables. These are the ones loaded into the view
        vm.filteredTables = ko.observableArray();
        
        

        // Filtered Components
        vm.filteredComponents = ko.observableArray();

        // Filtered Components
        vm.filteredLocalizations = ko.observableArray();
        
        // Filtered SQL
        vm.filteredSql = ko.observableArray();
        
        // Load model objects
        initModel(vm);
        
        try{
        // Populate table objects
        vm.tables(ko.utils.arrayMap(vm.datastructure.table,function(t){
            return new Table(t, vm.descriptives().filter(function(d){
                    return d.table == t.name;
            })[0]);
        }));
        }
        catch(e){
            alert(e);
        }        
        

        vm.shownTable(vm.tables()[0]);

        // Computed with all selected vba components
        vm.selectedVbaComponents = ko.computed(function(){
            if(vm.vbaComponents()){
                return ko.utils.arrayFilter(vm.vbaComponents(),function(c){
                    return c.selected() | false;
                });
            }
        });

        // Computed with all selected localizations
        vm.selectedLocalizations = ko.computed(function(){
            if(vm.localizations()){
                return ko.utils.arrayFilter(vm.localizations(),function(l){
                    return l.checked() | false;
                });
            }
        });
        
        // Computed with all selected sql components
        vm.selectedSql = ko.computed(function(){
            if(vm.sql()){
                return ko.utils.arrayFilter(vm.sql(),function(c){
                    return c.selected() | false;
                });
            }
        });
        
        
        // Computed with all selected tables
        vm.selectedTables = ko.computed(function(){
            return ko.utils.arrayFilter(vm.tables(), function(t){
                return t.indeterminate() == indeterminateStatus.Selected || t.indeterminate() == indeterminateStatus.PartiallySelected;
            });
        });

        vm.selectedLocale = ko.observable(null);

        // Subscribe to changes in filters
        vm.fieldFilter.subscribe(function(newValue){ 
            vm.shownTable().filterFields();
        });
        
        vm.tableFilter.subscribe(function(newValue){
            vm.filterTables();
        });
        
        vm.componentFilter.subscribe(function(newValue){
            vm.filterComponents();
        });

        vm.localizationFilter.subscribe(function(newValue){
            vm.filterLocalizations();
        });
        
        vm.sqlFilter.subscribe(function(newValue){
            vm.filterSql();
        });
        
        // Set default filter
        vm.filterTables();
        vm.filterSql();
        vm.filterComponents();
        vm.filterLocalizations();
        $(window).scroll(function(){
            $("#localeInfo").stop().animate({"marginTop": ($(window).scrollTop()) + "px", "marginLeft":($(window).scrollLeft()) + "px"}, "slow" );
        });
        return vm;
    };


    
});


ko.bindingHandlers.stopBubble = {
  init: function(element) {
    ko.utils.registerEventHandler(element, "click", function(event) {
         event.cancelBubble = true;
         if (event.stopPropagation) {
            event.stopPropagation(); 
         }
    });
  }

};

// Bindinghandler for checkboxes
ko.bindingHandlers.indeterminateOrChecked = {
  init: function(element) {
      try{
        $(element).prop('indeterminate',false);
        $(element).checked = false;
      }
      catch(e){alert(e);}
  },
  update:function(element,val){
      // Unchecked and undeterminate
      
      var valueAccessor = ko.unwrap(val());
      
      if(valueAccessor == indeterminateStatus.NotSelected){
          $(element).prop('indeterminate',false);
          $(element).prop('checked', false);
          // alert("unselected")
      }
      // Indeterminate
      else if(valueAccessor == indeterminateStatus.PartiallySelected){
          $(element).prop('indeterminate', true);
          $(element).prop('checked', false);
      }
      else {
        
        $(element).prop('indeterminate',false);
        $(element).prop('checked', true);
        
      }
      
  }
};
