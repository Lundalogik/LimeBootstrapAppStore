# Targethelper #
This app will help you keep track of how you and the company are doing to reach your monthly goals for the different activity types.

###How it works
Use the app to set targets. Admins can set target for all coworkers and regular users can add targets for themself

###Misc
It shows all strings in local language.

###How to set it up
Users need to have acceess to the target table.

Copy the targethelper folder and place it in the apps folder under the actionpad folder.

***targethelper.html***

Open the targethelper.html file (in the rootfolder of the app) and configure it as you want, it nows contain an example
```html
<div data-app="{app:'targethelper',config:{appmode: lbs.common.executeVba('TargetHelper.TargethelperMemberOfGroup',';Administrators;Superusers;') && 'admin' || 'user'}}"></div>
```
    
See targethelper.html for example.

In the install folder you can find 2 files.

1. app_instansiation.html

2. TargetHelper.bas



***1. app_instansiation.html ***

Take the code from the file and paste it in the index.html.

***2.TargetHelper.bas***

Insert the budgetgauge.bas file in the VBA. Run the sub Install() to create the necessary localization posts for the app.

