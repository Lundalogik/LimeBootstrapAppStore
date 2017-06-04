lbs.apploader.register('SMS', function () {
	var self = this;
	var initializeMessage = '';
	/*Config (version 2.0)
		This is the setup of your app. Specify which data and resources that should loaded to set the enviroment of your app.
		App specific setup for your app to the config section here, i.e self.config.yourPropertiy:'foo'
		The variabels specified in "config:{}", when you initalize your app are available in in the object "appConfig".
	*/
	self.config = function (appConfig) {
		this.generalDefaultValues = appConfig.generalDefaultValues || {};
		this.generalDefaultValues.messageType = this.generalDefaultValues.messageType || 'free';
		this.allowSmsOnTime = !!appConfig.allowSmsOnTime;
		this.smsSupplier = appConfig.smsSupplier;

		this.tableConfigs = appConfig.tableConfigs || {};
		var configKey = appConfig.configKey || '';
		var currentConfigObj = this.tableConfigs[configKey] || null;

		var splittedKey = configKey.split(';');
		if (splittedKey.length === 2 )
		{
			this.className = splittedKey[0];
			this.getReceiversFrom = splittedKey[1];
		}

		if (currentConfigObj) {
			
			currentConfigObj.specificDefaultValues = currentConfigObj.specificDefaultValues || {};
			var defaultValues = {};

			defaultValues.messageType = (currentConfigObj.specificDefaultValues && currentConfigObj.specificDefaultValues.messageType) || this.generalDefaultValues.messageType;

			this.defaultValues = defaultValues;

			this.receiverNameFieldName = currentConfigObj.receiverNameFieldName || 'name';
			this.receiverMobilephoneFieldName = currentConfigObj.receiverMobilephoneFieldName || 'mobilephone';
			this.selectionType = currentConfigObj.selectionType || 'selected';
			this.receiverTableName = currentConfigObj.receiverTableName || 'person';
			this.receiverFromFields = currentConfigObj.receiverFromFields || '';
			this.extraRelations = currentConfigObj.extraRelations || {};
			this.extraRelations.fieldRelations = this.extraRelations.fieldRelations || [];

			this.GetConfigXml = function () {
				var configXml = '<config>';

				configXml += '<getReceiversFrom>' + this.getReceiversFrom + '</getReceiversFrom>';
				configXml += '<smsSupplier>' + this.smsSupplier + '</smsSupplier>';
				configXml += '<receiverName>' + this.receiverNameFieldName + '</receiverName>';
				configXml += '<receiverMobilephone>' + this.receiverMobilephoneFieldName + '</receiverMobilephone>';
				configXml += '<selectionType>' + this.selectionType + '</selectionType>';
				configXml += '<receiverTableName>' + this.receiverTableName + '</receiverTableName>';
				configXml += '<receiverFromFields>' + this.receiverFromFields + '</receiverFromFields>';
				configXml += '</config>';
				
				return configXml;
			}

			this.dataSources = [
				{ type: 'xml', source: 'SMS.GetInitialData, ' + this.receiverTableName + ',' + this.GetConfigXml(), alias: 'initialData'}
			];
		}
		else {
			initializeMessage = "Can't find a config object matching the key: '" + configKey + "'\n\rCheck the config of the app.";
			this.dataSources = [];
		}
		
		this.resources = {
			scripts: [
				'/External Libs/Datetimepicker/moment-with-locales_tln_default_sv_.min.js', // OBS OBS Manually put in by TLN <-> Set default locale to 'sv' in end of file! OBS OBS
                '/External Libs/Datetimepicker/bootstrap-datetimepicker.min.js',
                '/External Libs/Selectpicker/bootstrap-select.min.js'
            ],
			styles: [
				'app.css',
				'/External Libs/Datetimepicker/datepicker.css',
				'/External Libs/Selectpicker/bootstrap-select.min.css'
				], // <= Load styling for the app.
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
		var appConfig = self.config;

		viewModel.errorMessage = ko.observable('');
		viewModel.sendErrorMessage = ko.observable('');
		viewModel.sendSuccess = ko.observable(false);
		
		viewModel.receivers = ko.observableArray();
		viewModel.templates = ko.observableArray();
		viewModel.users = ko.observableArray();
		viewModel.templateCodes = ko.observableArray();
		viewModel.receiverErrors = ko.observableArray();

		viewModel.allowSmsOnTime = ko.observable(appConfig.allowSmsOnTime);
		viewModel.receiversNoPhone = ko.observable(0);

		viewModel.inputValues = {
			messageType: ko.observable(appConfig.defaultValues && appConfig.defaultValues.messageType || ''),
			user: ko.observable(null),
			template: ko.observable(null),
			sendOnTime: ko.observable(false),
			message: ko.observable('')
		};


		$(document).keydown(function (e) {
            if (e.keyCode == 13) { // Enter pressed
                // stop the event propagate (if you want)
                //return false;
            }
            else if (e.keyCode == 27) { // Escape pressed
                return false;
            }
            else {
                // Let other keys go
            }
        });



		// Helper functions 
			function TemplateCode(templateCode) {
				var newTemplateCode = this;
				newTemplateCode.description = templateCode.description;
				newTemplateCode.code = templateCode.code;

				newTemplateCode.insertCode = function (templateCode) {
					var messageField = $('textarea.message-field');
					var textToInsert = templateCode.code;
					if (document.selection) {
						messageField.focus();
						sel = document.selection.createRange();
						sel.text = textToInsert;
					}
					else {
						messageField.value += textToInsert;
					}
				}

				return newTemplateCode;
			}

			function Receiver(receiver) {
				var newReceiver = this;
				newReceiver.id = parseInt(receiver.id['#cdata']);
				newReceiver.name = receiver.name['#cdata'];
				newReceiver.phone = (receiver.phone == null ? '' : receiver.phone['#cdata']);

				newReceiver.remove = function (receiver) {
					viewModel.receivers.remove(receiver);
				}

				return newReceiver;
			}

			function Template(template) {
				var newTemplate = this;
				newTemplate.id = parseInt(template.id['#cdata']);
				newTemplate.default = template.default['#cdata'] == 1 ? 1 : 0;
				newTemplate.name = template.name['#cdata'];
				newTemplate.message = template.message['#cdata'];

				newTemplate.select = function(template) {
					viewModel.inputValues.template(template);
					viewModel.inputValues.message(template.message);
				}

				return newTemplate
			}

			function User(user) {
				var newUser = this;
				newUser.id = parseInt(user.id['#cdata']);
				newUser.source = user.source['#cdata'];
				newUser.name = user.name['#cdata'];
				newUser.username = user.username['#cdata'];
				newUser.password = user.password['#cdata'];
				newUser.default = user.default['#cdata'] == '1' ? 1 : 0;
				newUser.serviceid = user.serviceid['#cdata'];
				newUser.platformid = user.platformid['#cdata'];
				newUser.platformpartnerid = user.platformpartnerid['#cdata'];
				newUser.gateid = user.gateid['#cdata'];

				newUser.select = function(user) {
					viewModel.inputValues.user(user);
				}

				return newUser;
			}

			function ReceiverError(receiverError) {
				var newReceiverError = this;
				newReceiverError.id = parseInt(receiverError.id['#cdata']);
				newReceiverError.message = receiverError.message['#cdata'];

				// Fetching values from receiver
				var matchingReceivers = $.grep( viewModel.receivers(), function( receiver, i ) {
					return receiver.id == newReceiverError.id;
				});
				if(matchingReceivers.length > 0) {
					var matchingReceiver = matchingReceivers[0];
					newReceiverError.receiverName = matchingReceiver.name;
					newReceiverError.receiverPhone = matchingReceiver.phone;
				}
				else {
					newReceiverError.receiverName = '';
					newReceiverError.receiverPhone = '';
				}
				return newReceiverError;
			}

			function addXmlElement(xml, elementName, elementValue) {
				return xml += ('<%1><![CDATA[%2]]></%1>').split('%1').join(elementName).split('%2').join(elementValue);
			}

			function addErrorMessage(message) {
				viewModel.errorMessage(viewModel.errorMessage() + (viewModel.errorMessage() == '' ? '' : '\n\r\n\r') + '• ' + message);
			}

			function replaceIfExist(text, from, to) {
				return to && text.split(from).join(to) || text;
			}
			viewModel.getLocalize = function(owner, code, replaceCode1, replaceCode2, replaceCode3, replaceCode4, replaceCode5) {
				var text = (viewModel.localize[owner] && viewModel.localize[owner][code]) || '<owner.code>'.replace('owner', owner).replace('code', code);
				text = replaceIfExist(text, '%0', '\n');
				text = replaceIfExist(text, '%1', replaceCode1);
				text = replaceIfExist(text, '%2', replaceCode2);
				text = replaceIfExist(text, '%3', replaceCode3);
				text = replaceIfExist(text, '%4', replaceCode4);
				text = replaceIfExist(text, '%5', replaceCode5);
				return text;
			}

		$('title').text(viewModel.getLocalize('sms', 'formHeader'));

		// If there's an error in the initialization set it here.
		if (initializeMessage && initializeMessage.length > 0) {
			addErrorMessage(initializeMessage);
		}
		else {


			// Try to read receivers from the initialData
			try {
				if (viewModel.initialData.root.receivers) {
					var nrOfReceiversWithNoPhone = parseInt(viewModel.initialData.root.receivers.noPhone || 0);
					viewModel.receiversNoPhone(nrOfReceiversWithNoPhone);

					if (viewModel.initialData.root.receivers.receiver) {
						var receivers = viewModel.initialData.root.receivers.receiver.length && viewModel.initialData.root.receivers.receiver || [viewModel.initialData.root.receivers.receiver];
						$.each(receivers, function (i, receiver) {
							viewModel.receivers.push(new Receiver(receiver));
						});
					}
				}
			}
			catch (ex) {
				var message = 'Error loading receivers: ' + ex;
				console.log(message);
				addErrorMessage(message);
			}

			// Try to read templates from the initialData
			try {
				if (viewModel.initialData.root.templates) {

					if (viewModel.initialData.root.templates.template) {
						var templates = viewModel.initialData.root.templates.template.length && viewModel.initialData.root.templates.template || [viewModel.initialData.root.templates.template];
						$.each(templates, function (i, template) {
							var newTemplate = new Template(template);
							if(newTemplate.default == 1) {
								newTemplate.select(newTemplate);
							}
							viewModel.templates.push(newTemplate);
						});
					}
				}
			}
			catch (ex) {
				var message = 'Error loading templates: ' + ex;
				addErrorMessage(message);
				console.log(message);
			}

			// Try to read users from the initialData
			try {
				if (viewModel.initialData.root.users) {
					if (viewModel.initialData.root.users.user) {
						var users = viewModel.initialData.root.users.user.length && viewModel.initialData.root.users.user || [viewModel.initialData.root.users.user];
						$.each(users, function (i, user) {
							var newUser = new User(user);
							if (newUser.default == 1) {
								viewModel.inputValues.user(newUser);
							}
							viewModel.users.push(newUser);
						});
					}
				}
			}
			catch (ex) {
				var message = 'Error loading users: ' + ex;
				addErrorMessage(message);
				console.log(message);
			}

			// Try to read templateCodes from the initialData
			try {
				if (viewModel.initialData.root.templateCodes) {
					if (viewModel.initialData.root.templateCodes.templateCode) {
						var templateCodes = viewModel.initialData.root.templateCodes.templateCode.length && viewModel.initialData.root.templateCodes.templateCode || [viewModel.initialData.root.templateCodes.templateCode];
						$.each(templateCodes, function (i, templateCode) {
							var newTemplateCode = new TemplateCode(templateCode);
							viewModel.templateCodes.push(newTemplateCode);
						});
					}
				}
			}
			catch (ex) {
				var message = 'Error loading templateCodes: ' + ex;
				addErrorMessage(message);
				console.log(message);
			}

			$('#datetimepicker').datetimepicker({
	            inline: false,
	            viewMode: 'days',
	            calendarWeeks: true,
	            defaultDate: moment(),
	            locale: lbs.limeDataConnection.Database.Locale || 'en-us',
	            icons: {
	                time: 'fa fa-clock-o',
	                date: 'fa fa-calendar',
	                up: 'fa fa-arrow-circle-up',
	                down: 'fa fa-arrow-circle-down',
	                previous: 'fa fa-arrow-circle-left',
	                next: 'fa fa-arrow-circle-right',
	                clear: 'fa fa-trash',
	                close: 'fa fa-times-circle'
	            },
	        });

	        viewModel.allowToSend = ko.computed(function() {
	        	return viewModel.inputValues.message().length > 0
	        		&& viewModel.receivers().length > 0
	        		&& viewModel.inputValues.user() != null;
	        });

			viewModel.close = function () {
				window.open('', '_parent', '');
				window.close();
			}

			viewModel.showErrorReceivers = function () {
				var xmlData = '<receivers>';

				$.each(viewModel.receiverErrors(), function (i, receiverError) {
					xmlData += '<receiver>%1</receiver>'.replace('%1', receiverError.id.toString());
				});
				xmlData += '</receivers>';

				lbs.common.executeVba('Sms.ShowReceivers', [xmlData, appConfig.receiverTableName]);

				viewModel.close();
			}

			viewModel.send = function () {
				var smsXml = '<smsData>';
				smsXml = addXmlElement(smsXml, 'message', replaceIfExist(viewModel.inputValues.message(), String.fromCharCode(10), "%0"));
				smsXml += '<smsuser>%1</smsuser>'.replace('%1', viewModel.inputValues.user().id.toString());

				smsXml += '<receivers>';
				$.each(viewModel.receivers(), function (i, receiver) {
					smsXml += '<receiver>%1</receiver>'.replace('%1', receiver.id.toString());
				});
				smsXml += '</receivers>';

				smsXml += '</smsData>';

				var relationXml = '<relationData>';
				relationXml += '<fieldRelations>';
				$.each(appConfig.extraRelations.fieldRelations, function (i, fieldRelation) {
					relationXml += '<fieldRelation>';
					relationXml += '<fieldNameReceiver>%1</fieldNameReceiver>'.replace('%1', fieldRelation.fieldNameReceiver);
					relationXml += '<fieldNameSms>%2</fieldNameSms>'.replace('%2', fieldRelation.fieldNameSms);
					relationXml += '</fieldRelation>';
				});
				relationXml += '</fieldRelations>';
				relationXml += '</relationData>';

				$('#modal-loading').modal('show');

				var results = {};
				var xmlData = lbs.common.executeVba("Sms.SendAndCreateSms", [smsXml, appConfig.GetConfigXml(), relationXml]);

                results = lbs.loader.xmlToJSON(xmlData, 'results');

                results = results.results;

                if(results) {
                	results = results.results;
                	if(results.criticalError) { //Error before sending messages (Or VBA error)
                		viewModel.sendErrorMessage(results.criticalError['#cdata']);
						viewModel.sendSuccess(false);
                	}
                	else { // Error in response from webService.
                		var receiverErrors = results.receiverErrors;

                		if(receiverErrors) {
                			receiverErrors = receiverErrors.receiverError.length && receiverErrors.receiverError || [receiverErrors.receiverError];
                			$.each(receiverErrors, function (i, receiverError) {
								var newReceiverError = new ReceiverError(receiverError);
                				viewModel.receiverErrors.push(newReceiverError);
							});
                			var nrOfReceivers = viewModel.receivers().length;
                			var nrOfFailedMessages = viewModel.receiverErrors().length;

                			viewModel.sendSuccess(nrOfReceivers > nrOfFailedMessages);
                		}
                		else {
                			viewModel.sendSuccess(true);
                		}
                	}
                }
                else {
                	console.log('Unhandled exception in result');
                }

				$('#modal-loading').modal('hide');

				$('#modal-result').modal('show');
			}
		}

		return viewModel;
	};
});
