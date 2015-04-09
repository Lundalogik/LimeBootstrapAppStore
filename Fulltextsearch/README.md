# Fulltextsearch 
This app allows you to search for text/words in documents. 
Supported file types depend on which iFilters are installed on the SQL server. Common file types are doc, docx, msg, xls, xlxs, xml, txt and csv. New iFilters could always be installed (to be able to install an iFilter the
SQL Server has to be 64-bit if the OS on the PC is 64-bit).
Importent to know is that this search function does NOT support pdf-files. 


##Install
*	Add the "Fulltextsearch" folder to the apps folder.
*	Create a VBA module called "Fulltextsearch" and add the code from Fulltextsearch (Install-folder)
*	Create a SQL procedure called csp_finddocuments and add code from csp_finddocuments.
*	Create a SQL function called cfn_checkString and add code from cfn_checkString.
*	Create a SQL function called cfn_checkType and add code from cfn_checkType.
*	Create a SQL function called cfn_editString and add code from cdn_editString
*	Insert following html tag in the actionpad where you want it to be shown. 
	```html
		<div data-app="{app:'Fulltextsearch',config:{}}"></div>
	```

*	In SQL Management Studio you must enable Fulltextsearch on the file-table if its not already enabled.


