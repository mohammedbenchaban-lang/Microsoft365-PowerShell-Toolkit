#Requires -Version 7.0
<#
.SYNOPSIS
    Microsoft Graph connection helper module.
.DESCRIPTION
    Wraps Microsoft Graph PowerShell SDK connection/disconnection with
    consistent scope handling, logging, and connection-state checks so
    every script authenticates the same way.
#>

function Connect-ToolkitGraph {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$Scopes = @(
            "User.ReadWrite.All",
            "Directory.ReadWrite.All",
            "AuditLog.Read.All",
            "Reports.Read.All",
            "Mail.Read"
        ),

        [Parameter(Mandatory = $false)]
        [string]$TenantId
    )

    try {
        Test-RequiredModule -ModuleName "Microsoft.Graph"

        $context = Get-MgContext
        if ($context -and ($Scopes | Where-Object { $_ -notin $context.Scopes })) {
            Write-Log -Message "Existing Graph session is missing required scopes. Reconnecting." -Level "WARNING"
            Disconnect-MgGraph | Out-Null
            $context = $null
        }

        if (-not $context) {
            Write-Log -Message "Connecting to Microsoft Graph with scopes: $($Scopes -join ', ')" -Level "INFO"
            $connectParams = @{ Scopes = $Scopes }
            if ($TenantId) { $connectParams["TenantId"] = $TenantId }
            Connect-MgGraph @connectParams -NoWelcome
            $context = Get-MgContext
        }
        else {
            Write-Log -Message "Reusing existing Microsoft Graph session for $($context.Account)" -Level "INFO"
        }

        Write-Log -Message "Connected to tenant: $($context.TenantId) as $($context.Account)" -Level "SUCCESS"
        return $context
    }
    catch {
        Write-LogAndThrow -Message "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
    }
}

function Disconnect-ToolkitGraph {
    [CmdletBinding()]
    param()
    try {
        if (Get-MgContext) {
            Disconnect-MgGraph | Out-Null
            Write-Log -Message "Disconnected from Microsoft Graph." -Level "INFO"
        }
    }
    catch {
        Write-Log -Message "Error while disconnecting from Microsoft Graph: $($_.Exception.Message)" -Level "WARNING"
    }
}

function Assert-GraphConnection {
    [CmdletBinding()]
    param()
    if (-not (Get-MgContext)) {
        Write-LogAndThrow -Message "No active Microsoft Graph session. Run Connect-M365.ps1 first."
    }
}

Export-ModuleMember -Function Connect-ToolkitGraph, Disconnect-ToolkitGraph, Assert-GraphConnection
