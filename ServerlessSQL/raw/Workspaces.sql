DROP VIEW IF EXISTS [raw].[Workspaces]
GO

CREATE VIEW [raw].[Workspaces] AS

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
    WorkspaceName VARCHAR(50) '$.name', 
    WorkspaceDescription VARCHAR(50) '$.description', 
    WorkspaceType VARCHAR(50) '$.type', 
    WorkspaceState VARCHAR(50) '$.state', 
    DataRetrievalState VARCHAR(100) '$.dataRetrievalState', 
    CapacityId VARCHAR(100) '$.capacityId', 
    users NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (users) WITH (
    UserAccessRight varchar(100) '$.groupUserAccessRight', 
    UserIdentifier varchar(100) '$.identifier', 
    UserPrincipalType varchar(100) '$.principalType'
  )