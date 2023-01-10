USE [powerbimonitor]
GO

DROP VIEW IF EXISTS [raw].[DatasourceInstances]
GO

CREATE VIEW [raw].[DatasourceInstances] AS

SELECT 
  DatasourceId, 
  DatasourceType, 
  GatewayId, 
  ConnectionDetailsServer, 
  ConnectionDetailsDatabase, 
  ConnectionDetailsPath, 
  ConnectionDetailsUrl --,CAST(rows.filepath(1) AS varchar(4)) AS ExtractYear
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
    datasourceInstances NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (datasourceInstances) WITH (
    DatasourceType VARCHAR(50) '$.datasourceType', 
    ConnectionDetailsServer VARCHAR(100) '$.connectionDetails.server', 
    ConnectionDetailsDatabase VARCHAR(50) '$.connectionDetails.database', 
    ConnectionDetailsPath VARCHAR(255) '$.connectionDetails.path', 
    ConnectionDetailsUrl VARCHAR(255) '$.connectionDetails.url', 
    DatasourceId VARCHAR(50) '$.datasourceId', 
    GatewayId VARCHAR(50) '$.gatewayId'
  )