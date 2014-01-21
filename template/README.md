#Template project

This is a template app project and a good start for creating your very own app.

##Basic usage

##App.js
1. Create a config and specify a datasource
2. Implement the function initialize()

```javascript
lbs.apploader.register('template', function () { //Give your app a name here
    var self = this;

    //config
    this.config = {
        dataSources: [ //Datasource to load. You can have many

        ],
        resources: {
            scripts: [], //Scripts your app requires. Base path is the appfolder
            styles: ['app.css'], // Include
            libs: [''] //LBS includes many great libs, such as d3.js. Load them here
        }
    },

    //initialize
    this.initialize = function (node, viewModel) { 

    	//node = the html node 
    	//viewModel = Your data from the dataSource and all localizations

        //Use this method to setup you app. 
        //
        //The data you requested along with activeInspector are delivered in the variable viewModel.
        //You may make any modifications you please to it or replace is with a entirely new one before returning it.
        //The returned viewmodel will be used to build your app.

        viewModel.myappname = 'This is an example app';
        viewModel.myapptext = 'The JS solution whould work nicely as <br />a template you know ;)';


        return viewModel;
    }
});

```

##App.html
Build your view

##App.json
Meta data for you app. Versioning and installation

##app.css
if you want custom styleing app it here and include it in the app.js