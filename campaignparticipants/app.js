lbs.apploader.register('campaignparticipants', function () {
    var self = this;

    //config
    self.config = {
        dataSources: [
          {type: 'xml', source: 'campaignparticipants.Initialize', alias:"campaignparticipants"}
        
        ],
        resources: {
            scripts: ["chart.js"],
            styles: ['app.css'],
            libs: []
        }
    },

    //initialize
    this.initialize = function (node,viewModel) {
        // if (!self.config.currency){
        //     self.config.currency="tkr"
        // }
        // if (!self.config.divider){
        //     self.config.divider=1000
        // }
        // if (!self.config.decimals){
        //     self.config.decimals=0
        // }
        // if (!self.config.name){
        //     self.config.name="Pipeline"
        // }
        

        var ctx = document.getElementById("participantChart").getContext("2d");
        
        var data = viewModel.campaignparticipants.data.participants

        //#F79646 -orange, invited
        //#0F8B05  -green, accepted
        //#FF0000 -red, declined
        //#0000FF -blue, done
               
        var chartValues = new Array()

        for (var i = 0; i < data.value.length; i++) {   

            chartValues[i] = {}

            chartValues[i].value = parseInt(data.value[i].counter);

            //SET CORRECT COLORS FROM THE PARTICIPANTSTATUS
            if(data.value[i].key=="accepted") {
                
               chartValues[i].color = "#0F8B05"
                        // alert(data.value[i].key)                      
            }  
            else if (data.value[i].key=="declined"){

                chartValues[i].color = "#FF0000"

            }
            else if (data.value[i].key=="invited"){

                chartValues[i].color = "#F79646"
                
            }
            else{

                chartValues[i].color = "#0000FF"
            }   
            

        };

   
    new Chart(ctx).Doughnut(chartValues);  

    // return data;
    };

     
 });

