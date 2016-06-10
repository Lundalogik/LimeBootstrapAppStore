# Embrello #

CREATED BY: Fredrik Eriksson, Lundalogik AB

DESIGNED BY: Joakim Lindblom, Lundalogik AB

## About ##
Embrello offers a new and different way to look at LIME Pro data. Embrello lives in the Panes next to the Limelight, browser, Outlook calendar and Outlook inbox and lets you view the records in your current tab as cards on a Kanban style board (think Trello, LeanKit Kanban etc.). This gives you a good overview and offers a different way to view your data besides the classic LIME Pro list.


## Features ##

### Use in multiple tabs ###
Embrello can be set up to show data from multiple LIME Pro tabs, each with unique settings of how to show the records and what information to show for each record. Examples of usage are:

* **Deals**: View the current pipe or all deals, won or lost. Either for the whole company or for a specific salesperson at the time.
* **Projects or project activities**: What are my current project activities and what phase are they in? Development, testing, ready to launch etc.?
* **Development tasks**: Similar to project activities, Embrello will give a nice overview of the current work being investigated, developed, tested etc.
* **Solution improvements**: This tab is part of the LIME Pro Core database and is a good way to keep track of changes, fixes or wishes that need to be fixed in your LIME Pro solution. Use Embrello to easily see what is being done right now and what comes next.

### Fast filtering ###
Embrello shows the records that your currently open tab contains at the moment. This means that fast filtering your list will make Embrello remove cards that were filtered out when refreshing it. A warning triangle icon will appear left of the board title when a filter is applied on the list.

### Click to open ###
Click any card in Embrello and the corresponding record will be opened.

## Technical overview ##
To be able to use Embrello on a tab you must have an option field on the card. Each option in that field will be converted into a lane in Embrello. All the records currently visible in the active tab will be converted into a card in the corresponding lane.

### Inactive options ###
An inactive option in the selected option field will not be rendered as a lane in Embrello. Hence, a record with an inactive option selected will not be fetched from the database.


## Install ##
You need to do the following to add Embrello to your database.

* Add the SQL table valued function `cfn_gettablefromstring` using the script in the file `cfn_gettablefromstring.sql` under the Install subfolder.
* Add the SQL procedure `csp_embrello_getboard` using the script in the file `csp_embrello_getboard.sql` under the Install subfolder.
* Add the localization records needed by running the script in the file `createLocalizeRecords.sql` under the Install folder. *Beware*: If you do not have all the language columns that exist in the LIME Pro Core Database you have to remove the ones you do not have from the SQL script before running it. Otherwise it will fail.
* If you are running LIME Pro 10.12 or later, please restart the LDC manually (right-click on it and click "Shut down").
* Restart the LIME Pro client and add the VBA module `App_Embrello` located in the Install subfolder.
* Add the folder embrello under apps in your Actionpad folder.
* Configure the embrello.html file to make Embrello work the way you want to. Out of the box, Embrello is configured to work for the Deals tab in the LIME Pro Core Database.
* Add a link in your main Actionpad, for example like this:
```html
<li data-bind="vba:'App_Embrello.openEmbrello', text:localize.App_Embrello.openEmbrello, icon:'fa-align-left fa-rotate-90'"></li>
```
* Add a customization record in Lundalogik Lime under the customer. Note the version installed (can be found in the app.json file).

### Update ###
**Important**: If you update your version of Embrello, remember to first make a copy of the file `embrello.html` so you don't lose your app configuration.


## Setup ##
The file `embrello.html` contains the app config object. An example is shown below together with an explanation for the different settings available.

