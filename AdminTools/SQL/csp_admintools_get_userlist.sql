USE [jka_test]
GO

/****** Object:  StoredProcedure [dbo].[csp_admintools_get_userlist]    Script Date: 2014-11-17 16:50:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_admintools_get_userlist]
	-- Add the parameters for the stored procedure here
	@@date DATETIME,
	@@format NVARCHAR(8),
	@@retval NVARCHAR(MAX) OUTPUT
AS
BEGIN
	--FLAG_EXTERNALACCESS --
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @logintable TABLE
	(
		[logintime] DATETIME,
		[logouttime] DATETIME,
		[iduser] INTEGER
	)

	
	IF @@format = N'hh'
	BEGIN
		INSERT INTO @logintable
		SELECT	DATEADD(hour, DATEDIFF(hour, 0, [logintime]), 0),
				CASE
					WHEN [logouttime] IS NOT NULL THEN DATEADD(hour, DATEDIFF(hour, 0, DATEADD(hh,0,[logouttime])),0)
					WHEN [logouttime] IS NULL AND [logintime] <> (SELECT TOP 1 [logintime] FROM [session] WHERE [iduser] = s.[iduser] ORDER BY [logintime] desc) THEN DATEADD(hour, DATEDIFF(hour, 0, DATEADD(dd,1,[logintime])),0)
					ELSE DATEADD(hour, DATEDIFF(hour, 0, DATEADD(dd,1,[logintime])),0) 
				END,
				[iduser]
		FROM [session] s
	END
	ELSE IF @@format = N'dd'
	BEGIN
		INSERT INTO @logintable
		SELECT	DATEADD(Day, DATEDIFF(Day, 0, [logintime]), 0),
				CASE
					WHEN [logouttime] IS NOT NULL THEN DATEADD(Day, DATEDIFF(Day, 0, DATEADD(dd,0,[logouttime])),0)
					WHEN [logouttime] IS NULL AND [sessionidentifier] <> (SELECT TOP 1 [sessionidentifier] FROM [session] WHERE [iduser] = s.[iduser]) THEN DATEADD(hour, DATEDIFF(hour, 0, DATEADD(dd,1,[logintime])),0)
					ELSE DATEADD(Day, DATEDIFF(Day, 0, DATEADD(dd,1,[logintime])),0) 
				END,
				[iduser]
		FROM [session] s
	END
	

	DECLARE @rettable TABLE
	(
		[username] NVARCHAR(128),
		[iduser] INTEGER,
		[idcoworker] INTEGER,
		[name] NVARCHAR(128)
	)




	INSERT INTO @rettable
	SELECT u.[username], u.[iduser], NULL,N''
	FROM @logintable l 
	JOIN [user] u ON u.[iduser] = l.[iduser] 
	WHERE logintime <= @@date AND logouttime >= @@date
	GROUP BY u.[username], u.[iduser]

	UPDATE r
	SET r.[name] = c.[name],
		r.[idcoworker] = c.[idcoworker]
	FROM @rettable r
	INNER JOIN [coworker] c ON c.[username] = r.[iduser]
	
	SELECT @@retval = N'<users>' + ISNULL((SELECT * FROM @rettable as u FOR XML AUTO),N'') + N'</users>'
END

GO

