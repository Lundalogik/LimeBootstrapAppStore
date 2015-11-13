-- This script creates the localize table.

BEGIN TRY
	BEGIN TRANSACTION

	-- Variables
	DECLARE	@return_value INT
			, @defaultvalue NVARCHAR(128)
			, @localname INT
			, @idstring INT
			, @idtable INT
			, @transid UNIQUEIDENTIFIER
			, @descriptive INT
			, @idfield INT
			, @fieldname NVARCHAR(64)
			, @idcategory INT
			, @newtablename NVARCHAR(64)
			, @newtablelocalname_sv NVARCHAR(64)
			, @newtablelocalname_en_us NVARCHAR(64)
			, @newtablelocalnameplural_sv NVARCHAR(64)
			, @newtablelocalnameplural_en_us NVARCHAR(64)
			, @descriptiveexpression NVARCHAR(512)

	SET @return_value = NULL
	SET @defaultvalue = ''
	SET @localname = NULL
	SET @idstring = NULL
	SET @idtable = NULL
	SET @transid = NEWID()
	SET @descriptive = NULL
	SET @idfield = NULL
	SET @fieldname = N''
	SET @idcategory = NULL

	-----------------------------------------
	------------- SET VALUES ! --------------
	SET @newtablename = N'localize'
	SET @newtablelocalname_sv = N'Översättning'
	SET @newtablelocalname_en_us = N'Localization'
	SET @newtablelocalnameplural_sv = N'Översättningar'
	SET @newtablelocalnameplural_en_us = N'Localizations'
	SET @descriptiveexpression = N'[localize].[owner]'
	-----------------------------------------

	PRINT 'CREATE TABLE: ' + @newtablename
	EXEC [dbo].[lsp_addtable]
		@@name = @newtablename
		, @@idtable = @idtable OUTPUT
		, @@localname = @localname OUTPUT
		, @@descriptive = @descriptive OUTPUT
		, @@transactionid = @transid
		, @@user = 1

	-- Set local name
	PRINT 'TABLE ' + @newtablename + ': SET LOCAL NAME'
	UPDATE [string]
	SET en_us = @newtablelocalname_en_us
		, sv = @newtablelocalname_sv
	WHERE [idstring] = @localname

	-- Set local name plural
	PRINT 'TABLE ' + @newtablename + ': SET LOCAL NAME PLURAL'
	SET @idstring = NULL
	EXEC	dbo.lsp_addstring
			@@idcategory = 17
			, @@string = @newtablelocalnameplural_sv
			, @@lang = 'sv'
			, @@idstring = @idstring OUTPUT

	EXEC	dbo.lsp_setstring
			@@idstring = @idstring
			, @@lang = N'en_us'
			, @@string = @newtablelocalnameplural_en_us

	EXEC lsp_addattributedata
		@@owner	= N'table',
		@@idrecord = @idtable,
		@@idrecord2 = NULL,
		@@name = N'localnameplural',
		@@value	=  @idstring

	EXEC [dbo].[lsp_settableattributevalue] @@idtable = @idtable, @@name = N'invisible', @@valueint = 2	--Osynlig för alla utom Administratörer

	-----------------------------------------
	------------ CREATE FIELDS ! ------------

	SET @fieldname = N'owner'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null


	EXEC	@return_value = [dbo].[lsp_addfield]
			@@table = @newtablename,
			@@name = @fieldname,
			@@fieldtype = 1,					--Textfält
			@@length = 64,
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
			
			
	UPDATE [string] SET en_us = 'Owner', sv = 'Ägare' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'width', @@valueint = 6
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 2	--Fast bredd


	SET @fieldname = N'code'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null


	EXEC	@return_value = [dbo].[lsp_addfield]
			@@table = @newtablename,
			@@name = @fieldname,
			@@fieldtype = 1,					--Textfält
			@@length = 32,
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
			
			
	UPDATE [string] SET en_us = 'Text code', sv = 'Textkod' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'width', @@valueint = 6
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 2	--Fast bredd
	

	SET @fieldname = N'lookupcode'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null


	EXEC	@return_value = [dbo].[lsp_addfield]
			@@table = @newtablename,
			@@name = @fieldname,
			@@fieldtype = 1,					--Textfält
			@@length = 128,
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
			
			
	UPDATE [string] SET en_us = 'VBA Lookup code', sv = 'VBA Lookup code' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'width', @@valueint = 6
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 3	--Fast bredd på ny rad
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'limereadonly', @@valueint = 1	--Skrivskyddad (endast i Lime)
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'onsqlupdate', @@value = N'N''Localize.GetText("'' + [localize].[owner] + N''", "'' + [localize].[code] + N''")'''	--SQL vid uppdatering
	
	
	SET @fieldname = N'formtag'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null


	EXEC	@return_value = [dbo].[lsp_addfield]
			@@table = @newtablename,
			@@name = @fieldname,
			@@fieldtype = 1,					--Textfält
			@@length = 256,
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
			
			
	UPDATE [string] SET en_us = 'VBA Form tag', sv = 'VBA Formulär-tag' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'width', @@valueint = 6
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 2	--Fast bredd
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'limereadonly', @@valueint = 1	--Skrivskyddad (endast i Lime)
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'onsqlupdate', @@value = N'N''<localize owner="'' + [localize].[owner] + N''" code="'' + [localize].[code] + N''"/>'''	--SQL vid uppdatering
	
	
	
	SET @fieldname = N'aplocalizecode'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null


	EXEC	@return_value = [dbo].[lsp_addfield]
			@@table = @newtablename,
			@@name = @fieldname,
			@@fieldtype = 1,					--Textfält
			@@length = 128,
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
			
			
	UPDATE [string] SET en_us = 'Actionpad translation code', sv = 'Actionpad översättningskod' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'width', @@valueint = 6
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 2	--Fast bredd
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'limereadonly', @@valueint = 1	--Skrivskyddad (endast i Lime)
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'onsqlupdate', @@value = N'CASE WHEN [localize].[owner] <> N'''' AND [localize].[code] <> N'''' THEN N''localize.'' + [localize].[owner] + N''.'' + [localize].[code] ELSE N'''' END'	--SQL vid uppdatering
	
	
	SET @fieldname = N'context'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null


	EXEC	@return_value = [dbo].[lsp_addfield]
			@@table = @newtablename,
			@@name = @fieldname,
			@@fieldtype = 1,					--Textfält
			@@length = 512,
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
			
			
	UPDATE [string] SET en_us = 'Context', sv = 'Kontext' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'width', @@valueint = 12
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 3	--Fast bredd på ny rad
	
	
	
	SET @fieldname = N'sv'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null


	EXEC	@return_value = [dbo].[lsp_addfield]
			@@table = @newtablename,
			@@name = @fieldname,
			@@fieldtype = 1,					--Textfält
			@@length = 0,
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
			
			
	UPDATE [string] SET en_us = 'Swedish', sv = 'Svenska' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'height', @@valueint = 2	--Höjd
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 1	--Variabel bredd på ny rad
	
	
	SET @fieldname = N'en_us'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null


	EXEC	@return_value = [dbo].[lsp_addfield]
			@@table = @newtablename,
			@@name = @fieldname,
			@@fieldtype = 1,					--Textfält
			@@length = 0,
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
			
			
	UPDATE [string] SET en_us = 'English', sv = 'Engelska' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'height', @@valueint = 2	--Höjd
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 1	--Variabel bredd på ny rad
	
	
	SET @fieldname = N'no'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null


	EXEC	@return_value = [dbo].[lsp_addfield]
			@@table = @newtablename,
			@@name = @fieldname,
			@@fieldtype = 1,					--Textfält
			@@length = 0,
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
			
			
	UPDATE [string] SET en_us = 'Norwegian', sv = 'Norska' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'height', @@valueint = 2	--Höjd
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 1	--Variabel bredd på ny rad
	
	
	SET @fieldname = N'da'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null


	EXEC	@return_value = [dbo].[lsp_addfield]
			@@table = @newtablename,
			@@name = @fieldname,
			@@fieldtype = 1,					--Textfält
			@@length = 0,
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
			
			
	UPDATE [string] SET en_us = 'Danish', sv = 'Danska' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'height', @@valueint = 2	--Höjd
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 1	--Variabel bredd på ny rad
	
	
	
	SET @fieldname = N'fi'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null


	EXEC	@return_value = [dbo].[lsp_addfield]
			@@table = @newtablename,
			@@name = @fieldname,
			@@fieldtype = 1,					--Textfält
			@@length = 0,
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
			
			
	UPDATE [string] SET en_us = 'Finnish', sv = 'Finska' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'height', @@valueint = 2	--Höjd
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 1	--Variabel bredd på ny rad
	
	-----------------------------------------


	-- Set table descriptive
	PRINT 'TABLE ' + @newtablename + ': SET DESCRIPTIVE EXPRESSION'
	EXEC	dbo.lsp_setstring
			@@idstring = @descriptive
			, @@lang = N'ALL'
			, @@string = @descriptiveexpression



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