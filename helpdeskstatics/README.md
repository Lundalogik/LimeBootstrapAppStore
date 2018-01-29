#  Helpdesk Statics #

The Helpdesk Statics app shows you statistics from the helpdesk tab in a view in the actionpad.

There are three headers with different data.

**Active** (tickets where closed date is null)
Shows totals and coworker specific data

* Open
* Not initiated
* Delyed

**Incomming** (Created tickets on Created date)

* Today
* Week
* Month

**Closed** (Closed tickets on closed date)

* Today
* Week
* Month

###How is calculation done
Is done in a SQL procedure, csp_getHelpdeskStatistics.

**Active**

* Open: all tickets where enddate IS NULL
* Not initiated: All tickets where startdate and enddate IS NULL
* Delyed: All tickets where deadlinedate < GETDATE() AND [enddate] IS NULL 

**Incomming and Closed**

* today: All tickets where created time/enddate is the same as the today date
* Week: all tickets where the created time/enddat week is the same as the week of todays date
* Month: all tickets where the created time/enddat month is the same as the month of todays date

###To use:
Insert the SQL proceduer named **csp_getHelpdeskStatistics** in the database where you want to use the helpdesk statistics. Please observe that the field for Delayed helpdesk tickets is **[nextactiondate]** as used in LIME Core v. 5.1-database. If you use **[deadlinedate]**, please uncomment and comment the correct section in the SQL-code.

Copy the helpdeskstatistics app folder to the apps folder under the actionpad folder.

Insert the following html tag in the actionpad where you want it to be shown, most likeley the index actionpad.

	<div data-app="{app:'helpdeskstatics'}"></div>


***Localize texts***
Run the SQL-code named createLocalizeRecordHelpdeskStatistics.sql. This will create all records needed for the localizations.

####Only show when helpdesk tab is active
Most common is to only show the helpdesk statistics when the helpdesk tab is active. In order to do this you need to add the VBA code saved in the app folder.


####Configuration
There are only one configuration parameter available and that is the update interval. This is set in seconds and are as standard every 15 minutes (900 seconds). If you want to change this use the following config parameter

* updateTimer

**Example**

Set update interval to every 30 minuters. 60*30 = 1800 seconds

    <div data-app="{app:'helpdeskstatics', config:{updateTimer:1800}}"></div>