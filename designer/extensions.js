jQuery.fn.extend({
	firstClass: function() {
		var classes = this.attr('class');
		if(classes) {
			var c = classes.split(/\s+/);
			return _.first(c);
		}
		return undefined;
	},
	textBinding: function() {
		var bind = this.attr('data-bind');
		if(bind) {
			var parser = editor.parser.getParserForAttribute("data-bind");
			var parsed = parser(bind);
			var text = _.find(parsed, function(v) {
				return v["key"] === "text";
			});
			if(text) {
				var val = text["value"];
				if(val) {
					var parts = val.split(/\./);
					var l = _.last(parts);
					if(l !== "text") {
						return l;
					} else {
						return parts[parts.length-2];
					}
				}
			}
		}
	}
});