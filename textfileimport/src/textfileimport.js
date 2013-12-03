
var TextFileImport = null;



(function() {
    if (TextFileImport == null)
        TextFileImport = new Object();
    
    var m_strFileDelimiter = '';
    var m_strQualifier = '';
    var m_strSeparator = 'true';
    
    TextFileImport.getApplication = function () {
	    return window.external;
    }    
    
    TextFileImport.getFileDelimiter = function () {
	    return m_strFileDelimiter;
    }
    
    TextFileImport.getQualifier = function () {
        return m_strQualifier;
    }
    
    TextFileImport.getSeparator = function () {
	    return m_strSeparator;
    }
    
    /*
        
    */
    TextFileImport.invokeUI = function () {
        var pDiv = null;
        var strHtml = "";
        
        pDiv = document.getElementById("TextFileImport");
        
        if (pDiv == null || pDiv.tagName.toLowerCase() != "div")
            throw new Error(Invoker.getText("textfileimport", "error.missingDiv"));
        
        strHtml  = "<div>";
	    strHtml += "<p>Import</p>";
	    strHtml += "<ul id='allSettings'>";
	    strHtml += "<li><span class='normaltext'>Avgränsare:</span>";
        strHtml += "<select width='94px' id='columndelimiter_import'  style='font-family: Verdana;font-size: 10px; width:65px;' name='columndelimiter'>";
        strHtml += "<option value='TabDelimited' selected='true'>tab</option>";
	    strHtml += "<option value=';'>;</option>";
	    strHtml += "<option value=':'>:</option>";
	    strHtml += "<option value='CSVDelimited'>,</option>";
	    strHtml += "<option value='|'>|</option>";
	    strHtml += "</select>";
	    strHtml += "</li>";
	    strHtml += "<li><span class='normaltext'>Textkvalificerare:</span>";
	    strHtml += "<select id='qualifier_import' style='font-family: Verdana;font-size: 10px; width:65px;' name='columndelimiter'>";
	    strHtml += "<option value='' selected='true'>[none]</option>";
	    strHtml += "<option value='quote'>\"</option>";
	    strHtml += "<option value=\"'\">'</option>"
	    strHtml += "</select>";
	    strHtml += "</li>";
	    strHtml += "<li><span class='normaltext'>Separatorer:</span>";
	    strHtml += "<input class='checkbox' type='checkbox' id='separator_import' checked='true' NAME='separator_import'/>";
	    strHtml += "<br/><br/>";
	    strHtml += "<button onclick='TextFileImport.invokeAppFromUI();' class='usebutton' style='float: right; margin: 5px;'>Importera</button><br><br>";
	    strHtml += "</ul>";
	    strHtml += "</div>"; 
	
	    pDiv.innerHTML = strHtml;        
    }
    
    TextFileImport.invokeApp = function () {
        m_strFileDelimiter = Invoker.getIniString("textfileimport", "application", "delimiter", "TabDelimiter");
        m_strQualifier = Invoker.getIniString("textfileimport", "application", "qualifier", "");
        m_strSeparator = Invoker.getIniString("textfileimport", "application", "separator", "0");
        
        if (m_strSeparator != "0" && m_strSeparator != "1")
            m_strSeparator = "0";
            
        m_strSeparator = m_strSeparator == "0" ? "false" : "true";
        
        showImportWindow(1);
    }
    
    TextFileImport.invokeAppFromUI = function () {
	    m_strQualifier = window.document.all("qualifier_import").value
	    m_strFileDelimiter = window.document.all("columndelimiter_import").value;
	    m_strSeparator = window.document.all("separator_import").checked;
		
        showImportWindow(1);
    }
    
    function showImportWindow (nModal) {
        var pExplorer = null;
        var pXmlImport = null;
        var windowHeight = screen.availHeight - 150;
        
        
        try {
            pExplorer = window.external.ActiveExplorer;
            
            if (pExplorer == null || pExplorer.ParentInspector != null)
                throw new Error(Invoker.getText("textfileimport", "validate.noMainExplorer"));
    
            if (Invoker.getIniString("textfileimport", "Explorers", pExplorer.Class.Name, "1") == "0")
                throw new Error(Invoker.getText("textfileimport", "validate.disabled"));
     
            pXmlImport = TextFileImport_GetXmlImportInstance(window.external);

            if (pXmlImport == null)
                throw new Error(Invoker.getText("textfileimport", "error.noXmlInstance"));
            
            if (nModal == undefined || nModal == null)
                nModal = 1;

            if (pXmlImport.InitializeImport(m_strFileDelimiter, m_strQualifier)) {
                if (nModal == 1)
                    window.showModalDialog("apps/textfileimport/src/import.htm", self, "dialogHeight:" + windowHeight + "px; dialogWidth: 850px; edge:sunken; help:no;resizeable:no;scroll:no;status:no;");
                else
                    window.showModelessDialog("apps/textfileimport/src/import.htm", self, "dialogHeight:" + windowHeight + "px; dialogWidth: 850px; edge:sunken; help:no;resizeable:no;scroll:no;status:no;");	    
            }
        }
        catch (pError) {
            alert (pError.message);
        }
    }
    
}) ();