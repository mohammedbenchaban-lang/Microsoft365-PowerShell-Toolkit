#Requires -Version 7.0
<#
.SYNOPSIS
    Disables sign-in for a Microsoft 365 user account.
.DESCRIPTION
    Sets AccountEnabled to $false via Update-MgUser, typically used for offboarding or suspected compromise.
.EXAMPLE
    .\Disable-User.ps1 -UserPrincipalName "jane.doe@contoso.com"
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


Initialize-ToolkitLog -ScriptName "Disable-User.ps1" | Out-Null
Write-Log -Message "Starting Disable-User.ps1" -Level "INFO"

try {
    Assert-NotNullOrEmpty -Value $UserPrincipalName -ParameterName "UserPrincipalName"
    Assert-GraphConnection

    if ($PSCmdlet.ShouldProcess($UserPrincipalName, "Disable sign-in")) {
        Update-MgUser -UserId $UserPrincipalName -AccountEnabled:$false
        Write-Log -Message "Disabled sign-in for $UserPrincipalName" -Level "SUCCESS"
    }

    Write-Log -Message "Disable-User.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Disable-User.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
