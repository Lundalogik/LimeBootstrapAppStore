USE [limedemo_v2]
GO
/****** Object:  StoredProcedure [dbo].[csp_getBusinessValue]    Script Date: 2016-08-31 10:32:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<SSM
-- Create date: <2013-10-16>
-- Description:	<Used to return busniessvaluesw>
-- =============================================
ALTER PROCEDURE [dbo].[csp_getBusinessValue]
		@@lang nvarchar(5),
		@@idcoworker INT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	
	DECLARE @lang nvarchar(5)
	set @lang = @@lang
	--CORRECT LANGUAGE BUG
	IF @lang = N'en-us'
		SET @lang = N'en_us'
		
	SELECT   
		(Select s.stringorder as stringorder ,s.[key] as [key] , dbo.lfn_getstring2(b.dealstatus,@lang) as [dealstatus], CAST(sum(value) as bigint) as [value] 
		from [deal] b 
		inner join string s on s.idstring=b.dealstatus 
		WHERE b.[status]=0
		group by [dealstatus], s.[stringorder], s.[key] 
		order by s.[stringorder] asc 
		FOR XML RAW ('value'), TYPE, ROOT ('all')
    ),
           
    (
		Select  s.stringorder as [stringorder],s.[key] as [key], dbo.lfn_getstring2(b.dealstatus,@lang) as [dealstatus], CAST(sum(value) as bigint) as [value] 
		from [deal] b
		inner join string s on s.idstring=b.dealstatus 
		where b.coworker =@@idcoworker and b.[status]=0
		group by [dealstatus], s.[stringorder], s.[key] 
		order by s.[stringorder] asc 
		FOR XML RAW ('value'), TYPE, ROOT ('coworker')
    )
	FOR XML PATH(''), TYPE, ROOT ('businessfunnel');	
	
	
END