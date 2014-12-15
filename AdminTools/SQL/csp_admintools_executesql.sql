USE [jka_test]
GO

/****** Object:  StoredProcedure [dbo].[csp_admintools_executesql]    Script Date: 2014-11-17 16:49:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_admintools_executesql]
	-- Add the parameters for the stored procedure here
	@@sql AS NVARCHAR(MAX)
AS
BEGIN
	--FLAG_EXTERNALACCESS--
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    EXECUTE(@@sql)
END

GO

