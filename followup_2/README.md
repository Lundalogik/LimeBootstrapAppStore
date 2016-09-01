#Aware

## Requires a license
For more information please contact Lundalogik AB.

#  Follow Up #
This app will help you keep track of how you and the company are doing to reach your monthly goals for the different activity types.
It has two stages, All and Mine:

* All: Shows statistics of how the company is doing with its monthly goals on each activity type.
* Mine: Shows statistics of how you are doing with your monthly goals on each activity type.

###How it works
The numbers in the tile is representing:

***[Done activities] / [goal until today] ( [total goal for month] )***

The tile are represented in tree colors, red, yellow and green. You set the percentage representing the colors by specifying the limit for the yellow color.

Example: yellow on 75% will end up in 

* 0% - 74% - Red
* 75% - 99% - Yellow
* 100% + - Green

**The tagets**

In the Target table each coworker gets a goal per activity and month. Only coworkers with goals will be calculated.

###Misc
It shows all strings in local language.

###How to set it up
Copy the followup folder and place it in the apps folder under the actionpad folder.
In the install folder you can find 4 files.

1. followup.html
2. Code_ for_ThisApplication
3. Followup.bas

***1. followup.html***

Copy the followup.html file and place it under the actionpad folder.
In the followup.html file you add a div tag for each activity type you want to see, like this.
```html
<div data-app="{
    app:'followup', 
    config: {
        /* Limit the number of hits */
        choiceLimits: {
            totalMax: 999,
            targetMax: 999,
            coworkerMax: 999
        },
    	coloring: {
    		green: 1.0,
    		yellow: 0.6 
    	},
        /* Add logic for which users that will be able to admin the app, example only users in the group administrator */
        securityLevel: lbs.limeDataConnection.ActiveUser.Administrator && 'admin' || 'user',
        structureMapping: {
            targetType: 'count', // 'count', 'sum'

            /* Field mappings for target table */
            targetTable: 'target',
            targetTypeField: 'targettype',
            targetValueField: 'targetvalue',
            targetDateField: 'targetdate',

            /* Field mappings for score table */
            scoreTable: 'history',
            scoreTypeField: 'type',
            scoreValueField: '',
            scoreDateField: 'date',
        },
        /* Map the keys from the optionsfield in the different tables */
    	targetMapping: [
    		{
                targetTypeKey: 'customervisit',
    			scoreTypeKey: 'customervisit'
    		},
            {
                targetTypeKey: 'salescall',
                scoreTypeKey: 'salescall' 
            },
            {
                targetTypeKey: 'agreement',
                scoreTypeKey: 'talkedto' 
            }
    	]
	}
}"/>
```
    
See followup.html for example.

***2. Code_ for_ThisApplication***

Take the code from the file and paste it in the Setup sub in ThisApplication.

***3. Followup.bas***

Insert the Followup.bas file in the VBA. Run the sub Install() to create the necessary localization posts for the app.
