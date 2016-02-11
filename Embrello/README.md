# Embrello #

CREATED BY: Fredrik Eriksson, Lundalogik AB

## About ##
Embrello offers a new and different way to look at LIME Pro data. Embrello lives in the Panes next to the calendar, inbox and browser and lets you view the records in your current tab as cards on a Kanban style board (think Trello, LeanKit Kanban etc.). This gives you a good overview and offers a different way to view your data besides the classic LIME Pro list.


## Features ##

### Use in multiple tabs ###
Embrello can be set up to show data from multiple LIME Pro tabs, each with unique settings of how to show the records and what information to show for each record. Examples of usage are:

* Deals: View the current pipe or all deals, won or lost. Either for the whole company or for a specific salesperson at the time.
* Projects or project activities: What are my current project activities and what phase are they in? Development, testing, ready to launch etc.?
* Solution improvements: This tab is part of the LIME Pro Core database and is a good way to keep track of changes, fixes or wishes that need to be fixed in your LIME Pro solution. Use Embrello to easily see what is being done right now and what comes next.

### Fast filtering ###
Embrello shows the records that your currently open tab contains at the moment. This means that fast filtering your list will make Embrello remove cards that were filtered out when refreshing it.


## Install ##
You need to do the following to add Embrello to your database.

* Add the SQL table valued function cfn_gettablefromstring.
* Add the SQL procedure csp_embrello_getboard.
* Add the VBA module App_Embrello.
* Add the folder embrello under apps in your Actionpad folder.
* Configure the embrello.html file to make Embrello work the way you want to. Embrello is configured to work for the Deals tab in the LIME Pro Core database out of the box.


## Setup ##
The file `embrello.html` contains the app config object. An example is shown below together with an explanation for the different settings available.

```html
<div data-app="{app:'Embrello', config: {
		boards : [ {
			table: 'business',
			lanes : {
				optionField: 'businesstatus',
				individualLaneSettings: [
					{
						key: 'contact',
						color: 'blue',
						cardIcon: 'completion',
						positiveSummation: true
					},
					{
						key: 'requirement',
						color: 'turquoise',
						cardIcon: 'completion',
						positiveSummation: true
					},
					{
						key: 'tender',
						color: 'green',
						cardIcon: 'completion',
						positiveSummation: true
					},
					{
						key: 'agreement',
						color: 'clean-green',
						cardIcon: 'happy',
						positiveSummation: true
					},
					{
						key: 'rejection',
						color: 'deep-red',
						cardIcon: 'sad',
						positiveSummation: false
					},
					{
						key: 'onhold',
						color: 'orange',
						cardIcon: 'wait',
						positiveSummation: false
					}
				]
			},
			summation: {
				field: 'businessvalue',
				unit: 'SEK'
			},
			card: {
				titleField: 'name',
				value: {
					field: 'businessvalue',
					unit: 'SEK'
				},
				percentField: 'probability',
				sorting: {
					field: 'timestamp',
					descending: true
				},
				owner: {
					fieldName: 'coworker',
					relatedTableName: 'coworker',
					relatedTableFieldName: 'name'
				},
				additionalInfo: {
					fieldName: 'company',
					relatedTableName: 'company',
					relatedTableFieldName: 'name'
				}
			}
		}]
	}
}"></div>
```

#### boards ####
An array containing board objects. Each board object represent a LIME Pro tab and each tab can only be represented once.

