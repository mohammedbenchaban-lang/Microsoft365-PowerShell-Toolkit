#Requires -Version 7.0
<#
.SYNOPSIS
    Establishes an authenticated Microsoft Graph session for the toolkit.
.DESCRIPTION
    Connects to Microsoft Graph using modern (interactive/device-code) authentication with the scopes required across the toolkit. Reuses an existing valid session where possible.
.EXAMPLE
    .\Connect-M365.ps1
.EXAMPLE
    .\Connect-M365.ps1 -TenantId "contoso.onmicrosoft.com"
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [string]$TenantId
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "Connect-M365.ps1" | Out-Null
Write-Log -Message "Starting Connect-M365.ps1" -Level "INFO"

try {
    Assert-NotNullOrEmpty -Value "placeholder" -ParameterName "internal-check"
    $context = Connect-ToolkitGraph -TenantId $TenantId
    Write-Host "Connected as $($context.Account) to tenant $($context.TenantId)" -ForegroundColor Green

    Write-Log -Message "Connect-M365.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Connect-M365.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
