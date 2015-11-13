#CreateCustomerBFUS

##Info
This app is a supplement to the big LIME Pro - BFUS integration that gathers data from BFUS and writes it to LIME. It could however, from a technical standpoint, also be used separately.

The app lets the user create a LIME Pro prospect customer in BFUS. The customer will then automatically be part of the main integration. It is also possible to udpate some data in LIME Pro and send it to BFUS.

If BFUS already has a customer with the same organizational number or civic registration number, the user will receive a warning. It is possible for the user to override that warning by clicking the Yes button that is automatically shown in case of a warning. LIME Pro will then resend the customer with a flag lettning BFUS know that it should suppress the registration number warning.

#####Important Notices
* The BFUS version must be 6.1 or higher.
* In the current version, the app only says that there is information missing on the customer record if BFUS returns an error claiming that some required information is not provided. A future improvement of the app could be adding support for showing to the user which information BFUS wants.
* BFUS does not support updates of the address on an existing customer.
* BFUS does not accept combinations of zip code and city where either the zip code or the city is already used in another combination in BFUS. A future improvement of the BFUS side of the integration discussed is that this will generate a warning that can be overrun by the end user instead. The app is somewhat prepared for this. You would need to set the correct BFUS warning in the parameter BFUSWarnings.Address.

##Install
1. Add the app folder to your Actionpad folder.
2. Run the script createLocalizeRecords.sql to add the necessary localize records.
3. Add the VBA module app_CreateCustomerBFUS.
4. Remove the readonly setting if the customer is integrated with BFUS, done in VBA, on the fields that can be updated in BFUS by this app. Currently these are (stated by BFUS API name):

* FirstName
* LastName
* AcceptEMail
* EMail1
* EMail2
* EMail3
* AcceptSMS



##Setup
Use the below JSON configuration to instantiate the app.
```html
<div data-app="{app:'CreateCustomerBFUS',
				config:{
					baseURI: 'http://...',
					ewiKey: '...',
					crossDomainCall: true,
					fieldMappings: {
						'FirstName': 'firstname',
						'LastName': 'lastname',	
						'IsBusinessCustomer': 'category',
						'PinCode': 'orgnr',
						'CompanyCode': 'orgnr',
						'AcceptEMail': 'accepts_email',
						'EMail1': 'email1',
						'EMail2': 'email2',
						'EMail3': 'email3',
						'AcceptSMS': 'accepts_sms',
						'Phones': [
							{
								'PhoneTypeId': 10980000,
								'Number': 'phone2'
							},
							{
								'PhoneTypeId': 10980100,
								'Number': 'fax'
							},
							{
								'PhoneTypeId': 10980200,
								'Number': 'phonemisc'
							},
							{
								'PhoneTypeId': 10980300,
								'Number': 'phone1'
							},
							{
								'PhoneTypeId': 10980500,
								'Number': 'mobile'
							}
						],
						'Addresses': [
							{
								'AddressTypeId': 10090000,
								'StreetName': 'invoicestreet',
								'StreetQualifier': 'invoicestreet',
								'StreetNumberSuffix': 'invoicestreet',
								'PostOfficeCode': 'invoicezipcode',
								'City': 'invoicecity',
								'CountryCode': 'country',
								'ApartmentNumber': 'apartmentnumber',
								'FloorNumber': 'floornumber',
							}
						]
					}
				}
				}"></div>
```

#####Phone Numbers
In BUFS it is possible to create new custom Phone Types. The main integration (that updates LIME Pro based on BFUS data) retreives the types defined in the example configuration JSON shown here. If the customer wants to use other Phone Types that must be changed both in the main integration and in the configuration JSON for this app. Which Phone Types that exist can be fetched by a GET to `Common/Phone/GetPhoneTypeInformation_v1/<a randomly chosen ExternalId>`. This is done by a button that is commented out in the html file for this app. Use it if you need to find out which Phone Types there are but remove the button as soon as you have looked it up!

#####Addresses
The standard address type that is used in the main integration (that updates LIME Pro based on BFUS data) is the one set in the example configuration JSON for this app. If the customer wants to change this, it must be updated in both the main integration and the configuration JSON. Which Address Types that exist can be fetched here `Common/Address/GetAddressTypeInformation_v1/<a randomly chosen ExternalId>`. This is done by a button that is commented out in the html file for this app. Use it if you need to find out which Phone Types there are but remove the button as soon as you have looked it up!

The values for `StreetName`, `StreetQualifier` and `StreetNumberSuffix` will be treated according to the following logics:
* **StreetName**: If any of `StreetQualifier` and `StreetNumberSuffix` have been specified as the same field as `StreetName`, then the value from the LIME Pro field will be cut at the last existing space before it is sent to BFUS.
* **StreetQualifier**: If it is the same LIME Pro field as `StreetName` then that string will be cut at the last space and the value passed will be the numeric value of the last part of the string. Otherwise, if it is the same LIME Pro field as `StreetNumberSuffix`, that string will have everything but the numerical values removed before sending to BFUS.
* **StreetNumberSuffix**: If it is the same LIME Pro field as `StreetName` then that string will be cut at the last space and the value passed will be the string that is left when all numeric values have been removed from the string. If there is no space at all, then this property will be empty. Otherwise, if it is the same LIME Pro field as `StreetQualifier`, that string will have the numerical values removed before sending to BFUS.


##Future development ideas
* Add support for updating phone numbers in LIME Pro. This requires that the big integration has support for PhoneId.
* Make the button for updating in BFUS visible (or highlighted or similar) only if any information that can be updated in BFUS has been updated in LIME Pro.
* In the current version, LIME Pro adds "19-" to all civic registration numbers for private persons before sending it to BFUS. It will be necessary to add "20-" on some customers instead in a near future. Not a trivial task though; How will 100+ year olds be treated then?