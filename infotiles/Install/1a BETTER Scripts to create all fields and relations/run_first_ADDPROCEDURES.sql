
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[csp_infotiles_scriptfield_addtable]
    @@tablename NVARCHAR(64) ,
    @@localname_singular NVARCHAR(MAX) ,
    @@localname_plural NVARCHAR(MAX) ,
    @@failexistingtable INT = 1 ,
    @@messagetext NVARCHAR(512) = N'' OUTPUT ,
    @@idtable INT = NULL OUTPUT ,
    @@iddescriptiveexpression INT = NULL OUTPUT
AS
    BEGIN

	
        DECLARE @return_value INT
        DECLARE @idstringlocalname INT
        DECLARE @idstring INT
        
        DECLARE @sql NVARCHAR(300)
        DECLARE @currentPosition INT
        DECLARE @nextOccurance INT
        DECLARE @currentString NVARCHAR(256)
        DECLARE @currentLanguage NVARCHAR(8)
        DECLARE @currentLocalize NVARCHAR(256)
        DECLARE @isFirstLocalize BIT
        DECLARE @count INT
	
        SET @return_value = 0 -- DEFAULT OK
        SET @idstringlocalname = NULL
        SET @idstring = NULL
        SET @@idtable = NULL
        
        SET @@iddescriptiveexpression = NULL
        SET @sql = N''
        SET @isFirstLocalize = 1
        SET @@messagetext = N''
	
        BEGIN TRY

	--Check if table already exists
            EXEC lsp_gettable @@name = @@tablename, @@count = @count OUTPUT
	
            IF @count > 0 --Tablename already exists
                BEGIN
                    SET @@idtable = -1
                    SET @@iddescriptiveexpression = -1
                    SET @@messagetext = N'Table ' + QUOTENAME(@@tablename)
                        + N' already exists.'
                    IF @@failexistingtable = 1
                        SET @return_value = -1
                END
            ELSE
                BEGIN
                    EXEC @return_value = [dbo].[lsp_addtable] @@name = @@tablename,
                        @@idtable = @@idtable OUTPUT,
                        @@localname = @idstringlocalname OUTPUT,
                        @@descriptive = @@iddescriptiveexpression OUTPUT,
                        @@user = 1
			

		--If return value is not 0, something went wrong and the table wasn't created
                    IF @return_value <> 0
                        BEGIN
                            SET @@idtable = -1
                            SET @@iddescriptiveexpression = -1
                            SET @@messagetext = N'Table '
                                + QUOTENAME(@@tablename)
                                + N' couldn''t be created'
                        END
                    ELSE
                        BEGIN

			--Set localnames singular
                            IF CHARINDEX(':', @@localname_singular, 0) > 0
                                BEGIN
				--Make sure @@localname_singular ends with ; in order to avoid infinite loop
                                    IF RIGHT(@@localname_singular, 1) <> N';'
                                        BEGIN
                                            SET @@localname_singular = @@localname_singular
                                                + N';'
                                        END
			
				--Make sure @@localname dont start with ;
                                    WHILE LEFT(@@localname_singular, 1) = N';'
                                        BEGIN
                                            SET @@localname_singular = SUBSTRING(@@localname_singular,
                                                              2,
                                                              LEN(@@localname_singular))
                                        END

                                    SET @currentPosition = 0
				--Loop through localnames
                                    WHILE @currentPosition <= LEN(@@localname_singular)
                                        AND @return_value = 0
                                        BEGIN
                                            SET @nextOccurance = CHARINDEX(';',
                                                              @@localname_singular,
                                                              @currentPosition)
                                            IF @nextOccurance <> 0
                                                BEGIN
                                                    SET @sql = N''
                                                    SET @currentString = SUBSTRING(@@localname_singular,
                                                              @currentPosition,
                                                              @nextOccurance
                                                              - @currentPosition)
                                                    SET @currentLanguage = SUBSTRING(@currentString,
                                                              0,
                                                              CHARINDEX(':',
                                                              @currentString))
                                                    SET @currentLocalize = SUBSTRING(@currentString,
                                                              CHARINDEX(':',
                                                              @currentString)
                                                              + 1,
                                                              LEN(@currentString)
                                                              - CHARINDEX(':',
                                                              @currentString))
					
						--Set local names for field
                                                    SET @sql = N'UPDATE [string] 
						SET [' + @currentLanguage + N'] = '''
                                                        + @currentLocalize
                                                        + N''''
                                                        + N' WHERE [idstring] = '
                                                        + CONVERT(NVARCHAR(12), @idstringlocalname)
                                                    EXEC sp_executesql @sql
					
                                                    SET @currentPosition = @nextOccurance
                                                        + 1
                                                END
                                        END
                                END	
			--End localnames singular
			
			--Set localnames plural
                            IF CHARINDEX(':', @@localname_plural, 0) > 0
                                BEGIN
				--Make sure @@localname_plural ends with ; in order to avoid infinite loop
                                    SET @currentPosition = 0
                                    IF RIGHT(@@localname_plural, 1) <> N';'
                                        BEGIN
                                            SET @@localname_plural = @@localname_plural
                                                + N';'
                                        END
				
				--Make sure @@localname dont start with ;
                                    WHILE LEFT(@@localname_plural, 1) = N';'
                                        BEGIN
                                            SET @@localname_plural = SUBSTRING(@@localname_plural,
                                                              2,
                                                              LEN(@@localname_plural))
                                        END

                                    SET @currentPosition = 0
				--Loop through localnames
                                    WHILE @currentPosition <= LEN(@@localname_plural)
                                        AND @return_value = 0
                                        BEGIN
                                            SET @nextOccurance = CHARINDEX(';',
                                                              @@localname_plural,
                                                              @currentPosition)
                                            IF @nextOccurance <> 0
                                                BEGIN
                                                    SET @currentString = SUBSTRING(@@localname_plural,
                                                              @currentPosition,
                                                              @nextOccurance
                                                              - @currentPosition)
                                                    SET @currentLanguage = SUBSTRING(@currentString,
                                                              0,
                                                              CHARINDEX(':',
                                                              @currentString))
                                                    SET @currentLocalize = SUBSTRING(@currentString,
                                                              CHARINDEX(':',
                                                              @currentString)
                                                              + 1,
                                                              LEN(@currentString)
                                                              - CHARINDEX(':',
                                                              @currentString))
					
                                                    IF @isFirstLocalize = 1
                                                        BEGIN
                                                            EXEC @return_value = [dbo].[lsp_addstring] @@idcategory = 17,
                                                              @@string = @currentLocalize,
                                                              @@lang = @currentLanguage,
                                                              @@idstring = @idstring OUTPUT
                                                            SET @isFirstLocalize = 0
                                                        END
                                                    ELSE
                                                        BEGIN
                                                            EXEC @return_value = dbo.lsp_setstring @@idstring = @idstring,
                                                              @@lang = @currentLanguage,
                                                              @@string = @currentLocalize
                                                        END
					
                                                    SET @currentPosition = @nextOccurance
                                                        + 1
                                                END
                                        END
                                END	

                            EXEC @return_value = lsp_addattributedata @@owner = N'table',
                                @@idrecord = @@idtable, @@idrecord2 = NULL,
                                @@name = N'localnameplural',
                                @@value = @idstring
			--End localnames plural
			
			
			--If return value is not 0, something went wrong while setting table attributes
                            IF @return_value <> 0
                                BEGIN
                                    SET @@messagetext = N'Something went wrong while setting localnames for table '
                                        + QUOTENAME(@@tablename)
                                        + N'. Please check that table properties are correct.'
                                END
                            IF @return_value = 0
                                BEGIN
                                    SET @@messagetext = N'ADDED TABLE '
                                        + QUOTENAME(@@tablename)
                                END
                        END
                END

				

        END TRY
        BEGIN CATCH
            SET @return_value = -99
            SET @@messagetext = LEFT(ERROR_MESSAGE(), 512)
        END CATCH

        RETURN @return_value
    END


	GO

	CREATE PROCEDURE [dbo].[csp_infotiles_scriptfield_addfield]
    @@tablename NVARCHAR(64) ,
    @@fieldname NVARCHAR(64) ,
    @@type NVARCHAR(64) ,
    @@localname NVARCHAR(MAX) -- N'lang:text;lang2:text2'
    ,
    @@separator NVARCHAR(MAX) = N'' -- N'lang:text;lang2:text2'
    ,
    @@defaultvalue NVARCHAR(64) = NULL ,
    @@limedefaultvalue NVARCHAR(64) = NULL ,
    @@limereadonly INT = 0 ,
    @@invisible INT = 0 ,
    @@required INT = NULL ,
    @@width INT = NULL ,
    @@height INT = NULL ,
    @@length INT = NULL ,
    @@isnullable INT = 0 ,
    @@idcategoryshared NVARCHAR(32) = NULL ,
    @@failexistingfield INT = 1 ,
    @@messagetext NVARCHAR(512) = N'' OUTPUT ,
    @@idfield INT = NULL OUTPUT,
	@@addCategory INT = 0
