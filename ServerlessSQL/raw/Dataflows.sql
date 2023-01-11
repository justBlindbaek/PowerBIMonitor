USE [powerbimonitor]
GO

CREATE OR ALTER VIEW [raw].[Dataflows] AS

SELECT 
  WorkspaceId, 
  DataflowId, 
  DataflowName, 
  DataflowDescription,
  DataflowConfiguredBy,
  DataflowModifiedBy,
  DataflowModifiedDate, 
  DataflowEndorsement, 
  DataflowCertifiedBy, 
  DatasourceInstanceId, 
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
    dataflows NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (dataflows) WITH (
    DataflowId VARCHAR(50) '$.objectId', 
    DataflowName VARCHAR(100) '$.name', 
    DataflowDescription VARCHAR(255) '$.description', 
    DataflowConfiguredBy VARCHAR(100) '$.configuredBy', 
    DataflowModifiedBy VARCHAR(100) '$.modifiedBy', 
    DataflowModifiedDate DATETIME '$.modifiedDateTime', 
    DataflowEndorsement VARCHAR(100) '$.endorsementDetails.endorsement', 
    DataflowCertifiedBy VARCHAR(100) '$.endorsementDetails.certifiedBy', 
    DatasourceInstanceId VARCHAR(50) '$.datasourceUsages[0].datasourceInstanceId', 
    users NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (users) WITH (
    UserAccessRight VARCHAR(100) '$.dataflowUserAccessRight', 
    UserIdentifier VARCHAR(100) '$.identifier', 
    UserPrincipalType VARCHAR(100) '$.principalType'
  )