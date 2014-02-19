lbs.apploader.register('designer', function () {
    var self = this;
    //config
    self.config = {
        dataSources: [
            {type:'activeInspector', alias: "inspector"}
        ],
        resources: {
            scripts: ["extensions.js", "editor.js", "parser.js", "appstore.js", "widget.js", "element.js"],
            styles: ["designer.css"],
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

