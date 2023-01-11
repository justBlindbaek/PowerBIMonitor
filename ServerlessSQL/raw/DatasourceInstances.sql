USE [powerbimonitor]
GO

CREATE OR ALTER VIEW [raw].[DatasourceInstances] AS

SELECT 
  DatasourceId, 
  DatasourceType, 
  GatewayId, 
  ConnectionDetailsServer, 
  ConnectionDetailsDatabase, 
  ConnectionDetailsPath, 
  ConnectionDetailsUrl,
  ConnectionDetailsKind, 
  ConnectionDetailsAccount, 
  ConnectionDetailsDomain, 
  ConnectionDetailsClassInfo, 
  ConnectionDetailsLoginServer, 
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
    datasourceInstances NVARCHAR(MAX) AS JSON, 
    ADF_PipelineRunId VARCHAR(50) '$.ADF_PipelineRunId'
  ) CROSS APPLY openjson (datasourceInstances) WITH (
    DatasourceType VARCHAR(50) '$.datasourceType', 
    ConnectionDetailsServer VARCHAR(100) '$.connectionDetails.server', 
    ConnectionDetailsDatabase VARCHAR(50) '$.connectionDetails.database', 
    ConnectionDetailsPath VARCHAR(255) '$.connectionDetails.path', 
    ConnectionDetailsKind VARCHAR(255) '$.connectionDetails.kind', 
    ConnectionDetailsUrl VARCHAR(255) '$.connectionDetails.url', 
    ConnectionDetailsAccount VARCHAR(255) '$.connectionDetails.account', 
    ConnectionDetailsDomain VARCHAR(255) '$.connectionDetails.domain', 
    ConnectionDetailsEmailAddress VARCHAR(255) '$.connectionDetails.emailAddress', 
    ConnectionDetailsClassInfo VARCHAR(255) '$.connectionDetails.classInfo', 
    ConnectionDetailsLoginServer VARCHAR(255) '$.connectionDetails.loginServer', 
    DatasourceId VARCHAR(50) '$.datasourceId', 
    GatewayId VARCHAR(50) '$.gatewayId'
  )