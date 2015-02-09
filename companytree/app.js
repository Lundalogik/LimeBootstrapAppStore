lbs.apploader.register('companytree', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config =  function(appConfig){
            this.appConfig = appConfig;
            this.dataSources = [];
            this.resources = {
                scripts: ['d3.min.js'], // <= External libs for your apps. Must be a file
                styles: ['app.css'], // <= Load styling for the app.
                libs: ['xml2json.js'] // <= Allready included libs, put not loaded per default. Example json2xml.js
            };
    };

    //initialize---------------------------

    /*Initialize
        Initialize happens after the data and recources are loaded but before the view is rendered.
        Here it is your job to implement the logic of your app, by attaching data and functions to 'viewModel' and then returning it
        The data you requested along with localization are delivered in the variable viewModel.
        You may make any modifications you please to it or replace is with a entirely new one before returning it.
        The returned viewModel will be used to build your app.
        
        Node is a reference to the HTML-node where the app is being initalized form. Frankly we do not know when you'll ever need it,
        but, well, here you have it.
    */
    self.initialize = function (node, viewModel) {
        var appConfig = self.config.appConfig;

        self.vm = function(){
          var self = this;
          self.config = appConfig;

          self.type = ko.observable();
          var yscale = 1;
          var xscale = 1;

          if(self.config.type === undefined){
            self.type("list");
          }
          else{
            self.type(self.config.type);
          }

          if(self.type()==='windowed'){
           
            var idrecord = lbs.common.executeVba("CompanyTree.GetRecordID," + self.type());

            var json = lbs.common.executeVba("CompanyTree.GetHierarchy," + idrecord)
            self.data = $.parseJSON(json);
            
            var margin = {top: 20, right: 20, bottom: 20, left: 120};
            var i = 0,
                duration = 750,
                root;

            var width = ko.computed(function(){
                return $(window).width();
            });
            var height = ko.computed(function(){
                return $(window).height();
            });

            var tree = d3.layout.tree()
                .size([height(), width() - 30]);

            var diagonal = d3.svg.diagonal()
                .projection(function(d) { return [d.y, d.x]; });

            var svg = d3.select("#treecontainer" + type()).append("svg")
                .attr("width", width() + margin.right + margin.left)
                .attr("height", height() + margin.top + margin.bottom)
                .append("g")
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

            var nodes = tree.nodes(self.data);

            var root = nodes[0];
          }

          self.collapse = function(d) {
            if (d.children) {
              d._children = d.children;
              d._children.forEach(collapse);
              d.children = null;
            }
          }

          self.update = function(source){

            var nodes = tree.nodes(root).reverse();
    
            var links = tree.links(nodes);
            var maxDepth = 0;
            nodes.forEach(function(d){
              if(d.depth > maxDepth){
                maxDepth = d.depth;
              }
            });
            nodes.forEach(function(d) { d.y = d.depth * width() / (1.5*maxDepth ); });

            var node = svg.selectAll("g.node")
                .data(nodes, function(d) { return d.id || (d.id = ++i); });

            // Enter any new nodes at the parent's previous position.
            var nodeEnter = node.enter().append("g")
                .attr("class", "node")
                .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; });


            nodeEnter.append("circle")
                .attr("r", 1e-6)
                .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; })
                .on("click", click);

            nodeEnter.append("text")
                .attr("x", function(d) { return d.children || d._children ? -10 : 10; })
                .attr("dy", ".35em")
                .attr("style", function(d){ return (d.idrecord == idrecord ? "font-weight: bold; font-size: 13px; "  : "font-size: 11px; ") + "cursor: pointer;"})
                .attr("idrecord", function(d){return d.name})
                .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
                .text(function(d) { return d.name; })
                .style("fill-opacity", 1e-6)
                .on("click",openRecord);

            // Transition nodes to their new position.
            var nodeUpdate = node.transition()
                .duration(duration)
                .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

            nodeUpdate.select("circle")
                .attr("r", 4.5)
                .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

            nodeUpdate.select("text")
                .style("fill-opacity", 1);

            // Transition exiting nodes to the parent's new position.
            var nodeExit = node.exit().transition()
                .duration(duration)
                .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
                .remove();

            nodeExit.select("circle")
                .attr("r", 1e-6);

            nodeExit.select("text")
                .style("fill-opacity", 1e-6);

            // Update the links…
            var link = svg.selectAll("path.link")
                .data(links, function(d) { return d.target.id; });

            // Enter any new links at the parent's previous position.
            link.enter().insert("path", "g")
                .attr("class", "link")
                .attr("d", function(d) {
                  var o = {x: source.x0, y: source.y0};
                  return diagonal({source: o, target: o});
                });

            // Transition links to their new position.
            link.transition()
                .duration(duration)
                .attr("d", diagonal);

            // Transition exiting nodes to the parent's new position.
            link.exit().transition()
                .duration(duration)
                .attr("d", function(d) {
                  var o = {x: source.x, y: source.y};
                  return diagonal({source: o, target: o});
                })
                .remove();

            // Stash the old positions for transition.
            nodes.forEach(function(d) {
              d.x0 = d.x;
              d.y0 = d.y;
            });

          }

          function click(d) {
            if (d.children) {
              d._children = d.children;
              d.children = null;
            } else {
              d.children = d._children;
              d._children = null;
            }
            update(d);
          }

          function openRecord(d){
              
              var link = lbs.common.createLimeLink('company', d.idrecord);
              window.open('','_parent','');
              window.close();
              lbs.common.executeVba('CompanyTree.OpenCompanyRecord,' + link)
              

          }
          if(type() == 'windowed'){
            if(root.children === undefined){
              self.collapse(root);
              self.update(root);
            }
            else{
              root.children.forEach(collapse);
              self.update(root.children);
            }

            nodes.forEach(function(d){
              if(d.idrecord == idrecord){
                toggleParent(d)
              }
            });
          }

          function toggleParent(d){
            if(d.parent !== undefined){
              click(d);
              toggleParent(d.parent);
            }
          }

        }

        $(window).resize(function(){

        })
        return self.vm;

    };


});
