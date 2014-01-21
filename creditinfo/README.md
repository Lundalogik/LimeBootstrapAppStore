#Creditinfo

##Info
This app takes performs a credit check on the supplied organisation. Credit rating is shown in the actionpad as a colorful badge. A bad rating is displayed as red, a medium rating as yellow and a good rating as green. The rating fades with time and disappears after a certain age (default 365 days)

##Install

Copy “creditinfo” folder to the “apps” folder. The inspector where the app is supplied must have the following fields:
*	registrationno - text field - Contains the registration number
* 	creditinfo - XML field - Stores the data
 
Add the following HTML to the ActionPad (BusinessCheck-example):

```html
<div data-app="{app:'creditinfo', config:{
	businessCheck:{
customerLoginName : 'string',
		    	userLoginName: 'string',
            		password : 'string',
            		packageName : 'string'
	}
}}">
</div>
```

##Setup
The app takes a config with the following parameters
*	[vendor-config] - object with vendor properties such as user, password
*	maxAge - Optional, Integer specifying the maximum age of the rating in days. Default: 365
*	onlyAllowPublicCompanies - Optional, If false you can perform creditchecks on all companies or persons. However they will receive a letter and there will be an additional cost. Default: False

The app should be place just below the ActionPad `class=”header-container”` <div>

##Vendors
The app is built to work with any vendor that has a webservice to perform the check.
*	BusinessCheck - Implemented
*	Soliditet -	Waiting for implementation
*	[Add your favourite here…]

###BusinessCheck-setup
BusinessCheck requires you to create a package for the customer and allow webservice access. The package should ONLY contain “ratingvalue” and “ratingtext”. Call Bisnode Kredit and they will help you. 

Many customers have unique users and passwords for every LIME-user. In that case you’ll need to implement a function which fetches this information from the users coworker card. An example:

```html
<div data-app="{app:'creditinfo', config:{
	businessCheck:{
customerLoginName : 'CustomerX',
		    	userLoginName: lbs.common.executeVBA('Your VBA-function here'),
            		password : lbs.common.executeVBA('Your VBA-function here'),
            		packageName : 'CustomerXRatingPackage'
	}
}}">
</div>
```