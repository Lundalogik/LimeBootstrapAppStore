# Fulltextsearch 
This app allows you to search for text or words in documents stored in the documents tab in Lime CRM.

## Requirements
Supported file types depend on which iFilters that are installed in Windows and activated by the SQL server. As a default, SQL Server will activate every iFilter that is installed in Windows. This will normally include most common file types, such as doc, docx, msg, xls, xlxs, xml, txt and csv. This is what the add-on is sold to be able to do.

*Important:* pdf files are not supported.

New iFilters could be installed, but that requires that the SQL Server is 64-bit if Windows is 64-bit. To check which filters that are active on a SQL Server, the following command could be used:
```sql
EXEC sp_help_fulltext_system_components 'filter'
```

## Features
The search is conducted on full words only as default. If two or more words are typed separated with space, only documents containing all of the words are shown in the result list. There are ways to perform more advanced searches. For this, there are two helper buttons that will insert an operator in the search string. The purpose behind these are described below.

*OR*: If two words are separated by the OR operator, the search result will contain all documents that has at least one of the two words in them.
*BEGINS WITH*: This operator (*) can be used to search for only the beginning of a word, and accept all endings of it, when finding documents. For example, searching for "cust*" will return documents containing words such as "customer", "custom", "customs" etc.

## Installation
1. Create the SQL function cfn_addon_fulltextsearch_checkstring.
2. Create the SQL function cfn_addon_fulltextsearch_checktype.
3. Create the SQL function cfn_addon_fulltextsearch_editstring.
4. Create the SQL procedure csp_addon_fulltextsearch_finddocuments. If you get an error stating that:
```
Cannot use a CONTAINS or FREETEXT predicate on table or indexed view 'dbo.file' because it is not full-text indexed.
```
this means that a full-text search index must be created on the column ```dbo.file.data``` first. 
The full-text index is created by right clicking the table ```dbo.file``` and then 'Full-Text index' -> 'Define Full-Text Index'. This will start a wizard where you should follow the steps below (done in Management Studio 13.0 for a SQL 2008 database):
a. Choose 'pk__file__idfile' as a unique index. Click 'Next >'.
b. The next page in the wizard is for choosing which column to perform full-text searches in. Tick the box for 'data'. In the drop down in the column 'Type column', select 'fileextension'. Also specify your desired language in the column 'Language for Word Breaker'. Click 'Next >'.
c. Select Change Tracking. Let the option 'Automatically' be selected. Click 'Next >'.
d. Select Catalog, Index Filegroup and Stoplist. Tick the box 'Create a new catalog'. Enter the name 'addon_fulltextsearch'. Let it be Accent sensitive. Click 'Next >'.
e. Define Population Schedules (Optional). Skip this and just click 'Next >'.
f. Full-Text Indexing Wizard Description. Click 'Finish'.
g. When the wizard has completed its work, click 'Close'.

5. If you are running Lime CRM Server 12.x or later, please restart the LDC manually (right-click on it and click "Shut down").
6. Restart the Lime CRM desktop client.
7. Add the VBA module AO_Fulltextsearch and save the VBA project.
8. Add the "Fulltextsearch" folder to the Actionpads\apps folder.
9. In the main actionpad, where you want the app to be shown: Insert one of the two ways of showing the app found in app_instantiation.html.
10. Publish the actionpads.
11. Restart the Lime CRM desktop client and start using the add-on!
12. Add a customization record in Lundalogik's Lime CRM under the customer. Note the version installed (can be found in the app.json file).
