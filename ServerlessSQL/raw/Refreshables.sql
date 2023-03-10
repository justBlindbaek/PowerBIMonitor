USE [powerbimonitor]
GO

CREATE OR ALTER VIEW [raw].[Refreshables] AS

SELECT
  Id,
  Name,
  Kind,
  RefreshStartTime,
  RefreshEndTime,
  RefreshCount,
  RefreshFailures,
  RefreshAverageDuration,
  RefreshMedianDuration,
  RefreshesPerDay,
  LastRefreshId,
  LastRefreshType,
  LastRefreshStartTime,
  LastRefreshEndTime,
  LastRefreshServiceExceptionJson,
  LastRefreshStatus,
  LastRefreshRequestId,
  RefreshScheduleDays,
  RefreshScheduleTimes,
  RefreshScheduleEnabled,
  RefreshScheduleLocalTimeZoneId,
  RefreshScheduleNotifyOption,
  ConfiguredBy,
  CapacityId,
  CapacityName,
  CapacitySku,
  WorkspaceId,
  WorkspaceName, 
  CAST(rows.filepath(1) AS INT) AS ExtractYear, 
  CAST(rows.filepath(2) AS INT) AS ExtractMonth, 
  CAST(LEFT(RIGHT(CAST(rows.filepath(3) AS VARCHAR(50)),13),8) AS DATE) AS ExtractDate, 
  ADF_PipelineRunId
FROM
  OPENROWSET(
    BULK 'https://[StorageAccountName].dfs.core.windows.net/raw/powerbi-tenant/refreshables/year=*/month=*/*', 
    FORMAT = 'CSV',
    FIELDQUOTE = '0x0b',
    FIELDTERMINATOR ='0x0b',
    ROWTERMINATOR = '0x0b'
  ) WITH (
     jsonContent varchar(MAX)
  ) AS [rows] CROSS APPLY openjson (jsonContent) WITH (
    value NVARCHAR(MAX) AS JSON, 
    ADF_PipelineRunId VARCHAR(50) '$.DW_PipelineRunId'
  ) CROSS APPLY openjson (value) WITH (
    Id VARCHAR(50) '$.id',
    Name VARCHAR(50) '$.name',
    Kind VARCHAR(50) '$.kind',
    RefreshStartTime DATETIME2 '$.startTime',
    RefreshEndTime DATETIME2 '$.endTime',
    RefreshCount INT '$.refreshCount',
    RefreshFailures INT '$.refreshFailures',
    RefreshAverageDuration DECIMAL(10,4) '$.averageDuration',
    RefreshMedianDuration DECIMAL(10,4) '$.medianDuration',
    RefreshesPerDay INT '$.refreshesPerDay',
    LastRefreshId BIGINT '$.lastRefresh.id',
    LastRefreshType VARCHAR(50) '$.lastRefresh.refreshType',
    LastRefreshStartTime DATETIME2 '$.lastRefresh.startTime',
    LastRefreshEndTime DATETIME2 '$.lastRefresh.endTime',
    LastRefreshServiceExceptionJson NVARCHAR(MAX) '$.lastRefresh.serviceExceptionJson',
    LastRefreshStatus VARCHAR(50) '$.lastRefresh.status',
    LastRefreshRequestId VARCHAR(50) '$.lastRefresh.requestId',
    LastRefreshExtendedStatus VARCHAR(50) '$.lastRefresh.extendedStatus',
    RefreshScheduleDays NVARCHAR(MAX) '$.refreshSchedule.days' AS JSON,
    RefreshScheduleTimes NVARCHAR(MAX) '$.refreshSchedule.times' AS JSON,
    RefreshScheduleEnabled BIT '$.refreshSchedule.enabled',
    RefreshScheduleLocalTimeZoneId VARCHAR(50) '$.refreshSchedule.localTimeZoneId',
    RefreshScheduleNotifyOption VARCHAR(50) '$.refreshSchedule.notifyOption',
    ConfiguredBy VARCHAR(50) '$.configuredBy[0]',
    CapacityId VARCHAR(50) '$.capacity.id',
    CapacityName VARCHAR(50) '$.capacity.displayName',
    CapacitySku VARCHAR(50) '$.capacity.sku',
    WorkspaceId VARCHAR(50) '$.group.id',
    WorkspaceName VARCHAR(50) '$.group.name'
  )