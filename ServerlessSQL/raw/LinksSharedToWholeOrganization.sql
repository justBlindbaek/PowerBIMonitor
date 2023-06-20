USE [powerbimonitor]
GO

CREATE OR ALTER VIEW [raw].[PublishedToWeb] AS

SELECT 
  ArtifactId, 
  DisplayName, 
  ArtifactType, 
  AccessRight, 
  ShareType, 
  SharerEmailAddress, 
  SharerDisplayName, 
  SharerIdentifier, 
  SharerGraphId, 
  SharerPrincipalType, 
  CAST(rows.filepath(1) AS INT) AS ExtractYear, 
  CAST(rows.filepath(2) AS INT) AS ExtractMonth, 
  CAST(LEFT(RIGHT(CAST(rows.filepath(3) AS VARCHAR(60)),13),8) AS DATE) AS ExtractDate, 
  ADF_PipelineRunId
FROM 
  OPENROWSET(
    BULK 'https://[StorageAccountName].dfs.core.windows.net/raw/powerbi-tenant/linksSharedToWholeOrganization/year=*/month=*/*', 
    FORMAT = 'CSV', 
    FIELDQUOTE = '0x0b', 
    FIELDTERMINATOR = '0x0b', 
    ROWTERMINATOR = '0x0b'
  ) WITH (
    jsonContent VARCHAR(MAX)
  ) AS [rows] CROSS APPLY openjson (jsonContent) WITH (
    ArtifactAccessEntities NVARCHAR(MAX) AS JSON, 
    ADF_PipelineRunId VARCHAR(50) '$.ADF_PipelineRunId'
  ) CROSS APPLY openjson (ArtifactAccessEntities) WITH (
    ArtifactId VARCHAR(50) '$.artifactId', 
    DisplayName VARCHAR(50) '$.displayName', 
    ArtifactType VARCHAR(50) '$.artifactType', 
    AccessRight VARCHAR(50) '$.accessRight', 
    ShareType VARCHAR(50) '$.shareType', 
    SharerEmailAddress VARCHAR(50) '$.sharer.emailAddress', 
    SharerDisplayName VARCHAR(50) '$.sharer.displayName', 
    SharerIdentifier VARCHAR(50) '$.sharer.identifier', 
    SharerGraphId VARCHAR(50) '$.sharer.graphId', 
    SharerPrincipalType VARCHAR(50) '$.sharer.principalType'
  )