#Requires -Version 7.0
<#
.SYNOPSIS
    Shared helper utilities for the Microsoft365-PowerShell-Toolkit.
.DESCRIPTION
    Report export helpers, standardized exit codes, and progress bar
    wrappers shared across scripts.
#>

$Script:ExitCodes = @{
    Success          = 0
    GeneralError     = 1
    ValidationError  = 2
    ConnectionError  = 3
    NotFound         = 4
    PartialSuccess   = 5
}

function Get-ToolkitExitCode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Success", "GeneralError", "ValidationError", "ConnectionError", "NotFound", "PartialSuccess")]
        [string]$Name
    )
    return $Script:ExitCodes[$Name]
}

function Export-ToolkitReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $InputObject,

        [Parameter(Mandatory = $true)]
        [string]$ReportName
    )

    $reportRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Reports"
    if (-not (Test-Path -Path $reportRoot)) {
        New-Item -Path $reportRoot -ItemType Directory -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $reportPath = Join-Path -Path $reportRoot -ChildPath "${ReportName}_$timestamp.csv"

    try {
        $InputObject | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8
        Write-Log -Message "Report exported to $reportPath" -Level "SUCCESS"
        return $reportPath
    }
    catch {
        Write-Log -Message "Failed to export report: $($_.Exception.Message)" -Level "ERROR"
        throw
    }
}

function Show-ToolkitProgress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Activity,

        [Parameter(Mandatory = $true)]
        [string]$Status,

        [Parameter(Mandatory = $true)]
        [int]$PercentComplete
    )
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
}

Export-ModuleMember -Function Get-ToolkitExitCode, Export-ToolkitReport, Show-ToolkitProgress -Variable ExitCodes
