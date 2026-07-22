#Requires -Version 7.0
<#
.SYNOPSIS
    Reports Multi-Factor Authentication registration status for all users.
.DESCRIPTION
    Uses Get-MgReportAuthenticationMethodUserRegistrationDetail to flag users who are not MFA-registered, a common security audit ask.
.EXAMPLE
    .\MFA-Status.ps1 -NotRegisteredOnly
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [switch]$NotRegisteredOnly
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "MFA-Status.ps1" | Out-Null
Write-Log -Message "Starting MFA-Status.ps1" -Level "INFO"

try {
    Assert-GraphConnection
    $details = Get-MgReportAuthenticationMethodUserRegistrationDetail -All |
        Select-Object UserPrincipalName, IsMfaRegistered, IsMfaCapable, IsPasswordlessCapable

    if ($NotRegisteredOnly) {
        $details = $details | Where-Object { -not $_.IsMfaRegistered }
    }

    Write-Log -Message "Retrieved MFA status for $($details.Count) user(s)." -Level "INFO"
    Export-ToolkitReport -InputObject $details -ReportName "MFAStatus"

    Write-Log -Message "MFA-Status.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "MFA-Status.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
