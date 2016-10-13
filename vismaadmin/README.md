#Visma Administration

##Saves your time
The Visma Administration-app saves your time by making it super-easy in transferring your customers from LIME Pro to Visma Administration as well as showing invoice figures directly in LIME Pro!

##Description
The Visma Administration app allows you to create customers from LIME Pro to Visma Administration by simply clicking a button in the Actionpad on the Company card. Once the customer is created you will receive the Visma CustomerID which will allow you to update customer information from LIME Pro to Visma Administration if you make any changes to your customer information in LIME Pro. When you update your customer in LIME Pro to Visma, you will also receive the latest figures for turnover this, as well as last year.

Every night, invoicing information is transferred from Visma Administration to LIME Pro and visualized in the tab "Invoices" on the company card.

##Installation
1. Install the Visma-service on the Visma server by following the instructions in ..\Install\SERVICE\README.txt or <a href="http://docs.lundalogik.com/pro/addons/visma-administration/installation">here</a>
2. Copy "vismaadmin" folder to the “apps” folder in the Actionpad-folder.
3. Run the SQL-scripts for creating the tables, fields and localization-records needed ("..\Install\SQL") in the right order according to the README-file in the folder and put the icons ("..\Install\ICONS") on the tables.
4. Add separators according to the images in the ..\Install\SQL folder.
5. Create a security policy named "tbl_visma" with only read rights for all groups except administrators. Add the policy to the tables "invoice" and "invoicerow" ass well as for the fields "vismaid", "visma_turnover_yearnow" & "visma_turnover_lastyear".
6. Import the file Visma.bas ("..\Install\VBA").
7. In company.html add the following row (change the vismaUrl, where it says "provisma", to the computername-specific address): 
``` html
<div data-app="{app:'vismaadmin',config:{
	vismaUrl:'http://provisma:8194/api/v1/customer'
	}}">
</div>
```
8. Create a user in LIME Pro that is a member of the Administrators group. Make sure that the user has default login set to "Lime" and not "Windows".
9. Run the Visma service in order to fully create all invoices and invoicerows in LIME Pro.
10. If you need to do an initial migration of customers from Visma to Lime CRM, add the following in index.html (only available for administrators). Change the vismaUrl, where it says "provisma", to the computername-specific address:
``` html
<ul class="menu expandable">
    <li class="menu-header"data-bind="text:'Kommando'"></li> 
    <li class="divider"></li>       
    <li data-bind="
    vba:'Visma.SyncFromVisma, http://provisma:8194/api/v1/customer/export', 
    text:'Migrate customers from Visma', 
    visible: ActiveUser.isAdmin,
    icon:'fa-refresh'"></li>   
</ul>
```

## Important
You need to be able to connect to your Visma-database when transferring your customers from LIME Pro to Visma Administration.

### More reading
For more extensive description of the app and how to install it, please see the <a href="http://docs.lundalogik.com/pro/addons/Visma-administration/start">documentation</a>
