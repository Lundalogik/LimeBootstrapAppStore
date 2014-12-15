USE [jka_test]
GO

/****** Object:  StoredProcedure [dbo].[csp_admintools_get_database_info]    Script Date: 2014-11-17 16:49:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_admintools_get_database_info]
	-- Add the parameters for the stored procedure here
	@@retval AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @serverversion NVARCHAR(16)
	DECLARE @productversion NVARCHAR(16)
	DECLARE @sql NVARCHAR(512)
	DECLARE @memory NVARCHAR(16)
	DECLARE @totalmemory NVARCHAR(16)
	DECLARE @targetmemory NVARCHAR(16)
	DECLARE @usercount INTEGER

	SELECT @usercount = COUNT(DISTINCT iduser) FROM [session] WHERE [logintime] > DATEADD(MM,-3,GETDATE())


	SELECT @productversion = CAST(SERVERPROPERTY('productversion') AS NVARCHAR(16))

	SELECT @serverversion = CASE 
							WHEN @productversion LIKE '8.00%' THEN N'SQL Server 2000'
							WHEN @productversion LIKE '9.00%' THEN N'SQL Server 2005'
							WHEN @productversion LIKE '10.00%' THEN N'SQL Server 2008'
							WHEN @productversion LIKE '10.50%' THEN N'SQL Server 2008R2'
							WHEN @productversion LIKE '11.0%' THEN N'SQL Server 2012'
							WHEN @productversion LIKE '12.0%' THEN N'SQL Server 2014' --?!????
							END
							
	IF @serverversion LIKE '%2012%' OR @serverversion LIKE '%2014%'
	BEGIN
		SET @sql = N'SELECT @memory = physical_memory_kb/1024 FROM sys.dm_os_sys_info'
		EXEC sp_executesql @sql, N'@memory INT OUT', @memory OUT
	END
	ELSE
	BEGIN
		SET @sql = N'SELECT @memory = physical_memory_in_bytes/1024/1024 FROM sys.dm_os_sys_info'
		EXEC sp_executesql @sql, N'@memory INT OUT', @memory OUT
	END

	SELECT @totalmemory = cntr_value/1024 FROM sys.dm_os_performance_counters WHERE counter_name = N'Total Server Memory (KB)'
	SELECT @targetmemory = cntr_value/1024 FROM sys.dm_os_performance_counters WHERE counter_name = N'Target Server Memory (KB)'


	SET @@retval = (
					SELECT
					(SELECT COUNT(*) FROM [table] WHERE [idtable] > 1000) AS [tablecount],
					CONVERT(VARCHAR(25), DB.name) AS dbname,
					(SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'rows') AS [size],
					(SELECT SUM((size*8)/1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'log') AS [logsize],
					CONVERT(VARCHAR(32), create_date, 20) AS [creationdate],
					-- last backup
					ISNULL((SELECT TOP 1 CONVERT(NVARCHAR(32),BK.backup_finish_date,20)
					FROM msdb..backupset BK WHERE BK.database_name = DB.name ORDER BY backup_set_id DESC),'-') AS [lastbackup],
					(SELECT [value] FROM [setting] WHERE [name] = N'sys_version_ldc') AS N'ldcversion',
					(SELECT CONVERT(NVARCHAR(32),f.[timestamp],20) from [file] f
					JOIN [filetype] ft ON f.[filetype] = ft.[idfiletype] WHERE ft.[name] = N'vba') AS N'vbatimestamp',
					(SELECT CONVERT(NVARCHAR(32),f.[timestamp],20) from [file] f
					JOIN [filetype] ft ON f.[filetype] = ft.[idfiletype] WHERE ft.[name] = N'clientactionpad') AS N'actionpadtimestamp',
					@memory + N' MB' AS 'physmemory',
					@totalmemory + N' MB' AS 'totmemory',
					@targetmemory + N' MB' AS 'targetmemory',
					@serverversion AS N'serverversion',
					@usercount AS N'userspast90',
					ISNULL((SELECT TOP 1 CONVERT(NVARCHAR(32),d.create_date,20) FROM sys.databases d
					INNER JOIN msdb.dbo.restorehistory h ON h.destination_database_name = d.name
					WHERE d.name = DB.name
					ORDER BY d.create_date DESC),N'-') AS N'lastrestore'
					FROM sys.databases DB
					WHERE DB.name = (SELECT DB_NAME())
					FOR XML AUTO
					)
	
	SET @@retval = N'<dbinfo>' + @@retval + N'</dbinfo>'
END


GO

