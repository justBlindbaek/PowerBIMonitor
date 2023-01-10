USE [powerbimonitor]
GO

DROP VIEW IF EXISTS [raw].[ActivityEvents]
GO

CREATE VIEW [raw].[ActivityEvents] AS

SELECT 
  ActivityEventId, 
  CreationTime, 
  Operation, 
  OrganizationId, 
  UserKey, 
  Activity, 
  Workload, 
  UserId, 
  ClientIP --,CAST(rows.filepath(1) AS varchar(4)) AS EventYear
  --,CAST(rows.filepath(2) AS varchar(2)) AS EventMonth
  --,LEFT(RIGHT(CAST(rows.filepath(3) AS varchar(50)),7),2) AS EventDay
  --,CAST(LEFT(RIGHT(CAST(rows.filepath(3) AS varchar(50)),13),8) AS DATE) AS EventDate
FROM 
  OPENROWSET(
    BULK 'https://[StorageAccountName].dfs.core.windows.net/raw/powerbi-tenant/activityevents/year=*/month=*/*', 
    FORMAT = 'CSV', FIELDQUOTE = '0x0b', 
    FIELDTERMINATOR = '0x0b', ROWTERMINATOR = '0x0b'
  ) WITH (
    jsonContent varchar(MAX)
  ) AS [rows] CROSS APPLY openjson (jsonContent) WITH (
    activityEventEntities NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (activityEventEntities) WITH (
    ActivityEventId VARCHAR(50) '$.Id', 
    CreationTime DATETIME '$.CreationTime', 
    Operation VARCHAR(50) '$.Operation', 
    OrganizationId VARCHAR(50) '$.OrganizationId', 
    UserKey VARCHAR(50) '$.UserKey', 
    Activity VARCHAR(50) '$.Activity', 
    Workload VARCHAR(50) '$.Workload', 
    UserId VARCHAR(50) '$.UserId', 
    ClientIP VARCHAR(50) '$.ClientIP'
  )
