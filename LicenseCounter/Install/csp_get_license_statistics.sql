﻿USE [Lime_prod]
GO
/****** Object:  StoredProcedure [dbo].[csp_get_license_statistics]    Script Date: 03/22/2016 10:20:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[csp_get_license_statistics]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @nbr AS INTEGER
	DECLARE @date AS DATETIME = GETDATE()
	DECLARE @idlicenses INTEGER

	SELECT @nbr = COUNT(*) FROM [user] u
	INNER JOIN [coworker] c ON c.[username] = u.[iduser]
	WHERE u.[username] NOT LIKE '%llab%'
	AND u.[username] NOT LIKE '%lundalogik%'
	AND u.[username] NOT LIKE '%test%'
	AND u.[username] NOT LIKE '%admin%'
	AND c.[status] = 0
	AND u.[iduser] NOT IN ( 
							SELECT ad.[idrecord]
							FROM dbo.[attributedata] ad
							WHERE ad.[owner] = N'user'
							AND ad.[name] = N'active'
							AND ad.[value] = N'0'
							)
	UPDATE [coworker]
	SET [inactive] = 0
	
	UPDATE [coworker]
	SET [inactive] = 1
	WHERE [idcoworker] IN
	(SELECT c.[idcoworker]
	FROM [coworker] c
	INNER JOIN [user] u ON u.[iduser] = c.[username]
	INNER JOIN [attributedata] ad ON ad.[idrecord] = u.[iduser] AND ad.[owner] = N'user' AND ad.[name] = N'active' AND ad.[value] = N'0')
	
	INSERT INTO [licenses]
	([number],[date],[createduser],[createdtime],[timestamp],[status])
	VALUES
	(@nbr,DATEADD(DAY,-1,@date),1,@date,@date,0)

	SELECT @idlicenses = SCOPE_IDENTITY()
	
	INSERT INTO [licenses_coworker]
	([coworker],[licenses],[timestamp],[type],[createdtime],[createduser], [status],[loggedin])
	SELECT
		c.[idcoworker],
		@idlicenses,
		@date,
		(SELECT s.[idstring] 
		FROM [string] s 
		JOIN [category] c ON c.[idcategory] = s.[idcategory] 
		WHERE s.[key] = CASE 
							WHEN u.[username] LIKE N'%llab%' THEN 'undebit'
							WHEN u.[username] LIKE N'%lundalogik%' THEN 'undebit'
							WHEN u.[username] LIKE N'%test%' THEN 'undebit'
							WHEN u.[username] LIKE N'%admin%' THEN 'undebit'
							WHEN u.[iduser] IN (SELECT ad.[idrecord]
												FROM dbo.[attributedata] ad
												WHERE ad.[owner] = N'user'
												AND ad.[name] = N'active'
												AND ad.[value] = N'0'
												) THEN 'undebit'
							ELSE 'debit'
						END
		),
		@date,
		1,
		0,
		CASE
			WHEN (
					SELECT COUNT(*)
						FROM [session] s
					WHERE
						(
							DATEADD(DAY,DATEDIFF(DAY,0,GETDATE()),-1) = DATEADD(DAY,DATEDIFF(DAY,0,[logintime]),0)
							OR DATEADD(DAY,DATEDIFF(DAY,0,GETDATE()),-1)  = DATEADD(DAY,DATEDIFF(DAY,0,[logouttime]),0)
						)
						AND s.[iduser] = u.[iduser]
				) > 0
			THEN
				1
			ELSE
				0
		END
	FROM [user] u
	INNER JOIN [coworker] c ON c.[username] = u.[iduser]
END	
