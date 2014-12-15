USE [jka_test]
GO

/****** Object:  StoredProcedure [dbo].[csp_admintools_get_procedures]    Script Date: 2014-11-17 16:50:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_admintools_get_procedures]
	-- Add the parameters for the stored procedure here
	@@retval NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	-- FLAG_EXTERNALACCESS --
	SET NOCOUNT ON;

	SET @@retval = (
					SELECT	[name],
							[modify_date], 
							[type_desc] 
					FROM	[sys].[objects] AS p 
					WHERE (
							[name] LIKE N'%cfn%' 
							OR [name] LIKE '%csp%'
						  ) AND [name] NOT LIKE '%admintools%' 
					ORDER BY [modify_date] DESC 
					FOR XML AUTO
					)
	SET @@retval = N'<procedures>' + ISNULL(@@retval,N'') + N'</procedures>'
END

GO

