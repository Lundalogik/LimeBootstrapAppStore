USE [limedemo_v2]
GO

/****** Object:  StoredProcedure [dbo].[csp_getCampaignParticipants]    Script Date: 11/26/2013 23:58:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<SSM
-- Create date: <2013-11-23>
-- Description:	<Used to return the number of participants in each status>
-- =============================================
CREATE PROCEDURE [dbo].[csp_getCampaignParticipants]
		@@lang nvarchar(5),
		@@idcampaign INT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	
	DECLARE @lang nvarchar(5)
	set @lang = @@lang
	--CORRECT LANGUAGE BUG
	IF @lang = N'en-us'
		SET @lang = N'en_us'
		
	select dbo.lfn_getstring2(p.participantstatus,@lang) as [participantstatus],
	COUNT(p.idparticipant) as [counter] 
	from participant p
	inner join string s on s.idstring = p.participantstatus
	where campaign = 1701
	group by p.participantstatus
	FOR XML RAW ('value'), TYPE, ROOT ('participants')	
	
END
GO

