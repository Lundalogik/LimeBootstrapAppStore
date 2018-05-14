# Lime CRM InfoTiles

## Serving you the numbers you care about
Lime CRM InfoTiles brings you your personalized daily information needs served at your fingertips. This addictive app not only saves you time but also keeps you up-to-date with the information you desire. 

## Description
Lime CRM InfoTiles presents the result from filters that you setup in Lime CRM. A filter could for instance be “history notes made on my customers by anyone else but myself during last day” and present a “# new history notes” on your actionpad. 
Each item can use individual color settings making it easy to identify urgency.
When you click on the text, Lime CRM will bring you to the correct table with the appropriate filter.
As you set your filters yourself, only you, Lime CRM and the sky is the limit.

## Requirements
* Lime Bootstrap
* Lime CRM Desktop Client
* Compatible with Lime CRM Cloud

## Installation
1. Create the table "infotile" with the necessary fields, see installation instructions <a href="https://raw.githubusercontent.com/Lundalogik/LimeBootstrapAppStore/master/infotiles/Docs/Lime CRM InfoTiles.docx" download >here</a>. Use the icon "Install\filter_and_sort.ico" for the table.
2. Restart the Lime CRM Desktop Client.
3. Import the file InfoTiles.bas from the ..InfoTiles\Install folder
4. Compile and save the VBA.
5. Copy the "infotiles" folder to the Actionpads\apps folder.
6. In index.html add the following row: 
``` html
<div data-app="{
  app: 'infotiles',
  config: {
    showOnEmpty: true
  }
}">
</div>
```
7. Publish the Actionpads.

### Configuration
``` js
{
  showOnEmpty: true, // [Optional] - Default value false
  timer: 30 // [Optional] - How often the infotiles app should reload (in Seconds), 
            // if undefined/null/false it never reloads (Default: undefined)
            // Try to avoid this functionality if possible due to server performance and user experience
}
```

## More reading
For more extensive description of the app and how to install it, please see the <a href="https://raw.githubusercontent.com/Lundalogik/LimeBootstrapAppStore/master/infotiles/Docs/Lime CRM InfoTiles.docx" download >documentation</a>
