SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Andreas Åström, Lundalogik AB
-- Create date: 2014-03-11
-- Description:	Returns 1 if the provided search string contains a logical operator (AND, OR, &&)
--				and 0 otherwise.

-- Modified: 2018-01-10, Fredrik Eriksson, Lundalogik AB
--			Updated according to requirements on Community Add-ons.
-- =============================================
CREATE FUNCTION [dbo].[cfn_addon_documentsearch_hasoperator] 
(
	@searchstring  NVARCHAR(4000)
)
RETURNS BIT
AS
BEGIN
	DECLARE @and NVARCHAR(10)
	DECLARE @or NVARCHAR(10)
	DECLARE @andchar NVARCHAR(10)
	DECLARE @return BIT

	SET @and = N' AND '
	SET @or = N' OR '
	SET @andchar = N' && '

	IF CHARINDEX(@and, @searchstring) != 0
			OR CHARINDEX(@or, @searchstring) != 0
			OR CHARINDEX(@andchar, @searchstring) != 0
	BEGIN
		SET @return =  1
	END
	ELSE
	BEGIN
		SET @return =  0
	END
	RETURN @return
END
