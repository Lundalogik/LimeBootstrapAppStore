#Info Tile

##Info
The Info Tile is a super simple app, inspired from the Win8 tiles. Supply your favourite LIME Filter and the tile will show the count of the filter and the name. An example is "My todos". You can even supply a icon and your own color! Almost like a real designer!

##Install

Copy "infotile" folder to the “apps” folder. 
 
Add the following HTML to the ActionPad (Todo example):

```html
<div data-app="{app:'infotile', 
				config:{
					className:'todo', 
					filterName:'Mina försenade uppgifter',
					tileColor:'blue', 
					icon:'fa-user', 
					displayText:'Ditt favorit urval'
			}}">
</div>
```

##Setup
The app takes a config with the following parameters
*	className - name of the class where your favourite filter lives, example "todo" or "company"
*	filterName - name of filter (Urval)
*	tileColor - Color of the tile. You can pick any color you like. Just supply a hex-color or a rgb/rgba-color. Better still pick one of the beautiful color presets, see more below
*	tileColor - Color of the tile. You can pick any color you like. Just supply a hex-color or a rgb/rgba-color
*	icon - Supply a font awesome icon for even cooler experience
*	displayText - Optional. The filterName will be the default text, but you can supply your own text here.


###Colors
*	blue
*	darkgrey
*	red
*	yellow
*	orange
*	green  