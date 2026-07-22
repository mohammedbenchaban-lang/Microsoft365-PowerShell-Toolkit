#Requires -Version 7.0
<#
.SYNOPSIS
    Identifies Microsoft 365 users with no recent sign-in activity.
.DESCRIPTION
    Uses SignInActivity on Get-MgUser to flag accounts inactive beyond a configurable threshold, useful for license reclamation and offboarding audits.
.EXAMPLE
    .\Inactive-Users.ps1 -InactiveDaysThreshold 90
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [int]$InactiveDaysThreshold = 90
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "Inactive-Users.ps1" | Out-Null
Write-Log -Message "Starting Inactive-Users.ps1" -Level "INFO"

try {
    Assert-GraphConnection
    $cutoff = (Get-Date).AddDays(-$InactiveDaysThreshold)

    $users = Get-MgUser -All -Property "DisplayName,UserPrincipalName,SignInActivity,AccountEnabled" |
        Select-Object DisplayName, UserPrincipalName, AccountEnabled, `
            @{Name="LastSignIn";Expression={$_.SignInActivity.LastSignInDateTime}}

    $inactive = $users | Where-Object {
        (-not $_.LastSignIn) -or ([datetime]$_.LastSignIn -lt $cutoff)
    }

    Write-Log -Message "$($inactive.Count) of $($users.Count) users are inactive beyond $InactiveDaysThreshold days." -Level "INFO"
    Export-ToolkitReport -InputObject $inactive -ReportName "InactiveUsers"

    Write-Log -Message "Inactive-Users.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Inactive-Users.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
