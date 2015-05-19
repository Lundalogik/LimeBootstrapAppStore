#LIME Garcon
##Serving you the numbers you care about
The LIME Garcon brings you your personalized daily information needs served at your fingertips. This addictive app not only saves you time but also keeps you up-to-date with the information you desire. 
##Description
The LIME Garcon presents the result from filters that you setup in LIME. A filter could for instance be “history notes made on my customers by anyone else but myself during last day” and present a “# new history notes” on your actionpad. 
Each item can use individual color settings making it easy to identify urgency.
When you click on the text, LIME will bring you to the correct table with the appropriate filter.
As you set your filters yourself, only you, LIME and the sky is the limit.

The LIME Garcon presents the result from filters that you setup in LIME. A filter could for instance be “history notes made on my customers by anyone else but myself during last day” and present a “# new history notes” on your actionpad. 
Each item can use individual color settings making it easy to identify urgency.
When you click on the text, LIME will bring you to the correct table with the appropriate filter.
As you set your filters yourself, only you, LIME and the sky is the limit.
##Installation
1. Copy "garcon" folder to the “apps” folder.
2. Create table “garconsettings” with the necessary fields, see installation below and put the icon “..\Install\filter_and_sort.ico” on it if you don’t want to use one of your own choice.
3. Import the file Garcon.bas from the ..Garcon\Install folder
4. In index.html add the following row <div data-app="{app:'garcon'}"></div>

##Fields (garconsettings)
|   Field (type)   |  Description   |
| --- | --- |
|  ACTIVE (Yes/No)   |   Uncheck this box if you want to save the filter but not show right now   |
|  COWORKER (Relation)  |  Relation to [coworker]. Recommended to set the ActiveUser as default | 
|   ALL (Yes/No)  |   Click the field if everyone should see this filter   |
|   LABEL (Text(32))   |   The text that follow the filter result number, i.e. “result” + “new history notes”  |
|   ICON (Text(32))	   |   Icon with search help to identify accepted icon names   |
|   EXPLORER (Text(32))   |   Table where your filter is located   |
|   NAME (Text(32))  |   Filter that will produce the result, i.e. number of hits matching your filter   |
|   COLOR (Option)   |   Add these options [blue, darkgrey, red, pink, orange, green]. Background color of the tile   |
|   VISIBLEONZERO (Yes/No)   |   When ticked, item will be shown on the list when result is zero.   |
|   SORTORDER (Integer)  |   Sort order on actionpad  |
|   SEARCHICON (Html field (Tab))   |   Suggested URL is [http://fortawesome.github.io/Font-Awesome/icons/] Use it to search for icons and then copy paste the preferred one into the field [icon]   |

A recommendation is to put a LIME Access query on the table:
``` vba 
(garconsettings.all = 1) 
or 
(garconsettings.coworker.idcoworker = activeuser.idcoworker) 
```

##Suggested field setup
###Database names
<img src="https://github.com/Lundalogik/LimeBootstrapAppStore/blob/master/garcon/Docs/databasnames.png">
###Swedish names
<img src="https://github.com/Lundalogik/LimeBootstrapAppStore/blob/master/garcon/Docs/swedishnames.png">
###English names
<img src="https://github.com/Lundalogik/LimeBootstrapAppStore/blob/master/garcon/Docs/englishnames.png">
