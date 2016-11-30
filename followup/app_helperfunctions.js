var helperLib = {};

helperLib.sortParent = function(a,b) {
	return a.name > b.name && 1 || -1;
}

helperLib.sortChild = function(a,b) {
	return a.name > b.name && 1 || -1;
}

helperLib.goToNextMonth = function(reverse) {
	$('#datetimepicker').data('DateTimePicker').hide();
	var currentChoice = $('#datetimepicker').data('DateTimePicker').date();
	var increment = reverse && -1 || 1;

	$('#datetimepicker').data('DateTimePicker').date(currentChoice.add(increment, 'month'));
}

helperLib.canGetTargetData = function(viewModel) {
	var selectedData = helperLib.getSelectedObjects(viewModel);
	// Fetch marked values
	var markedCoworkers = selectedData.coworkers;
	var markedTargets = selectedData.targets;

	return (markedCoworkers.length > 0 && markedTargets.length > 0);
}

helperLib.getSelectedObjects = function(viewModel) {
	var markedCoworkers = $.grep( viewModel.choices.coworkers() || [], function( coworker, i ) {
		return coworker.state() == true;
	});
	var markedTargets = $.grep( viewModel.choices.targettypes() || [], function( targettype, i ) {
		return targettype.state() == true;
	});

	return {
		coworkers: markedCoworkers,
		targets: markedTargets,
	};
}

helperLib.parseXmlToJavaScriptObject = function(xmlData) {
	var json = xml2json($.parseXML(xmlData),'');
 	json = $.parseJSON(json);
 	return json;
}

helperLib.getCoworkerNameFromId = function(viewModel, idcoworker) {
	for (var i = 0; i < viewModel.choices.coworkers().length; i++) {
		if(viewModel.choices.coworkers()[i].idcoworker == idcoworker) {
			return viewModel.choices.coworkers()[i].name;
		}
	};
	return '';
}

helperLib.getTargetNameFromKey = function(viewModel, targettypeKey) {
	for (var i = 0; i < viewModel.choices.targettypes().length; i++) {
		if(viewModel.choices.targettypes()[i].key == targettypeKey) {
			return viewModel.choices.targettypes()[i].text;
		}
	};
	return '';
}

helperLib.getListSizeByChildCount = function(childCount) {
	var listSizeClass;
	if (childCount >= 3) {
		listSizeClass = 'large-height';
	}
	else if(childCount >= 2) {
		listSizeClass = 'medium-height';
	}
	else {
		listSizeClass = 'small-height';
	}
	return listSizeClass;
}

helperLib.getColoringByTargetObj = function(appConfig, targetObj) {
	var coloring;
	if (targetObj.monthToDateValue == 0) {
		coloring = 'list-group-item-success';
	}
	else if (targetObj.goalNowQuota >= appConfig.coloring.green) {
		coloring = 'list-group-item-success';
	}
	else if (targetObj.goalNowQuota >= appConfig.coloring.yellow) {
		coloring = 'list-group-item-warning';
	}
	else {
		coloring = 'list-group-item-danger';
	}
	return coloring;
}

helperLib.getColoringBarByTargetObj = function(appConfig, targetObj) {
	var coloring;
	if (targetObj.monthToDateValue == 0) {
		coloring = 'progress-bar-success';
	}
	else if (targetObj.goalNowQuota >= appConfig.coloring.green) {
		coloring = 'progress-bar-success';
	}
	else if (targetObj.goalNowQuota >= appConfig.coloring.yellow) {
		coloring = 'progress-bar-warning';
	}
	else {
		coloring = 'progress-bar-danger';
	}
	return coloring;
}

helperLib.getNrOfMarked = function(viewModel) {
	var markedCoworkers = $.grep( viewModel.choices.coworkers(), function( coworker, i ) {
		return coworker.state() == true;
	});

	var markedTargets = $.grep( viewModel.choices.targettypes(), function( targettype, i ) {
		return targettype.state() == true;
	});

	return {
		coworkers: markedCoworkers.length,
		targets: markedTargets.length
	}
}


helperLib.checkversion = function() {
	var localVersionData = $.parseJSON(lbs.loader.loadLocalFileToString("system/version.json"));
    var sortedVersions = localVersionData.versions.sort(function(ls, rs) {
    	return helperLib.compareVersions(ls.version.toString(), rs.version.toString());
    });

    return sortedVersions[0].version;
	
}

helperLib.compareVersions = function(ls, rs) {
	var rsSplitted = rs.toString().split('.');
	var lsSplitted = ls.toString().split('.');
	var returnValue = null;

	for (var i = 0; i < Math.min(rsSplitted.length, lsSplitted.length); i++) {
		var rsCurrent = parseInt(rsSplitted[i]);
		var lsCurrent = parseInt(lsSplitted[i]);

		if (rsCurrent > lsCurrent) {
			returnValue = 1; // ls is a higher version number
			break;
		}
		else if (rsCurrent < lsCurrent) {
			returnValue = -1; // rs is a higher version number
			break;
		}
		else {
			// Continute to next version part
		}
	};

	if (returnValue == null && rsSplitted.length < lsSplitted.length) {
		returnValue = -1; // rs is a higher version number
	}
	else if (returnValue == null && rsSplitted.length > lsSplitted.length) {
		returnValue = 1; // ls is a higher version number
	}
	else if (returnValue == null) {
		returnValue = 0; // The same versions
	}

	return returnValue;
}

helperLib.allChoicesClicked = function(choices){
	var prevAllChoices = helperLib.allChoicesComputed(choices);
	$.each(choices,function(i,choice){
		choice.state(!prevAllChoices);
	});
}

helperLib.allChoicesComputed = function(choices){
	
	var unchecked = $.grep(choices,function(choice,i){
		return choice.state() == false;
	});
	return unchecked.length == 0;
}