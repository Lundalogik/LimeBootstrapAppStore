## Requires a license
For more information please contact Lundalogik AB.

#  Follow Up #
This app will help you keep track of how you and the company are doing to reach your monthly goals for the different activity types.
It has two stages, All and Mine:

* All: Shows statistics of how the company is doing with its monthly goals on each activity type.
* Mine: Shows statistics of how you are doing with your monthly goals on each activity type.

###How it works
The numbers in the tile is representing:

***[Done activities] / [goal until today] ( [total goal for month] )***

The tile are represented in tree colors, red, yellow and green. You set the percentage representing the colors by specifying the limit for the yellow color.

Example: yellow on 75% will end up in 

* 0% - 74% - Red
* 75% - 99% - Yellow
* 100% + - Green

**The tagets**

In the Target table each coworker gets a goal per activity and month. Only coworkers with goals will be calculated.

###Misc
It shows all strings in local language.

###Requirements
<table>
  <th>
    Table name
  </th>
  <th>
    Field name
  </th>
  <th>
    Field type
  </th>
  <tr>
    <td>history</td>
    <td>type</td> 
    <td>Option field</td>
  </tr>
  <tr>
    <td>history</td>
    <td>date</td> 
    <td>Date field</td>
  </tr>
   <tr>
    <td>history</td>
    <td>coworker</td> 
    <td>Relation field</td>
  </tr>
   <tr>
    <td>target</td>
    <td>targettype</td> 
    <td>Option field</td>
  </tr>
   <tr>
    <td>target</td>
    <td>targetvalue</td> 
    <td>Integer field</td>
  </tr>
   <tr>
    <td>target</td>
    <td>targetdate</td> 
    <td>Month field</td>
  </tr>
   <tr>
    <td>target</td>
    <td>coworker</td> 
    <td>Relation field</td>
  </tr>
</table>

###How to set it up
Copy the followup folder and place it in the apps folder under the actionpad folder.
In the install folder you can find 4 files.

1. followup.html
2. Code_ for_ThisApplication
3. csp_ vba_getfigures.sql
4. Followup.bas

***1. followup.html***

Copy the followup.html file and place it under the actionpad folder.
In the followup.html file you add a div tag for each activity type you want to see, like this.
```html
<div id="app" data-app="{app:'followup', config:{
	historytype:'customervisit', 
	targettype:'customervisit', 
	yellow:0.75}}">
</div>
```
    
	
* historytype = Key from the option field on the history card
* targettype = Key from the option field on the target card
* yellow = Between this percentage and 100 percent the tile will be yellow  

See followup.html for example.

***2. Code_ for_ThisApplication***

Take the code from the file and paste it in the Setup sub in ThisApplication.

***3. csp_ vba_getfigures.sql***

Insert the SQL procedure in the database you want to use. 

***4. Followup.bas***

Insert the Followup.bas file in the VBA. Run the sub Install() to create the necessary localization posts for the app.
