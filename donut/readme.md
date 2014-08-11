#Participant Donut Chart

##Info
The Participant Donut Chart works similarly to the old Campaign Participants app, but with a little more flare! Now you can hover over the donut "slices" and see the actual number of participants and also the participant status.

##Install

Copy "donut" folder to the "apps" folder. 

Create a VBA module called "Donutchart" and add the .bas file from the "/install" folder (drag n drop of the .bas file works well)
Add the stored procedure from the "/install" folder into your preferred database
 
Add the following code to the `campaign.html` (for example):

```html
<div data-app="{app:'donut', config:{}}"></div>
```

##Additional setup
You can add more colors and change their order by editing the "colors" section under Morris.Donut()

```javascript
Morris.Donut({			
            element: 'donutchart',
            data: dataArray,
			colors: ['#FF0000','#F79646','#0F8B05','#0000FF']
        });
```

Do we need text here to save us from bugs?
