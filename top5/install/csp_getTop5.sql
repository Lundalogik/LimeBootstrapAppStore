GO
/****** Object:  StoredProcedure [dbo].[csp_getTop5]    Script Date: 13.2.2015 13:44:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<ILE>
-- Create date: <2015-02-13>
-- Description:	<Used to return top five sales reps>
-- =============================================
CREATE PROCEDURE [dbo].[csp_getTop5]
	@@dayrange INT,
	@@businessstatus INT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --

	Select top 5 c.name, c.idcoworker, CAST(sum(b.businessvalue) as bigint) as businessvalue from business b inner join coworker c on b.coworker = c.idcoworker where b.quotesent >= DATEADD(day, -@@dayrange, convert(date, getdate())) and b.businesstatus = @@businessstatus
		group by c.[name], c.[idcoworker] 
		order by [businessvalue] desc 
		FOR XML RAW ('value'), TYPE, ROOT ('top5');
	
END