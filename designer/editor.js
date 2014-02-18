var editor = (function() {

	var $template;

	function createEditorsForElement(e) {
		var $editor = $(".editor");
		$editor.children().remove();

		editor.element.createEditControlForElement(e, $editor, refresh);
	}

	function addIcon($li, icon, fn) {
		var $i = $("<i class='fa " + icon +"' />"); // + text +"</button>");
		$i.on("click", function() {
			fn();
			refresh();
		});
		$li.append($i);
	}

	function addIcons($e, $li) {
		if($e.prop("tagName") === "UL") {
			addIcon($li, "fa-plus", function() { $e.append($("<li></li>")); });
		}

		addIcon($li, "fa-sort-up", function() { $e.insertBefore($e.prev());})

		addIcon($li, "fa-sort-down", function() { $e.insertAfter($e.next());})

		addIcon($li, "fa-times", function() { $e.remove(); });
	}

	function createLi(e, $e) {
		var $li = $("<li><span>" +e.nodeName + "</span></li>");
		
		var c = $e.firstClass();
		var t = $e.textBinding();
		if(c && t) {
			$("span", $li).append(" (c:" + c + " / t:" + t + ") ");
		} else if(c) {
			$("span", $li).append(" (c:" + c + ") ");
		} else if(t){
			$("span", $li).append(" (t:" + t + ") ");
		}
		
		addIcons($e, $li);

		return $li;
	}

	function itr($ctx, $nodes) {
		if($nodes.length > 0 ) {
			var $ul = $("<ul></ul>");

			$nodes.each(function(i,e){
				if(e.nodeName === "#text") {
					return;
				}

				var $e = $(e);
				var $li = createLi(e, $e);

				$("span", $li).on("click", function(){
					createEditorsForElement(e);
				});
				
				$ul.append($li);
				itr($ul, $e.contents())
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

	function setup(model) {
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

