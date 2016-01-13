-- 
-- DSG
-- =================

-- Block                                   |                                 Version
-- -------                                 |                                 -------
-- csp_scriptfield_relation_oneToMany      |                                     1.0
-- csp_scriptfield_relation_oneToOne       |                                     1.0
-- 
-- 
-- SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT '[csp_scriptfield_relation_oneToMany]'
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[csp_scriptfield_relation_oneToMany]'))
BEGIN DROP PROCEDURE [dbo].[csp_scriptfield_relation_oneToMany] END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

-- DSG
-- version: 1.0
-- component: scriptfield
-- release: 1 | order: 1
-- changelog: 1.0 | 2013-11-18 | MHE | Created
-- END_DSG
-- =============================================
CREATE PROCEDURE [dbo].[csp_scriptfield_relation_oneToMany]
	@field_table NVARCHAR(128),
	@field_name NVARCHAR(128),
	@field_localname_sv NVARCHAR(128),
	@field_localname_en NVARCHAR(128),
	@tab_table NVARCHAR(128),
	@tab_name NVARCHAR(128),
	@tab_localname_sv NVARCHAR(128),
	@tab_localname_en NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION
		   
		/**********************
		DECLARE vars
		**********************/
		DECLARE	@return_value INT
			, @defaultvalue NVARCHAR(128)
			, @idfield INT
			, @localname INT
			, @idcategory INT
			, @idstring INT
			, @sqlcommand NVARCHAR(2048)

		-- Special relation variables.
		DECLARE @idfield1 INT		--Field
		DECLARE @idfield2 INT		--Tab
		DECLARE @idtable1 INT		--Table with field
		DECLARE @idtable2 INT		--Table with tab
		DECLARE @idrelation INT

		-- init vars
		SET @idfield1 = NULL
		SET @idfield2 = NULL
		SET @idtable1 = NULL
		SET @idtable2 = NULL
		SET @idrelation = NULL

		/**********************
		create field 1
		**********************/
		PRINT N'CREATE FIELD (FIELD): ' + @field_table + '.' + @field_name
		SET @return_value = NULL
		SET @defaultvalue = ''
		SET @idfield1 = NULL
		SET @localname = NULL
		SET @idcategory = NULL
		SET @idstring = NULL

		-- create field
		EXEC	@return_value = [dbo].[lsp_addfield]
				@@table = @field_table,
				@@name = @field_name,
				@@fieldtype = 16,					--realationfield
				@@defaultvalue = @defaultvalue OUTPUT,
				@@idfield = @idfield1 OUTPUT,
				@@localname = @localname OUTPUT,
				@@idcategory = @idcategory OUTPUT

		-- set localname
		UPDATE [string] SET sv = @field_localname_sv, en_us = @field_localname_en WHERE [idstring] = @localname
		
		--set realtioncount
		EXEC lsp_setattributevalue @@owner = 'field', @@idrecord = @idfield1, @@name = 'relationmincount', @@value = 0

		/**********************
		create field 2
		**********************/
		PRINT N'CREATE FIELD (TAB): ' + @tab_table + '.' + @tab_name
		SET @return_value = NULL
		SET @defaultvalue = ''
		SET @idfield2 = NULL
		SET @localname = NULL
		SET @idcategory = NULL
		SET @idstring = NULL

		EXEC	@return_value = [dbo].[lsp_addfield]
				@@table = @tab_table,
				@@name = @tab_name,
				@@fieldtype = 16,					--Relationsfält
				@@defaultvalue = @defaultvalue OUTPUT,
				@@idfield = @idfield2 OUTPUT,
				@@localname = @localname OUTPUT,
				@@idcategory = @idcategory OUTPUT

		-- set localname
		UPDATE [string] SET sv = @tab_localname_sv, en_us = @tab_localname_en WHERE [idstring] = @localname

		--set realtioncount
		EXEC lsp_setattributevalue @@owner = 'field', @@idrecord = @idfield2, @@name = 'relationmincount', @@value = 0
		EXEC lsp_setattributevalue @@owner = 'field', @@idrecord = @idfield2, @@name = 'relationmaxcount', @@value = 1

		/**********************
		add relation
		**********************/
		PRINT N'ADD RELATION: ' + @field_table + ' - ' + @tab_table
		
		SELECT @idtable1 = idtable
		FROM [table]
		WHERE [name] = @field_table

		SELECT @idtable2 = idtable
		FROM [table]
		WHERE [name] = @tab_table

		EXEC	@return_value = lsp_addrelation
				@@idfield1 = @idfield1,	--exempel: countrycode
				@@idtable1 = @idtable1,	--exempel: person
				@@idfield2 = @idfield2,	--exempel: persOUTPUT	@@idtable2 = @idtable2,	--exempel: country
				@@idrelation = @idrelation OUTPUT
				
		PRINT N'RELATION CREATED: ' + CAST(@idrelation AS NVARCHAR(128))
				
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return 
		-- error information about the original error that 
		-- caused execution to jump to the CATCH block.
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
		
	END CATCH
END

GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[csp_scriptfield_relation_oneToMany]'))
BEGIN RAISERROR('The object csp_scriptfield_relation_oneToMany was not created!',11,1) END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT '[csp_scriptfield_relation_oneToOne]'
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[csp_scriptfield_relation_oneToOne]'))
BEGIN DROP PROCEDURE [dbo].[csp_scriptfield_relation_oneToOne] END
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

-- DSG
-- version: 1.0
-- component: scriptfield
-- release: 1 | order: 1
-- changelog: 1.0 | 2013-11-18 | MHE | Created
-- END_DSG
-- =============================================
CREATE PROCEDURE csp_scriptfield_relation_oneToOne
	@field1_table NVARCHAR(128),
	@field1_name NVARCHAR(128),
	@field1_localname_sv NVARCHAR(128),
	@field1_localname_en NVARCHAR(128),
	@field2_table NVARCHAR(128),
	@field2_name NVARCHAR(128),
	@field2_localname_sv NVARCHAR(128),
	@field2_localname_en NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION
		   
		/**********************
		DECLARE vars
		**********************/
		DECLARE	@return_value INT
			, @defaultvalue NVARCHAR(128)
			, @idfield INT
			, @localname INT
			, @idcategory INT
			, @idstring INT
			, @sqlcommand NVARCHAR(2048)

		-- Special relation variables.
		DECLARE @idfield1 INT		--Field
		DECLARE @idfield2 INT		--Tab
		DECLARE @idtable1 INT		--Table with field
		DECLARE @idtable2 INT		--Table with tab
		DECLARE @idrelation INT

		-- init vars
		SET @idfield1 = NULL
		SET @idfield2 = NULL
		SET @idtable1 = NULL
		SET @idtable2 = NULL
		SET @idrelation = NULL

		/**********************
		create field 1
		**********************/
		PRINT N'CREATE FIELD (FIELD): ' + @field1_table + '.' + @field1_name
		SET @return_value = NULL
		SET @defaultvalue = ''
		SET @idfield1 = NULL
		SET @localname = NULL
		SET @idcategory = NULL
		SET @idstring = NULL

		-- create field
		EXEC	@return_value = [dbo].[lsp_addfield]
				@@table = @field1_table,
				@@name = @field1_name,
				@@fieldtype = 16,					--realationfield
				@@defaultvalue = @defaultvalue OUTPUT,
				@@idfield = @idfield1 OUTPUT,
				@@localname = @localname OUTPUT,
				@@idcategory = @idcategory OUTPUT

		-- set localname
		UPDATE [string] SET sv = @field1_localname_sv, en_us = @field1_localname_en WHERE [idstring] = @localname
		
		--set realtioncount
		EXEC lsp_setattributevalue @@owner = 'field', @@idrecord = @idfield1, @@name = 'relationmincount', @@value = 0
		EXEC lsp_setattributevalue @@owner = 'field', @@idrecord = @idfield1, @@name = 'relationmaxcount', @@value = 1
		
		/**********************
		create field 2
		**********************/
		PRINT N'CREATE FIELD (FIELD): ' + @field1_table + '.' + @field2_name
		SET @return_value = NULL
		SET @defaultvalue = ''
		SET @idfield2 = NULL
		SET @localname = NULL	
		SET @idcategory = NULL
		SET @idstring = NULL

		EXEC	@return_value = [dbo].[lsp_addfield]
				@@table = @field1_table,
				@@name = @field2_name,
				@@fieldtype = 16,					--Relationsfält
				@@defaultvalue = @defaultvalue OUTPUT,
				@@idfield = @idfield2 OUTPUT,
				@@localname = @localname OUTPUT,
				@@idcategory = @idcategory OUTPUT

		-- set localname
		UPDATE [string] SET sv = @field2_localname_sv, en_us = @field2_localname_en WHERE [idstring] = @localname

		--set realtioncount
		EXEC lsp_setattributevalue @@owner = 'field', @@idrecord = @idfield2, @@name = 'relationmincount', @@value = 0
		EXEC lsp_setattributevalue @@owner = 'field', @@idrecord = @idfield2, @@name = 'relationmaxcount', @@value = 1

		/**********************
		add relation
		**********************/
		PRINT N'ADD RELATION: ' + @field1_table + ' - ' + @field2_table
		
		SELECT @idtable1 = idtable
		FROM [table]
		WHERE [name] = @field1_table

		SELECT @idtable2 = idtable
		FROM [table]
		WHERE [name] = @field2_table

		EXEC	@return_value = lsp_addrelation
				@@idfield1 = @idfield1,	--exempel: countrycode
				@@idtable1 = @idtable1,	--exempel: person
				@@idfield2 = @idfield2,	--exempel: persOUTPUT	@@idtable2 = @idtable2,	--exempel: country
				@@idrelation = @idrelation OUTPUT
				
		PRINT N'RELATION CREATED: ' + CAST(@idrelation AS NVARCHAR(128))
				
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return 
		-- error information about the original error that 
		-- caused execution to jump to the CATCH block.
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
		
	END CATCH
END

GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[csp_scriptfield_relation_oneToOne]'))
BEGIN RAISERROR('The object csp_scriptfield_relation_oneToOne was not created!',11,1) END

GO

