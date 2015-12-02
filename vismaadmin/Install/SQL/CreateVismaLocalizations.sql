-- This script will insert a record in the localize table
-- that is needed in the VISMA Administration module

INSERT INTO localize
(
	createduser
	, updateduser
	, [status]
	, [owner]
	, code
	, context
	, sv
	, en_us
	, [no]
	, da
	, fi
)
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'Actionpad_Company' AS [owner]
	, N'e_toolong_zip' AS code
	, N'Error message when zipcode is too long' AS context
	, N'Postnummer får max vara 12 tecken' AS sv
	, N'Postal zipcode must be less than 12 characters long to be added in Visma' AS en_us
	, N'Postnummer må være under 12 tegn' AS [no]
	, N'Postal zipcode must be less than 12 characters long to be added in Visma' AS da
	, N'Postal zipcode must be less than 12 characters long to be added in Visma' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'Actionpad_Company' AS [owner]
	, N'e_toolong_fax' AS code
	, N'Error message when fax number is too long' AS context
	, N'Fax får max vara 12 tecken' AS sv
	, N'Fax number must be less than 12 characters long to be added in Visma' AS en_us
	, N'Fax må være under 12 tegn' AS [no]
	, N'Fax number must be less than 12 characters long to be added in Visma' AS da
	, N'Fax number must be less than 12 characters long to be added in Visma' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'Actionpad_Company' AS [owner]
	, N'e_toolong_phoneno' AS code
	, N'Error message when phone number is too long' AS context
	, N'Telefonnummer får max vara 12 tecken' AS sv
	, N'Phone number must be less than 12 characters long to be added in Visma' AS en_us
	, N'Telefonnummeret må være under 12 tegn' AS [no]
	, N'Phone number must be less than 12 characters long to be added in Visma' AS da
	, N'Phone number must be less than 12 characters long to be added in Visma' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'Actionpad_Company' AS [owner]
	, N'e_tooshort_company' AS code
	, N'Error message when compnay name is too short' AS context
	, N'Företagsnamn måste innehålla minst 3 tecken' AS sv
	, N'Company name must be at least 3 characters long' AS en_us
	, N'Fax må være under 12 tegn' AS [no]
	, N'Company name must be at least 3 characters long' AS da
	, N'Company name must be at least 3 characters long' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'Actionpad_Company' AS [owner]
	, N'e_companyonly' AS code
	, N'Error message when no company' AS context
	, N'Enbart företag kan skickas' AS sv
	, N'For company only' AS en_us
	, N'Kun bedrifter kan sendes' AS [no]
	, N'For company only' AS da
	, N'For company only' AS fi