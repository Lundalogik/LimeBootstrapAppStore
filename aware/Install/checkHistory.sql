USE [lbstest_aas]
GO

/****** Object:  StoredProcedure [dbo].[csp_checkHistory]    Script Date: 2014-05-08 20:57:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_checkHistory]
	@idrecord as int
	,@interval1 as int
	,@interval2 as int
	,@result as NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	DECLARE @timestamp DATETIME
	DECLARE @intervalDate1 as datetime
	DECLARE @intervalDate2 as datetime
	DECLARE @val as int

	set @intervalDate1 = DATEADD(day,-@interval1,getdate())
	set @intervalDate2 = DATEADD(day,-@interval2,getdate())

	select @timestamp = 
	(SELECT TOP 1 timestamp
	from history
	where company = @idrecord
	order by timestamp desc
	)

	if @timestamp < @intervalDate2
	begin 
	set @val =  1
	end 
	else if @timestamp < @intervalDate1 
	begin
	set @val = 2
	end 
	ELSE 
	begin
	set @val = 3
	end


	select @result =
	(select @val as myvar 
	for xml raw)
END

GO

