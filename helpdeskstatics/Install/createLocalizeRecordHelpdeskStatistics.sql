-- This script will insert records in the localize table
-- that is needed in the Helpdesk Statistics-app.

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
	, fi
	, da
)
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'HelpdeskStatics' AS [owner]
	, N'i_HelpdeskStatics_incomeheader' AS code
	, N'Returns Incomming' AS context
	, N'Inkomna' AS sv
	, N'Incoming' AS en_us
	, N'Inkommende' AS [no]
	, N'Saapuvat' AS fi
	, N'Indkommende' AS da
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'HelpdeskStatics' AS [owner]
	, N'i_HelpdeskStatics_open' AS code
	, N'Returns open' AS context
	, N'�ppna' AS sv
	, N'Open' AS en_us
	, N'�pne' AS [no]
	, N'Avaa' AS fi
	, N'�bne' AS da
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'HelpdeskStatics' AS [owner]
	, N'i_HelpdeskStatics_today' AS code
	, N'Returns today' AS context
	, N'Idag' AS sv
	, N'Today' AS en_us
	, N'I dag' AS [no]
	, N'T�n��n' AS fi
	, N'I dag' AS da
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'HelpdeskStatics' AS [owner]
	, N'i_HelpdeskStatics_activeheader' AS code
	, N'Returns active' AS context
	, N'Aktiva' AS sv
	, N'Active' AS en_us
	, N'Aktive' AS [no]
	, N'Aktiivinen' AS fi
	, N'Aktive' AS da		
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'HelpdeskStatics' AS [owner]
	, N'i_HelpdeskStatics_delayed' AS code
	, N'Returns delayed' AS context
	, N'F�rsenade' AS sv
	, N'Delayed' AS en_us
	, N'Forsinkede' AS [no]
	, N'My�h�ss�' AS fi
	, N'Forsinket' AS da
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'HelpdeskStatics' AS [owner]
	, N'i_HelpdeskStatics_all' AS code
	, N'All' AS context
	, N'Alla' AS sv
	, N'All' AS en_us
	, N'Alle' AS [no]
	, N'Kaikki' AS fi
	, N'Alle' AS da
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'HelpdeskStatics' AS [owner]
	, N'i_HelpdeskStatics_month' AS code
	, N'Returns Month' AS context
	, N'Denna m�nad' AS sv
	, N'This month' AS en_us
	, N'Denne m�neden' AS [no]
	, N'T�ss� kuussa' AS fi
	, N'Denna m�ned' AS da
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'HelpdeskStatics' AS [owner]
	, N'i_HelpdeskStatics_closedheader' AS code
	, N'Returns closed' AS context
	, N'St�ngda' AS sv
	, N'Closed' AS en_us
	, N'Stengt' AS [no]
	, N'Suljettu' AS fi
	, N'Afsluttet' AS da					
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'HelpdeskStatics' AS [owner]
	, N'i_HelpdeskStatics_notinitiated' AS code
	, N'Returns not initiated' AS context
	, N'Ej p�b�rjade' AS sv
	, N'Not initiated' AS en_us
	, N'Ikke startet p�' AS [no]
	, N'Ei aloitettu' AS fi
	, N'Ikke p�begyndt' AS da			
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'HelpdeskStatics' AS [owner]
	, N'i_HelpdeskStatics_mine' AS code
	, N'Mine' AS context
	, N'Mina' AS sv
	, N'Mine' AS en_us
	, N'Mina' AS [no]
	, N'Omat' AS fi
	, N'Mine' AS da
UNION ALL
SELECT 1 AS createduser
	, 1 AS updateduser
	, 0 AS [status]
	, N'HelpdeskStatics' AS [owner]
	, N'i_HelpdeskStatics_week' AS code
	, N'Returns week' AS context
	, N'Denna vecka' AS sv
	, N'This week' AS en_us
	, N'Denne uken' AS [no]
	, N'T�ll� viikolla' AS fi
	, N'Denne uge' AS da
