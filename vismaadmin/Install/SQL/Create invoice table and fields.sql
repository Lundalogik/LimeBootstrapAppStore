-- This script will add the necessary invoice tables and fields for the VISMA connector module

BEGIN TRY
	BEGIN TRANSACTION

	--CREATE invoice TABLE AND FIELDS IF invoice dont exist AND company AND coworker DO EXIST
	IF(NOT EXISTS(SELECT * 
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_SCHEMA = 'dbo'
		AND TABLE_NAME = 'invoice'))
	AND(EXISTS(SELECT * 
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_SCHEMA = 'dbo'
		AND TABLE_NAME = 'company'))
		AND (EXISTS(SELECT * 
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_SCHEMA = 'dbo'
		AND TABLE_NAME = 'coworker'))
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
		SET @name = N'invoice'
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

		UPDATE [string] SET en_us = N'Invoice', sv = N'Faktura', [no] = N'Faktura', fi = N'Lasku' WHERE [idstring] = @localname
		--CREATE PLURAL NAME
		DECLARE @tempstringid INT

		INSERT INTO [string] (idcategory, sv, en_us, [no], fi) 
		VALUES (17, N'Fakturor', N'Invoices', N'Invoices', N'Invoices')
		SELECT TOP(1) @tempstringid = idstring FROM string ORDER BY idstring DESC

		INSERT INTO attributedata (owner, idrecord, name, value)
		VALUES (N'table', @idtable, N'localnameplural', @tempstringid)

		--CREATE TEXT FIELD invoice_number
		SET @tablename = N'invoice'
		SET @fieldname = N'invoice_number'
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
			@@length = 64,						--Behövs endast om textfält
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
				
		UPDATE [string] SET en_us = N'Invoice Number', sv = N'Fakturanummer', [no] = N'Fakturanummer', fi = N'Laskun Numero' WHERE [idstring] = @localname

		--CREATE RELATION FIELD company
		DECLARE @ftable NVARCHAR(128)
		, @fname NVARCHAR(128)
		, @f_localname_sv NVARCHAR(128)
		, @f_localname_en NVARCHAR(128)
		, @t_table NVARCHAR(128)
		, @t_name NVARCHAR(128)
		, @t_localname_sv NVARCHAR(128)
		, @t_localname_en NVARCHAR(128)

		SET @ftable = N'invoice'
		SET @fname = N'company'
		SET @f_localname_sv = N'Företag'
		SET @f_localname_en = N'Company'
		SET @t_table = N'company'
		SET @t_name = N'invoice'
		SET @t_localname_sv = N'Fakturor'
		SET @t_localname_en = N'Invoices'

		EXEC [dbo].[csp_scriptfield_relation_oneToMany]
           @field_table = @ftable, 
           @field_name = @fname, 
           @field_localname_sv = @f_localname_sv, 
           @field_localname_en = @f_localname_en, 
           @tab_table = @t_table, 
           @tab_name = @t_name, 
           @tab_localname_sv = @t_localname_sv, 
           @tab_localname_en = @t_localname_en
			
		SELECT @idtable = idtable FROM [table] where name = 'invoice'
		SELECT @idfield = idfield FROM field where idtable = @idtable AND name = 'company'

		--CREATE TEXT FIELD customerid
		SET @tablename = N'invoice'
		SET @fieldname = N'customerid'
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
						
		UPDATE [string] SET en_us = N'Customer Number', sv = N'Kundnummer', [no] = N'Kundenummer', fi = N'Asiakasnumero' WHERE [idstring] = @localname

		--CREATE TEXT FIELD customer_reference
		SET @tablename = N'invoice'
		SET @fieldname = N'customer_reference'
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
			@@length = 256,						--Behövs endast om textfält
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
						
		UPDATE [string] SET en_us = N'Customers Reference', sv = N'Kundens Referens', [no] = N'Kundens Referanse', fi = N'Asiakkaan Viite' WHERE [idstring] = @localname

		----CREATE RELATION FIELD coworker
		SET @ftable = N'invoice'
		SET @fname = N'coworker'
		SET @f_localname_sv = N'Vår referens'
		SET @f_localname_en = N'Our reference'
		SET @t_table = N'coworker'
		SET @t_name = N'invoice'
		SET @t_localname_sv = N'Fakturor'
		SET @t_localname_en = N'Invoices'

		EXEC [dbo].[csp_scriptfield_relation_oneToMany]
           @field_table = @ftable, 
           @field_name = @fname, 
           @field_localname_sv = @f_localname_sv, 
           @field_localname_en = @f_localname_en, 
           @tab_table = @t_table, 
           @tab_name = @t_name, 
           @tab_localname_sv = @t_localname_sv, 
           @tab_localname_en = @t_localname_en

		SELECT @idtable = idtable FROM [table] where name = 'invoice'
		SELECT @idfield = idfield FROM field where idtable = @idtable AND name = 'coworker'

		--CREATE TEXT FIELD invoice_type
		SET @tablename = N'invoice'
		SET @fieldname = N'invoice_type'
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
			@@length = 64,						--Behövs endast om textfält
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
						
		UPDATE [string] SET en_us = N'Type', sv = N'Typ', [no] = N'Type', fi = N'Tyyppi' WHERE [idstring] = @localname
		EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 3	--NewLine

		--CREATE TEXT FIELD serie
		SET @tablename = N'invoice'
		SET @fieldname = N'serie'
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
			@@length = 64,						--Behövs endast om textfält
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
						
		UPDATE [string] SET en_us = N'Series', sv = N'Serie', [no] = N'Serie', fi = N'Sarja' WHERE [idstring] = @localname

		--CREATE DATE FIELD invoice_date
		SET @tablename = N'invoice'
		SET @fieldname = N'invoice_date'
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
			@@fieldtype = 7,					--Date field
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
						
		UPDATE [string] SET en_us = N'Invoice Date', sv = N'Fakturadatum', [no] = N'Fakturadato', fi = N'Laskutus päivämäärä' WHERE [idstring] = @localname
		EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'isnullable', @@valueint = 1	--nullable
		EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'defaultvalue', @@valueint = null	--default

		--CREATE DATE FIELD invoice_expires
		SET @tablename = N'invoice'
		SET @fieldname = N'invoice_expires'
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
			@@fieldtype = 7,					--Date field
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
						
		UPDATE [string] SET en_us = N'Due Date', sv = N'Förfallodatum', [no] = N'Forfallsdato', fi = N'Eräpäivä' WHERE [idstring] = @localname
		EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'isnullable', @@valueint = 1	--nullable
		EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'defaultvalue', @@valueint = null	--default

		--CREATE DECIMAL FIELD invoice_sum
		SET @tablename = N'invoice'
		SET @fieldname = N'invoice_sum'
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
	
		UPDATE [string] SET en_us = N'Amount', sv = N'Belopp ex moms', [no] = N'Beløp ex mom', fi = N'Määrä ex ALV' WHERE [idstring] = @localname
		EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 3	--NewLine

		--CREATE DECIMAL FIELD invoice_vat
		SET @tablename = N'invoice'
		SET @fieldname = N'invoice_vat'
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
						
		UPDATE [string] SET en_us = N'VAT', sv = N'Moms', [no] = N'Moms', fi = N'VAT' WHERE [idstring] = @localname

		--CREATE DECIMAL FIELD invoice_total_sum
		SET @tablename = N'invoice'
		SET @fieldname = N'invoice_total_sum'
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
						
		UPDATE [string] SET en_us = N'Total Amount', sv = N'Total Belopp', [no] = N'Totalt Beløp', fi = N'Kokonaismäärä' WHERE [idstring] = @localname

		--CREATE DECIMAL FIELD invoice_balance
		SET @tablename = N'invoice'
		SET @fieldname = N'invoice_balance'
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
						
		UPDATE [string] SET en_us = N'Balance', sv = N'Saldo', [no] = N'Saldo', fi = N'Tasapaino' WHERE [idstring] = @localname

		--CREATE YES/NO FIELD paid
		SET @tablename = N'invoice'
		SET @fieldname = N'paid'
		PRINT N'CREATE FIELD: ' + @tablename + '.' + @fieldname
		SET @return_value = null
		SET @defaultvalue = 0
		SET @idfield = null
		SET @localname = null
		SET @idcategory = null
		SET @idstring = null

		EXEC @return_value = [dbo].[lsp_addfield]
			@@table = @tablename,
			@@name = @fieldname,
			@@fieldtype = 13,					--Ja/Nej-fält
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
						
		UPDATE [string] SET en_us = N'Paid', sv = N'Betald', [no] = N'Betalt', fi = N'Maksettu' WHERE [idstring] = @localname
		EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 3	--NewLine

		--CREATE DATE FIELD invoice_expires
		SET @tablename = N'invoice'
		SET @fieldname = N'paid_date'
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
			@@fieldtype = 7,					--Date field
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT

		UPDATE [string] SET en_us = N'Payment Date', sv = N'Betalningsdatum', [no] = N'Betalingsdato', fi = N'Maksupäivä' WHERE [idstring] = @localname
		EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'isnullable', @@valueint = 1	--nullable
		EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'defaultvalue', @@valueint = null	--default

		--CREATE YES/NO FIELD shredded
		SET @tablename = N'invoice'
		SET @fieldname = N'invoice_shredded'
		PRINT N'CREATE FIELD: ' + @tablename + '.' + @fieldname
		SET @return_value = null
		SET @defaultvalue = 0
		SET @idfield = null
		SET @localname = null
		SET @idcategory = null
		SET @idstring = null

		EXEC @return_value = [dbo].[lsp_addfield]
			@@table = @tablename,
			@@name = @fieldname,
			@@fieldtype = 13,					--Ja/Nej-fält
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT
						
		UPDATE [string] SET en_us = N'Shredded', sv = N'Makulerad', [no] = N'Makulert', fi = N'Silputtu' WHERE [idstring] = @localname

	END
	ELSE
	BEGIN
		PRINT N'invoice TABLE ALREADY EXISTS AND/OR company AND/OR person TABLE DOES NOT EXIST'
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