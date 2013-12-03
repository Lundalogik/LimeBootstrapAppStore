
var TextFileImportAddin = null;

(function() {
    if (TextFileImportAddin == null)
        TextFileImportAddin = new Object();
    
    // A javascript expression that defines how we get hold of the Lime.Application object
    var m_strGetLimeExpression = "window.external;";
    
    /***
        Return the Lime.Application object
     **/
    function getApplication() {
        return eval(m_strGetLimeExpression);
    }
    
    /*
        Returns the loaded LimeTextFileImport.Addin instance. Null if not found or not loaded.
     */
    TextFileImportAddin.getAddin = function () {
        var pApplication = getApplication();
        var pConnection = null;
        var pAddIn = null;
        var nCount = 0;
        var nIndex = 0;
        
        if (getComparableVersion(pApplication.Version) < getComparableVersion("10.2.103")) {
            nCount = pApplication.AddIns.Count;
        
            for (nIndex = 1; nIndex <= nCount && pConnection == null; nIndex++) {
                pAddIn = pApplication.AddIns.Item(nIndex);
                
                if (pAddIn != null && pAddIn.ProgID == "LimeTextFileImport.Addin" && pAddIn.Connect)
                    pConnection = pAddIn.Object;
            }
        }
        else {
            pConnection = pApplication.FindAddIn("LimeTextFileImport.Addin");
        }
        
        if (pConnection == null)
            throw new Error(Invoker.getText("textfileimport", "Error.NotInstalled"));
        
        return pConnection;
    }
    
    /*
        Returns the current importer held by the addin
    */
    TextFileImportAddin.getImporter = function () {
        var pApplication = getApplication();
        var pConnection = TextFileImportAddin.getAddin(pApplication);
        
        if (pConnection != null)
            return pConnection.GetImporter();
        else
            return null;
    }
    
    /***
        Initializes the error info and must be called before ErrorInfo.show.
     **/
    TextFileImportAddin.init = function (strGetLimeExpression) {
        if (strGetLimeExpression != undefined && strGetLimeExpression != null && strGetLimeExpression.length > 0)
            m_strGetLimeExpression = strGetLimeExpression;
        else
            m_strGetLimeExpression = "window.external;";   
    }
    
    TextFileImportAddin.setDefaultCursor = function() {
        var pApplication = null;
        
        try {
            pApplication = getApplication();
        
            if (pApplication != null)
                pApplication.MousePointer = 0;
        }
        catch (error) {
            var e = error.message;
        }
    }
    
    TextFileImportAddin.setWaitCursor = function() {
        var pApplication = null;
        
        try {
            pApplication = getApplication();
        
            if (pApplication != null)
                pApplication.MousePointer = 11;
        }
        catch (error) {
            var e = error.message;
        }
    }
    
    /*
        Returns the version in a comparable format.
    */
    function getComparableVersion (strVersion) {
        var nMajor = 0;
        var nMinor = 0;
        var nBuild = 0;
        var nIndex = 0;
        var strLocale = "";
        var strError = "";
        
        strVersion = strVersion.split(".");
        
        for (nIndex = 0; nIndex < strVersion.length && nIndex < 3; nIndex++) {
            if (!isNaN(strVersion[nIndex])) {
                if (nIndex == 0)
                    nMajor = parseInt(strVersion[nIndex]) * 10000;
                else if (nIndex == 1)
                    nMinor = parseInt(strVersion[nIndex]) * 1000;
                else if (nIndex == 2)
                    nBuild = parseInt(strVersion[nIndex]);
            }
            else {
                strLocale = window.external.Locale;
                
                switch (strLocale.toLowerCase())
                {
                case "sv":
                    strError = "Det angivna versionnumret har ett felaktigt format.";
                    break;
                default:
                    strError = "Invalid format of the specified version.";
                    break;
                }
                
                throw new Error(strError);
            }
        }
        
        return nMajor + nMinor + nBuild;   
    }
}) ();