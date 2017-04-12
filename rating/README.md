#  Rating #

Example use of this app:
1. You have a thirdparty portal that sends out surveys and collect ratings 
2. You use lime survey to do this

Rating will sum up different ratings and average rating from a specific customer. Maybe next time you contact this customer you can in before hand see if they're satisfied with earlier contact or not.

## Installation ##
1. Create a new table with database name "rating"
2. Create a field of type "Grade" and enter database name "score"
3. Relate one to many from company to rating
4. Put HTML on the company actionpad
5. Run the SQL code to create procedure
6. Run exec lsp_setdatabasetimestamp and restart LDC
7. Restart Lime CRM

## Preview ##
It looks better vertically than horizontally

![previewpicture](http://i.imgur.com/nIgl5vC.png)

CREATED BY: ATH
