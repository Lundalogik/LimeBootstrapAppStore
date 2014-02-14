/* appstore.js
 * Facade for http://limebootstrap.lundalogik.com/
 */

var editor = editor || {};

editor.appstore = (function() {

	function availableBindings() {
		return [{
			"binding": "icon",
			"input": ["text", "icon"],
			"description": "Adds an icon"
		}, {
			"binding":"call",
			"input":["text", "field"],
			"description":"Calls the number"
		}, {
			"binding":"openURL",
			"input":["text", "field"],
			"description":"Opens url in browser"
		}];
	}

	function availableWidgets() {
		return [{
			"name":"Menu",
			"classes": [{
				"name": "expandable",
				"optional": true,
				"description": "Add for a expandable menu"
			}],
			"description":"menu is nice",
			"html":"<ul class='menu' data-widget='Menu'></ul>"
		}, {
			"name": "Button",
			"bindings": [
				{ "binding": "text", "value": "'Ok!'"},
				{ "binding": "click", "value": "alert('foo')"}
			],
			"description": "A button",
			"html":"<button data-widget='Button'></button>"
		}];
	}

	return {
		bindings: availableBindings,
		widgets: availableWidgets,
	};
})();