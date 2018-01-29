USE [appathon_bos]
GO

/****** Object:  StoredProcedure [dbo].[csp_getReferences]    Script Date: 2015-11-05 20:05:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Lundalogik, BOS
-- Create date: 2015-11-05
-- Description:	Fetches an XML with potential references for a chosen prospect.
-- =============================================
CREATE PROCEDURE [dbo].[csp_getReferences]
	@@idcompany AS INT,
	@@result AS NVARCHAR(MAX) OUTPUT
	
AS
BEGIN	
	-- FLAG_EXTERNALACCESS --
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	WITH input_company (idcompany, name, relation, postalcity, turnover, classification, noofemployeescompany)
	AS
	(
		SELECT	idcompany, name, relation, postalcity, turnover, classification, noofemployeescompany
		FROM	[company]
		WHERE	idcompany = @@idcompany
	)
	SELECT @@result = (SELECT	name, idcompany
	FROM	company c
	WHERE	idcompany <> @@idcompany
	AND relation = 335501 -- Have to be a customer
	AND c.classification = (select classification from input_company)
	AND postalcity = (SELECT postalcity from input_company)
	AND (c.turnover < (SELECT turnover from input_company) * 1.2 AND c.turnover > (SELECT turnover from input_company) * 0.8)
	AND (c.noofemployeescompany < (SELECT noofemployeescompany from input_company) * 1.5 AND c.noofemployeescompany > (SELECT noofemployeescompany from input_company) * 0.5)
	FOR XML PATH('company'), ROOT('companies'))
END

GO


