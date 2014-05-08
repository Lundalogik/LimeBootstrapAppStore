#Lync Connector

Lime PRO - Connects people!

The Lync Connector allows you to directly interact and show the Lync status from your colleagues in any Actionpad in Lime PRO, as long as you have a coworker relation on the card where you want to show the information. This is ideal if you, for example, use Lime as a helpdesk-system and easily want to contact the responsible coworker for a specific ticket. If your colleague changes his Lync-status, the Lync-status will automagically update in Lime, you don't even have to reopen the card.

The app includes a hover functionality which opens up the standard Lync controls, allowing you to easily send a message or call your colleague! WOHOO!

##Install

Copy “lyncconnector” folder to the “apps” folder. The inspector where the app is supplied must either be of class "coworker" or have a relation to the coworker-table.
 

 If you want to show the app on class "coworker" add the following HTML to the ActionPad inside the head (LyncConnector-example):

```html
<div class="header-container blue">
    <div data-app="{ app: 'LyncConnector', config: { appType: 'head' } }"></div>
</div>
```

If you want to show the app on other classes add the following HTML to the ActionPad inside the body (LyncConnector-example). The example below will be put in the Helpdesk-Actionpad. Change 'helpdesk' to 'business' if in Business-Actionpad and so on:
```html
<div class="header-container red">
</div>

<div data-app="{ app: 'LyncConnector', config: { coworkerPropertyPath: 'helpdesk' } }"></div>
```