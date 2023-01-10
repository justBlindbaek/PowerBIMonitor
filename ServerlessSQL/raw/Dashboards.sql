USE [powerbimonitor]
GO

DROP VIEW IF EXISTS [raw].[Dashboards]
GO

CREATE VIEW [raw].[Dashboards] AS

SELECT 
  DashboardId, 
  DashboardName, 
  IsReadOnly, 
  UserAccessRight, 
  UserIdentifier, 
  UserPrincipalType --,CAST(rows.filepath(1) AS varchar(4)) AS ExtractYear
  --,CAST(rows.filepath(2) AS varchar(2)) AS ExtractMonth
  --,LEFT(RIGHT(CAST(rows.filepath(3) AS varchar(50)),7),2) AS ExtractDay
  , CAST(LEFT(RIGHT(CAST(rows.filepath(3) AS varchar(50)), 13), 8) AS DATE) AS ExtractDate 
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
    dashboards NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (dashboards) WITH (
    DashboardId varchar(255) '$.id', 
    DashboardName varchar(255) '$.displayName', 
    IsReadOnly BIT '$.isReadOnly', 
    users NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (users) WITH (
    UserAccessRight varchar(100) '$.dashboardUserAccessRight', 
    UserIdentifier varchar(100) '$.identifier', 
    UserPrincipalType varchar(100) '$.principalType'
  )