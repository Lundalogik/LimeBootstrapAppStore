-- This script will create the fields necessary for the app CreateCustomerBFUS
-- Make sure that the settings variables are correct for your LIME Pro database.

-- SETTINGS --
--------------
DECLARE @customertablename NVARCHAR(64)
SET @customertablename = N''
--------------

IF @customertablename = N''
BEGIN
	RAISERROR(N'You must set the parameter @customertablename at the top of the script!', 11, 1)
	RETURN
END


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

	
	SET @tablename = @customertablename
	SET @fieldname = N'senttobfusstatus'
	PRINT N'CREATE FIELD: ' + @tablename + '.' + @fieldname
	SET @return_value = NULL
	SET @defaultvalue = ''
	SET @idfield = NULL
	SET @localname = NULL
	SET @idcategory = NULL
	SET @idstring = NULL


	EXEC	@return_value = [dbo].[lsp_addfield]
			@@table = @tablename,
			@@name = @fieldname,
			@@fieldtype = 21,					--Alternativfält
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
			
	UPDATE [string] SET en_us = N'Status of last sending to BFUS', sv = N'Status senast skickat till BFUS' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'width', @@valueint = 3
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'invisible', @@valueint = 1	--Dold på kort
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'limereadonly', @@valueint = 1	--Skrivskyddad (endast i Lime)
	
	SELECT TOP 1 @idstring = idstring
	FROM string
	WHERE idcategory = @idcategory
	
	UPDATE string
	SET [key] = N'empty'
	WHERE idstring = @idstring

	PRINT N'idstring for empty option: ' + CONVERT(NVARCHAR(32), @idstring)

	PRINT 'ADD ALTERNATIVES: ' + @tablename + '.' + @fieldname
	PRINT '----------------------------------------'
	DECLARE @option_sv NVARCHAR(64)

	SET @idstring = NULL
	SET @option_sv = N'OK'
	EXEC	dbo.lsp_addstring
			@@idcategory = @idcategory
			, @@string = @option_sv
			, @@lang = 'sv'
			, @@idstring = @idstring OUTPUT
	EXEC	dbo.lsp_setstring
			@@idstring = @idstring
			, @@lang = N'en_us'
			, @@string = N'OK'
	
	UPDATE string
	SET [key] = N'ok'
	WHERE idstring = @idstring

	PRINT 'Set green color on ' + @option_sv
	EXEC lsp_addattributedata
		@@owner	= N'string',
		@@idrecord = @idstring,
		@@idrecord2 = NULL,
		@@name = N'color',
		@@value	= 32768				-- Green
	
	PRINT N'idstring for ' + @option_sv + N': ' + CONVERT(NVARCHAR(32), @idstring)
	
	SET @idstring = NULL
	SET @option_sv = N'Misslyckat'
	EXEC	dbo.lsp_addstring
			@@idcategory = @idcategory
			, @@string = @option_sv
			, @@lang = 'sv'
			, @@idstring = @idstring OUTPUT
	EXEC	dbo.lsp_setstring
			@@idstring = @idstring
			, @@lang = N'en_us'
			, @@string = N'Failed'
	
	UPDATE string
	SET [key] = N'failed'
	WHERE idstring = @idstring

	PRINT 'Set red color on ' + @option_sv
	EXEC lsp_addattributedata
		@@owner	= N'string',
		@@idrecord = @idstring,
		@@idrecord2 = NULL,
		@@name = N'color',
		@@value	= 255				-- Red

	PRINT N'idstring for ' + @option_sv + N': ' + CONVERT(NVARCHAR(32), @idstring)


END TRY
BEGIN CATCH
	DECLARE @errormessage NVARCHAR(512)
	SET @errormessage = ERROR_MESSAGE()
	ROLLBACK TRANSACTION
	RAISERROR(@errormessage, 11, 1)
	RETURN
END CATCH

COMMIT TRANSACTION

-- Run the different procedures to make LISA and the LIME server get the database structure again.
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'lsp_refreshldc')
BEGIN
	EXEC lsp_refreshldc
END

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'lsp_setdatabasetimestamp')
BEGIN
	EXEC lsp_setdatabasetimestamp
END

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'lsp_refreshcaches')
BEGIN
	EXEC lsp_refreshcaches
END


GO
