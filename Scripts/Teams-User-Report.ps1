#Requires -Version 7.0
<#
.SYNOPSIS
    Reports Microsoft Teams activity for all users.
.DESCRIPTION
    Uses Get-MgReportTeamsUserActivityUserDetail to summarize each user's Teams usage (chat, calls, meetings) for the selected period.
.EXAMPLE
    .\Teams-User-Report.ps1 -Period D30
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


Initialize-ToolkitLog -ScriptName "Teams-User-Report.ps1" | Out-Null
Write-Log -Message "Starting Teams-User-Report.ps1" -Level "INFO"

try {
    Assert-GraphConnection
    $reportPath = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Reports\TeamsActivityRaw.csv"
    Get-MgReportTeamsUserActivityUserDetail -Period $Period -OutFile $reportPath
    $data = Import-Csv -Path $reportPath

    Write-Log -Message "Retrieved Teams activity for $($data.Count) user(s)." -Level "INFO"
    Export-ToolkitReport -InputObject $data -ReportName "TeamsActivity"

    Write-Log -Message "Teams-User-Report.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Teams-User-Report.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
