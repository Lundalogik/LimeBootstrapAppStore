-- This script will add the necessary invoicerow table and and fields for the VISMA connector module

BEGIN TRY
	BEGIN TRANSACTION

	--CREATE invoicerow TABLE AND FIELDS IF invoicerow DOESN'T EXIST AND invoice DO EXIST
	IF(NOT EXISTS(SELECT * 
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_SCHEMA = 'dbo'
		AND TABLE_NAME = 'invoicerow'))
	AND(EXISTS(SELECT * 
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_SCHEMA = 'dbo'
		AND TABLE_NAME = 'invoice'))
	BEGIN
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

		SET @return_value = null
		SET @name = N'invoicerow'
		PRINT N'CREATE TABLE: ' + @name
		SET @idtable = null
		SET @localname = null
		SET @descriptive = null
		SET @sql = N''

		EXEC @return_value = [dbo].[lsp_addtable]
			@@name = @name,
			@@idtable = @idtable OUTPUT,
			@@localname = @localname OUTPUT,
			@@descriptive = @descriptive OUTPUT,
			@@sql = @sql

		UPDATE [string] SET en_us = N'Invoice Row', sv = N'Fakturarad', [no] = N'Fakturarad', fi = N'Fakturarad' WHERE [idstring] = @localname
		--CREATE PLURAL NAME
		DECLARE @tempstringid INT

		INSERT INTO [string] (idcategory, sv, en_us, [no], fi) 
		VALUES (17, N'Fakturarader', N'Invoicerows', N'Invoicerows', N'Invoicerows')
		SELECT TOP(1) @tempstringid = idstring FROM string ORDER BY idstring DESC

		INSERT INTO attributedata (owner, idrecord, name, value)
		VALUES (N'table', @idtable, N'localnameplural', @tempstringid)

		----CREATE RELATION FIELD invoice
		DECLARE @ftable NVARCHAR(128)
		, @fname NVARCHAR(128)
		, @f_localname_sv NVARCHAR(128)
		, @f_localname_en NVARCHAR(128)
		, @t_table NVARCHAR(128)
		, @t_name NVARCHAR(128)
		, @t_localname_sv NVARCHAR(128)
		, @t_localname_en NVARCHAR(128)

		SET @ftable = N'invoicerow'
		SET @fname = N'invoice'
		SET @f_localname_sv = N'Faktura'
		SET @f_localname_en = N'Invoice'
		SET @t_table = N'invoice'
		SET @t_name = N'invoicerow'
		SET @t_localname_sv = N'Fakturarader'
		SET @t_localname_en = N'Invoice rows'

		EXEC [dbo].[csp_scriptfield_relation_oneToMany]
           @field_table = @ftable, 
           @field_name = @fname, 
           @field_localname_sv = @f_localname_sv, 
           @field_localname_en = @f_localname_en, 
           @tab_table = @t_table, 
           @tab_name = @t_name, 
           @tab_localname_sv = @t_localname_sv, 
           @tab_localname_en = @t_localname_en

		SELECT @idtable = idtable FROM [table] where name = 'invoicerow'
		SELECT @idfield = idfield FROM field where idtable = @idtable AND name = 'invoice'

		--CREATE TEXT FIELD item
		SET @tablename = N'invoicerow'
		SET @fieldname = N'item'
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
		@@length = 128,						--Behövs endast om textfält
		@@defaultvalue = @defaultvalue OUTPUT,
		@@idfield = @idfield OUTPUT,
		@@localname = @localname OUTPUT,
		@@idcategory = @idcategory OUTPUT
				
		UPDATE [string] SET en_us = N'Item', sv = N'Artikel', [no] = N'Artikkel', fi = N'Artikkeli' WHERE [idstring] = @localname

		--CREATE TEXT FIELD description
		SET @tablename = N'invoicerow'
		SET @fieldname = N'description'
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
		@@length = 128,						--Behövs endast om textfält
		@@defaultvalue = @defaultvalue OUTPUT,
		@@idfield = @idfield OUTPUT,
		@@localname = @localname OUTPUT,
		@@idcategory = @idcategory OUTPUT
						
		UPDATE [string] SET en_us = N'Description', sv = N'Beskrivning', [no] = N'Beskrivelse', fi = N'Kuvaus' WHERE [idstring] = @localname

		--CREATE DECIMAL FIELD units
		SET @tablename = N'invoicerow'
		SET @fieldname = N'units'
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
						
		UPDATE [string] SET en_us = N'Units', sv = N'Antal', [no] = N'Antall', fi = N'Määrä' WHERE [idstring] = @localname

		--CREATE DECIMAL FIELD row_value
		SET @tablename = N'invoicerow'
		SET @fieldname = N'row_value'
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
						
		UPDATE [string] SET en_us = N'Amount', sv = N'Summa', [no] = N'Sum', fi = N'Koko' WHERE [idstring] = @localname

		--CREATE TEXT FIELD rowid
		SET @tablename = N'invoicerow'
		SET @fieldname = N'rowid'
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
		@@length = 32,						--Behövs endast om textfält
		@@defaultvalue = @defaultvalue OUTPUT,
		@@idfield = @idfield OUTPUT,
		@@localname = @localname OUTPUT,
		@@idcategory = @idcategory OUTPUT
						
		UPDATE [string] SET en_us = N'Row ID', sv = N'Rad ID', [no] = N'Rad ID', fi = N'Row ID' WHERE [idstring] = @localname
		EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'invisible', @@valueint = 1	--Osynligt på kort

	END
	ELSE
	BEGIN
		PRINT N'invoicerow TABLE ALREADY EXISTS AND/OR invoice TABLE DOES NOT EXIST'
	END

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