AS
    BEGIN



        DECLARE @return_value INT
        DECLARE @idstringlocalname INT
        DECLARE @idcategory INT
        DECLARE @idstring INT
        DECLARE @idfieldtype INT
        DECLARE @count INT
        DECLARE @sql NVARCHAR(300)
        DECLARE @currentPosition INT
        DECLARE @nextOccurance INT
        DECLARE @currentString NVARCHAR(256)
        DECLARE @currentLanguage NVARCHAR(8)
        DECLARE @currentLocalize NVARCHAR(256)

        SET @return_value = 0 -- DEFAULT OK
        SET @@idfield = NULL
        SET @idstringlocalname = NULL
        SET @idcategory = NULL
        SET @idstring = NULL
        SET @@messagetext = N''
        SET @sql = N''
	
        BEGIN TRY

		--Check if field already exists
            EXEC lsp_getfield @@table = @@tablename, @@name = @@fieldname,
                @@count = @count OUTPUT
	
            IF @count > 0 --Fieldname already exists
                BEGIN
                    SET @@messagetext = N'Field ' + QUOTENAME(@@tablename)
                        + N'.' + QUOTENAME(@@fieldname) + N' already exists.'
                    IF @@failexistingfield = 1
                        SET @return_value = -1
                END
            ELSE --Field doesn't exist
                BEGIN
			--Check if fieldtype exists
                    IF ( SELECT COUNT(*)
                         FROM   fieldtype
                         WHERE  name = @@type
                                AND active = 1
                                AND creatable = 1
                       ) <> 1
                        BEGIN
                            SET @@messagetext = N'''' + @@type
                                + N''' is not a valid fieldtype. Field '
                                + QUOTENAME(@@tablename) + N'.'
                                + QUOTENAME(@@fieldname)
                                + ' couldn''t be created'
                            SET @return_value = -2
                        END
                    ELSE
                        BEGIN
				-- Get field type
                            SELECT  @idfieldtype = idfieldtype
                            FROM    fieldtype
                            WHERE   name = @@type
                                    AND active = 1
                                    AND creatable = 1

                            EXEC @return_value = [dbo].[lsp_addfield] @@table = @@tablename,
                                @@name = @@fieldname,
                                @@fieldtype = @idfieldtype,
                                @@length = @@length,
                                @@isnullable = @@isnullable,
                                @@defaultvalue = @@defaultvalue OUTPUT,
                                @@idfield = @@idfield OUTPUT,
                                @@localname = @idstringlocalname OUTPUT,
                                @@idcategory = @idcategory OUTPUT

					IF @@addCategory = 1 AND @idcategory = -1
					BEGIN
						EXECUTE @return_value = lsp_setfieldattributevalue @@idfield = @@idfield, 
													 @@name = N'idcategory',
													 @@valueint = @idcategory OUTPUT--,
													-- @@transactionid = @@transactionid,
													-- @@user = @@user
					END
				

				--If return value is not 0, something went wrong and the field wasn't created
                            IF @return_value <> 0
                                BEGIN
                                    SET @@messagetext = N'Field '
                                        + QUOTENAME(@@tablename) + N'.'
                                        + QUOTENAME(@@fieldname)
                                        + N' couldn''t be created'
                                END
                            ELSE
                                BEGIN
                                    SET @return_value = 0

                                    IF CHARINDEX(':', @@localname, 0) > 0
                                        BEGIN

						--Make sure @@localname ends with ; in order to avoid infinite loop
                                            IF RIGHT(@@localname, 1) <> N';'
                                                BEGIN
                                                    SET @@localname = @@localname
                                                        + N';'
                                                END
						--Make sure @@localname dont start with ;
                                            WHILE LEFT(@@localname, 1) = N';'
                                                BEGIN
                                                    SET @@localname = SUBSTRING(@@localname,
                                                              2,
                                                              LEN(@@localname))
                                                END


                                            SET @currentPosition = 0
						--Loop through localnames
                                            WHILE @currentPosition <= LEN(@@localname)
                                                AND @return_value = 0
                                                BEGIN
                                                    SET @nextOccurance = CHARINDEX(';',
                                                              @@localname,
                                                              @currentPosition)
                                                    IF @nextOccurance <> 0
                                                        BEGIN
                                                            SET @sql = N''
                                                            SET @currentString = SUBSTRING(@@localname,
                                                              @currentPosition,
                                                              @nextOccurance
                                                              - @currentPosition)
                                                            SET @currentLanguage = SUBSTRING(@currentString,
                                                              0,
                                                              CHARINDEX(':',
                                                              @currentString))
                                                            SET @currentLocalize = SUBSTRING(@currentString,
                                                              CHARINDEX(':',
                                                              @currentString)
                                                              + 1,
                                                              LEN(@currentString)
                                                              - CHARINDEX(':',
                                                              @currentString))
						
								--Set local names for field
                                                            SET @sql = N'UPDATE [string] 
								SET ' + QUOTENAME(@currentLanguage) + N' = '''
                                                              + @currentLocalize
                                                              + N''''
                                                              + N' WHERE [idstring] = '
                                                              + CONVERT(NVARCHAR(12), @idstringlocalname)
                                                            EXEC sp_executesql @sql
						
                                                            SET @currentPosition = @nextOccurance
                                                              + 1
                                                        END
                                                END	
                                        END	
				
					-- SHARED IDCATEGORY
									
                                    IF @return_value = 0
                                        AND @@idcategoryshared IS NOT NULL
                                        EXEC [dbo].[lsp_setattributevalue] @@owner = 'field',
                                            @@idrecord = @@idfield,
                                            @@name = 'idcategory',
                                            @@value = @@idcategoryshared

					--Set limereadonly attribute
                                    IF @return_value = 0
                                        EXEC @return_value = [dbo].[lsp_setfieldattributevalue] @@idfield = @@idfield,
                                            @@name = N'limereadonly',
                                            @@valueint = @@limereadonly
				
					--Set Default value (interpreted by LIME)
                                    IF @return_value = 0
                                        AND @@limedefaultvalue IS NOT NULL
                                        BEGIN
                                            EXEC @return_value = [dbo].[lsp_setattributevalue] @@owner = N'field',
                                                @@idrecord = @@idfield,
                                                @@name = N'limedefaultvalue',
                                                @@value = @@limedefaultvalue	-- Default Value (interpreted by LIME Pro) 
                                        END
				
					--Set invisible/visible
                                    IF @return_value = 0
                                        EXEC @return_value = [dbo].[lsp_setattributevalue] @@owner = N'field',
                                            @@idrecord = @@idfield,
                                            @@name = N'invisible',
                                            @@valueint = @@invisible
				
					--Set required attribute
                                    IF @return_value = 0
                                        AND @@required IS NOT NULL
                                        BEGIN
                                            EXEC @return_value = [dbo].[lsp_setfieldattributevalue] @@idfield = @@idfield,
                                                @@name = N'required',
                                                @@valueint = @@required
                                        END

					--Set width
                                    IF @return_value = 0
                                        AND @@width IS NOT NULL
                                        BEGIN
                                            EXEC @return_value = [dbo].[lsp_setfieldattributevalue] @@idfield = @@idfield,
                                                @@name = N'width',
                                                @@valueint = @@width
                                        END
				
					--Set height
                                    IF @return_value = 0
                                        AND @@height IS NOT NULL
                                        BEGIN
                                            EXEC @return_value = [dbo].[lsp_setfieldattributevalue] @@idfield = @@idfield,
                                                @@name = N'height',
                                                @@valueint = @@height
                                        END
			
				
					--Create separator
                                    IF @return_value = 0
                                        AND @@separator <> N''
                                        AND CHARINDEX(':', @@separator, 0) > 0
                                        BEGIN
                                            SET @idstring = -1
                                            EXEC @return_value = [dbo].[lsp_setattributevalue] @@owner = N'field',
                                                @@idrecord = @@idfield,
                                                @@name = 'separator',
                                                @@value = 1
                                            EXEC @return_value = [dbo].[lsp_setattributevalue] @@owner = N'field',
                                                @@idrecord = @@idfield,
                                                @@name = N'separatorlocalname',
                                                @@value = @idstring OUTPUT
												
						--Make sure @@@@separator ends with ; in order to avoid infinite loop
                                            IF RIGHT(@@separator, 1) <> N';'
                                                BEGIN
                                                    SET @@separator = @@separator
                                                        + N';'
                                                END
					
						--Make sure @@@@separator dont start with ;
                                            WHILE LEFT(@@separator, 1) = N';'
                                                BEGIN
                                                    SET @@separator = SUBSTRING(@@separator,
                                                              2,
                                                              LEN(@@separator))
                                                END

                                            SET @currentPosition = 0
					
						--Loop through localnames
                                            WHILE @currentPosition <= LEN(@@separator)
                                                AND @return_value = 0
                                                BEGIN
                                                    SET @nextOccurance = CHARINDEX(';',
                                                              @@separator,
                                                              @currentPosition)
                                                    IF @nextOccurance <> 0
                                                        BEGIN
                                                            SET @currentString = SUBSTRING(@@separator,
                                                              @currentPosition,
                                                              @nextOccurance
                                                              - @currentPosition)
                                                            SET @currentLanguage = SUBSTRING(@currentString,
                                                              0,
                                                              CHARINDEX(':',
                                                              @currentString))
                                                            SET @currentLocalize = SUBSTRING(@currentString,
                                                              CHARINDEX(':',
                                                              @currentString)
                                                              + 1,
                                                              LEN(@currentString)
                                                              - CHARINDEX(':',
                                                              @currentString))
                                                            EXEC @return_value = [dbo].[lsp_setattributevalue] @@owner = N'string',
                                                              @@idrecord = @idstring,
                                                              @@name = @currentLanguage,
                                                              @@value = @currentLocalize
                                                            SET @currentPosition = @nextOccurance
                                                              + 1
                                                        END
                                                END								
                                        END
					--End of creating separator
				
				
				
					--If return value is not 0, something went wrong while setting field attributes
                                    IF @return_value <> 0
                                        BEGIN
                                            SET @@messagetext = N'Something went wrong while setting attributes for field '
                                                + QUOTENAME(@@tablename)
                                                + N'.' + QUOTENAME(@@fieldname)
                                                + N'. Please check that field properties are correct.'
                                        END

                                    IF @return_value = 0
                                        BEGIN
                                            SET @@messagetext = N'ADDING FIELD '
                                                + QUOTENAME(@@tablename)
                                                + N'.' + QUOTENAME(@@fieldname)
                                        END
				
                                END
                        END
                END	
        END TRY
        BEGIN CATCH
            SET @return_value = -99
            SET @@messagetext = LEFT(ERROR_MESSAGE(), 512)
        END CATCH

        RETURN @return_value
    END

	GO

