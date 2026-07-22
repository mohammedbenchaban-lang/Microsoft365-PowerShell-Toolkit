#Requires -Version 7.0
<#
.SYNOPSIS
    Generates a mailbox usage report across the tenant.
.DESCRIPTION
    Uses the Microsoft Graph Reports API (Get-MgReportMailboxUsageDetail) to summarize mailbox size, item count, and last activity date per user.
.EXAMPLE
    .\Mailbox-Report.ps1 -Period D30
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("D7","D30","D90","D180")]
    [string]$Period = "D30"
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "Mailbox-Report.ps1" | Out-Null
Write-Log -Message "Starting Mailbox-Report.ps1" -Level "INFO"

try {
    Assert-GraphConnection
    $reportPath = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Reports\MailboxUsageRaw.csv"
    Get-MgReportMailboxUsageDetail -Period $Period -OutFile $reportPath
    $data = Import-Csv -Path $reportPath

    Write-Log -Message "Retrieved mailbox usage for $($data.Count) mailbox(es)." -Level "INFO"
    Export-ToolkitReport -InputObject $data -ReportName "MailboxUsage"

    Write-Log -Message "Mailbox-Report.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Mailbox-Report.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
