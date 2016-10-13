-- Written by: Fredrik Eriksson
-- Created: 2016-03-11

-- Returns the SQL expression for the specified field.
CREATE FUNCTION [dbo].[cfn_embrello_getsqlexpression]
(
	@@tablename NVARCHAR(64)
	, @@fieldname NVARCHAR(64)
	, @@tablealias NVARCHAR(32)
	, @@iduser INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @exp NVARCHAR(MAX)
	SET @exp = ISNULL(
		(
			SELECT N'(' + ad.[value] + N')'
			FROM attributedata ad
			INNER JOIN field f
				ON f.idfield = ad.idrecord
			INNER JOIN [table] t
				ON t.idtable = f.idtable
			WHERE ad.[owner] = N'field'
				AND ad.name = N'sql'
				AND t.name = @@tablename
				AND f.name = @@fieldname
		)
	, N'')
	
	IF @exp <> N''
	BEGIN
		-- Fix expression so that it works in the Embrello query
		SET @exp = REPLACE(@exp, N'[' + @@tablename + N'].', N'[' + @@tablealias + N'].')
		
		-- Replace @iduser if that tricky old thing has been used in the SQL expression
		SET @exp = REPLACE(@exp, N'@iduser', @@iduser)
		
	END
	
	RETURN @exp
END