The 5 sql scripts contained in this folder will create the tables and columns needed for the VISMA Administration Add-On

Run in this order:

1. relationProcedures.sql
2. Create company fields.sql
3. Create Invoice table and fields.sql
4. Create invoicerow table and fields.sql
5. CreateVismaLocalizations.sql

You should now have all the tables and and fields in LIME! :)

---------- ERRORS --------------
If you get errors, these may be caused by the fields or tables existing from before. In that case, you will have to build the fields yourself because
we dont want to override old tables automatically.
