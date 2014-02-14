var editor = editor || {};

/* element.js
 * Used to edit element attribute values
 */


editor.element = (function() {

	function updateField($field, values) {
		var str = editor.parser.valuesToString(values);
		$field.val(str);
		renderValueEditor($field, values);
	}

	function renderArrayEditor($field, values) {
		var $parent = $field.parent();

		$(":not(input.field)", $parent).remove();

		values.forEach(function (e,i) {
			var $elm = $("<span>" + e + "</span> <span class=\"remove"+i+"\">remove</span><br />");
			$parent.append($elm);
			$(".remove"+i, $parent).on("click", function() {
				values.splice(i,1);
				updateField($field, values);
			});
		});
	}

	function renderObjectEditor($field, values) {
		var $parent = $field.parent();

		$(":not(input.field)", $parent).remove();

		values.forEach(function (e,i){
			var $elm = $("<span>" + e["key"] + "</span> <span class=\"edit" +i+"\">edit</span> <span class=\"remove"+i+"\">remove</span><br />");
			$parent.append($elm);
			$(".remove"+i, $parent).on("click", function() {
				values.splice(i,1);
				updateField($field, values);
			});
			$(".edit"+i, $parent).on("click", function() {
				var $fragment = $("<span>key: " +  e["key"]+ "</span> <input type='text' name='value' placeholder='Value' /> <button class=\"editbtn\">Update</button>");
				$parent.append($fragment);
				$("input[name='value']", $parent).val(e["value"]);

				$("button.editbtn", $parent).on("click", function() {
					var value = $("input[name='value']", $parent).val();
					var obj = {"key": e["key"], "value": value};
					console.log(obj);
					values[i] = obj;
					updateField($field, values);
				});
			});
		});
	}

	function renderValueEditor($field, values) {
		if(values.length > 0 && typeof(values[0]) === "object") {
			renderObjectEditor($field, values);
		} else {
			renderArrayEditor($field, values);
		}
	}

	function setupAddButton($field) {
		var $container = $field.parent();
		var nodename = $field.data("nodename");
		if(nodename === "class") {
			$("span.add",$container.parent()).on("click", function() {
				var $fragment = $("<input type='text' name='add' /> <button class=\"addbtn\">Add</button>")
				$container.append($fragment);

				$("button.addbtn", $container).on("click", function() {
					var value = $("input[name='add']", $container).val();
					var current = getFieldValues($field);
					current.push(value);
					updateField($field, current);
				});
			});

		} else if(nodename === "data-bind") {
			$("span.add",$container.parent()).on("click", function() {
				var $fragment = $("<input type='text' name='key' placeholder='Key' /> <input type='text' name='value' placeholder='Value' /> <button class=\"addbtn\">Add</button>");
				$container.append($fragment);

				$("button.addbtn", $container).on("click", function() {
					var key = $("input[name='key']", $container).val();
					var value = $("input[name='value']", $container).val();
					var obj = {"key": key, "value": value};
					var current = getFieldValues($field);
					current.push(obj);
					updateField($field, current);
				});
			});
		}
	}

	function getFieldValues($field) {
		var value = $field.val();
		var nodename = $field.data("nodename");
		var parser = editor.parser.getParserForAttribute(nodename);
		var parsed = parser(value);
		return parsed;
	}

	function extendInputField($field) {
		$field.hide();
		setupAddButton($field);
		var parsed = getFieldValues($field);
		renderValueEditor($field, parsed);
	}

	function createEditorForAttribute(attr,$container) {
		var $fragment = $("<div><strong>" + attr.nodeName + "</strong> <span class=\"add\">+</span><div><input class=\"field\" type='text' data-nodename=\""+ attr.nodeName +"\" value=\"" + attr.nodeValue + "\" /></div></div>");

		$container.append($fragment);

		extendInputField($("input",$fragment));
	}

	function updateAttributeChanges(element, $container) {
		var $elm = $(element);
		
		$("input", $container).each(function() {
			var $that = $(this);
			var attr = $that.attr("data-nodename");
			var val = $that.val();
			if(val !== "") {
				$elm.attr(attr, $that.val());
			} else {
				$elm.removeAttr(attr);
			}
		});
	}

	function addSaveChangesButton(element, $container, syncChangesCb) {
		var $btn = $("<button>Save changes</button>");
		$btn.on("click", function(){
			updateAttributeChanges(element, $container);

			syncChangesCb();
		});
		$container.append($btn);
	}

	function createEditControlForElement(element, $container, syncChangesCb) {
		if(!element.hasAttribute("class")) {
			element.setAttribute("class", "");
		}

		if(!element.hasAttribute("data-bind")) {
			element.setAttribute("data-bind", "");
		}


		for (var attr, i=0, attrs=element.attributes, l=attrs.length; i<l; i++){
			attr = attrs.item(i)
			createEditorForAttribute(attr,$container);
		}

		addSaveChangesButton(element, $container, syncChangesCb);
	}

	return {
		createEditControlForElement: createEditControlForElement,
	};

})();
