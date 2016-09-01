var dataHandlingLib = {
    viewModel: {},
    appConfig: {}
};


dataHandlingLib.getNewCookieObj = function(viewModel) {
	var selectedData = helperLib.getSelectedObjects(viewModel);
	var dataToSave = {
		selectedCoworkers: selectedData.coworkers,
		selectedTargettypes: selectedData.targets,
		groupby: viewModel.grouping.selected() || 'target'
	};
	return dataToSave;
}

dataHandlingLib.setCookie = function(viewModel) {
	var dataToSave = dataHandlingLib.getNewCookieObj(viewModel);
	viewModel.cookieObj = dataToSave;
	if(!lbs.bakery || viewModel.securityLevel == 'admin'){
		lbs.bakery.setCookie(viewModel.cookieName, JSON.stringify(dataToSave),5);
	}
}

dataHandlingLib.getCookie = function(viewModel) {
	if(!lbs.bakery || viewModel.securityLevel == 'user') {
		return dataHandlingLib.getNewCookieObj(viewModel); //Return default cookieObj
	}

	var cookieObj = null;
	// Check if cookie exists
	var existingCookieValue = lbs.bakery.getCookie(viewModel.cookieName);
	if(existingCookieValue.length > 0) {
		cookieObj = JSON.parse(existingCookieValue);
	}
	if (!cookieObj){
		dataHandlingLib.setCookie(viewModel, viewModel.cookieName);
		existingCookieValue = lbs.bakery.getCookie(viewModel.cookieName);
		if(existingCookieValue.length > 0) {
			cookieObj = JSON.parse(existingCookieValue);
		}
	}
	return cookieObj;
}

