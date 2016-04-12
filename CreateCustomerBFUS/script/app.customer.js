/**
	This file contains code that creates a Customer object that is used in app.js.
*/

var Customer = function(fieldMappings, rec) {
	var self = this;
	self.fieldMappings = fieldMappings;
	self.rec = rec;

	self.getCustomerId = function(customerIdFieldName) {
		return window.external.ActiveInspector.Controls.GetValue(customerIdFieldName);
	}

	self.getCustomerCode = function(customerCodeFieldName) {
		return window.external.ActiveInspector.Controls.GetValue(customerCodeFieldName);
	}

	/**
		Sends the LIME Pro field names of the fields that can be updated in BFUS the current version of this app to VBA.
	*/
	self.setUpdateableFields = function() {
		var bfusFieldNames = ['FirstName','LastName','AcceptEMail','EMail1','EMail2','EMail3','AcceptSMS'];
		var limeFieldNames = ';';
		var exp = '';			// We have to use dynamic Javascript here

		// Loop over all BFUS fields.
		$.each(bfusFieldNames, function(i, field) {
			exp = exp + 'if (self.fieldMappings.' + field + ' !== \'\') { limeFieldNames = limeFieldNames + self.fieldMappings.' + field + ' + \';\' };\n'
		});
		eval(exp);
		lbs.common.executeVba('App_CreateCustomerBFUS.setUpdateableFields,' + limeFieldNames);
	}

	/**
		Sends the LIME Pro field name of the CustomerId field to VBA so that code there can check the field when needed.
	*/
	self.setFieldNameCustomerId = function() {
		lbs.common.executeVba('App_CreateCustomerBFUS.setFieldNameCustomerId,' + self.fieldMappings.CustomerId);
	}

	/**
		Returns true if the customer is eligible for sending to BFUS.
		Since it is not mandatory to define any rules in the config for the app the default of this function is true.
	*/
	self.eligibleForBFUSSending = function(eligibleForBFUSSending) {
		if (eligibleForBFUSSending !== undefined) {
	        return lbs.common.executeVba('App_CreateCustomerBFUS.isEligibleForSendingToBFUS,' + lbs.activeInspector.ID + ','
	                                        + eligibleForBFUSSending.limeField, + ','
	                                        + eligibleForBFUSSending.validIdstrings);
	    }
	    else {
	        return true;
	    }
	}

	/**
		Returns false if the customer is modified and otherwise true.
	*/
	self.isRecordSaved = function() {
		return lbs.common.executeVba('App_CreateCustomerBFUS.isRecordSaved,' + lbs.activeInspector.ID);
	}

	/**
		Returns true if the customer was successfully saved and otherwise false.
	*/
	self.saveRecord = function() {
		return lbs.common.executeVba('App_CreateCustomerBFUS.saveRecord,' + lbs.activeInspector.ID);
	}

	/**
		Calls VBA sub to save info on successful calls to the BFUS service.
	*/
	self.saveSuccessInfo = function(customerId, customerCode) {
		lbs.common.executeVba('App_CreateCustomerBFUS.saveBFUSResponseData,' 
                                    + lbs.activeInspector.ID + ',' 
                                    + self.fieldMappings.CustomerId + ',' 
                                    + customerId + ',' 
                                    + self.fieldMappings.CustomerCode + ','  
                                    + customerCode);
	}

	/**
		Calls VBA sub to save info on errors.
	*/
	self.saveErrorInfo = function() {
		lbs.common.executeVba('App_CreateCustomerBFUS.saveErrorInfo,' + lbs.activeInspector.ID);
	}

	/**
        Returns true if the customer is already integrated with BFUS and otherwise false.
    */
    self.isIntegratedWithBFUS = function(customerIdFieldName) {
        return (self.getCustomerId(customerIdFieldName) !== '');
    }

	/**
	    Returns a customer object to send when creating a new customer in BFUS.
	*/
	self.createCustomerJSON = function(suppressPinCodeWarning, suppressAddressWarning) {
	    var c = this;
	    var exp = '';
	    c.Header = {};
	    c.Header.ExternalId = lbs.activeInspector.Record.ID;
	    c.Header.SuppressPinCodeWarning = suppressPinCodeWarning;
	    c.Header.SuppressAddressWarning = suppressAddressWarning;
	    
	    // Build string with Javascript code to make configurable field mappings possible.
	    c.Customer = {};
	    c.Customer.IsProtectedIdentity = false;
	    exp = exp + 'c.Customer.IsBusinessCustomer = (self.rec.' + self.fieldMappings.IsBusinessCustomer + '.value === ' + self.fieldMappings.IsBusinessCustomerLIMEOptionId + ');\n';
	    exp = exp + 'c.Customer.FirstName = self.rec.' + self.fieldMappings.FirstName + '.text;\n';
	    exp = exp + 'if (!c.Customer.IsBusinessCustomer) { c.Customer.LastName = self.rec.' + self.fieldMappings.LastName + '.text; }\n';
	    exp = exp + 'if (!c.Customer.IsBusinessCustomer) { c.Customer.PinCode = \'19-\' + self.rec.' + self.fieldMappings.PinCode + '.text; }\n';
	    exp = exp + 'if (c.Customer.IsBusinessCustomer) { c.Customer.CompanyCode = \'16-\' + self.rec.' + self.fieldMappings.CompanyCode + '.text + \'-00\'; }\n';
	    
	    c.Customer.EmailInformation = {};
	    exp = exp + 'c.Customer.EmailInformation.AcceptEMail = (self.rec.' + self.fieldMappings.AcceptEMail + '.value === 1);\n';
	    if (self.fieldMappings.Email1 !== '') {
	        exp = exp + 'c.Customer.EmailInformation.EMail1 = self.rec.' + self.fieldMappings.EMail1 + '.text;\n';
	    }
	    if (self.fieldMappings.Email2 !== '') {
	        exp = exp + 'c.Customer.EmailInformation.EMail2 = self.rec.' + self.fieldMappings.EMail2 + '.text;\n';
	    }
	    if (self.fieldMappings.Email3 !== '') {
	        exp = exp + 'c.Customer.EmailInformation.EMail3 = self.rec.' + self.fieldMappings.EMail3 + '.text;\n';
	    }
	    
	    c.Customer.SMSInformation = {};
	    exp = exp + 'c.Customer.SMSInformation.AcceptSMS = (self.rec.' + self.fieldMappings.AcceptSMS + '.value === 1);\n';
	    c.Customer.Phones = [];
	    $.each(self.fieldMappings.Phones, function (index, obj) {
	    	exp = exp + 'if (self.rec.' + obj.Number + '.text !== \'\') { '
	        exp = exp + 'c.Customer.Phones.push({'
	        exp = exp + 'PhoneTypeId : ' + obj.PhoneTypeId + ','
	        exp = exp + 'Number : self.rec.' + obj.Number + '.text'
	        exp = exp + '}); }\n'
	    });
	    
	    c.Customer.Addresses = [];
	    $.each(self.fieldMappings.Addresses, function (index, obj) {
	        exp = exp + 'var splittedAddress = getSplittedAddress(self.rec.' + obj.StreetName + '.text, \'' + obj.StreetName + '\', \n';
	        exp = exp + 'self.rec.' + obj.StreetQualifier + '.text, \'' + obj.StreetQualifier + '\', \n';
	        exp = exp + 'self.rec.' + obj.StreetNumberSuffix + '.text, \'' + obj.StreetNumberSuffix + '\');\n';
	        exp = exp + 'c.Customer.Addresses.push({'
	        exp = exp + 'AddressTypeId : ' + obj.AddressTypeId + ', '
	        exp = exp + 'StreetName : splittedAddress.StreetName, '
	        exp = exp + 'StreetQualifier : splittedAddress.StreetQualifier, '
	        exp = exp + 'StreetNumberSuffix : splittedAddress.StreetNumberSuffix, '
	        exp = exp + 'PostOfficeCode : self.rec.' + obj.PostOfficeCode + '.text, '
	        exp = exp + 'City : self.rec.' + obj.City + '.text, '
	        exp = exp + 'CountryCode : self.rec.' + obj.CountryCode + '.text, '
	        exp = exp + 'ApartmentNumber : self.rec.' + obj.ApartmentNumber + '.text, '
	        exp = exp + 'FloorNumber : self.rec.' + obj.FloorNumber + '.text'
	        exp = exp + '});\n'
	    });

	    // Add all properties
	    eval(exp);
	    
	    return c;
	}

	/**
	    Returns a customer object to send when updating a customer in BFUS.
	*/
	self.updateCustomerJSON = function(suppressPinCodeWarning, suppressAddressWarning) {
	    var c = this;
	    var exp = '';
	    
	    c.Header = {};
	    c.Header.ExternalId = lbs.activeInspector.Record.ID;
	    
	    // Build string with Javascript code to make configurable field mappings possible.
	    c.Customer = {};
	    c.Customer.IsProtectedIdentity = false;
	    exp = exp + 'c.Customer.CustomerCode = self.getCustomerCode(\'' + self.fieldMappings.CustomerCode + '\');\n';
	    exp = exp + 'c.Customer.CustomerId = self.getCustomerId(\'' + self.fieldMappings.CustomerId + '\');\n';
	    exp = exp + 'c.Customer.FirstName = self.rec.' + self.fieldMappings.FirstName + '.text;\n';
	    exp = exp + 'if (self.rec.' + self.fieldMappings.IsBusinessCustomer + '.value !== ' + self.fieldMappings.IsBusinessCustomerLIMEOptionId + ') { c.Customer.LastName = self.rec.' + self.fieldMappings.LastName + '.text; }\n';
	    
	    c.Customer.EmailInformation = {};
	    exp = exp + 'c.Customer.EmailInformation.AcceptEMail = (self.rec.' + self.fieldMappings.AcceptEMail + '.value === 1);\n';
	    if (self.fieldMappings.Email1 !== '') {
	        exp = exp + 'c.Customer.EmailInformation.EMail1 = self.rec.' + self.fieldMappings.EMail1 + '.text;\n';
	    }
	    if (self.fieldMappings.Email2 !== '') {
	        exp = exp + 'c.Customer.EmailInformation.EMail2 = self.rec.' + self.fieldMappings.EMail2 + '.text;\n';
	    }
	    if (self.fieldMappings.Email3 !== '') {
	        exp = exp + 'c.Customer.EmailInformation.EMail3 = self.rec.' + self.fieldMappings.EMail3 + '.text;\n';
	    }

	    c.Customer.SMSInformation = {};
	    exp = exp + 'c.Customer.SMSInformation.AcceptSMS = (self.rec.' + self.fieldMappings.AcceptSMS + '.value === 1);\n';
	    c.Customer.Phones = [];

	    // The below can be used when support for updating phone numbers have been added by BFUS. You need to fix the code that sets PhoneId and DeleteObject though.
	    // c.Customer.Phones = [];
	    // $.each(self.fieldMappings.Phones, function (index, obj) {
	    //     exp = exp + 'c.Customer.Phones.push({'
	    //     	//##TODO: Set PhoneId!
	    //     exp = exp + 'PhoneTypeId : ' + obj.PhoneTypeId + ','
	    //     exp = exp + 'Number : self.rec.' + obj.Number + '.text'
	    //     	//##TODO: Set DeleteObject!
	    //     exp = exp + '});\n'
	    // });

	    // Add all properties
	    eval(exp);

	    return c;
	}

	/**
		Splits a street address and returns it as an object with three parameters according to what BFUS wants.
	*/
	getSplittedAddress = function(streetName, streetNameFieldName, streetQualifier, streetQualifierFieldName, streetNumberSuffix, streetNumberSuffixFieldName) {
		var streetAddressObj = {};

		var lastSpaceStreetName = streetName.lastIndexOf(' ');

		// Fix street address
		if (streetNameFieldName === streetQualifierFieldName || streetNameFieldName === streetNumberSuffixFieldName) {
			var lastSpaceStreetName = streetName.lastIndexOf(' ');
			streetAddressObj.StreetName = streetName.substr(0, (lastSpaceStreetName > 0 ? lastSpaceStreetName : streetName.length));
		}
		else {
			streetAddressObj.StreetName = streetName;
		}

		// Fix street number
		if (streetQualifierFieldName === streetNameFieldName) {
			streetAddressObj.StreetQualifier = streetName.substr(lastSpaceStreetName + 1, streetName.length).replace(/\D+/g, '');	// replace all non-digits with nothing
		}
		else if (streetQualifierFieldName === streetNumberSuffixFieldName) {
			streetAddressObj.StreetQualifier = streetQualifier.replace( /\D+/g, '');	// replace all non-digits with nothing
		}
		else {
			streetAddressObj.StreetQualifier = streetQualifier;
		}

		// Fix street number suffix
		if (streetNumberSuffixFieldName === streetNameFieldName) {
			if (lastSpaceStreetName > 0) {
				streetAddressObj.StreetNumberSuffix = streetName.substr(lastSpaceStreetName + 1, streetName.length).replace(/[0-9]/g, '');	// replace all digits with nothing
			}
			else {
				streetAddressObj.StreetNumberSuffix = '';
			}
		}
		else if (streetNumberSuffixFieldName === streetQualifierFieldName) {
			streetAddressObj.StreetNumberSuffix = streetNumberSuffix.replace(/[0-9]/g, '');	// replace all digits with nothing
		}
		else {
			streetAddressObj.StreetNumberSuffix = streetNumberSuffix;
		}

		return streetAddressObj;
	}
}