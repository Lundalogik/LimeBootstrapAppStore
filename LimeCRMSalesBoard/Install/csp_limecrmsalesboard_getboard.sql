SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Written by: Fredrik Eriksson
-- Created: 2015-11-05

-- Returns xml with information needed to draw a board.
CREATE PROCEDURE [dbo].[csp_embrello_getboard]
	@@tablename NVARCHAR(64)
	, @@lanefieldname NVARCHAR(64)
	, @@titlefieldname NVARCHAR(64)
	, @@completionfieldname NVARCHAR(64) = N''
	, @@sumfieldname NVARCHAR(64) = N''
	, @@valuefieldname NVARCHAR(64) = N''
	, @@sortfieldname NVARCHAR(64) = N''
	, @@ownerfieldname NVARCHAR(64)
	, @@ownerrelatedtablename NVARCHAR(64)
	, @@ownerdescriptivefieldname NVARCHAR(64)
	, @@additionalinfofieldname NVARCHAR(64) = N''
	, @@additionalinforelatedtablename NVARCHAR(64) = N''
	, @@additionalinfodescriptivefieldname NVARCHAR(64) = N''
	, @@additionalinfodateformat INT = NULL
	, @@additionalinfodatelength INT = NULL
	, @@idrecords NVARCHAR(MAX)
	, @@lang NVARCHAR(5)
	, @@limeservername NVARCHAR(64)
	, @@limedbname NVARCHAR(64)
	, @@iduser INT
