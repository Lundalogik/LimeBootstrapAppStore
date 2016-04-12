#GetAccept - eSigning

CREATED BY: GetAccept
To use this app you need to have a GetAccept account, create one for free att www.getaccept.com 

#Close more deals faster
GetAccept is a third party tool helping sales people close more deals by taking control of the proposal and eSigning workflow. Now it is integrated with LIME Pro and you can send your document directly from LIME Pro through GetAccept. 

Features :
- Send all doucment from LIME Pro through GetAccept
- Document tracking, who has recived and opened the sent document
- Document analytics, when was it opened, how many times, what pages did they spend time on etc
- Commenting, discuss your proposal directly in the document
- Automatic reminders smooothly moving your deal forward
- eSigning, make it easy for you customers to say and skip the hazle with printers and scanners

#How does it work
You can add the GetAccept App on every object where there is a document tab present. 

##Installation
1. Copy the "getaccept" folder to the apps folder in the Actionpad-folder.
2. Add a yes/no field named to "sent_with_ga" to the document table, set it as protected for editing in LIME Pro
3. Import the GetAccept.bas ("..\Install\VBA") to the VBA
4. Run the Install method in the GetAccept VBA module. You must have a localization table in the databas. For now it is only translated to English and Swedish. Check which fields you have in your localization table. Dependent on which fields you have you need to remove languages in AddOrCheckLocalize in the VBA (Example: If the lanugage Norwegian is missing in you localization table you should remove  oRec.Value("no") = sNO and oRecs(1).Value("no") = sNO)
5. Import the html-tag below to the tables where you want the GetAccept App tho be shown. most commonly used from company.html or busniess.html. Th table must have a document table and you must be able to connect to a person tab either directly on the table or on a related table.

``` html
<div data-app="{app:'GetAccept',config:{
	title_field: 'comment', 
	personSourceTab: '', 	
	personSourceField: 'company',
	businessValue:''  
	}}">
</div>
```
Configuration:
- title_field: The document name field
- personSourceTab: If there is a realiton tab on the object where it shoud look for recipient persons directly, ex: if you place it in company.hmtl you should have persons
- personSourceField: If there is a realtion field on the object where it should look for persons connected to a sub table, ex: if you place it in busniess.html and you have a connection to the company where - persons are connected. 
- businessValue> The name of the field containing the busniessvalue

You are now done. Each user will have their own login credentials which is used to start using the GetAccept integration.

## Important
Each user at a company using the GetAccept integration need to have a GetAccept account.
