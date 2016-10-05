-- ---------------------------------------------------------------------
-- Script to create the localize records needed in Lime CRM Sales Board.
-- ---------------------------------------------------------------------


-- Insert new records
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us, da, [no], fi) SELECT 0,1,1, N'App_LimeCRMSalesBoard', N'tooltipFilter', N'Tooltip shown when hovering over warning icon that appears when the list has been fast filtered.', N'Listan är filtrerad!', N'The list is filtered!', N'The list is filtered!', N'The list is filtered!', N'The list is filtered!'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us, da, [no], fi) SELECT 0,1,1, N'App_LimeCRMSalesBoard', N'openLimeCRMSalesBoard', N'Text in link to open Lime CRM Sales 	Board.', N'Visa i Lime CRM Sales Board', N'Show in Lime CRM Sales Board', N'Show in Lime CRM Sales Board', N'Show in Lime CRM Sales Board', N'Show in Lime CRM Sales Board'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us, da, [no], fi) SELECT 0,1,1, N'App_LimeCRMSalesBoard', N'notActivated', N'Text shown in Lime CRM Sales Board when the tab is not set up for using Lime CRM Sales Board.', N'Den aktuella fliken är inte konfigurerad för Lime CRM Sales Board.', N'The current tab is not configured to use Lime CRM Sales Board.', N'The current tab is not configured to use Lime CRM Sales Board.', N'The current tab is not configured to use Lime CRM Sales Board.', N'The current tab is not configured to use Lime CRM Sales Board.'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us, da, [no], fi) SELECT 0,1,1, N'App_LimeCRMSalesBoard', N'btnRefresh', N'Text on refresh buttons.', N'Uppdatera', N'Refresh', N'Refresh', N'Refresh', N'Refresh'
INSERT INTO localize ([status], createduser, updateduser, [owner], code, context, sv, en_us, da, [no], fi) SELECT 0,1,1, N'App_LimeCRMSalesBoard', N'boardtitleSumLabel', N'Label before the positive summation.', N'totalt', N'in total', N'in total', N'in total', N'in total'


-- Run onsqlupdate on complete localize table.
DECLARE @sql NVARCHAR(MAX)
SET @sql = ''
SELECT @sql = @sql + ', [' + f.[name] + '] = (' + a.[value] + ')' + CHAR(10) FROM [attributedata] AS a
             INNER JOIN [field] AS f ON a.[idrecord] = f.[idfield]
             INNER JOIN [table] AS t ON f.[idtable] = t.[idtable]
                  WHERE a.[owner] = 'field'
                  AND [a].[name] ='onsqlupdate'
                  AND t.[name] = 'localize'

SET @sql = 'UPDATE [localize] SET [status] = [status] ' + @sql
SET @sql = @sql + ' WHERE [status] = 0'

EXEC(@sql)
