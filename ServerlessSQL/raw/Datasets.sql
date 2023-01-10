USE [powerbimonitor]
GO

DROP VIEW IF EXISTS [raw].[Datasets]
GO

CREATE VIEW [raw].[Datasets] AS

SELECT 
  WorkspaceId, 
  DatasetId, 
  DatasetName, 
  DatasetConfiguredBy, 
  DatasetTargetStorageMode, 
  DatasetCreatedDate, 
  DatasetDescription, 
  ContentProviderType, 
  DatasetEndorsement, 
  DatasetCertifiedBy, 
  DatasourceInstanceId, 
  SchemaRetrievalError, 
  UserIdentifier, 
  UserAccessRight, 
  UserPrincipalType --,CAST(rows.filepath(1) AS varchar(4)) AS ExtractYear
  --,CAST(rows.filepath(2) AS varchar(2)) AS ExtractMonth
  --,LEFT(RIGHT(CAST(rows.filepath(3) AS varchar(50)),7),2) AS ExtractDay
  ,CAST(LEFT(RIGHT(CAST(rows.filepath(3) AS varchar(50)),13),8) AS DATE) AS ExtractDate
FROM 
  OPENROWSET(
    BULK 'https://[StorageAccountName].dfs.core.windows.net/raw/powerbi-tenant/workspaceinfo/year=*/month=*/*', 
    FORMAT = 'CSV', FIELDQUOTE = '0x0b', 
    FIELDTERMINATOR = '0x0b'
  ) WITH (
    jsonContent varchar(MAX)
  ) AS [rows] CROSS APPLY openjson (jsonContent) WITH (
    workspaces NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (workspaces) WITH (
    WorkspaceId VARCHAR(50) '$.id', 
    datasets NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (datasets) WITH (
    DatasetId varchar(100) '$.id', 
    DatasetName varchar(100) '$.name', 
    DatasetConfiguredBy varchar(100) '$.configuredBy', 
    DatasetTargetStorageMode varchar(100) '$.targetStorageMode', 
    DatasetCreatedDate datetime '$.createdDate', 
    ContentProviderType varchar(255) '$.contentProviderType', 
    DatasetEndorsement varchar(100) '$.endorsementDetails.endorsement', 
    DatasetCertifiedBy varchar(100) '$.endorsementDetails.certifiedBy', 
    DatasourceInstanceId varchar(100) '$.datasourceUsages[0].datasourceInstanceId', 
    SchemaRetrievalError varchar(100) '$.schemaRetrievalError', 
    DatasetDescription varchar(100) '$.description', 
    users NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (users) WITH (
    UserAccessRight varchar(100) '$.datasetUserAccessRight', 
    UserIdentifier varchar(100) '$.identifier', 
    UserPrincipalType varchar(100) '$.principalType'
  )