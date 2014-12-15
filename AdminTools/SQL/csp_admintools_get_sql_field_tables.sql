USE [jka_test]
GO

/****** Object:  StoredProcedure [dbo].[csp_admintools_get_sql_field_tables]    Script Date: 2014-11-17 16:50:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_admintools_get_sql_field_tables]
	@@retval AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @rettable TABLE
	(
		[tname] NVARCHAR(64),
		[localname] NVARCHAR(64),
		[count] INTEGER
	)

	INSERT INTO @rettable
	SELECT	t.[name],
			s1.[sv],
			COUNT(t.[name])
	FROM [field] f
	INNER JOIN [attributedata] a ON a.[idrecord] = f.[idfield] AND a.[owner] = N'field'
	INNER JOIN [table] t ON t.[idtable] = f.[idtable]
	INNER JOIN [string] s1 ON s1.[idstring] = t.[localname]
	WHERE a.[name] like N'%sql%'
	AND [idfield] > 1000
	GROUP BY t.[name], s1.[sv]

	SET @@retval = (SELECT * FROM @rettable AS [table] ORDER BY [count] DESC
					FOR XML AUTO)

	SET @@retval = N'<tables>' + @@retval + N'</tables>'
END

GO

