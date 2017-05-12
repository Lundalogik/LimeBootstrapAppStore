var oneFlow = {
	apiEndpoint : "",
	companyPart : "",
	table : "",
	appViewModel : {},
/*
*	Setup function for initializing the oneFlow object with data from LBS
*/
	"setup" : function(config, viewModel){
		apiEndpoint = config.endpoint;
		oneFlow.appViewModel = viewModel;
		oneFlow.companyPart = config.companyName;
		oneFlow.table = config.table;
		oneFlow.defaultCountry = config.defaultCountry;
	},
/*
*	Fetch position for the active user. Position is used in the api requests.
*/
	"getPosition" : function(userEmail, async, positionObservable){
		var handleResponse = function(response, status){
			if(!response){
				oneFlow.appViewModel.error(true);
				positionObservable(null);
				return;
			}
			
			positionObservable(response.collection[0].id);
		}

		var params = "email=" + encodeURIComponent(userEmail);
		//params = params"&limit_to_own_account=true";
		
		oneFlow.apiRequest(async, 'positions/','GET',{}, params, "",  handleResponse);
	},
/*
*	Fetch the customer's templates. Only fetching active templates and integration templates.
*/
	"getTemplates" : function(){
		var handleResponse = function(response, status){
			if(!response){
				oneFlow.appViewModel.error(true);
				return;
			}

			var visibleTemplates = ko.utils.arrayFilter(response.collection, function(item) {
	            return item.id;
	        });

			oneFlow.appViewModel.templates(ko.utils.arrayMap(visibleTemplates, function(item){
				return new oneFlow.Models.Template(item);
			}));
			
		}
		oneFlow.apiRequest(true,'templates/?integration_type=4','GET',{},"",oneFlow.appViewModel.position(), handleResponse);
	},

/*
*	Fetch single agreement based on the id in Oneflow.
*/
	"getAgreement" : function(name, updated, id, async){
		var handleResponse = function(response, status){
			if(!response && status != 404){
				oneFlow.appViewModel.agreementError(true);
				return;
			}
			
			var agreement = oneFlow.parseAgreement(response, name, updated);	
			
			
			var index = -1;
			_.each(oneFlow.appViewModel.agreements(), function(item, i){
				if(item.id === agreement.id){
					index = i;
				}
			});
			
			if(index > -1){
				oneFlow.appViewModel.agreements[index] = agreement;
			}else{
				oneFlow.appViewModel.agreements.push(agreement);	
			}
			
			var cookieAgreement = lbs.bakery.getCookie("OneFlow_" + oneFlow.appViewModel.deal.iddeal.value);
			if(cookieAgreement){
                if(cookieAgreement == agreement.id){
                	oneFlow.appViewModel.selectedAgreement(agreement);
                }
            }
		}

		oneFlow.apiRequest(async, 'agreements/' + id, 'GET', {}, "", oneFlow.appViewModel.position(), handleResponse);
	},

/*
*	Fetch all tags for all the customer's templates.
*/
	"getTags" : function(){
		var handleResponse = function(response, status){
			if(!response){
				oneFlow.appViewModel.error(true);
				return;
			}
			var json = {};
			_.each(response.collection, function(item){
				json[item.id] = item.name;
			})
			oneFlow.appViewModel.tags(json);
		}
		oneFlow.apiRequest(false, 'tags/', 'GET', {}, "", oneFlow.appViewModel.position(), handleResponse);
	},

/*
*	Method for creating an agreement in Oneflow using the template, the recipients chosen
*	in the form and adding data codes from a preset list (../resources/data.jsn), loaded separately. The list is
* 	used to fetch data from fields in Lime.
*/
	"createAgreement" : function(){
		var handleResponse = function(response, status){
			if(!response){
				oneFlow.appViewModel.error(true);
				oneFlow.appViewModel.sending(false);
			}
			
			var agreement = oneFlow.parseAgreement(response);

			lbs.common.executeVba("OneFlow.CreateAgreement, " + btoa(oneFlow.appViewModel.documentName()) + ", " + agreement.id + ", " + oneFlow.table);
			oneFlow.appViewModel.agreements.push(agreement);
			oneFlow.appViewModel.selectedAgreement(agreement);
			$('#finishedModal').modal({ keyboard: false });
		}

		var internalPart = "";
		var externalPart = "";
		var internalParty = new oneFlow.Models.Party(null);
		var externalParty = new oneFlow.appViewModel.externalParty();
		externalParty.participants = [];
	
		var data = [];
		$.getJSON('../Actionpads/apps/oneflow/resources/data.json', function(json){
            var json = lbs.common.executeVba('OneFlow.ParseCodes, ' + btoa(JSON.stringify(json)));
            json = JSON.parse(json);
            _.each(json.data, function(item){
            	if(item.value){
	            	data.push({
	            		"key" : "data_field",
	            		"value" : {
	            			"external_key": item.external_key,
	            			"value" : item.value
	            		}
	            	});
	            }
            });
        });

		_.each(oneFlow.appViewModel.coworkers(),function(item){
			if(item.type().value >= 0 && (!item.activeUser || item.type().value == 0)){
				internalPart = item.part;
				var internalParticipant = new oneFlow.Models.Participant(item, (item.activeUser ? 1 : 0));
				internalParty.participants.push(internalParticipant);
			}
		});
		_.each(oneFlow.appViewModel.persons(),function(item){
			if(item.type().value >= 0){
				externalPart = item.part;
				var externalParticipant = new oneFlow.Models.Participant(item, 0);
				externalParty.participants.push(externalParticipant);
			}
		})

		var agreement = {
			template_id : oneFlow.appViewModel.selectedTemplate().id,
			parties : [],
			data : data
		};

		if(internalParty.participants.length > 0){
			internalParty.name = internalPart;
			internalParty.self = 1;
			agreement.parties.push(internalParty);
		}
		if(externalParty.participants.length > 0){
			externalParty.name = externalPart;
			agreement.parties.push(externalParty);
		}
		oneFlow.apiRequest(false, 'agreements/', 'POST', agreement, "", oneFlow.appViewModel.position(), handleResponse);
	},
/*
*	Update agreement in Oneflow with new data from Lime.
*/
	"updateAgreement" : function(agreement) {
		var handleResponse = function(response, status){
			if(!response){
				oneFlow.appViewModel.error(true);
				oneFlow.appViewModel.success(false);
				setTimeout(function(){
					oneFlow.appViewModel.error(false);
				},5000);
				oneFlow.appViewModel.sending(false);
			}
			else{
				oneFlow.appViewModel.error(false);
				oneFlow.appViewModel.success(true);

				lbs.common.executeVba("OneFlow.UpdateAgreement, " + agreement.id);
				setTimeout(function(){
					oneFlow.appViewModel.sending(false);
					oneFlow.appViewModel.success(false);
				},3000);
			}
		}
		oneFlow.appViewModel.sending(true);
		// A user cannot update other people's contracts.
		if(agreement.participants.filter(function(p){
			return p.email === oneFlow.appViewModel.email;
		}).length === 0){
			alert(oneFlow.appViewModel.localize.OneFlow.errorUpdateParticipant);
			return;
		}
		var signed = false;
		_.each(agreement.participants, function(p){
			// Signerat
			if(p.rawState === 1){
				signed = true;
			}
		});
		
		if(signed){
			if(!confirm(oneFlow.appViewModel.localize.OneFlow.warnUpdateSigned)){
				return;
			}
		}

		 // Nothing has happened on the deal since the contract was last updated. Nothing to do!
		 // Show 
		if(moment(agreement.updated).diff(moment(oneFlow.appViewModel.deal.timestamp.value))>0){
			oneFlow.appViewModel.error(false);
			oneFlow.appViewModel.success(true);
			setTimeout(function(){
				oneFlow.appViewModel.sending(false);
				oneFlow.appViewModel.success(false);
			},3000);
			return;
		}
		
		var data = [];
		$.getJSON('../Actionpads/apps/oneflow/resources/data.json', function(json){
            var json = lbs.common.executeVba('OneFlow.ParseCodes, ' + btoa(JSON.stringify(json)));
            json = JSON.parse(json);
            _.each(json.data, function(item){
            	if(item.value){
	            	data.push({
	            		"key" : "data_field",
	            		"value" : {
	            			"external_key": item.external_key,
	            			"value" : item.value
	            		}
	            	});
	            }
            });
        });

        var agreementUpdate = {
        	data : data
        };
		oneFlow.apiRequest(false, 'agreements/' + agreement.id, 'PUT', agreement, "", oneFlow.appViewModel.position(), handleResponse);
	},

/*
*	Parse data from either Lime or Oneflow and return an agreement object.
*/
	"parseAgreement" : function(response, documentName, updated){
		var agreement = new oneFlow.Models.Agreement(response,documentName,updated);
		return agreement;
	},

/*
*	Handles a generic api request.
*/
	"apiRequest" : function (async, action, method, json, params, position, callback) {
		// Adds the action to the base api endpoint
        var postUrl = apiEndpoint + action;

        // Adds any query parameters to the endpoint
        postUrl = postUrl + (params ? "?" + params : "");

        // Open a request
        var oReq = new XMLHttpRequest();
        oReq.open(method, postUrl, async);

        // Add request headers
        oReq.setRequestHeader('Content-type', 'application/json');
        oReq.setRequestHeader('X-Flow-Api-Token', oneFlow.appViewModel.token());
        if(position !== ""){
        	oReq.setRequestHeader('X-Flow-Current-Position', position)
        }
        
        // When request is done
        oReq.onreadystatechange = function () {
            if (oReq.readyState == 4) {
            	// If OK
                if (oReq.status == 200 || oReq.status == 302) {
                	oneFlow.appViewModel.error(false);
                    callback(JSON.parse(oReq.responseText), oReq.status);
                }
                // If not OK
                else {
                	oneFlow.appViewModel.innerException("Felmeddelande från servern: " + JSON.parse(oReq.responseText).error);
                    callback(false, oReq.status); 
                }
            }
        };
        if (json) {
            oReq.send(JSON.stringify(json));
        }
        else {
            oReq.send();
        }
    },

    "evalState" : function(participant){
    	var delivery = participant.delivery_channel_status;
    	if(delivery == 1 || delivery == 2 || delivery == 3){
    		return eval(oneFlow.Enums.signeeStates.deliveryStatus);
    	}
    	var state = participant.state;

    	if(state == 1 || state == 2 || state == 3){
    		return eval(oneFlow.Enums.signeeStates.state[state]);
    	}
    	if(participant.visits == 0){
    		return eval(oneFlow.Enums.signeeStates.opened[0]);
    	}
    	else if(participant.visits > 0){
    		return eval(oneFlow.Enums.signeeStates.opened[1]).replace('{x}',participant.visits);
    	}
    	return "";
    	
    },

/*
*	
*/
    "Models" : {
	    "Template" : function(template){
	    	var self = this;
	    	if(template){
	    		self.tags = ko.observableArray();
	    		if (template.agreement.tags){
	    			self.tags(ko.utils.arrayMap(template.agreement.tags, function(tag){
		    			return {'name': oneFlow.appViewModel.tags()[tag.tag.id]};
		    		}));
	    		}
	    		self.id = template.agreement.id;
	    		self.name = template.name;
	    		self.selected = ko.computed(function(){return oneFlow.appViewModel.selectedTemplate() == self});
	    		self.select = function(){
	    			oneFlow.appViewModel.selectedTemplate(self.selected() ? null : self);
	    		}
	    	}
	    	
	    },

	    "Party" : function(party){
	    	var _this = this;
	    	if(party){
	    		_this.name = party.name;
	    		_this.country = party.country || oneFlow.defaultCountry;
	    		_this.orgnr = party.orgnr;
	    		_this.phone_number = party.phone_number;
	    		_this.consumer = 0;
	    		_this.participants = ko.utils.arrayMap(party.participants, function(item){
	    			return new oneFlow.Models.Participant(item);
	    		});
	    	}
	    	else{
	    		_this.name = '';
	    		_this.country = oneFlow.defaultCountry;
	    		_this.orgnr = '';
	    		_this.phone_number = '';
	    		_this.consumer = 0;
	    		_this.participants = [];
	    	}
	    },

	    "Participant" : function(participant, self) {
	    	var _this = this;
	    	if(participant){
	    		_this.type = participant.type().value;
	    		_this.email = participant.email;
	    		_this.fullname = participant.fullname;
	    		_this.self = self;
	    		_this.phone_number = participant.phone_number;
	    		if(participant.position){
    				if(self === 0){
	    				_this.position_id = participant.position();
    				}
	    		}
	    	}
	    },

	    "Person" : function(person){
	    	var self = this;
	    	if(person){
	    		self.email = person.email.text;
	    		self.fullname = person.firstname.text + ' ' + person.lastname.text;
	    		self.phone_number = person.mobilephone ? person.mobilephone.text : '';
	    		self.placeholder = false;
	    		self.part = person.company.text;
	    		self.checked = ko.observable(true);
	    	}
	    	self.types = ko.observableArray([
	    		new oneFlow.Models.ParticipantType(oneFlow.Enums.participantTypes.none, self),
	    		new oneFlow.Models.ParticipantType(oneFlow.Enums.participantTypes.decisionMaker,self),
	    		new oneFlow.Models.ParticipantType(oneFlow.Enums.participantTypes.influencer,self)
    			]
	    	);
	    	self.type = ko.observable(self.types()[0]);
	    },

	    "Coworker" : function(coworker){
	    	var self = this;
	    	self.position = ko.observable();
	    	if(coworker){
	    		self.activeUser = coworker.username.value == oneFlow.appViewModel.activeUser.ID;
	    		self.email = coworker.email.text;
	    		self.fullname = coworker.firstname.text + ' ' + coworker.lastname.text;
	    		self.phone_number = coworker.cellphone ? coworker.cellphone.text : '';
	    		self.placeholder = false;
	    		self.part = oneFlow.companyPart;
	    	}
	    	self.types = ko.observableArray([
	    		new oneFlow.Models.ParticipantType(oneFlow.Enums.participantTypes.none, self),
	    		new oneFlow.Models.ParticipantType(oneFlow.Enums.participantTypes.decisionMaker,self),
	    		new oneFlow.Models.ParticipantType(oneFlow.Enums.participantTypes.influencer,self)
    			]
	    	);

    		self.type = ko.observable(self.types()[self.activeUser ? 1 : 0]);
	    },

	    "ParticipantType" : function(type, participant){
	    	var self = this;
	    	
	    	self.participant = participant;
	    	self.text = eval(type.text);
	    	self.value = type.value;

	    	self.pick = function(){
	    		self.participant.type(self);
	    	}

	    },

	    "Agreement" : function(response, documentName, updated){
	    	var self = this;
	    	
	    	if(response){
	    		var parties = response.parties;
				var participants = [];

				if(!(parties instanceof Array)){
					parties = [parties];
				}
				
				_.each(parties,function(party){

					var parts = party.participants;
					if(!(parts instanceof Array)){
						parts = [parts];
					}

					_.each(parts, function(p){
						var participant = {
							fullname : p.fullname,
							rawState : p.state,
							state : oneFlow.evalState(p),
							email : p.email,
							phone_number : p.phone_number,
							part : party.name,
							type : p.type,
							opened : p.first_visit ? true : false,
							openedTooltip: eval(oneFlow.Enums.openStates[p.first_visit ? 1 : 0]),
							stateClass : ko.computed(function(){
								switch(p.state){
									case 0:
										return "list-group-item-warning";
									case 1:
										return "list-group-item-success";
									case 2:
										return "list-group-item-danger";
									case 3:
										return "disabled"
									default:
										return "";
								}
							})
						};
						participants.push(participant);	
					});
				});
				
	    		self.id = response.id;
				self.name= documentName;
				self.rawState = response.state;
				self.state_timestamp= moment(response.state_timestamp).format("YYYY-MM-DD");
				self.state = eval(oneFlow.Enums.agreementStates[response.state]);
				self.expire_date = response.expire_date;
				self.participants = participants;
				self.updated= moment(updated).format("YYYY-MM-DD HH:mm:ss");
				self.error = ko.observable(false);

				self.stateClass = ko.computed(function(){
					switch(response.state){
						case 0:
							return "label-draft";
						case 1:
							return "label-pending";
						case 2:
							return "label-warning";
						case 4:
							return "label-success";
						case 5:
							return "label-danger";
						case 7:
							return "label-danger";
						default:
							return "label-pending";
					}
				});
				self.open = function(){
					lbs.common.executeVba("OneFlow.OpenAgreement, " + response.id);
				};
				self.openAndClose = function(){
					lbs.common.executeVba("OneFlow.OpenAgreement, " + response.id);
					lbs.common.executeVba("OneFlow.Refresh");
		            window.open('','_parent','');
	            	window.close();
				};
				self.click = function(){

					if(oneFlow.appViewModel.selectedAgreement()){
						oneFlow.appViewModel.selectedAgreement(this.id == oneFlow.appViewModel.selectedAgreement().id ? null : this);
					}
					else{
						oneFlow.appViewModel.selectedAgreement(this);	
					}
					lbs.bakery.setCookie("OneFlow_" + oneFlow.appViewModel.deal.iddeal.value, oneFlow.appViewModel.selectedAgreement() ? oneFlow.appViewModel.selectedAgreement().id : -1)
				};

	    	}else{

	    		self.id = null;
				self.name = documentName;
				self.rawState = 8;
				self.state = eval(oneFlow.Enums.agreementStates[8]);
				self.participants = [];
				self.error = ko.observable(true);
				self.stateClass = self.stateClass = ko.observable("label-danger");
				self.click = function(){

				};

	    	}
	    }
	},

	"Enums" : {
		"participantTypes" : {
			"none" : {
				"value" : -1,
				"text" : "oneFlow.appViewModel.localize.OneFlow.noReceiver"
			},
			"decisionMaker" : {
				"value" : 1,
				"text" : "oneFlow.appViewModel.localize.OneFlow.decisionMaker"
			},
			"influencer" : {
				"value" : 0,
				"text" : "oneFlow.appViewModel.localize.OneFlow.influencer"
			}
		},
		"agreementStates" : {
			"0" : "oneFlow.appViewModel.localize.OneFlow.draftState",
			"1" : "oneFlow.appViewModel.localize.OneFlow.pendingState",
			"2" : "oneFlow.appViewModel.localize.OneFlow.expiredState",
			"3" : "oneFlow.appViewModel.localize.OneFlow.partlySignedState",
			"4" : "oneFlow.appViewModel.localize.OneFlow.signedState",
			"5" : "oneFlow.appViewModel.localize.OneFlow.declinedState",
			"6" : "oneFlow.appViewModel.localize.OneFlow.templateState",
			"7" : "oneFlow.appViewModel.localize.OneFlow.declinedState",
			"8" : "oneFlow.appViewModel.localize.OneFlow.removedState"
		},
		"signeeStates" : {
			"state": {
				"1" : "oneFlow.appViewModel.localize.OneFlow.signedState",
				"2" : "oneFlow.appViewModel.localize.OneFlow.declinedState",
				"3" : "oneFlow.appViewModel.localize.OneFlow.signeeRemovedState"
			},
			"opened": {
				"0" : "oneFlow.appViewModel.localize.OneFlow.notOpened",
				"1" : "oneFlow.appViewModel.localize.OneFlow.openedXTimes"
			},
			"deliveryStatus" : "oneFlow.appViewModel.localize.OneFlow.deliveryFailed"
		},
		"openStates" : {
			"0" : "oneFlow.appViewModel.localize.OneFlow.notOpened",
			"1" : "oneFlow.appViewModel.localize.OneFlow.opened"
		}
	}
}