```html
<div data-app="{app:'Embrello', config: {
		maxNbrOfRecords: 1000,
		boards: [ {
			table: 'business',
			lanes: {
				optionField: 'businesstatus',
				defaultValues: {
					laneColor: 'clean-green',
					icon: 'completion',
					positiveSummation: true
				},
				individualLaneSettings: [
					{
						key: 'contact',
						color: 'blue'
					},
					{
						key: 'requirement',
						color: 'turquoise'
					},
					{
						key: 'tender',
						color: 'green'
					},
					{
						key: 'agreement',
						cardIcon: 'happy'
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

**maxNbrOfRecords**: The maximum number of records fetched from the database, no matter how many records that are currently shown in the list.

**boards**: An array containing board objects. Each board object represent a LIME Pro tab and each tab can only be represented once.

**boards.table**: The database name of the table the board concerns.

**boards.lanes**: An object with settings for the lanes on the board.

**boards.lanes.optionField**: The options of this field will render one lane each.

**boards.lanes.defaultValues**: An object with default values that will be used by Embrello if a value is not specified for a specific option in the individualLaneSettings array.

**boards.lanes.defaultValues.laneColor**: The default color for a lane if another one is not specified in the individualLaneSettings array. Must be one of the following: 'blue', 'turquoise', 'green', 'clean-green', 'orange' or 'deep-red'.

**boards.lanes.defaultValues.icon**: The default icon for a lane if another one is not specified in the individualLaneSettings array. Must be one of the following: 'completion', 'happy', 'sad' or 'wait'.

**boards.lanes.defaultValues.positiveSummation**: The default setting for if the summation values for a lane should add to the principal sum in the board title or the sum within parenthesis. Used if another one is not specified in the individualLaneSettings array.

**boards.lanes.individualLaneSettings**: An array of objects where each object represents an option in the option field.

**boards.lanes.individualLaneSettings.key**: The key of the option. Used to identify which option the settings should be used for. If not specified, an id must be specified.

**boards.lanes.individualLaneSettings.id**: Only used if a key was not specified. Should then contain the idstring of the option the settings should be applied on.

**boards.lanes.individualLaneSettings.color**: The color of the lane, meaning the color of the bar above the first card and the color of the icon (not valid for icon 'completion'). Must be one of the following: 'blue', 'turquoise', 'green', 'clean-green', 'orange' or 'deep-red'.

**boards.lanes.individualLaneSettings.cardIcon**: Determines which icon that is going to be shown on the cards in the lane. Must be one of the following: 'completion', 'happy', 'sad' or 'wait'.

**boards.lanes.individualLaneSettings.positiveSummation**: Should be set to true if the summation values for the lane should add to the principal sum in the board title and false if instead the sum within parenthesis.

**boards.summation**: An object with settings for how the summation in the title of the board should be done.

**boards.summation.field**: The database name of the field that should be summarized. Note: This does not have to be the same as the value field on the card. SQL expression on the field is supported by Embrello.

**boards.summation.unit**: The unit that will be shown after the summarized values.

**boards.card**: An object with settings that are common for all the cards on the board.

**boards.card.titleField**: The database name of the field that will be shown in the first row on the cards.

**boards.card.value**: An object with settings for the value of the cards.

**boards.card.value.field**: The database name of the field that will be shown as the value on the card. SQL expression on the field is supported by Embrello.

**boards.card.value.unit**: The unit that will be shown after the card values.

**boards.card.percentField**: The database name of the field that will be used to show the completion icon on the cards. Must be a percent field. Can be left empty or removed from configuration. SQL expression on the field is supported by Embrello.

**boards.card.sorting**: Settings for how the cards should be sorted within the lanes. Can be removed from the configuration.

**boards.card.sorting.field**: The database name of the field that should control the sorting.

**boards.card.sorting.descending**: A boolean that tells Embrello whether to sort descending or ascending.

**boards.card.owner**: The owner of the card will be shown at the bottom of each card. Is always assumed to be a relation to another table.

**boards.card.owner.fieldName**: The database name of the relation field on the card the board is configured for.

**boards.card.owner.relatedTableName**: The database name of the table the relation field points to. *Important*: Record access on the target table is neglected.

**boards.card.owner.relatedTableFieldName**: The database name of the field on the related table that should be shown on the card in Embrello.

**boards.card.additionalInfo**: This information will be shown after the value of the card. Can be either a relation to another table or a field directly on the card which the board is configured for.

**boards.card.additionalInfo.fieldName**: The database name of the field (relation or other) on the card the board is configured for.

**boards.card.additionalInfo.relatedTableName**: If the field is a relation field, then this parameter should be set to the database name of the table the relation field points to. If not a relation field, then just leave this parameter empty or remove it. *Important*: Record access on the target table is neglected.

**boards.card.additionalInfo.relatedTableFieldName**: If the field is a relation field, then this parameter should be set to the database name of the field on the related table that should be shown on the card in Embrello. If not a relation field, then just leave this parameter empty or remove it.

**boards.card.additionalInfo.dateFormat**: Include this object in the configuration if the chosen field is a Time field and you want to specify the format of the date and/or time shown. Not mandatory. Example:
```javascript
dateFormat: {
	sqlFormatCode: 120,
	length: 10
}
```

**boards.card.additionalInfo.dateFormat.sqlFormatCode**: The [T-SQL format code](http://www.w3schools.com/sql/func_convert.asp) that should be used. Not mandatory.

**boards.card.additionalInfo.dateFormat.length**: The number of characters SQL Server should cut the formatted timestamp to after having converted it into text. Not mandatory.