# ActionPad Editor

## What?
Used to edit actionpads, will load ActionPad view (.html) with the same name as ActiveInspector. Supports live editing (more or less) of view.

## Todo
Change ``js/appstore.js`` to load data from Appstore instead of using hardcoded values

### Start

Example launching from ``LBSHelper``

```
Public Function DisplayEditor()
    Dim dialog As Lime.dialog
    Set dialog = New Lime.dialog
    dialog.Property("height") = 1000
    dialog.Property("width") = 1400
    dialog.Property("url") = WebFolder & "lbs.html?ap=designer&type=tab"
    Call dialog.show(lkDialogHTML)
End Function
```