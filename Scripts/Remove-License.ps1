#Requires -Version 7.0
<#
.SYNOPSIS
    Removes a Microsoft 365 license SKU from a user.
.DESCRIPTION
    Looks up the SKU by part number and removes it from the target user via Set-MgUserLicense.
.EXAMPLE
    .\Remove-License.ps1 -UserPrincipalName "jane.doe@contoso.com" -SkuPartNumber "ENTERPRISEPACK"
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [Parameter(Mandatory = $true)]
    [string]$SkuPartNumber
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "Remove-License.ps1" | Out-Null
Write-Log -Message "Starting Remove-License.ps1" -Level "INFO"

try {
    Assert-NotNullOrEmpty -Value $UserPrincipalName -ParameterName "UserPrincipalName"
    Assert-NotNullOrEmpty -Value $SkuPartNumber -ParameterName "SkuPartNumber"
    Assert-GraphConnection

    $sku = Get-MgSubscribedSku -All | Where-Object { $_.SkuPartNumber -eq $SkuPartNumber }
    if (-not $sku) {
        Write-LogAndThrow -Message "SKU '$SkuPartNumber' was not found in this tenant."
    }

    if ($PSCmdlet.ShouldProcess($UserPrincipalName, "Remove license $SkuPartNumber")) {
        Set-MgUserLicense -UserId $UserPrincipalName -AddLicenses @() -RemoveLicenses @($sku.SkuId)
        Write-Log -Message "Removed license $SkuPartNumber from $UserPrincipalName" -Level "SUCCESS"
    }

    Write-Log -Message "Remove-License.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Remove-License.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
