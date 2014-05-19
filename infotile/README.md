#Info Tile

##Info
The Info Tile is a super simple app, inspired from the Win8 tiles. Supply your favourite LIME Filter and the tile will show the count of the filter and the name. An example is "My todos". You can even supply a icon and your own color! Almost like a real designer!

##Install

Copy "infotile" folder to the “apps” folder. 
 
Add the following HTML to the `index.html`, see setup below for configuration settings:


##News in Info Tile app. 
Enables you to add an automatic refresh to the application by adding a "updateTimer" to the config file.

##Timer
Worth to think about is that too many auto refresh can make Lime slow. Recommended is 
to use this in a time interval of 20 minutes to 30 minutes. 

##News in config file
You can now add updateTimer to your config file. The update timer is set in miliseconds.



```html
<div data-app="{app:'infotile', 
				config:{
					className:'helpdesk', 
					filterName:'Mina försenade uppgifter',
					tileColor:'blue', 
					icon:'fa-user',
					iconPosition: 'right', 
					displayText:'test',
					updateTimer: 20000
			}}">
</div>
```

Create a VBA module called "InfoTile" and add the VBA from the folder "install/InfoTile" (drag n drop of the .bas file works well)

##Setup
The app takes a config with the following parameters
*	className - name of the class where your favourite filter lives, example "todo" or "company"
*	filterName - name of filter (Urval)
*	tileColor - Color of the tile. You can pick any color you like. Just supply a hex-color or a rgb/rgba-color. Better still pick one of the beautiful color presets, see more below
*	tileColor - Color of the tile. You can pick any color you like. Just supply a hex-color or a rgb/rgba-color
*	icon - Supply a font awesome icon for even cooler experience
*	displayText - Optional. The filterName will be the default text, but you can supply your own text here.
*	iconPosition - Optional, is default set as right but can be placed left


###Colors
*	blue
*	darkgrey
*	red
*	yellow
*	orange
*	green  

