lbs.apploader.register('d3_charts_donut', function () {
    self = this;

    //config
    this.config = {
        dataSources: [

        ],
        resources: {
            scripts: [],
            styles: ['app.css'],
            libs: ['d3.v3.min.js']
        },
        data: [
            {value: 21780, text: "Alfa"},
            {value: 21682, text: "Bravo"},
            {value: 5000, text: "Charlie"},
            {value: 5000, text: "Delta"},
            {value: 5000, text: "Foxtrot"},
            {value: 5000, text: "Echo"},
          ],
        label: 'Awesome',
        unit: 'count',
        width: 350,
        heigth: 300,
        radius: 100,
        innerRadius: 45,
        textOffset: 14,
        transitionTime: 200
    },


    //initialize
    this.initialize = function (element,viewModel) {

        viewModel.appname = 'Chart Donut';

        this.build(
          this.config.data,
          this.config.label,
          this.config.unit,
          this.config.width,
          this.config.heigth,
          this.config.radius,
          this.config.innerRadius,
          this.config.textOffset,
          this.config.transitionTime
          );

        return viewModel;
    }

    this.build = function(data,label,unit,width,heigth,radius,innerRadius,textOffset,transitionTime){
        
      var w = width;
      var h = heigth;
      var r = radius;
      var ir = innerRadius;
      var textOffset = 14;
      var tweenDuration = transitionTime;
      var data = data;
      var label = label;
      var unit = unit;

      //OBJECTS TO BE POPULATED WITH DATA LATER
      var lines, valueLabels, nameLabels;
      var pieData = [];    
      // var oldPieData = [];
      var filteredPieData = [];

      //D3 helper function to populate pie slice parameters from array data
      var donut = d3.layout.pie().value(function(d){
        return d.value;
      });

      //D3 helper function to create colors from an ordinal scale
      var color = d3.scale.category20();

      //D3 helper function to draw arcs, populates parameter "d" in path object
      var arc = d3.svg.arc()
        .startAngle(function(d){ return d.startAngle; })
        .endAngle(function(d){ return d.endAngle; })
        .innerRadius(ir)
        .outerRadius(r);

      ///////////////////////////////////////////////////////////
      // CREATE VIS & GROUPS ////////////////////////////////////
      ///////////////////////////////////////////////////////////

      var vis = d3.select(".chart_donut").append("svg:svg")
        .attr("width", w)
        .attr("height", h);

      //GROUP FOR ARCS/PATHS
      var arc_group = vis.append("svg:g")
        .attr("class", "arc")
        .attr("transform", "translate(" + (w/2) + "," + (h/2) + ")");

      //GROUP FOR LABELS
      var label_group = vis.append("svg:g")
        .attr("class", "label_group")
        .attr("transform", "translate(" + (w/2) + "," + (h/2) + ")");

      //GROUP FOR CENTER TEXT  
      var center_group = vis.append("svg:g")
        .attr("class", "center_group")
        .attr("transform", "translate(" + (w/2) + "," + (h/2) + ")");

      //PLACEHOLDER GRAY CIRCLE
      var paths = arc_group.append("svg:circle")
          .attr("fill", "#EFEFEF")
          .attr("r", r);

      ///////////////////////////////////////////////////////////
      // CENTER TEXT ////////////////////////////////////////////
      ///////////////////////////////////////////////////////////

      //WHITE CIRCLE BEHIND LABELS
      var whiteCircle = center_group.append("svg:circle")
        .attr("fill", "white")
        .attr("r", ir);

      // "TOTAL" LABEL
      var totalLabel = center_group.append("svg:text")
        .attr("class", "label")
        .attr("dy", -15)
        .attr("text-anchor", "middle") // text-align: right
        .text(label);

      //TOTAL TRAFFIC VALUE
      var totalValue = center_group.append("svg:text")
        .attr("class", "total")
        .attr("dy", 7)
        .attr("text-anchor", "middle") // text-align: right
        .text("Waiting...");

      //UNITS LABEL
      var totalUnits = center_group.append("svg:text")
        .attr("class", "units")
        .attr("dy", 21)
        .attr("text-anchor", "middle") // text-align: right
        .text(unit);

      update(data);

      // to run each time data is generated
      function update(data,label,units) {
        
        pieData = donut(data,label,units);
        var totalOctets = 0;
        filteredPieData = pieData.filter(filterData);

        function filterData(element, index, array) {
          element.name = data[index].text;
          element.value = data[index].value;
          totalOctets += element.value;
          return (element.value > 0);
        }

        if(filteredPieData.length > 0 ){

          //REMOVE PLACEHOLDER CIRCLE
          arc_group.selectAll("circle").remove();

          totalValue.text(function(){
            return totalOctets;
          });

          //DRAW ARC PATHS
          paths = arc_group.selectAll("path").data(filteredPieData);
          
          paths.enter().append("svg:path")
            .attr("stroke", "white")
            .attr("stroke-width", 0.5)
            .attr("fill", function(d, i) { return color(i); })
            
            .transition()
              .duration(tweenDuration)
              .attrTween("d", pieTween);
          
          paths
            .transition()
              .duration(tweenDuration)
              .attrTween("d", pieTween);
          
          paths.exit()
            .transition()
              .duration(tweenDuration)
              .attrTween("d", removePieTween)
            .remove();

          //DRAW TICK MARK LINES FOR LABELS
          lines = label_group.selectAll("line").data(filteredPieData);
          lines.enter().append("svg:line")
            .attr("x1", 0)
            .attr("x2", 0)
            .attr("y1", -r-3)
            .attr("y2", -r-8)
            .attr("stroke", "gray")
            .attr("transform", function(d) {
              return "rotate(" + (d.startAngle+d.endAngle)/2 * (180/Math.PI) + ")";
            });
          lines.transition()
            .duration(tweenDuration)
            .attr("transform", function(d) {
              return "rotate(" + (d.startAngle+d.endAngle)/2 * (180/Math.PI) + ")";
            });
          lines.exit().remove();

          //DRAW LABELS WITH PERCENTAGE VALUES
          valueLabels = label_group.selectAll("text.value").data(filteredPieData)
            .attr("dy", function(d){
              if ((d.startAngle+d.endAngle)/2 > Math.PI/2 && (d.startAngle+d.endAngle)/2 < Math.PI*1.5 ) {
                return 5;
              } else {
                return -7;
              }
            })
            .attr("text-anchor", function(d){
              if ( (d.startAngle+d.endAngle)/2 < Math.PI ){
                return "beginning";
              } else {
                return "end";
              }
            })
            .text(function(d){
              var percentage = (d.value/totalOctets)*100;
              return percentage.toFixed(1) + "%";
            });

          valueLabels.enter().append("svg:text")
            .attr("class", "value")
            .attr("transform", function(d) {
              return "translate(" + Math.cos(((d.startAngle+d.endAngle - Math.PI)/2)) * (r+textOffset) + "," + Math.sin((d.startAngle+d.endAngle - Math.PI)/2) * (r+textOffset) + ")";
            })
            .attr("dy", function(d){
              if ((d.startAngle+d.endAngle)/2 > Math.PI/2 && (d.startAngle+d.endAngle)/2 < Math.PI*1.5 ) {
                return 5;
              } else {
                return -7;
              }
            })
            .attr("text-anchor", function(d){
              if ( (d.startAngle+d.endAngle)/2 < Math.PI ){
                return "beginning";
              } else {
                return "end";
              }
            }).text(function(d){
              var percentage = (d.value/totalOctets)*100;
              return percentage.toFixed(1) + "%";
            });

          valueLabels.transition().duration(tweenDuration).attrTween("transform", textTween);
          valueLabels.exit().remove();


          //DRAW LABELS WITH ENTITY NAMES
          nameLabels = label_group.selectAll("text.units").data(filteredPieData)
            .attr("dy", function(d){
              if ((d.startAngle+d.endAngle)/2 > Math.PI/2 && (d.startAngle+d.endAngle)/2 < Math.PI*1.5 ) {
                return 17;
              } else {
                return 5;
              }
            })
            .attr("text-anchor", function(d){
              if ((d.startAngle+d.endAngle)/2 < Math.PI ) {
                return "beginning";
              } else {
                return "end";
              }
            }).text(function(d){
              return d.name;
            });

          nameLabels.enter().append("svg:text")
            .attr("class", "units")
            .attr("transform", function(d) {
              return "translate(" + Math.cos(((d.startAngle+d.endAngle - Math.PI)/2)) * (r+textOffset) + "," + Math.sin((d.startAngle+d.endAngle - Math.PI)/2) * (r+textOffset) + ")";
            })
            .attr("dy", function(d){
              if ((d.startAngle+d.endAngle)/2 > Math.PI/2 && (d.startAngle+d.endAngle)/2 < Math.PI*1.5 ) {
                return 17;
              } else {
                return 5;
              }
            })
            .attr("text-anchor", function(d){
              if ((d.startAngle+d.endAngle)/2 < Math.PI ) {
                return "beginning";
              } else {
                return "end";
              }
            }).text(function(d){
              return d.name;
            });

          nameLabels.transition().duration(tweenDuration).attrTween("transform", textTween);

          nameLabels.exit().remove();
        }  
      }

      ///////////////////////////////////////////////////////////
      // FUNCTIONS //////////////////////////////////////////////
      ///////////////////////////////////////////////////////////

      // Interpolate the arcs in data space.
      function pieTween(d, i) {
        var s0;
        var e0;
   
        s0 = 0;
        e0 = 0;
        
        var i = d3.interpolate({startAngle: s0, endAngle: e0}, {startAngle: d.startAngle, endAngle: d.endAngle});
        return function(t) {
          var b = i(t);
          return arc(b);
        };
      }

      function removePieTween(d, i) {
        s0 = 2 * Math.PI;
        e0 = 2 * Math.PI;
        var i = d3.interpolate({startAngle: d.startAngle, endAngle: d.endAngle}, {startAngle: s0, endAngle: e0});
        return function(t) {
          var b = i(t);
          return arc(b);
        };
      }

      function textTween(d, i) {
        var a;
      
        a = 0;
        
        var b = (d.startAngle + d.endAngle - Math.PI)/2;

        var fn = d3.interpolateNumber(a, b);
        return function(t) {
          var val = fn(t);
          return "translate(" + Math.cos(val) * (r+textOffset) + "," + Math.sin(val) * (r+textOffset) + ")";
        };
      }
        
    }


});