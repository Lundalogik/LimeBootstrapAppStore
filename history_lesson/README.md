#Template project

This is a template app project and a good start for creating your very own app.

##Basic usage

##App.js
1. Create a config and specify a datasource
2. Implement the function initialize()

```javascript
lbs.apploader.register('template', function () { // <= Insert name of app here
    var self = this;

    /*Config
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e config.yourpropertiy:'foo'
        These properties are all public and can be set during app initalization. This makes a great way
        for you to make your app very configurable.
    */
    this.config = {
        dataSources: [ //Either provide your data source here, or let the user of your app supply it

        ],
        resources: { // <= Add any extra resources that should be loadad. The paths are realtive your app folder, exept libs which are loaded from system/js/
            scripts: [], // <= External libs for your apps. Must be a file
            styles: ['app.css'], // <= Load styling for the app.
            libs: [] // <= Allready included libs, put not loaded per default. Example json2xml.js
        }
    },

    /*Initialize
        Initialize happens after the data and recources are loaded but before the view is rendered.
        Here it is your job to implement the logic of your app, by attaching data and functions to 'viewModel' and then returning it
        The data you requested along with localization are delivered in the variable viewModel.
        You may make any modifications you please to it or replace is with a entirely new one before returning it.
        The returned viewModel will be used to build your app.
        
        Node is a reference to the HTML-node where the app is being initalized form. Frankly we do not know when you'll ever need it,
        but, well, here you have it.
    */
    this.initialize = function (node, viewModel) {
        viewModel.hello = "world"
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
