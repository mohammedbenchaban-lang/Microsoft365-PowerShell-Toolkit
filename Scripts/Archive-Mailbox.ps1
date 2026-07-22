#Requires -Version 7.0
<#
.SYNOPSIS
    Enables the in-place archive mailbox for a Microsoft 365 user.
.DESCRIPTION
    Connects to Exchange Online and enables the auto-expanding archive mailbox via Enable-Mailbox -Archive.
.EXAMPLE
    .\Archive-Mailbox.ps1 -Identity "jane.doe@contoso.com"
.NOTES
    Author  : Mohammed Chems Eddine Benchabane
    Module  : Microsoft365-PowerShell-Toolkit
    Requires: Microsoft.Graph PowerShell SDK + ExchangeOnlineManagement module
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$Identity
)

$ErrorActionPreference = "Stop"
$ModuleRoot = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "Modules"
Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
Import-Module (Join-Path $ModuleRoot "GraphConnection.psm1") -Force
Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force


Initialize-ToolkitLog -ScriptName "Archive-Mailbox.ps1" | Out-Null
Write-Log -Message "Starting Archive-Mailbox.ps1" -Level "INFO"

try {
    Assert-NotNullOrEmpty -Value $Identity -ParameterName "Identity"
    Test-RequiredModule -ModuleName "ExchangeOnlineManagement"

    if (-not (Get-ConnectionInformation)) {
        Write-Log -Message "Connecting to Exchange Online..." -Level "INFO"
        Connect-ExchangeOnline -ShowBanner:$false
    }

    if ($PSCmdlet.ShouldProcess($Identity, "Enable archive mailbox")) {
        Enable-Mailbox -Identity $Identity -Archive
        Write-Log -Message "Archive mailbox enabled for $Identity" -Level "SUCCESS"
    }

    Write-Log -Message "Archive-Mailbox.ps1 completed successfully." -Level "SUCCESS"
    exit (Get-ToolkitExitCode -Name "Success")
}
catch {
    Write-Log -Message "Archive-Mailbox.ps1 failed: $($_.Exception.Message)" -Level "ERROR"
    exit (Get-ToolkitExitCode -Name "GeneralError")
}
