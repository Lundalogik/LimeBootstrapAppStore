USE [limedemov2]
GO

/****** Object:  StoredProcedure [dbo].[csp_getHelpdeskStatistics]    Script Date: 11/12/2013 00:05:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<SSM>
-- Create date: <11/11/2013>
-- Description:	<returns helpdeskl statics in XMl>
-- =============================================
CREATE PROCEDURE [dbo].[csp_getHelpdeskStatistics]
	@@idcoworker INT
	
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	
	SET DATEFIRST 1

	--DECLARE @@idcoworker INT 

	--SET @@idcoworker = 1001

	SELECT
		--statics for general helpdesk tickets
		(SELECT 
			SUM(CASE WHEN [enddate] IS NULL THEN 1 ELSE 0 END) AS 'open'
			,SUM(CASE WHEN [startdate] IS NULL THEN 1 ELSE 0 END) AS 'notInitiated'
			,SUM(CASE WHEN [deadlinedate] < GETDATE() AND [enddate] IS NULL THEN 1 ELSE 0 END) AS 'delayed'            
		FROM [helpdesk]
		WHERE [status] = 0
		AND [enddate] IS NULL
		FOR XML RAW('value'),TYPE, ROOT('general')
		),
		
		--statics for coworker helpdesk tickets
		(SELECT 
			SUM(CASE WHEN [coworker] = @@idcoworker AND [enddate] IS NULL THEN 1 ELSE 0 END) AS 'open'
			,SUM(CASE WHEN [coworker] = @@idcoworker AND [startdate] IS NULL THEN 1 ELSE 0 END) AS 'notInitiated'
			,SUM(CASE WHEN [coworker] = @@idcoworker AND [deadlinedate] < GETDATE() AND [enddate] IS NULL THEN 1 ELSE 0 END) AS 'delayed'
	            
		FROM [helpdesk]
		WHERE [status] = 0
		AND [enddate] IS NULL
		FOR XML RAW('value'),TYPE, ROOT('coworker')	
		),
		
		--statics for incomming helpdesk tickets
		(SELECT 
			SUM(CASE WHEN CONVERT(NVARCHAR, [createdtime], 23) = CONVERT(NVARCHAR, GETDATE(), 23) THEN 1 ELSE 0 END) AS 'today'
			,SUM(CASE WHEN DATEPART(YEAR, [createdtime]) = DATEPART(yy, GETDATE()) AND DATEPART(ww, [createdtime]) = DATEPART(ww, GETDATE()) THEN 1 ELSE 0 END) AS 'week'
			,SUM(CASE WHEN DATEPART(YEAR, [createdtime]) = DATEPART(yy, GETDATE()) AND DATEPART(mm, [createdtime]) = DATEPART(mm, GETDATE()) THEN 1 ELSE 0 END) AS 'month'
	            
		FROM [helpdesk]
		WHERE [status] = 0
		FOR XML RAW('value'),TYPE, ROOT('incomming')	
		),
		
		--statics for closed helpdesk tickets
		(SELECT 
			SUM(CASE WHEN CONVERT(NVARCHAR, [enddate], 23) = CONVERT(NVARCHAR, GETDATE(), 23) THEN 1 ELSE 0 END) AS 'today'
			,SUM(CASE WHEN DATEPART(YEAR, [enddate]) = DATEPART(yy, GETDATE()) AND DATEPART(ww, [enddate]) = DATEPART(ww, GETDATE()) THEN 1 ELSE 0 END) AS 'week'
			,SUM(CASE WHEN DATEPART(YEAR, [enddate]) = DATEPART(yy, GETDATE()) AND DATEPART(mm, [enddate]) = DATEPART(mm, GETDATE()) THEN 1 ELSE 0 END) AS 'month'     
		FROM [helpdesk]
		WHERE [status] = 0
		FOR XML RAW('value'),TYPE, ROOT('closed')
	)
	FOR XML PATH(''), TYPE, ROOT ('helpdeskstatics');	
		
	
END


GO

