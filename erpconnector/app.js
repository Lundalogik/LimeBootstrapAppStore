lbs.apploader.register('erpconnector', function () {
    var self = this;

    /*Config (version 2.0)
     This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
     App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
     The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
     */
    self.config = function (appConfig) {
        this.view = appConfig.view || 'actionpad';
        this.groupOptions = appConfig.groupOptions || [
            {
                value: 'month',
                text: 'viewModel.localize.ERPConnector.months'
            },
            {
                value: 'quarter',
                text: 'viewModel.localize.ERPConnector.quarters'
            }
        ];
        this.thousandSeparator = appConfig.thousandSeparator || ' ';
        this.currency = appConfig.curreny || 'SEK'
        this.dataSources = [{type: 'activeInspector', alias: 'company'}];
        this.resources = {
            scripts: ['/scripts/chart.js', '/scripts/utils.js'], // <= External libs for your apps. Must be a file
            styles: ['app.css'], // <= Load styling for the app.
            libs: ['underscore-min.js'] // <= Allready included libs, put not loaded per default. Example json2xml.js
        };
        this.erpUrl = appConfig.erpUrl; //applied from the app config
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
        viewModel.view = ko.observable(self.config.view);
        
        //Check if it is a company with an exisiting ID, this is used in the VBA function Erp.SendToErp
        // Actionpad specific variables
        viewModel.newCompany = ko.observable(false);
        viewModel.erpTurnOverThisYear = ko.observable("0");
        viewModel.erpTurnOverLastYear = ko.observable("0");
        viewModel.hasTurnOver = ko.observable(false);
        viewModel.erpUrl = self.config.erpUrl;

        if (viewModel.company.erp_turnover_yearnow.text !== "0") {
            viewModel.hasTurnOver(true);
            viewModel.erpTurnOverThisYear(viewModel.company.erp_turnover_yearnow.text);
            viewModel.erpTurnOverLastYear(viewModel.company.erp_turnover_lastyear.text);
        }

        viewModel.newCompany(viewModel.company.erpid.text === '');
    

        viewModel.sendToERP = function () {
            // DO validation
            if (lbs.common.executeVba('ERPConnector.CheckValidate') === true){

                //Call the VBA function Erp.SentToErp with the array and newCompany variable
                var ErpResponse = lbs.common.executeVba('ERPConnector.SendToErp,' + viewModel.erpUrl + ',' + viewModel.newCompany());

                //Make a JSON from the response from VBA in order to get the vismaid (Number)
                if (!ErpResponse || ErpResponse.status === 404 || ErpResponse === "") {

                    alert('Vi kunde för närvarande inte hämta kundinformation från ERP-system.');
                } else {
                    ErpResponse = JSON.parse(ErpResponse);
                     //Save erpid (Number) to field-erpid in Lime CRM
                    if (ErpResponse.Number !== "") {  
                        lbs.limeDataConnection.ActiveInspector.Controls.SetValue('erpid', ErpResponse.Number);
                        lbs.limeDataConnection.ActiveInspector.Controls.SetValue('erp_turnover_yearnow', ErpResponse.AccumulateTurnoverThisYear);
                        lbs.limeDataConnection.ActiveInspector.Controls.SetValue('erp_turnover_lastyear', ErpResponse.AccumulateTurnoverLastYear);
                        lbs.limeDataConnection.ActiveInspector.Save();
                        lbs.limeDataConnection.ActiveInspector.WebBar.Refresh();
                    }
                }
            }
        };


        // Dashboard specific variables
        viewModel.jsonData = {};
        viewModel.currency = self.config.currency;
        viewModel.thousandSeparator = self.config.thousandSeparator;
        viewModel.months = ko.observableArray();
        viewModel.quarters = ko.observableArray();
        viewModel.groupBy = ko.observable('month');
        viewModel.showChart = ko.observable();
        viewModel.legends = ko.observable();
        viewModel.groupOptions = ko.observableArray(ko.utils.arrayMap(self.config.groupOptions, function(option) {
            return new utils.GroupOption(option, viewModel);
        }));
        viewModel.groupBy.subscribe(function() {
            viewModel.initChart();
        });
        var datasets = [];
        var chart;
        var ctx = document.getElementById('chart').getContext('2d');

        viewModel.getInvoiceData = function() {
            $('body').addClass('dashboard');
            lbs.loader.loadDataSource (
                viewModel.jsonData,
                {type: 'records', source: 'ERPConnector.GetInvoiceData'},
                true
            );
            viewModel.initChart();
            viewModel.showChart(_.filter(datasets, function(dataset) { return !_.isEmpty(dataset)}).length !== 0);
        }
        viewModel.initChart = function() {
            if(chart) {
                chart.destroy();
            }
            viewModel.months(ko.utils.arrayMap(_.range(0, 12), function(nbr) {
                return moment(nbr + 1,'MM').format('MMMM');
            }));

            viewModel.quarters(ko.utils.arrayMap(_.range(0,4), function(nbr) {
                return 'Q' + (nbr+1);
            }));

            var years = _.map(_.map(_.range(0, 4), function(nbr) {
                return moment().add(-nbr,'years').format('YYYY')
            }), function(year) {
                return _.map((viewModel.groupBy() === 'month' ? viewModel.months() : viewModel.quarters()) , function(m){ return 0; });
            });
           
            _.each(viewModel.jsonData.invoice.records, function(invoice) {
                var yearsAgo = moment().diff(moment(invoice.paid_date.text).format('YYYY'), 'years');
                if(years[yearsAgo]){
                    var value = invoice.invoice_total_sum.value ? invoice.invoice_total_sum.value : 0;
                    switch(viewModel.groupBy()){
                        case 'month':
                            
                            years[yearsAgo][parseInt(moment(invoice.paid_date.text).format('MM')) - 1] += value;
                            break;
                        case 'quarter':
                            years[yearsAgo][Math.floor(moment(invoice.paid_date.text).month() / 3)] += value;
                            break;
                    }
                }
            });

            var i = -1;
            datasets = _.map(years, function(year) {
                i = i + 1;
                var sum = parseInt(_.reduce(year, function(a,b) { return a + b}));
                
                return sum > 0 ? {
                    label: moment().add(-i,'years').format('YYYY'),
                    fill: true,
                    hidden: false,
                    sum: sum,
                    index: i,
                    lineTension: 0.2,
                    backgroundColor: utils.colors[i].chartBackground,
                    borderColor: utils.colors[i].chartBorder,
                    borderCapStyle: 'butt',
                    borderJoinStyle: 'miter',
                    pointBorderColor: utils.chartBorder,
                    pointBackgroundColor: '#fff',
                    pointBorderWidth: 1,
                    pointHoverRadius: 5,
                    pointHoverBackgroundColor: '#fff',
                    pointBorderColor: utils.colors[i].chartBorder,
                    pointHoverBorderWidth: 2,
                    pointRadius: 1,
                    pointHitRadius: 10,
                    data: year,
                    spanGaps: false
                } : {};
            });
            

            var options = {
                scales: {
                    yAxes: [{
                        ticks: {
                            callback: function(value) {
                                return utils.prettyNumber(value, viewModel.thousandSeparator);
                            }
                        }
                    }]
                },
                tooltips: {
                    callbacks: {
                        label: function(tooltipItem, data) {
                            return utils.prettyNumber(tooltipItem.yLabel, viewModel.thousandSeparator, viewModel.currency);
                        },
                        title: function(tooltipItem, data) {
                            return data.datasets[tooltipItem[0].datasetIndex].label + ' - ' + tooltipItem[0].xLabel;
                        }
                    }
                },
                legend: false,
                legendCallback: function(chart) {
                    viewModel.legends(ko.utils.arrayMap(chart.data.datasets, function(dataset, index) {
                        return {
                            label: dataset.label,
                            sum: dataset.sum,
                            backgroundColor: utils.colors[dataset.index].legendBackground,
                            color: utils.colors[dataset.index].legendText,
                            tooltip: viewModel.localize.ERPConnector.total + ': ' + utils.prettyNumber(dataset.sum, viewModel.thousandSeparator, viewModel.currency)
                        }
                    }).reverse());
                }
            }

            var data = {
                labels: viewModel.groupBy() === 'month' ? viewModel.months() : viewModel.quarters(),
                datasets: _.filter(datasets, function(dataset) { return !_.isEmpty(dataset)})
            }
            chart = new Chart(ctx, {
                type: 'line',
                data: data,
                options: options
            });
            chart.generateLegend();


        }


        if(viewModel.view() === 'dashboard') {
            viewModel.getInvoiceData();    
        }
        
        return viewModel;
    };
});