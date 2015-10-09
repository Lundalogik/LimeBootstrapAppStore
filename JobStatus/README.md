#  Job Status #

CREATED BY: Andreas Åström

# About
This app shows you the status of your SQL-jobs. 

###[Important to know is that the user who runs the LIME server needs to be Sysadmin on the SQL server]

##Installation
1. Add SQL-procedure
2. Add VBA-modul
3. Add app
4. Configure your application

##Configuration
To setup the application you need to select which job the app should be listened to and for which user-groups it should be visible for.

```html
<div data-app="{app:'JobStatus',config:{
	JobNames:'Job1: Job2: Job3',
	Groups: 'User : Administrators'}}"></div>
<div class="lime-logo-bottom"></div>
```

```html
<div data-app="{app:'JobStatus',config:{
	JobNames:'Job1',
	Groups: 'Administrators'}}"></div>
<div class="lime-logo-bottom"></div>
```
