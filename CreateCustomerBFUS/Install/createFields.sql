-- This script will create the fields necessary for the app CreateCustomerBFUS
-- Make sure that the settings variables are correct for your LIME Pro database.

-- SETTINGS --
--------------
DECLARE @customertablename NVARCHAR(64)
SET @customertablename = N'customer'
--------------



BEGIN TRY
	BEGIN TRANSACTION
	
	--VARIABLER
	DECLARE	@return_value INT
		, @defaultvalue NVARCHAR(128)
		, @idfield INT
		, @localname INT
		, @idcategory INT
		, @idstring INT
		, @sqlcommand NVARCHAR(2048)
		, @fieldname NVARCHAR(64)
		, @tablename NVARCHAR(64)

	SET @tablename = @customertablename
	SET @fieldname = N'lastsenttobfus'
	PRINT N'CREATE FIELD: ' + @tablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null


	EXEC	@return_value = [dbo].[lsp_addfield]
			@@table = @tablename,
			@@name = @fieldname,
			@@fieldtype = 7,					--Datumfält
			@@isnullable = 1,
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
			
	UPDATE [string] SET en_us = 'Last sent to BFUS', sv = 'Senast skickad till BFUS' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'width', @@valueint = 3
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'invisible', @@valueint = 1	--Dold på kort
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'type', @@valueint = 9		--Format: Datum, tid med sekunder
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'limereadonly', @@valueint = 1	--Skrivskyddad (endast i Lime)



END TRY
BEGIN CATCH
	DECLARE @errormessage NVARCHAR(512)
	SET @errormessage = ERROR_MESSAGE()
	ROLLBACK TRANSACTION
	RAISERROR(@errormessage, 11, 1)
	RETURN
END CATCH

COMMIT TRANSACTION

EXEC lsp_refreshldc
EXEC lsp_refreshcaches

GO
