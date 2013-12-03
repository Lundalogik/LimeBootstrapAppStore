var Xml = null;

(function() {
    if (Xml == null)
        Xml = new Object();

    /*
    */
    Xml.decode = function(value) {
        var result = "";
        
        if (value != undefined && value != null) {
            result = value.replace(/&quot;/i, "\"");
        }
        
        return result;
    }

    /*
    */
    Xml.encode = function(value) {
        var result = "";
        
        if (value != undefined && value != null) {
            result = value.toString().replace("\"", "&quot;");
        }
        
        return result;
    }

    /*
    */
    Xml.getAttribute = function(element, name) {
        var result = "";
        
        if (element != null) {
            result = element.getAttribute(name);
            
            if (result.length > 0)
                result = Xml.decode(result);
        }
        
        return result;
    }

    /*
    */
    Xml.removeAttribute = function(element, name) {
        if (element != null) {
            if (element.attributes.getNamedItem(name) != null)
                element.attributes.removeNamedItem(name);
        }
    }

    /*
    */
    Xml.setAttribute = function(element, name, value) {
        if (element != null && name != null && name != undefined && name.length > 0)
            element.setAttribute(name, Xml.encode(value));
    }

    /*
    */
    Xml.xPath = function(xPath, p1, p2, p3, p4, p5) {
        var result = "";
        
        if (xPath != undefined && xPath != null && xPath.length > 0) {
            result = xPath;
            
            if (p1 != undefined && p1 != null)
                result = result.replace("{0}", Xml.encode(p1));
            
            if (p2 != undefined && p2 != null)
                result = result.replace("{1}", Xml.encode(p2));
            
            if (p3 != undefined && p3 != null)
                result = result.replace("{2}", Xml.encode(p3));
            
            if (p4 != undefined && p4 != null)
                result = result.replace("{3}", Xml.encode(p4));
            
            if (p5 != undefined && p5 != null)
                result = result.replace("{4}", Xml.encode(p5));   
        }
        
        return result;
    }
}) ();