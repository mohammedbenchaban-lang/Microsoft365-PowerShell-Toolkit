#Requires -Version 7.0
<#
.SYNOPSIS
    Reports OneDrive storage usage for a Microsoft 365 user.
.DESCRIPTION
    Uses Get-MgUserDrive to retrieve quota, used, and remaining storage for a given user's OneDrive.
.EXAMPLE
    .\OneDrive-Storage.ps1 -UserPrincipalName "jane.doe@contoso.com"
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "OneDrive-Storage.ps1" | Out-Null
Write-Log -Message "Starting OneDrive-Storage.ps1" -Level "INFO"

try {
    Assert-NotNullOrEmpty -Value $UserPrincipalName -ParameterName "UserPrincipalName"
    Assert-GraphConnection

    $drive = Get-MgUserDrive -UserId $UserPrincipalName
    $report = [PSCustomObject]@{
        UserPrincipalName = $UserPrincipalName
        TotalGB           = [math]::Round($drive.Quota.Total / 1GB, 2)
        UsedGB            = [math]::Round($drive.Quota.Used / 1GB, 2)
        RemainingGB       = [math]::Round($drive.Quota.Remaining / 1GB, 2)
        State             = $drive.Quota.State
    }

    Write-Log -Message "Retrieved OneDrive usage for $UserPrincipalName" -Level "INFO"
    Export-ToolkitReport -InputObject @($report) -ReportName "OneDriveStorage_$($UserPrincipalName -replace '[^a-zA-Z0-9]','_')"

    Write-Log -Message "OneDrive-Storage.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "OneDrive-Storage.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
