lbs.apploader.register('LyncConnector', function() {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config = function(appConfig) {
        this.appConfig = appConfig;
        this.dataSources = [{
            type: 'activeInspector'
        }, {
            type: 'relatedRecord',
            source: 'coworker',
            view: 'email;name'
        }];
        this.resources = {
            scripts: [], // <= External libs for your apps. Must be a file
            styles: ['app.css'], // <= Load styling for the app.
            libs: [] // <= Allready included libs, put not loaded per default. Example json2xml.js
        };
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
    self.initialize = function(node, vm) {
        var nameCtrl;
        vm.appType = self.config.appConfig.appType;
        vm.hasLyncConnection = ko.observable(false);
        vm.presenceClass = ko.observable('');
        vm.presenceColor = ko.observable('');
        vm.presenceText = ko.observable('');
        vm.coworkerObject = ko.observable({});
        var pathArray;
        var tmpObj = vm;
        var coworkerPropertyName = self.config.appConfig.coworkerPropertyName || 'coworker';

        if (self.config.appConfig.coworkerPropertyPath) {
            pathArray = self.config.appConfig.coworkerPropertyPath.split('.');
            for (var i = 0, max = pathArray.length; i < max; i += 1) {
                tmpObj = tmpObj[pathArray[i]];
            }
            if (tmpObj[coworkerPropertyName]) {
                vm.coworkerObject(tmpObj[coworkerPropertyName]);
            }
        } else {
            vm.coworkerObject(vm[coworkerPropertyName]);
        }

        function initLync() {
            vm.showLyncPresencePopup = function(data, event) {
                showLyncPresencePopup(vm.coworkerObject().email.value, $(event.target));
            };
            vm.hideLyncPresencePopup = function() {
                hideLyncPresencePopup();
            };

            if (nameCtrl) {
                nameCtrl.GetStatus(vm.coworkerObject().email.value, 'users');
                vm.hasLyncConnection(true);
            }
        }

        function IsSupportedNPApiBrowserOnWin() {
            return true; // SharePoint does this: IsSupportedChromeOnWin() || IsSupportedFirefoxOnWin()
        }

        function IsNPAPIOnWinPluginInstalled(a) {
            return Boolean(navigator.mimeTypes) && navigator.mimeTypes[a] && navigator.mimeTypes[a].enabledPlugin
        }

        function createNPApiOnWindowsPlugin(b) {
            var c = null;
            if (IsSupportedNPApiBrowserOnWin())
                try {
                    c = document.getElementById(b);
                    if (!Boolean(c) && IsNPAPIOnWinPluginInstalled(b)) {
                        var a = document.createElement("object");
                        a.id = b;
                        a.type = b;
                        a.width = "0";
                        a.height = "0";
                        a.style.setProperty("visibility", "hidden", "");
                        document.body.appendChild(a);
                        c = document.getElementById(b);
                    }
                } catch (d) {
                    c = null;
                }
            return c;
        }

        function showLyncPresencePopup(userName, target) {
            if (!nameCtrl) {
                return;
            }

            var eLeft = $(target).offset().left;
            var x = eLeft - $(window).scrollLeft();

            var eTop = $(target).offset().top;
            var y = eTop - $(window).scrollTop();

            nameCtrl.ShowOOUI(userName, 0, x, y);
        }

        function hideLyncPresencePopup() {
            if (!nameCtrl) {
                return;
            }
            nameCtrl.HideOOUI();
        }

        function getLyncPresenceString(status) {
            var result = {
                color: '',
                cssClass: '',
                text: ''
            };

            switch (status) {
                case 0:
                    result.color = '#5DD255';
                    result.cssClass = 'available';
                    result.text = 'Available';
                    break;
                case 1:
                    result.color = '#999999';
                    result.cssClass = 'offline';
                    result.text = 'Offline';
                    break;
                case 2:
                case 4:
                case 16:
                    result.color = '#FFD200';
                    result.cssClass = 'away';
                    result.text = 'Away';
                    break;
                case 3:
                case 5:
                    result.color = '#D00E0D';
                    result.cssClass = 'inacall';
                    result.text = 'In a call';
                    break;
                case 6:
                case 7:
                case 8:
                case 10:
                    result.color = '#D00E0D';
                    result.cssClass = 'busy';
                    result.text = 'Busy';
                    break;
                case 9:
                case 15:
                    result.color = '#D00E0D';
                    result.cssClass = 'donotdisturb';
                    result.text = 'Do not disturb';
                    break;
                case 18:
                    result.color = '#D00E0D';
                    result.cssClass = 'presenting';
                    result.text = 'Presenting';
                    break;
            }

            return result;
        }

        function attachLyncPresenceChangeEvent() {
            if (!nameCtrl) {
                return;
            }
            nameCtrl.OnStatusChange = onLyncPresenceStatusChange;
        }

        function onLyncPresenceStatusChange(userName, status, id) {
            statusObj = getLyncPresenceString(status);
            vm.presenceClass(statusObj.cssClass);
            vm.presenceColor(statusObj.color);
            vm.presenceText(statusObj.text);
        }

        var coworkerObject = vm.coworkerObject && vm.coworkerObject() || {};
        if (coworkerObject.email && coworkerObject.email.value) {
            try {
                if (window.ActiveXObject) {
                    nameCtrl = new ActiveXObject("Name.NameCtrl");
                } else {
                    nameCtrl = createNPApiOnWindowsPlugin("application/x-sharepoint-uc");
                }
                attachLyncPresenceChangeEvent();
            } catch (ex) {}

            initLync();
        }

        return vm;
    };
});
