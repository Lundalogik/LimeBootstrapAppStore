lbs.apploader.register('pie', function () {
    var self = this;    
    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */

    self.config =  function(appConfig){            
            this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
            this.fields = appConfig.fields;
            this.options = appConfig.options;
            this.dataSources = [{type: 'activeInspector'}];            
            this.resources = {
                scripts: ['Chart.min.js'], // <= External libs for your apps. Must be a file
                styles: ['app.css'], // <= Load styling for the app.
                libs: [] // <= Allready included libs, put not loaded per default. Example json2xml.js
            };        
    };    
    
    //initialize   
    self.initialize = function (node, viewModel) {               
        var data = self.config.fields;
        data = JSON.stringify(data);                      
        data  = JSON.parse(data);
                
        var valArray = [];
        var colors = [];
        jQuery.each(data, function (i, val){                    
            valArray.push(window.external.ActiveInspector.Controls.GetText(val.field));
            //alert(viewModel.person. +val.field + .text);
            colors.push(val.color);           
        });
        go(valArray,colors);
        return viewModel;
    };

    function go(valArray,colors) {            
        var ctx = $("#myChart").get(0).getContext("2d");                   
        var data = "["
        for (var i = 0; i < valArray.length; i++) {                
            if (valArray[i].indexOf(",") >= 0) {                                
                var d = valArray[i].split(' ');    
                d = removeAllDots(d[0]);                                                
                d = d.replace(/\s/g,'');                               
                d = Math.round(d.replace(',','.'));                                            
                data = data + "{\"value\" : "+ d +", \"color\" : \"" + colors[i] +"\"}"
                data = data + ",";        
            }
            else
            {          
                var d = removeAllDots(valArray[i]);              
                if (d.indexOf(',')> 0)
                {
                    d = Math.round(d.replace(',','.'));                        
                }                 
                if (d != 0)
                {                   
                    if (d.match(/\s/g, '')){                        
                        d = d.replace(/\s/g, '');    
                    }                                     
                }
                                    
                data = data + "{\"value\" : "+ d +", \"color\" : \"" + colors[i] +"\"}"
                //data = data + "{\"value\" : "+ valArray[i].replace(/\s/g, '') +", \"color\" : \"" + colors[i] +"\"}"
                data = data + ",";        
            }
        }            
        data = data.substring(0,data.length - 1) + "]";         
        data = JSON.parse(data);
       
        var options = self.config.options;        
        new Chart(ctx).Doughnut(data,options);
    };    

    function removeAllDots(str)
    {
        var index = str.indexOf('.');
        if (index > -1){
            str = str.substr( 0, index ) + 
                str.slice( index ).replace( /\./g, '' );
        }
        return str;    
    }

});
