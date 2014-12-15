USE [jka_test]
GO

/****** Object:  StoredProcedure [dbo].[csp_admintools_trigger_sqlonupdate]    Script Date: 2014-11-17 16:51:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_admintools_trigger_sqlonupdate]
	-- Add the parameters for the stored procedure here
	@@table AS NVARCHAR(64)
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = ''
	SELECT @sql = @sql + ', [' + f.[name] + '] = (' + a.[value] + ')' + CHAR(10) FROM [attributedata] AS a
								 INNER JOIN [field] AS f ON a.[idrecord] = f.[idfield]
								 INNER JOIN [table] AS t ON f.[idtable] = t.[idtable]
								 WHERE a.[owner] = 'field'
								 AND [a].[name] ='onsqlupdate'
								 AND t.[name] = @@table
                             
	SET @sql = 'UPDATE ['+ @@table +'] SET [status] = [status] ' + @sql
	SET @sql = @sql + ' WHERE [status] = 0'
	EXECUTE(@sql)
END

GO

