lbs.apploader.register('GetAccept', function () { //Insert name of app here            
    var self = this;
    self.config = function (appConfig) {
        this.appConfig = appConfig;
        this.dataSources = [
            { type: 'activeInspector' }
        ];
        this.resources = {
            scripts: [],
            styles: ['app.css'],
            libs: []
        };
    };
    self.initialize = function (node, viewModel) {
        var appConfig = self.config.appConfig;
        viewModel.config = appConfig;

        var authEndpoint = "https://dev.getaccept.com/api";
        var apiEndpoint = "https://dev.getaccept.com/api";

        var clientId = "Lime";
        var entityId = "";
        var userHash = "";

        var tokenHandler = "";
        var requestToken = "";
        var accessToken = "";
        var contact_json;
        var refreshToken = "";
        var expireToken = "";

        // Nya globala variabler
        var className = lbs.limeDataConnection.ActiveInspector.Class.name;
        var class_id = 'id' + className;


        viewModel.type = ko.observable();
        viewModel.document_list = ko.observableArray();
        viewModel.signer_list = ko.observableArray();
        viewModel.signer_filter = ko.observable('');
        viewModel.selected_signer = ko.observableArray();
        viewModel.cc_list = ko.observableArray();
        viewModel.selected_cc = ko.observableArray();
        viewModel.entity_list = ko.observableArray();
        //viewModel.recipients = ko.observableArray();
        viewModel.send_json = ko.observableArray();
        viewModel.login_verified = ko.observable();
        viewModel.class_name = ko.observable();

        viewModel.class_name = className;

        viewModel.signer_filtered_list = ko.computed(function() {
            var filter = viewModel.signer_filter();
            if (!filter) { return viewModel.signer_list(); }
            return viewModel.signer_list().filter(function(i) { return i.name.toLowerCase().indexOf(filter.toLowerCase()) > -1; });
        });
        
        if (appConfig.type === undefined) {
            viewModel.type("list");
        }
        else {
            viewModel.type(appConfig.type);
        }

        viewModel.send_json = {
            name: ''
        };

        openModal = function () {
            
            var got_token = lbs.common.executeVba("GetAccept.OpenGetAccept," + className + ',' + appConfig.personSourceTab + ',' + appConfig.personSourceField);
            if (got_token == '-1') {
                //No document selected - do nothing
            }
            else  if (got_token != '') {
                saveToken(JSON.parse(got_token));
                //viewModel.login_verified = true;
                document.location = document.location;
            }
            else {
                //viewModel.login_verified = true;
                logoutSession();
                document.location = document.location;
            }
        }

        createDocument = function () {
             
            var document_name = lbs.common.executeVba("GetAccept.GetDocumentDescription," + className);
            var external_id = lbs.common.executeVba("GetAccept.GetDocumentId," + className);

            document_name = document_name.replace(/\.[^/.]+$/, "");
            document_name = document_name.replace(/\.|\_|\-/g, ' ');
            if (document_name == document_name.toLowerCase()) {
                document_name = document_name.replace(/\b[a-zA-Z\u00C0-\u00ff]/g, function (letter) {
                    return letter.toUpperCase();
                });
            }
            
            var deal_value="";
            var deal_name="";
            var comany_name="";

            if(className == "business"){                                
                
                //deal_value = eval('viewModel.' + className + '.businessvalue' + '.text');

                deal_value = eval('viewModel.' + className + '.' + appConfig.businessValue+'.value');
                deal_name = eval('viewModel.' + className + '.name.text');
                company_name = eval('viewModel.' + className + '.company.text');
            }
            else if(className == "company"){                
                company_name = eval('viewModel.' + className + '.name.text');
            }
            
            
            //deal_value = deal_value.replace(',', '');
            viewModel.send_json = {
                name: document_name,
                file_ids: '',
                type: 'sales',
                value: deal_value,
                external_id: external_id,
                recipients: [],
                company_name: company_name,
                is_automatic_sending: true
            };
            listContacts();
        }

        uploadDocument = function (callback) {
            var document_data = lbs.common.executeVba("GetAccept.GetDocumentData," + className);
            var document_name = lbs.common.executeVba("GetAccept.GetDocumentDescription," + className)
            alert(document_name);;
            var json = {
                file_name: document_name,
                file_content: document_data
            };

            apiRequest('upload', 'POST', json, function (data) {
                viewModel.send_json["file_ids"] = data.file_id;
                if (callback) {
                    callback();
                }
            });
        }

        

        sendDocument2 = function () {
            alert(JSON.stringify(viewModel.send_json));
        }
        sendDocument = function () {
            if (viewModel.selected_signer.length > 0 || viewModel.selected_cc.length > 0) {
                $('.win-loading').removeClass('hidden');
                $('.win-document').addClass('hidden');
                $('.win-loading h1').text(viewModel.localize.GetAccept.ga_uploading_document+'...');
                var timerId = setInterval(function () {
                    if ($('.win-loading .progress-bar').width() < $('.win-loading .progress-bar').parent().width()) {
                        $('.win-loading .progress-bar').css('width', $('.win-loading .progress-bar').width() + 20);
                    }
                    else {
                        clearInterval(timerId);
                    }
                }, 200);

                uploadDocument(function () {
                    //Get contacts
                    var recipients = [];
                    var have_signer = false;
                    var have_cc = false;
                    for (var contact in contact_json.Persons) {
                        if ($.inArray(contact_json.Persons[contact].email, viewModel.selected_signer) > -1) {
                            if (contact_json.Persons[contact].email) {
                                recipients.push({
                                    email: contact_json.Persons[contact].email,
                                    first_name: contact_json.Persons[contact].firstname,
                                    last_name: contact_json.Persons[contact].lastname,
                                    mobile: contact_json.Persons[contact].mobilephone,
                                    role: 'signer'
                                });
                                have_signer = true;
                            }
                        }
                        if ($.inArray(contact_json.Persons[contact].email, viewModel.selected_cc) > -1) {
                            if (contact_json.Persons[contact].email) {
                                recipients.push({
                                    email: contact_json.Persons[contact].email,
                                    first_name: contact_json.Persons[contact].firstname,
                                    last_name: contact_json.Persons[contact].lastname,
                                    mobile: contact_json.Persons[contact].mobilephone,
                                    role: 'cc'
                                });
                                have_cc = true;
                            }
                        }
                    }
                    if (have_signer){
                        viewModel.send_json["is_signing"] = true;
                    }
                    else if (have_cc && !have_signer){
                        viewModel.send_json["is_signing"] = 0;
                    }
                    viewModel.send_json.recipients = recipients;

                    $('.win-loading h1').text(viewModel.localize.GetAccept.ga_creating_document+'...');
                    apiRequest('documents', 'POST', viewModel.send_json, function (data) {
                        //console.log(data);
                        if (viewModel.send_json.is_automatic_sending == true) {
                            $('.win-loading h1').text(viewModel.localize.GetAccept.ga_sending_document+'...');
                        }

                        setTimeout(function () {
                            lbs.common.executeVba("GetAccept.SetDocumentStatus," + 1 + ',' + className);
                            if (viewModel.send_json.is_automatic_sending == false) {
                                //Open GA in new window
                                var docUrl = '/document/' + (data.status == 'draft' ? 'edit' : 'view') + '/' + data.id;
                                var sso_url = 'https://app.getaccept.com/auth/sso/login?token=' + escape(accessToken) + '&entity_id=' + entityId + '&go=' + escape(docUrl);
                                lbs.common.executeVba("GetAccept.OpenGALink", sso_url);
                            }
                            else {
                                //logga historik. skicka in vilken klass kör från för att göra den dynamisk
                                //lbs.common.executeVba("GetAccept.OpenGALink",sso_url);
                            }
                            //stäng fönstret 
                            window.open('', '_parent', '');
                            window.close();
                        }, 5000);
                    });
                });
            }
            else {
                alert(viewModel.localize.GetAccept.ga_least_one_recipient);
            }
        }

        openDocument = function () {
            viewModel.send_json.is_automatic_sending = false;
            sendDocument();
        }

        listContacts = function () {
            var contacts = lbs.common.executeVba("GetAccept.GetContactList," + className);
            if (contacts){
                contact_json = JSON.parse(contacts);
                $.each(contact_json.Persons, function (index, person) {
                    var pers = new personFactory(person)
                    viewModel.signer_list.push(pers);
                });

                //personFactory(JSON.parse(contacts))          
                //viewModel.signer_list = 
                viewModel.cc_list = contact_json.Persons;
                viewModel.selected_signer = [];
                // Plockade bort denna. 
                //viewModel.selected_signer = [ viewModel.contact.email.text ];            
                viewModel.selected_cc = [];

            }
            else{
                alert(viewModel.localize.GetAccept.ga_least_one_contact);
            }
        }

        getStatus = function(status){
            return viewModel.localize.GetAccept['ga_'+status];
        }

        personFactory = function (person) {
            var pers = this;
            pers.name = person.firstname + ' ' + person.lastname;
            pers.email = person.email;
            pers.mobilephone = person.mobilephone;
            pers.signer = ko.observable(false);
            pers.cc = ko.observable(false);            

            //kanske kan ta bort denna
            pers.setSigner = function (person) {
                //var signer = (pers.signer() ? true:false);                     
                if (viewModel.selected_signer.indexOf(person.email) < 0) {
                    viewModel.selected_signer.push(person.email);
                }
                else {
                    //viewModel.selected_cc.remove(person.email); 
                    ko.utils.arrayRemoveItem(viewModel.selected_signer, person.email)
                }
                return true;
            }

            pers.setCC = function (person) {               
                if (viewModel.selected_cc.indexOf(person.email) < 0) {
                   viewModel.selected_cc.push(person.email);                   
                }
                else {                    
                    //viewModel.selected_cc.remove(person.email); 
                    ko.utils.arrayRemoveItem(viewModel.selected_cc, person.email)                                    
                }                
                return true;
            }

            return pers;

        }

        checkDocuments = function () {
            //Ändrade här skickar in class_id istället för idbussiniss samt la till vilken class man är på            
            var active_record_id = lbs.limeDataConnection.ActiveInspector.Controls.GetValue(class_id);
            //alert(external_id);      
            var document_ids = lbs.common.executeVba("GetAccept.CheckDocuments," + active_record_id + ',' + className);
            if (document_ids) {
                //alert(document_ids);
                listDocuments(document_ids);
            }
        }

        initPush = function () {
            //Add to scripts 'pusher.min.js'
            userHash = lbs.bakery.getCookie("userHash");
            if (userHash) {
                var pusher = new Pusher('d3f332f9b68a9e71641e', {
                    encrypted: true,
                    //authEndpoint: 'https://dev.getaccept.com/pusher/auth'
                });
                var pusherChannel = pusher.subscribe('private-user_' + userHash);
                //alert('init private-user_'+userHash);
                pusherChannel.bind('document.commented', function (data) {
                    alert(JSON.stringify(data));
                    //document.location=document.location;
                });
                pusherChannel.bind('document.viewed', function (data) {
                    alert(JSON.stringify(data));
                    //document.location=document.location;
                });

            }
        }

        saveDocument = function () {
            var document_id = this.id;
            var documentname = this.name;
            
            //Use parameter direct,  /download?direct=true to get binary content back
            //This can later be processed in VBA to store file in Lime
            apiRequest('documents/' + document_id + '/download', 'GET', '', function (data) {
                if (typeof (data.document_url) != 'undefined') {                    
                    lbs.common.executeVba("GetAccept.DownloadFile," + data.document_url + ',' + documentname + ',' + className + ',' + appConfig.title_field);
                }
                else {
                    alert('Could not find signed document');
                }
            });
        }

        listDocuments = function (document_ids) {
            getToken();
            //var external_id = lbs.limeDataConnection.ActiveInspector.Controls.GetValue(class_id);
            //alert(document_ids);
            //alert(accessToken);
            var list_data = [];
            if (document_ids && accessToken) {
                apiRequest('documents?external_id=' + document_ids, 'GET', '', function (data) {
                    if (data) {
                        if (data.length > 0) {
                            $.each(data, function (i, item) {
                                var docUrl = '/document/' + (item.status == 'draft' ? 'edit' : 'view') + '/' + item.id;
                                var sso_url = 'https://app.getaccept.com/auth/sso/login?token=' + escape(accessToken) + '&entity_id=' + entityId + '&go=' + escape(docUrl);
                                list_data.push({ id: item.id, name: item.name, status: item.status, sso_url: sso_url, is_signing: item.is_signing });
                                //alert(JSON.stringify(viewModel.document_list));
                            });

                        }
                        else {
                            //    var docUrl = '/document/'+(data.status=='draft' ? 'edit':'view')+'/'+data.id;
                            //    var sso_url = 'https://app.getaccept.com/auth/sso/login?token='+escape(accessToken)+'&entity_id='+entityId+'&go='+escape(docUrl);
                            //    viewModel.document_list.push( { name: data.name, status: data.status, sso_url: sso_url } );
                        }
                    }
                    viewModel.document_list.removeAll();
                    ko.utils.arrayPushAll(viewModel.document_list, list_data)
                });
            }
            // VARFÖR DENNA? 
            //var contact_list = lbs.common.executeVba("GetAccept.GetContactList");
        }

        selectEntity = function () {
            //alert(JSON.stringify(this));
            entityId = this.entity_id;
            userHash = this.user_hash;
            lbs.bakery.setCookie("entityId", entityId, 30);
            lbs.bakery.setCookie("userHash", userHash, 30);
            tokenHandler.entity_id = entityId;
            tokenHandler.user_hash = userHash;
            apiRequest('refresh/' + entityId, 'GET', '', function (data) {
                data.entity_id = entityId;
                data.user_hash = userHash;
                //alert(JSON.stringify(data));
                saveToken(data);
                //checkLogin();
                document.location = document.location;
            });

        }

        listEntities = function () {
            if (!entityId) {
                apiRequest('users/me', 'GET', '', function (data) {
                    //alert(JSON.stringify(data));
                    if (typeof data.entities != 'undefined') {
                        if (data.entities.length == 1) {
                            entityId = data.entities[0].id;
                            userHash = data.user.id;
                            lbs.bakery.setCookie("entityId", entityId, 30);
                            lbs.bakery.setCookie("userHash", userHash, 30);
                            tokenHandler.entity_id = entityId;
                            tokenHandler.user_hash = userHash;
                            createDocument();
                        } else {
                            //viewModel.entity_list = data.entities;
                            $.each(data.entities, function (i, item) {
                                viewModel.entity_list.push({ entity_name: item.name, entity_id: item.id, user_hash: data.user.id });
                            });
                            $('.win-entity').removeClass('hidden');
                        }
                    }
                });
            }
        }

        checkLogin = function () {
            getToken();
            var nowSec = Math.ceil(new Date().getTime() / 1000);
            if (expireToken && (expireToken - ((expireToken - nowSec) / 2)) > nowSec) {
                //Have token
                $('.win-auth').addClass('hidden');
                $('.win-entity').addClass('hidden');
                if (entityId) {
                    $('.win-document').removeClass('hidden');
                    createDocument();
                }
                else {
                    listEntities();
                }

            }
            else if (expireToken) {
                //TODO: Refresh token after half expiry
                apiRequest('refresh/' + entityId, 'GET', '', function (data) {
                    data.entity_id = entityId;
                    saveToken(data);
                    createDocument();
                });

                //var entityId = appConfig['entityId'] ? appConfig['entityId'] : null
                /*
                $http({method: "GET", url: apiEndpoint+"/v1/refresh"+(entityId ? '/'+entityId : ''), headers: { 'Authorization': 'Bearer '+accessToken } })
                     .success(function(data) {
                        saveToken(data);
                     })
                     .error(function(data, status) {
                        //$scope.data.error = "ERROR: " + data.error_description;
                     });
                */
            }
            else if (accessToken) {
                $('.win-document').removeClass('hidden');
                $('.win-auth').addClass('hidden');
                createDocument();
            }
            else {
                $('.win-document').addClass('hidden');
                $('.win-auth').removeClass('hidden');
            }

        }

        loginForm = function (email, password) {
            var postUrl = authEndpoint + "/v1/auth";
            //console.log(postUrl);
            var xhr = new XMLHttpRequest();
            xhr.open('POST', postUrl, true);
            xhr.setRequestHeader('Content-type', 'application/json');
            xhr.onreadystatechange = function () {
                // If the request completed
                if (xhr.readyState == 4) {
                    status = xhr.status;
                    if (status == 200) {
                        data = JSON.parse(xhr.responseText);
                        saveToken(data);
                        checkLogin();
                    }
                    else {
                        data = JSON.parse(xhr.responseText);
                        alert(data.error);
                    }
                }
            };
            var json = '{ "email": "' + email + '","password": "' + password + '", "client_id": "' + clientId + '" }';
            xhr.send(json);
        }

        function apiRequest(action, method, json, callback) {
            var postUrl = apiEndpoint + "/v1/" + action;
            var xhr = new XMLHttpRequest();
            xhr.open(method, postUrl, true);
            xhr.setRequestHeader('Content-type', 'application/json');
            xhr.setRequestHeader('Authorization', 'bearer ' + accessToken);
            xhr.onreadystatechange = function () {
                // If the request completed
                if (xhr.readyState == 4) {
                    status = xhr.status;
                    if (status == 200) {
                        callback(JSON.parse(xhr.responseText));
                    }
                    else {
                        callback(false);
                    }
                }
            };
            if (json) {
                xhr.send(JSON.stringify(json));
            }
            else {
                xhr.send();
            }
        }

        initControls = function () {
            $('.win-auth form').on('submit', function (event) {
                loginForm($(this).find('#email').val(), $(this).find('#password').val());
                event.preventDefault();
            });
        }

        logoutSession = function () {
            accessToken = "";
            refreshToken = "";
            expireToken = "";
            lbs.bakery.setCookie("accessToken", null, -1);
            lbs.bakery.setCookie("refreshToken", null, -1);
            lbs.bakery.setCookie("expireToken", null, -1);
            lbs.bakery.setCookie("entityId", null, -1);
            lbs.bakery.setCookie("userHash", null, -1);

            $('.win-document').addClass('hidden');
            $('.win-auth').removeClass('hidden');
            viewModel.login_verified = false;
            lbs.common.executeVba("GetAccept.SetTokens", "-");
            try{
                apiRequest('revoke', 'GET', '', function (data) {
                });
            }
            catch(e){

            }
            //if (skip_vba != true){
            //}
            //stäng fönstret 
            if (viewModel.type() === 'windowed') {
                window.open('', '_parent', '');
                window.close();
            }
        }

        getToken = function () {
            var have_token = false;
            if (typeof lbs.bakery.getCookie("accessToken") != 'undefined') {
                if (lbs.bakery.getCookie("accessToken") != '') {
                    have_token = true;
                }
            }

            if (have_token) {
                accessToken = lbs.bakery.getCookie("accessToken");
                refreshToken = lbs.bakery.getCookie("refreshToken");
                expireToken = lbs.bakery.getCookie("expireToken");
                entityId = lbs.bakery.getCookie("entityId");
                userHash = lbs.bakery.getCookie("userHash");
                fullToken = lbs.bakery.getCookie("fullToken");
                if (fullToken) {
                    lbs.common.executeVba("GetAccept.SetTokens", fullToken);
                }
                viewModel.login_verified = true;
            }
            else {
                viewModel.login_verified = false;
            }
        }

        saveToken = function (data, skip_vba) {
            if (data.access_token) {
                accessToken = data.access_token;
            }
            //prompt('',data.accessToken);
            if (data.refresh_token) {
                refreshToken = data.refresh_token;
            }
            if (data.entity_id) {
                entityId = data.entity_id;
                lbs.bakery.setCookie("entityId", entityId, 30);
            }
            if (data.user_hash) {
                userHash = data.user_hash;
                lbs.bakery.setCookie("userHash", userHash, 30);
            }
            var expireToken = Math.ceil(new Date().getTime() / 1000) + data.expires_in;
            lbs.bakery.setCookie("accessToken", accessToken, 30);
            lbs.bakery.setCookie("refreshToken", refreshToken, 30);
            lbs.bakery.setCookie("expireToken", expireToken, 30);
            lbs.bakery.setCookie("fullToken", JSON.stringify(data), 30);

            if (skip_vba != true) {
                tokenHandler = data;
                lbs.common.executeVba("GetAccept.SetTokens", JSON.stringify(data));
            }
        }
        if (viewModel.type() === 'windowed') {
            document.title = "GetAccept";
            $('.win-auth').removeClass('hidden');
            checkLogin();
            initControls();
        }
        else {
            checkDocuments();
            //initPush();       
        }

        return viewModel;
    };
});


// JavaScript source code
