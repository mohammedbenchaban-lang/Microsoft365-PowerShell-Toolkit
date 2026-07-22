#Requires -Version 7.0
<#
.SYNOPSIS
    Generates a consolidated tenant security posture report.
.DESCRIPTION
    Combines active security alerts (Get-MgSecurityAlert) and MFA registration gaps into a single summary report for security analyst review.
.EXAMPLE
    .\Security-Report.ps1
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [int]$TopAlerts = 50
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "Security-Report.ps1" | Out-Null
Write-Log -Message "Starting Security-Report.ps1" -Level "INFO"

try {
    Assert-GraphConnection

    Show-ToolkitProgress -Activity "Security report" -Status "Retrieving alerts" -PercentComplete 30
    $alerts = Get-MgSecurityAlert -Top $TopAlerts |
        Select-Object Title, Severity, Status, CreatedDateTime, Category

    Show-ToolkitProgress -Activity "Security report" -Status "Checking MFA gaps" -PercentComplete 70
    $mfaGaps = Get-MgReportAuthenticationMethodUserRegistrationDetail -All |
        Where-Object { -not $_.IsMfaRegistered } |
        Select-Object UserPrincipalName, IsMfaRegistered

    Write-Log -Message "Retrieved $($alerts.Count) alert(s) and $($mfaGaps.Count) MFA gap(s)." -Level "INFO"
    Export-ToolkitReport -InputObject $alerts -ReportName "SecurityAlerts"
    Export-ToolkitReport -InputObject $mfaGaps -ReportName "SecurityMFAGaps"

    Write-Log -Message "Security-Report.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Security-Report.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