create PROCEDURE [dbo].[csp_infotiles_scriptfield_addrelation_onetomany]
    @@field_table NVARCHAR(128) ,
    @@field_name NVARCHAR(128) ,
    @@field_localname NVARCHAR(MAX) ,
    @@tab_table NVARCHAR(128) ,
    @@tab_name NVARCHAR(128) ,
    @@tab_localname NVARCHAR(MAX) ,
    @@failexistingfield INT = 1 ,
    @@messagetext NVARCHAR(512) = N'' OUTPUT ,
    @@idfieldfield INT = NULL OUTPUT ,
    @@idfieldtab INT = NULL OUTPUT
AS
    BEGIN
        SET NOCOUNT ON;

        BEGIN TRY

		   
		/**********************
		DECLARE vars
		**********************/
            DECLARE @return_value INT
		--DECLARE @defaultvalue NVARCHAR(128)
		--DECLARE @idfield INT
            DECLARE @localname INT
            DECLARE @idcategory INT
		--DECLARE @idstring INT
		--DECLARE @sqlcommand NVARCHAR(2048)

		-- Special relation variables.
            DECLARE @idtable1 INT		--Table with field
            DECLARE @idtable2 INT		--Table with tab
            DECLARE @idrelation INT
            DECLARE @count_field INT
            DECLARE @count_tab INT
            DECLARE @sql NVARCHAR(300)
            DECLARE @currentPosition INT
            DECLARE @nextOccurance INT
            DECLARE @currentString NVARCHAR(256)
            DECLARE @currentLanguage NVARCHAR(8)
            DECLARE @currentLocalize NVARCHAR(256)

		-- init vars
            SET @return_value = 0 -- DEFAULT OK
            SET @@messagetext = N''
            SET @sql = N''
            SET @@idfieldfield = NULL
            SET @@idfieldtab = NULL

	

		-- CHECK IF ONE FIELD EXIST		
            SET @count_field = NULL
            SET @count_tab = NULL
            EXEC lsp_getfield @@table = @@field_table, @@name = @@field_name,
                @@count = @count_field OUTPUT

            EXEC lsp_getfield @@table = @@tab_table, @@name = @@tab_name,
                @@count = @count_tab OUTPUT


            IF @count_field + @count_tab > 0 --Fieldname already exists
                BEGIN
					
                    IF @count_field > 0
                        BEGIN
                            SET @@messagetext = N'Field '
                                + QUOTENAME(@@field_table) + N'.'
                                + QUOTENAME(@@field_name)
                                + N' already exists.'
                        END
                    IF @count_tab > 0
                        BEGIN
                            SET @@messagetext = @@messagetext + CHAR(10)
                                + N'Field ' + QUOTENAME(@@tab_table) + N'.'
                                + QUOTENAME(@@tab_name) + N' already exists.'
                        END
                    IF @@failexistingfield = 1
                        SET @return_value = -1
                END
            ELSE
                BEGIN
                    IF @return_value = 0
                        BEGIN
					-- ADD FIELD 1 (FIELD)
                            SET @localname = NULL
                            SET @idcategory = NULL

					-- create field
                            EXEC @return_value = [dbo].[lsp_addfield] @@table = @@field_table,
                                @@name = @@field_name, @@fieldtype = 16,					--realationfield
                                @@idfield = @@idfieldField OUTPUT,
                                @@localname = @localname OUTPUT,
                                @@idcategory = @idcategory OUTPUT
					
                            IF @return_value <> 0
                                BEGIN
                                    SET @@messagetext = N'Field '
                                        + QUOTENAME(@@field_table) + N'.'
                                        + QUOTENAME(@@field_name)
                                        + N' couldn''t be created'
                                END
                            ELSE
                                BEGIN
	
					-- fix localisation

                                    IF CHARINDEX(':', @@field_localname, 0) > 0
                                        BEGIN

						--Make sure @@localname ends with ; in order to avoid infinite loop
                                            IF RIGHT(@@field_localname, 1) <> N';'
                                                BEGIN
                                                    SET @@field_localname = @@field_localname
                                                        + N';'
                                                END
						--Make sure @@localname dont start with ;
                                            WHILE LEFT(@@field_localname, 1) = N';'
                                                BEGIN
                                                    SET @@field_localname = SUBSTRING(@@field_localname,
                                                              2,
                                                              LEN(@@field_localname))
                                                END


                                            SET @currentPosition = 0
						--Loop through localnames
                                            WHILE @currentPosition <= LEN(@@field_localname)
                                                AND @return_value = 0
                                                BEGIN
                                                    SET @nextOccurance = CHARINDEX(';',
                                                              @@field_localname,
                                                              @currentPosition)
                                                    IF @nextOccurance <> 0
                                                        BEGIN
                                                            SET @sql = N''
                                                            SET @currentString = SUBSTRING(@@field_localname,
                                                              @currentPosition,
                                                              @nextOccurance
                                                              - @currentPosition)
                                                            SET @currentLanguage = SUBSTRING(@currentString,
                                                              0,
                                                              CHARINDEX(':',
                                                              @currentString))
                                                            SET @currentLocalize = SUBSTRING(@currentString,
                                                              CHARINDEX(':',
                                                              @currentString)
                                                              + 1,
                                                              LEN(@currentString)
                                                              - CHARINDEX(':',
                                                              @currentString))
						
								--Set local names for field
                                                            SET @sql = N'UPDATE [string] 
								SET ' + QUOTENAME(@currentLanguage) + N' = '''
                                                              + @currentLocalize
                                                              + N''''
                                                              + N' WHERE [idstring] = '
                                                              + CONVERT(NVARCHAR(12), @localname)
                                                            EXEC sp_executesql @sql
						
                                                            SET @currentPosition = @nextOccurance
                                                              + 1
                                                        END
                                                END	
                                        END	

                                END

										--set realtioncount
                            EXEC @return_value = [dbo].[lsp_setattributevalue] @@owner = 'field',
                                @@idrecord = @@idfieldfield,
                                @@name = 'relationmincount', @@value = 0

                            IF @return_value <> 0
                                BEGIN
                                    SET @@messagetext = N'Something went wrong while setting attributes for field '
                                        + QUOTENAME(@@field_table) + N'.'
                                        + QUOTENAME(@@field_name)
                                        + N'. Please check that field properties are correct.'
                                END



                        END

                    IF @return_value = 0
                        BEGIN
					-- ADD FIELD 2 (TAB)
                            SET @localname = NULL
                            SET @idcategory = NULL

					-- create field
                            EXEC @return_value = [dbo].[lsp_addfield] @@table = @@tab_table,
                                @@name = @@tab_name, @@fieldtype = 16,					--realationfield
                                @@idfield = @@idfieldTab OUTPUT,
                                @@localname = @localname OUTPUT,
                                @@idcategory = @idcategory OUTPUT
					
                            IF @return_value <> 0
                                BEGIN
                                    SET @@messagetext = N'Field '
                                        + QUOTENAME(@@tab_table) + N'.'
                                        + QUOTENAME(@@tab_name)
                                        + N' couldn''t be created'
                                END
                            ELSE
                                BEGIN
	
					-- fix localisation

                                    IF CHARINDEX(':', @@tab_localname, 0) > 0
                                        BEGIN

						--Make sure @@localname ends with ; in order to avoid infinite loop
                                            IF RIGHT(@@tab_localname, 1) <> N';'
                                                BEGIN
                                                    SET @@tab_localname = @@tab_localname
                                                        + N';'
                                                END
						--Make sure @@localname dont start with ;
                                            WHILE LEFT(@@tab_localname, 1) = N';'
                                                BEGIN
                                                    SET @@tab_localname = SUBSTRING(@@tab_localname,
                                                              2,
                                                              LEN(@@tab_localname))
                                                END


                                            SET @currentPosition = 0
						--Loop through localnames
                                            WHILE @currentPosition <= LEN(@@tab_localname)
                                                AND @return_value = 0
                                                BEGIN
                                                    SET @nextOccurance = CHARINDEX(';',
                                                              @@tab_localname,
                                                              @currentPosition)
                                                    IF @nextOccurance <> 0
                                                        BEGIN
                                                            SET @sql = N''
                                                            SET @currentString = SUBSTRING(@@tab_localname,
                                                              @currentPosition,
                                                              @nextOccurance
                                                              - @currentPosition)
                                                            SET @currentLanguage = SUBSTRING(@currentString,
                                                              0,
                                                              CHARINDEX(':',
                                                              @currentString))
                                                            SET @currentLocalize = SUBSTRING(@currentString,
                                                              CHARINDEX(':',
                                                              @currentString)
                                                              + 1,
                                                              LEN(@currentString)
                                                              - CHARINDEX(':',
                                                              @currentString))
						
								--Set local names for field
                                                            SET @sql = N'UPDATE [string] 
								SET ' + QUOTENAME(@currentLanguage) + N' = '''
                                                              + @currentLocalize
                                                              + N''''
                                                              + N' WHERE [idstring] = '
                                                              + CONVERT(NVARCHAR(12), @localname)
                                                            EXEC sp_executesql @sql
						
                                                            SET @currentPosition = @nextOccurance
                                                              + 1
                                                        END
                                                END	
                                        END	

                                END

										--set realtioncount
                            EXEC @return_value = [dbo].[lsp_setattributevalue] @@owner = 'field',
                                @@idrecord = @@idfieldtab,
                                @@name = 'relationmincount', @@value = 0

                            IF @return_value = 0
                                BEGIN
                                    EXEC @return_value = [dbo].[lsp_setattributevalue] @@owner = 'field',
                                        @@idrecord = @@idfieldtab,
                                        @@name = 'relationmaxcount',
                                        @@value = 1
                                END
                            IF @return_value <> 0
                                BEGIN
                                    SET @@messagetext = N'Something went wrong while setting attributes for field '
                                        + QUOTENAME(@@tab_table) + N'.'
                                        + QUOTENAME(@@tab_name)
                                        + N'. Please check that field properties are correct.'
                                END



                        END

                    IF @return_value = 0
                        BEGIN
				-- ADD RELATION
                            SET @idtable1 = NULL
                            SET @idtable2 = NULL
                            SET @idrelation = NULL

                            EXEC lsp_gettable @@name = @@field_table,
                                @@idtable = @idtable1 OUTPUT
                            EXEC lsp_gettable @@name = @@tab_table,
                                @@idtable = @idtable2 OUTPUT

                            EXEC @return_value = lsp_addrelation @@idfield1 = @@idfieldfield,
                                @@idtable1 = @idtable1,
                                @@idfield2 = @@idfieldtab,
                                @@idrelation = @idrelation OUTPUT


                            IF @return_value <> 0
                                BEGIN
                                    SET @@messagetext = N'Something went wrong while adding relation between field '
                                        + QUOTENAME(@@field_table) + N'.'
                                        + QUOTENAME(@@field_name)
                                        + N' and field '
                                        + QUOTENAME(@@tab_table) + N'.'
                                        + QUOTENAME(@@tab_name)
                                        + N'. Please check that field properties are correct.'
                                END
                        END

                    IF @return_value = 0
                        BEGIN
                            SET @@messagetext = N'ADDED ONE TO MANY RELATION BETWEEN FIELD '
                                + QUOTENAME(@@field_table) + N'.'
                                + QUOTENAME(@@field_name) + N' AND FIELD '
                                + QUOTENAME(@@tab_table) + N'.'
                                + QUOTENAME(@@tab_name)
                                        
                        END

                END
		

        END TRY
        BEGIN CATCH
            SET @return_value = -99
            SET @@messagetext = LEFT(ERROR_MESSAGE(), 512)
        END CATCH
        RETURN @return_value
    END


	GO

