#Lync Connector

The Lync Connector allows you to directly show the picture and Lync status from your colleagues in any Actionpad in Lime PRO, as long as you have a coworker relation on the card where you want to show the information. This is ideal if you, for example, use Lime as a helpdesk-system and easily want to contact the responsible coworker for a specific ticket. If your colleague changes the status, the status will automagically update in Lime, you don't even have to reopen the card.

The app includes a hover functionality which opens up the standard Lync controls, allowing you to easily send a message or call your colleague! WOHOO!

##Install

Copy “showlync” folder to the “apps” folder. The inspector where the app is supplied must either be of class "coworker" or have a relation to the coworker-table.
 
Add the following HTML to the ActionPad (ShowLync-example):

```html
<div data-app="{app:'showlync', config:{
                coworkerfield: 'string',
    }
}">
</div>
```

If using in the coworker actionpad, place it in the header for best design.

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
