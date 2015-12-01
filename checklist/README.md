#Checklist
The checklist is a very simpel checklist. It can be used in any case you need someting to keep track of things that should be done.
You can eaither generate a checklist based on a template or let the user add their own tasks or even both!

#*WARNING JUST UPDATED! DOCS AND OLD VERSIONS ARE NOT WORKING!*

##Install
*	Add the "checklist" folder to the apps folder
*	Create a VBA module called "Checklist" and add the code from checklist
*	In the module checklist, find the section "Install" and run it (press F5)
*	Create an XML field called "checklist" on the inspectors you want to have a checklist on
*	Optional: If you want the ability to have pre-maid checklist, automagically loaded:
	*	Add tabel "Checklist" with fields...
		*	title
		*	order (integer field)
		*	mouseover
		*	origin
	*	Implement "Checklist.Initalize" method in the VBA

##Usage
The checklist has the following properties:
*	canBeUnchecked - True/False - If true the user can uncheck completed tasks
*	allowRemove - True/False - If true tasks can be removed
*	canAddTask - True/False - The user can add tasks. If you don't have pre-maid list, this option should be True

Usage example:

```html
<div data-app="{app:'checklist',config:{canBeUnchecked:true,allowRemove:true, canAddTask:true}}"></div>
```
