USE []
GO
/****** Object:  StoredProcedure [dbo].[csp_updateContractQueue]    Script Date: 05/08/2014 21:42:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<ILE
-- Create date: <2014-04-28>
-- Description:	<Used to update contract queuepos>
-- =============================================
ALTER PROCEDURE [dbo].[csp_updateCampaignQueue]
(		
		@@idcampaign int
)
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	SET NOCOUNT ON;
	
	DECLARE @idcampaign int
	SET @idcampaign = @@idcampaign
	
	--update the count for all contracts on the desires unit
	UPDATE c
	SET
		c.queuepos = res.rnk
	FROM 
		participant c
	--join in your calculated new value
	LEFT JOIN (
		  SELECT 
		  ROW_NUMBER() OVER(ORDER BY queuetime) AS rnk,
		  idparticipant
		  FROM participant
		  WHERE queuetime is not null and campaign = @@idcampaign
		  
	) res ON res.idparticipant = c.idparticipant
	WHERE 1=1
		  AND c.campaign = @@idcampaign
		  AND c.queuetime is not null
		  
END
