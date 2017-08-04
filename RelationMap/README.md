#Relation Map 
##Overview and details all in one place
Get a good overview of your hierarchical data, and pop up the details for any record that looks interesting or suspicious.
##Description
Relation Map is an app that is meant to give you a good overview over relatively large data sets of hierarchical data. It works for any record type that has a relation field of its own type. This means that the records can have a parent record of its own type, and anywhere from 0 -> n number of children of its own type, creating a hierarchical relationship structure among the records, with at least one top node in the tree. Two examples of this are corporate groups, with parent and subsidiary companies, and the reporting structure within a company, with coworkers reporting to one other coworker and having possibly many coworkers reporting to them.

Every node in the hiererachy is represented with a circle and a short text string. In the examples from above, good choices for texts would be the name of the company and the name of the coworker.

If the node has child nodes (daughter companies or coworkers reporting to them), they can also have a descriptive text, for example the name of the coworker group they are responsible for.

By hovering the mouse pointer over a node's text, you can get a tooltip popup, with more information about that record. What information that is shown in this tooltip is configured when you set up the app, and can be information directly from that record, but also from related records. Only the data in the database sets the limit! But don't overdo it, this is meant for a quick overview. Too much information will clutter, and hide the most important data, and it could slow down the loading time of the app.

##Configuration
Configuration wise, quite a bit is possible. The biggest one is of course that you're able to choose which record type it should map against (company, coworker etc.), but it is also possible to have more than one instance if the app in the same solution. This means that you can have one link in the actionpad that opens up a map of the corporate structure, and another link that opens up a map of the coworker structure.

One parameter that can change the look and use case of the app quite a bit, is how "deep" into the tree you want to be able to see. The default depth is 2 steps, and what that means is that when you have the CEO or the main holding company at the center of the tree, then you can see that companies/coworker's children and their children, but their "grand children's" children will be hidden, and all you can see is which of the "grand children" have children at all. Because of the fact that the entire structure is not always visible, it is possible to navigate the tree. By clicking on a node you make it the center node, and you can see 2 steps down from THAT node. By clicking the center node you can always navigate one step up, to that node's parent (parent company or the coworker they report to). It's also possible to navigate any number of steps up in the structure, using the breadcrumb at the top of the window.
By making the depth you can see bigger, you get more of an overview, but it also easily gets pretty cluttered, and if you don't have a very big screen, the resolution is rather low.

By having a record selected in the list when you start the app, you can create the tree based on that record. For the app to open without a record selected, a default record must be specified, which will then be opened if a selected record of the correct type is not found.

When you navigate the tree, by either clicking a node or in the breadcrumb, there are some very beautiful animations, guiding you through the transition of the map. These can be switched off if you want the graphics to be a little more snappy.

Colors are fully custumizable. The default colors are based on lime and magenta, but all text and graphics can be set to any color.

The app opens up in a separate HTML dialog. Its size is adapted to the size of the screen, to be able to present the data with as high resolution as possible.

##Installation
1. Copy the RelationMap folders to the .../Actionpads/apps folder, and move folder RelationMapHelper one step up, from .../apps/RelationMap to .../apps.
2. Import the RelationMap VBA file to the project. Implement/adapt a "GetJson" function, a "GenerateJson" function, a "GetView" function case, and a "GetParentFieldName" function case, that fits your database models and the data you want the app to display. Also add the constants that the functions will use at the top of the file. If you want your app to be based on coworkers or companies, then there are template functions that could potentially work out of the box, or with minimal modification. If it should be based on a different record type, then those templates should still get you pretty far. 
3. Add instansiation of RelationMapHelper in the index actionpad. Can be found under .../Actionpads/apps/RelationMapHelper/Install/app_instansiation.html.
4. Add a link in the actionpad to instansiate RelationMap, and a localization post if you need the link to display in more than one language. A template instansiation can be found under .../Actionpads/apps/RelationMap/Install/app_instansiation.html.
5. Modify relationMap.html with the settings you want. When first installed, they are set to the same values as the default values.
6. In case you want more than one version of the app (for example one for companies and one for coworkers), then you need to implement additional "GetJson" and "GenerateJson" functions, "GetView" and "GetParentFieldName" function cases, create additional relationMap.html files and give them different names, as well as create more than one actionpad link to instansiate the app.