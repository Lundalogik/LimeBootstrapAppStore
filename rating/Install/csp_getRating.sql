-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<ATH @ Lundalogik AS>
-- Create date: <12.04.2017>
-- Description:	<Sums up rating on a selected company>
-- =============================================
ALTER PROCEDURE [dbo].[csp_getRating]
	-- Add the parameters for the stored procedure here
	@@idcompany INT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	-- FLAG_EXTERNALACCESS --

	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT (
		SELECT count(score) as 'amount', score as 'score' FROM rating WHERE rating.[status] = 0 AND company = @@idcompany GROUP BY score
		FOR XML RAW('value'), TYPE, ROOT('score')
	),
	(
		SELECT count(idrating) as 'totalvotes', count(DISTINCT score) as 'uniquevotes', SUM(score) as 'totalscore', AVG(score) as 'avg'
		FROM rating WHERE rating.[status] = 0 AND company = @@idcompany
		FOR XML RAW('value'), TYPE, ROOT('vote')
	)
	FOR XML PATH(''), TYPE, ROOT('rating')
END
GO
