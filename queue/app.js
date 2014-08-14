lbs.apploader.register('queue', function () {
    var self = this;
    //config
    self.config = {
        color:"blue",
		flashColor:"red",
        displayText:"",
		iconPosition:"right",
        icon:"fa-user",
		blinktime:"700",
        dataSources: [
            {type: 'xml', source: 'Queue.GetQueueLength', alias:"queueLength"}
        ],
        resources: {
            scripts: ['jquery-ui-1.10.4.js'],
            styles: ['app.css'],
            libs: []
        },
    },

    //initialize
    self.initialize = function (node,viewmodel) {
            viewmodel.queueLength =  viewmodel.queueLength.data.queue.value.maxqueue;
            if(self.config.displayText){
                viewmodel.displayText = self.config.displayText;
            }else{
                viewmodel.displayText = "in Queue";    
            }

            viewmodel.iconPosition=self.config.iconPosition;

            viewmodel.icon = self.config.icon;
            viewmodel.color = function(){
                switch(self.config.color){
                    case "blue":
                        return "#d6417d";
                    break;
                    case "darkgrey":
                        return "rgb(176, 176, 176)";
                    break;
                    case "red":
                        return "rgb(232, 89, 89)";
                    break;
                    case "pink":
                        return "rgb(243, 150, 206)";
                    break;
                    case "orange":
                        return "rgb(244, 187, 36)";
                    break;
                    case "green":
                        return "rgb(153, 216, 122)";
                    break;
                    default:
                        return self.config.color;
                    break;
                }

            }
			
			viewmodel.flashColor = function(){
                switch(self.config.flashColor){
                    case "blue":
                        return "#e85959";
                    break;
                    case "darkgrey":
                        return "rgb(176, 176, 176)";
                    break;
                    case "red":
                        return "#e85959";
                    break;
                    case "pink":
                        return "rgb(243, 150, 206)";
                    break;
                    case "orange":
                        return "rgb(244, 187, 36)";
                    break;
                    case "green":
                        return "rgb(153, 216, 122)";
                    break;
                    default:
                        return self.config.flashColor;
                    break;
                }

            }

            viewmodel.addToQueue = function(){
                lbs.common.executeVba("Queue.AddToQueue");
				$("#queuebox").effect("highlight", {color: '#41d69a'}, 700);
				//$("#queuebox" ).effect( "bounce", { times: 3 }, "slow" );
				setTimeout(function () {
					lbs.common.executeVba("Queue.closeInspector")
				}, 750);
            }
			
			viewmodel.removeFromQueue = function(){
                lbs.common.executeVba("Queue.RemoveFromQueue");
				//$("#queuebox").effect("highlight", {color: '#41d69a'}, 700);
				//$("#remqueuebox" ).effect( "bounce", { times: 2 }, "slow" );
            }
            return  viewmodel;

    }

});

