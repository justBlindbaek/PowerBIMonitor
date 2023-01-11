USE [powerbimonitor]
GO

CREATE OR ALTER VIEW [raw].[DashboardTiles] AS

SELECT 
  DashboardId, 
  DashboardName, 
  TitlId, 
  TileTitle, 
  TileReportId, 
  TileDatasetId, 
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
    dashboards NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (dashboards) WITH (
    DashboardId VARCHAR(50) '$.id', 
    DashboardName VARCHAR(255) '$.displayName', 
    tiles NVARCHAR(MAX) AS JSON
  ) CROSS APPLY openjson (tiles) WITH (
    TileId VARCHAR(50) '$.id', 
    TileTitle VARCHAR(200) '$.title', 
    TileReportId VARCHAR(50) '$.reportId',
    TileDatasetId VARCHAR(50) '$.datasetId'
  )