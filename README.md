# Monitoring Power BI and Fabric

A complete solution to extract and query:
 - Activity/audit events from Power BI & Fabric
 - Artifacts metadata from Power BI & Fabric
 - Admin tenant settings (Power BI & Fabric)
 - Microsoft Graph data (users, groups, licenses)

## Overall architecture

The data is extracted using with either Azure Data Factory or Integration Pipelines in Azure Synapse Analytics. If Synapse is used, then the data can be queried with the Serverless SQL Pool and made available for reporting.

![Overall architecture](https://justb.dk/wp-content/uploads/2023/08/Architecture.png)

## The solution is descibed in these blog posts:
 - https://justb.dk/blog/2021/02/extracting-the-power-bi-activity-log-with-data-factory/
 - https://justb.dk/blog/2021/02/extracting-power-bi-metadata-with-data-factory-part-1/
 - https://justb.dk/blog/2021/04/extracting-power-bi-metadata-with-data-factory-part-2/
 - https://justb.dk/blog/2022/04/extracting-microsoft-graph-data-with-data-factory/
 - https://justb.dk/blog/2023/01/extracting-power-bi-tenant-metadata-with-synapse-analytics/
 - https://justb.dk/blog/2023/01/query-power-bi-tenant-metadata-with-synapse-serverless-sql-pool/
 - https://justb.dk/blog/2023/01/query-power-bi-activity-events-with-synapse-serverless-sql/
 - https://justb.dk/blog/2023/03/extension-to-the-scanner-api/
 - https://justb.dk/blog/2023/06/extract-and-query-the-tenant-settings/

## Alternative solutions

List of other ways and solutions to monitor Power BI and Fabric
 
 - [pbimonitor](https://github.com/RuiRomano/pbimonitor) by Rui Romano. Using PowerShell and including Power BI templates to analyse all the data.
 - [Admin Monitoring for Tenant Admins](https://learn.microsoft.com/en-us/fabric/admin/monitoring-workspace). The build-in solution from Microsoft.
 - [Argus PBI](https://www.arguspbi.com/). Payed service to monitoring the whole-tenant for Power BI.
 - [Power BI Sentinel](https://www.powerbisentinel.com/usage-logging/). Payed service with Governance, Auditing and Disaster Recovery for Power BI and Fabric.
