# Changelog for Lime CRM Sales Board

## v2.3.0
**Released:** 2018-04-18

**Authors:** Jonatan Tegen and Fredrik Eriksson

* Performance improvements.
* Restructured Javascript code.
* Restructured files according to add-on requirements.
* VBA is default data source instead of SQL.

## v2.2.1
**Released:** 2017-06-07

**Authors:** Fredrik Eriksson

* Bug fix: If the ignoreOptions object was removed from the config and VBA was used to fetch data, the app didn't start showing the previously ignored options.


## v2.2.0
**Released:** 2017-06-01

**Authors:** Fredrik Eriksson

* Added feature: Possibility to ignore certain options through the app config.


## v2.1.2
**Released:** 2017-02-01

**Authors:** Fredrik Eriksson

* Bug fix: Sorting of cards have been fixed.


## v2.1.1
**Released:** 2017-02-01

**Authors:** Fredrik Eriksson

#### Bug fixes
* Cards are now filtered again when using a filter in the Lime explorer.
* Using dynamic card icons does no longer result in an empty board when refreshing.


## v2.1.0
**Released:** 2017-01-26

**Authors:** Fredrik Eriksson

* Dynamic card icons. Now possible to have different card icons within the same lane.


## v2.0.1
**Released:** 2016-10-13

**Authors:** Fredrik Eriksson

* Fixed names of VBA module and SQL code in README. Removed spaces and also changed to lowercase for SQL procedures and functions.


## v2.0.0
**Released:** 2016-10-13

**Authors:** Fredrik Eriksson

* Added support for the hosting environment. Data can now be fetched using VBA instead of SQL (configurable).


## v1.3.0
**Released:** 2016-10-05

**Authors:** Fredrik Eriksson

* Changed name of app to LimeCRMSalesBoard.


## v1.2.2
**Released:** 2016-06-10

**Authors:** Fredrik Eriksson

* Added features: Support for date fields as additional info.


## v1.2.1
**Released:** 2016-03-17

**Authors:** Fredrik Eriksson

* Added features: Negative sum not shown if zero. Bugfix: Board title now fetched from localize table.


## v1.2.0
**Released:** 2016-03-11

**Authors:** Fredrik Eriksson

* Added features: SQL expressions on summation field, completion field and value field are now supported.


## v1.1.1
**Released:** 2016-03-10

**Authors:** Fredrik Eriksson

* Added features: Board size now follows the window size. PercentField can be omitted in app configuration.


## v1.1.0
**Released:** 2016-03-02

**Authors:** Fredrik Eriksson

* Added features include: inactive options not fetched from database, an option doesn't have to have a specified individualLaneSetting, possibility to set default values for lane settings.

## v1.0.0
**Released:** 2016-02-29

**Authors:** Fredrik Eriksson

* The first version that could be considered releaseable!

## v0.1.0
**Released:** 2015-12-18

**Authors:** Fredrik Eriksson

* An early version. A GUI redesign is looming.
