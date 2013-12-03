
// creates and initializes an xml document object from the provided data
function createXmlDocument(xmlData) {
    var xmlDocument = null;
    
    try {
        xmlDocument = new ActiveXObject('MSXML2.DOMDocument.6.0');
        xmlDocument.async = false;
        xmlDocument.validateOnParse = true;
        xmlDocument.loadXML(xmlData);
        xmlDocument.setProperty('SelectionLanguage', 'XPath');
    }
    catch (error) {
        throw(error);
    }
    
    return xmlDocument;
}

function selectedValues (sel) { 
	var r = new Array(); 
	var i = 0; 
	for (var s = 0; s < sel.options.length; s++) 
		if (sel.options[s].selected) 
			r[i++] = sel.options[s].value; 
  
  return r; 
} 

function SortDictionary(Buffer){
    var pAdoRs = new ActiveXObject("ADODB.Recordset"); 
    var cSortField = "name";
    var cKeyField = "id";
    var cMaxLength = 255;
    var adVarChar = 200;
    var adOpenDynamic = 2;
    
    
    //Setup the recordset
    pAdoRs.Fields.Append(cSortField, adVarChar, cMaxLength)
    pAdoRs.Fields.Append(cKeyField, adVarChar, cMaxLength)
    pAdoRs.CursorType = adOpenDynamic;
    pAdoRs.Open()
    pAdoRs.Sort = cSortField;
    
    for (var i = 0; i < Buffer.length; i++){
        pAdoRs.AddNew();
        pAdoRs.Fields(cSortField).Value = Buffer[i];
        pAdoRs.Fields(cKeyField).Value = Buffer[i];
    }
    
    pAdoRs.Update();
    pAdoRs.MoveFirst();
    Buffer = new Array();
    
    i = 0;
    while (!pAdoRs.EOF){
        Buffer[i] = pAdoRs.Fields(cKeyField).Value;
        pAdoRs.MoveNext();
        i ++;
    }
    return Buffer;
}

function SaveLogFileToDisk(){
	var pXmlInstance = TextFileImport_GetXmlImportInstance(window.external);
	pXmlInstance.SaveLogFile(window.document.all('importlog').innerHTML);
}