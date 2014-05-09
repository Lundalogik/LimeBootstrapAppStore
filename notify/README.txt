#Notify

We know you have customers that are more important than others. With Notify nothing slips through your fingers. It gives you full control of the latest actions made on your most precious companies.
You get total control and who wouldn't want that?

This is what you get:
<ul>
	<li>Notifications from chosen companies</li>
	<li>Not missing out on important actions you are not involved in</li>
	<li>Help with getting your priorities straight</li>
</ul>

##Basic usage

Keep calm and let Notify notify.

##Installation

Requirements for Notify:
<ul>
	<li>A new table in LISA - subscription</li>
	<li>Relations from subscription to company and to coworker</li>
</ul>

##Configuration of notify

Following need to be implemented in the database:
•	New table subscription with relation to company and coworker and a y/n-field unsubscribe 
•	Add code to Globals
•	Add procedure [dbo].[csp_get_subscriptions] 
The standard configuration for notify is:
•	time= 7 days back. You can update this in csp_get_subscriptions. 

Add the following code to company.html
<ul class="menu expandable collapsed"><li class="menu-header", data-bind=" text:'Länkar'"></li>  	
<button class="btn btn-default btn-lime"  data-bind="vba:'Globals.CreateSubscription', text:'Notify', icon:'fa-check'"></button>	</ul>

Add the following code to index.html: 

<div data-app="{app:'subscriptions',config:{}}"></div>



