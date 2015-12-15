Installationsanvisning Visma Administration-integration

1. Skapa en mapp för installation (t.ex. c:\VismaIntegration)
2. Skapa två undermappar, "bin" och "export"
3. Packa upp programfilerna till undermappen "bin"
4. Ladda hem och installera Pyton 3.4 från https://www.python.org/downloads/
5. Skapa en virtuel miljö i mappen som du skapade i punkt 1. 
 * C:\VismaIntegration>c:\Python34\python.exe -m venv venv
6. Aktivera miljön
 * C:\VismaIntegration>venv\Scripts\activate.bat
7. Installera Lime Pro API klienten från PyPi
 * (venv) C:\VismaIntegration>pip install limeclient
(Mer information om installationen av Python och Import-api'et finns på http://docs.lundalogik.com/pro/integration/import/api)
8. Öppna VismaIntegrationService.exe.config och gör miljöinställningarna
 * sökväg till Visma Gemensamma Filer-mappen
 * sökväg till Visma Företags-mappen
 * sökväg till exportfilen för fakturahuvuden
 * sökväg till exportfilen för fakturarader
 * sökväg till python.exe i den virtuella miljön som du satte upp i steg 5
 * LimeApi-inställningar
9. Installera VismaIntegrationService.exe som Windows-tjänst
 * start->run-> cmd.exe (högerklick, kör som Admin)
 * C:\windows\microsoft.net\framework\v4.0.30319>installutil c:\VismaIntegration\bin\VismaIntegrationService.exe
10. Lägg till VismaIntegrationService.exe i Windows-brandvägg
 * Start->control panel->windows firewall->Allow an app or feature through Windows Firewall->Följ guiden. 
11. Starta tjänsten
 * Start->control panel->Administrative tools->Services->högerklick på VismaIntegrationService, "run".
12. Kontrollera i programmets logg-fil (C:\VismaIntegration\bin\logg) att tjänsten startat korrekt och kunde ansluta till Vismas API. 
13. Färdig