USE [limedemo_v2]
GO

/****** Object:  StoredProcedure [dbo].[csp_getBusinessValue]    Script Date: 11/23/2013 14:44:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<SSM
-- Create date: <2013-10-16>
-- Description:	<Used to return busniessvaluesw>
-- =============================================
CREATE PROCEDURE [dbo].[csp_getBusinessValue]
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
		(Select s.stringorder as stringorder ,s.[key] as [key] , dbo.lfn_getstring2(b.businesstatus,@lang) as [businesstatus], CAST(sum(businessvalue) as bigint) as [businessvalue] 
		from [business] b 
		inner join string s on s.idstring=b.businesstatus 
		WHERE b.[status]=0
		group by [businesstatus], s.[stringorder], s.[key] 
		order by s.[stringorder] asc 
		FOR XML RAW ('value'), TYPE, ROOT ('all')
    ),
           
    (
		Select  s.stringorder as [stringorder],s.[key] as [key], dbo.lfn_getstring2(b.businesstatus,@lang) as [businesstatus], CAST(sum(businessvalue) as bigint) as [businessvalue] 
		from [business] b
		inner join string s on s.idstring=b.businesstatus 
		where b.coworker =@@idcoworker and b.[status]=0
		group by [businesstatus], s.[stringorder], s.[key] 
		order by s.[stringorder] asc 
		FOR XML RAW ('value'), TYPE, ROOT ('coworker')
    )
	FOR XML PATH(''), TYPE, ROOT ('businessfunnel');	
	
	
END
GO

