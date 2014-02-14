module("parser")
test( "empty string should return empty object", function() {
	var parser = editor.parser.getParserForAttribute("data-bind");
	var result = parser("");
	deepEqual( result, [], "Passed!" );
});

test("should parse simple input",function() {
	var parser = editor.parser.getParserForAttribute("data-bind");
	var result = parser("text: foo.text");
	deepEqual( result, [{"key": "text", "value": "foo.text"}], "Passed!" );
});

test("should parse complex data-bind input",function() {
	var parser = editor.parser.getParserForAttribute("data-bind");
	var result = parser("visible: company.inactive.value === 1, text: company.name.text +' '+ localize.Actionpad_Company.inactive");
	deepEqual( result, [{"key": "visible", "value": "company.inactive.value === 1"}, {"key": "text", "value": "company.name.text +' '+ localize.Actionpad_Company.inactive"}], "Passed!" );
});

test("should parse class list",function() {
	var parser = editor.parser.getParserForAttribute("class");
	var result = parser("a b c");
	deepEqual( result, ["a", "b", "c"], "Passed!" );
});

test("should create class string from array", function() {
	var result = editor.parser.valuesToString(["a", "b", "c"]);
	equal(result, "a b c", "Passed!");
});

test("should create simple data-bind string", function() {
	var result = editor.parser.valuesToString([{"key": "text", "value": "foo.text"}]);
	equal(result, "text: foo.text", "Passed!");
});

test("should create complex data-bind string", function() {
	var result = editor.parser.valuesToString([{"key": "visible", "value": "company.inactive.value === 1"}, {"key": "text", "value": "company.name.text +' '+ localize.Actionpad_Company.inactive"}]);
	equal(result, "visible: company.inactive.value === 1, text: company.name.text +' '+ localize.Actionpad_Company.inactive");
});