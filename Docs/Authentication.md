# Authentication

This toolkit uses **modern authentication** exclusively via the Microsoft Graph PowerShell SDK — no legacy basic auth, no stored credentials or client secrets in scripts.

## How It Works

`Scripts/Connect-M365.ps1` calls `Connect-ToolkitGraph` (in `Modules/GraphConnection.psm1`), which:

1. Checks for an existing valid Graph session with the required scopes.
2. If none exists, calls `Connect-MgGraph` which opens an interactive browser sign-in
   (or device code flow in non-interactive/headless environments).
3. Verifies and logs the connected tenant and account.

## Required Scopes

```
User.ReadWrite.All
Directory.ReadWrite.All
AuditLog.Read.All
Reports.Read.All
Mail.Read
```

## Using a Specific Tenant

```powershell
.\Connect-M365.ps1 -TenantId "contoso.onmicrosoft.com"
```

## App-Only Authentication (Automation Scenarios)

For unattended/scheduled runs, register an Entra ID app with certificate-based
authentication and grant it the application-permission equivalents of the
scopes above, then connect with:

```powershell
Connect-MgGraph -ClientId "<app-id>" -TenantId "<tenant-id>" -CertificateThumbprint "<thumbprint>"
```

> Never commit client secrets or certificates to source control. Use a secrets
> manager (Azure Key Vault, GitHub Actions secrets, etc.) in production.
