lbs.apploader.register('designer', function () {
    var self = this;
    //config
    self.config = {
        dataSources: [
            {type:'activeInspector', alias: "inspector"}
        ],
        resources: {
            scripts: ["js/bootstrap-iconpicker.js", "extensions.js", "editor.js", "parser.js", "appstore.js", "widget.js", "element.js"],
            styles: ["css/bootstrap-iconpicker.min.css", "designer.css"],
            libs: ["underscore-min.js"]
        }
    };

    function saveChanges() {
        lbs.loader.saveLocalFile(lbs.limeDataConnection.ActiveInspector.Class.Name+".html", btoa($("#template").text()));
    }

    //initialize
    self.initialize = function (node,viewModel) {
        editor.setup(viewModel.inspector);
        $("#template").text(lbs.loader.loadLocalFileToString(lbs.limeDataConnection.ActiveInspector.Class.Name+".html"));
        $("#SaveBtn").on("click", saveChanges);

        editor.load();

        return viewModel;
    }
});

