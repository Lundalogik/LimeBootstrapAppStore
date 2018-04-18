# Lime CRM Sales Board


## About
Lime CRM Sales Board offers a new and different way to look at Lime CRM data. Lime CRM Sales Board lives in the Panes next to the Limelight, browser, Outlook calendar and Outlook inbox and lets you view the records in your current tab as cards on a Kanban style board (think Trello, LeanKit Kanban etc.). This gives you a good overview and offers a different way to view your data besides the classic Lime CRM list.


## Features

### Use in multiple tabs
Lime CRM Sales Board can be set up to show data from multiple Lime CRM tabs, each with unique settings of how to show the records and what information to show for each record. Examples of usage are:

* **Deals**: View the current pipe or all deals, won or lost. Either for the whole company or for a specific salesperson at the time.
* **Projects or project activities**: What are my current project activities and what phase are they in? Development, testing, ready to launch etc.?
* **Helpdesk cases**: Get an overview of new, ongoing, parked and finished cases. Perhaps for the current week or a certain team?
* **Development tasks**: Similar to project activities, Lime CRM Sales Board will give a nice overview of the current work being investigated, developed, tested etc.
* **Solution improvements**: This tab is part of the Lime CRM Core database and is a good way to keep track of changes, fixes or wishes that need to be fixed in your Lime CRM solution. Use Lime CRM Sales Board to easily see what is being done right now and what comes next.

### Fast filtering
Lime CRM Sales Board shows the records that your currently open tab contains at the moment. This means that fast filtering your list will make Lime CRM Sales Board remove cards that were filtered out when refreshing it. A warning triangle icon will appear left of the board title when a filter is applied on the list.

### Click to open
Click any card in Lime CRM Sales Board and the corresponding record will be opened.

## Technical overview
To be able to use Lime CRM Sales Board on a tab you must have an option field on the card. Each option in that field will be converted into a lane in Lime CRM Sales Board. All the records currently visible in the active tab will be converted into a card in the corresponding lane.

### Inactive options
An inactive option in the selected option field will not be rendered as a lane in Lime CRM Sales Board. Hence, a record with an inactive option selected will not be fetched from the database.


## Install
You need to do the following to add Lime CRM Sales Board to your database.

