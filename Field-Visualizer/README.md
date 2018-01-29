Field Visualizer
=========

Field Visualizer turns data into prettiness.


Info
----

This app turns data from a super field into something that's easier and quicker to interpret; an icon, a helptext and a colour. The app could, for example, be used to

* Indicate if this is a customer or a supplier.
* Indicate that a requirement is not met (e.g. invoice not paid).
* Indicate that the customer has been neglected.

It makes the experience more visual and thereby faster and more intuitive.


Install
-----------

1. Copy “Visualizer” folder to the “apps” folder. 
1. Create your integer, yes/no or option field if it doesn't already exists. E.g. if you want different icons for customers and suppliers, you probably already have an option field with these two options.
1. Add the following HTML to the ActionPad and add configuration:

```html

<div data-app="{app:'Visualizer', 
	config:{
		Value: lbs.activeInspector.Controls('buyingstatus'),
		Map: [
			{	
				id:'108601',
				value:'fa-star',
				text: 'Aktiv kund',
				colorVar: '#7bbb1c'
			},
			{	
				id:'108401',
				value:'fa-thumbs-down',
				text: 'Ej intressant',
				colorVar: '#c0c0c0'
			},
			{	
				id:'108701',
				value:'fa-times',
				text: 'F.d. kund',
				colorVar: '#ca220f'
			},
			{	
				id:'192501',
				value:'fa-truck',
				text: 'Leverantör',
				colorVar: '#7680b4'
			},
			{	
				id:'108501',
				value:'fa-question',
				text: 'Prospekt',
				colorVar: '#dc730a'
			}
		]
		
	}}">
</div>
```
1. OPTIONAL! Write SQL-logic for your field. For inspiration: if you want an icons showing if someone has performed a customer visit the last six months or not, the following SQL returns 000000 if the customer has had a customer visit within the last 180 days, otherwise 111111:

```sql(
CASE 
WHEN EXISTS
(SELECT h.[idhistory]
FROM history h
WHERE h.[date] >= GETDATE()-180
AND h.[type] = 168301
AND h.[status] = 0
AND h.[company] = [company].[idcompany])
THEN 000000
ELSE 111111
END
)```


Setup
---
App is configured in the html file using the following parameters:
### Value: ###
The superfield of your choice, e.g.:
lbs.activeInspector.Controls('buyingstatus')

### Map: ###

- id:  the value that is returned from your super field, often an integer
- value:  font awesome name of the icon
- text: the helptext
- colorVar: hexdecimal for the background colour

