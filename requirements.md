# Requirements

## Runtime

- **PowerShell 7.0+** (cross-platform: Windows, macOS, Linux)
- **Microsoft Graph PowerShell SDK**
  ```powershell
  Install-Module Microsoft.Graph -Scope CurrentUser
  ```
- **ExchangeOnlineManagement** module (required only for `Create-SharedMailbox.ps1` and `Archive-Mailbox.ps1`)
  ```powershell
  Install-Module ExchangeOnlineManagement -Scope CurrentUser
  ```

## Microsoft Entra ID (Azure AD) Permissions

The toolkit requests the following Microsoft Graph delegated scopes on connect (see `Docs/Authentication.md` for details):

| Scope | Purpose |
|---|---|
| `User.ReadWrite.All` | Create, update, disable/enable, and remove users |
| `Directory.ReadWrite.All` | License assignment and directory object management |
| `AuditLog.Read.All` | Audit log search, MFA registration reporting |
| `Reports.Read.All` | Mailbox usage, Teams activity, and other usage reports |
| `Mail.Read` | Mailbox-related reporting |

An account with at least the **User Administrator** or **Global Reader** Entra ID role (depending on script) is required. Destructive actions (`Remove-User.ps1`) require **User Administrator** or higher.

## Tested Environments

- Windows 11 + PowerShell 7.4
- Ubuntu 22.04 + PowerShell 7.4
- macOS Sonoma + PowerShell 7.4
