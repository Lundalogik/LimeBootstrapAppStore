#CreateCustomerBFUS

##Info


###Important Notices
* In the current version, the app only says that there is information missing on the customer record if BFUS returns an error claiming that some required information is not provided. A future improvement of the app could be adding support for showing to the user which information BFUS wants.

##Install
1. Add the app folder to your Actionpad folder.
2. Add the following localize records:
*	app_CreateCustomerBFUS.btnCreate
*	app_CreateCustomerBFUS.btnUpdate
*	app_CreateCustomerBFUS.loader
*	app_CreateCustomerBFUS.i_sentToBFUS
*	app_CreateCustomerBFUS.e_recordNotSaved
*	app_CreateCustomerBFUS.e_couldNotSend
*	app_CreateCustomerBFUS.e_missingData
*	app_CreateCustomerBFUS.btnWarningYes
*	app_CreateCustomerBFUS.btnWarningNo
*	app_CreateCustomerBFUS.warningTextPinCode
*	app_CreateCustomerBFUS.warningTextCompanyCode
*	app_CreateCustomerBFUS.warningTextAddressCreate
*	app_CreateCustomerBFUS.warningTextAddressUpdate
3. Add the VBA module app_CreateCustomerBFUS.

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
								'StreetName': 'invoicestreet',
								'StreetQualifier': 'name',
								'StreetNumberSuffix': 'name',
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


##Setup