1. Download the latest [release from GitHub](https://github.com/Lundalogik/addon-limecrmsalesboard/releases).
2. *Only needed if you want to use SQL as datasource instead of VBA:* Add the SQL table valued function `cfn_gettablefromstring`.
3. *Only needed if you want to use SQL as datasource instead of VBA:* Add the SQL scalar valued function `cfn_limecrmsalesboard_getsqlexpression`.
4. *Only needed if you want to use SQL as datasource instead of VBA:* Add the SQL procedure `csp_limecrmsalesboard_getboard`.
5. Add the localization records needed by running the script in the file `createLocalizeRecords.sql` under the Install folder. *Beware*: If you do not have all the language columns that exist in the Lime CRM Core Database you have to remove the ones you do not have from the SQL script before running it. Otherwise it will fail.
6. *Only needed if you want to use SQL as datasource instead of VBA:* Restart the LDC (right-click on it and click "Shut down").
7. Restart the Lime CRM desktop client and add the VBA module `App_LimeCRMSalesBoard`.
8. Add the folder LimeCRMSalesBoard under apps in your Actionpads folder.
9. Configure the LimeCRMSalesBoard.html file to make Lime CRM Sales Board work the way you want to. Out of the box, Lime CRM Sales Board is configured to work for the Deals tab in the Lime CRM Core Database.
10. Add a link in your main Actionpad, for example like this:
```html
<li data-bind="vba:'App_LimeCRMSalesBoard.openLimeCRMSalesBoard', text:localize.App_LimeCRMSalesBoard.openLimeCRMSalesBoard, icon:'fa-align-left fa-rotate-90'"></li>
```
11. Compile and save VBA.
12. Publish Actionpads.
13. Add a customization record under the customer in our own Lime CRM. Link it to the product card for Lime CRM Sales Board. Note the version installed.

### Update
**Important**: If you update your version of Lime CRM Sales Board, remember to first make a copy of the file `LimeCRMSalesBoard.html` so you do not lose your app configuration.


## Setup
The file `views\LimeCRMSalesBoard.html` contains the app config object. An example is shown below together with an explanation for the different settings available.

```html
<div data-app="{app:'LimeCRMSalesBoard', config: {
		dataSource: 'vba',
		maxNbrOfRecords: 300,
		boards: [ {
			table: 'deal',
			lanes: {
				optionField: 'dealstatus',
				defaultValues: {
					laneColor: 'clean-green',
					cardIcon: 'completion',
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
				field: 'value',
				unit: 'SEK'
			},
			card: {
				titleField: 'name',
				value: {
					field: 'value',
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

**dataSource**: Can be either 'vba' or 'sql'. Important: Should always be 'vba' in the cloud environment.

**maxNbrOfRecords**: The maximum number of records fetched from the database, no matter how many records that are currently shown in the list. A recommended number is 300. Showing more records than that is not really what the Sales Board is for. Better to use the Salespipe add-on if you are looking for summations of a pipe containing that many records.

**boards**: An array containing board objects. Each board object represent a Lime CRM tab and each tab can only be represented once.

**boards.table**: The database name of the table the board concerns.

**boards.lanes**: An object with settings for the lanes on the board.

**boards.lanes.optionField**: The options of this field will render one lane each.

**boards.lanes.ignoreOptions**: This object is only needed if you want to prevent certain columns from being drawn on the board. If not present, all active options will be included on the board. Note that inactive options always are ignored.

**boards.lanes.ignoreOptions.keys**: A semicolon separated list of the keys of the options to ignore. Best practice is to both start and end the string with a semicolon.

**boards.lanes.ignoreOptions.ids**: Only used if there is no keys property defined on the ignoreOptions object. A semicolon separated list of the idstrings of the options to ignore. Best practice is to both start and end the string with a semicolon.

**boards.lanes.defaultValues**: An object with default values that will be used by Lime CRM Sales Board if a value is not specified for a specific option in the individualLaneSettings array.

**boards.lanes.defaultValues.laneColor**: The default color for a lane if another one is not specified in the individualLaneSettings array. Must be one of the following: 'blue', 'turquoise', 'green', 'clean-green', 'orange' or 'deep-red'.

**boards.lanes.defaultValues.cardIcon**: The default icon for a lane if another one is not specified in the individualLaneSettings array. Must be one of the following: 'completion', 'happy', 'sad' or 'wait'. Always overrides the cardIconField setting.

**boards.lanes.defaultValues.cardIconField**: The name of the field from where the name of the icon to use for the cards should be fetched. The field must contain one of the following strings: 'completion', 'happy', 'sad' or 'wait'. Will only be used if a cardIcon is not specified neither on the defaultValues object nor on the individualLaneSettings for a lane.

**boards.lanes.defaultValues.positiveSummation**: The default setting for if the summation values for a lane should add to the principal sum in the board title or the sum within parenthesis. Used if another one is not specified in the individualLaneSettings array.

**boards.lanes.individualLaneSettings**: An array of objects where each object represents an option in the option field.

**boards.lanes.individualLaneSettings.key**: The key of the option. Used to identify which option the settings should be used for. If not specified, an id must be specified.

**boards.lanes.individualLaneSettings.id**: Only used if a key was not specified. Should then contain the idstring of the option the settings should be applied on.

**boards.lanes.individualLaneSettings.color**: The color of the lane, meaning the color of the bar above the first card and the color of the icon (not valid for icon 'completion'). Must be one of the following: 'blue', 'turquoise', 'green', 'clean-green', 'orange' or 'deep-red'.

**boards.lanes.individualLaneSettings.cardIcon**: Determines which icon that is going to be shown on the cards in the lane. Must be one of the following: 'completion', 'happy', 'sad' or 'wait'. Always overrides the cardIcon and cardIconField attributes on the defaultValues object.

**boards.lanes.individualLaneSettings.positiveSummation**: Should be set to true if the summation values for the lane should add to the principal sum in the board title and false if instead the sum within parenthesis.

**boards.summation**: An object with settings for how the summation in the title of the board should be done.

**boards.summation.field**: The database name of the field that should be summarized. Note: This does not have to be the same as the value field on the card. SQL expression on the field is supported by Lime CRM Sales Board.

**boards.summation.unit**: The unit that will be shown after the summarized values.

**boards.card**: An object with settings that are common for all the cards on the board.

**boards.card.titleField**: The database name of the field that will be shown in the first row on the cards.

**boards.card.value**: An object with settings for the value of the cards.

**boards.card.value.field**: The database name of the field that will be shown as the value on the card. SQL expression on the field is supported by Lime CRM Sales Board.

**boards.card.value.unit**: The unit that will be shown after the card values.

**boards.card.percentField**: The database name of the field that will be used to show the completion icon on the cards. Must be a percent field. Can be left empty or removed from configuration. SQL expression on the field is supported by Lime CRM Sales Board.

**boards.card.sorting**: Settings for how the cards should be sorted within the lanes. Can be removed from the configuration.

**boards.card.sorting.field**: The database name of the field that should control the sorting.

**boards.card.sorting.descending**: A boolean that tells Lime CRM Sales Board whether to sort descending or ascending.

**boards.card.owner**: The owner of the card will be shown at the bottom of each card. Is always assumed to be a relation to another table.

**boards.card.owner.fieldName**: The database name of the relation field on the card the board is configured for.

**boards.card.owner.relatedTableName**: The database name of the table the relation field points to. *Important*: Record access on the target table is neglected.

**boards.card.owner.relatedTableFieldName**: The database name of the field on the related table that should be shown on the card in Lime CRM Sales Board.

**boards.card.additionalInfo**: This information will be shown after the value of the card. Can be either a relation to another table or a field directly on the card which the board is configured for.

**boards.card.additionalInfo.fieldName**: The database name of the field (relation or other) on the card the board is configured for.

**boards.card.additionalInfo.relatedTableName**: If the field is a relation field, then this parameter should be set to the database name of the table the relation field points to. If not a relation field, then just leave this parameter empty or remove it. *Important*: Record access on the target table is neglected.

**boards.card.additionalInfo.relatedTableFieldName**: If the field is a relation field, then this parameter should be set to the database name of the field on the related table that should be shown on the card in Lime CRM Sales Board. If not a relation field, then just leave this parameter empty or remove it.

**boards.card.additionalInfo.dateFormat**: Important: Only works when dataSource = 'sql'. Include this object in the configuration if the chosen field is a Time field and you want to specify the format of the date and/or time shown. Not mandatory. Example:
```javascript
dateFormat: {
	sqlFormatCode: 120,
	length: 10
}
```

**boards.card.additionalInfo.dateFormat.sqlFormatCode**: The [T-SQL format code](http://www.w3schools.com/sql/func_convert.asp) that should be used. Not mandatory.

**boards.card.additionalInfo.dateFormat.length**: The number of characters SQL Server should cut the formatted timestamp to after having converted it into text. Not mandatory.