#Card Completion

The card completion app is the number one app for your company in order to encourage your coworkers to add data into LIME Pro. It is of course very important, but not always that fun to fill LIME Pro with important information regarding your relations and we know – it’s easy to forget! Setting important fields to mandatory is not always the solution – because you do not always have the information needed at your fingertips! 

The card completion app will help you by showing the total card completion of a card and if you click it you will see which fields are missing data. Click the field and the focus is set to the correct field and you can just start typing. Eazy peazy!

##Install

Copy the “cardcompletion” folder to the “apps” folder. Complete the configuration with the fields to be included in the app as well as their weighting points. See below for example on the company card:
Add the following HTML to the ActionPad (company.html example below):

```html
<div class="header-container blue">
    <div data-app="{ app: 'cardcomplete', config: { appType: 'head' } }"></div>
</div>
```

##Setup

The app is configured with the following parameters
[vendor-config] - object with vendor properties such as user, password
maxAge - Optional, Integer specifying the maximum age of the rating in days. Default: 365
inline - Optional, Boolean specifing if the should be expanded from start. Set to true if you're using the app in a field an not in the actionpad
onlyAllowPublicCompanies - Optional, If false you can perform creditchecks on all companies or persons. However they will receive a letter and there will be an additional cost. Default: False
The app should be place just below the ActionPad class=”header-container”.
