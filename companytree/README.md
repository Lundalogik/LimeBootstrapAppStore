#  companytree #

Companytree is an app for visualizing corporate structures in a tree overview.

## Features
### Company Actionpad and Main Explorer
The app can be used from the Company Actionpad and the Company tab of the main explorer. When used from the main explorer, a single company must be selected. In both cases, click the link in the actionpad in order to open an html dialog. The tree structure will be displayed in the new window. The tree has expandable child nodes and all company names can be clicked in order to open the corresponding company record.

### Pre-requisites
The app requires a mother-daughter company relation structure where the relation field is called 'mothercompany'.


##Installation

Copy the folder "companytree" into the "apps" folder. Move the file "companytree.html" from the subfolder "HTML" to the root folder "Actionpads". 

Add the SQL procedure and SQL function from the SQL folder to the database.

Import the module CompanyTree.bas from the VBA folder into the Lime database.

Add the following code to the company actionpad or the index actionpad:
    
	<div data-app="{app: 'companytree', config:{type: 'list'}}"></div>

CREATED BY: JKA