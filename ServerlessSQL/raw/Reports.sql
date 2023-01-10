DROP VIEW IF EXISTS [raw].[Reports]
GO

CREATE VIEW [raw].[Reports] AS

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
  UserPrincipalType --,CAST(rows.filepath(1) AS varchar(4)) AS ExtractYear
  --,CAST(rows.filepath(2) AS varchar(2)) AS ExtractMonth
  --,LEFT(RIGHT(CAST(rows.filepath(3) AS varchar(50)),7),2) AS ExtractDay
  , 
  CAST(LEFT(RIGHT(CAST(rows.filepath(3) AS varchar(50)), 13), 8) AS DATE) AS ExtractDate 
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
    reports NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (reports) WITH (
    ReportType varchar(255) '$.reportType', 
    ReportId varchar(255) '$.id', 
    ReportName varchar(255) '$.name', 
    DatasetId varchar(255) '$.datasetId', 
    CreatedDateTime datetime '$.createdDateTime', 
    CreatedBy varchar(100) '$.createdBy', 
    ModifiedBy varchar(100) '$.modifiedBy', 
    ModifiedDateTime datetime '$.modifiedDateTime', 
    Endorsement varchar(100) '$.endorsementDetails.endorsement', 
    CertifiedBy varchar(100) '$.endorsementDetails.certifiedBy', 
    AppId varchar(100) '$.appId', 
    users NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (users) WITH (
    UserAccessRight varchar(100) '$.reportUserAccessRight', 
    UserIdentifier varchar(100) '$.identifier', 
    UserPrincipalType varchar(100) '$.principalType'
  )