insert into localize ([status], createduser, updateduser, [timestamp], createdtime, 
[owner], code, 
sv, [no], en_us, 
context, lookupcode)
VALUES (0, 1, 1, GETDATE(), GETDATE(), 
'app_businessoverview', 'lasthistorie', 
'dag sedan sista kontakten', 'dag siden sist kontakt', 'day since last contact', 
'Translation for the app "business overview"', 'Localize.GetText("app_BusinessOverview", "lasthistorie")'),

(0, 1, 1, GETDATE(), GETDATE(), 
'app_businessoverview', 'lasthistories',
'dager sedan sista kontakten', 'dager siden sist kontakt', 'days sinse last contact',
'Translation for the app "business overview"', 'Localize.GetText("app_BusinessOverview", "lasthistories")'),

(0, 1, 1, GETDATE(), GETDATE(), 
'app_businessoverview', 'nohist',
'Ingen historik att hämta från', 'Ingen historie å hente fra', 'No history on this customer',
'Translation for the app "business overview"', 'Localize.GetText("app_BusinessOverview", "nohist")'),

(0, 1, 1, GETDATE(), GETDATE(), 
'app_businessoverview', 'salesopp',
'Försäljning möj.', 'Salgs mulig.', 'Sales opp.',
'Translation for the app "business overview"', 'Localize.GetText("app_BusinessOverview", "salesop")'),

(0, 1, 1, GETDATE(), GETDATE(), 
'app_businessoverview', 'saleswon',
'Svensk?', 'Totalt solgt', 'Total won',
'Translation for the app "business overview"', 'Localize.GetText("app_BusinessOverview", "saleswon")'),

(0, 1, 1, GETDATE(), GETDATE(), 
'app_businessoverview', 'activesos',
'Aktive SOS!', 'Aktive SOS!', 'Active SOS!',
'Translation for the app "business overview"', 'Localize.GetText("app_BusinessOverview", "activesos")'),

(0, 1, 1, GETDATE(), GETDATE(), 
'app_businessoverview', 'noactivesos',
'Aktive SOS :D', 'Aktive SOS :D', 'Active SOS :D',
'Translation for the app "business overview"', 'Localize.GetText("app_BusinessOverview", "noactivesos")'),

(0, 1, 1, GETDATE(), GETDATE(), 
'app_businessoverview', 'totalactivesos',
'Totalt', 'Total', 'In Total',
'Translation for the app "business overview"', 'Localize.GetText("app_BusinessOverview", "totalactivesos")')

--select * from localize order by createdtime desc

--delete from localize where [owner] = 'app_businessoverview'