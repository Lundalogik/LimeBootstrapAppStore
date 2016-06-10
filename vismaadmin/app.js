lbs.apploader.register('vismaadmin', function () {
    var self = this;

    /*Config (version 2.0)
     This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
     App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
     The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
     */
    self.config = function (appConfig) {
        this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
        this.dataSources = [{type: 'activeInspector', alias: 'company'}];
        this.resources = {
            scripts: [], // <= External libs for your apps. Must be a file
            styles: ['app.css'], // <= Load styling for the app.
            libs: [] // <= Allready included libs, put not loaded per default. Example json2xml.js
        };
        this.vismaUrl = appConfig.vismaUrl; //applied from the app config
    };

    //initialize
    /*Initialize
     Initialize happens after the data and recources are loaded but before the view is rendered.
     Here it is your job to implement the logic of your app, by attaching data and functions to 'viewModel' and then returning it
     The data you requested along with localization are delivered in the variable viewModel.
     You may make any modifications you please to it or replace is with a entirely new one before returning it.
     The returned viewModel will be used to build your app.

     Node is a reference to the HTML-node where the app is being initalized form. Frankly we do not know when you'll ever need it,
     but, well, here you have it.
     */

    self.initialize = function (node, viewModel) {

        //Check if it is a company with an exisiting ID, this is used in the VBA function Visma.SendToVisma
        viewModel.newCompany = ko.observable(false);
        viewModel.vismaTurnOverThisYear = ko.observable("0");
        viewModel.vismaTurnOverLastYear = ko.observable("0");
        viewModel.hasTurnOver = ko.observable(false);
        viewModel.vismaUrl = self.config.vismaUrl;

        if (viewModel.company.visma_turnover_yearnow.text !== "0") {
            viewModel.hasTurnOver(true);
            viewModel.vismaTurnOverThisYear(viewModel.company.visma_turnover_yearnow.text);
            viewModel.vismaTurnOverLastYear(viewModel.company.visma_turnover_lastyear.text);
        }

        if (viewModel.company.vismaid.text !== '') {
            viewModel.newCompany(false);
        } else {
            viewModel.newCompany(true);
        }

        viewModel.sendToVisma = function () {
            // DO validation
            if (lbs.common.executeVba('Visma.CheckValidate') === true){

                //Call the VBA function Visma.SentToVisma with the array and newCompany variable
                var VismaResponse = lbs.common.executeVba('Visma.SendToVisma,' + viewModel.vismaUrl + ',' + viewModel.newCompany());

                //Make a JSON from the response from VBA in order to get the vismaid (Number)
                if (!VismaResponse || VismaResponse.status === 404 || VismaResponse === "") {

                    alert('Vi kunde för närvarande inte hämta kundinformation från Visma Administration.');
                } else {
                    VismaResponse = JSON.parse(VismaResponse);
                     //Save vismaid (Number) to field-vismaid in LIME Pro
                    if (VismaResponse.Number !== "") {  
                        lbs.limeDataConnection.ActiveInspector.Controls.SetValue('vismaid', VismaResponse.Number);
                        lbs.limeDataConnection.ActiveInspector.Controls.SetValue('visma_turnover_yearnow', VismaResponse.AccumulateTurnoverThisYear);
                        lbs.limeDataConnection.ActiveInspector.Controls.SetValue('visma_turnover_lastyear', VismaResponse.AccumulateTurnoverLastYear);
                        lbs.limeDataConnection.ActiveInspector.Save();
                        lbs.limeDataConnection.ActiveInspector.WebBar.Refresh();
                    }
                }
            }
        };
        return viewModel;
    };
});