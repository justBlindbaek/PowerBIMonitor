USE [powerbimonitor]
GO

CREATE OR ALTER VIEW [raw].[Reports] AS

SELECT 
  WorkspaceId, 
  ReportId, 
  ReportName, 
  ReportType, 
  DatasetId, 
  AppId, 
  CreatedBy, 
  CreatedDateTime, 
  ModifiedBy, 
  ModifiedDateTime, 
  Endorsement, 
  CertifiedBy, 
  UserAccessRight, 
  UserIdentifier, 
  UserPrincipalType, 
  CAST(rows.filepath(1) AS INT) AS ExtractYear, 
  CAST(rows.filepath(2) AS INT) AS ExtractMonth, 
  CAST(LEFT(RIGHT(CAST(rows.filepath(3) AS VARCHAR(50)),13),8) AS DATE) AS ExtractDate, 
  ADF_PipelineRunId
FROM 
  OPENROWSET(
    BULK 'https://[StorageAccountName].dfs.core.windows.net/raw/powerbi-tenant/workspaceinfo/year=*/month=*/*', 
    FORMAT = 'CSV', 
	FIELDQUOTE = '0x0b', 
    FIELDTERMINATOR = '0x0b'
  ) WITH (
    jsonContent VARCHAR(MAX)
  ) AS [rows] CROSS APPLY openjson (jsonContent) WITH (
    workspaces NVARCHAR(MAX) AS JSON, 
    ADF_PipelineRunId VARCHAR(50) '$.ADF_PipelineRunId'
  ) CROSS APPLY openjson (workspaces) WITH (
    WorkspaceId VARCHAR(50) '$.id', 
    reports NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (reports) WITH (
    ReportType VARCHAR(255) '$.reportType', 
    ReportId VARCHAR(50) '$.id', 
    ReportName VARCHAR(255) '$.name', 
    DatasetId VARCHAR(50) '$.datasetId', 
    CreatedDateTime DATETIME '$.createdDateTime', 
    CreatedBy VARCHAR(100) '$.createdBy', 
    ModifiedBy VARCHAR(100) '$.modifiedBy', 
    ModifiedDateTime DATETIME '$.modifiedDateTime', 
    Endorsement VARCHAR(100) '$.endorsementDetails.endorsement', 
    CertifiedBy VARCHAR(100) '$.endorsementDetails.certifiedBy', 
    AppId VARCHAR(50) '$.appId', 
    users NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (users) WITH (
    UserAccessRight VARCHAR(100) '$.reportUserAccessRight', 
    UserIdentifier VARCHAR(100) '$.identifier', 
    UserPrincipalType VARCHAR(100) '$.principalType'
  )