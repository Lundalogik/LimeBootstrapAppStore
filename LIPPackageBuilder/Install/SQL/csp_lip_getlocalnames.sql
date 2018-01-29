/****** Object:  StoredProcedure [dbo].[csp_lip_getlocalnames]    Script Date: 2016-05-17 07:27:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Written by: Fredrik Eriksson, Lundalogik AB
-- Created: 2016-01-25

-- This procedure is used in the LIP package builder.
-- Returns the local names for all fields and tables as an xml.

--##TODO: Lägg tillbaka validationtexts, comments och descriptions. XML:en blir dock för stor om man har med dem.
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'csp_lip_getlocalnames' AND UPPER(type) = 'P')
   DROP PROCEDURE [csp_lip_getlocalnames]
GO
CREATE PROCEDURE [dbo].[csp_lip_getlocalnames]
	@@lang NVARCHAR(5) = N''
	, @@idcoworker INT = NULL
AS
BEGIN

	-- FLAG_EXTERNALACCESS --
	
	--------------- PART 1: Preparations ---------------
	
	-- Get active languages
	DECLARE @langs TABLE
	(
		lang NVARCHAR(5)
	)
	
	INSERT INTO @langs
	(
		lang
	)
	SELECT REPLACE(name, N'lang_active_', N'') AS lang
	FROM setting
	WHERE name LIKE N'lang_active_%'
		AND value = N'1'
		
	DECLARE @nbroflangs INT
	SELECT @nbroflangs = COUNT(*)
	FROM @langs
	
	-- Build SQL strings for language depending columns
	DECLARE @gettablescolumns NVARCHAR(MAX) = N''
	DECLARE @gettablessingularcolumns NVARCHAR(MAX) = N''
	DECLARE @gettablespluralcolumns NVARCHAR(MAX) = N''
	DECLARE @getfieldscolumns NVARCHAR(MAX) = N''
	DECLARE @getseparatorscolumns NVARCHAR(MAX) = N''
	DECLARE @getlimevalidationtextscolumns NVARCHAR(MAX) = N''
	DECLARE @getcommentscolumns NVARCHAR(MAX) = N''
	DECLARE @getdescriptionscolumns NVARCHAR(MAX) = N''
	DECLARE @getoptionscolumns NVARCHAR(MAX) = N''
	DECLARE @lang NVARCHAR(5)
	
	DECLARE cur CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
	SELECT lang
	FROM @langs
	
	-- Create cursor for active languages. The cursor will be reused several times.
	OPEN cur
	FETCH NEXT FROM cur INTO @lang
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @gettablescolumns = @gettablescolumns + N'		, NULL AS [localname_singular!2!' + @lang + ']' + CHAR(10)
		SET @gettablescolumns = @gettablescolumns + N'		, NULL AS [localname_plural!3!' + @lang + ']' + CHAR(10)
		SET @gettablescolumns = @gettablescolumns + N'		, NULL AS [Fields!4!' + @lang + ']' + CHAR(10)
		SET @gettablescolumns = @gettablescolumns + N'		, NULL AS [separator!5!' + @lang + ']' + CHAR(10)
		--SET @gettablescolumns = @gettablescolumns + N'		, NULL AS [limevalidationtext!6!' + @lang + ']' + CHAR(10)
		--SET @gettablescolumns = @gettablescolumns + N'		, NULL AS [comment!7!' + @lang + ']' + CHAR(10)
		--SET @gettablescolumns = @gettablescolumns + N'		, NULL AS [description!8!' + @lang + ']' + CHAR(10)
		SET @gettablescolumns = @gettablescolumns + N'		, NULL AS [option!9!' + @lang + ']' + CHAR(10)
		FETCH NEXT FROM cur INTO @lang
	END
	CLOSE cur
	
	-- Get table singular names
	OPEN cur
	FETCH NEXT FROM cur INTO @lang
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @gettablessingularcolumns = @gettablessingularcolumns + N'		, s.[' + @lang + '] AS [localname_singular!2!' + @lang + ']' + CHAR(10)
		SET @gettablessingularcolumns = @gettablessingularcolumns + N'		, NULL AS [localname_plural!3!' + @lang + ']' + CHAR(10)
		SET @gettablessingularcolumns = @gettablessingularcolumns + N'		, NULL AS [Fields!4!' + @lang + ']' + CHAR(10)
		SET @gettablessingularcolumns = @gettablessingularcolumns + N'		, NULL AS [separator!5!' + @lang + ']' + CHAR(10)
		--SET @gettablessingularcolumns = @gettablessingularcolumns + N'		, NULL AS [limevalidationtext!6!' + @lang + ']' + CHAR(10)
		--SET @gettablessingularcolumns = @gettablessingularcolumns + N'		, NULL AS [comment!7!' + @lang + ']' + CHAR(10)
		--SET @gettablessingularcolumns = @gettablessingularcolumns + N'		, NULL AS [description!8!' + @lang + ']' + CHAR(10)
		SET @gettablessingularcolumns = @gettablessingularcolumns + N'		, NULL AS [option!9!' + @lang + ']' + CHAR(10)
		FETCH NEXT FROM cur INTO @lang
	END
	CLOSE cur
	
	-- Get table plural names
	OPEN cur
	FETCH NEXT FROM cur INTO @lang
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @gettablespluralcolumns = @gettablespluralcolumns + N'		, NULL AS [localname_singular!2!' + @lang + ']' + CHAR(10)
		SET @gettablespluralcolumns = @gettablespluralcolumns + N'		, s.[' + @lang + '] AS [localname_plural!3!' + @lang + ']' + CHAR(10)
		SET @gettablespluralcolumns = @gettablespluralcolumns + N'		, NULL AS [Fields!4!' + @lang + ']' + CHAR(10)
		SET @gettablespluralcolumns = @gettablespluralcolumns + N'		, NULL AS [separator!5!' + @lang + ']' + CHAR(10)
		--SET @gettablespluralcolumns = @gettablespluralcolumns + N'		, NULL AS [limevalidationtext!6!' + @lang + ']' + CHAR(10)
		--SET @gettablespluralcolumns = @gettablespluralcolumns + N'		, NULL AS [comment!7!' + @lang + ']' + CHAR(10)
		--SET @gettablespluralcolumns = @gettablespluralcolumns + N'		, NULL AS [description!8!' + @lang + ']' + CHAR(10)
		SET @gettablespluralcolumns = @gettablespluralcolumns + N'		, NULL AS [option!9!' + @lang + ']' + CHAR(10)
		FETCH NEXT FROM cur INTO @lang
	END
	CLOSE cur
	
	-- Get fields
	OPEN cur
	FETCH NEXT FROM cur INTO @lang
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @getfieldscolumns = @getfieldscolumns + N'		, NULL AS [localname_singular!2!' + @lang + ']' + CHAR(10)
		SET @getfieldscolumns = @getfieldscolumns + N'		, NULL AS [localname_plural!3!' + @lang + ']' + CHAR(10)
		SET @getfieldscolumns = @getfieldscolumns + N'		, s.[' + @lang + '] AS [Fields!4!' + @lang + ']' + CHAR(10)
		SET @getfieldscolumns = @getfieldscolumns + N'		, NULL AS [separator!5!' + @lang + ']' + CHAR(10)
		--SET @getfieldscolumns = @getfieldscolumns + N'		, NULL AS [limevalidationtext!6!' + @lang + ']' + CHAR(10)
		--SET @getfieldscolumns = @getfieldscolumns + N'		, NULL AS [comment!7!' + @lang + ']' + CHAR(10)
		--SET @getfieldscolumns = @getfieldscolumns + N'		, NULL AS [description!8!' + @lang + ']' + CHAR(10)
		SET @getfieldscolumns = @getfieldscolumns + N'		, NULL AS [option!9!' + @lang + ']' + CHAR(10)
		FETCH NEXT FROM cur INTO @lang
	END
	CLOSE cur
	
	-- Get separators
	OPEN cur
	FETCH NEXT FROM cur INTO @lang
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @getseparatorscolumns = @getseparatorscolumns + N'		, NULL AS [localname_singular!2!' + @lang + ']' + CHAR(10)
		SET @getseparatorscolumns = @getseparatorscolumns + N'		, NULL AS [localname_plural!3!' + @lang + ']' + CHAR(10)
		SET @getseparatorscolumns = @getseparatorscolumns + N'		, NULL AS [Fields!4!' + @lang + ']' + CHAR(10)
		SET @getseparatorscolumns = @getseparatorscolumns + N'		, s.[' + @lang + '] AS [separator!5!' + @lang + ']' + CHAR(10)
		--SET @getseparatorscolumns = @getseparatorscolumns + N'		, NULL AS [limevalidationtext!6!' + @lang + ']' + CHAR(10)
		--SET @getseparatorscolumns = @getseparatorscolumns + N'		, NULL AS [comment!7!' + @lang + ']' + CHAR(10)
		--SET @getseparatorscolumns = @getseparatorscolumns + N'		, NULL AS [description!8!' + @lang + ']' + CHAR(10)
		SET @getseparatorscolumns = @getseparatorscolumns + N'		, NULL AS [option!9!' + @lang + ']' + CHAR(10)
		FETCH NEXT FROM cur INTO @lang
	END
	CLOSE cur
	
	-- Get limevalidationtexts
	OPEN cur
	FETCH NEXT FROM cur INTO @lang
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @getlimevalidationtextscolumns = @getlimevalidationtextscolumns + N'		, NULL AS [localname_singular!2!' + @lang + ']' + CHAR(10)
		SET @getlimevalidationtextscolumns = @getlimevalidationtextscolumns + N'		, NULL AS [localname_plural!3!' + @lang + ']' + CHAR(10)
		SET @getlimevalidationtextscolumns = @getlimevalidationtextscolumns + N'		, NULL AS [Fields!4!' + @lang + ']' + CHAR(10)
		SET @getlimevalidationtextscolumns = @getlimevalidationtextscolumns + N'		, NULL AS [separator!5!' + @lang + ']' + CHAR(10)
		--SET @getlimevalidationtextscolumns = @getlimevalidationtextscolumns + N'		, s.[' + @lang + '] AS [limevalidationtext!6!' + @lang + ']' + CHAR(10)
		--SET @getlimevalidationtextscolumns = @getlimevalidationtextscolumns + N'		, NULL AS [comment!7!' + @lang + ']' + CHAR(10)
		--SET @getlimevalidationtextscolumns = @getlimevalidationtextscolumns + N'		, NULL AS [description!8!' + @lang + ']' + CHAR(10)
		SET @getlimevalidationtextscolumns = @getlimevalidationtextscolumns + N'		, NULL AS [option!9!' + @lang + ']' + CHAR(10)
		FETCH NEXT FROM cur INTO @lang
	END
	CLOSE cur
	
	-- Get comments
	OPEN cur
	FETCH NEXT FROM cur INTO @lang
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @getcommentscolumns = @getcommentscolumns + N'		, NULL AS [localname_singular!2!' + @lang + ']' + CHAR(10)
		SET @getcommentscolumns = @getcommentscolumns + N'		, NULL AS [localname_plural!3!' + @lang + ']' + CHAR(10)
		SET @getcommentscolumns = @getcommentscolumns + N'		, NULL AS [Fields!4!' + @lang + ']' + CHAR(10)
		SET @getcommentscolumns = @getcommentscolumns + N'		, NULL AS [separator!5!' + @lang + ']' + CHAR(10)
		--SET @getcommentscolumns = @getcommentscolumns + N'		, NULL AS [limevalidationtext!6!' + @lang + ']' + CHAR(10)
		--SET @getcommentscolumns = @getcommentscolumns + N'		, s.[' + @lang + '] AS [comment!7!' + @lang + ']' + CHAR(10)
		--SET @getcommentscolumns = @getcommentscolumns + N'		, NULL AS [description!8!' + @lang + ']' + CHAR(10)
		SET @getcommentscolumns = @getcommentscolumns + N'		, NULL AS [option!9!' + @lang + ']' + CHAR(10)
		FETCH NEXT FROM cur INTO @lang
	END
	CLOSE cur
	
	-- Get description
	OPEN cur
	FETCH NEXT FROM cur INTO @lang
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @getdescriptionscolumns = @getdescriptionscolumns + N'		, NULL AS [localname_singular!2!' + @lang + ']' + CHAR(10)
		SET @getdescriptionscolumns = @getdescriptionscolumns + N'		, NULL AS [localname_plural!3!' + @lang + ']' + CHAR(10)
		SET @getdescriptionscolumns = @getdescriptionscolumns + N'		, NULL AS [Fields!4!' + @lang + ']' + CHAR(10)
		SET @getdescriptionscolumns = @getdescriptionscolumns + N'		, NULL AS [separator!5!' + @lang + ']' + CHAR(10)
		--SET @getdescriptionscolumns = @getdescriptionscolumns + N'		, NULL AS [limevalidationtext!6!' + @lang + ']' + CHAR(10)
		--SET @getdescriptionscolumns = @getdescriptionscolumns + N'		, NULL AS [comment!7!' + @lang + ']' + CHAR(10)
		--SET @getdescriptionscolumns = @getdescriptionscolumns + N'		, s.[' + @lang + '] AS [description!8!' + @lang + ']' + CHAR(10)
		SET @getdescriptionscolumns = @getdescriptionscolumns + N'		, NULL AS [option!9!' + @lang + ']' + CHAR(10)
		FETCH NEXT FROM cur INTO @lang
	END
	CLOSE cur
	
	-- Get options
	OPEN cur
	FETCH NEXT FROM cur INTO @lang
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @getoptionscolumns = @getoptionscolumns + N'		, NULL AS [localname_singular!2!' + @lang + ']' + CHAR(10)
		SET @getoptionscolumns = @getoptionscolumns + N'		, NULL AS [localname_plural!3!' + @lang + ']' + CHAR(10)
		SET @getoptionscolumns = @getoptionscolumns + N'		, NULL AS [Fields!4!' + @lang + ']' + CHAR(10)
		SET @getoptionscolumns = @getoptionscolumns + N'		, NULL AS [separator!5!' + @lang + ']' + CHAR(10)
		--SET @getoptionscolumns = @getoptionscolumns + N'		, NULL AS [limevalidationtext!6!' + @lang + ']' + CHAR(10)
		--SET @getoptionscolumns = @getoptionscolumns + N'		, NULL AS [comment!7!' + @lang + ']' + CHAR(10)
		--SET @getoptionscolumns = @getoptionscolumns + N'		, NULL AS [description!8!' + @lang + ']' + CHAR(10)
		SET @getoptionscolumns = @getoptionscolumns + N'		, s.[' + @lang + '] AS [option!9!' + @lang + ']' + CHAR(10)
		FETCH NEXT FROM cur INTO @lang
	END
	CLOSE cur
	
	-- Destroy our reusable cursor
	DEALLOCATE cur
	
	
	--------------- PART 2: Build XML ---------------
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = N'SELECT *' + CHAR(10)
	SET @sql = @sql + N'FROM' + CHAR(10)
	SET @sql = @sql + N'(' + CHAR(10)
	
	--	-- Get tables
	SET @sql = @sql + N'	SELECT 1 AS Tag' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS Parent' + CHAR(10)
	SET @sql = @sql + N'		, t.name AS [Tables!1!name]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [Fields!4!name]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [Fields!4!order]' + CHAR(10)
	SET @sql = @sql + @gettablescolumns
	SET @sql = @sql + N'		, NULL AS [option!9!key]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [option!9!color]' + CHAR(10)			--##TODO!!
	SET @sql = @sql + N'	FROM [table] t' + CHAR(10)
	SET @sql = @sql + N'	WHERE t.idtable > 1000' + CHAR(10)

	--	-- Get table local names singular
	SET @sql = @sql + N'	UNION ALL' + CHAR(10)
	SET @sql = @sql + N'	SELECT 2 AS Tag' + CHAR(10)
	SET @sql = @sql + N'		, 1 AS Parent' + CHAR(10)
	SET @sql = @sql + N'		, t.name AS [Tables!1!name]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [Fields!4!name]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [Fields!4!order]' + CHAR(10)
	SET @sql = @sql + @gettablessingularcolumns
	SET @sql = @sql + N'		, NULL AS [option!9!key]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [option!9!color]' + CHAR(10)			--##TODO!!
	SET @sql = @sql + N'	FROM [table] t' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN string s' + CHAR(10)
	SET @sql = @sql + N'		ON s.idstring = t.localname' + CHAR(10)
	SET @sql = @sql + N'	WHERE t.idtable > 1000' + CHAR(10)
	
	--	-- Get table local names plural
	SET @sql = @sql + N'	UNION ALL' + CHAR(10)
	SET @sql = @sql + N'	SELECT 3 AS Tag' + CHAR(10)
	SET @sql = @sql + N'		, 1 AS Parent' + CHAR(10)
	SET @sql = @sql + N'		, t.name AS [Tables!1!name]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [Fields!4!name]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [Fields!4!order]' + CHAR(10)
	SET @sql = @sql + @gettablespluralcolumns
	SET @sql = @sql + N'		, NULL AS [option!9!key]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [option!9!color]' + CHAR(10)			--##TODO!!
	SET @sql = @sql + N'	FROM [table] t' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN attributedata ad' + CHAR(10)
	SET @sql = @sql + N'		ON ad.idrecord = t.idtable' + CHAR(10)
	SET @sql = @sql + N'			AND ad.[owner] = N''table''' + CHAR(10)
	SET @sql = @sql + N'			AND ad.name = N''localnameplural''' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN string s' + CHAR(10)
	SET @sql = @sql + N'		ON s.idstring = ad.value' + CHAR(10)
	SET @sql = @sql + N'	WHERE t.idtable > 1000' + CHAR(10)
		
	--	-- Get fields
	SET @sql = @sql + N'	UNION ALL' + CHAR(10)
	SET @sql = @sql + N'	SELECT 4 AS Tag' + CHAR(10)
	SET @sql = @sql + N'		, 1 AS Parent' + CHAR(10)
	SET @sql = @sql + N'		, t.name AS [Tables!1!name]' + CHAR(10)
	SET @sql = @sql + N'		, f.name AS [Fields!4!name]' + CHAR(10)
	SET @sql = @sql + N'		, f.fieldorder AS [Fields!4!order]' + CHAR(10)
	SET @sql = @sql + @getfieldscolumns
	SET @sql = @sql + N'		, NULL AS [option!9!key]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [option!9!color]' + CHAR(10)			--##TODO!!
	SET @sql = @sql + N'	FROM field f' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN [table] t' + CHAR(10)
	SET @sql = @sql + N'		ON t.idtable = f.idtable' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN string s' + CHAR(10)
	SET @sql = @sql + N'		ON s.idstring = f.localname' + CHAR(10)
	SET @sql = @sql + N'	WHERE f.idtable > 1000' + CHAR(10)
	
	-- Get separators
	SET @sql = @sql + N'	UNION ALL' + CHAR(10)
	SET @sql = @sql + N'	SELECT 5 AS Tag' + CHAR(10)
	SET @sql = @sql + N'		, 4 AS Parent' + CHAR(10)
	SET @sql = @sql + N'		, t.name AS [Tables!1!name]' + CHAR(10)
	SET @sql = @sql + N'		, f.name AS [Fields!4!name]' + CHAR(10)
	SET @sql = @sql + N'		, f.fieldorder AS [Fields!4!order]' + CHAR(10)
	SET @sql = @sql + @getseparatorscolumns
	SET @sql = @sql + N'		, NULL AS [option!9!key]' + CHAR(10)
	SET @sql = @sql + N'		, NULL AS [option!9!color]' + CHAR(10)			--##TODO!!
	SET @sql = @sql + N'	FROM field f' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN [table] t' + CHAR(10)
	SET @sql = @sql + N'		ON t.idtable = f.idtable' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN attributedata ad1' + CHAR(10)
	SET @sql = @sql + N'		ON ad1.idrecord = f.idfield' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN attributedata ad2' + CHAR(10)
	SET @sql = @sql + N'		ON ad2.idrecord = ad1.idrecord' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN string s' + CHAR(10)
	SET @sql = @sql + N'		ON s.idstring = ad1.value' + CHAR(10)
	SET @sql = @sql + N'	WHERE f.idtable > 1000' + CHAR(10)
	SET @sql = @sql + N'		AND ad1.[owner] = N''field''' + CHAR(10)
	SET @sql = @sql + N'		AND ad2.[owner] = N''field''' + CHAR(10)
	SET @sql = @sql + N'		AND ad1.name = N''separatorlocalname''' + CHAR(10)
	SET @sql = @sql + N'		AND ad2.name = N''separator''' + CHAR(10)
	SET @sql = @sql + N'		AND ad2.value = 1' + CHAR(10)
	
	-- Get limevalidationtexts
	--SET @sql = @sql + N'	UNION ALL' + CHAR(10)
	--SET @sql = @sql + N'	SELECT 6 AS Tag' + CHAR(10)
	--SET @sql = @sql + N'		, 4 AS Parent' + CHAR(10)
	--SET @sql = @sql + N'		, t.name AS [Tables!1!name]' + CHAR(10)
	--SET @sql = @sql + N'		, f.name AS [Fields!4!name]' + CHAR(10)
	--SET @sql = @sql + N'		, f.fieldorder AS [Fields!4!order]' + CHAR(10)
	--SET @sql = @sql + @getlimevalidationtextscolumns
	--SET @sql = @sql + N'	FROM field f' + CHAR(10)
	--SET @sql = @sql + N'	INNER JOIN [table] t' + CHAR(10)
	--SET @sql = @sql + N'		ON t.idtable = f.idtable' + CHAR(10)
	--SET @sql = @sql + N'	INNER JOIN attributedata ad' + CHAR(10)
	--SET @sql = @sql + N'		ON ad.idrecord = f.idfield' + CHAR(10)
	--SET @sql = @sql + N'	INNER JOIN string s' + CHAR(10)
	--SET @sql = @sql + N'		ON s.idstring = ad.value' + CHAR(10)
	--SET @sql = @sql + N'	WHERE f.idtable > 1000' + CHAR(10)
	--SET @sql = @sql + N'		AND ad.[owner] = N''field''' + CHAR(10)
	--SET @sql = @sql + N'		AND ad.name = N''limevalidationtext''' + CHAR(10)
	
	---- Get comments
	--SET @sql = @sql + N'	UNION ALL' + CHAR(10)
	--SET @sql = @sql + N'	SELECT 7 AS Tag' + CHAR(10)
	--SET @sql = @sql + N'		, 4 AS Parent' + CHAR(10)
	--SET @sql = @sql + N'		, t.name AS [Tables!1!name]' + CHAR(10)
	--SET @sql = @sql + N'		, f.name AS [Fields!4!name]' + CHAR(10)
	--SET @sql = @sql + N'		, f.fieldorder AS [Fields!4!order]' + CHAR(10)
	--SET @sql = @sql + @getcommentscolumns
	--SET @sql = @sql + N'		, NULL AS [option!9!key]' + CHAR(10)
	--SET @sql = @sql + N'		, NULL AS [option!9!color]' + CHAR(10)			--##TODO!!
	--SET @sql = @sql + N'	FROM field f' + CHAR(10)
	--SET @sql = @sql + N'	INNER JOIN [table] t' + CHAR(10)
	--SET @sql = @sql + N'		ON t.idtable = f.idtable' + CHAR(10)
	--SET @sql = @sql + N'	INNER JOIN attributedata ad' + CHAR(10)
	--SET @sql = @sql + N'		ON ad.idrecord = f.idfield' + CHAR(10)
	--SET @sql = @sql + N'	INNER JOIN string s' + CHAR(10)
	--SET @sql = @sql + N'		ON s.idstring = ad.value' + CHAR(10)
	--SET @sql = @sql + N'	WHERE f.idtable > 1000' + CHAR(10)
	--SET @sql = @sql + N'		AND ad.[owner] = N''field''' + CHAR(10)
	--SET @sql = @sql + N'		AND ad.name = N''comment''' + CHAR(10)
	
	---- Get description (tooltip)
	--SET @sql = @sql + N'	UNION ALL' + CHAR(10)
	--SET @sql = @sql + N'	SELECT 8 AS Tag' + CHAR(10)
	--SET @sql = @sql + N'		, 4 AS Parent' + CHAR(10)
	--SET @sql = @sql + N'		, t.name AS [Tables!1!name]' + CHAR(10)
	--SET @sql = @sql + N'		, f.name AS [Fields!4!name]' + CHAR(10)
	--SET @sql = @sql + N'		, f.fieldorder AS [Fields!4!order]' + CHAR(10)
	--SET @sql = @sql + @getdescriptionscolumns
	--SET @sql = @sql + N'		, NULL AS [option!9!key]' + CHAR(10)
	--SET @sql = @sql + N'		, NULL AS [option!9!color]' + CHAR(10)			--##TODO!!
	--SET @sql = @sql + N'	FROM field f' + CHAR(10)
	--SET @sql = @sql + N'	INNER JOIN [table] t' + CHAR(10)
	--SET @sql = @sql + N'		ON t.idtable = f.idtable' + CHAR(10)
	--SET @sql = @sql + N'	INNER JOIN attributedata ad' + CHAR(10)
	--SET @sql = @sql + N'		ON ad.idrecord = f.idfield' + CHAR(10)
	--SET @sql = @sql + N'	INNER JOIN string s' + CHAR(10)
	--SET @sql = @sql + N'		ON s.idstring = ad.value' + CHAR(10)
	--SET @sql = @sql + N'	WHERE f.idtable > 1000' + CHAR(10)
	--SET @sql = @sql + N'		AND ad.[owner] = N''field''' + CHAR(10)
	--SET @sql = @sql + N'		AND ad.name = N''description''' + CHAR(10)
	
	---- Get options
	SET @sql = @sql + N'	UNION ALL' + CHAR(10)
	SET @sql = @sql + N'	SELECT 9 AS Tag' + CHAR(10)
	SET @sql = @sql + N'		, 4 AS Parent' + CHAR(10)
	SET @sql = @sql + N'		, t.name AS [Tables!1!name]' + CHAR(10)
	SET @sql = @sql + N'		, f.name AS [Fields!4!name]' + CHAR(10)
	SET @sql = @sql + N'		, f.fieldorder AS [Fields!4!order]' + CHAR(10)
	SET @sql = @sql + @getoptionscolumns
	SET @sql = @sql + N'		, s.[key] AS [option!9!key]' + CHAR(10)
	SET @sql = @sql + N'		, col.value AS [option!9!color]' + CHAR(10)			
	SET @sql = @sql + N'	FROM field f' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN [table] t' + CHAR(10)
	SET @sql = @sql + N'		ON t.idtable = f.idtable' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN attributedata ad' + CHAR(10)
	SET @sql = @sql + N'		ON ad.idrecord = f.idfield' + CHAR(10)
	SET @sql = @sql + N'	INNER JOIN string s' + CHAR(10)
	SET @sql = @sql + N'		ON s.idcategory = ad.value' + CHAR(10)
	SET @sql = @sql + N'    OUTER APPLY (SELECT value FROM attributedata ad WHERE [owner] = ''string'' AND idrecord = s.idstring AND ad.name = ''color'') col'
	SET @sql = @sql + N'	WHERE f.idtable > 1000' + CHAR(10)
	SET @sql = @sql + N'		AND ad.[owner] = N''field''' + CHAR(10)
	SET @sql = @sql + N'		AND ad.name = N''idcategory''' + CHAR(10)
	
	-- Close SQL statement
	SET @sql = @sql + N') t' + CHAR(10)
	SET @sql = @sql + N'ORDER BY t.[Tables!1!name] ASC, t.[Fields!4!order] ASC, t.Tag ASC' + CHAR(10)
	SET @sql = @sql + N'FOR XML EXPLICIT' + CHAR(10)
	
	-- Run SQL code to get XML that will be returned to LIME Pro VBA.
	PRINT LEFT(@sql,4000)
	PRINT SUBSTRING(@sql, 4001,4000)
	EXEC sp_executesql @sql
	
END