create PROCEDURE [dbo].[csp_infotiles_scriptfield_validate_optiontext]
    (
      @@localname NVARCHAR(MAX) ,
      @@idcategory INT, 
	  @@noofmatches INT = 0 OUTPUT
    )

AS
    BEGIN
	
        DECLARE @returnvalue INT = 0
        DECLARE @sql NVARCHAR(300) = N''
        DECLARE @currentPosition INT
        DECLARE @nextOccurance INT
        DECLARE @currentString NVARCHAR(256)
        DECLARE @currentLanguage NVARCHAR(8)
        DECLARE @currentLocalize NVARCHAR(256)
        IF CHARINDEX(':', @@localname, 0) > 0
            BEGIN

						--Make sure @@localname ends with ; in order to avoid infinite loop
                IF RIGHT(@@localname, 1) <> N';'
                    BEGIN
                        SET @@localname = @@localname + N';'
                    END
						--Make sure @@localname dont start with ;
                WHILE LEFT(@@localname, 1) = N';'
                    BEGIN
                        SET @@localname = SUBSTRING(@@localname, 2,
                                                    LEN(@@localname))
                    END


                SET @currentPosition = 0
						--Loop through localnames
                WHILE @currentPosition <= LEN(@@localname)
                    BEGIN
                        SET @nextOccurance = CHARINDEX(';', @@localname,
                                                       @currentPosition)
                        IF @nextOccurance <> 0
                            BEGIN
                                                           
                                SET @currentString = SUBSTRING(@@localname,
                                                              @currentPosition,
                                                              @nextOccurance
                                                              - @currentPosition)
                                SET @currentLanguage = SUBSTRING(@currentString,
                                                              0,
                                                              CHARINDEX(':',
                                                              @currentString))
                                SET @currentLocalize = SUBSTRING(@currentString,
                                                              CHARINDEX(':',
                                                              @currentString)
                                                              + 1,
                                                              LEN(@currentString)
                                                              - CHARINDEX(':',
                                                              @currentString))
						
								--Set local names for field
                                SET @sql = @sql
                                    + CASE WHEN @sql != N'' THEN N' OR '
                                           ELSE N''
                                      END + QUOTENAME(@currentLanguage)
                                    + N' = ''' + @currentLocalize + N''''  
                                                              
                                                              
                                                            
						
                                SET @currentPosition = @nextOccurance + 1
                            END
                    END	
            END	

        IF @sql != N''
            BEGIN
		

                DECLARE @sqlfull NVARCHAR(MAX)
                DECLARE @idcategory INT = 4401

                SET @sqlfull = N'SELECT  @count_sql = COUNT(*) FROM [dbo].[string] WHERE [idcategory] = @idcategory_sql AND ('
                    + @sql + N')'

										

                EXEC sp_executesql @sqlfull,
                    N'@count_sql INT OUTPUT, @idcategory_sql INT',
                    @count_sql = @@noofmatches OUTPUT,
                    @idcategory_sql = @@idcategory
            END	

    END
    

	GO

	CREATE PROCEDURE [dbo].[csp_infotiles_scriptfield_addoption]
    @@tablename NVARCHAR(64) ,
    @@fieldname NVARCHAR(64) ,
    @@localname NVARCHAR(MAX) , -- N'lang:text;lang2:text2'
    @@key NVARCHAR(256) = N'' ,
    @@failexistingoption INT = 1 ,
    @@idstring INT = NULL OUTPUT ,
    @@messagetext NVARCHAR(512) = N'' OUTPUT,
	@@default INT = 0,
	@@color INT = NULL
AS
    BEGIN
        SET NOCOUNT ON;

        BEGIN TRY

		/**********************
		DECLARE vars
		**********************/
            DECLARE @return_value INT
            DECLARE @idfield INT = NULL
            DECLARE @idcategory INT = NULL
            DECLARE @currentPosition INT
            DECLARE @nextOccurance INT
            DECLARE @currentString NVARCHAR(256)
            DECLARE @currentLanguage NVARCHAR(8)
            DECLARE @currentLocalize NVARCHAR(256)
            DECLARE @isFirstLocalize BIT
            DECLARE @keyAlreadyExist INT
            DECLARE @optionAlreadyExists INT
			DECLARE @defaultidstring INT

            SET @isFirstLocalize = 1
            SET @@messagetext = N''
            SET @return_value = 0
            SET @keyAlreadyExist = 0
            SET @optionAlreadyExists = 0
		/**********************
		get field 
		**********************/
            EXEC [dbo].[lsp_getfield] @@idfield = @idfield OUTPUT,
                @@name = @@fieldname, @@table = @@tablename
			
			SELECT @defaultidstring = fv.defaultvalue
			FROM fieldview fv
			WHERE fv.idfield = @idfield

            IF @idfield IS NULL
                BEGIN
                    SET @@messagetext = N'MISSING FIELD '
                        + QUOTENAME(@@tablename) + N'.'
                        + QUOTENAME(@@fieldname) + N' FAILED TO ADD OPTION '
                        + @@localname
                    SET @return_value = -1
                END
            ELSE
                BEGIN
			-- GET idcategory for field
                    EXEC [dbo].[lsp_getattributedata] @@owner = N'field',
                        @@idrecord = @idfield, @@name = N'idcategory',
                        @@value = @idcategory OUTPUT, @@count = 1

                    IF ISNULL(@idcategory, 0) = 0
                        BEGIN
                            SET @@messagetext = N'MISSING CATEGORY FOR FIELD '
                                + QUOTENAME(@@tablename) + N'.'
                                + QUOTENAME(@@fieldname)
                                + N' FAILED TO ADD OPTION ' + @@localname
                            SET @return_value = -2
                        END
                END
		
            IF @return_value = 0
                AND LEN(ISNULL(@@key, N'')) > 0
                BEGIN
			-- MAKE SURE [key] IS UNIQUE
                    IF EXISTS ( SELECT  [idstring]
                                FROM    [dbo].[string]
                                WHERE   [idcategory] = @idcategory
                                        AND [key] = @@key )
                        BEGIN
                            SET @@messagetext = N'OPTION WITH KEY ''' + @@key
                                + N''' ALREADY EXISTS FOR FIELD '
                                + QUOTENAME(@@tablename) + N'.'
                                + QUOTENAME(@@fieldname)
                                + N' FAILED TO ADD OPTION ' + @@localname
                            
                            SET @keyAlreadyExist = 1
							
                            IF @@failexistingoption = 1
                                SET @return_value = -3
                        END
                END

            IF @return_value = 0
                BEGIN
			-- MAKE SURE NOT DUPLICATE IN ANY LANGUAGE
                    DECLARE @noOfHits INT
                    EXECUTE [dbo].[csp_infotiles_scriptfield_validate_optiontext] @@localname = @@localname,
                        @@idcategory = @idcategory,
                        @@noofmatches = @noOfHits OUTPUT
					
                    IF @noOfHits > 0
                        BEGIN
                            SET @@messagetext = N'OPTION  ''' + @@localname
                                + N''' ALREADY EXISTS FOR FIELD '
                                + QUOTENAME(@@tablename) + N'.'
                                + QUOTENAME(@@fieldname)
                                + N' FAILED TO ADD OPTION'
                            
                            SET @optionAlreadyExists = 1
							
                            IF @@failexistingoption = 1
                                SET @return_value = -4
                        END
                END

			-- VALIDATIONS OK --> Add Option
            IF ( @keyAlreadyExist + @optionAlreadyExists ) = 0
                BEGIN
                    IF @return_value = 0
                        BEGIN
                            SET @@idstring = NULL

			--Set localnames
                            IF CHARINDEX(':', @@localname, 0) > 0
                                BEGIN
				--Make sure @@localname_plural ends with ; in order to avoid infinite loop
                                    SET @currentPosition = 0
                                    IF RIGHT(@@localname, 1) <> N';'
                                        BEGIN
                                            SET @@localname = @@localname
                                                + N';'
                                        END
				
				--Make sure @@localname dont start with ;
                                    WHILE LEFT(@@localname, 1) = N';'
                                        BEGIN
                                            SET @@localname = SUBSTRING(@@localname,
                                                              2,
                                                              LEN(@@localname))
                                        END

                                    SET @currentPosition = 0
				--Loop through localnames
                                    WHILE @currentPosition <= LEN(@@localname)
                                        AND @return_value = 0
                                        BEGIN
                                            SET @nextOccurance = CHARINDEX(';',
                                                              @@localname,
                                                              @currentPosition)
                                            IF @nextOccurance <> 0
                                                BEGIN
                                                    SET @currentString = SUBSTRING(@@localname,
                                                              @currentPosition,
                                                              @nextOccurance
                                                              - @currentPosition)
                                                    SET @currentLanguage = SUBSTRING(@currentString,
                                                              0,
                                                              CHARINDEX(':',
                                                              @currentString))
                                                    SET @currentLocalize = SUBSTRING(@currentString,
                                                              CHARINDEX(':',
                                                              @currentString)
                                                              + 1,
                                                              LEN(@currentString)
                                                              - CHARINDEX(':',
                                                              @currentString))
													IF @@default = 1
													BEGIN
														SET @@idstring = @defaultidstring

														EXEC @return_value = dbo.lsp_setstring @@idstring = @@idstring,
																@@lang = @currentLanguage,
																@@string = @currentLocalize
													END
													ELSE
													BEGIN
													IF @isFirstLocalize = 1
														BEGIN
															EXEC @return_value = [dbo].[lsp_addstring] @@idcategory = @idcategory,
																@@string = @currentLocalize,
																@@lang = @currentLanguage,
																@@idstring = @@idstring OUTPUT
															SET @isFirstLocalize = 0
														END
													ELSE
														BEGIN
															EXEC @return_value = dbo.lsp_setstring @@idstring = @@idstring,
																@@lang = @currentLanguage,
																@@string = @currentLocalize
														END
					
													--SET @currentPosition = @nextOccurance
													--	+ 1
													END
													
													SET @currentPosition = @nextOccurance + 1
                                                END
                                        END
                                END	
                            IF @return_value != 0
                                BEGIN
                                    SET @@messagetext = N'FAILED TO ADD OPTION '
                                        + @@localname + N' FOR FIELD '
                                        + QUOTENAME(@@tablename) + N'.'
                                        + QUOTENAME(@@fieldname)
                                END
                            ELSE
                                BEGIN
                                    SET @@messagetext = N'ADDED OPTION '
                                        + @@localname + N' FOR FIELD '
                                        + QUOTENAME(@@tablename) + N'.'
                                        + QUOTENAME(@@fieldname)
                                END
                
                            IF ISNULL(@@idstring, 0) > 0
                                AND @return_value = 0
                                BEGIN
								IF @@color IS NOT NULL
								BEGIN
									EXEC @return_value = [dbo].[lsp_addattributedata]
										@@owner= 'string',
										@@idrecord			= @@idstring,
										@@idrecord2			= NULL,
										@@name = 'color'				,
										@@value	= @@color
								END
						-- ADD key to string
                                    IF LEN(ISNULL(@@key, N'')) > 0
                                        BEGIN
                                            EXEC @return_value = dbo.lsp_setstring @@idstring = @@idstring,
                                                @@lang = N'key',
                                                @@string = @@key
                                        END
                                    IF @return_value != 0
                                        BEGIN
                                            SET @@messagetext = N'FAILED TO ADD KEY '
                                                + @@key + N' FOR OPTION '
                                                + @@localname + N' FOR FIELD '
                                                + QUOTENAME(@@tablename)
                                                + N'.' + QUOTENAME(@@fieldname)
                                        END
                                END
                        END
                END
        END TRY
        BEGIN CATCH
            SET @return_value = -99
            SET @@messagetext = LEFT(ERROR_MESSAGE(), 512)
        END CATCH

        RETURN @return_value
    END