AS
BEGIN

	-- FLAG_EXTERNALACCESS --
	
	-- Fix en-us, make it en_us
	SET @@lang = REPLACE(@@lang, N'-', N'_')
	
	-- Get idcategory for option field for lanes
	DECLARE @idcategory INT
	SELECT @idcategory = ad.value
	FROM field f
	INNER JOIN [table] t
		ON t.idtable = f.idtable
	INNER JOIN attributedata ad
		ON ad.idrecord = f.idfield
	WHERE t.name = @@tablename
		AND f.name = @@lanefieldname
		AND ad.[owner] = N'field'
		AND ad.name = N'idcategory'
	
	IF @idcategory IS NULL
	BEGIN
		RETURN
	END
	
	-- Build string with dynamic SQL
	DECLARE @sql NVARCHAR(MAX)
	DECLARE @sqlexpression NVARCHAR(MAX)
	
	SET @sql = N'SELECT *' + CHAR(10)
	SET @sql = @sql + N'FROM' + CHAR(10)
	SET @sql = @sql + N'(' + CHAR(10)
	
	-- Get lanes
	SET @sql = @sql + N'	SELECT 1 AS Tag' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS Parent' + CHAR(10)
	SET @sql = @sql + N'		, s.[stringorder] AS [Lanes!1!order]' + CHAR(10)
	SET @sql = @sql + N'		, s.[idstring] AS [Lanes!1!id]' + CHAR(10)
	SET @sql = @sql + N'		, s.[key] AS [Lanes!1!key]' + CHAR(10)
	SET @sql = @sql + N'		, s.[' + @@lang + N'] AS [Lanes!1!name]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [Cards!2!title]' + CHAR(10)
	
	IF @@completionfieldname <> N''
	BEGIN
		SET @sql = @sql + N'		, NULL AS [Cards!2!completionRate]' + CHAR(10)
	END
	
	IF @@sumfieldname <> N''
	BEGIN
		SET @sql = @sql + N'		, NULL AS [Cards!2!sumValue]' + CHAR(10)
	END
	
	IF @@valuefieldname <> N''
	BEGIN
		SET @sql = @sql + N'		, NULL AS [Cards!2!value]' + CHAR(10)
	END
	
	IF @@sortfieldname <> N''
	BEGIN
		SET @sql = @sql + N'		, NULL AS [Cards!2!sortValue]' + CHAR(10)
	END
	
	SET @sql = @sql + N'		, NULL AS [Cards!2!owner]' + CHAR(10)
	
	IF @@additionalinfofieldname <> N''
	BEGIN
		SET @sql = @sql + N'		, NULL AS [Cards!2!additionalInfo]' + CHAR(10)
	END
	
	SET @sql = @sql + N'		, NULL AS [Cards!2!link]' + CHAR(10)
	SET @sql = @sql + N'	FROM string s' + CHAR(10)
	SET @sql = @sql + N'	LEFT JOIN attributedata ad' + CHAR(10)
	SET @sql = @sql + N'		ON s.idstring = ad.idrecord' + CHAR(10)
	SET @sql = @sql + N'			AND ad.[owner] = N''string''' + CHAR(10)
	SET @sql = @sql + N'			AND ad.name = N''inactive''' + CHAR(10)
	SET @sql = @sql + N'	WHERE s.idcategory = ' + CONVERT(NVARCHAR(20), @idcategory) + CHAR(10)
	SET @sql = @sql + N'		AND s.[' + @@lang + N'] <> N''''' + CHAR(10)
	SET @sql = @sql + N'		AND ISNULL(ad.value, 0) = 0' + CHAR(10)

	-- Get cards
	SET @sql = @sql + N'	UNION ALL' + CHAR(10)
	SET @sql = @sql + N'	SELECT 2 AS Tag' + CHAR(10)
	SET @sql = @sql + N'		, 1 AS Parent' + CHAR(10)
	SET @sql = @sql + N'		, s.stringorder AS [Lanes!1!order]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [Lanes!1!id]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [Lanes!1!key]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [Lanes!1!name]' + CHAR(10)
	SET @sql = @sql + N'		, REPLACE(REPLACE(A1.[' + @@titlefieldname + N'], N''\'', N''\\''), N''"'', N''\"'') AS [Cards!2!title]' + CHAR(10)
	
	IF @@completionfieldname <> N''
	BEGIN
		-- Check if SQL expression on field
		SET @sqlexpression = [dbo].[cfn_embrello_getsqlexpression](@@tablename, @@completionfieldname, N'A1', @@iduser)
		IF @sqlexpression <> N''
		BEGIN
			SET @sql = @sql + N'		, CONVERT(NVARCHAR(32), ISNULL(' + @sqlexpression + N', 0)) AS [Cards!2!value]' + CHAR(10)
		END
		ELSE
		BEGIN
			SET @sql = @sql + N'		, CONVERT(NVARCHAR(32), A1.[' + @@completionfieldname + N']) AS [Cards!2!completionRate]' + CHAR(10)
		END
	END
	
	IF @@sumfieldname <> N''
	BEGIN
		-- Check if SQL expression on field
		SET @sqlexpression = [dbo].[cfn_embrello_getsqlexpression](@@tablename, @@sumfieldname, N'A1', @@iduser)
		IF @sqlexpression <> N''
		BEGIN
			SET @sql = @sql + N'		, ISNULL(' + @sqlexpression + N', 0) AS [Cards!2!value]' + CHAR(10)
		END
		ELSE
		BEGIN
			SET @sql = @sql + N'		, ISNULL(A1.[' + @@sumfieldname + N'], 0) AS [Cards!2!sumValue]' + CHAR(10)
		END
	END
	
	IF @@valuefieldname <> N''
	BEGIN
		-- Check if SQL expression on field
		SET @sqlexpression = [dbo].[cfn_embrello_getsqlexpression](@@tablename, @@valuefieldname, N'A1', @@iduser)
		IF @sqlexpression <> N''
		BEGIN
			SET @sql = @sql + N'		, ISNULL(' + @sqlexpression + N', 0) AS [Cards!2!value]' + CHAR(10)
		END
		ELSE
		BEGIN
			SET @sql = @sql + N'		, ISNULL(A1.[' + @@valuefieldname + N'], 0) AS [Cards!2!value]' + CHAR(10)
		END
	END
	
	IF @@sortfieldname <> N''
	BEGIN
		SET @sql = @sql + N'		, A1.[' + @@sortfieldname + N'] AS [Cards!2!sortValue]' + CHAR(10)
	END
	
	SET @sql = @sql + N'		, REPLACE(REPLACE(A2.[' + @@ownerdescriptivefieldname + '], N''\'', N''\\''), N''"'', N''\"'') AS [Cards!2!owner]' + CHAR(10)
	
	IF @@additionalinfofieldname <> N''
	BEGIN
		-- Build conversion strings to use if a date field
		DECLARE @dateconversionprefix NVARCHAR(32)
		DECLARE @dateconversionsuffix NVARCHAR(32)
		
		IF @@additionalinfodateformat IS NOT NULL OR @@additionalinfodatelength IS NOT NULL
		BEGIN
			SET @dateconversionprefix = N'CONVERT(NVARCHAR(' + CONVERT(NVARCHAR(20), ISNULL(@@additionalinfodatelength, 64)) + N'), '
			SET @dateconversionsuffix = ISNULL(N', ' + CONVERT(NVARCHAR(20), @@additionalinfodateformat), N'') + N')'
		END
		ELSE
		BEGIN
			SET @dateconversionprefix = N''
			SET @dateconversionsuffix = N''
		END
		
		-- Check if additionalInfo is a field on the table itself or on a related table
		IF @@additionalinforelatedtablename <> N''
		BEGIN
			SET @sql = @sql + N'		, REPLACE(REPLACE(' + @dateconversionprefix + 'A3.[' + @@additionalinfodescriptivefieldname + N']' + @dateconversionsuffix + ', N''\'', N''\\''), N''"'', N''\"'') AS [Cards!2!additionalInfo]' + CHAR(10)
		END
		ELSE
		BEGIN
			SET @sql = @sql + N'		, REPLACE(REPLACE(' + @dateconversionprefix + 'A1.[' + @@additionalinfofieldname + N']' + @dateconversionsuffix + ', N''\'', N''\\''), N''"'', N''\"'') AS [Cards!2!additionalInfo]' + CHAR(10)
		END
	END
	
	SET @sql = @sql + N'		, N''limecrm:' + @@tablename + N'.' + @@limedbname + '.' + @@limeservername + '?'' + CONVERT(NVARCHAR(20), A1.[id' + @@tablename + N']) AS [Cards!2!link]' + CHAR(10)
	SET @sql = @sql + N'	FROM [' + @@tablename + N'] A1' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN [dbo].[cfn_gettablefromstring](@@idrecords, N'';'') ids' + CHAR(10)
	SET @sql = @sql + N'		ON ids.value = A1.[id' + @@tablename + N']' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN string s' + CHAR(10)
	SET @sql = @sql + N'		ON s.idstring = A1.[' + @@lanefieldname + N']' + CHAR(10)
	SET @sql = @sql + N'	LEFT JOIN attributedata ad' + CHAR(10)
	SET @sql = @sql + N'		ON s.idstring = ad.idrecord' + CHAR(10)
	SET @sql = @sql + N'			AND ad.[owner] = N''string''' + CHAR(10)
	SET @sql = @sql + N'			AND ad.name = N''inactive''' + CHAR(10)
	SET @sql = @sql + N'	LEFT JOIN [' + @@ownerrelatedtablename + N'] A2' + CHAR(10)
	SET @sql = @sql + N'		ON A2.[id' + @@ownerrelatedtablename + N'] = A1.[' + @@ownerfieldname + N']' + CHAR(10)
	
	IF @@additionalinfofieldname <> N''
			AND @@additionalinforelatedtablename <> N''
	BEGIN
		SET @sql = @sql + N'	LEFT JOIN [' + @@additionalinforelatedtablename + N'] A3' + CHAR(10)
		SET @sql = @sql + N'		ON A3.[id' + @@additionalinforelatedtablename + N'] = A1.[' + @@additionalinfofieldname + N']' + CHAR(10)
	END
	
	SET @sql = @sql + N'	WHERE s.[' + @@lang + N'] <> N''''' + CHAR(10)
	SET @sql = @sql + N'		AND ISNULL(ad.value, 0) = 0' + CHAR(10)
	SET @sql = @sql + N') t' + CHAR(10)
	SET @sql = @sql + N'ORDER BY t.[Lanes!1!order] ASC, t.Tag ASC' + CHAR(10)
	SET @sql = @sql + N'FOR XML EXPLICIT' + CHAR(10)
	
	-- Run SQL code to get XML that will be returned to LIME Pro VBA.
	EXEC sp_executesql
		@sql
		, N'@@idrecords NVARCHAR(MAX)'
		, @@idrecords
END

GO

-- Make procedure available in VBA
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'lsp_refreshldc')
BEGIN
	EXEC lsp_refreshldc
END

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'lsp_setdatabasetimestamp')
BEGIN
	EXEC lsp_setdatabasetimestamp
END

GO