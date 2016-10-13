enums = {
    "initialize": function (vm){
        vm.fieldTypes = {
            "1" : "string",
            "2" : "geography",
            "3" : "integer",
            "4" : "decimal",
            "7" : "time",
            "8" : "text",
            "9" : "script",
            "10" : "html",
            "11" : "xml",
            "12" : "link",
            "13" : "yesno",
            "14" : "multirelation",
            "15" : "file",
            "16" : "relation",
            "17" : "user",
            "18" : "security",
            "19" : "calendar",
            "20" : "set",
            "21" : "option",
            "22" : "image",
            "23" : "formatedstring",
            "25" : "automatic",
            "26" : "color",
            "27" : "sql",
            "255" : "system"
        };
		
		//Translation for tooltip. Field:Label
		vm.fieldLabels = {
			"0": "None",
			"1": "Name",
			"2": "Key",
			"3": "Description",
			"4": "StartDate",
			"5": "DueDate",
			"6": "Category",
			"7": "Completed",
			"8": "Notes",
			"9": "Priority",
			"10": "Responsible Co-worker",
			"13": "Home Telephone Number",
			"14": "Business Telephone Number",
			"15": "Mobile Telephone Number",
			"16": "Home Fax Number",
			"17": "Business Fax Number",
			"18": "Birthday",
			"19": "Home Address",
			"20": "Business Address",
			"21": "Business Home Page",
			"22": "Personal Home Page",
			"23": "Email",
			"24": "Email 2",
			"25": "Job Title",
			"26": "Nickname",
			"27": "Received Time",
			"28": "Sent Time",
			"29": "Location",
			"30": "First Name",
			"31": "Last Name",
			"11": "Table Name",
			"12": "Record ID",
			"32": "Inactive",
			"33": "Company Number",
			"34": "Visiting Address",
			"35": "Record image",
			"36": "Signature",
			"37": "Screenshot",
			"38": "Address - Street Address",
			"39": "Address - Zip Code",
			"40": "Address - City",
			"41": "Address - Country",
			"42": "Customer Number",
			"43": "Geography",
			"44": "Address - Street Address2",
			"45": "Visiting Address - Street Address",
			"46": "Visiting Address - Street Address2",
			"47": "Visiting Address - Zip Code",
			"48": "Visiting Address - City",
			"49": "Visiting Address - Country"

		};
		
		//Translation for tooltip. Field:Newline
		vm.fieldNewline = {
			"0": "Variable Width",
			"1": "Variable Width on New Line",
			"2": "Fixed Width",
			"3": "Fixed Width on New Line"
        };
		
		//Translation for tooltip. Field:Adlabel
		vm.fieldAdlabel = {
			"0": "None",
			"1": "Object GUID",
			"2": "Distinguished name",
			"3": "SID",
			"4": "User logon name",
			"5": "Logon Name (Pre-Windows 2000)",
			"6": "First name",
			"7": "Initials",
			"8": "Last name",
			"9": "Full name",
			"10": "Name",
			"11": "Display name",
			"12": "Description",
			"13": "Office",
			"14": "Telephone number",
			"15": "E-mail",
			"16": "Web page",
			"17": "Street",
			"18": "P.O. Box",
			"19": "City",
			"20": "State/Province",
			"21": "Postal Code",
			"22": "Country/Region",
			"23": "Telephone - Home",
			"24": "Telephone - Pager",
			"25": "Telephone - Mobile",
			"26": "Telephone - Fax",
			"27": "Telephone - IP Phone",
			"28": "Notes",
			"29": "Title",
			"30": "Department",
			"31": "Company"
		};
		
		//Translation for tooltip. Field:invisible
		vm.fieldInvisible = {
			"0": "No",
			"1": "On Forms",
			"2": "In Lists",
			"65535": "Everywhere"
		};
		
		vm.tableLabel = {
			"0":"none",
			"1":"company",
			"2":"person",
			"3":"project",
			"4":"todo",
			"5":"note",
			"6":"user",
			"7":"document",
			"8":"campaign",
			"9":"history",
			"10":"trashcan",
			"11":"infolog",
			"12":"sos",
			"13":"office",
			"14":"product",
			"15":"article",
			"16":"category"
		};
		
		vm.tableinvisible = {
		"0":"no",
		"1":"yes",
		"2":"nonadministrators"
		};
		
        // Attributes for tables
        vm.tableAttributes = [
            "tableorder",
            "invisible",
            "descriptive",
            "syscomment",
            "label",
            "log",
            "actionpad"
        ];

        // Attributes for fields
        vm.fieldAttributes = [
            "fieldtype",
            "limereadonly",
            "invisible",
            "required",
            "width",
            "height",
            "length",
            "defaultvalue",
            "limedefaultvalue",
            "limerequiredforedit",
            "newline",
            "sql",
            "onsqlupdate",
            "onsqlinsert",
            "fieldorder",
            "isnullable",
            "type",
            "relationtab",
            "syscomment",
            "formatsql",
            "limevalidationrule",
            "label",
            "adlabel",
            "idrelation",
            "relationsingle",
            "string",
            "optionquery"
        ];
        vm.FieldtTypeDisplayNames = {
            "string" : "Text",
            "formatedstring" : "Formatted text",
            "yesno" : "Yes/No",
            "link" : "Link",
            "option" : "Option",
            "relation" : "Realtion",
            "time" : "Time",
            "integer" : "Integer",
            "decimal" : "Decimal",
            "user" : "Username"
        };
        
        vm.excludedOptionAttributes = [
            "idcategory",
            "timestamp"
        ]
            


    }
}