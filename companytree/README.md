#  Company Tree #

Companytree is an app for visualizing corporate structures in a tree overview.

## Features
### Company Actionpad and Main Explorer
The app can be used from the Company Actionpad and the Company tab of the main explorer. When used from the main explorer, a single company must be selected. In both cases, click the link in the actionpad in order to open an html dialog. The tree structure will be displayed in the new window. The tree has expandable child nodes and all node names can be clicked in order to open the corresponding company record.

### Configuration
Two things can be specified in the configuration of the application - type and whether or not to list contact persons on a company. The config should be left empty with the only exception for when specified in the file 'companytree.html'. In this file, the type has already been set to 'windowed', which should always be the chosen value. The parameter 'persons' can be set to '1' or '0' depending on if you want to see related contact persons or not.


## Installation

### Pre-requisites
The app requires a mother-daughter company relation structure where the relation field is called 'parentcompany'.

### Installation guide

Copy the folder "companytree" into the "apps" folder. Move the file "companytree.html" from the subfolder "HTML" to the root folder "Actionpads". Remember to specify the configuration parameter 'persons'.

Add the SQL procedure and SQL function from the SQL folder to the database.

Import the module CompanyTree.bas from the VBA folder into the Lime database.

Add the following code to the company actionpad or the index actionpad:
    
	<div data-app="{app: 'companytree', config:{}}"></div>
