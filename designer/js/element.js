var editor = editor || {};

/* element.js
 * Used to edit element attribute values
 */

editor.element = (function() {

	var saveChangesCb;

	function updateField($field, values) {
		var str = editor.parser.valuesToString(values);
		$field.val(str);
		renderValueEditor($field, values);
		saveChangesCb();
	}

	function renderArrayEditor($field, values) {
		var $parent = $field.parent();

		$(":not(input.field)", $parent).remove();

		values.forEach(function (e,i) {
			var $elm = $("<span>" + e + "</span> <i class=\"fa fa-times remove"+i+"\" /><br />");
			$parent.append($elm);
			$(".remove"+i, $parent).one("click", function() {
				values.splice(i,1);
				updateField($field, values);
			});
		});
	}

	function addIconSelector($container, value, saveCallBack) {
		var $fragment = $("<button class=\"btn btn-default iconpicker\" data-icon=\"fontawesome\" role=\"iconpicker\"></button>");
		$container.append($fragment);
		var v = "";
		if(value.length > 2) {
			v = value.substring(1, value.length-1);
		}
		var $btn = $(".btn.iconpicker", $container);
		$btn.iconpicker({ 
			iconset: 'fontawesome',
			icon: v, 
			rows: 4,
			cols: 4,
			placement: 'bottom',
		});
		$btn.on("change", function(e) {
			saveCallBack("'" + e.icon + "'");
		});
	}

	function renderObjectEditor($field, values) {
		var $parent = $field.parent();

		$(":not(input.field)", $parent).remove();

		values.forEach(function (e,i){
			var $elm = $("<span>" + e["key"] + "</span> <i class=\"fa fa-edit edit" +i+"\" /> <i class=\"fa fa-times remove"+i+"\" /><br />");
			$parent.append($elm);
			$(".remove"+i, $parent).one("click", function() {
				values.splice(i,1);
				updateField($field, values);
			});
			$(".edit"+i, $parent).one("click", function() {
				if(e["key"] !== "icon") {
					var $fragment = $("<div><span>key: " +  e["key"]+ "</span> <input type='text' name='value' placeholder='Value' /> <button class=\"editbtn\">Update</button></div>");
					$parent.append($fragment);
					$("input[name='value']", $parent).val(e["value"]);

					$("button.editbtn", $parent).on("click", function() {
						var value = $("input[name='value']", $parent).val();
						var obj = {"key": e["key"], "value": value};
						values[i] = obj;
						updateField($field, values);
					});
				} else {
					addIconSelector($parent, e["value"], function(v) {
						var obj = {"key": e["key"], "value": v};
						values[i] = obj;
						updateField($field, values);
					});
				}
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

	
	function createTranslationButton($container, $valueField) {
		function createTranslationCallBack() {
			var key = $("#translationkey").val();
			var val  = $("#translationvalue").val();
			if(key && val) {
				var owner = "ActionPad_" + lbs.limeDataConnection.ActiveInspector.Class.Name;

				lbs.loader.createUpdateTranslation(owner, key, val, "sv");
				$valueField.val("localize." + owner + "." + key);
			}
			$("#addTranslationDialog").modal("hide");
		}

		var $framgment = $("<button class=\"btn translation\">Add translation</button>")
		$container.append($framgment);
		var $btn = $(".btn.translation", $container);
		$btn.hide();
		$btn.insertBefore($btn.prev());
		$btn.on("click", function() {
			$("#addTranslationButton").off("click");
			$("#addTranslationButton").on("click", createTranslationCallBack);

			$("#addTranslationDialog").modal("show");
		});
		return $btn;
	}

	function setupWizardForNewBinding($container) {
		var $valfield = $("input[name='value']", $container);
		addIconSelector($container, "", function(v) {
			$valfield.val(v);
		});
		var $btn = $(".btn.iconpicker", $container);
		$btn.hide();
		$btn.insertBefore($btn.prev());

		var $translationBtn = createTranslationButton($container, $valfield);

		$("input[name='key']", $container).on("keyup", function() {
			var $that = $(this);
			var val = $that.val();
			if(val === "icon") {
				$btn.show();
				$valfield.hide();
			} else if(val === "text") {
				$translationBtn.show();
			} else {
				$btn.hide();
				$translationBtn.hide();
				$valfield.show();
			}
		});
	}

	function setupAddButton($field) {
		var $container = $field.parent();
		var nodename = $field.data("nodename");
		if(nodename === "class") {
			$("i.fa-plus",$container.parent()).one("click", function() {
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
			$("i.fa-plus",$container.parent()).one("click", function() {
				var $fragment = $("<input type='text' name='key' placeholder='Key' /> <input type='text' name='value' placeholder='Value' /> <button class=\"addbtn\">Add</button>");
				$container.append($fragment);

				setupWizardForNewBinding($container);

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
		var $fragment = $("<div><strong>" + attr.nodeName + "</strong> <i class=\"fa fa-plus\" /><div><input class=\"field\" type='text' data-nodename=\""+ attr.nodeName +"\" value=\"" + attr.nodeValue + "\" /></div></div>");

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

	function createEditControlForElement(element, $container, syncChangesCb) {
		//TODO: avoid this?!
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

		saveChangesCb = function() {
			updateAttributeChanges(element, $container);
			syncChangesCb();
		};
	}

	return {
		createEditControlForElement: createEditControlForElement,
	};

})();
