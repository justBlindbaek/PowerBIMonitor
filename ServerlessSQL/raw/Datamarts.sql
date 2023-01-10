USE [powerbimonitor]
GO

DROP VIEW IF EXISTS [raw].[Datamarts]
GO

CREATE VIEW [raw].[Datamarts] AS

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
    datamarts NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (datamarts) WITH (
    DatamartId varchar(100) '$.objectId', 
    DatamartName varchar(100) '$.name', 
    DatamartType varchar(100) '$.type', 
    DatamartDescription varchar(255) '$.description', 
    DatamartConfiguredBy varchar(100) '$.configuredBy', 
    DatamartModifiedBy varchar(100) '$.modifiedBy', 
    DatamartModifiedDate datetime '$.modifiedDateTime', 
    DatamartEndorsement varchar(100) '$.endorsementDetails.endorsement', 
    DatamartCertifiedBy varchar(100) '$.endorsementDetails.certifiedBy', 
    SensitivityLabelId varchar(100) '$.sensitivityLabel.labelId', 
    DatasourceInstanceId varchar(100) '$.datasourceUsages[0].datasourceInstanceId', 
    users NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (users) WITH (
    UserAccessRight varchar(100) '$.datamartUserAccessRight', 
    UserIdentifier varchar(100) '$.identifier', 
    UserPrincipalType varchar(100) '$.principalType'
  )