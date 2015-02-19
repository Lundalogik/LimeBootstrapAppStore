USE [lime_basic_v5]
GO
/****** Object:  StoredProcedure [dbo].[csp_getBusinessValue]    Script Date: 2015-02-13 19:10:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<JSV
-- Create date: <2015-02-17>
-- Description:	<Used to return values for the BusinessOverview app>
-- =============================================
ALTER PROCEDURE [dbo].[csp_getBusinessOverview]
		@@lang nvarchar(5),
		@@idcompany INT,
		@@moneyFormat nvarchar(5)
AS
BEGIN
	-- FLAG_EXTERNALACCESS --

	DECLARE @lang nvarchar(5)
	set @lang = @@lang
	--CORRECT LANGUAGE BUG
	IF @lang = N'en-us'
		SET @lang = N'en_us'
	select
	(select FORMAT(CAST(ISNULL(SUM(businessvalue),0) as decimal), 'C', @@moneyFormat) as 'Total' 
	from business 
	where businesstatus != 15101 and company = @@idcompany FOR XML RAW ('value'), TYPE, root ('Total_opportunity')
	),
	(	
	select FORMAT(CAST(ISNULL(SUM(businessvalue),0) as decimal), 'C', @@moneyFormat) as 'Total' 
	from business 
	where businesstatus = 15101 and company = @@idcompany FOR XML RAW ('value'), TYPE, root ('Total_won') 
	)
	FOR XML path(''), type, ROOT ('Business');

	select
	(select CAST(ISNULL(COUNT(idhelpdesk),0) as bigint) as 'Antall_aktive' from helpdesk 
	where enddate is not null and company = @@idcompany FOR XML RAW, TYPE
	),
	(	
	select CAST(ISNULL(COUNT(idhelpdesk),0) as bigint) as 'Total_helpdesk' from helpdesk
	where company = @@idcompany FOR XML RAW ('value'), TYPE, root ('Total') 
	)
	FOR XML path(''), type, ROOT ('Helpdesk');

	--  
	-- Add the T-SQL statements to compute the return value here
	select CASE WHEN EXISTS 
		(SELECT TOP 1 DATEDIFF(day,h.[date],getdate()) as 'Last_contact', h.[note] from history h where h.company = @@idcompany
		AND h.[status] = 0 
		AND h.[type] = 168701 OR h.[type] = 179001 OR h.[type] = 168301)
		
		then (SELECT TOP 1 
		ISNULL(DATEDIFF(day,h.[date],getdate()),0) as 'Last_contact', 
		ISNULL(h.[note], 'none') from history h 
		where h.company = @@idcompany
		AND h.[status] = 0 
		AND h.[type] = 168701 OR h.[type] = 179001 OR h.[type] = 168301
		ORDER BY h.[date] DESC FOR XML RAW, ELEMENTS, ROOT ('History'))

		else (select CAST('-1' as nvarchar) as 'Last_contact' FOR XML RAW, ELEMENTS, ROOT ('History'))
		end
	
END

