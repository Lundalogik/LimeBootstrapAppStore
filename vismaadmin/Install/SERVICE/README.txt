Installationsanvisning Visma Administration-integration (english below)

1. Skapa en mapp för installation (t.ex c:\VismaIntegration)
2. Skapa två undermappar, "bin" och "export"
3. Packa upp programfilerna till undermappen "bin"
4. Installera Pyton 3.4 som följer med i paketet
5. Skapa en virtuel miljö i mappen som du skapade i punkt 1 (kör cmd som administratör).
<<<<<<< HEAD
 * C:\VismaIntegration > c:\Python34\python.exe -m venv venv
=======
 * C:\VismaIntegration>c:\Python34\python.exe -m venv venv
>>>>>>> origin/master
6. Aktivera miljön
 * C:\VismaIntegration > venv\Scripts\activate.bat
7. Installera Lime Pro API klienten från PyPi
 * (venv) C:\VismaIntegration>pip install limeclient
(Mer information om installationen av Python och Import-api'et finns på http://docs.lundalogik.com/pro/integration/import/api)
8. Öppna VismaIntegrationService.exe.config och gör miljöinställningarna
 * VismaCommonPath = sökväg till Visma Gemensamma Filer-mappen (standardsökväg redan ifylld)
 * VismaDbPath = sökväg till Visma Företags-mappen (standardsökväg redan ifylld)
 * ExportInvoiceHeadFile = sökväg till exportfilen för fakturahuvuden (standardsökväg redan ifylld)
 * ExportInvoiceRowFile = sökväg till exportfilen för fakturarader (standardsökväg redan ifylld)
 * ExportCustomerFinancialInfoFile = sökväg till exportfilen för omsättningstal för kund (standardsökväg redan ifylld)
 * ExportCustomerFile = sökväg till exportfilen för kundmigrations-filen (standardsökväg redan ifylld)
 * PythonExecutable = sökväg till python.exe i den virtuella miljön som du satte upp i steg 5 (standardsökväg redan ifylld)
 * LimeApiUri = sökväg till LIME Pro servern (se bilder för exempel både för on-premise och hosting-sökväg)
 * LimeApiDb = namn på LIME Pro databas (skall vara tom om det är en hosting installation)
 * LimeApiUser = namn på den LIME Pro-användare som skall köra Python skriptet. Användaren skall ha skapats för installation av tjänsten
 * LimeApiPassword = lösenord för den LIME Pro-användare som kör python skriptet. Användaren skall ha skapats för installation av tjänsten
9. Installera VismaIntegrationService.exe som Windows-tjänst
 * start->run-> cmd.exe (högerklick, kör som Admin)
 * C:\windows\microsoft.net\framework\v4.0.30319 > installutil c:\VismaIntegration\bin\VismaIntegrationService.exe
10. Lägg till VismaIntegrationService.exe i Windows-brandvägg
 * Start->control panel->windows firewall->Allow an app or feature through Windows Firewall->Följ guiden. 
11. Starta tjänsten
 * Start->control panel->Administrative tools->Services->högerklick på VismaIntegrationService, "run".
12. Kontrollera i programmets logg-fil (C:\VismaIntegration\bin\logg) att tjänsten startat korrekt och kunde ansluta till Vismas API. 
13. Färdig

----------- ENGLISH -------------- 
1. Create a folder for intallation (preferably c:\VismaIntegration)
2. Create two subfolders, "bin" and "export"
3. Unzip the programfiles to the folder "bin"
4. Install Python 3.4 (included in the installation package)
5. Create a virtual environment in the folder you created in step 1
 * C:\VismaIntegration>c:\Python34\python.exe -m venv venv
6. Activate the environment
 * C:\VismaIntegration>venv\Scripts\activate.bat
7. Install the LIME Pro API client from PyPi
 * (venv) C:\VismaIntegration>pip install limeclient
(More information regarding the installation of Python and the Import-API is available at http://docs.lundalogik.com/pro/integration/import/api)
8. Open the config-file VismaIntegrationService.exe.config and make the environnmental configurations
 * VismaCommonPath = path to the Visma Gemensamma Filer-folder (default path already suggested)
 * VismaDbPath = path to the Visma Företags-folder (default path already suggested)
 * ExportInvoiceHeadFile = path to the exportfile for invoices (default path already suggested)
 * ExportInvoiceRowFile = path to the exportfile for invoicerows (default path already suggested)
 * ExportCustomerFinancialInfoFile =  path to the exportfile for turnover for customer (default path already suggested)
 * ExportCustomerFile =  path to the exportfile for customer migration (default path already suggested)
 * PythonExecutable = path to python.exe in the virtual environment that you cretaed in step 5 (default path already suggested)
 * InvoiceExportIntervalSeconds = how often the export of invoices from Visma should be done (default-value = 10)
 * LimeApiUri = path to the LIME Pro server used (see images for example for both on-premise as well as hosting paths)
 * LimeApiDb = name of the LIME Pro database connected (should be empty if hosting-installation)
 * LimeApiUser = name of the LIME Pro-user who runs the python script (as created prior to installing the service)
 * LimeApiPassword = password for the LIME Pro-user who runs the python script (as created prior to installing the service)
9. Install VismaIntegrationService.exe as a Windows-service
 * start->run-> cmd.exe (right click, run as administrator)
 * C:\windows\microsoft.net\framework\v4.0.30319>installutil c:\VismaIntegration\bin\VismaIntegrationService.exe
10. Add VismaIntegrationService.exe in Windows-firewall
 * Start->control panel->windows firewall->Allow an app or feature through Windows Firewall -> Follow the guide. 
11. Start the service
 * Start->control panel->Administrative tools->Services->right-click on VismaIntegrationService, "run".
12. Make sure that the program is running correctly and can connect to the Visma API by looking in the log-file (C:\VismaIntegration\bin\logg). 
13. Done