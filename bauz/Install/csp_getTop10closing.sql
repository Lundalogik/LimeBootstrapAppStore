USE [appathondeluxe]
GO

/****** Object:  StoredProcedure [dbo].[csp_getTop10closing]    Script Date: 2015-12-10 20:15:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<ILE>
-- Create date: <2015-02-13>
-- Description:	<Used to return top five sales reps>
-- =============================================
CREATE PROCEDURE [dbo].[csp_getTop10closing]

AS
BEGIN
	-- FLAG_EXTERNALACCESS --

	SELECT top 10 ISNULL(LEFT(co.name, 32), '-') as name, CONVERT(NVARCHAR(32), CAST(b.businessvalue as INT)) as businessvalue, ISNULL(c.name, '-') as coworkername
	FROM business b
	INNER JOIN [string] s
		ON s.idstring = b.businesstatus
		AND s.[key] = 'tender'
	LEFT JOIN coworker c
		ON c.idcoworker = b.coworker
		AND c.[status] = 0
	LEFT JOIN company co
		ON b.company = co.idcompany
		AND co.[status] = 0
	WHERE b.[status] = 0
	ORDER BY b.[businessvalue] DESC

	FOR XML RAW ('value'), TYPE, ROOT ('top10closing');

	--Select top 10 c.name, c.idcoworker, CAST(sum(b.businessvalue) as bigint) as businessvalue 
	--from business b inner join coworker c 
	--	on b.coworker = c.idcoworker 
	--where b.quotesent >= DATEADD(day, -@@dayrange, convert(date, getdate())) and b.businesstatus = @@businessstatus
	--group by c.[name], c.[idcoworker] 
	--order by [businessvalue] desc 
	
	
	
END
GO

