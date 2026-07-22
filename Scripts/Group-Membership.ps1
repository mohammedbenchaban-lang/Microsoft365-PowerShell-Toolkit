#Requires -Version 7.0
<#
.SYNOPSIS
    Reports group membership for a given Microsoft 365 user.
.DESCRIPTION
    Uses Get-MgUserMemberOf to list every group (security and Microsoft 365) a user belongs to.
.EXAMPLE
    .\Group-Membership.ps1 -UserPrincipalName "jane.doe@contoso.com"
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


Initialize-ToolkitLog -ScriptName "Group-Membership.ps1" | Out-Null
Write-Log -Message "Starting Group-Membership.ps1" -Level "INFO"

try {
    Assert-NotNullOrEmpty -Value $UserPrincipalName -ParameterName "UserPrincipalName"
    Assert-GraphConnection

    $user = Get-MgUser -UserId $UserPrincipalName -ErrorAction SilentlyContinue
    if (-not $user) {
        Write-LogAndThrow -Message "User '$UserPrincipalName' was not found."
    }

    $groups = Get-MgUserMemberOf -UserId $user.Id -All | ForEach-Object {
        [PSCustomObject]@{
            GroupDisplayName = $_.AdditionalProperties["displayName"]
            GroupId          = $_.Id
        }
    }

    Write-Log -Message "$UserPrincipalName is a member of $($groups.Count) group(s)." -Level "INFO"
    Export-ToolkitReport -InputObject $groups -ReportName "GroupMembership_$($UserPrincipalName -replace '[^a-zA-Z0-9]','_')"

    Write-Log -Message "Group-Membership.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Group-Membership.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
