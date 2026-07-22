#Requires -Version 7.0
<#
.SYNOPSIS
    Bulk-creates Microsoft 365 users from a CSV file.
.DESCRIPTION
    Reads a CSV (DisplayName, UserPrincipalName, MailNickname) and creates each user via New-MgUser, reporting progress and per-row success/failure.
.EXAMPLE
    .\Bulk-Create-Users.ps1 -CsvPath ".\Reports\SampleUsers.csv"
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "Bulk-Create-Users.ps1" | Out-Null
Write-Log -Message "Starting Bulk-Create-Users.ps1" -Level "INFO"

try {
    Assert-NotNullOrEmpty -Value $CsvPath -ParameterName "CsvPath"
    Test-CsvSchema -CsvPath $CsvPath -RequiredColumns @("DisplayName", "UserPrincipalName", "MailNickname")
    Assert-GraphConnection

    $rows = Import-Csv -Path $CsvPath
    $total = $rows.Count
    $index = 0
    $results = @()

    foreach ($row in $rows) {
        $index++
        Show-ToolkitProgress -Activity "Bulk creating users" -Status $row.UserPrincipalName -PercentComplete ([int](($index / $total) * 100))

        try {
            if (-not (Test-EmailFormat -EmailAddress $row.UserPrincipalName)) {
                throw "Invalid email format: $($row.UserPrincipalName)"
            }
            $passwordProfile = @{
                Password                      = [System.Guid]::NewGuid().ToString().Substring(0,12) + "!Aa1"
                ForceChangePasswordNextSignIn = $true
            }
            $newUser = New-MgUser -DisplayName $row.DisplayName `
                -UserPrincipalName $row.UserPrincipalName `
                -MailNickname $row.MailNickname `
                -AccountEnabled `
                -PasswordProfile $passwordProfile
            Write-Log -Message "Created $($row.UserPrincipalName)" -Level "SUCCESS"
            $results += [PSCustomObject]@{ UserPrincipalName = $row.UserPrincipalName; Status = "Created"; Error = "" }
        }
        catch {
            Write-Log -Message "Failed to create $($row.UserPrincipalName): $($_.Exception.Message)" -Level "ERROR"
            $results += [PSCustomObject]@{ UserPrincipalName = $row.UserPrincipalName; Status = "Failed"; Error = $_.Exception.Message }
        }
    }

    Export-ToolkitReport -InputObject $results -ReportName "BulkCreateUsers"
    $failedCount = ($results | Where-Object { $_.Status -eq "Failed" }).Count
    if ($failedCount -gt 0) {
        Write-Log -Message "$failedCount of $total users failed to create. See report for details." -Level "WARNING"
    }

    Write-Log -Message "Bulk-Create-Users.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Bulk-Create-Users.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
