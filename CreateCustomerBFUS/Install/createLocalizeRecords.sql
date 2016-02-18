-- Create new records in localize table
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'btnCreate', N'Text on the create button.', N'Skapa i BFUS', N'Send to BFUS'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'btnUpdate', N'Text on update button.', N'Uppdatera i BFUS', N'Update in BFUS'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'loader', N'Text that is shown when sending to BFUS.', N'Skickar', N'Sending'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'e_couldNotSend', N'Message prompted to user if there was an error when sending to BFUS.', N'Något gick fel! Var vänlig försök igen.', N'Something went wrong! Please, try again.'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'btnWarningNo', N'Text on button for answering No to a question as a result of a warning from BFUS.', N'Avbryt', N'Cancel'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'btnWarningYes', N'Text on button for answering Yes to a question as a result of a warning from BFUS.', N'Ja', N'Yes'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'warningTextAddressCreate', N'Text shown to user with question if a warning on address is returned from BFUS when creating.', N'Adressen stämmer inte överens med postnummerregistret i BFUS. Vill du skapa kunden ändå?', N'The combination of zip code and address is not valid according to BFUS. Do you still want to create it?'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'warningTextAddressUpdate', N'Text shown to user with question if a warning on address is returned from BFUS when updating.', N'Adressen stämmer inte överens med postnummerregistret i BFUS. Vill du uppdatera kunden ändå?', N'The combination of zip code and address is not valid according to BFUS. Do you still want to update it?'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'warningTextPinCode', N'Text shown to user if a warning on PinCode is returned from BFUS.', N'Det finns redan en kund med det personnumret i BFUS. Vill du skapa kunden ändå?', N'A customer with that civic registration number already exists in BFUS. Do you still want to create it?'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'warningTextCompanyCode', N'Text shown to user if a warning on CompanyCode is returned from BFUS.', N'Det finns redan en kund med det organisationsnumret i BFUS. Vill du skapa kunden ändå?', N'A customer with that organizational number already exists in BFUS. Do you still want to create it?'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'i_sentToBFUS', N'Text shown after a successful call to BFUS.', N'Kunden skickades till BFUS.', N'The customer was sent to BFUS.'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'e_recordNotSaved', N'Message prompted to user if the inspector is not saved when clicking the send button.', N'Det gick inte att spara kunden.', N'The customer could not be saved.'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'e_missingData', N'Message prompted to user if BFUS reported back that required data is missing.', N'All nödvändig information är inte ifylld. Fyll i, spara och skicka igen.', N'Required data missing. Fill in, save and try to send again.'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us) SELECT 0,1,1, N'App_CreateCustomerBFUS', N'e_mustSendUpdateToBFUS', N'Message prompted to user if any of the fields that are updateable in BFUS has been updated.', N'Kunden kan inte sparas förrän ändringarna har skjutits över till BFUS då berörda fält har ändrats. Spara i BFUS genom knapp i Actionpaden.', N'Since data that also exists in BFUS has been changed, you have to send the customer to BFUS to be able to save it in LIME. Please use the button in the Actionpad.'


-- Run onsqlupdate on complete localize table.
DECLARE @sql NVARCHAR(MAX)
SET @sql = ''
SELECT @sql = @sql + ', [' + f.[name] + '] = (' + a.[value] + ')' + CHAR(10) FROM [attributedata] AS a
             INNER JOIN [field] AS f ON a.[idrecord] = f.[idfield]
             INNER JOIN [table] AS t ON f.[idtable] = t.[idtable]
                  WHERE a.[owner] = 'field'
                  AND [a].[name] ='onsqlupdate'
                  AND t.[name] = 'localize'

SET @sql = 'UPDATE [localize] SET [status] = [status] ' + @sql
SET @sql = @sql + ' WHERE [status] = 0'

EXEC(@sql)
