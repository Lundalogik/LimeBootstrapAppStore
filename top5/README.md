#Top 5 Sales Reps

##Info
When you want to rank your sales reps according to who's best and who's not! This app will let them compete against each other and boost your sales! $$$

Are your sales reps performing poorly because they have no idea of who's performing the best? Fear no more, Lundalogik is back once again to solve all your troubles.

<li>More salescalls</li>
<li>More meetings</li>
<li>More quotes</li>
<li>More orders</li>
<li>Make more money!</li>
</ul>

##Install
Copy "top5" folder to the "apps" folder. 

Create a VBA module called "Top5" and add the .bas file from the "/install" folder (drag n drop of the .bas file works well).
You can modify the date range (i.e. how many days back do you want to see the results from) and business status in the VBA code:
    
	'OPTION SETUP
	'the option key of the preferred business status
	Public Const sOptionkey As String = "agreement"
	'the date range of how many days back you want to see results
	Public Const dayRange As Integer = 30
	'OPTION SETUP END


####SQL
Add the stored procedures from the "/install" folder into your preferred database
 
####HTML
Add the following code to the `index.html`:
    
	<div data-app="{app:'top5', config:{}}"></div>
