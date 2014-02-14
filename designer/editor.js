var editor = (function() {

	var $template;

	function createEditorsForElement(e) {
		var $editor = $(".editor");
		$editor.children().remove();

		editor.element.createEditControlForElement(e, $editor, refresh);
	}

	function addButton($li, text, fn) {
		var $btn = $("<button>" + text +"</button>");
		$btn.on("click", function() {
			fn();
			refresh();
		});
		$li.append($btn);
	}

	function addButtons(e, $li) {
		var $e = $(e);
		if(e.nodeName === "UL") {
			addButton($li, "Add Li", function() { $e.append($("<li></li>")); });
		}

		addButton($li, "Remove", function() { $e.remove(); });

		addButton($li, "up", function() { $e.insertBefore($e.prev());})

		addButton($li, "down", function() { $e.insertAfter($e.next());})
	}

	function itr($ctx, $nodes) {
		if($nodes.length > 0 ) {
			var $ul = $("<ul></ul>");

			$nodes.each(function(i,e){
				if(e.nodeName === "#text") {
					return;
				}

				var $li = $("<li><span>" +e.nodeName+"</span></li>");

				addButtons(e, $li);

				$("span", $li).on("click", function(){
					createEditorsForElement(e);
					refresh();
				});
				
				$ul.append($li);
				itr($ul, $(e).contents())
			});

			$ctx.append($ul);
		}
	}

	function refresh() {
		reloadOutline();
		applyTemplate();
		$("#template").val($template.html());
	}

	function reloadOutline() {
		$(".outline").contents().remove();
		itr( $(".outline"), $template.contents());
	}

	function applyTemplate() {
		document.getElementById('preview').contentWindow.document.getElementById('body').innerHTML = $template.clone().html();
	}

	function load() {
		var text = $("#template").val();
		$template = $("<div>" +text+"</div>");

		refresh();
	}

	function setup() {
		document.getElementById('preview').contentWindow.document.write("<html><body id='body'></body></html>");

		var $widgetList = $("#widgets");
		var widgets = editor.appstore.widgets();
		widgets.forEach(function(w) {
			var $opt = $("<option value=\""+w["name"]+"\">"+w["name"]+"</option>");
			$widgetList.append($opt);
		});

		$("#addwidgetbtn").on("click", function() {
			lbs.log.info("hai");
			var selected = $widgetList.val();
			var widget = _.find(widgets, function(w) { return w["name"] === selected; })
			lbs.log.info("underscore");
			var $widget = editor.widget.activate(widget);
			$template.append($widget);
			refresh();
		});
	}

	return {
		setup: setup,
		load: load
	};
})();

