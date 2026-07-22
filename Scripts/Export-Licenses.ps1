#Requires -Version 7.0
<#
.SYNOPSIS
    Exports Microsoft 365 license SKU consumption to a CSV report.
.DESCRIPTION
    Retrieves subscribed SKUs via Get-MgSubscribedSku and reports total vs. consumed units per SKU.
.EXAMPLE
    .\Export-Licenses.ps1
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [switch]$IncludeZeroConsumption
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "Export-Licenses.ps1" | Out-Null
Write-Log -Message "Starting Export-Licenses.ps1" -Level "INFO"

try {
    Assert-GraphConnection
    $skus = Get-MgSubscribedSku -All | Select-Object SkuPartNumber, ConsumedUnits, `
        @{Name="TotalUnits";Expression={$_.PrepaidUnits.Enabled}}, `
        @{Name="AvailableUnits";Expression={$_.PrepaidUnits.Enabled - $_.ConsumedUnits}}

    if (-not $IncludeZeroConsumption) {
        $skus = $skus | Where-Object { $_.ConsumedUnits -gt 0 }
    }

    Write-Log -Message "Retrieved license usage for $($skus.Count) SKU(s)." -Level "INFO"
    Export-ToolkitReport -InputObject $skus -ReportName "Licenses"

    Write-Log -Message "Export-Licenses.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Export-Licenses.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
