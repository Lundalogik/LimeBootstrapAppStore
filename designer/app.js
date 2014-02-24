lbs.apploader.register('designer', function () {
    var self = this;
    //config
    self.config = {
        dataSources: [
            {type:'activeInspector', alias: "inspector"}
        ],
        resources: {
            scripts: ["lib/bootstrap-iconpicker.js", "js/extensions.js", "js/editor.js", "js/parser.js", "js/appstore.js", "js/widget.js", "js/element.js"],
            styles: ["css/bootstrap-iconpicker.min.css", "css/designer.css"],
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

