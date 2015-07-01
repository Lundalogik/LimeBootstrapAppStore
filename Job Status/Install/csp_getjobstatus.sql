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
-- Author:		AAS
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE csp_getjobstatus
	@@job_name AS NVARCHAR(64),
	@@xml AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --

	DECLARE @sql AS nvarchar(max) 
	DECLARE @result as XML
	
	SELECT @sql = (
					N'SELECT @result = ( 
						SELECT top 1 
									j.name AS ''JobName'', 
									h.step_id AS ''step'', 
									msdb.dbo.agent_datetime(run_date,run_time) AS ''RunDateTime'',
									STUFF(STUFF(REPLACE(STR(run_duration,6,0),'' '',''0''), 3,0,'':''),6,0,'':'') AS run_duration_formatted,
									h.[message],
									h.run_status,
									j.[enabled]
						FROM msdb.dbo.sysjobs j 
						INNER JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
						WHERE j.name like ''' + @@job_name + '''
						and h.step_id = 0
						ORDER BY ''RunDateTime'' DESC
					FOR XML PATH(''job''))')
					-- , ROOT(''jobstatus'')
	print @sql
	EXEC sp_executesql @sql, N'@result as xml OUTPUT', @result OUTPUT
	SET @@xml = CASE WHEN @result IS NULL THEN '' ELSE CAST(@result AS NVARCHAR(MAX)) END

END
GO
