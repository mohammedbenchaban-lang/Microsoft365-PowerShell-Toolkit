#Requires -Version 7.0
<#
.SYNOPSIS
    Centralized logging module for the Microsoft365-PowerShell-Toolkit.
.DESCRIPTION
    Provides consistent, timestamped, colored console logging and persistent
    file logging under ./Logs/ for every script in the toolkit.
#>

function Initialize-ToolkitLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ScriptName = (Split-Path -Leaf $MyInvocation.PSCommandPath)
    )

    $logRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Logs"
    if (-not (Test-Path -Path $logRoot)) {
        New-Item -Path $logRoot -ItemType Directory -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFile = Join-Path -Path $logRoot -ChildPath "$($ScriptName -replace '\.ps1$','')_$timestamp.log"

    $Global:ToolkitLogPath = $logFile
    Write-Log -Message "Log initialized for $ScriptName" -Level "INFO"
    return $logFile
}

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"

    switch ($Level) {
        "INFO"    { Write-Host $line -ForegroundColor Cyan }
        "SUCCESS" { Write-Host $line -ForegroundColor Green }
        "WARNING" { Write-Host $line -ForegroundColor Yellow }
        "ERROR"   { Write-Host $line -ForegroundColor Red }
        "DEBUG"   { Write-Verbose $line }
    }

    if ($Global:ToolkitLogPath) {
        try {
            Add-Content -Path $Global:ToolkitLogPath -Value $line -ErrorAction Stop
        }
        catch {
            Write-Host "[$timestamp] [ERROR] Failed to write to log file: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

function Write-LogAndThrow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    Write-Log -Message $Message -Level "ERROR"
    throw $Message
}

Export-ModuleMember -Function Initialize-ToolkitLog, Write-Log, Write-LogAndThrow
