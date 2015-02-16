-- This script creates the necessary admin table for the app newscarousel
-- No configuration is needed, just cross your fingers and run it!

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
			, @newtablelocalname_da NVARCHAR(64)
			, @newtablelocalname_no NVARCHAR(64)
			, @newtablelocalname_fi NVARCHAR(64)
			, @newtablelocalnameplural_sv NVARCHAR(64)
			, @newtablelocalnameplural_en_us NVARCHAR(64)
			, @newtablelocalnameplural_da NVARCHAR(64)
			, @newtablelocalnameplural_no NVARCHAR(64)
			, @newtablelocalnameplural_fi NVARCHAR(64)
			, @tableorder INT
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

	---------------------------------------------
	--------------- TABLE NAMES -----------------
	SET @newtablename = N'newscarousel'
	SET @newtablelocalname_sv = N'Nyhet'
	SET @newtablelocalname_en_us = N'News'
	SET @newtablelocalname_da = N'Nyhed'
	SET @newtablelocalname_no = N'Nyhet'
	SET @newtablelocalname_fi = N'Uutiset'
	SET @newtablelocalnameplural_sv = N'Nyheter'
	SET @newtablelocalnameplural_en_us = N'News'
	SET @newtablelocalnameplural_da = N'Nyheder'
	SET @newtablelocalnameplural_no = N'Nyheter'
	SET @newtablelocalnameplural_fi = N'Uutiset'
	---------------------------------------------

	-- ##TODO: Behövs kod för att räkna fram table order om den ska hamna sist??
	-- SET @tableorder = (SELECT )

	PRINT N'CREATE TABLE: ' + @newtablename
	EXEC [dbo].[lsp_addtable]
		@@name = @newtablename
		, @@idtable = @idtable OUTPUT
		, @@localname = @localname OUTPUT
		, @@descriptive = @descriptive OUTPUT
		, @@transactionid = @transid
		, @@user = 1

	-- Set local name
	PRINT N'TABLE ' + @newtablename + N': SET LOCAL NAME'
	UPDATE [string]
	SET en_us = @newtablelocalname_en_us
		, sv = @newtablelocalname_sv
		, da = @newtablelocalname_da
		, [no] = @newtablelocalname_no
		, fi = @newtablelocalname_fi
	WHERE [idstring] = @localname

	-- Set local name plural
	PRINT N'TABLE ' + @newtablename + N': SET LOCAL NAME PLURAL'
	SET @idstring = NULL
	EXEC	dbo.lsp_addstring
			@@idcategory = 17
			, @@string = @newtablelocalnameplural_sv
			, @@lang = N'sv'
			, @@idstring = @idstring OUTPUT

	EXEC [dbo].[lsp_setstring]
		@@idstring = @idstring
		, @@lang = N'en_us'
		, @@string = @newtablelocalnameplural_en_us

	EXEC [dbo].[lsp_setstring]
		@@idstring = @idstring
		, @@lang = N'da'
		, @@string = @newtablelocalnameplural_da

	EXEC [dbo].[lsp_setstring]
		@@idstring = @idstring
		, @@lang = N'no'
		, @@string = @newtablelocalnameplural_no

	EXEC [dbo].[lsp_setstring]
		@@idstring = @idstring
		, @@lang = N'fi'
		, @@string = @newtablelocalnameplural_fi

	EXEC lsp_addattributedata
		@@owner	= N'table',
		@@idrecord = @idtable,
		@@idrecord2 = NULL,
		@@name = N'localnameplural',
		@@value	=  @idstring

	PRINT N'TABLE ' + @newtablename + N': SET VISIBILITY SETTING'
	EXEC [dbo].[lsp_settableattributevalue] @@idtable = @idtable, @@name = N'invisible', @@valueint = 2	--Osynlig för alla utom Administratörer

	PRINT N'TABLE ' + @newtablename + N': SET POLICY'
	EXEC lsp_setattributevalue @@owner = N'table', @@idrecord = @idtable, @@name = N'idpolicy', @@valueint = 1	--1 = administrators

	---- Set table order
	--PRINT 'TABLE ' + @newtablename + ': SET TABLE ORDER'
	--EXEC lsp_setattributevalue
	--	@@owner = N'table'
	--	, @@idrecord = @idtable
	--	, @@name = N'tableorder'
	--	, @@valueint = @tableorder



	---------------------------------------------
	------------ CREATE FIELDS START ------------
	--VARIABLER
	--DECLARE	@return_value INT
	--	, @defaultvalue NVARCHAR(128)
	--	, @idfield INT
	--	, @localname INT
	--	, @idcategory INT
	--	, @idstring INT
	--	, @sqlcommand NVARCHAR(2048)
	--	, @fieldname NVARCHAR(64)



	SET @fieldname = N'headline'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null

	EXEC @return_value = [dbo].[lsp_addfield]
		@@table = @newtablename,
		@@name = @fieldname,
		@@fieldtype = 1,					--Textfält
		@@length = 32,						--Behövs endast om textfält
		@@defaultvalue = @defaultvalue OUTPUT,
		@@idfield = @idfield OUTPUT,
		@@localname = @localname OUTPUT,
		@@idcategory = @idcategory OUTPUT

	UPDATE [string]
	SET en_us = N'Headline'
		, sv = N'Rubrik'
		, da = N'Sidehoved'
		, [no] = N'Overskrift'
		, fi = N'Otsikko'
	WHERE [idstring] = @localname

	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'width', @@valueint = 4
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 2	--Fast bredd



	SET @fieldname = N'text'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null

	EXEC @return_value = [dbo].[lsp_addfield]
		@@table = @newtablename,
		@@name = @fieldname,
		@@fieldtype = 1,					--Textfält
		@@length = 128,						--Behövs endast om textfält
		@@defaultvalue = @defaultvalue OUTPUT,
		@@idfield = @idfield OUTPUT,
		@@localname = @localname OUTPUT,
		@@idcategory = @idcategory OUTPUT

	UPDATE [string]
	SET en_us = N'Text'
		, sv = N'Brödtext'
		, da = N'Brudtekst'
		, [no] = N'Brødtekst'
		, fi = N'Kuvaus'
	WHERE [idstring] = @localname

	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'width', @@valueint = 4
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'height', @@valueint = 4	--Höjd
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 3	--Fast bredd på ny rad



	SET @fieldname = N'startdate'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null

	EXEC @return_value = [dbo].[lsp_addfield]
		@@table = @newtablename,
		@@name = @fieldname,
		@@fieldtype = 7,					--Datumfält
		@@defaultvalue = @defaultvalue OUTPUT,
		@@idfield = @idfield OUTPUT,
		@@localname = @localname OUTPUT,
		@@idcategory = @idcategory OUTPUT

	UPDATE [string]
	SET en_us = N'Start date'
		, sv = N'Startdatum'
		, da = N'Start dato'
		, [no] = N'Startdato'
		, fi = N'Aloitusaika'
	WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'width', @@valueint = 2
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'type', @@valueint = 1		--Format: Datum, tid
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'required', @@valueint = 1  --Obligatoriskt
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 3	--Fast bredd på ny rad


	SET @fieldname = N'enddate'
	PRINT N'CREATE FIELD: ' + @newtablename + '.' + @fieldname
	SET @return_value = null
	SET @defaultvalue = ''
	SET @idfield = null
	SET @localname = null
	SET @idcategory = null
	SET @idstring = null

	EXEC @return_value = [dbo].[lsp_addfield]
		@@table = @newtablename,
		@@name = @fieldname,
		@@fieldtype = 7,					--Datumfält
		@@isnullable = 1,
		@@defaultvalue = @defaultvalue OUTPUT,
		@@idfield = @idfield OUTPUT,
		@@localname = @localname OUTPUT,
		@@idcategory = @idcategory OUTPUT

	UPDATE [string]
	SET en_us = N'End date'
		, sv = N'Slutdatum'
		, da = N'Slut dato'
		, [no] = N'Sluttdato'
		, fi = N'Lopetusaika'
	WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'width', @@valueint = 2
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'type', @@valueint = 1		--Format: Datum, tid
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 2	--Fast bredd


	---------------------------------------------
	----------- CREATE RELATION START -----------

	-- Special relation variables.
	DECLARE @idfield1 INT		--Field
	DECLARE @idfield2 INT		--Tab
	DECLARE @idtable1 INT		--Table with field
	DECLARE @idtable2 INT		--Table with tab
	DECLARE @idrelation INT
	DECLARE @nameoftablewithfield NVARCHAR(64)
	DECLARE @relationfieldname NVARCHAR(64)
	DECLARE @nameoftablewithtab NVARCHAR(64)
	DECLARE @relationtabname NVARCHAR(64)

	SET @idfield1 = NULL
	SET @idfield2 = NULL
	SET @idtable1 = NULL
	SET @idtable2 = NULL
	SET @idrelation = NULL

	SET @nameoftablewithfield = @newtablename
	SET @relationfieldname = N'coworker'
	SET @nameoftablewithtab = N'coworker'
	SET @relationtabname = @newtablename

	PRINT N'CREATE FIELD: ' + @nameoftablewithfield + '.' + @relationfieldname
	SET @return_value = NULL
	SET @defaultvalue = ''
	SET @idfield1 = NULL
	SET @localname = NULL
	SET @idcategory = NULL
	SET @idstring = NULL

	EXEC @return_value = [dbo].[lsp_addfield]
		@@table = @nameoftablewithfield,
		@@name = @relationfieldname,
		@@fieldtype = 16,					--Relationsfält
		@@defaultvalue = @defaultvalue OUTPUT,
		@@idfield = @idfield1 OUTPUT,
		@@localname = @localname OUTPUT,
		@@idcategory = @idcategory OUTPUT

	UPDATE [string]
	SET en_us = N'Coworker'
		, sv = N'Medarbetare'
		, da = N'Kollega'
		, [no] = N'Medarbeider'
		, fi = N'Työntekijä'
	WHERE [idstring] = @localname

	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield1, @@name = N'width', @@valueint = 2
	EXEC lsp_setattributevalue @@owner = N'field', @@idrecord = @idfield1, @@name = N'relationmincount', @@value = 0
	EXEC lsp_setattributevalue @@owner = N'field', @@idrecord = @idfield1, @@name = N'limedefaultvalue', @@value = N'ActiveUser.Record.ID'	-- Default Value (interpreted by LIME Pro)
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield1, @@name = N'newline', @@valueint = 3	--Fast bredd på ny rad

	PRINT N'CREATE FIELD: ' + @nameoftablewithtab + '.' + @relationtabname
	SET @return_value = NULL
	SET @defaultvalue = ''
	SET @idfield2 = NULL
	SET @localname = NULL
	SET @idcategory = NULL
	SET @idstring = NULL

	EXEC @return_value = [dbo].[lsp_addfield]
		@@table = @nameoftablewithtab,
		@@name = @relationtabname,
		@@fieldtype = 16,					--Relationsfält
		@@defaultvalue = @defaultvalue OUTPUT,
		@@idfield = @idfield2 OUTPUT,
		@@localname = @localname OUTPUT,
		@@idcategory = @idcategory OUTPUT

	UPDATE [string]
	SET en_us = @newtablelocalname_en_us
		, sv = @newtablelocalname_sv
		, da = @newtablelocalname_da
		, [no] = @newtablelocalname_no
		, fi = @newtablelocalname_fi
	WHERE [idstring] = @localname

	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield2, @@name = N'invisible', @@valueint = 65535	--Överallt

	EXEC lsp_setattributevalue @@owner = N'field', @@idrecord = @idfield2, @@name = N'relationmincount', @@value = 0
	EXEC lsp_setattributevalue @@owner = N'field', @@idrecord = @idfield2, @@name = N'relationmaxcount', @@value = 1


	PRINT N'ADD RELATION: ' + @nameoftablewithfield + ' - ' + @nameoftablewithtab
	SELECT @idtable1 = idtable
	FROM [table]
	WHERE [name] = @nameoftablewithfield

	SELECT @idtable2 = idtable
	FROM [table]
	WHERE [name] = @nameoftablewithtab

	EXEC @return_value = lsp_addrelation
		@@idfield1 = @idfield1,
		@@idtable1 = @idtable1,
		@@idfield2 = @idfield2,
		@@idtable2 = @idtable2,
		@@idrelation = @idrelation OUTPUT

	------------ CREATE RELATION END ------------
	---------------------------------------------


	SET @fieldname = N'inactive'
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
			@@fieldtype = 13,					--Ja/Nej-fält
			@@defaultvalue = @defaultvalue OUTPUT,
			@@idfield = @idfield OUTPUT,
			@@localname = @localname OUTPUT,
			@@idcategory = @idcategory OUTPUT


	UPDATE [string]
	SET en_us = N'Inactive'
		, sv = N'Inaktiv'
		, da = N'Inaktiv'
		, [no] = N'Inaktiv'
		, fi = N'Toimeton'
	WHERE [idstring] = @localname
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'width', @@valueint = 2
	EXEC [dbo].[lsp_setfieldattributevalue] @@idfield = @idfield, @@name = N'newline', @@valueint = 2	--Fast bredd


	------------- CREATE FIELDS END -------------
	---------------------------------------------



	-- Set table descriptive
	SET @descriptiveexpression = N'[' + @newtablename + N'].[headline]'
	PRINT N'TABLE ' + @newtablename + N': SET DESCRIPTIVE EXPRESSION'
	EXEC [dbo].[lsp_setstring]
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
GO

EXEC lsp_refreshldc
EXEC lsp_refreshcaches

GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Niklas Olsson
-- Description:	Returns a xml with data for the news carousel app.
-- =============================================
CREATE PROCEDURE csp_app_newscarousel_getxml
	@@lang NVARCHAR(32) = N''
	, @@idcoworker INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

    -- FLAG_EXTERNALACCESS --

	SELECT TOP 5 nc.headline
		, nc.[text]
		, c.firstname + ' ' + c.lastname AS 'coworker'
		, CONVERT(NVARCHAR(10), nc.startdate, 120) AS 'date'
	FROM newscarousel nc
	INNER JOIN dbo.coworker c
		ON nc.coworker = c.idcoworker
	WHERE nc.inactive = 0
		AND ISNULL(nc.enddate,'2990-11-01') > GETDATE()
		AND nc.[status] = 0
	FOR XML PATH('news')

END
GO

EXEC lsp_refreshldc

GO