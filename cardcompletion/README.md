#Card Completion

The card completion app is the number one app for your company in order to encourage your coworkers to add data into LIME Pro. It is of course very important, but not always that fun to fill LIME Pro with important information regarding your relations and we know – it’s easy to forget! Setting important fields to mandatory is not always the solution – because you do not always have the information needed at your fingertips! 

The card completion app will help you by showing the total card completion of a card and if you click it you will see which fields are missing data. Click the field and the focus is set to the correct field and you can just start typing. Eazy peazy!

##Install

Copy the “cardcompletion” folder to the “apps” folder. Complete the configuration with the fields to be included in the app as well as their weighting points. See below for example on the company card:
Add the following HTML to the ActionPad (company.html example below):

```html
<div data-app="{ app: 'cardcomplete' }"></div>
```

##Setup

The app is configured by setting the cardcompletion variable in app.js.
example:
```javascript
tables: [{
                name: "company",
                fields: [{
                    name: "phone",
                    name_sv: "Telefon",
                    weight: 20
                },
                {
                    name: "www",
                    name_sv: "Hemsida",
                    weight: 10
                },
            	{
                name: "person",
                fields: [{
                    name: "phone",
                    name_sv: "Telefon",
                    weight: 25
                },
                {
                    name: "mobilephone",
                    name_sv: "Mobilnummer",
                    weight: 25
                },
                {
                    name: "email",
                    name_sv: "Epost",
                    weight: 40
                },
                {
                    name: "position",
                    name_sv: "titel",
                    weight: 10
                }]
            }]
´´´

For each table where you wish to implement this app you must add a table object. Every table object has an array of fields with their name, localname and weight. Each field is then calculated into the card completion rate.