dataHandlingLib.loadChoiceData = function(viewModel, appConfig) {
	var sourceString = 'FollowUp.GetChoices, ' +
    	appConfig.structureMapping.targetTable + ', ' +
    	appConfig.structureMapping.targetTypeField + ', ' +
    	appConfig.structureMapping.scoreTable + ', ' +
    	appConfig.structureMapping.scoreTypeField;

	var choiceData = lbs.loader.loadDataSources({}, [{
		type: 'xml',
		source: sourceString,
		PassInspectorParam: false,
		alias: 'choiceData'
	}], true);
	choiceData = choiceData.choiceData.choiceData;
	var limeScoreTypes = [];
	var limeTargetTypes = [];

	var coworkers = [];

	if (choiceData.coworkers && choiceData.coworkers.coworker) {
		if (viewModel.securityLevel == 'user') {
			var yourUserExist = $.grep( choiceData.coworkers.coworker, function( coworker, i ) {
				return coworker.idcoworker['#cdata'] == viewModel.activeCoworker;
			}).length > 0;

			if(yourUserExist === false) {
				viewModel.errorMessage(viewModel.localize.Followup.no_goals || 'No localize found for - Followup.no_goals');
				return;
			}
		}
		var coworkerObjs = choiceData.coworkers.coworker.length && choiceData.coworkers.coworker || [choiceData.coworkers.coworker];
		for (var i = 0; i < coworkerObjs.length; i++) {
			var idcoworker = coworkerObjs[i].idcoworker['#cdata'];
			var isCoworkerMarked = false;

			if (viewModel.securityLevel == 'user') {
				isCoworkerMarked = idcoworker == viewModel.activeCoworker;
			}
			else {
				isCoworkerMarked = $.grep( viewModel.cookieObj.selectedCoworkers, function( coworker, i ) {
					return coworker.idcoworker === idcoworker;
				}).length > 0;
			}


			var coworker = {
				name : coworkerObjs[i].name['#cdata'],
				idcoworker : idcoworker,
				state : ko.observable(isCoworkerMarked),
				coworkerClicked : function(clickedObj) {
					if(clickedObj.state() == false) {
						var nrOfMarked = helperLib.getNrOfMarked(viewModel);

						if(nrOfMarked.coworkers >= appConfig.choiceLimits.coworkerMax) {
							alert(viewModel.localize.Followup.validate_maxcoworkers || 'No localize found for - Followup.validate_maxcoworkers');
							return;
						}
						else if(nrOfMarked.coworkers + nrOfMarked.targets >= appConfig.choiceLimits.totalMax) {
							alert(viewModel.localize.Followup.validate_maxobjects || 'No localize found for - Followup.validate_maxobjects');
							return;
						}
					}
					clickedObj.state(!clickedObj.state());
					
				}
			};
			coworkers.push(coworker);
		};
	}
	else {
		viewModel.errorMessage(viewModel.localize.Followup.coworker_notargetdata || 'No localize found for - Followup.coworker_notargetdata'); 
	}



	if (choiceData.scoretypes && choiceData.scoretypes.scoretype) {
		var scoretypeObjs = choiceData.scoretypes.scoretype.length && choiceData.scoretypes.scoretype || [choiceData.scoretypes.scoretype];
		for (var i = 0; i < scoretypeObjs.length; i++) {
			var scoreType = {
				text : scoretypeObjs[i].text['#cdata'],
				key : scoretypeObjs[i].key['#cdata'],
				value : scoretypeObjs[i].value['#cdata']
			};
			limeScoreTypes.push(scoreType);
		}
	}
	else {
		viewModel.errorMessage(viewModel.localize.Followup.error_no_scoretypes || 'No localize found for - Followup.error_no_scoretypes'); 
	}

	var targettypes = [];
	if (choiceData.targettypes && choiceData.targettypes.targettype) {
		var targettypeObjs = choiceData.targettypes.targettype.length && choiceData.targettypes.targettype || [choiceData.targettypes.targettype];

		for (var i = 0; i < targettypeObjs.length; i++) {
			var targetType = {
				text : targettypeObjs[i].text['#cdata'],
				key : targettypeObjs[i].key['#cdata'],
				value : targettypeObjs[i].value['#cdata']
			};
			limeTargetTypes.push(targetType);
		}
		
		for (var i = 0; i < appConfig.targetMapping.length; i++) {
			var currentMapping = appConfig.targetMapping[i];

			var existingTarget = $.grep( limeTargetTypes, function( val, i ) {
				return val.key == currentMapping.targetTypeKey;
			});

			// Proceed if target key (Mapped from config matches with a target in Lime database)
			if(existingTarget.length > 0) {
				
				var existingScore = $.grep( limeScoreTypes, function( val, i ) {
					return val.key == currentMapping.scoreTypeKey;
				});
				// Proceed if score key (Mapped from config matches with a target in Lime database)
				if(existingScore.length > 0) {
					var currentTargetLime = existingTarget[0];
					var currentScoreLime = existingScore[0];
					var targetValue = currentTargetLime.value;

					var isTargetMarked = false;
					if (viewModel.securityLevel == 'user') {
						isTargetMarked = true;
					}
					else {
						isTargetMarked = $.grep( viewModel.cookieObj.selectedTargettypes, function( target, i ) {
							return target.value === targetValue;
						}).length > 0 ;
					}

					var targettype = {
						text : currentTargetLime.text,
						key : currentTargetLime.key,
						value : targetValue,
						scoreTypeKey : currentScoreLime.key,
						state : ko.observable(isTargetMarked),
						targettypeClicked : function (clickedObj) {
							if(clickedObj.state() == false) {
								var nrOfMarked = helperLib.getNrOfMarked(viewModel);

								if(nrOfMarked.targets >= appConfig.choiceLimits.targetMax) {
									alert(viewModel.localize.Followup.validate_maxtarget || 'No localize found for - Followup.validate_maxtarget');
									return;
								}
								else if(nrOfMarked.targets + nrOfMarked.coworkers >= appConfig.choiceLimits.totalMax) {
									alert(viewModel.localize.Followup.validate_maxobjects || 'No localize found for - Followup.validate_maxobjects');
									return;
								}
							}
							clickedObj.state(!clickedObj.state());
						}
					};

					targettypes.push(targettype);
				}
				else {
					var warningText = viewModel.localize.Followup.error_nomatch_score || 'No localize found for - Followup.error_nomatch_score';
					warningText = warningText.replace("%1", currentMapping.scoreTypeKey);
					warningText = warningText.replace("%2", appConfig.structureMapping.scoreTable);
					viewModel.errorMessage(warningText);
				}
			}
			else {
				var warningText = viewModel.localize.Followup.error_nomatch_target || 'No localize found for - Followup.error_nomatch_target';
				warningText = warningText.replace("%1", currentMapping.targetTypeKey);
				warningText = warningText.replace("%2", appConfig.structureMapping.targetTable);
				viewModel.errorMessage(warningText);
			}
		};
	}
	else {
		viewModel.errorMessage(viewModel.localize.Followup.error_no_targettypes || 'No localize found for - Followup.error_no_targettypes');
	}
    viewModel.choices.coworkers(coworkers);
    viewModel.choices.targettypes(targettypes);
}


