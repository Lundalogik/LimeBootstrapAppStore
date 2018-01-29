lbs.apploader.register('RelationMap', function () {
    var self = this;

    self.config = function (appConfig) {
            this.getJsonFunction = appConfig.getJsonFunction || "GetJsonCoworker";
            this.selectedRecordId = lbs.common.executeVba("RelationMap.GetSelectedRecordId," + appConfig.recordType);
            this.title = appConfig.title || "Organizational schema";
            this.depth = appConfig.depth || 2;
            this.animationDuration = appConfig.animationDuration || 1000;
            this.circleOutlineColor = appConfig.circleOutlineColor;
            this.circleFillColor = appConfig.circleFillColor;
            this.linkStrokeColor = appConfig.linkStrokeColor;
            this.nodePrimaryTextColor = appConfig.nodePrimaryTextColor;
            this.nodeSecondaryTextColor = appConfig.nodeSecondaryTextColor;
            this.toolTipTextColor = appConfig.toolTipTextColor;
            this.toolTipBackgroundColor = appConfig.toolTipBackgroundColor;

            this.dataSources = [];
            this.resources = {
                scripts: ['tree.js', 'helperFunctions.js'], // <= External libs for your apps. Must be a file
                styles: ['app.css'], // <= Load styling for the app.
                libs: ['d3.v3.min.js'] // <= Already included libs, put not loaded per default. Example json2xml.js
            };
    };

    self.initialize = function (node, viewModel) {

        /**
         * Variables
         */

        // Lime colors:
        var blue = "#00BEFF",
            magenta ="#FF0096",
            green = "#A0D700",
            turquoise = "#00C8AA",
            orange = "#EF6407";

        var circleOutlineColor = self.config.circleOutlineColor ? self.config.circleOutlineColor : green,
            circleFillColor = self.config.circleFillColor ? self.config.circleFillColor : helperFunctions.calculateTransparentColor(green, '#FFFFFF', 0.35),
            linkStrokeColor = self.config.linkStrokeColor ? self.config.linkStrokeColor : helperFunctions.calculateTransparentColor(green, '#FFFFFF', 0.4),
            nodePrimaryTextColor = self.config.nodePrimaryTextColor ? self.config.nodePrimaryTextColor : "#000",
            nodeSecondaryTextColor = self.config.nodeSecondaryTextColor ? self.config.nodeSecondaryTextColor : helperFunctions.calculateTransparentColor(magenta, '#FFFFFF', 0.6),
            toolTipTextColor = self.config.toolTipTextColor ? self.config.toolTipTextColor : helperFunctions.calculateTransparentColor(green, '#FFFFFF', 0.4),
            toolTipBackgroundColor = self.config.toolTipBackgroundColor ? self.config.toolTipBackgroundColor : "#000",
            depth = self.config.depth,
            animationDuration = self.config.animationDuration,
            stringJson = lbs.common.executeVba("RelationMap." + self.config.getJsonFunction),
            font = "Segoe UI",
            screenHeight = screen.height,
            screenWidth = screen.width,
            treeJson = JSON.parse(stringJson),
            original = treeJson,
            diameter = screenHeight - 35 - 80,
            width = diameter,
            height = diameter,
            sizeFactor = 1 / depth,
            i = 0;

        var treeLayout = d3.layout.tree()
            .size([360, diameter / 2])
            .separation(function (a, b) { return (a.parent === b.parent ? 1 : 5) / (a.depth + 0.000000001); }); //fullösning på när en nod bara har ett barn.

        var diagonal = d3.svg.diagonal.radial()
            .projection(function (d) { return [d.y, d.x / 180 * Math.PI]; });

        var svg = d3.select("#svgContainer").append("svg")
            .attr("width", width)
            .attr("height", height)
            .append("g")
            .attr("transform", "translate(" + diameter / 2 + "," + ((diameter / 2) - 10) + ")");

        var tooltip = d3.select("#svgContainer").append("div")
            .style("position", "absolute")
            .style("z-index", "10")
            .style("visibility", "hidden")
            .style("color", toolTipTextColor)
            .style("background", toolTipBackgroundColor)
            .style("opacity", "1")
            .style("border-radius", "3px")
            .style("padding", "6px 8px 6px 8px")
            .html("No info :'(");

        viewModel.root = ko.observable(treeJson);
        viewModel.root().x0 = height / 2;
        viewModel.root().y0 = 0;

        // Breadcrumb for navigation. Used in app.html.
        viewModel.breadCrumb = ko.computed(function() {
            var crumb = ko.observableArray();
            var node = viewModel.root();
            while (node) {
                node.select = function (d) { d !== viewModel.root() ? viewModel.selectNode(d) : null };
                crumb.unshift(node);
                node = node.parent;
            }
            return crumb();
        });

        // Set selected node to root and update tree.
        viewModel.selectNode = function (d) {
            if (d) {
                viewModel.root(d);
                tree.expand(viewModel.root(), 0, depth);
                updateTree(viewModel.root(), animationDuration);
            }
        }
        

        /**
         * Logic
         */

        // Sets title and renders tree.
        $('title').html(self.config.title);
        if (self.config.selectedRecordId) {
            tree.expand(viewModel.root(), 0, Number.MAX_VALUE);
            updateTree(viewModel.root(), 0);
            viewModel.selectNode(tree.selectNodeById(viewModel.root(), self.config.selectedRecordId, viewModel));
        }
        else {
            tree.expand(viewModel.root(), 0, depth);
            updateTree(viewModel.root(), animationDuration);            
        }
        return viewModel;

        function updateTree(source, duration) {

            // Compute the new tree layout.
            var nodes = treeLayout.nodes(source),
                links = treeLayout.links(nodes);

            // Normalize for fixed-depth.
            nodes.forEach(function (d) { d.y = d.parent ? d.depth * (diameter / 2 / depth - 350 / (depth * depth)) : 0; });

            // Update the nodes.
            var node = svg.selectAll("g.node")
                .data(nodes, function (d) { return d.id || (d.id = ++i); });

            // Enter any new nodes at the parent's previous position.
            var nodeEnter = node.enter().append("g")
                .attr("class", "node")
                .attr("transform", function (d) { return "rotate(" + (d.x - 90) + ")"; });

            nodeEnter.append("circle")
                .attr("r", 1e-6)
                .style("fill", function(d) { return d._children ? circleFillColor : "#fff"; })
                .style("stroke", circleOutlineColor)
                .style("stroke-width", "1.5px")
                .style("cursor", "pointer")
                .on("click", function (d) { d === viewModel.root() ? viewModel.selectNode(d.parent) : viewModel.selectNode(d)});

            nodeEnter.append("text")
                .attr("class", "primaryText")
                .style("fill-opacity", 1e-6)
                .on("mouseover", function(d) {
                    tooltip.html(d.tooltip);
                    return tooltip.style("visibility", "visible");})
                .on("mousemove", function () { return tooltip.style("top", (d3.event.pageY - 15) + "px").style("left", (d3.event.pageX + 15) + "px"); })
                .on("mouseout", function () { return tooltip.style("visibility", "hidden"); });

            nodeEnter.append("text")
                .attr("class", "secondaryText")
                .attr("transform", function (d) { return d.children || d === source ? "rotate(" + (90 - d.x) + ")" : "rotate(0)"; })
                .style("cursor", "default")
                .style("fill-opacity", 1e-6);


            // Transition nodes to their new position.
            var nodeUpdate = node
                .call(nodeTransition, duration);

            nodeUpdate.select("circle")
                .call(nodeCircleTransition, duration);

            nodeUpdate.select("text.primaryText")
                .call(nodePrimaryTextTransition, duration);

            nodeUpdate.select("text.secondaryText")
                .call(nodeSecondaryTextTransition, duration);

            // Remove exiting nodes.
            var nodeExit = node.exit().transition()
                .duration(0)
                //.attr("transform", function(d) { return "diagonal(" + source.y + "," + source.x + ")"; })
                .remove();

            nodeExit.select("circle")
                .attr("r", 1e-6);

            nodeExit.select("text")
                .style("fill-opacity", 1e-6);


            // Update the links.
            var link = svg.selectAll("path.link")
                .data(links, function (d) { return d.target.id; });

            // Enter any new links at the parent's previous position.
            link.enter().insert("path", "g")
                .attr("class", "link")
                .attr("d", function (d) {
                    var o = {x: source.x0, y: source.y0};
                    return diagonal({source: o, target: o});
                })
                .style("fill", "none")
                .style("stroke", linkStrokeColor)
                .style("stroke-width", "1.5px");

            // Transition links to their new position.
            link.transition()
                .duration(duration)
                .attr("d", diagonal);

            // Remove exiting links.
            link.exit().transition()
                .duration(0)
                .attr("d", function (d) {
                var o = {x: source.x, y: source.y};
                return diagonal({source: o, target: o});
                })
                .remove();

            // Stash the old positions for transition.
            nodes.forEach(function (d) {
                d.x0 = d.x;
                d.y0 = d.y;
            });


            /**
             * Transition functions on node updates.
             * Separate functions so that they can run concurrently.
             */

            function nodeTransition(path, duration) {
                path.transition("nodeTransition")
                    .duration(duration)
                    .attr("transform", function (d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; });
            }

            function nodeCircleTransition(path, duration) {
                path.transition("nodeCircleTransition")
                    .duration(duration)
                    .attr("r", function (d) { return d === source ? 18 * sizeFactor * 1.1 : 18 * sizeFactor; })
                    .style("fill", function (d) { return d._children ? circleFillColor : "#fff"; });
            }

            function nodePrimaryTextTransition(path, duration) {
                path.transition("nodePrimaryTextTransition")
                    .duration(0)
                    .attr("x", function (d) {
                        if (d === source) {
                            return (helperFunctions.getTextWidth(d.primaryText, 32 * sizeFactor * 1.1 + "px " + font)) / 2 + 28 * sizeFactor;
                        }
                        else if (d.children || d.x <= 180) {
                            return (helperFunctions.getTextWidth(d.primaryText, 32 * sizeFactor + "px " + font)) / 2 + 28 * sizeFactor;
                        }
                        else  {
                            return ((helperFunctions.getTextWidth(d.primaryText, 32 * sizeFactor + "px " + font)) / 2 + 28 * sizeFactor) * -1;
                        }
                    })
                    .attr("transform", function (d) {
                        if (d.children || d === source) {
                            return "rotate(" + (90 - d.x) + ")";
                        }
                        else if (d.x <= 180) {
                            return "rotate(0)";
                        }
                        else {
                            return "rotate(180)";
                        }
                    })
                    .transition()
                    .duration(duration)
                    .text(function (d){ return d.primaryText; })
                    .attr("dy", ".35em")
                    .attr("font-size", function (d) { return d === source ? 32 * sizeFactor * 1.1 + "px" : 32 * sizeFactor + "px" })
                    .attr("font-weight", function (d) { return d._children ? "bold" : null })
                    .attr("x", function (d) {
                        var isBold = d._children ? "bold " : "";
                        if (d === source) {
                            return (helperFunctions.getTextWidth(d.primaryText, isBold + 32 * sizeFactor * 1.1 + "px " + "'" + font + "'")) / 2 + 32 * sizeFactor;
                        }
                        else if (d.children || d.x <= 180) {
                            return (helperFunctions.getTextWidth(d.primaryText, isBold + 32 * sizeFactor + "px " + font)) / 2 + 30 * sizeFactor;
                        }
                        else  {
                            return ((helperFunctions.getTextWidth(d.primaryText, isBold + 32 * sizeFactor + "px " + font)) / 2 + 32 * sizeFactor) * -1;
                        }
                    })
                    .attr("transform", function (d) {
                        if (d.children || d === source) {
                            return "rotate(" + (90 - d.x) + ")";
                        }
                        else if (d.x <= 180) {
                            return "rotate(0)";
                        }
                        else {
                            return "rotate(180)";
                        }
                    })
                    .style("text-anchor", "middle" )
                    .style("fill", nodePrimaryTextColor )
                    .style("fill-opacity", 1.0);
            }

            function nodeSecondaryTextTransition(path, duration) {
                path.transition("nodeSecondaryTextTransition")
                    .duration(duration)
                    .text(function (d) { return d.children || d === source ? d.secondaryText : ""; })
                    .attr("x", function (d) { return d === source ? 28 * sizeFactor * 1.1 : 28 * sizeFactor })
                    .attr("y", function (d) { return d.x >= 90 && d.x <= 270 ? 40 * sizeFactor : 40 * sizeFactor })
                    .attr("dy", ".35em")
                    .attr("font-size",  function (d) { return d === viewModel.root() ? 28 * sizeFactor * 1.1 + "px" : 28 * sizeFactor + "px" })
                    .attr("text-anchor", "middle")
                    .attr("transform", function (d) { return d.children || d === viewModel.root() ? "rotate(" + (90 - d.x) + ")" : "rotate(0)";})
                    .style("fill", nodeSecondaryTextColor )
                    .style("fill-opacity", 1.0);
            }
        }
    };
});
