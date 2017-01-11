/****** Object:  StoredProcedure [dbo].[csp_lip_getxmldatabase_wrapper]    Script Date: 2017-01-03 10:26:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Written by: JKA, PDE and FER, Lundalogik AB
-- Created: 2016-01-25

-- Called by the LIP Package Builder. Returns relevant XML structure for the database.

CREATE PROCEDURE [dbo].[csp_lip_getxmldatabase_wrapper]
	@@lang NVARCHAR(5)
	, @@idcoworker INT = NULL
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @xmlasstring NVARCHAR(MAX)
	DECLARE @xml XML
	DECLARE @subxml NVARCHAR(MAX)
	
	-- Get complete xml structure
	EXECUTE lsp_getxmldatabase
		@@lang = @@lang
		, @@setstrings = 1
		, @@user = 1
		, @@fulloutput = 1
		, @@xml = @xmlasstring OUTPUT
	
	-- Escape tokens \ and " to prevent trouble when converting to JSON later on.
	SET @xml = CONVERT(XML, REPLACE(
								REPLACE(@xmlasstring, N'\', N'\\')
								, N'&quot;', N'\&quot;')
							)
	
	-- Only return relevant xml
	SET @subxml = N'<database><tables>'
	
	-- Remove system tables
	SET @xml.modify('delete (/database/table[@idtable<1000])[*]')

	-- Remove system fields
	SET @xml.modify('delete (/database/table[@idfield<1000])[*]')
	
	-- Remove system fields
	SET @xml.modify('delete (/database/table[@sql!=''''])[*]')
	

	DECLARE @procedurexml XML	
	SELECT @procedurexml = (
	SELECT o.name, CAST(m.definition AS VARBINARY(MAX)) AS definition FROM sys.objects o
	INNER JOIN sys.sql_modules m ON o.object_id = m.object_id
	WHERE o.name NOT LIKE 'lfn%' AND o.name NOT LIKE '%lsp%'
	AND (type = 'P' OR type = 'TF' OR type = 'fn')
	FOR XML PATH('ProcedureOrFunction'), ROOT('sql'), BINARY BASE64
	)
	



	DECLARE @iconXml XML
    SELECT @iconXml = (
		SELECT t.name AS [table], f.data AS iconbinarydata 
		FROM attributedata ad
		INNER JOIN [table] t ON ad.idrecord = t.idtable
		INNER JOIN [file] f ON ad.value = f.idfile
		WHERE ad.owner = 'table'
		AND ad.name = 'icon'
		AND t.idtable > 1000
		FOR XML PATH('tableicon'), ROOT('tableicons'), BINARY BASE64
	)

	DECLARE @descriptiveXml XML
	SELECT @descriptiveXml =
	(
		SELECT t.c.value('../@name','nvarchar(512)') AS [table], t.c.value('@sql','nvarchar(512)') AS expression
		FROM @xml.nodes('/database/table/field[@name="descriptive" and @sql!="''''"]') AS t(c)
		FOR XML PATH('descriptive'), ROOT('descriptives')
	)
	
	
	DECLARE @optionQuery XML
	-- Fetch owner, the readable optionquery and the entire file as binary
	SELECT @optionQuery =(
		SELECT t.name + '.' + fi.name AS [owner], CAST(data AS XML).value('(/queries/@text)[1]','nvarchar(512)') AS [text] 
		FROM [file] f 
		INNER JOIN attributedata ad ON ad.value = f.idfile
		INNER JOIN field fi ON ad.idrecord = fi.idfield
		INNER JOIN [table] t ON fi.idtable = t.idtable
		WHERE filetype = 2
		AND fi.idtable > 1000
		AND ad.name = 'optionquery'
		FOR XML PATH('optionquery'), ROOT('optionqueries'), BINARY BASE64
	)


	SELECT @subxml = @subxml + CAST(T.C.query('.') AS NVARCHAR(MAX))
	FROM @xml.nodes('/database/table') AS T(C) 
	
	SET @subXml = @subxml + '</tables>'+ CAST(@descriptiveXml as nvarchar(max)) + CAST(@procedureXml AS nvarchar(MAX)) + CAST(@iconXml AS NVARCHAR(MAX)) + CAST(@optionQuery AS NVARCHAR(MAX)) + '</database>'

	-- Return data to client
	SELECT @subxml
END
