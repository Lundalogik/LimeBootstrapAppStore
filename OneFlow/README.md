#  OneFlow #
Connection between the E-signing and templating application Oneflow. Enables for users in Lime to create contracts in Oneflow with data fetched from Lime CRM. Furthermore it's possible to track the lifespan of this contract and see who has opened and signed the document.

### Requires a license
For more information please contact Lundalogik AB.

### Installation
This app is built as a LIP package, meaning you can install it with the single VBA-command `Call LIP.Install("OneFlow")`. This will install everything needed with the assumption that the database is based on a Lime Core database version 5.3 or newer. In addition to this, the customer must generate an integration token for each Oneflow account (note: __account__, not __user__) and add this to the app configuration. 

*Note* that the app uses a large amount of localizations which means that any installation without LIP will be time consuming.

### Configuration
There are only a handful of configurable settings for this app. However the configuration has to be added three times. Once for the actionpad view of the app, once for the windowed view and once for the view where the user can set/change account. The settings should be exactly the same except for the parameter __mode__ (see below).
```
<div data-app="{app:'OneFlow',config:{
	    accounts: [
	        {
	            name: 'Lundalogik',
	            token: '181d1971d047c3c78812e14d08983a9a56aa51d5'
	        }
	    ], 
	    companyName: 'Customer name',
	    idField: 'oneflowid',
	    defaultCountry: 'SE',
	    linkField: 'documentlink',
	    table: 'deal',
	    mode: 'actionpad'
    }}" />
```

The configuration should thus contain the following information:
* accounts: A pair of name and token for each Oneflow account. The name is only for visibility purposes in Lime.
* companyName: The name sent to Oneflow for signing purposes.
* idField: Database name for the field where the Oneflow-ID for each contract is stored on the document table.
* defaultCountry: Default country code.
* linkField: Field where the link to the Oneflow contract will be stored on the document record.
* table: Database name for the equivalent of the Deal table in Lime Core 5.4. This can for instance be __business__ in earlier implementations of Lime.
* mode. This should be either __actionpad__, __windowed__ or  __setAccount__ depending on the view.

The two files for views can be found under */Actionpads/apps/OneFlow/Views* and the third view should be added as a div with a data-app attribute to the deal actionpad.

