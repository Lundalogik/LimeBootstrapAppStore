#  GDPR-handler #

CREATED BY: Rasmus Alestig Thunborg (RTH)

##INFO
GDPR (General Data Protection Regulation) is a regulation which regulates how information about people should be stored. This customization has been made to help Willhem follow these laws.

Core functionalities for this app includes:

* A button that allows a user to get a transcript of records for a selected customer, saved as a new history note.
* A button that allows a user to anonymize a selected customer or coworker.
* Possibility to create a job from a stored procedure that is run in on a specific date each month which will anonymize all the customer that have not had an active contract since three months back.

(The last functionality will require heavy configuration depending on how the customer's solution is built.)

##Installation

Disclaimer: This was developed on version 10.14. Should work with any solution that have the Bootstrap actionpads.

* Add app folder to the actionpads/apps folder and add the app instanciation to the index.html actionpad.
* Add the gdprlog, either by manually creating it using the pictures in the installation folder as a guide, or by using LIP with the GDPR_LOg_Package.zip.
* Add a new type for the history table called transcript, remember to give it the same key.
* Add the three SQL-procedures. Recommended: Run exec lsp_setdatabasetimestamp on the database afterward and restart the Lime Server component service (LDC).
* Add the VBA module, compile, run setup and save.
* Publish actionpads.
* Test test test and test. 
