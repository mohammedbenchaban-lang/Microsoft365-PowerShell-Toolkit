#Requires -Version 7.0
<#
.SYNOPSIS
    Creates a new Microsoft 365 user account via Microsoft Graph.
.DESCRIPTION
    Validates input, creates a user with New-MgUser, sets a temporary password requiring change at next sign-in, and logs the result.
.EXAMPLE
    .\Create-User.ps1 -DisplayName "Jane Doe" -UserPrincipalName "jane.doe@contoso.com" -MailNickname "jane.doe"
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,

    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [Parameter(Mandatory = $true)]
    [string]$MailNickname,

    [Parameter(Mandatory = $false)]
    [string]$TemporaryPassword = [System.Guid]::NewGuid().ToString().Substring(0,12) + "!Aa1"
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "Create-User.ps1" | Out-Null
Write-Log -Message "Starting Create-User.ps1" -Level "INFO"

try {
    Assert-NotNullOrEmpty -Value $DisplayName -ParameterName "DisplayName"
    Assert-NotNullOrEmpty -Value $UserPrincipalName -ParameterName "UserPrincipalName"
    if (-not (Test-EmailFormat -EmailAddress $UserPrincipalName)) {
        Write-LogAndThrow -Message "UserPrincipalName '$UserPrincipalName' is not a valid email format."
    }

    Assert-GraphConnection

    $passwordProfile = @{
        Password                      = $TemporaryPassword
        ForceChangePasswordNextSignIn = $true
    }

    if ($PSCmdlet.ShouldProcess($UserPrincipalName, "Create Microsoft 365 user")) {
        Show-ToolkitProgress -Activity "Creating user" -Status $UserPrincipalName -PercentComplete 50
        $newUser = New-MgUser -DisplayName $DisplayName `
            -UserPrincipalName $UserPrincipalName `
            -MailNickname $MailNickname `
            -AccountEnabled `
            -PasswordProfile $passwordProfile

        Write-Log -Message "Created user $($newUser.UserPrincipalName) (Id: $($newUser.Id))" -Level "SUCCESS"
        Write-Host "Temporary password: $TemporaryPassword" -ForegroundColor Yellow
    }

    Write-Log -Message "Create-User.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Create-User.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
