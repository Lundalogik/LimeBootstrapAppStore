lbs.apploader.register('cardcomplete', function () {
    var self = this;

    //config
    this.config = {
        dataSources: [
            { type: 'activeInspector' }
        ],

        cardcompletion: {
            tables: [{
                name: "company",
                fields: [{
                    name: "phone",
                    name_sv: "Telefon",
                    weight: 20
                },
                {
                    name: "www",
                    name_sv: "Hemsida",
                    weight: 10
                },
                {
                    name: "postaladdress1",
                    name_sv: "Postadress 1",
                    weight: 15
                },
                {
                    name: "postalzipcode",
                    name_sv: "Postnummer",
                    weight: 5
                },
                {
                    name: "postalcity",
                    name_sv: "Postort",
                    weight: 10
                },
                {
                    name: "registrationno",
                    name_sv: "Organisationsnummer",
                    weight: 30
                },
                {
                    name: "buyingstatus",
                    name_sv: "Kundstatus",
                    weight: 10
                }]
            },
            {
                name: "person",
                fields: [{
                    name: "phone",
                    name_sv: "Telefon",
                    weight: 25
                },
                {
                    name: "mobilephone",
                    name_sv: "Mobilnummer",
                    weight: 25
                },
                {
                    name: "email",
                    name_sv: "Epost",
                    weight: 40
                },
                {
                    name: "position",
                    name_sv: "titel",
                    weight: 10
                }]
            }]
        },

        resources: {
            scripts: [],
            styles: ['app.css'],
            libs: ['json2xml.js']
        }
    }

    //initialize
    this.initialize = function (node, viewModel) {

        //lbs.loader.loadDataSources(viewModel, this.config.dataSources, true)
        var activeInspector = lbs.loader.loadDataSources({}, [{ type: 'activeInspector', alias: 'activeInspector'}]).activeInspector;
        viewModel.incompleteFields = ko.observableArray();

        //Use this method to setup you app.
        //
        //The data you requested along with activeInspector are delivered in the variable viewModel.
        //You may make any modifications you please to it or replace is with a entirely new one before returning it.
        //The returned viewmodel will be used to build your app.
        var weighedSum = 0;
        var totalSum = 0;

        $.each(this.config.cardcompletion.tables, function (i, table) {
            if (lbs.activeClass == table.name) {
                $.each(table.fields, function (i, field) {
                    totalSum += field.weight;


                    if (activeInspector.hasOwnProperty(field.name)) {
                        if (eval("activeInspector." + field.name + ".text") != "") {
                            weighedSum += field.weight;
                        } else {
                            viewModel.incompleteFields.push(field);
                        }
                    }

                });

                viewModel.completePercent = Math.floor( weighedSum / totalSum * 100);
            }
        });

        viewModel.completionRate = ko.computed(function () {
            if (viewModel.completePercent <= 25) {
                return "low";
            }
            else if (viewModel.completePercent > 25 && viewModel.completePercent <= 50) {
                return "medium-low";
            }
            else if (viewModel.completePercent > 50 && viewModel.completePercent <= 75) {
                return "medium-high";
            }
            else if (viewModel.completePercent > 75) {
                return "high";
            }
        },this);

        viewModel.weighedSum = weighedSum;
        viewModel.totalSum = totalSum;

        return viewModel;
    }
});