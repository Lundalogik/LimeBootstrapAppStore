
var vm = {};

// Load viewmodel
initModel = function(viewModel){
    vm = viewModel;
}

//For checkboxes
var indeterminateStatus = {
    NotSelected : 0,
    PartiallySelected: 1,
    Selected : 2
};

// Table object
var Table = function(t, descriptive){

    var self = this;
    // Load database name
    self.name = t.name;
    // Load local name
    self.localname = t.localname;
    // Load timestamp
    self.timestamp = ko.observable(moment(t.timestamp).format("YYYY-MM-DD"));
    // Load invisible attribute
    self.invisible = t.invisible;
    // Initiate fields visible in gui
    self.guiFields = ko.observableArray();
    
    //Checks if any of the fields is included in an existing package.
	self.inExistingPackage = ko.observable(false);
    
    self.indeterminate = ko.observable(indeterminateStatus.NotSelected);
    
	// Load attributes 
    self.attributes = {};
    $.each(vm.tableAttributes, function(i, a){
        self.attributes[a] = t[a];
    });
    
    //helper function for indeterminate
    self.getIndeterminate = function(){
        var fieldCount = self.guiFields().length;
        var selectedFields = 0;
        
        ko.utils.arrayForEach(self.guiFields(), function(field){
            if(field.selected()){
                selectedFields++;
            }
        });
        var indeterminate = indeterminateStatus.NotSelected;
        try{
            if(selectedFields == 0){
                indeterminate = indeterminateStatus.NotSelected;
            }
            else if(selectedFields != fieldCount){
                indeterminate = indeterminateStatus.PartiallySelected;
            }
            else {
                indeterminate = indeterminateStatus.Selected;
            }
        }catch(e){alert(e);}
        return indeterminate;
    }
    
    var tooltipAttributesTable = "";

	//Tooltip for the table´s
	$.each(self.attributes, function(attributeName,attributeValue){
			if (attributeValue){
                if(attributeName == 'label'){
                    tooltipAttributesTable += '<b>' + attributeName + '</b>: ' + vm.tableLabel[attributeValue] + '<br>';
                }else if(attributeName == 'invisible'){
                    tooltipAttributesTable += '<b>' + attributeName + '</b>: ' + vm.tableinvisible[attributeValue] + '<br>';
                }else{
                    tooltipAttributesTable += '<b>' + attributeName + '</b>: ' + attributeValue + '<br>';
                }
            }
	 });

     if(descriptive && descriptive.expression){
         self.attributes['descriptive'] = descriptive.expression;   
     }

    self.tooltipAttributesTable = function(){
        return tooltipAttributesTable;
    }

    // Load gui fields
    self.guiFields(ko.utils.arrayMap(ko.utils.arrayFilter(t.field,function(f){ return f.fieldtype != 255;}), function(f){
        return new Field(f, self.name);
    }));

    

    // If fields of table are shown in column to the right
    self.shown = ko.computed(function(){
        return vm.shownTable() ? (vm.shownTable().name == self.name) : false;
    });

     // Click function to select table including all fields
    self.select = function(){
        self.show();
        var currentIndeterminate = self.indeterminate();
        
        try{
            if(currentIndeterminate == indeterminateStatus.NotSelected || currentIndeterminate == indeterminateStatus.PartiallySelected){
                ko.utils.arrayForEach(self.guiFields(),function(field){
                    field.selected(true);
                });
            }
            else{
                ko.utils.arrayForEach(self.guiFields(),function(field){
                    field.selected(false);
                });
            }
            self.indeterminate(self.getIndeterminate());
        }
        catch(e){alert(e);}
        return true;
    };

    // Click function to show fields
    self.show = function(){
        vm.shownTable(self);
    };
    

    // Computed for keeping track of selected fields
    self.selectedFields = ko.computed(function(){
        return ko.utils.arrayFilter(self.guiFields(), function(f){
            return f.selected();
        });
    });

    // FiltereD fields. These are the ones shown in the gui (but based on guiFields)
    self.filteredFields = ko.observableArray();

    // Filter function for fields
    self.filterFields = function(){
        if(vm.fieldFilter() != ""){
            self.filteredFields.removeAll();
            self.filteredFields(ko.utils.arrayFilter(self.guiFields(), function(item) {

                if(item.name.toLowerCase().indexOf(vm.fieldFilter().toLowerCase()) != -1){
                    return true;
                }
                if(item.localname.toLowerCase().indexOf(vm.fieldFilter().toLowerCase()) != -1){
                    return true;
                }
                if(item.timestamp().toLowerCase().indexOf(vm.fieldFilter().toLowerCase()) != -1){
                    return true;
                }
                return false;
            }));
        }else{
            self.filteredFields(self.guiFields().slice());
        }
    }

    // Select all fields
    self.selectFields = ko.observable(false);

   // Subscribe to select all event
    self.selectFields.subscribe(function(newValue){
        try{
            
            ko.utils.arrayForEach(self.filteredFields(),function(item){
                item.selected(newValue);
            });
            var indeterminate = indeterminateStatus.NotSelected;
            
            if (newValue == true){
                indeterminate = indeterminateStatus.Selected;
            }
            else {
                indeterminate = indeterminateStatus.NotSelected;
            }
            
        }
        catch(e){alert("hej:" + e);}

        self.indeterminate(indeterminate);
    });

    // Set default empty filter
    self.filterFields();
    
}

