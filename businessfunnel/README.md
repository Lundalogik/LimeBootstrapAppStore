#  Businessfunnel #

The businessfunnel shows you a bar shart in the actionpad and populates it with values from the project/business table.

It has two stages, All and Mine:

* All: A Salesfunnel with values from all deals

* Mine: A Sales funnel with values where Active User is set as coworker on th business card.

It shows all strings in local language.

###To use:
Insert the SQL proceduer named **getBusinessValue.sql** in the database where you want to use the business funnel. 

Copy the business funnel app folder to the apps folder under the actionpad folder.

Insert the following html tag in the actionpad where you want it to be shown, most likeley the index actionpad.

	<div data-app="{app:'businessfunnel'}"></div>

##Configurating the business funnel
Following field need to be implemented in the database:

*	 businessvalue (integer or decimal field)
*	 businessvalue (option field with different values, set key values also)
*	 coworker (relation field to coworker table)

###The standard configuration for the business funnel is:

*	currency = "tkr" - Set the currency for the pipeline
*	divider = 1000 - Devides the values with 1000 (tusentals avgränsare)
*	decimals = 0 - Number of decimals shown 
*	name = "Pipeline" - Name of the container
*	removeStatus:[] - Statuses can be remoeved by key on the optionfield businessstatus
*	color:[]

This means that if you dont configure the business funnel it will show you a bar chartwhith the name **Pipeline** where all values are divided with **1000** and the currency will be **tkr** (thousands of swedish crowns). **Zero decimals** will be added and **all statuses** in the option list businessstatus will be added. The default colors are used:

#### Default colors: ####

* #2693FF -blue
* #464646  -darkgrey
* #BF3B26 -red
* #D39D09 -yellow
* #E56C19 orange
* #83BA1Fgreen   

To set your own configuration you use the parameters when initializing the app.

####Example 1:
The customer want the currency in "kr" and they only have small deals so they do not talk thousends of crowns.

*	currency = "kr"
*	divider = 1
*	remove statuses 'onhold' and 'rejection' (key on the optionfield)

	`<div data-app="{app:'businessfunnel', config:{  currency:'kr', divider:1, removeStatus:'onhold','rejection']}}"></div>`
	

####Example 2
The customer want the currency in NOK and thet always use million NOK as value

*	currency = "NOK"
*	divider = 1 000 000 
*	remove statuses 'onhold' and 'rejection' (key on the optionfield)

	`<div data-app="{app:'businessfunnel', config:{ name:'Salgpipe', currency:'NOK', divider:1000000, removeStatus:['onhold','rejection']}}"></div>`

####Example 3
The customer want the currency in EURO and no devider, status onhold and rejection should not be shown and the colors to be used is picked by the customer.

*	currency = "€"
*	divider = 1
*	remove statuses 'onhold' and 'rejection' (key on the optionfield)
*	colors:['#FFFFFF', '#GGGGGG']

	`<div data-app="{app:'businessfunnel', config:{ currency:'€', divider:1, removeStatus:['onhold','rejection'], colors:['#FFFFFF', '#GGGGGG']}}"></div>`