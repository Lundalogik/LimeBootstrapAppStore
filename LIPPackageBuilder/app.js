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
                item.selected(newValue);
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
        

        // Navbar function to change tab
        vm.showTab = function(t){
            try{
                if (t == 'vba'){
                    vm.getVbaComponents();
                }
                vm.activeTab(t);
                
            }
            catch(e){alert(e);}
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
        
        
        vm.sql = ko.observableArray();
        
        
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
        
        // Filtered SQL
        vm.filteredSql = ko.observableArray();
        
        // Load model objects
        initModel(vm);

        // Populate table objects
        vm.tables(ko.utils.arrayMap(vm.datastructure.table,function(t){
            return new Table(t);
        }));
        
        // Computed with all selected vba components
        vm.selectedVbaComponents = ko.computed(function(){
            if(vm.vbaComponents()){
                return ko.utils.arrayFilter(vm.vbaComponents(),function(c){
                    return c.selected() | false;
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
                return t.selected();
            });
        });

        // Subscribe to changes in filters
        vm.fieldFilter.subscribe(function(newValue){ 
            vm.shownTable().filterFields();
        });
        vm.tableFilter.subscribe(function(newValue){
            vm.filterTables() = Tables();
        });
        
        vm.componentFilter.subscribe(function(newValue){
            vm.filterComponents();
        });
        
        vm.sqlFilter.subscribe(function(newValue){
            vm.filterSql();
        });
        
        // Set default filter
        vm.filterTables();
        vm.filterSql();
        vm.filterComponents();
        
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