var Field = function(f, tablename){
    var self = this;

    // Field attributes
    self.table = tablename;
    self.name = f.name;
    self.timestamp = ko.observable(moment(f.timestamp).format("YYYY-MM-DD"));
    self.localname = f.localname;


    self.inExistingPackage = ko.observable(false);

    self.attributes = {};
	self.tooltipAttributes = "";
    
    self.attributes["relationtab"] = '0';
    
    $.each(vm.fieldAttributes, function(index, attributeName){
        
        try{
            if(attributeName == 'fieldtype'){
                self.attributes[attributeName] = vm.fieldTypes[f[attributeName]];
            }
            else if(attributeName == 'relationmaxcount'){
                if(f[attributeName]){
                    self.attributes["relationtab"] = f[attributeName];
                    
                }
            }
            //Create LIP compatible options property
            else if(attributeName == 'string'){
                if(f[attributeName]){
                    if(Object.prototype.toString.call(f[attributeName]) === '[object Object]')
                        self.options = [f[attributeName]];
                    else
                        self.options = f[attributeName];

                    //Delete invalid LIP-properties (idcategory, idstring, etc...)
                    for(var i = 0;i < self.options.length;i++){
                        $.each(vm.excludedOptionAttributes, function(j, optionAttributeName){
                            delete self.options[i][optionAttributeName];
                        });

                    }
                }
            }
            //Handle option queries
            else if(attributeName =='optionquery'){
                if(f[attributeName]){
                    self.attributes[attributeName] = vm.optionQueries().filter(function(o){
                        var ownerTable = o.owner.substring(0,o.owner.indexOf("."));
                        var ownerField = o.owner.substring(o.owner.indexOf(".") + 1);
                        return ownerTable == self.table && ownerField == self.name;
                    })[0]["text"];

                }

            }
            else{
                if(f[attributeName]){
                    self.attributes[attributeName] = f[attributeName];
                }
            }
        }
        catch(e){
            alert("Error fetching attributes: " + e);
        }
        //Set option as default value and remove unnecessary attribute idstring
        if(self.options){
            for(var i = 0; i < self.options.length;i++){
                if(self.options[i]["idstring"] == self.attributes["defaultvalue"] && self.attributes["defaultvalue"] != null){    
              
                   
                    self.options[i]["default"] = "true";
                    delete self.options[i]["idstring"];
                     
                }
                else{
                    delete self.options[i]["idstring"];
                }
            }
        }
    });
	var tooltipAttributes = "";
    //Tooltip for the field´s
	$.each(self.attributes, function(attributeName,attributeValue){
		if(attributeName == 'label'){
			tooltipAttributes += '<b>' + attributeName + '</b>: ' + vm.fieldLabels[attributeValue] + '<br>';
		}
		else if(attributeName == 'newline'){
			tooltipAttributes += '<b>' + attributeName + '</b>: ' + vm.fieldNewline[attributeValue] + '<br>';
		}
		else if(attributeName == 'adlabel'){
			tooltipAttributes += '<b>' + attributeName + '</b>: ' + vm.fieldAdlabel[attributeValue] + '<br>';
		}
		else if(attributeName == 'invisible'){
			tooltipAttributes += '<b>' + attributeName + '</b>: ' + vm.fieldInvisible[attributeValue] + '<br>';
		}
		else{
			tooltipAttributes += '<b>' + attributeName + '</b>: ' + attributeValue + '<br>';
		}
	});

    self.tooltipAttributes = function(){
        return tooltipAttributes;
    }

    var getFieldTypeDisplayName = function(fieldtypeName, length){

        var fieldtypeDisplayName = vm.FieldtTypeDisplayNames[fieldtypeName];
        
        var lengthString = '';
        //Handle string fields
        if(fieldtypeName == "string"){
            if(length !== undefined && length > 0){
                lengthString = '(' + length + ')';
            }
            else if(length !== undefined && length == 0){
                lengthString = '(MAX)';
            }
        }

        return fieldtypeDisplayName + ' ' + lengthString;

    };

    self.fieldTypeDisplayName = ko.computed(function(){
        return getFieldTypeDisplayName(self.attributes.fieldtype , self.attributes.length)
    });

    // Observable for selecting field
    self.selected = ko.observable(false);

    // Subscribe to select event to see if table should be selected or deselected, or partially selected
    self.selected.subscribe(function(newValue){
        var fieldCount = vm.shownTable().guiFields().length;
        var selectedFields = 0;
        
        ko.utils.arrayForEach(vm.shownTable().guiFields(), function(field){
            if(field.selected()){
                selectedFields++;
            }
        });
        
        //Autoselect other side of the relation
        if(self.attributes["fieldtype"] == "relation"){
            //Find other field in tables using idrelation and relatedtable attribute
            var idrelation = self.attributes["idrelation"];
            var relatedTableName = self.attributes["relatedtable"];
            
            ko.utils.arrayForEach(vm.tables(),function(t){
                if(t.name == relatedTableName){
                    ko.utils.arrayForEach(t.guiFields(), function(f){
                        if(f.attributes["fieldtype"] == "relation" && f.attributes["idrelation"] == idrelation){
                            
                            f.selected(newValue);
                            t.indeterminate(t.getIndeterminate());
                        }
                    });
                }
            });
            
        }
        
        try{
            if(selectedFields == 0){
                vm.shownTable().indeterminate(indeterminateStatus.NotSelected);
            }
            else if(selectedFields != fieldCount){
                vm.shownTable().indeterminate(indeterminateStatus.PartiallySelected);
            }
            else {
                vm.shownTable().indeterminate(indeterminateStatus.Selected);
            }
        }catch(e){alert(e);}
        
    });
    
    // Click function for select
    self.select = function(){
        self.selected(!self.selected());
        vm.lastSelectedField(self);
    }
}

