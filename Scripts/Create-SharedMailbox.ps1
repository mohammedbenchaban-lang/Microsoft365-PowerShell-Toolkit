#Requires -Version 7.0
<#
.SYNOPSIS
    Creates a shared mailbox in Exchange Online.
.DESCRIPTION
    Shared mailbox creation is an Exchange Online operation, not a Graph user operation, so this script connects via ExchangeOnlineManagement and calls New-Mailbox -Shared.
.EXAMPLE
    .\Create-SharedMailbox.ps1 -DisplayName "Support Team" -PrimarySmtpAddress "support@contoso.com"
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK + ExchangeOnlineManagement module
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,

    [Parameter(Mandatory = $true)]
    [string]$PrimarySmtpAddress
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "Create-SharedMailbox.ps1" | Out-Null
Write-Log -Message "Starting Create-SharedMailbox.ps1" -Level "INFO"

try {
    Assert-NotNullOrEmpty -Value $DisplayName -ParameterName "DisplayName"
    if (-not (Test-EmailFormat -EmailAddress $PrimarySmtpAddress)) {
        Write-LogAndThrow -Message "PrimarySmtpAddress '$PrimarySmtpAddress' is not a valid email format."
    }
    Test-RequiredModule -ModuleName "ExchangeOnlineManagement"

    if (-not (Get-ConnectionInformation)) {
        Write-Log -Message "Connecting to Exchange Online..." -Level "INFO"
        Connect-ExchangeOnline -ShowBanner:$false
    }

    if ($PSCmdlet.ShouldProcess($PrimarySmtpAddress, "Create shared mailbox")) {
        New-Mailbox -Shared -Name $DisplayName -DisplayName $DisplayName -PrimarySmtpAddress $PrimarySmtpAddress
        Write-Log -Message "Created shared mailbox $PrimarySmtpAddress" -Level "SUCCESS"
    }

    Write-Log -Message "Create-SharedMailbox.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Create-SharedMailbox.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
