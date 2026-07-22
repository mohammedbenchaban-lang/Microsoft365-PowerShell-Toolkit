#Requires -Version 7.0
<#
.SYNOPSIS
    Input validation helpers for the Microsoft365-PowerShell-Toolkit.
.DESCRIPTION
    Centralizes common validation logic (email format, required modules,
    non-empty checks, CSV schema checks) so every script fails fast and
    with a clear, actionable message.
#>

function Test-EmailFormat {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$EmailAddress
    )
    return $EmailAddress -match '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
}

function Assert-NotNullOrEmpty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        $Value,

        [Parameter(Mandatory = $true)]
        [string]$ParameterName
    )
    if ([string]::IsNullOrWhiteSpace($Value)) {
        Write-LogAndThrow -Message "Parameter '$ParameterName' cannot be null or empty."
    }
}

function Test-RequiredModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ModuleName
    )
    $missing = @()
    foreach ($module in $ModuleName) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            $missing += $module
        }
    }
    if ($missing.Count -gt 0) {
        Write-LogAndThrow -Message "Missing required module(s): $($missing -join ', '). Install with: Install-Module $($missing -join ', ') -Scope CurrentUser"
    }
    return $true
}

function Test-CsvSchema {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$CsvPath,

        [Parameter(Mandatory = $true)]
        [string[]]$RequiredColumns
    )

    if (-not (Test-Path -Path $CsvPath)) {
        Write-LogAndThrow -Message "CSV file not found at path: $CsvPath"
    }

    $header = (Get-Content -Path $CsvPath -TotalCount 1) -split ","
    $missingColumns = $RequiredColumns | Where-Object { $_ -notin $header }

    if ($missingColumns.Count -gt 0) {
        Write-LogAndThrow -Message "CSV is missing required column(s): $($missingColumns -join ', ')"
    }
    return $true
}

Export-ModuleMember -Function Test-EmailFormat, Assert-NotNullOrEmpty, Test-RequiredModule, Test-CsvSchema
