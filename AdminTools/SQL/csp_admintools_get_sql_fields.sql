USE [jka_test]
GO

/****** Object:  StoredProcedure [dbo].[csp_admintools_get_sql_fields]    Script Date: 2014-11-17 16:50:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_admintools_get_sql_fields]
	@@retval AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @rettable TABLE
	(
		[tname] NVARCHAR(64),
		[tlocalname] NVARCHAR(64),
		[fname] NVARCHAR(64),
		[flocalname] NVARCHAR(64),
		[sqltype] NVARCHAR(64)
	)

	INSERT INTO @rettable
	SELECT	t.[name],
			s1.[sv], 
			f.[name], 
			s2.[sv], 
			a.[name] 
	FROM [field] f
	INNER JOIN [attributedata] a ON a.[idrecord] = f.[idfield] AND a.[owner] = N'field'
	INNER JOIN [table] t ON t.[idtable] = f.[idtable]
	INNER JOIN [string] s1 ON s1.[idstring] = t.[localname]
	INNER JOIN [string] s2 ON s2.[idstring] = f.[localname]
	WHERE a.[name] like N'%sql%'
	AND [idfield] > 1000
	ORDER BY t.[name]

	SET @@retval = (SELECT * FROM @rettable AS sqlfield
					FOR XML AUTO)

	SET @@retval = N'<sqlfields>' + @@retval + N'</sqlfields>'
END

GO

