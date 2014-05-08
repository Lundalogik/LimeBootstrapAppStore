USE [lbstest_aas]
GO

/****** Object:  StoredProcedure [dbo].[csp_checkHelpdesk]    Script Date: 2014-05-08 20:57:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_checkHelpdesk]
	@xml as nvarchar(max) output 
	,@idrecord as int 
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	declare @count as int  

	select @count = count(*) 
	from helpdesk 
	where company = @idrecord 

	select @xml =
	(select @count as myvar 
	for xml raw)
END

GO

