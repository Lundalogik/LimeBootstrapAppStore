USE [jka_test]
GO

/****** Object:  StoredProcedure [dbo].[csp_admintools_get_sql_job_status]    Script Date: 2014-11-17 16:50:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_admintools_get_sql_job_status]
	-- Add the parameters for the stored procedure here
	@@retval NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @retTable TABLE
	(
		[name] NVARCHAR(128),
		[step_id] INTEGER,
		[rundatetime] DATETIME,
		[runduration] NVARCHAR(16),
		[message] NVARCHAR(MAX),
		[status] INTEGER,
		[enabled] BIT
	)
	DECLARE cur CURSOR STATIC LOCAL FORWARD_ONLY FOR
	SELECT
		DISTINCT j.name
	FROM msdb.dbo.sysjobs j
	WHERE j.name LIKE '%lime%'
	DECLARE @jobname AS NVARCHAR(128)

	OPEN cur
	FETCH NEXT FROM cur INTO @jobname
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO @retTable
		SELECT 
			TOP 6
			j.name as 'JobName',
			h.step_id as 'step',
			msdb.dbo.agent_datetime(run_date, run_time) as 'RunDateTime',
			STUFF(STUFF(REPLACE(STR(run_duration, 6, 0), ' ', '0'), 3, 0, ':'), 6,
				  0, ':') AS run_duration_formatted,
			h.[message],
			h.run_status,
			j.[enabled]
		From msdb.dbo.sysjobs j 
		INNER JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id 
		WHERE j.[name] = @jobname
		--AND h.step_id = 0
		ORDER BY msdb.dbo.agent_datetime(run_date, run_time) desc, h.step_id desc
		FETCH NEXT FROM cur INTO @jobname
	END

	CLOSE cur
	DEALLOCATE cur

	SET @@retval = N'<sqljobs>' + (SELECT * FROM @retTable as job FOR XML AUTO) + N'</sqljobs>' --+ N'<job name="errortest" rundatetime="2014-07-29 08:44:49" message="Error." runduration="00:01:00" status="0" enabled="1"/><job name="disabledtest" message="Disabled." rundatetime="2014-07-29 08:44:49" runduration="00:00:00" status="1" enabled="0"/><job name="disablederrortest" message="Executed as user: NT SERVICE\SQLSERVERAGENT. The step succeeded." rundatetime="2014-07-29 08:44:49" runduration="01:00:00" status="0" enabled="0"/>
END


GO

