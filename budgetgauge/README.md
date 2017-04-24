
#  Budgetgaguge #
This app will help you keep track of how you and the company are doing to reach your monthly and yearly goal for a specific target, for exampel the value of won deals.

###How it works
You can see current value, total month goal and month to date goal.

The gauge are represented in tree colors, red, yellow and green. You set the percentage representing the colors by specifying the limit for the yellow color.

Example: yellow on 85% will end up in 

* 0% - 84% - Red
* 85% - 99% - Yellow
* 100% + - Green

**The tagets**

In the Target table each coworker gets a goal per month. Only coworkers with goals will be calculated.

###Misc
It shows all strings in local language.

###How to set it up
Users need to have acceess to the target table.

Copy the budgetgauge folder and place it in the apps folder under the actionpad folder.


In the install folder you can find 2 files.

1. app_instansiation.html

2. budgetgauge.bas



***1. app_instansiation.html ***

Take the code from the file and paste it in the index.html.

***2.budgetgauge.bas***

Insert the budgetgauge.bas file in the VBA. Run the sub Install() to create the necessary localization posts for the app.



