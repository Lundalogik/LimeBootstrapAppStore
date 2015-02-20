News Carousel
=========

Your own info channel within LIME Pro.


Info
----

This app shows a carousel of brief information for the LIME users. The app can, for example, be used to:

* Inform that LIME Pro will be upgraded on Friday between 1pm and 4pm.
* Give LIME Pro tip-and-trick of the week.
* Remind everyone of Friday's After Work.

It's an easy and visual way to communicate LIME Pro related things within LIME Pro.


Installation
-----------

1. Copy the “newscarousel” folder to the “apps” folder.
1. Run the attached SQL-script in order to create the necessary procedure, table, and fields.
1. Restart LIME Pro if open.
1. Add the following HTML to the Index ActionPad and add configuration:

```html
<div data-app="{ app: 'newscarousel' }"></div>
```

Setup
---
The app should not need any further setup. Go to the News tab in LIME Pro and add your first news!

Technical info
---
The news texts can be formatted using [Markdown](http://daringfireball.net/projects/markdown/syntax).
News are loaded into the app on startup, so you need to restart the client in order to see changes made.
