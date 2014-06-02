#Pies
##About
This amazing application allows you to visualizing your data in many
different shapes. 

The app works with both decimal and integer fields and you can add as many 
you like. 

By changing the "InnerCutout" percent you can make it look even more fantastic.
###Installation

```html
 <div data-app="{app:'pie',
	config:{
			fields: 
				[
					{field: 'value1', color: '#660099'},
					{field: 'value2', color: '#FFCC33'},					
					{field: 'value3', color: '#3366FF'},					
					{field: 'value6', color: '#009966'},
					{field: 'value8', color: '#F7464A'}
				]
			,options: {segmentStrokeWidth:2,percentageInnerCutout:80}
	}
}">	
</div>
```

To install the app you need to add which fields you are interested in and what options you like to use in your config file.

###Options
```html
Doughnut.defaults = {
	//Boolean - Whether we should show a stroke on each segment
	segmentShowStroke : true,
	
	//String - The colour of each segment stroke
	segmentStrokeColor : "#fff",
	
	//Number - The width of each segment stroke
	segmentStrokeWidth : 2,
	
	//The percentage of the chart that we cut out of the middle.
	percentageInnerCutout : 50,
	
	//Boolean - Whether we should animate the chart	
	animation : true,
	
	//Number - Amount of animation steps
	animationSteps : 100,
	
	//String - Animation easing effect
	animationEasing : "easeOutBounce",
	
	//Boolean - Whether we animate the rotation of the Doughnut
	animateRotate : true,

	//Boolean - Whether we animate scaling the Doughnut from the centre
	animateScale : false,
	
	//Function - Will fire on animation completion.
	onAnimationComplete : null
} 
```

