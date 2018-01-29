SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Andreas Åström, Lundalogik AB
-- Create date: 2014-03-11
-- Description:	Checks which type of logic operator that is used in the search string.

-- Modified: 2018-01-10, Fredrik Eriksson, Lundalogik AB
--			Updated according to requirements on Community Add-ons.
-- =============================================
CREATE FUNCTION [dbo].[cfn_addon_documentsearch_getoperator]
(
	@searchstring  NVARCHAR(4000)
)
RETURNS NVARCHAR(10)
AS
BEGIN
	
	DECLARE @and NVARCHAR(10)
	DECLARE @or NVARCHAR(10)
	DECLARE @andchar NVARCHAR(10)
	DECLARE @return NVARCHAR(10)

	-- Define operators to search for
	SET @and = N' AND '
	SET @or = N' OR '
	SET @andchar = N' && '

	IF CHARINDEX(@and, @searchstring) != 0
	BEGIN
		SET @return = @and
	END
	ELSE IF CHARINDEX(@or, @searchstring) != 0
	BEGIN
		SET @return = @or
	END
	ELSE IF CHARINDEX(@andchar, @searchstring) != 0
	BEGIN
		SET @return = @andchar
	END
	
	RETURN @return
END
