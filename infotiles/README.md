#Lime CRM InfoTiles
##Serving you the numbers you care about
Lime CRM InfoTiles brings you your personalized daily information needs served at your fingertips. This addictive app not only saves you time but also keeps you up-to-date with the information you desire. 
##Description
Lime CRM InfoTiles presents the result from filters that you setup in Lime CRM. A filter could for instance be “history notes made on my customers by anyone else but myself during last day” and present a “# new history notes” on your actionpad. 
Each item can use individual color settings making it easy to identify urgency.
When you click on the text, Lime CRM will bring you to the correct table with the appropriate filter.
As you set your filters yourself, only you, Lime CRM and the sky is the limit.

##Installation
1. Copy the "infotiles" folder to the “apps” folder.
2. Create table “infotile” with the necessary fields, see installation below and put the icon “..\Install\filter_and_sort.ico” on it if you don’t want to use one of your own choice.
3. Import the file InfoTiles.bas from the ..InfoTiles\Install folder
4. In index.html add the following row: 
``` html
<div data-app="{app:'infotiles', config:{showOnEmpty: true}}"></div>
```
### More reading
For more extensive description of the app and how to install it, please see the <a href="https://raw.githubusercontent.com/Lundalogik/LimeBootstrapAppStore/master/infotiles/Docs/Lime CRM InfoTiles.docx" download >documentation</a>
