#Lync Connector

LIME Pro - Connects people!

The Lync Connector allows you to directly interact and show the Lync status from your colleagues in any Actionpad in LIME Pro, so long as you have a coworker relation on the card where you want to show the information. This is ideal if you, for example, use LIME Pro as a helpdesk system and wish to contact the responsible coworker for a specific ticket. If your colleague changes his Lync-status, the Lync-status will immediately update right on the card.

The app includes a hover functionality which opens up the standard Lync controls, allowing you to easily send a message or call your colleague! WOHOO!

##Install

Copy the “LyncConnector” folder to the “apps” folder. The inspector where the app is supplied must either be of class "coworker" or have a relation to a coworker. Please note that the email-address of the coworker must match the email-address used for the coworker's Lync-account. Otherwise, nothing will show up for that coworker.


 If you want to show the app on class "coworker" add the following HTML to the ActionPad inside the head (LyncConnector-example):

```html
<div class="header-container blue">
    <div data-app="{ app: 'LyncConnector', config: { appType: 'head' } }"></div>
</div>
```

In this case, the app will show the icon and name for the head, so those properties should be removed if placed in an existing Actionpad.


If you want to show the app on other classes add the following HTML to the ActionPad inside the body (LyncConnector-example). The example below will be put in the Helpdesk-Actionpad. Change 'helpdesk' to 'business' if in Business-Actionpad and so on:

```html
<div class="header-container red">
</div>

<div data-app="{ app: 'LyncConnector', config: { coworkerPropertyPath: 'helpdesk' } }"></div>
```


The app defaults to looking at the object called "coworker", if any. If you want to use an object of a different name, for example "responsible", you can supply this name in the config-property "coworkerPropertyName":

```html
<div class="header-container red">
</div>

<div data-app="{ app: 'LyncConnector', config: { coworkerPropertyPath: 'helpdesk', coworkerPropertyName: 'responsible' } }"></div>
```

The above example will look for the responsible-property on the helpdesk-object.


Even deeper chains of objects can be used by supplying the "path" to the object like the following example shows:

```html
<div class="header-container red">
</div>

<div data-app="{ app: 'LyncConnector', config: { coworkerPropertyPath: 'helpdesk.relatedCoworkers', coworkerPropertyName: 'responsible' } }"></div>
```

This will look at helpdesk.relatedCoworkers.responsible.


Please feel free to look at the usage-example files provided in the app-folder.
