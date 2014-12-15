USE [jka_test]
GO

/****** Object:  StoredProcedure [dbo].[csp_admintools_get_infologstats]    Script Date: 2014-11-17 16:49:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_admintools_get_infologstats]
	-- Add the parameters for the stored procedure here
	@@date AS DATETIME,
	@@groupby AS NVARCHAR(8),
	@@retxml AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(3500)
	DECLARE @params NVARCHAR(512)
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

	DECLARE @statstable TABLE
	(
		[timestamp] DATETIME,
		[type] INTEGER
	)

	
	IF @@groupby = N'hh'
	BEGIN
		INSERT INTO @statstable
		SELECT	DATEADD(hour, DATEDIFF(hour, 0, i.[timestamp]), 0), i.[type]
		FROM [infologdata] i
		WHERE DATEADD(hour, DATEDIFF(hour, 0, i.[timestamp]), 0) >= @startdate
		AND DATEADD(hour, DATEDIFF(hour, 0,i.[timestamp]), 0) <= @enddate
	END
	ELSE IF @@groupby = N'dd'
	BEGIN
		INSERT INTO @statstable
		SELECT	DATEADD(Day, DATEDIFF(Day, 0, i.[timestamp]), 0), i.[type]
		FROM [infologdata] i
		WHERE DATEADD(Day, DATEDIFF(Day, 0, i.[timestamp]), 0) >= @startdate
		AND DATEADD(Day, DATEDIFF(Day, 0, i.[timestamp]), 0) <= @enddate

	END
	


	DECLARE @nbr INTEGER
	DECLARE @date DATETIME = @startdate

	DECLARE @rettable TABLE
	(
		[date] DATETIME,
		[info] INTEGER,
		[warning] INTEGER,
		[error] INTEGER,
		[hh] INTEGER,
		[dd] INTEGER
	)

	WHILE @date <= @enddate
	BEGIN
		
		
		IF @@groupby = N'hh'
		BEGIN
			
			IF (SELECT COUNT(*) FROM @statstable WHERE [timestamp] = @date) > 0
			BEGIN
				INSERT INTO @rettable
				SELECT  TOP 1
					[timestamp],
					(SELECT COUNT(*) FROM @statstable WHERE [timestamp] = @date AND [type] = 0),
					(SELECT COUNT(*) FROM @statstable WHERE [timestamp] = @date AND [type] = 1),
					(SELECT COUNT(*) FROM @statstable WHERE [timestamp] = @date AND [type] = 2),
					DATEPART(HH,@date),
					0
				FROM @statstable
				WHERE [timestamp] = @date 
			END
			ELSE
			BEGIN
				INSERT INTO @rettable
				SELECT @date, 0, 0, 0, DATEPART(HH,@date), 0
			END
			SELECT @date = DATEADD(hh,1,@date)
		END
		ELSE IF @@groupby = N'dd'
		BEGIN
			IF (SELECT COUNT(*) FROM @statstable WHERE [timestamp] = @date) > 0
			BEGIN
				INSERT INTO @rettable
				SELECT TOP 1
					[timestamp],
					(SELECT COUNT(*) FROM @statstable WHERE [timestamp] = @date AND [type] = 0),
					(SELECT COUNT(*) FROM @statstable WHERE [timestamp] = @date AND [type] = 1),
					(SELECT COUNT(*) FROM @statstable WHERE [timestamp] = @date AND [type] = 2),
					0,
					DATEPART(DD,@date)
				FROM @statstable
				WHERE [timestamp] = @date 
			END
			ELSE
			BEGIN
				INSERT INTO @rettable
				SELECT @date, 0, 0, 0, 0, DATEPART(DD,@date)
				
			END
			SELECT @date = DATEADD(DD,1,@date)
		END
	end

	
	SET @@retxml = ISNULL(N'<errors>' + (SELECT * FROM @rettable e FOR XML AUTO) + N'</errors>' ,N'')


END

GO

