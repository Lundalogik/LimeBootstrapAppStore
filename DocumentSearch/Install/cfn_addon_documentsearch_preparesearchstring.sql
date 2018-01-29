SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Andreas Åström, Lundalogik AB
-- Create date: 2014-03-11
-- Description:	Handles the search string to be used in a full-text search

-- Modified: 2018-01-10, Fredrik Eriksson, Lundalogik AB
--			Updated according to requirements on Community Add-ons.
-- =============================================
CREATE FUNCTION [dbo].[cfn_addon_documentsearch_preparesearchstring]
(
	@@searchstring NVARCHAR(4000)
)
RETURNS NVARCHAR(4000)
AS
BEGIN

	IF [dbo].[cfn_addon_documentsearch_hasoperator](@@searchstring) = 1
	BEGIN 	
	
		DECLARE @word NVARCHAR(512)
		DECLARE @type NVARCHAR(10)
		DECLARE @subword NVARCHAR(512)
		DECLARE @rows INT
		
		SET @rows = 0
		
		DECLARE @stringTable TABLE
		(
			[rows] INT
			, [word] NVARCHAR(32)
			, [separator] NVARCHAR(32)
			, [done] INT
		)

		WHILE [dbo].[cfn_addon_documentsearch_hasoperator](@@searchstring) = 1
		BEGIN
			SET @type = N''
			SET @type = [dbo].[cfn_addon_documentsearch_getoperator](@@searchstring)
			SET @word = SUBSTRING(@@searchstring, 0, CHARINDEX(@type, @@searchstring))
			SET @@searchstring = SUBSTRING(@@searchstring, CHARINDEX(@type, @@searchstring) + LEN(@type), LEN(@@searchstring))
		
			IF [dbo].[cfn_addon_documentsearch_hasoperator](@word) = 0
			BEGIN					
				INSERT INTO @stringTable
				(
					[word]
					, [separator]
					, [rows]
					, [done]
				)
				VALUES
				(
					@word
					, 1
					, @rows
					, 0
				)

				SET @rows = @rows + 1
				INSERT INTO @stringTable
				(
					[word]
					, [separator]
					, [rows]
					, [done]
				)
				VALUES
				(
					@type
					, 0
					, @rows
					, 0
				)
			END
			ELSE
			BEGIN
				SET @@searchstring = REPLACE(@word, N' ', N'" & "') + N' ' + @@searchstring
			END
			SET @rows = @rows + 1
		END

		INSERT INTO @stringTable
		(
			[word]
			, [separator]
			, [rows]
			, [done]
		)
		VALUES
		(
			@@searchstring
			, 1
			, @rows
			, 0
		)
	END
	ELSE
	BEGIN
		INSERT INTO @stringTable
		(
			[word]
			, [separator]
			, [rows]
			, [done]
		)
		VALUES
		(
			REPLACE(@@searchstring, N' ', N'" & "')
			, 1
			, @rows
			, 0
		)
	END

	DECLARE @count INT
	DECLARE @string NVARCHAR(256)
	DECLARE @separator NVARCHAR(10)
	SET @word = N''
	SET @string = N''

	SELECT @count = COUNT(*)
	FROM @stringTable
	WHERE word <> N''
	SET @rows = 0

	WHILE @count >= @rows
	BEGIN
		SELECT TOP 1 @word = [word]
		FROM @stringTable
		WHERE [done] = 0
			AND [word] <> N''
			AND [separator] = 1
	
		SET @separator = NULL				-- Reset the separator to prevent adding the previous one last in the string
		SELECT TOP 1 @separator = [word]
		FROM @stringTable
		where [done] = 0
			and [word] <> N''
			and [separator] = 0
		
		SET @string = @string + N'"' + RTRIM(LTRIM(ISNULL(@word, N''))) + N'"'
						+ CASE
							WHEN ISNULL(@separator, N'') = N' && '
								THEN N'AND' ELSE ISNULL(@separator, N'')
						END

		UPDATE @stringTable
		SET done = 1
		WHERE [rows] = @rows
			AND [word] <> N''
		
		SET @rows = @rows + 1

		UPDATE @stringTable
		SET [done] = 1
		WHERE [rows] = @rows
			AND word <> N''
	
		SET @rows = @rows + 1
	END

	SET @string = REPLACE(@string, N'""', N'')
	
	RETURN @string

END
