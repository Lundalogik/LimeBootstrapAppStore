/**
	This file contains code that creates a Customer object that is used in app.js.
*/

var Customer = function() {
	var self = this;
	/**
		Returns true if the customer is eligible for sending to BFUS.
		Since it is not mandatory to define any rules in the config for the app the default of this function is true.
	*/
	self.eligibleForBFUSSending = function(eligibleForBFUSSending) {
		if (eligibleForBFUSSending !== undefined) {
	        return lbs.common.executeVba('app_CreateCustomerBFUS.isEligibleForSendingToBFUS,' + lbs.activeInspector.ID + ','
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
		return lbs.common.executeVba('app_CreateCustomerBFUS.isRecordSaved,' + lbs.activeInspector.ID);
	}

	/**
        Returns true if the customer is already integrated with BFUS and otherwise false.
    */
    self.isIntegratedWithBFUS = function(customeridFieldName) {
        var isIntegrated = false;
        var exp = 'isIntegrated = window.external.ActiveInspector.Controls.GetValue("' + customeridFieldName + '") !== \'\'';
        eval(exp);
        return isIntegrated;
    }

	/**
	    Returns a customer object to send when creating a new customer in BFUS.
	*/
	self.createCustomerJSON = function(fieldMappings, rec, suppressPinCodeWarning, suppressAddressWarning) {
	    var c = this;
	    var exp = '';
	    c.Header = {};
	    c.Header.ExternalId = lbs.activeInspector.Record.ID;
	    c.Header.SuppressPinCodeWarning = suppressPinCodeWarning;
	    c.Header.SuppressAddressWarning = suppressAddressWarning;
	    
	    c.Customer = {};
	    c.Customer.IsProtectedIdentity = false;
	    exp = exp + 'c.Customer.FirstName = rec.' + fieldMappings.FirstName + '.text;\n';
	    exp = exp + 'c.Customer.LastName = rec.' + fieldMappings.LastName + '.text;\n';
	    exp = exp + 'c.Customer.IsBusinessCustomer = (rec.' + fieldMappings.IsBusinessCustomer + '.value === ' + fieldMappings.IsBusinessCustomerLIMEOptionId + ');\n';
	    exp = exp + 'c.Customer.PinCode = rec.' + fieldMappings.PinCode + '.text;\n';
	    exp = exp + 'c.Customer.CompanyCode = rec.' + fieldMappings.CompanyCode + '.text;\n';
	    
	    c.Customer.EmailInformation = {};
	    exp = exp + 'c.Customer.EmailInformation.AcceptEMail = rec.' + fieldMappings.AcceptEMail + '.text;\n';
	    if (fieldMappings.Email1 !== '') {
	        exp = exp + 'c.Customer.EmailInformation.EMail1 = rec.' + fieldMappings.EMail1 + '.text;\n';
	    }
	    if (fieldMappings.Email2 !== '') {
	        exp = exp + 'c.Customer.EmailInformation.EMail2 = rec.' + fieldMappings.EMail2 + '.text;\n';
	    }
	    if (fieldMappings.Email3 !== '') {
	        exp = exp + 'c.Customer.EmailInformation.EMail3 = rec.' + fieldMappings.EMail3 + '.text;\n';
	    }
	    
	    c.Customer.SMSInformation = {};
	    exp = exp + 'c.Customer.SMSInformation.AcceptSMS = rec.' + fieldMappings.AcceptSMS + '.text;\n';
	    
	    c.Customer.Phones = [];
	    $.each(fieldMappings.Phones, function (index, obj) {
	        exp = exp + 'c.Customer.Phones.push({'
	        exp = exp + 'PhoneTypeId : ' + obj.PhoneTypeId + ','
	        exp = exp + 'Number : rec.' + obj.Number + '.text,'
	        exp = exp + '});\n'
	    });
	    
	    c.Customer.Addresses = [];
	    $.each(fieldMappings.Addresses, function (index, obj) {
	        exp = exp + 'c.Customer.Addresses.push({'
	        exp = exp + 'AddressTypeId : ' + obj.AddressTypeId + ','
	        exp = exp + 'StreetName : rec.' + obj.StreetName + '.text,'
	        exp = exp + 'StreetQualifier : rec.' + obj.StreetQualifier + '.text,'
	        exp = exp + 'StreetNumberSuffix : rec.' + obj.StreetNumberSuffix + '.text,'
	        exp = exp + 'PostOfficeCode : rec.' + obj.PostOfficeCode + '.text,'
	        exp = exp + 'City : rec.' + obj.City + '.text,'
	        exp = exp + 'CountryCode : rec.' + obj.CountryCode + '.text,'
	        exp = exp + 'ApartmentNumber : rec.' + obj.ApartmentNumber + '.text,'
	        exp = exp + 'FloorNumber : rec.' + obj.FloorNumber + '.text,'
	        exp = exp + '});\n'
	    });
	    
	    // Add all properties
	    eval(exp);
	    
	    return c;
	}

	/**
	    Returns a customer object to send when creating a new customer in BFUS.
	*/
	self.updateCustomerJSON = function() {
	    var c = this;
	    var exp = '';
	    
	    c.Header = {};
	    c.Header.ExternalId = lbs.activeInspector.Record.ID;
	    // c.Header.SuppressPinCodeWarning = self.suppressPinCodeWarning;
	    c.Header.SuppressAddressWarning = self.suppressAddressWarning;

	    //##TODO!

	    // Add all properties
	    eval(exp);

	    return c;
	}
}