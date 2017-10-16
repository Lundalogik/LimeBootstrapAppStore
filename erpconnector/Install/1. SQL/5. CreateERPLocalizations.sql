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
	, N'ERPConnector' AS [owner]
	, N'e_toolong_zip' AS code
	, N'Error message when zipcode is too long' AS context
	, N'Postnummer måste vara mindre än 12 tecken' AS sv
	, N'Postal zipcode must be less than 12 characters' AS en_us
	, N'Postnummer må være under 12 tegn' AS [no]
	, N'Postnummeret skal være mindre end 12 tegn' AS da
	, N'Puhelinnumerossa on oltava alle 12 merkkiä' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'ERPConnector' AS [owner]
	, N'e_toolong_phoneno' AS code
	, N'Error message when phone number is too long' AS context
	, N'Telefonnummer måste vara mindre än 12 tecken' AS sv
	, N'Phone number must be less than 12 characters long to be added in Visma' AS en_us
	, N'Telefonnummeret må være under 12 tegn' AS [no]
	, N'Telefonnummeret skal være mindre end 12 tegn' AS da
	, N'Puhelinnumerossa on oltava alle 12 merkkiä' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'ERPConnector' AS [owner]
	, N'e_tooshort_company' AS code
	, N'Error message when compnay name is too short' AS context
	, N'Företagsnamn måste innehålla minst 3 tecken' AS sv
	, N'Company name must be at least 3 characters long' AS en_us
	, N'Fax må være under 12 tegn' AS [no]
	, N'Virksomhedsnavnet skal være mindst 3 tegn' AS da
	, N'Yrityksen nimessä on oltava vähintään 3 merkkiä' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'ERPConnector' AS [owner]
	, N'e_companyonly' AS code
	, N'Error message when no company' AS context
	, N'Enbart företag kan skickas' AS sv
	, N'For company only' AS en_us
	, N'Kun bedrifter kan sendes' AS [no]
	, N'Kun for virksomheden' AS da
	, N'Toimintoa voi käyttää vain yrityskortilta' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'ERPConnector' AS [owner]
	, N'SendToERP' AS code
	, N'Text in Actionpad when sending company to ERP' AS context
	, N'Skicka till ERP-system' AS sv
	, N'Send to ERP-system' AS en_us
	, N'Send til ERP-system' AS [no]
	, N'Send til ERP system' AS da
	, N'Lähetä ERP-järjestelmään' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'ERPConnector' AS [owner]
	, N'UpdateInERP' AS code
	, N'Text in Actionpad when sending company to ERP' AS context
	, N'Uppdatera i ERP-system' AS sv
	, N'Update in ERP-system' AS en_us
	, N'Oppdater i ERP-system' AS [no]
	, N'Opdater i ERP system' AS da
	, N'Päivitä ERP-järjestelmässä' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'ERPConnector' AS [owner]
	, N'invoiceHeader' AS code
	, N'Title in header for invoice graph' AS context
	, N'Fakturering' AS sv
	, N'Invoicing' AS en_us
	, N'Fakturering' AS [no]
	, N'Fakturering' AS da
	, N'Laskutus' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'ERPConnector' AS [owner]
	, N'invoiceSubHeader' AS code
	, N'Subtitle for invoice graph' AS context
	, N'Betalda fakturor mot kunden de senaste fem åren' AS sv
	, N'Payed invoices for the customer the last five years' AS en_us
	, N'Kunders betalte fakturaer de siste fem årene' AS [no]
	, N'Kundens betalte faktura de sidste 5 år' AS da
	, N'Asiakkaan maksetut laskut viimeiseltä viideltä vuodelta' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'ERPConnector' AS [owner]
	, N'months' AS code
	, N'Months in invoice graph' AS context
	, N'Månader' AS sv
	, N'Months' AS en_us
	, N'Måneder' AS [no]
	, N'Måneder' AS da
	, N'Kuukaudet' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'ERPConnector' AS [owner]
	, N'quarters' AS code
	, N'Quarters in invoice graph' AS context
	, N'Kvartal' AS sv
	, N'Quarters' AS en_us
	, N'Kvartal' AS [no]
	, N'Kvartal' AS da
	, N'Vuosineljännekset' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'ERPConnector' AS [owner]
	, N'noInvoices' AS code
	, N'Text showing in graph when there are no invoices' AS context
	, N'Inga fakturor finns registrerade på företaget!' AS sv
	, N'No invoices are registered on this company!' AS en_us
	, N'Det finnes ingen fakturaer på denne kunden!' AS [no]
	, N'Der findes ingen faktura på denne kunde!' AS da
	, N'Asiakkaalle ei ole merkitty laskuja!' AS fi
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'ERPConnector' AS [owner]
	, N'total' AS code
	, N'Text for total sum' AS context
	, N'Totalt' AS sv
	, N'Total' AS en_us
	, N'Total' AS [no]
	, N'Totalt' AS da
	, N'Yhteensä' AS fi