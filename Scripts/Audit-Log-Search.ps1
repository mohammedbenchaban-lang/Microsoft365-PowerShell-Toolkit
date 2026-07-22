#Requires -Version 7.0
<#
.SYNOPSIS
    Searches Microsoft 365 directory audit logs.
.DESCRIPTION
    Uses Get-MgAuditLogDirectoryAudit with an OData filter to search audit activity within a date range, useful for incident investigation.
.EXAMPLE
    .\Audit-Log-Search.ps1 -StartDate (Get-Date).AddDays(-7)
.EXAMPLE
    .\Audit-Log-Search.ps1 -ActivityDisplayName "Reset password"
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [datetime]$StartDate = (Get-Date).AddDays(-7),

    [Parameter(Mandatory = $false)]
    [datetime]$EndDate = (Get-Date),

    [Parameter(Mandatory = $false)]
    [string]$ActivityDisplayName
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "Audit-Log-Search.ps1" | Out-Null
Write-Log -Message "Starting Audit-Log-Search.ps1" -Level "INFO"

try {
    Assert-GraphConnection
    $startIso = $StartDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $endIso = $EndDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    $filter = "activityDateTime ge $startIso and activityDateTime le $endIso"
    if ($ActivityDisplayName) {
        $filter += " and activityDisplayName eq '$ActivityDisplayName'"
    }

    $events = Get-MgAuditLogDirectoryAudit -Filter $filter -All |
        Select-Object ActivityDisplayName, ActivityDateTime, `
            @{Name="InitiatedBy";Expression={$_.InitiatedBy.User.UserPrincipalName}}, Result

    Write-Log -Message "Retrieved $($events.Count) audit log event(s)." -Level "INFO"
    Export-ToolkitReport -InputObject $events -ReportName "AuditLogSearch"

    Write-Log -Message "Audit-Log-Search.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Audit-Log-Search.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
