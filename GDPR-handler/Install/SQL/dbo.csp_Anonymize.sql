
GO
/****** Object:  StoredProcedure [dbo].[csp_Anonymize]    Script Date: 2017-05-10 13:46:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rasmus Alestig Thunborg (RTH)
-- Create date: 2017-02-22
-- Description:	A procedure to anonymize irrelevant customers and coworkers as according to the PUL-law. To be run monthly. 
-- =============================================
ALTER PROCEDURE [dbo].[csp_Anonymize]
	
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	SET NOCOUNT ON;

    BEGIN

		-- All the code, which has a red line under it, that revolves around contracts is one way to solve the logic of which customers to anonymize. 
		-- In this scenario, we do not select customer that have any active contracts on them or finished contracts that ended less than three months ago. 

		DECLARE @idcompany int
		DECLARE logCustomerCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR
		SELECT idcompany 
		FROM company
		LEFT JOIN contractcustomer ON idcompany = contractcustomer.company AND contractcustomer.[status] = 0
		LEFT JOIN [contract] ON idcontract = contractcustomer.[contract] AND [contract].[status] = 0
		WHERE idcompany NOT IN
		(select company.idcompany from company
		INNER JOIN contractcustomer ON idcompany = contractcustomer.company AND contractcustomer.[status] = 0
		INNER JOIN [contract] ON idcontract = contractcustomer.[contract] AND [contract].[status] = 0
		WHERE [contract].contractstatus <> 303901)
		AND company.[status] = 0
		AND [contract].lastdebitdate < DATEADD(month, -3, GETDATE())
		OR contractcustomer.idcontractcustomer IS NULL

		----------------------------------------------------------------------------------------------

	OPEN logCustomerCursor
		FETCH NEXT FROM logCustomerCursor INTO @idcompany
		WHILE @@FETCH_STATUS = 0
		BEGIN			

			INSERT INTO gdprlog ([status], createduser, [timestamp], updateduser, createdtime, [type], [datetime], responsible, company)
			VALUES(0, 1, GETDATE(), 1, GETDATE(), dbo.cfn_lc_getidstringbykey('gdprlog', 'type', 'monthly'), GETDATE(), 1001, @idcompany) --Change responsible to correct admin ID. 

		FETCH NEXT FROM logCustomerCursor INTO @idcompany
		END
		CLOSE logCustomerCursor
		DEALLOCATE logCustomerCursor
		
	END

	BEGIN

		UPDATE company 
		SET name = 'Anonymous-contact',
		phone = '',
		fullpostaladdress = '',
		postaladdress1 = '',
		postaladdress2 = '',
		postalzipcode = '',
		postalcity = '', 
		visitingzipcode = '',
		visitingcity = '',
		country = ''
		FROM company
		LEFT JOIN contractcustomer ON idcompany = contractcustomer.company AND contractcustomer.[status] = 0
		LEFT JOIN [contract] ON idcontract = contractcustomer.[contract] AND [contract].[status] = 0
		WHERE idcompany NOT IN
		(select company.idcompany from company
		INNER JOIN contractcustomer ON idcompany = contractcustomer.company AND contractcustomer.[status] = 0
		INNER JOIN [contract] ON idcontract = contractcustomer.[contract] AND [contract].[status] = 0
		WHERE [contract].contractstatus <> 303901)
		AND company.[status] = 0
		AND [contract].lastdebitdate < DATEADD(month, -3, GETDATE())
		OR contractcustomer.idcontractcustomer IS NULL

	END

	BEGIN

		DELETE p 
		from person p
		INNER JOIN company c ON c.idcompany = p.company
		where c.name = 'Anonymous-contact'

	END
	BEGIN 

		DELETE d
		from document d
		INNER JOIN company c ON c.idcompany = d.company
		where c.name = 'Anonymous-contact'

	END
	BEGIN  -- Add the four commented lines below and configure if only history notes that have a certain type should be emptied. 
	
		DELETE h
		from history h
		INNER JOIN company c ON c.idcompany = h.company
	--	INNER JOIN [string] s ON s.idstring = h.[type]
		where c.name = 'Anonymous-contact'
	--	AND ( s.[key] = 'customercomment' OR s.[key] = 'fromcustomer')

	END
	BEGIN 

		DELETE h 
		from history h
		INNER JOIN helpdesk d on d.idhelpdesk = h.helpdesk
		INNER JOIN company c on c.idcompany = d.company
	--	INNER JOIN [string] s ON s.idstring = h.[type]
		where c.name = 'Anonymous-contact'
	--	AND ( s.[key] = 'customercomment' OR s.[key] = 'fromcustomer')

	END
	BEGIN 

		UPDATE history 
		set company = ''
		from history h
		INNER JOIN company c ON c.idcompany = h.company
		WHERE c.name = 'Anonymous-contact'

	END
	BEGIN 

		UPDATE helpdesk
		set person = '',
		email = '',
		[description] = ''
		from helpdesk h
		INNER JOIN company c ON c.idcompany = h.company
		where c.name = 'Anonymous-contact'

	END

		BEGIN
		UPDATE coworker
		set name = 'Anonymous-employee', 
		firstname = 'Anonymous-',
		lastname = 'employee',
		phone = '',
		cellphone = '',
		email = '',
		office = '',
		username = ''
		WHERE inactive = 1
		AND name != 'Anonymous-employee'


		DECLARE @idcoworker int
		DECLARE logCoworkerCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR
		SELECT idcoworker 
		FROM coworker
		WHERE inactive = 1
		AND name != 'Anonymous-employee'		
		OPEN logCoworkerCursor
		FETCH NEXT FROM logCoworkerCursor INTO @idcoworker
		WHILE @@FETCH_STATUS = 0
		BEGIN			

			INSERT INTO gdprlog ([status], createduser, [timestamp], updateduser, createdtime, [type], [datetime], responsible, coworker)
			VALUES(0, 1, GETDATE(), 1, GETDATE(), dbo.cfn_lc_getidstringbykey('gdprlog', 'type', 'monthly'), GETDATE(), 1, @idcoworker)   --Change responsible to other ID if needed

		FETCH NEXT FROM logCoworkerCursor INTO @idcoworker
		END
		CLOSE logCoworkerCursor
		DEALLOCATE logCoworkerCursor

		END
END