// Status options (development, beta, release)
var StatusOption = function(o){
    var self = this;
    self.text = o;
    this.select = function(){
        vm.status(this.text);
    }
}

var VbaComponent = function(c){
    var self = this;
    self.name = c.name;
    self.type = c.type;
    self.selected = ko.observable(false);
    self.extension = function(){
        if(self.type == "Module"){
            return ".bas";
        }
        else if(self.type=="Class Module"){
            return ".cls";
        }
        else if(self.type == "Form"){
            return ".frm";
        }
        else return "";
    }
}

var Relation = function(idrelation, tablename, fieldname){
    var self = this;
    self.idrelation = idrelation;
    self.table1 =  tablename;
    self.field1 =  fieldname;
    self.table2 =  "";
    self.field2 = "";

    self.serialize = function(){
            return {    "table1": self.table1,
                        "field1": self.field1,
                        "table2": self.table2,
                        "field2": self.field2
                    };

    }

}

var SqlComponent = function(sql){
    var self = this;
    self.name = sql.name;
    self.selected = ko.observable(false);
}

var TableIcon = function(icon){
    var self = this;
    self.table = icon.table;
    self.binarydata = icon.iconbinarydata;
}

var OptionQuery = function(o){
    var self = this;
    self.owner = o.owner;
    self.text = o.text;
}


var Descriptive = function(d){
    var self = this;
    self.table = d.table;
    self.expression = d.expression;
    
}

var Localize = function(l){
    var self = this;
    self.owner = l.owner.text;
    self.code = l.code.text;
    self.sv = l.sv.text;
    self.en_us = l.en_us.text;
    self.fi = l.fi.text;
    self.no = l.no.text;
    self.da = l.da.text;
    self.checked = ko.observable(false);
    self.selected = ko.computed(function(){
        return vm.selectedLocale() === self;
    })
    self.select = function(){
        vm.selectedLocale(vm.selectedLocale() === self ? null : self);
    };
}
