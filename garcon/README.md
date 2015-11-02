#LIME Garcon
##Serving you the numbers you care about
The LIME Garcon brings you your personalized daily information needs served at your fingertips. This addictive app not only saves you time but also keeps you up-to-date with the information you desire. 
##Description
The LIME Garcon presents the result from filters that you setup in LIME. A filter could for instance be “history notes made on my customers by anyone else but myself during last day” and present a “# new history notes” on your actionpad. 
Each item can use individual color settings making it easy to identify urgency.
When you click on the text, LIME will bring you to the correct table with the appropriate filter.
As you set your filters yourself, only you, LIME and the sky is the limit.

##Installation
1. Copy "garcon" folder to the “apps” folder.
2. Create table “garconsettings” with the necessary fields, see installation below and put the icon “..\Install\filter_and_sort.ico” on it if you don’t want to use one of your own choice.
3. Import the file Garcon.bas from the ..Garcon\Install folder
4. In index.html add the following row: 
``` html
<div data-app="{app:'garcon'}"></div>
```

## Important
Try to avoid using this app within cards, since that will slow down opening a card up, thus giving a poor user experience. Also be careful with the amount of filters you activate. The more the filters/tiles, the more the impact on performance in the solution!
### More reading
For more extensive description of the app and how to install it, please see the <a href="https://raw.githubusercontent.com/Lundalogik/LimeBootstrapAppStore/master/garcon/Docs/LIME Garcon.docx" download >documentation</a>
