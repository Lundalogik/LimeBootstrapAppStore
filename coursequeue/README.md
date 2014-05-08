markdown

#Course Queue
The No.1 queue management tool for course / campaign handling!

Do you have a problem with setting up a queue for fully booked campaign or course? Dont you worry, Lundalogik has came up with a solution of queuing up the possible participants on sign up order!

All potential participants will be shown and queued up on the actionpad if there will be cancellations etc. for signing up!







#Installation

Download the installation file through the link.

Add the \install\Queue.bas into your VBA.

Open SQL-management studio, find the database where you want to use the business funnel and choose "New Query". Insert the SQL procedures csp_getQueueLength and csp_updateCampaignQueue from the Install folder for your database.

Your Course participant card requires two fields:
<li>queuetime</li
<li>queuepos</li>