#LIME Bootstrap AppStore

This repo contains all apps available for LIME Bootstrap. The appstore itself can be found [here](http://limebootstrap.lundalogik.com/web/appstore/index.html)

##Building apps
Check out the [manual page](http://limebootstrap.lundalogik.com/web/manual/buildingApps/)

##Committing an app
Any app committed, containing a valid `app.json`-file will automatically be added to the AppStore. As soon as you visit the AppStore, a complete rebuild will be trigged, and your app should show up. The purpose of the `app.json`-file is to provide information about the app, versioning and installation.

A commit is done by pushing a new folder, containing an app, to this repo. If you are a member of the Lundalogik organisation you can simply push it to master. Otherwise use a pull request.

__WARNING:__ Committing an invalid `app.json` may cause the appstore to crash. Take an extra look before committing. If something goes bad, just fix your json and the appstore should recover all by itself.

__NOTE:__ The `app.json` powers the versioning system of the app. When you raise a version number an automatic message will be shown to all users of the app, with debug enabled, asking them to update.

Any pictures (.jpg, .jpeg, .png) in the app's root folder will automatically be used as cover pictures for the app. If you don't want these pictures to be distributed when someone downloads your app, just append an undersore `_` to the filename and it will be ignored. `_example.png`

The information about the app in the appstore is pulled from the `README.md`-file in the app's root folder

##App.json
The `app.json` should be formated as:

```JSON
{
	"name": "[NAME OF APP]",
	"author":"[AUTHORS NAME]",
	"status":"[STATUS OF THE APP, CAN BE: 'release', 'beta' OR 'Development']",
	"shortDesc":"[A short text to describe the app]",
	"versions":[
			{
			"version":"1",
			"date":"2014-02-06",
			"comments":"Css improvements!"
		},
		{
			"version":"0.9",
			"date":"2013-11-18",
			"comments":"The first stable beta of the Business Funnel"
		}
	],
	"install":{

	}
}

````

- Name: Name of the app. Call it something short but descriptive
- Autor: Just to know who to blame
- Status: Shows a badge in the appstore, displaying status.
	*Development*: not ready to be used, *Beta*: At your own risk, *Release*: Should work
- Short Description: A short text to explain what the app is used for
- Versions: an array containing different versions
  - version: An unsigned double (positive decimal)
  - date: Date of the update
  - comments: What does the update do?
- Install: Not yet implemented, but the idea is that the apps should install themselves. This section will provide the instructions.
