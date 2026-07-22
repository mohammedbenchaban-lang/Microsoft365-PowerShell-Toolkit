#Requires -Version 7.0
<#
.SYNOPSIS
    Exports all Microsoft 365 users to a CSV report.
.DESCRIPTION
    Retrieves all users via Get-MgUser -All and exports key attributes to a timestamped CSV in ./Reports.
.EXAMPLE
    .\Export-Users.ps1
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$Properties = @("DisplayName","UserPrincipalName","Mail","AccountEnabled","Department","JobTitle")
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "Export-Users.ps1" | Out-Null
Write-Log -Message "Starting Export-Users.ps1" -Level "INFO"

try {
    Assert-GraphConnection
    Show-ToolkitProgress -Activity "Exporting users" -Status "Querying Microsoft Graph" -PercentComplete 20

    $users = Get-MgUser -All -Property $Properties | Select-Object $Properties
    Write-Log -Message "Retrieved $($users.Count) users." -Level "INFO"

    Export-ToolkitReport -InputObject $users -ReportName "Users"

    Write-Log -Message "Export-Users.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Export-Users.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
