USE [powerbimonitor]
GO

CREATE OR ALTER VIEW [raw].[Workspaces] AS

SELECT 
  WorkspaceId, 
  WorkspaceType, 
  WorkspaceName, 
  WorkspaceDescription, 
  WorkspaceState, 
  CapacityId, 
  DataRetrievalState, 
  UserAccessRight, 
  UserIdentifier, 
  UserPrincipalType, 
  CAST(CAST(rows.filepath(1) AS VARCHAR(4)) AS INT) AS ExtractYear, 
  CAST(CAST(rows.filepath(2) AS VARCHAR(2)) AS INT) AS ExtractMonth, 
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
    WorkspaceName VARCHAR(50) '$.name', 
    WorkspaceDescription VARCHAR(50) '$.description', 
    WorkspaceType VARCHAR(50) '$.type', 
    WorkspaceState VARCHAR(50) '$.state', 
    DataRetrievalState VARCHAR(100) '$.dataRetrievalState', 
    CapacityId VARCHAR(50) '$.capacityId', 
    users NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (users) WITH (
    UserAccessRight VARCHAR(100) '$.groupUserAccessRight', 
    UserIdentifier VARCHAR(100) '$.identifier', 
    UserPrincipalType VARCHAR(100) '$.principalType'
  )