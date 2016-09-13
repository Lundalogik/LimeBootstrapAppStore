
DECLARE @debug INT = 1
DECLARE @fail_if_table_exist INT = 1
DECLARE @fail_if_field_exist INT = 1
DECLARE @fail_if_option_exist INT = 1
DECLARE @fail_if_relation_exist INT = 1




SET NOCOUNT ON;

DECLARE @temp_table TABLE
    (
      [id] [INT] IDENTITY(1, 1) ,
      [table] NVARCHAR(64) ,
      [localname] NVARCHAR(128) ,
      [localname_plural] NVARCHAR(128) ,
      [processed] INT
    )

DECLARE @temp_field TABLE
    (
      [id] [INT] IDENTITY(1, 1) ,
      [table] NVARCHAR(64) ,
      [field] NVARCHAR(64) ,
      [localname] NVARCHAR(128) ,
      [fieldtype] NVARCHAR(64) ,
      [length] INT ,
      [isnullable] INT ,
      [required] INT ,
      [shared_idcategory_table] NVARCHAR(64) ,
      [shared_idcategory_field] NVARCHAR(64) ,
	  [addcategory] INT,
      [processed] INT
    )

DECLARE @temp_option TABLE
    (
      [id] [INT] IDENTITY(1, 1) ,
      [table] NVARCHAR(64) ,
      [field] NVARCHAR(64) ,
      [optiontext] NVARCHAR(128) ,
      [key] NVARCHAR(64) ,
      [processed] INT,
	  [default] INT,
	  [color] INT
    )

DECLARE @temp_relation_one_to_many TABLE
    (
      [id] [INT] IDENTITY(1, 1) ,
      [table_field] NVARCHAR(64) ,
      [name_field] NVARCHAR(64) ,
      [localname_field] NVARCHAR(128) ,
      [table_tab] NVARCHAR(64) ,
      [name_tab] NVARCHAR(64) ,
      [localname_tab] NVARCHAR(128) ,
      [processed] INT
    )

DECLARE @tablename NVARCHAR(64)
DECLARE @fieldname NVARCHAR(64)

-- GARCONSETTINGS

SET @tablename = N'garconsettings'


INSERT  INTO @temp_table
        ( [table] ,
          [localname] ,
          [localname_plural]
        )
        SELECT  @tablename ,
                N'sv:Garconinställning;en_us:Garcon Setting;fi:Garcon-asetus' ,
                N'sv:Garconinställningar;en_us:Garcon Settings;fi:Garcon-asetukset'


SET @fieldname = N'active'

