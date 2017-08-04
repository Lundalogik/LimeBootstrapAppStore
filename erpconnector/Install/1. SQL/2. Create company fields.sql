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

	--CREATE INTEGER FIELD erpid
	SET @tablename = N'company'
	SET @fieldname = N'erpid'
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
				
	UPDATE [string] SET en_us = N'Customer number ERP', sv = N'Kundnummer ERP', [no] = N'Kundenummer ERP', da = N'Kundenummer ERP', fi = N'Asiakasnumero (ERP)' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'limereadonly', @@valueint = 1	--ReadOnly
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 3	--NewLine
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'isnullable', @@valueint = 1	--nullable
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'defaultvalue', @@valueint = null	--default
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'label', @@valueint = 2	--label = 2 = key

	--CREATE DECIMAL FIELD erp_turnover_yearnow
	SET @tablename = N'company'
	SET @fieldname = N'erp_turnover_yearnow'
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
						
	UPDATE [string] SET en_us = N'Turnover this year ERP', sv = N'Omsättning i år ERP', [no] = N'Omsetning hittil i år ERP', da = N'Omsætning i år ERP', fi = N'Myynti tänä vuonna (ERP)' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'limereadonly', @@valueint = 1	--ReadOnly
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'isnullable', @@valueint = 1	--nullable
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'defaultvalue', @@valueint = null	--default

	--CREATE DECIMAL FIELD erp_turnover_yearnow
	SET @tablename = N'company'
	SET @fieldname = N'erp_turnover_lastyear'
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
						
	UPDATE [string] SET en_us = N'Turnover last year ERP', sv = N'Omsättning fg år ERP', [no] = N'Omsetning forrige år ERP', da = N'Omsætning sidste år ERP', fi = N'Myynti viime vuonna (ERP)' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'limereadonly', @@valueint = 1	--ReadOnly
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'isnullable', @@valueint = 1	--nullable
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'defaultvalue', @@valueint = null	--default

	--CREATE HTML-field erpconnector_graph
	SET @tablename = N'company'
	SET @fieldname = N'erpconnector_graph'
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
	@@fieldtype = 10,					--html field
	@@defaultvalue = @defaultvalue OUTPUT,
	@@idfield = @idfield OUTPUT,
	@@localname = @localname OUTPUT,
	@@idcategory = @idcategory OUTPUT
						
	UPDATE [string] SET en_us = N'Invoice overview', sv = N'Fakturaöversikt', [no] = N'Fakturaoversikt', da = N'Fakturaoversigt', fi = N'Laskun yleiskatsaus' WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'type', @@valueint = 1	--Tab

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