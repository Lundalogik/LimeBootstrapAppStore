
/*****************************************************************************
    This file contains customizable functions used by the MergeDoubles
    applications. You must NOT remove any functions declared in this file but
    you only need to actually implement those functions that your customization
    actually need.
    
    If a function returns a value a default value is specified in the comment
    preceeding its declaration. If you choose not to implement the function,
    make sure you return the default value.
 *****************************************************************************/
 
var MergeDoublesCustomizer = null;
 
(function() {
    if (MergeDoublesCustomizer == null)
        MergeDoublesCustomizer = new Object();
        
    
    /*
        This function should be implemented if you need to set one of the selected
        records as the target record. You return the id of that record and the
        user will not be able to select any other record as the target in the
        dialog.
            
        Parameters
            pApplication: A reference to the Lime application
        
        Returns
            long: The ID of the record all other records should be merged to
            
        Default return value
            0
            
        Comments
            Selected records are always pApplication.ActiveExplorer.Selection.
     */
    MergeDoublesCustomizer.getTargetRecordId = function (pApplication) {
        // Add your comment here to explain the purpose of your customization
        return 0;
    }
    
    /*
        Implement this function if you need to perfom any extended validation on the
        selected records.
        
        Parameters
            pApplication: A reference to the Lime application
        
        Returns
            bool: True on success, false on failure
        
        Default return value
            true
        
        Comments
            Selected records are always pApplication.ActiveExplorer.Selection.
            
            The call to this method is declared in the ini file of the application.
            The default value for the text id is 'NoMessage' simply meaning this
            validation has no message linked to it. You can choose to add a message
            in the language file and change the ini file but you will only be able
            to display one message regardless of the cause of the failure.
            Otherwise you need to display the reason on your own and if you need to
            support multiple languages you need to handle it on your own.
            
            If you show a message don't forget to set mousepointer to default first.
     */
     MergeDoublesCustomizer.validate = function (pApplication) {
        // Add your comment here to explain the purpose of your customization
        return true;
     }
}) ();