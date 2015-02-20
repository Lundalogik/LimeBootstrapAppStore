#  Business overview #

The Company Overview app gives you a visual presentation of your customer in the actionpad.

There are three headers with different data.

**SOS** (Active tickets)
Shows total active tickets and historical overview of all tickets ever registered.

* Open
* Total amount of tickets

**Sales overview** (Active opportunities)

* The total amount of active sales opportunities based on the business status. 
* The total amount of sales opportunities total won


**History overview** (Elapsed time since last conversation)

* Total time since you've last been in contact with the customer
* Based on certain activities, like sales call, customer visit, etc.  

###Install:
Insert the SQL proceduer named **scp_BusinessOverview** in the database. 
Run the SQL procedure named **scp_BusinessOverviewTranslations**. This script adds the translations for norwegian and English, the swedish one is in alpha, but feel free to ente the SQL script and customize it.
Drag'n drop the app_BusinessOverview.bas into your VBA project. 

Copy the businessOverview app folder to the apps folder in the actionpad folder.

Insert the following html tag in the actionpad where you want it to be shown, most likely the company actionpad.

	<div data-app="{app:'businessOverview'}"></div>

	