# Connection Tag
This app enables for users to tag a history note or a todo with the names of a related company's contact persons. By selecting a person from the provided dropdown menu, the contact's name will be added to a text field on the active record.

## Install
The app can only be added to actionpads where the active record has a relation to a company.

*	Add the "ConnectionTag" folder to the apps folder.
*	Create the VBA module called "ConnectionTag" by dragging it into the VBA interpreter from the folder Installation.
*	Insert following html tag in the actionpad where you want it to be shown. 
	```html
		<div data-app="{app: 'ConnectionTag',config:{table: 'history', field: 'note'}}"></div>
	```
*	Change the config tag to match your active record and the text field you want to tag.
*	Add localization record for the label with owner set to 'ConnectionTag' and code to 'label'.


##### Created by: Jonatan Kåhrström