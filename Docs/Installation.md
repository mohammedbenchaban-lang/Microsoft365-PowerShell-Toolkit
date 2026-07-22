# Installation

## 1. Install PowerShell 7+

- **Windows**: `winget install --id Microsoft.PowerShell`
- **macOS**: `brew install --cask powershell`
- **Linux**: see [Microsoft's PowerShell install docs](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)

## 2. Install Required Modules

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module ExchangeOnlineManagement -Scope CurrentUser   # optional, for mailbox scripts
Install-Module PSScriptAnalyzer -Scope CurrentUser           # optional, for linting
```

## 3. Clone the Repository

```bash
git clone https://github.com/mohammedbenchaban-lang/Microsoft365-PowerShell-Toolkit.git
cd Microsoft365-PowerShell-Toolkit
```

## 4. Connect and Run

```powershell
cd Scripts
.\Connect-M365.ps1
.\Export-Users.ps1
```

Reports are written to `/Reports`, logs to `/Logs`.
