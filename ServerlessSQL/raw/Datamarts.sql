USE [powerbimonitor]
GO

CREATE OR ALTER VIEW [raw].[Datamarts] AS

SELECT 
  WorkspaceId, 
  DatamartId, 
  DatamartName, 
  DatamartType, 
  DatamartDescription,
  DatamartConfiguredBy,
  DatamartModifiedBy,
  DatamartModifiedDate, 
  DatamartEndorsement, 
  DatamartCertifiedBy,
  SensitivityLabelId, 
  DatasourceInstanceId, 
  UserIdentifier, 
  UserAccessRight, 
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
    datamarts NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (datamarts) WITH (
    DatamartId VARCHAR(50) '$.objectId', 
    DatamartName VARCHAR(100) '$.name', 
    DatamartType VARCHAR(100) '$.type', 
    DatamartDescription VARCHAR(255) '$.description', 
    DatamartConfiguredBy VARCHAR(100) '$.configuredBy', 
    DatamartModifiedBy VARCHAR(100) '$.modifiedBy', 
    DatamartModifiedDate DATETIME '$.modifiedDateTime', 
    DatamartEndorsement VARCHAR(100) '$.endorsementDetails.endorsement', 
    DatamartCertifiedBy VARCHAR(100) '$.endorsementDetails.certifiedBy', 
    SensitivityLabelId VARCHAR(50) '$.sensitivityLabel.labelId', 
    DatasourceInstanceId VARCHAR(100) '$.datasourceUsages[0].datasourceInstanceId', 
    users NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (users) WITH (
    UserAccessRight VARCHAR(100) '$.datamartUserAccessRight', 
    UserIdentifier VARCHAR(100) '$.identifier', 
    UserPrincipalType VARCHAR(100) '$.principalType'
  )