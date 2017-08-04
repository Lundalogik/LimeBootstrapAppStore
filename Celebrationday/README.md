#  Celebrationday #

CREATED BY: Sofie Sundåker

##Why use Celebrationday?
Every customer and coworker should be celebrated on their special day! 
With this app it's easier than ever to keep track of birthdays and employmentdays.

Just choose the end date for the period you want to check and you'll get a list with all birthdays and employment days within that period. You can also create selections from the lists. 

Because noone want's to be forgotten on their celebration day!

##Installation
* Add datefields in LISA
* Add app folder
* Add VBA-file
* Add SQL-procedure
* Configure if needed
* Be happy! :) 

##Configuration
To setup the application you need to add one date field on the customer table and two on the coworker table (except if they already exist, in which case you should check the names of the fields, should be "dob" and "employmentdate").

```html
<div data-app="{app:'Celebrationday',config:{}}"></div>
```
