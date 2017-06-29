# SMS #

CREATED BY: Tommy, Lundalogik

## Lime Bootstrap SMS – Module ##
### About. ###

This application allows you to select one or many objects with phone numbers in Lime and send them a text message.

You can choose to write a custom text och just pick a preset template that you've created before.
You also have the ability to use template codes wich mean that you can for example have a message like:
"Hello #firstname#,
I look forward to see you tomorrow at #place_of_event#"

## Installation ##
1. Do one of the following:
	1. If installed with LIP - Jump to Step 2
	2. Install the app manually
		1. Create the tables and fields that is located in app.json package.
		2. Add the VBA modules from the folder Install\VBA.
2. Copy the png files from tableicons folder in the "Install\tableicons"
3. Make sure to add an empty option of the field: [smstemplate].[fortable] (This is not supported by Lip yet)
4. Add the content of the "Install\Actionpads\Add to Config.txt" to the "_Config.js" file in the root of the "Actionpads" folder
5. Create all localize records by running the Sub "SMS.Install"
6. Move the file "Install\Actionpads\smstemplate.html" to the root of the "Actionpads" folder
7. Add lbs.html as the Default AP for the table smstemplate
8. Make sure to config the app in the "sms.html" file in the root of the "SMS" folder.
9. Add code for opening the app in the AP where you want it, by calling the VBA Module "SMS.OpenSMSModule"
10. Add the wanted template codes in the VBA Function: "Sms.GetTemplateCodes"

## Example of settings ##
```html
<div data-app="{app:'SMS',config:{
	/* 'classname' is the class it fetches receivers from */
	/* 'getReceiversFrom' is what object it fetches from [explorer or inspector] */
	/* 'configKey' must match with a key in the tableConfigs table in this config */
	configKey: lbs.common.getURLParameter('classname') + ';' + lbs.common.getURLParameter('getReceiversFrom'),

	allowSmsOnTime: false,
	smsSupplier: 'link_mobility',
	generalDefaultValues: {
		messageType: 'template'
	},
	tableConfigs: {
		'person;explorer': {
			receiverNameFieldName: 'name',
			receiverMobilephoneFieldName: 'mobilephone',
			receiverTableName: 'person',
			receiverFromFields: '',
			specificDefaultValues: {
				messageType: ''
			},
			extraRelations: {
				fieldRelations: [
					{
						fieldNameSms: 'company',
						fieldNameReceiver: 'company'
					}
				]
			}
		},
		'company;explorer': {
			receiverNameFieldName: 'name',
			receiverMobilephoneFieldName: 'phone',
			selectionType: 'selected', // Only used for explorers
			receiverTableName: 'company',
			receiverFromFields: '',
			specificDefaultValues: {
				messageType: ''
			},
			extraRelations: {
				fieldRelations: [
				]
			}
		}
	}
}}"></div>
```