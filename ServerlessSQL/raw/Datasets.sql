USE [powerbimonitor]
GO

CREATE OR ALTER VIEW [raw].[Datasets] AS

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
  UserPrincipalType, 
  CAST(rows.filepath(1) AS INT) AS ExtractYear, 
  CAST(rows.filepath(2) AS INT) AS ExtractMonth, 
  CAST(LEFT(RIGHT(CAST(rows.filepath(3) AS VARCHAR(50)),13),8) AS DATE) AS ExtractDate, 
  ADF_PipelineRunId
FROM 
  OPENROWSET(
    BULK 'https://[StorageAccountName].dfs.core.windows.net/raw/powerbi-tenant/workspaceinfo/year=*/month=*/*', 
    FORMAT = 'CSV', FIELDQUOTE = '0x0b', 
    FIELDTERMINATOR = '0x0b'
  ) WITH (
    jsonContent VARCHAR(MAX)
  ) AS [rows] CROSS APPLY openjson (jsonContent) WITH (
    workspaces NVARCHAR(MAX) AS JSON, 
    ADF_PipelineRunId VARCHAR(50) '$.ADF_PipelineRunId'
  ) CROSS APPLY openjson (workspaces) WITH (
    WorkspaceId VARCHAR(50) '$.id', 
    datasets NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (datasets) WITH (
    DatasetId VARCHAR(50) '$.id', 
    DatasetName VARCHAR(100) '$.name', 
    DatasetConfiguredBy VARCHAR(100) '$.configuredBy', 
    DatasetTargetStorageMode VARCHAR(100) '$.targetStorageMode', 
    DatasetCreatedDate DATETIME '$.createdDate', 
    ContentProviderType VARCHAR(255) '$.contentProviderType', 
    DatasetEndorsement VARCHAR(100) '$.endorsementDetails.endorsement', 
    DatasetCertifiedBy VARCHAR(100) '$.endorsementDetails.certifiedBy', 
    DatasourceInstanceId VARCHAR(50) '$.datasourceUsages[0].datasourceInstanceId', 
    SchemaRetrievalError VARCHAR(100) '$.schemaRetrievalError', 
    DatasetDescription VARCHAR(100) '$.description', 
    users NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (users) WITH (
    UserAccessRight VARCHAR(100) '$.datasetUserAccessRight', 
    UserIdentifier VARCHAR(100) '$.identifier', 
    UserPrincipalType VARCHAR(100) '$.principalType'
  )