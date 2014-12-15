USE [jka_test]
GO

/****** Object:  StoredProcedure [dbo].[csp_admintools_get_new_indices]    Script Date: 2014-11-17 16:50:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_admintools_get_new_indices]
	-- Add the parameters for the stored procedure here
	@@retval AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	-- FLAG_EXTERNALACCESS --
	SET NOCOUNT ON;

	SET @@retval = (SELECT  TOP 10 CAST(migs.avg_total_user_cost * ( migs.avg_user_impact / 100.0 ) 
			* ( migs.user_seeks + migs.user_scans ) AS INTEGER) AS improvement_measure , 
			'CREATE INDEX [missing_index_' 
			+ CONVERT (VARCHAR, mig.index_group_handle) + '_' 
			+ CONVERT (VARCHAR, mid.index_handle) + '_' 
			+ LEFT(PARSENAME(mid.statement, 1), 32) + ']' + ' ON ' 
														  + mid.statement
			+ ' (' + ISNULL(mid.equality_columns, '') 
			+ CASE WHEN mid.equality_columns IS NOT NULL 
						AND mid.inequality_columns IS NOT NULL THEN ',' 
				   ELSE '' 
			  END + ISNULL(mid.inequality_columns, '') + ')'  
		   + ISNULL(' INCLUDE ('+ mid.included_columns + ')', '') 
			  AS create_index_statement , 
			  mid.statement,
			CAST(migs.avg_user_impact AS INTEGER) AS avg_user_impact, 
			CAST(migs.avg_system_impact AS INTEGER) AS avg_system_impact, 
			CAST(migs.avg_total_system_cost AS INTEGER) AS avg_system_cost, 
			CAST(migs.avg_total_user_cost AS INTEGER) AS avg_user_cost
	FROM    sys.dm_db_missing_index_groups mig 
			INNER JOIN sys.dm_db_missing_index_group_stats migs 
				   ON migs.group_handle = mig.index_group_handle 
			INNER JOIN sys.dm_db_missing_index_details mid 
				   ON mig.index_handle = mid.index_handle 
	WHERE   migs.avg_total_user_cost * ( migs.avg_user_impact / 100.0 ) 
			* ( migs.user_seeks + migs.user_scans ) > 10 
	AND mid.database_id = db_id()
	ORDER BY migs.avg_total_user_cost * migs.avg_user_impact 
				 * ( migs.user_seeks + migs.user_scans ) DESC
	FOR XML AUTO)
	SET @@retval = N'<indices>' + ISNULL(@@retval,N'') + N'</indices>'
END

GO

