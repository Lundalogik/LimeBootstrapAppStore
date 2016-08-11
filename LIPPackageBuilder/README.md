# LIP Package Builder

LIP Package builder is a tool created to make building LIP packages easier.
Some of the features are: 

  - Easy GUI for selecting database objects (tables and fields)
  - Easy installation
  - Magic
  - High usability factor

Lastly save the entire package by clicking Generate Package.

##Installation:
1. Install by using lip.InstallFromZipFile and point out this zip file.
2. Move the file Install\packagebuilder.html to the main Actionpadfolder

Open the packagebuilder by calling the function LIPPackageBuilder.OpenPackageBuilder


# Wanted future features
These are some of the future features of LIP Package Builder

#### Attributes
- fieldselection (urvalskoppling)
- record access (postbehörighet)


#### Other
- Dependencies and modifying existing packages.

# What works then?
You can create a package with the following objects from a LIME Pro Application:
- Tables and fields
- VBA modules
- SQL functions and procedures


# How to use
1. Open the package builder by running the sub LIPPackageBuilder.OpenPackageBuilder in LIME VBA.
2. Select the objects that are to be included in the package. See the section Package Information for more information about the limitations in the packagebuilder
3. Make sure you have selected anything and given the package a name
4. When "Create Package" button is clicked the package will be built as a zip-file and a windows explorer will be opened with the selected save destination path.
5. You can proceed to install the package using LIP in another LIME database.


#Package information

The package follows the structure described in the LIP repository. 

### Limitations
- SQL Procedures and functions are exported to a subfolder in the package zip file and requires manual installment.
- Option queries are exported to textfiles named [table].[field].txt allowing users to manually add the option queries to their corresponding fields
- Table icons are exported to a subfolder 'tableicons' in the package zip file



