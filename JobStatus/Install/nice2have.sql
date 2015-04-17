
;WITH historyrecords
AS
(	 
	SELECT ROW_NUMBER() OVER(PARTITION BY job_id ORDER BY msdb.dbo.agent_datetime(run_date,run_time) DESC) AS nbr
		, job_id
		, step_id
		, run_status
		, msdb.dbo.agent_datetime(run_date,run_time) AS runDateTime
		, run_duration
		, [message]
	from msdb.dbo.sysjobhistory 
	where step_id = 0
)
SELECT top 10
		j.name AS 'JobName', 
		h.step_id AS 'step', 
		h.runDateTime,
		STUFF(STUFF(REPLACE(STR(h.run_duration,6,0),'','0'), 3,0,':'),6,0,':') AS run_duration_formatted,
		h.[message],
		h.run_status,
		j.[enabled], 
		j.job_id  
FROM msdb.dbo.sysjobs j 
INNER JOIN historyrecords h
	ON j.job_id = h.job_id
		AND h.nbr = 1
WHERE j.name like 'Area52 to Lime Pro'
	AND h.step_id = 0
ORDER BY RunDateTime DESC



--select * from msdb.dbo.sysjobhistory
--order by instance_id



