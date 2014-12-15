USE [jka_test]
GO

/****** Object:  StoredProcedure [dbo].[csp_admintools_search_in_programmability]    Script Date: 2014-11-17 16:50:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_admintools_search_in_programmability]
	-- Add the parameters for the stored procedure here
	@@searchval NVARCHAR(128),
	@@retval NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	-- FLAG_EXTERNALACCESS --
	SET NOCOUNT ON;


    SET @@retval = CAST((SELECT TOP 10 s.[name] AS name, s.[type_desc] as 'type', --N'...' +  SUBSTRING(m.[definition],CHARINDEX(@@searchval,m.definition) - 30,80) + N'...' AS N'code',
	(LEN(m.[definition]) - LEN(REPLACE(m.[definition],@@searchval,N'')))/LEN(@@searchval) AS nbr
	FROM sys.sql_modules m 
	INNER JOIN sys.objects s
	ON m.object_id=s.object_id
	WHERE CHARINDEX(@@searchval,m.definition) > 0
	AND (s.[name] LIKE '%csp%' OR s.[name] LIKE '%cfn%')
	ORDER by nbr DESC
	FOR XML AUTO) AS NVARCHAR(MAX))

	SET @@retval = N'<searchresult>' + ISNULL(@@retval,N'') + N'</searchresult>'
	
END

GO

