#Requires -Version 7.0
<#
.SYNOPSIS
    Resets a Microsoft 365 user's password and forces change at next sign-in.
.DESCRIPTION
    Generates (or accepts) a new temporary password and applies it via Update-MgUser, forcing the user to change it at next sign-in.
.EXAMPLE
    .\Reset-Password.ps1 -UserPrincipalName "jane.doe@contoso.com"
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [Parameter(Mandatory = $false)]
    [string]$NewPassword = [System.Guid]::NewGuid().ToString().Substring(0,12) + "!Aa1"
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "Reset-Password.ps1" | Out-Null
Write-Log -Message "Starting Reset-Password.ps1" -Level "INFO"

try {
    Assert-NotNullOrEmpty -Value $UserPrincipalName -ParameterName "UserPrincipalName"
    Assert-GraphConnection

    $user = Get-MgUser -UserId $UserPrincipalName -ErrorAction SilentlyContinue
    if (-not $user) {
        Write-LogAndThrow -Message "User '$UserPrincipalName' was not found."
    }

    $passwordProfile = @{
        Password                      = $NewPassword
        ForceChangePasswordNextSignIn = $true
    }

    if ($PSCmdlet.ShouldProcess($UserPrincipalName, "Reset password")) {
        Update-MgUser -UserId $user.Id -PasswordProfile $passwordProfile
        Write-Log -Message "Password reset for $UserPrincipalName" -Level "SUCCESS"
        Write-Host "New temporary password: $NewPassword" -ForegroundColor Yellow
    }

    Write-Log -Message "Reset-Password.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Reset-Password.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
