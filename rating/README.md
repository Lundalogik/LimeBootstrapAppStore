#  Rating #

Example use of this app:
1. You have a thirdparty portal that sends out surveys and collect ratings 
2. You use lime survey to do this

Rating will sum up different ratings and average rating from a specific customer. Maybe next time you contact this customer you can in before hand see if they're satisfied with earlier contact or not.

## Installation ##
0. Put the rating folder in Actionpad/apps
1. Create a new table with database name "rating"
2. Create a field of type "Grade" and enter database name "score"
3. Relate one to many from company to rating
4. Put HTML on the company actionpad
5. Run the SQL code to create procedure
6. Run exec lsp_setdatabasetimestamp and restart LDC
7. Restart Lime CRM

Note to self:
1. As of now there's no handling for locale. Just edit directly in app.html. In the future it'll be better with an installation package for fields, table and lingo.
2. Clean up app.html, put css in app.css
3. Consider dropping a div to show the star on progress bar and use data-bind instead. But icon will show before score. 

## Preview ##
It looks better vertically than horizontally

![previewpicture](http://i.imgur.com/nIgl5vC.png)

CREATED BY: ATH
