markdown

#Course Queue
The No.1 queue management tool for course / campaign handling!

Do you have a problem with setting up a queue for fully booked campaign or course? Dont you worry, Lundalogik has came up with a solution of queuing up the possible participants on sign up order!

All potential participants will be shown and queued up on the actionpad if there will be cancellations etc. for signing up!







#Installation

Download the installation file through the link.

Your Course participant card requires two fields:
<li>queuetime (fieldtype: datetime)</li>
<li>queuepos (fieldtype: integer)</li>


Add the \install\Queue.bas into your VBA.

Open SQL-management studio, find the database where you want to use the business funnel and choose "New Query". Insert the SQL procedures csp_getQueueLength and csp_updateCampaignQueue from the Install folder for your database.

You need to call the app from the <u>Course participant</u> card with the following code:

```html
<div data-app="{app:'queue', config:{
		color:'blue',
		flashColor:'red',
    displayText:'',
		iconPosition:'right',
    icon:'fa-user',
		blinktime:'300'}}">
</div>
```

The config fields are self explanatory and may or may not work :)