INSERT  INTO @temp_field
        ( [table] ,
          field ,
          [localname] ,
          fieldtype ,
          [length] ,
          isnullable ,
          [required] ,
          shared_idcategory_table ,
          shared_idcategory_field
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Aktiv;en_us:Active;fi:Aktiivinen' ,
                N'yesno' ,
                NULL ,
                NULL ,
                NULL ,
                NULL ,
                NULL

SET @fieldname = N'visiblefor'

INSERT  INTO @temp_field
        ( [table] ,
          field ,
          [localname] ,
          fieldtype ,
          [length] ,
          isnullable ,
          [required] ,
          shared_idcategory_table ,
          shared_idcategory_field
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Synlig för;en_us:Visible for;fi:Näkyvillä' ,
                N'option' ,
                NULL ,
                NULL ,
                0 ,
                NULL ,
                NULL

INSERT  INTO @temp_option
        ( [table] ,
          field ,
          [optiontext] ,
          [key],
		  [default]
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Specifik avdelning;en_us:Specific department;fi:Tietty osasto' ,
                N'department',
				0
        UNION ALL
        SELECT  @tablename ,
                @fieldname ,
                 N'sv:Specifik medarbetare;en_us:Specific coworker;fi:Tietty työntekijä' ,
                N'me',
				0
		UNION ALL
        SELECT  @tablename ,
                @fieldname ,
                 N'sv:Alla;en_us:All;fi:Kaikki' ,
                N'all',
				1

  
SET @fieldname = N'operator'

INSERT  INTO @temp_field
        ( [table] ,
          field ,
          [localname] ,
          fieldtype ,
          [length] ,
          isnullable ,
          [required] ,
          shared_idcategory_table ,
          shared_idcategory_field
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Operator;en_us:Operator;fi:Operaattori' ,
                N'option' ,
                NULL ,
                NULL ,
                0 ,
                NULL ,
                NULL

INSERT  INTO @temp_option
        ( [table] ,
          field ,
          [optiontext] ,
          [key],
		  [default]
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Länk;en_us:Link;fi:Linkki' ,
                N'link',
				0
        UNION ALL
        SELECT  @tablename ,
                @fieldname ,
                 N'sv:Summering;en_us:Sum;fi:Summa' ,
                N'sum',
				0
		UNION ALL
        SELECT  @tablename ,
                @fieldname ,
                 N'sv:Antal träffar;en_us:Hitcount;fi:Osumat' ,
                N'count',
				1
		UNION ALL
        SELECT  @tablename ,
                @fieldname ,
                 N'sv:Fältvärde;en_us:Field value;fi:Field value' ,
                N'field',
				0
     
SET @fieldname = N'visibleon'

INSERT  INTO @temp_field
        ( [table] ,
          field ,
          [localname] ,
          fieldtype ,
          [length] ,
          isnullable ,
          [required] ,
          shared_idcategory_table ,
          shared_idcategory_field,
		  addcategory
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Synlig på;en_us:Visble on;fi:Näkyvissä kortilla' ,
                N'string' ,
                32 ,
                NULL ,
                0 ,
                NULL ,
                NULL,
				1 
INSERT  INTO @temp_option
        ( [table] ,
          field ,
          [optiontext] ,
          [key],
		  [default]
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:;en_us:' ,
                N'',
				0

SET @fieldname = N'classname'

INSERT  INTO @temp_field
        ( [table] ,
          field ,
          [localname] ,
          fieldtype ,
          [length] ,
          isnullable ,
          [required] ,
          shared_idcategory_table ,
          shared_idcategory_field,
		  addcategory
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Flik;en_us:Tab;fi:Välilehti' ,
                N'string' ,
                32 ,
                NULL ,
                1 ,
                NULL ,
                NULL ,
				1 

INSERT  INTO @temp_option
        ( [table] ,
          field ,
          [optiontext] ,
          [key],
		  [default]
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:;en_us:' ,
                N'',
				0


SET @fieldname = N'fieldname'

INSERT  INTO @temp_field
        ( [table] ,
          field ,
          [localname] ,
          fieldtype ,
          [length] ,
          isnullable ,
          [required] ,
          shared_idcategory_table ,
          shared_idcategory_field,
		  addcategory
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Fält;en_us:Field;fi:Kenttä' ,
                N'string' ,
                32 ,
                NULL ,
                0 ,
                NULL ,
                NULL ,
				1 
INSERT  INTO @temp_option
        ( [table] ,
          field ,
          [optiontext] ,
          [key],
		  [default]
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:;en_us:' ,
                N'',
				0

SET @fieldname = N'filtername'

INSERT  INTO @temp_field
        ( [table] ,
          field ,
          [localname] ,
          fieldtype ,
          [length] ,
          isnullable ,
          [required] ,
          shared_idcategory_table ,
          shared_idcategory_field,
		  addcategory
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Urval;en_us:Filter;fi:Suodatin' ,
                N'string' ,
                32 ,
                NULL ,
                0 ,
                NULL ,
                NULL ,
				1 
INSERT  INTO @temp_option
        ( [table] ,
          field ,
          [optiontext] ,
          [key],
		  [default]
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:;en_us:' ,
                N'',
				0

SET @fieldname = N'icon'

INSERT  INTO @temp_field
        ( [table] ,
          field ,
          [localname] ,
          fieldtype ,
          [length] ,
          isnullable ,
          [required] ,
          shared_idcategory_table ,
          shared_idcategory_field
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Ikon;en_us:Icon;fi:Kuvake' ,
                N'string' ,
                32 ,
                NULL ,
                0 ,
                NULL ,
                NULL 

SET @fieldname = N'label'

INSERT  INTO @temp_field
        ( [table] ,
          field ,
          [localname] ,
          fieldtype ,
          [length] ,
          isnullable ,
          [required] ,
          shared_idcategory_table ,
          shared_idcategory_field
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Benämning i actionpad;en_us:Label;fi:Kuvaus' ,
                N'string' ,
                32 ,
                NULL ,
                0 ,
                NULL ,
                NULL 

SET @fieldname = N'sortorder'

INSERT  INTO @temp_field
        ( [table] ,
          field ,
          [localname] ,
          fieldtype ,
          [length] ,
          isnullable ,
          [required] ,
          shared_idcategory_table ,
          shared_idcategory_field
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Sortering;en_us:Sort order;fi:Järjestys' ,
                N'string' ,
                32 ,
                NULL ,
                0 ,
                NULL ,
                NULL 


SET @fieldname = N'size'

INSERT  INTO @temp_field
        ( [table] ,
          field ,
          [localname] ,
          fieldtype ,
          [length] ,
          isnullable ,
          [required] ,
          shared_idcategory_table ,
          shared_idcategory_field
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Storlek;en_us:Size;fi:Koko' ,
                N'option' ,
                NULL ,
                NULL ,
                0 ,
                NULL ,
                NULL

INSERT  INTO @temp_option
        ( [table] ,
          field ,
          [optiontext] ,
          [key],
		  [default]
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Medium;en_us:Medium;fi:Keskikokoinen' ,
                N'medium',
				0
        UNION ALL
        SELECT  @tablename ,
                @fieldname ,
                 N'sv:Large;en_us:Large;fi:Suuri' ,
                N'large',
				0
		UNION ALL
        SELECT  @tablename ,
                @fieldname ,
                 N'sv:Small;en_us:Small;fi:Pieni' ,
                N'small',
				1


SET @fieldname = N'color'

INSERT  INTO @temp_field
        ( [table] ,
          field ,
          [localname] ,
          fieldtype ,
          [length] ,
          isnullable ,
          [required] ,
          shared_idcategory_table ,
          shared_idcategory_field
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Färg;en_us:Color;fi:Väri' ,
                N'option' ,
                NULL ,
                NULL ,
                0 ,
                NULL ,
                NULL

INSERT  INTO @temp_option
        ( [table] ,
          field ,
          [optiontext] ,
          [key],
		  [default],
		  [color]
        )
        SELECT  @tablename ,
                @fieldname ,	
				N'sv:Blekgrön;en_us:Clean-green;fi:Puhdas vihreä',
				N'clean-green',
				0,
				6008832
		UNION ALL
		SELECT  @tablename ,
				@fieldname ,
				N'sv:Blå;en_us:Blue;fi:Sininen',
				N'blue',
				0,
				16749350
		UNION ALL
		SELECT  @tablename ,
				@fieldname ,
				N'sv:Lila;en_us:Purple;fi:Lila',
				N'purple',
				0,
				11934616
		UNION ALL
		SELECT  @tablename ,
				@fieldname ,
				N'sv:Gul;en_us:Yellow;fi:Keltainen',
				N'yellow',
				0,
				630227
		UNION ALL
		SELECT  @tablename ,
				@fieldname ,
				N'sv:Grön;en_us:Green;fi:Vihreä',
				N'green',
				0,
				2079363
		UNION ALL
		SELECT  @tablename ,
				@fieldname ,
				N'sv:Citrus;en_us:Citrus;fi:Sitrus',
				N'citrus',
				0,
				47298
		UNION ALL
		SELECT  @tablename ,
				@fieldname ,
				N'sv:Djupröd;en_us:Deep-red;fi:Syvänpunainen',
				N'deep-red',
				0,
				1842376
		UNION ALL
		SELECT  @tablename ,
				@fieldname ,
				N'sv:Ljusgrå;en_us:Light-grey;fi:Vaaleanharmaa',
				N'light-grey',
				0,
				9145227
		UNION ALL
		SELECT  @tablename ,
				@fieldname ,
				N'sv:Magenta;en_us:Magenta;fi:Magenta',
				N'magenta',
				0,
				7477200
		UNION ALL
		SELECT  @tablename ,
				@fieldname ,
				N'sv:Mörkgrå;en_us:Dark-grey;fi:Tummanharmaa',
				N'dark-grey',
				0,
				4605510
		UNION ALL
		SELECT  @tablename ,
				@fieldname ,
				N'sv:Mörklila;en_us:Purple-rain;fi:Tummanlila',
				N'purple-rain',
				0,
				9973850
		UNION ALL
		SELECT  @tablename ,
				@fieldname ,
				N'sv:Orange;en_us:Orange;fi:Oranssi',
				N'orange',
				0,
				1666277
		UNION ALL
		SELECT  @tablename ,
				@fieldname ,
				N'sv:Röd;en_us:Red;fi:Punainen',
				N'red',
				0,
				2505663
		UNION ALL
		SELECT  @tablename ,
				@fieldname ,
				N'sv:Turkos;en_us:Turquoise;fi:Turkoosi',
				N'turquoise',
				0,
				11576320

SET @fieldname = N'visibleonzero'

INSERT  INTO @temp_field
        ( [table] ,
          field ,
          [localname] ,
          fieldtype ,
          [length] ,
          isnullable ,
          [required] ,
          shared_idcategory_table ,
          shared_idcategory_field
        )
        SELECT  @tablename ,
                @fieldname ,
                N'sv:Synlig om noll;en_us:Visable on Zero;fi:Näkyvissä nolla-arvolla' ,
                N'yesno' ,
                NULL ,
                NULL ,
                NULL ,
                NULL ,
                NULL

-- REALATIONS
INSERT  INTO @temp_relation_one_to_many
        ( table_field ,
          name_field ,
          localname_field ,
          table_tab ,
          name_tab ,
          localname_tab
        )


--RELATION WITH COWORKER
        SELECT  N'garconsettings' ,
                N'coworker' ,
                N'sv:Specifik medarbetare;en_us:Specific coworker;fi:Tietty työntekijä' ,
                N'coworker' ,
                N'garconsettings' ,
                N'sv:Garconinställningar;en_us:Garcon Settings;fi:Garcon-asetukset' 



IF @debug = 1
    BEGIN

        SELECT  *
        FROM    @temp_table
        ORDER BY [id] ASC
        SELECT  *
        FROM    @temp_field
        ORDER BY [id] ASC
        SELECT  *
        FROM    @temp_option
        ORDER BY [id] ASC
        SELECT  *
        FROM    @temp_relation_one_to_many
        ORDER BY [id] ASC


    END


ELSE
    BEGIN
-- ##############################################################################################################

        BEGIN TRY
            BEGIN TRANSACTION script_field

            DECLARE @totaltables INT = 0
            DECLARE @totalfields INT = 0
            DECLARE @totaloptions INT = 0
            DECLARE @totalrelations INT = 0

            DECLARE @noofaddedtables INT = 0
            DECLARE @noofaddedfields INT = 0
            DECLARE @noofaddedoptions INT = 0
            DECLARE @noofaddedrelations INT = 0

            DECLARE @notaddedtables INT = 0
            DECLARE @notaddedfields INT = 0
            DECLARE @notaddedoptions INT = 0
            DECLARE @notaddedrelations INT = 0

            

            DECLARE @message NVARCHAR(2048) = N''
            DECLARE @returnvalue INT = 0
            DECLARE @idtable INT

            

			-- GET TOTALS
            SELECT  @totaltables = COUNT(*)
            FROM    @temp_table

            SELECT  @totalfields = COUNT(*)
            FROM    @temp_field

            SELECT  @totaloptions = COUNT(*)
            FROM    @temp_option

            SELECT  @totalrelations = COUNT(*)
            FROM    @temp_relation_one_to_many


            DECLARE @t_id INT
            DECLARE @t_table NVARCHAR(64)
            DECLARE @t_localname NVARCHAR(MAX)
            DECLARE @t_localnameplural NVARCHAR(MAX)


            DECLARE tablecursor CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
            FOR
                SELECT  [id] ,
                        [table] ,
                        [localname] ,
                        [localname_plural]
                FROM    @temp_table
                WHERE   [processed] IS NULL
                ORDER BY [id] ASC

			
            OPEN tablecursor
            FETCH NEXT FROM tablecursor INTO @t_id, @t_table, @t_localname,
                @t_localnameplural
            WHILE @@FETCH_STATUS = 0
                BEGIN
                    IF @returnvalue = 0
                        BEGIN
                            SET @idtable = NULL
                            SET @message = N''

                            EXECUTE @returnvalue = [dbo].[csp_garcon_scriptfield_addtable] @@tablename = @t_table,
                                @@localname_singular = @t_localname,
                                @@localname_plural = @t_localnameplural,
                                @@failexistingtable = @fail_if_table_exist,
                                @@messagetext = @message OUTPUT,
                                @@idtable = @idtable OUTPUT
  --,@@iddescriptiveexpression OUTPUT
							
                            PRINT @message
                            
                            IF ISNULL(@idtable, 0) > 0
                                BEGIN
                                    SET @noofaddedtables = @noofaddedtables
                                        + 1
                                    PRINT REPLICATE(CHAR(13), 1)
                                        + N'- ADDED @idtable = '
                                        + CAST(@idtable AS NVARCHAR(32))
								-- REMOVE 1 since always added
                                    SET @notaddedtables = @notaddedtables - 1
                                END
                        END
						-- ALWAYS ADD 1 (Removed if table is created)
                    SET @notaddedtables = @notaddedtables + 1

                    UPDATE  @temp_table
                    SET     [processed] = 1
                    WHERE   [id] = @t_id

                    FETCH NEXT FROM tablecursor INTO @t_id, @t_table,
                        @t_localname, @t_localnameplural
                END
            CLOSE tablecursor
            DEALLOCATE tablecursor
	
            DECLARE @f_id INT
            DECLARE @f_table NVARCHAR(64)
            DECLARE @f_field NVARCHAR(64)
            DECLARE @f_localname NVARCHAR(128)
            DECLARE @f_fieldtype NVARCHAR(64)
            DECLARE @f_length INT
            DECLARE @f_isnullable INT
            DECLARE @f_required INT
            DECLARE @f_shared_idcategory_table NVARCHAR(64)
            DECLARE @f_shared_idcategory_field NVARCHAR(64)
			DECLARE @f_addcategory INT

            DECLARE @idfield INT
            DECLARE @f_shared_idcategory NVARCHAR(32)

            DECLARE fieldcursor CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
            FOR
                SELECT  tf.[id] ,
                        tf.[table] ,
                        tf.field ,
                        tf.[localname] ,
                        tf.fieldtype ,
                        tf.[length] ,
                        tf.isnullable ,
                        tf.[required] ,
                        tf.[shared_idcategory_table] ,
                        tf.[shared_idcategory_field],
						tf.addcategory

                FROM    @temp_field tf
                WHERE   tf.[processed] IS NULL
                ORDER BY tf.[id] ASC

			
            OPEN fieldcursor
            FETCH NEXT FROM fieldcursor INTO @f_id, @f_table, @f_field,
                @f_localname, @f_fieldtype, @f_length, @f_isnullable,
                @f_required, @f_shared_idcategory_table,
                @f_shared_idcategory_field,
				@f_addcategory
            WHILE @@FETCH_STATUS = 0
                BEGIN
					
					--GET IDCATEGORY IF SHARED
                    SET @f_shared_idcategory = NULL
                    IF ( ( LEN(ISNULL(@f_shared_idcategory_table, N'')) > 0 )
                         AND ( LEN(ISNULL(@f_shared_idcategory_field, N'')) > 0 )
                       )
                        BEGIN
                            SELECT TOP 1
                                    @f_shared_idcategory = a.[value]
                            FROM    [dbo].[field] f
                                    INNER JOIN [dbo].[table] t ON t.[idtable] = f.[idtable]
                                    INNER JOIN [dbo].[attributedata] a ON a.[idrecord] = f.[idfield]
                                                              AND a.[owner] = N'field'
                                                              AND a.[name] = N'idcategory'
                            WHERE   f.[name] = @f_shared_idcategory_field
                                    AND t.[name] = @f_shared_idcategory_table
                        END

                    IF @returnvalue = 0
                        BEGIN
                            SET @idfield = NULL
                            SET @message = N''

                            EXECUTE @returnvalue = [dbo].[csp_garcon_scriptfield_addfield] @@tablename = @f_table,
                                @@fieldname = @f_field, @@type = @f_fieldtype,
                                @@localname = @f_localname
  --,@@separator
  --,@@defaultvalue
  --,@@limedefaultvalue
  --,@@limereadonly
  --,@@invisible
                                , @@required = @f_required
  --,@@width
  --,@@height
                                , @@length = @f_length,
                                @@isnullable = @f_isnullable,
                                @@idcategoryshared = @f_shared_idcategory,
                                @@failexistingfield = @fail_if_field_exist,
                                @@messagetext = @message OUTPUT,
                                @@idfield = @idfield OUTPUT,
								@@addCategory = @f_addcategory
                            
                            PRINT @message

                            IF ISNULL(@idfield, 0) > 0
                                BEGIN
                                    SET @noofaddedfields = @noofaddedfields
                                        + 1
                                    PRINT REPLICATE(CHAR(13), 1)
                                        + N'- ADDED @idfield = '
                                        + CAST(@idfield AS NVARCHAR(32))
							-- REMOVE 1 since always added
                                    SET @notaddedfields = @notaddedfields - 1

                                END
                        END
						-- ALWAYS ADD 1 (Removed if field is created)
                    SET @notaddedfields = @notaddedfields + 1

                    UPDATE  @temp_field
                    SET     [processed] = 1
                    WHERE   [id] = @f_id

                    FETCH NEXT FROM fieldcursor INTO @f_id, @f_table, @f_field,
                        @f_localname, @f_fieldtype, @f_length, @f_isnullable,
                        @f_required, @f_shared_idcategory_table,
                        @f_shared_idcategory_field,@f_addcategory
                END
            CLOSE fieldcursor
            DEALLOCATE fieldcursor

            DECLARE @r_id INT
            DECLARE @r_table_field NVARCHAR(64)
            DECLARE @r_name_field NVARCHAR(64)
            DECLARE @r_localname_field NVARCHAR(128)
            DECLARE @r_table_tab NVARCHAR(64)
            DECLARE @r_name_tab NVARCHAR(64)
            DECLARE @r_localname_tab NVARCHAR(128)

            DECLARE @idfieldfield INT
            DECLARE @idfieldtab INT

            DECLARE relationcursor CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
            FOR
                SELECT  [id] ,
                        [table_field] ,
                        name_field ,
                        localname_field ,
                        [table_tab] ,
                        name_tab ,
                        localname_tab
                FROM    @temp_relation_one_to_many
                WHERE   [processed] IS NULL
                ORDER BY [id] ASC

			
            OPEN relationcursor
            FETCH NEXT FROM relationcursor INTO @r_id, @r_table_field,
                @r_name_field, @r_localname_field, @r_table_tab, @r_name_tab,
                @r_localname_tab
            WHILE @@FETCH_STATUS = 0
                BEGIN
                    
                    IF @returnvalue = 0
                        BEGIN
                            SET @idfieldfield = NULL
                            SET @idfieldtab = NULL
                            SET @message = N''

                            EXECUTE @returnvalue = [dbo].[csp_garcon_scriptfield_addrelation_onetomany] @@field_table = @r_table_field,
                                @@field_name = @r_name_field,
                                @@field_localname = @r_localname_field,
                                @@tab_table = @r_table_tab,
                                @@tab_name = @r_name_tab,
                                @@tab_localname = @r_localname_tab,
                                @@failexistingfield = @fail_if_relation_exist,
                                @@messagetext = @message OUTPUT,
                                @@idfieldfield = @idfieldfield OUTPUT,
                                @@idfieldtab = @idfieldtab OUTPUT

                            PRINT @message

                            IF ISNULL(@idfieldfield, 0) > 0
                                AND ISNULL(@idfieldtab, 0) > 0
                                BEGIN
                                    SET @noofaddedrelations = @noofaddedrelations
                                        + 1
                                    PRINT REPLICATE(CHAR(13), 1)
                                        + N'- ADDED @idfield(field) = '
                                        + CAST(@idfieldfield AS NVARCHAR(32))
                                    PRINT REPLICATE(CHAR(13), 1)
                                        + N'- ADDED @idfield(tab) = '
                                        + CAST(@idfieldtab AS NVARCHAR(32))
						-- REMOVE 1 since always added
                                    SET @notaddedrelations = @notaddedrelations
                                        - 1
                                END
                        END
						-- ALWAYS ADD 1 (Removed if relation is created)
                    SET @notaddedrelations = @notaddedrelations + 1

                    UPDATE  @temp_relation_one_to_many
                    SET     [processed] = 1
                    WHERE   [id] = @r_id

                    FETCH NEXT FROM relationcursor INTO @r_id, @r_table_field,
                        @r_name_field, @r_localname_field, @r_table_tab,
                        @r_name_tab, @r_localname_tab

                END
            CLOSE relationcursor
            DEALLOCATE relationcursor


            DECLARE @o_id INT
            DECLARE @o_table NVARCHAR(64)
            DECLARE @o_field NVARCHAR(64)
            DECLARE @o_optiontext NVARCHAR(MAX)
            DECLARE @o_key NVARCHAR(256)
			DECLARE @o_default INT
			DECLARE @o_color INT

            DECLARE @idstring INT

            DECLARE optioncursor CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
            FOR
                SELECT  [id] ,
                        [table] ,
                        field ,
                        [optiontext] ,
                        [key],
						[default],
						[color]
                FROM    @temp_option
                WHERE   [processed] IS NULL
                ORDER BY [id] ASC

			
            OPEN optioncursor
            FETCH NEXT FROM optioncursor INTO @o_id, @o_table, @o_field,
                @o_optiontext, @o_key,@o_default,@o_color
            WHILE @@FETCH_STATUS = 0
                BEGIN
            

                    IF @returnvalue = 0
                        BEGIN
							
                            SET @idstring = NULL
                            SET @message = N''

                            EXECUTE @returnvalue = [dbo].[csp_garcon_scriptfield_addoption] @@tablename = @o_table,
                                @@fieldname = @o_field,
                                @@localname = @o_optiontext, @@key = @o_key,
                                @@failexistingoption = @fail_if_option_exist,
                                @@idstring = @idstring OUTPUT,
                                @@messagetext = @message OUTPUT,
								@@default = @o_default,
								@@color = @o_color

                            PRINT @message
                            
                            IF ISNULL(@idstring, 0) > 0
                                BEGIN
                                    SET @noofaddedoptions = @noofaddedoptions
                                        + 1
                                    PRINT REPLICATE(CHAR(13), 1)
                                        + N'- ADDED @idstring = '
                                        + CAST(@idstring AS NVARCHAR(32))
							-- REMOVE 1 since always added
                                    SET @notaddedoptions = @notaddedoptions
                                        - 1
                                END
                        END
						-- ALWAYS ADD 1 (Removed if table is created)
                    SET @notaddedoptions = @notaddedoptions + 1

                    UPDATE  @temp_option
                    SET     [processed] = 1
                    WHERE   [id] = @o_id

                    FETCH NEXT FROM optioncursor INTO @o_id, @o_table,
                        @o_field, @o_optiontext, @o_key,@o_default,@o_color
                END
            CLOSE optioncursor
            DEALLOCATE optioncursor

            PRINT REPLICATE(N'#', 15)
            PRINT N'ANTAL TABELLER: ' + CAST(@totaltables AS NVARCHAR(32)) 
            PRINT N'ANTAL FÄLT: ' + CAST(@totalfields AS NVARCHAR(32)) 
            PRINT N'ANTAL RELATIONER: '
                + CAST(@totalrelations AS NVARCHAR(32)) 
            PRINT N'ANTAL ALTERNATIV: ' + CAST(@totaloptions AS NVARCHAR(32)) 
            PRINT REPLICATE(N'-', 15)
            PRINT N'ANTAL NYA TABELLER: '
                + CAST(@noofaddedtables AS NVARCHAR(32)) 
            PRINT N'ANTAL NYA FÄLT: ' + CAST(@noofaddedfields AS NVARCHAR(32)) 
            PRINT N'ANTAL NYA RELATIONER: '
                + CAST(@noofaddedrelations AS NVARCHAR(32)) 
            PRINT N'ANTAL NYA ALTERNATIV: '
                + CAST(@noofaddedoptions AS NVARCHAR(32)) 
            PRINT REPLICATE(N'-', 15)
            PRINT N'ANTAL EJ SKAPADE TABELLER: '
                + CAST(@notaddedtables AS NVARCHAR(32)) 
            PRINT N'ANTAL EJ SKAPADE FÄLT: '
                + CAST(@notaddedfields AS NVARCHAR(32)) 
            PRINT N'ANTAL EJ SKAPADE RELATIONER: '
                + CAST(@notaddedrelations AS NVARCHAR(32)) 
            PRINT N'ANTAL EJ SKAPADE ALTERNATIV: '
                + CAST(@notaddedoptions AS NVARCHAR(32)) 
            PRINT REPLICATE(N'#', 15)


            IF @returnvalue = 0
                BEGIN
                    PRINT N'ALLT KLART :-)'
                    PRINT N'COMMIT TRANSACTION'
                    COMMIT TRANSACTION script_field
                END
            ELSE
                BEGIN 
                    PRINT @message
                    PRINT N'DETTA GICK INTE BRA :-('
                    PRINT 'ROLLBACK TRANSACTION'
                    ROLLBACK TRANSACTION script_field
                END
        END TRY
        BEGIN CATCH
            PRINT ERROR_MESSAGE()
            PRINT N'DETTA GICK INTE BRA :-('
            PRINT 'ROLLBACK TRANSACTION'
            ROLLBACK TRANSACTION script_field
        END CATCH

        IF @returnvalue = 0
            EXEC dbo.lsp_refreshldc

    END