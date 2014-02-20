var editor = editor || {};

editor.widget = (function() {

	function activator(widget) {
		var $fragment = $(widget["html"]);
		if(widget["bindings"]){
			var bindings = _.map(widget["bindings"], function(b) {
				return {
					"key": b["binding"],
					"value": b["value"]
				};
			});
			var str = editor.parser.valuesToString(bindings);
			$fragment.attr("data-bind", str);
		}
		return $fragment;
	}

	return {
		activate: activator
	};
})();