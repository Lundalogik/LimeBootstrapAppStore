

/** 
 *
 */
function MergeSubRecord(record) {
    this.Description = record.Text("descriptive");
    this.ID = record.ID;
    this.Record = record;
}

/**
 *
 */
function MergeSubRecords(recordsClass) {
    this.obj = new Array();
    this.Class = recordsClass;
    this.Count = 0;
    
    function MergeSubRecords_Add(record) {
        var pSubRecord = new MergeSubRecord(record);
    
        this.Count++;
        this.obj[this.Count] = pSubRecord;
        
        return pSubRecord;
    }
    
    function MergeSubRecords_Item(index) {
        return this.obj[index];
    }
    
    function MergeSubRecords_RemoveAll() { 
        this.obj = new Object(); 
        this.Count = 0; 
    }
    
    this.Add = MergeSubRecords_Add;
    this.Item = MergeSubRecords_Item;
    this.RemoveAll = MergeSubRecords_RemoveAll;
}

/**
 * MergeRecord is a wrapper around LDE.Record to allow a faster
 * access to multi relation records.
 */
function MergeRecord(parent, record, fields, index) {
    this.Description = record.Text("descriptive");
    this.Fields = fields;
    this.Parent = parent;
    this.Record = record;
    this.Index = index;
    
    this.private__records = new Object();
    this.private__records__modified = null;
    
    // Links records from the source record to this
    function MergeRecord_Link(field, sourceRecord) {
        var pField = null;
        var pThisRecords = null;
        var pSourceRecords = null;
        var pNewSubRecord = null;
        
        pField = this.Fields.Lookup(field, lkLookupFieldByName);

        if (null == pField)
            return null;

        if (pField.Type != lkFieldTypeMultiLink)
            return null;
        
        pSourceRecords = sourceRecord.Records(field);
        
        if (pSourceRecords != null) {
            pThisRecords = this.Records(field);
        
            if (null == pThisRecords) {
                pThisRecords = new MergeSubRecords(pField.LinkedField.Class);
                this.private__records[field] = pThisRecords;
            }
         
            for(var i = 1; i <= pSourceRecords.Count; i++) {
				pNewSubRecord = pThisRecords.Add(pSourceRecords.Item(i).Record);
				pNewSubRecord.Record.Value(pField.LinkedField.Name) = this.Record.ID;
			}
			
			pSourceRecords.RemoveAll();
			
			if (null == this.private__records__modified)
			    this.private__records__modified = new Object();
			    
			this.private__records__modified[field] = 1;
        }
    }
    
    // Returns multi relation records
    function MergeRecord_Records(field) {
        var pRecords = null;
            
        pRecords = this.private__records[field];

        if (null == pRecords && this.Record != null) {
            pRecords = this.Parent.private__subrecords(field, this.Record.ID);
            
            if (pRecords != null)
                this.private__records[field] = pRecords;
        }
        
        return pRecords;
    } 
    
    // Update the record and all modified sub records
    function MergeRecord_Update() {
        var pBatch = null;
        var pField = null;
        var pSubRecords = null;

        pBatch = this.Record.Database.CreateObject("LDE.Batch");
        pBatch.Database = this.Record.Database;
        
        this.Record.Update(pBatch);
        
        if (this.private__records__modified != null) {
            for (var n1 = 1; n1 <= this.Fields.Count; n1++) {
                pField = this.Fields.Item(n1);
                
                if (lkFieldTypeMultiLink == pField.Type) {
                    if (this.private__records__modified[pField.Name] != null && 1 == this.private__records__modified[pField.Name]) {
                        pSubRecords = this.private__records[pField.Name];
                        
                        if (pSubRecords != null) {
                            for (var n2 = 1; n2 <= pSubRecords.Count; n2++) {
                                pSubRecords.Item(n2).Record.Update(pBatch);
                            }
                        }
                    }
                }
            }
        }
        
        pBatch.Execute();
    }
    
    this.Link = MergeRecord_Link;
    this.Records = MergeRecord_Records;
    this.Update = MergeRecord_Update;
}
 
/**
 *
 */
function MergeRecords(fields) { 
    this.obj = new Object(); 
    this.Count = 0; 
    this.Fields = fields;
    
    this.private__records = new Object();

    function MergeRecords_Add(key, record) {
        if (this.obj[key] != null)
            return null;
        
        this.Count++;    
        this.obj[key] = new MergeRecord(this, record, this.Fields, this.Count);
        
        return record;
    }
    
    function MergeRecords_Item(key) { 
        return this.obj[key]; 
    }

    function MergeRecords_RemoveAll() { 
        this.obj = new Object(); 
        this.Count = 0; 
    } 

    function MergeRecords_SubRecords(field, id) {
        var pMergeSubRecords = null;
        var pMergeRecord = null;
        var pField = null;
        var pLinkedClass = null;
        var pLinkedField = null;
        var pFilter = null;
        var pView = null;
        var pRecords = null;

        pField = this.Fields.Lookup(field, lkLookupFieldByName);

        if (null == pField)
            return null;

        if (pField.Type != lkFieldTypeMultiLink)
            return null;

        pLinkedField = pField.LinkedField;
        pLinkedClass = pLinkedField.Class;
            
        pRecords = this.private__records[field];

        if (null == pRecords) {
            pView = pLinkedClass.Database.CreateObject("LDE.View");
            pView.Add("descriptive", lkSortAscending);
            pView.Add(pLinkedField.Name);
            
            pFilter = pLinkedClass.Database.CreateObject("LDE.Filter");
           
            for (var i in this.obj) {
                pMergeRecord = this.obj[i];

                if (pMergeRecord != null) {
                    pFilter.AddCondition(pLinkedField.Name, lkOpEqual, pMergeRecord.Record.ID, lkConditionTypeUnspecified, lkFilterDecoratorNone);

                    if (pFilter.Count > 1)
                        pFilter.AddOperator(lkOpOr);
                }
            } 

            pRecords = pLinkedClass.Database.CreateObject("LDE.Records");
            pRecords.Open(pLinkedClass, pFilter, pView, 0);

            this.private__records[field] = pRecords;
        }
        
        pMergeSubRecords = new MergeSubRecords(pLinkedClass);
        
        for (var i = 1; i <= pRecords.Count; i++) {
            if (pRecords.Item(i).Value(pLinkedField.Name) == id)
                pMergeSubRecords.Add(pRecords.Item(i));
        }
        
        return pMergeSubRecords;
    }
    
    this.Add = MergeRecords_Add; 
    this.Item = MergeRecords_Item; 
    this.RemoveAll = MergeRecords_RemoveAll; 

    this.private__subrecords = MergeRecords_SubRecords;
}