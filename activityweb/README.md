#Activity Web

##Info
The No.1 activity goal measurement tool!

Do you have a problem with following your sales activity and goals? Dont you worry, Lundalogik has came up with a solution of seeing your activity progress towards your goals at one glance. ActivityWeb app draws your activity goals and done activities into one simple spiderweb chart. You'll immediately see your own activities in comparison to the activities of the whole company.

Proevolutionize your sales!

<li>More salescalls</li>
<li>More meetings</li>
<li>More quotes</li>
<li>More orders</li>
<li>Make more money!</li>
</ul>

##Install
Copy "activityweb" folder to the "apps" folder. 

Create a VBA module called "Activityweb" and add the .bas file from the "/install" folder (drag n drop of the .bas file works well)
Add the stored procedures from the "/install" folder into your preferred database
 
Add the following code to the `coworker.html`:

```html
<div data-app="{app:'activityweb', config:{}}"></div>
```