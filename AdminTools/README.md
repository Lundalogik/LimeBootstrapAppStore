#  AdminTools #

AdminTools is an application which supplies an overview of database and server information.

## Features

### Lime Usage
AdminTools adds a way of monitoring usage in lime over time:
- Number of unique logged in users.
- Number of transactions.
- Average transactiontimes.
- Number of infolog entries

All these can be plotted as a function over days or hours.

Users and transactions can be selected and their corresponding records can be opened.

### SQL Fields
All tables which contains SQL Fields (of any kind) are presented, ordered by number of SQL Fields. The tables can be expanded to show each individual field with the local name, database name and type.

### Index Info
The top 10 most fragmented indices are listed with the following information:
- Table name.
- Index name.
- Index fragmentation percentage.
- Table record count.
Additionally the app lists 10 potential new indices, ordered by estimated impact.

### Server Information
The app lists basic information about the server, including:
- SQL server version.
- Server physical memory.
- Server allocated memory.
- Server target memory.

### Database Information
Some fundamental information about Lime and its database is also listed:
- Database name
- LDC version
- Number of active users
- Database size
- Log size
- Database creation date
- Last backup date
- Last restore date
- VBA timestamp
- Actionpads last published date

### SQL Jobs
The last six SQL job steps with a name like '%Lime%' are listed with the following information:
- Job name
- Run datetime
- Run duration
- Status
- Enabled
- Execution message
Additionally, the user can execute single SQL jobs.

### SQL Programmability
Lists the ten most recently updated stored procedures and functions in the database with the following information:
- Name
- Last modified date
- Type
It is also possible to search in all custom made procedures and functions (csp:s and cfn:s) for any desired keyword.

##Installation

Copy the folder "AdminTools" into the "apps" folder. Move the file "admintools.html" from the subfolder "HTML" to the root folder "Actionpads". 

Add all the SQL procedures in the folder "SQL" to the Lime database.

Insert the VBA module "AdminTools.bas" to the Lime VBA. Add the following code to Application.Setup:

    If ActiveUser.Administrator Then
        If Application.Panes.Exists("AdminTools") = False Then
            Call Application.Panes.Add("AdminTools", WebFolder & "apps\AdminTools\gearwheels.ico", "", lkPaneStyleNoToolBar)
        End If
        Application.Panes("AdminTools").url = WebFolder & "lbs.html?ap=admintools&type=tab"
        Application.Panes.Visible = True
        If Not Application.Panes.ActivePane Is Application.Panes.Item("AdminTools") Then
            Set Application.Panes.ActivePane = Application.Panes.Item("AdminTools")
        End If
    End If