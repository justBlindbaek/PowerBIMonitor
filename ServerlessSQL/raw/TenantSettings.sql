USE [powerbimonitor]
GO

CREATE OR ALTER VIEW [raw].[TenantSettings] AS

SELECT 
  settingName, 
  title, 
  tenantSettingGroup, 
  enabled, 
  canSpecifySecurityGroups, 
  propertiesName, 
  propertiesValue, 
  propertiesType, 
  enabledSecurityGroupsGraphId, 
  enabledSecurityGroupsName,
  excludedSecurityGroupsGraphId, 
  excludedSecurityGroupsName,
  CAST(rows.filepath(1) AS INT) AS ExtractYear, 
  CAST(rows.filepath(2) AS INT) AS ExtractMonth, 
  CAST(LEFT(RIGHT(CAST(rows.filepath(3) AS VARCHAR(50)),13),8) AS DATE) AS ExtractDate, 
  ADF_PipelineRunId
FROM 
  OPENROWSET(
    BULK 'https://[StorageAccountName].dfs.core.windows.net/raw/powerbi-tenant/tenantsettings/year=*/month=*/*', 
    FORMAT = 'CSV', 
    FIELDQUOTE = '0x0b', 
    FIELDTERMINATOR = '0x0b', 
    ROWTERMINATOR = '0x0b'
  ) WITH (
    jsonContent VARCHAR(MAX)
  ) AS [rows] CROSS APPLY openjson (jsonContent) WITH (
    tenantSettings NVARCHAR(MAX) AS JSON, 
    ADF_PipelineRunId VARCHAR(50) '$.ADF_PipelineRunId'
  ) CROSS APPLY openjson (tenantSettings) WITH (
    settingName VARCHAR(50) '$.settingName', 
    title VARCHAR(255) '$.title', 
    tenantSettingGroup VARCHAR(50) '$.tenantSettingGroup', 
    enabled BIT '$.enabled', 
    canSpecifySecurityGroups BIT '$.canSpecifySecurityGroups', 
    enabledSecurityGroups NVARCHAR(MAX) '$.enabledSecurityGroups' AS JSON,
    excludedSecurityGroups NVARCHAR(MAX) '$.excludedSecurityGroups' AS JSON,
    properties NVARCHAR(MAX) '$.properties' AS JSON
  ) OUTER APPLY openjson (properties) WITH (
    propertiesName VARCHAR(50) '$.name', 
    propertiesValue VARCHAR(50) '$.value', 
    propertiesType VARCHAR(50) '$.type'
  ) OUTER APPLY openjson (enabledSecurityGroups) WITH (
    enabledSecurityGroupsGraphId VARCHAR(50) '$.graphId', 
    enabledSecurityGroupsName VARCHAR(50) '$.name'
  ) OUTER APPLY openjson (excludedSecurityGroups) WITH (
    excludedSecurityGroupsGraphId VARCHAR(50) '$.graphId', 
    excludedSecurityGroupsName VARCHAR(50) '$.name'
  )