USE [jka_test]
GO

/****** Object:  StoredProcedure [dbo].[csp_admintools_get_login_stats]    Script Date: 2014-11-17 16:49:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_admintools_get_login_stats]
	-- Add the parameters for the stored procedure here
	@@date AS DATETIME,
	@@groupby AS NVARCHAR(8),
	@@sessionxml AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET NOCOUNT ON;

	DECLARE @startdate DATETIME
	DECLARE @enddate DATETIME
	DECLARE @diff INTEGER

	

	IF @@groupby = N'dd'
	BEGIN
		SET @diff = 3 - DATEDIFF(dd,@@date,GETDATE())
		IF @diff < 0
			SET @diff = 0
		SET @startdate = DATEADD(dd,-3 - @diff,@@date)
		SET @enddate = DATEADD(mi,59,DATEADD(hh,23,DATEADD(dd, 3 - @diff, @@date)))
	END
	ELSE IF @@groupby = N'hh'
	BEGIN
		SET @diff = 23 - DATEDIFF(hh,@@date,GETDATE())
		IF @diff < 0
			SET @diff = 0
		SET @startdate = DATEADD(hh, - @diff, @@date)
		SET @enddate = DATEADD(mi,59,DATEADD(hh,23 -@diff,@@date))
	END

	DECLARE @logintable TABLE
	(
		[logintime] DATETIME,
		[logouttime] DATETIME,
		[iduser] INTEGER
	)

	
	IF @@groupby = N'hh'
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
	ELSE IF @@groupby = N'dd'
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
	


	DECLARE @nbr INTEGER
	DECLARE @date DATETIME = @startdate

	DECLARE @rettable TABLE
	(
		[date] DATETIME,
		[Nbr] INTEGER,
		[hh] INTEGER,
		[dd] INTEGER
	)

	WHILE @date <= @enddate
	BEGIN
		

		IF @@groupby = N'hh'
		BEGIN
			INSERT INTO @rettable
			SELECT @date, COUNT(DISTINCT iduser), DATEPART(HH,@date),0 FROM @logintable WHERE logintime <= @date AND logouttime >= @date
			SELECT @date = DATEADD(hh,1,@date)
		END
		ELSE IF @@groupby = N'dd'
		BEGIN
			INSERT INTO @rettable
			SELECT CAST(@date AS DATE), COUNT(DISTINCT iduser),0,DATEPART(DD,@date) FROM @logintable WHERE logintime <= @date AND logouttime >= @date
			SELECT @date = DATEADD(DD,1,@date)
		END
	end

	

	SET @@sessionxml = N'<sessions>' + (SELECT * FROM @rettable s FOR XML AUTO) + N'</sessions>' 

	
	
END

GO

