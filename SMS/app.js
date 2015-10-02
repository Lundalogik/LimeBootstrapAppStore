lbs.apploader.register('SMS', function () {
    var self = this;

    /*Config (version 2.0)
        This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
        App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
        The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
    */
    self.config = function (appConfig) {
        this.yourPropertyDefinedWhenTheAppIsUsed = appConfig.yourProperty;
        this.dataSources = [{ type: 'xml', source: 'SMS.GetPersons', alias: 'root' }, { type: 'xml', source: 'SMS.GetTemplates', alias: 'SMSTemplsates' }, { type: 'xml', source: 'SMS.GetUsers', alias: 'SMSUsers' }];
        this.resources = {
            scripts: ['bootstrap-datetimepicker.js'], // <= External libs for your apps. Must be a file
            styles: ['app.css', 'bootstrap-datetimepicker.css'], // <= Load styling for the app.
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
    self.initialize = function (node, viewModel) {
        viewModel.newValue = ko.observable('');
        viewModel.inputvalue = ko.observable('');
        viewModel.personsList = ko.observableArray();
        viewModel.personcounter = ko.observable(0);
        viewModel.messagetype = ko.observable('');
        viewModel.showTemplates = ko.observable(false);
        viewModel.templates = ko.observableArray();
        viewModel.users = ko.observableArray();
        viewModel.activeuser = ko.observable('');

        viewModel.success = ko.observable(true);

        $('title').text('LIME Pro - SMS Module');

        function Person(person) {
            var newPerson = this;
            newPerson.name = person.name;
            newPerson.phone = (person.phone == null ? '' : person.phone);
            newPerson.isvisible = ko.observable(true);
            newPerson.id = person.idperson;

            newPerson.remove = function () {
                newPerson.isvisible(false);
                viewModel.personcounter(viewModel.personcounter() - 1);
            }

            return newPerson;
        }

        function Template(template) {
            var newTemplate = this;
            newTemplate.title = template.title;
            newTemplate.message = template.message;

            newTemplate.select = function () {
                viewModel.inputvalue(this.message);
            }
            return newTemplate
        }

        function User(user) {
            var newUser = this;
            newUser.username = user.username;
            newUser.idsmsuser = user.idsmsuser;
            newUser.default = user.default;

            if (user.default == "Ja") {
                viewModel.activeuser(user);
            }

            newUser.choice = function () {
                viewModel.activeuser(this);
            }

            return newUser;
        }

        this.template = ko.computed(function () {
            if (viewModel.messagetype() === 'Fritext') {
                viewModel.showTemplates(false);
                viewModel.inputvalue('');
            }
            else if (viewModel.messagetype() != '') {
                viewModel.showTemplates(true)
                viewModel.inputvalue('');
            }
        });
        try {
            if (Object.prototype.toString.call(viewModel.root.persons.person) === '[object Array]') {
                $.each(viewModel.root.persons.person, function (index, person) {
                    var p = new Person(person)
                    viewModel.personsList.push(p);
                });
            }
            else {
                var p = new Person(viewModel.root.persons.person)
                viewModel.personsList.push(p);
            }
        }
        catch (ex) {
            alert(ex);
        }
        try {
            if (Object.prototype.toString.call(viewModel.SMSTemplsates.templates.template) === '[object Array]') {
                $.each(viewModel.SMSTemplsates.templates.template, function (i, temp) {
                    var template = new Template(temp);
                    viewModel.templates.push(template);
                });
            }
            else {
                var template = new Template(viewModel.SMSTemplsates.templates.template);
                viewModel.templates.push(template);
            }
        }
        catch (ex) {
            console.log(ex);
        }

        try {
            if (Object.prototype.toString.call(viewModel.SMSUsers.users.user) === '[object Array]') {
                $.each(viewModel.SMSUsers.users.user, function (i, us) {
                    var user = new User(us);
                    viewModel.users.push(user);
                });
            }
            else {
                var user = new User(viewModel.SMSUsers.users.user);
                viewModel.users.push(user);
            }
        }
        catch (ex) {
            console.log(ex);
        }


        viewModel.personcounter(viewModel.personsList().length);

        $(".form_datetime").datetimepicker({
            format: "dd MM yyyy - hh:ii"
        });

        viewModel.close = function () {
            window.open('', '_parent', '');
            window.close();
        }

        viewModel.send = function () {            
            $.each(viewModel.personsList(), function (i, person) {
                try {
                    if (person.isvisible()) {
                        if (person.phone != '') {
                            var smsdata = person.id + ":" + strReplace(viewModel.inputvalue()) + ":" + person.phone + ":" + viewModel.activeuser().idsmsuser;
                            try {
                                lbs.common.executeVba("SMS.CreateSMS," + smsdata)
                                viewModel.success(true);
                                $('#myModal').modal('show');
                            }
                            catch (e) {
                                viewModel.success(false);
                                console.log(e);
                            }
                        }
                    }
                }
                catch (ex) {
                    console.log(ex);
                }
            });

            // 
            //
        }

        function strReplace(str) {

            var find = "'";
            var re = new RegExp(find, 'g');
            str = str.replace(re, '__%__');

            find = ",";
            re = new RegExp(find, 'g');
            str = str.replace(re, '__$__');


            str = str.replace(/\ /g, '____');
            str = str.replace(/(?:\r\n|\r|\n)/g, '<br />');
            return str;
        }

        return viewModel;
    };
});
