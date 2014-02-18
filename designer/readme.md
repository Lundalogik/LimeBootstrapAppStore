### ActionPad Editor

launch from LBSHelper using this function

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