dataHandlingLib.getTargetData = function(viewModel, appConfig) {
	viewModel.parents([]);
	
	var chosenMonthMoment = $('#datetimepicker').data('DateTimePicker').date();
	var highestChildCount = 0;

	var selectedData = helperLib.getSelectedObjects(viewModel);

	// Fetch marked values
	var markedCoworkers = selectedData.coworkers;
	var markedTargets = selectedData.targets;

	if(viewModel.canGetTargetData() == false) {
		var warningMessage = viewModel.localize.Followup.validate_missingInput || 'No localize found for - Followup.validate_missingInput';
		alert(warningMessage);
		return;
	}
	// Build xml to send to VBA
	var xmlTargets = '<targets>';
	for (var i = 0; i < markedTargets.length; i++) {
		xmlTargets = xmlTargets + '<target>';
		xmlTargets = xmlTargets + '<targetTypeKey><![CDATA[' + markedTargets[i].key + ']]></targetTypeKey>';
		xmlTargets = xmlTargets + '<scoreTypeKey><![CDATA[' + markedTargets[i].scoreTypeKey + ']]></scoreTypeKey>';
		xmlTargets = xmlTargets + '</target>';
	};
	xmlTargets = xmlTargets + '</targets>';


	var xmlCoworker = '<coworkers>';
	for (var i = 0; i < markedCoworkers.length; i++) {
		xmlCoworker = xmlCoworker + '<coworker>';
		xmlCoworker = xmlCoworker + '<idcoworker><![CDATA[' + markedCoworkers[i].idcoworker + ']]></idcoworker>';
		xmlCoworker = xmlCoworker + '</coworker>';
	}
	xmlCoworker = xmlCoworker + '</coworkers>';

	var groupBy = viewModel.grouping.selected();
	var monthToGet = chosenMonthMoment.format('YYYY-MM-DD');

	var xmlStructure = '<structure>';
	xmlStructure = xmlStructure + '<targetTable>' + appConfig.structureMapping.targetTable + '</targetTable>';
	xmlStructure = xmlStructure + '<targetTypeField>' + appConfig.structureMapping.targetTypeField + '</targetTypeField>';
	xmlStructure = xmlStructure + '<targetDateField>' + appConfig.structureMapping.targetDateField + '</targetDateField>';
	xmlStructure = xmlStructure + '<targetValueField>' + appConfig.structureMapping.targetValueField + '</targetValueField>';
	xmlStructure = xmlStructure + '<scoreTable>' + appConfig.structureMapping.scoreTable + '</scoreTable>';
	xmlStructure = xmlStructure + '<scoreTypeField>' + appConfig.structureMapping.scoreTypeField + '</scoreTypeField>';
	xmlStructure = xmlStructure + '<scoreDateField>' + appConfig.structureMapping.scoreDateField + '</scoreDateField>';
	xmlStructure = xmlStructure + '<scoreValueField>' + appConfig.structureMapping.scoreValueField + '</scoreValueField>';
	xmlStructure = xmlStructure + '</structure>';

	var xmlData = lbs.common.executeVba('Followup.GetTargetData', [
		xmlCoworker,
		xmlTargets,
		groupBy,
		monthToGet,
		xmlStructure
	]);
	var targetData = helperLib.parseXmlToJavaScriptObject(xmlData);
	targetData = targetData.targetData;

	if(targetData.error) {
		viewModel.errorMessage(targetData.error['#cdata']);
	}
	else {
		viewModel.errorMessage('');
		dataHandlingLib.setCookie(viewModel);
		if(targetData.parents) {
			var parentData = targetData.parents.parent.length && targetData.parents.parent || [targetData.parents.parent];
			var parentArray = [];
			for (var i = 0; i < parentData.length; i++) {
	        	var parentObj = {
	        		id : parentData[i].id['#cdata'],
	        		children : ko.observableArray(),
	        		object : groupBy,
	        		currentValue : 0,
	        		targetValue : 0,
	        		monthToDateValue : 0,
	        	};
	        	
	        	if(groupBy == 'coworker') {
					parentObj.name = helperLib.getCoworkerNameFromId(viewModel, parentObj.id);
	        	}	
	        	else {
					parentObj.name = helperLib.getTargetNameFromKey(viewModel, parentObj.id);
	        	}

	        	if(parentData[i].children) {
					var childData = parentData[i].children.child.length && parentData[i].children.child || [parentData[i].children.child];
					var childArray = [];


					highestChildCount = Math.max(highestChildCount, childData.length);
		        	for (var j = 0; j < childData.length; j++) {
		        		var childObj = {
		        			id : childData[j].id['#cdata'],
		        			currentValue : childData[j].currentValue['#cdata'],
		        			targetValue : childData[j].targetValue['#cdata'],
		        			monthToDateValue : childData[j].monthToDateValue['#cdata']
		        		};

		        		// Summary for parentObject
						parentObj.currentValue += parseInt(childObj.currentValue);
						parentObj.targetValue += parseInt(childObj.targetValue);
						parentObj.monthToDateValue += parseInt(childObj.monthToDateValue);

						if(groupBy == 'coworker') {
							childObj.name = helperLib.getTargetNameFromKey(viewModel, childObj.id);
						}
						else {
							childObj.name = helperLib.getCoworkerNameFromId(viewModel, childObj.id);
						}

						childObj.goalNowQuota = (childObj.currentValue == 0 && childObj.monthToDateValue == 0 && 1) || (childObj.monthToDateValue != 0 && (childObj.currentValue / childObj.monthToDateValue) || 0);
						childObj.goalQuota = childObj.targetValue != 0 && (childObj.monthToDateValue / childObj.targetValue) || 0;
		        		childObj.totalQuota = childObj.targetValue != 0 && (childObj.currentValue / childObj.targetValue) || 0;

		        		childObj.getQuotaText = function(quotaValue)
		        		{
							return Math.round(quotaValue * 100) + '%';
		        		};

		        		childObj.getQuotaWidth = function(quotaValue)
		        		{
							return Math.min(Math.round(quotaValue * 100), 100) + '%';
		        		};

	        			childObj.coloring = helperLib.getColoringByTargetObj(appConfig, childObj);
	        			childObj.coloringBar = helperLib.getColoringBarByTargetObj(appConfig, childObj);

	        			childArray.push(childObj);
		        	};

		        	// Sort array
		        	childArray.sort(helperLib.sortChild);

		        	parentObj.children(childArray);
	        	}
	        	parentObj.infoMessage = ko.observable('');
	        	if(parentObj.children().length == 0) {
					
	        		parentObj.infoMessage(viewModel.localize.Followup.no_goals_month || 'No localize found for - Followup.no_goals_month');
	        	}
	        	parentArray.push(parentObj);
	        };

		    // Sort array
		    parentArray.sort(helperLib.sortParent);

	        viewModel.parents(parentArray);
		}

		// Closes settings modal window
		$('#showPreferencesModal').modal('hide');
		viewModel.grouping.latestFetched(groupBy);

		// Set height of each child container
		var listSizeClass = helperLib.getListSizeByChildCount(highestChildCount);
		viewModel.listSizeClass(listSizeClass);
	}
}