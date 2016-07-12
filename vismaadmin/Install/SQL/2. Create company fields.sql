-- This script will add the necessary fields in the company table for the VISMA connector module

BEGIN TRY
	BEGIN TRANSACTION

	--VARIABLES
	DECLARE @return_value INT
	, @name NVARCHAR(64)
	, @idtable INT
	, @localname INT
	, @descriptive INT
	, @sql NVARCHAR(256)
	, @defaultvalue NVARCHAR(128)
	, @idfield INT
	, @idcategory INT
	, @idstring INT
	, @sqlcommand NVARCHAR(2048)
	, @fieldname NVARCHAR(64)
	, @tablename NVARCHAR(64)

	--CHECK IF name column exists in the company table, if not create
	IF(EXISTS(SELECT * 
		FROM sys.columns 
		WHERE name = 'name' 
		AND Object_ID = Object_ID(N'company')))
	BEGIN
		PRINT N'name column already exists'
	END
	ELSE
	BEGIN
		--CREATE TEXT FIELD name
		SET @tablename = N'company'
		SET @fieldname = N'name'
		PRINT N'CREATE FIELD: ' + @tablename + '.' + @fieldname
		SET @return_value = null
		SET @defaultvalue = null
		SET @idfield = null
		SET @localname = null
		SET @idcategory = null
		SET @idstring = null

		EXEC @return_value = [dbo].[lsp_addfield]
		@@table = @tablename,
		@@name = @fieldname,
		@@fieldtype = 1,					--Text field
		@@length = 200,						--Behövs endast om textfält
		@@defaultvalue = @defaultvalue OUTPUT,
		@@idfield = @idfield OUTPUT,
		@@localname = @localname OUTPUT,
		@@idcategory = @idcategory OUTPUT
				
		UPDATE [string] SET en_us = N'Company name', sv = N'Företagsnamn', [no] = N'Firmanavn', fi = N'Nimi' WHERE [idstring] = @localname
	END

	--The following columns are created as long as none of them exists in the table from before

	--CREATE INTEGER FIELD vismaid
	SET @tablename = N'company'
	SET @fieldname = N'vismaid'
	PRINT N'CREATE FIELD: ' + @tablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = null
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null

	EXEC @return_value = [dbo].[lsp_addfield]
	@@table = @tablename,
	@@name = @fieldname,
	@@fieldtype = 1,					--Text field
	@@length = 16,						--Behövs endast om textfält
	@@defaultvalue = @defaultvalue OUTPUT,
	@@idfield = @idfield OUTPUT,
	@@localname = @localname OUTPUT,
	@@idcategory = @idcategory OUTPUT
				
	UPDATE [string] SET en_us = N'Customer ID Visma', sv = N'Kundnummer Visma', [no] = N'Kundenummer Visma', fi = N'Vismaid' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'limereadonly', @@valueint = 0	--ReadOnly
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 3	--NewLine
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'isnullable', @@valueint = 1	--nullable
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'defaultvalue', @@valueint = null	--default
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'label', @@valueint = 2	--label = 2 = key

	--CREATE DECIMAL FIELD visma_turnover_yearnow
	SET @tablename = N'company'
	SET @fieldname = N'visma_turnover_yearnow'
	PRINT N'CREATE FIELD: ' + @tablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = null
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null

	EXEC @return_value = [dbo].[lsp_addfield]
	@@table = @tablename,
	@@name = @fieldname,
	@@fieldtype = 4,					--decimal field
	@@defaultvalue = @defaultvalue OUTPUT,
	@@idfield = @idfield OUTPUT,
	@@localname = @localname OUTPUT,
	@@idcategory = @idcategory OUTPUT
						
	UPDATE [string] SET en_us = N'Turnover this year Visma', sv = N'Omsättning i år Visma', [no] = N'Omsetning i år Visma', fi = N'visma_turnover' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'limereadonly', @@valueint = 0	--ReadOnly
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'isnullable', @@valueint = 1	--nullable
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'defaultvalue', @@valueint = null	--default

	--CREATE DECIMAL FIELD visma_turnover_yearnow
	SET @tablename = N'company'
	SET @fieldname = N'visma_turnover_lastyear'
	PRINT N'CREATE FIELD: ' + @tablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = null
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null

	EXEC @return_value = [dbo].[lsp_addfield]
	@@table = @tablename,
	@@name = @fieldname,
	@@fieldtype = 4,					--decimal field
	@@defaultvalue = @defaultvalue OUTPUT,
	@@idfield = @idfield OUTPUT,
	@@localname = @localname OUTPUT,
	@@idcategory = @idcategory OUTPUT
						
	UPDATE [string] SET en_us = N'Turnover last year Visma', sv = N'Omsättning fg år Visma', [no] = N'Omsetning i fjor Visma', fi = N'visma_turnover_lastyear' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'limereadonly', @@valueint = 0	--ReadOnly
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'isnullable', @@valueint = 1	--nullable
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'defaultvalue', @@valueint = null	--default

END TRY
BEGIN CATCH
	DECLARE @errormessage NVARCHAR(512)
	SET @errormessage = ERROR_MESSAGE()
	ROLLBACK TRANSACTION
	RAISERROR(@errormessage, 11, 1)
	RETURN
END CATCH

COMMIT TRANSACTION
GO

EXEC lsp_refreshldc
EXEC lsp_refreshcaches

GO