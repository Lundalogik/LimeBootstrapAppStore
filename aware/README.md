#Aware

## Requires a license
For more information please contact Lundalogik AB. 

##About
Aware allows you to get a visual overview on your company. You can visualizing if a
company hasn't got a history note in a long time. If the company has an active
SOS-errand and if some information are missing on a company field. 

##Install
To install it you just paste the config file into your actionpad and change the
parameters.

icon1 = bad
icon2 = okey
icon3 = good

text1 = bad
text2 = okey
text3 = good

If a text parameter is left empty it will not show. 

###History
```html
 <div data-app="{app:'info',config:{
	icon1: 'fa-eye',
	icon2: 'fa-eye',
	icon3: 'fa-star',
	text1: 'Behöver kärlek',
	text2: 'Bortglömd?',
	text3: '',
	updateTimer: 10000000,
	dataSource: {
                    type:'xml',
                    source:'checkHistory.call_checkHistory,7,14'
                    , alias: 'aware'
                }
}}">
</div>
```
###SOS
```html
<div data-app="{app:'info',config:{
	icon1: 'fa-medkit',
	text1: 'SOS',
	text2: '',
	text3: '',
	updateTimer: 10000,
	dataSource: {
                    type:'xml',
                    source:'checkHistory.call_checkHelpdesk'
                    , alias: 'aware'
                }
}}">
</div> 
```
###Fields
```html
<div data-app="{app:'info',config:{
	icon1: 'fa-pencil',
	icon2: 'fa-pencil-square-o',
	icon3: 'fa-star',
	text1: 'Flera fält saknas',
	text2: 'Fält saknas',
	text3: 'Inga fält saknas',
	updateTimer: 1000000,
	dataSource: {
                    type:'xml',
                    source:'checkHistory.checkFields, name;phone;www'
                    , alias: 'aware'
                }
}}">
</div>
```