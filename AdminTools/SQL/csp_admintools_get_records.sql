USE [jka_test]
GO

/****** Object:  StoredProcedure [dbo].[csp_admintools_get_records]    Script Date: 2014-11-17 16:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_admintools_get_records]
	-- Add the parameters for the stored procedure here
	@@date AS DATETIME,
	@@format AS NVARCHAR(8),
	@@retval AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(3500)
	DECLARE @params NVARCHAR(512)

	DECLARE @statstable TABLE
	(
		[timestamp] DATETIME,
		[deleted] BIT,
		[new] BIT,
		[updated] BIT,
		[idrecord] INTEGER,
		[table] NVARCHAR(32)
	)
	
	
	IF @@format = N'hh'
	BEGIN
		INSERT INTO @statstable
		SELECT	DATEADD(hour, DATEDIFF(hour, 0, u.[timestamp]), 0),
				u.[deleted],
				u.[new],
				u.[updated],
				u.[idrecord],
				u.[table]
		FROM [updatelog] u
		INNER JOIN [table] t ON t.[name] = u.[table] 
		WHERE DATEADD(hour, DATEDIFF(hour, 0, u.[timestamp]), 0) = @@date
		AND t.[idtable] > 1000
	END
	ELSE IF @@format = N'dd'
	BEGIN
		INSERT INTO @statstable
		SELECT	DATEADD(Day, DATEDIFF(Day, 0, u.[timestamp]), 0),
				u.[deleted],
				u.[new],
				u.[updated],
				u.[idrecord],
				u.[table]
		FROM [updatelog] u
		INNER JOIN [table] t ON t.[name] = u.[table] 
		WHERE DATEADD(Day, DATEDIFF(Day, 0, u.[timestamp]), 0) = @@date
		AND t.[idtable] > 1000
	END
	

	DECLARE @new AS NVARCHAR(MAX)
	DECLARE @updated AS NVARCHAR(MAX)
	DECLARE @deleted AS NVARCHAR(MAX)

	SELECT @new =  N'<new>' + (SELECT 
						n.[idrecord],
						n.[table],
						COUNT(n.[idrecord]) AS N'nbr',
						CASE WHEN (SELECT TOP 1 u.[idrecord] FROM [updatelog] u WHERE u.[deleted] = 1 AND u.[idrecord] = n.[idrecord]) IS NOT NULL THEN 1
						ELSE 0 END AS 'removed'
					FROM @statstable n
					WHERE n.[new] = 1 
					GROUP BY n.[idrecord],n.[table]
					FOR XML AUTO) + N'</new>'
	SELECT @updated =  N'<updated>' + (SELECT 
						u.[idrecord],
						u.[table],
						COUNT(u.[idrecord]) AS N'nbr',
						CASE WHEN (SELECT TOP 1 u2.[idrecord] FROM [updatelog] u2 WHERE u2.[deleted] = 1 AND u2.[idrecord] = u.[idrecord]) IS NOT NULL THEN 1
						ELSE 0 END AS 'removed'
					FROM @statstable u
					WHERE u.[updated] = 1 AND u.[new] = 0
					GROUP BY u.[idrecord], u.[table]
					FOR XML AUTO) + N'</updated>'
	SELECT @deleted =  N'<deleted>' + (SELECT 
						d.[idrecord],
						d.[table],
						COUNT(d.[idrecord]) AS N'nbr',
						1 as 'removed'
					FROM @statstable d
					WHERE d.[deleted] = 1 
					GROUP BY d.[idrecord], d.[table]
					FOR XML AUTO) + N'</deleted>'
	SELECT @@retval = N'<records>' + ISNULL(@new,N'<new></new>') + ISNULL(@updated, N'<updated></updated>') + ISNULL(@deleted,N'<deleted></deleted>') + N'</records>'
END



GO

