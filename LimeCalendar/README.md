#  LimeCalendar #
Lime Calendar adds a simple calendar functionality to Lime. Through the calendar it is possible to track multiple Lime objects as long as they have at least a start date.

### Requires a license
For more information please contact Lundalogik AB.

### Filter your hits
With Lime Calendar it is also possible to filter your hits by the following:

* 'Selection' - See only tasks selected in the active explorer.
* 'Mine' - See only tasks where you are responsible.
* 'All' - See everyone's tasks.
* 'Coworker' - See a specifik coworker's tasks.
* 'Group' - Filter by an object related to the coworkers in Lime - e.g. Office.
* 'Status filter' - Table specific filter based on an option field.

### Installation
Lime Calendar is a LIP package, meaning you can install it with the single VBA-command `Call LIP.Install("LimeCalendar")`. This will install everything needed with the assumption that the database is based on a Lime Core database version 5.3 or newer. If this is not the case, some configuration of the Lime objects might be needed (see below).

In order to open the calendar, add an `<li>`-tag to a list as follows:
```
<li data-bind="vba: 'LimeCalendar.OpenCalendar, modal', icon: 'fa-calendar', text: localize.LimeCalendar.openCalendar" />
```
or
```
<li data-bind="vba: 'LimeCalendar.OpenCalendar, overview', icon: 'fa-calendar', text: localize.LimeCalendar.openCalendarOverview" />
```
The difference here is where it is opened: as a modal window, or in the Lime CRM overview tab.

### Configuration
Lime Calendar can be configured to work with any Lime object with the minimum requirement of a start date and a relation to a coworker. An example of a configuration can be seen below. Note that this is also the default configuration which will be loaded if you do not specifically ask Lime Calendar to load anything different.
```
<div data-app="{app:'LimeCalendar',config:{
    view: 'overview',
    tables: [
        {
            table: 'todo',
            fields: 'subject;starttime;endtime;coworker;person;note;done',
            view: 'coworker;person;note;done',
            viewLocalizations: 'todoCoworker;todoPerson;todoNote;todoDone',
            title: 'subject',
            start: 'starttime',
            end: 'endtime',
            options: {
                statusFilter: 'subject',
                initialField: 'coworker',
                dateformat: 'YYYY-MM-DD HH:mm',
                color: '#fff',
                backgroundColor: '#EF6407',
                borderColor: '#EF6407'
            }
        },
        {
            table: 'campaign',
            fields: 'name;startdate;enddate;coworker;campaignstatus;purpose',
            view: 'coworker;campaignstatus;purpose',
            viewLocalizations: 'todoCoworker;campaignStatus;campaignPurpose',
            title: 'name',
            start: 'startdate',
            end: 'enddate',
            options: {
                statusFilter: 'campaignstatus',
                initialField: 'coworker',
                dateformat: 'YYYY-MM-DD',
                color: '#fff',
                backgroundColor: '#00BEFF',
                borderColor: '#00BEFF'
            }
        }
    }}" />
```
A table object in the configuration can, and should hold the following information:
* table: Database name of the Lime table.
* fields: A semi colon-separated list of all fields to extract from the database.
* view: A semi colon-separated list of all fields which should be shown in the information view in the calendar. Note that all these must also be contained in the field attribute above.
* viewLocalizations: A semi colon-separated list of all localization codes added under the LimeCalender owner. These should match the view-list field by field.
* title: Field in the field-attribute above which should be used as a title field.
* start: Field in the field-attribute above which should be used as the start time.
* end: Field in the field-attribute above which should be used as the end time.
* options:
 * statusFilter [optional]: Field in the field-attribute above with which the user should be able to filter the result. This must be an option field or a text field with categories.
 * initialField: Field in the field-attribute above which is used to extract initials for the responsible coworker.
 * dateformat: Specifies the date format to be used.
 * color: Text color used for the tasks in the calendar.
 * backgroundColor: Background color used for the tasks in the calendar.
 * borderColor: Border color used for the tasks in the calendar. Preferably the same as the background color.

### Important note
By default no tasks older than two months will be loaded. This can be changed by altering the VBA constant ` NBR_OF_MONTHS ` in the module LimeCalendar.
