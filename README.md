<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:0078D4,100:00A4EF&height=220&section=header&text=Microsoft365-PowerShell-Toolkit&fontSize=32&fontColor=ffffff&animation=fadeIn&desc=Production-Style%20M365%20Administration%20%26%20Security%20Automation&descAlignY=62&descSize=16" />
</div>

<div align="center">

![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Microsoft Graph](https://img.shields.io/badge/Microsoft%20Graph-SDK-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![PSScriptAnalyzer](https://img.shields.io/github/actions/workflow/status/mohammedbenchaban-lang/Microsoft365-PowerShell-Toolkit/psscriptanalyzer.yml?label=PSScriptAnalyzer&style=for-the-badge)
![Tests](https://img.shields.io/github/actions/workflow/status/mohammedbenchaban-lang/Microsoft365-PowerShell-Toolkit/tests.yml?label=Tests&style=for-the-badge)

</div>

---

## 📋 Overview

**Microsoft365-PowerShell-Toolkit** is a production-style PowerShell 7 toolkit for day-to-day Microsoft 365 administration, built entirely on the **Microsoft Graph PowerShell SDK** with modern authentication. It's designed the way a Microsoft 365 Support Engineer, Azure Support Engineer, or Security Analyst would actually structure internal tooling: consistent logging, input validation, graceful error handling, and CSV reporting across every script.

This repo intentionally mirrors real support/admin workflows — user lifecycle management, licensing, mailbox and Teams reporting, MFA compliance, audit log search, and a consolidated security report — rather than one-off snippets.

---

## ✨ Features

- 🔐 **Modern authentication only** — no basic auth, no hardcoded credentials, app-only auth supported for automation
- 🧩 **21 scripts** across user lifecycle, licensing, mailbox, Teams, OneDrive, audit, and security domains
- 🧱 **Shared module architecture** (`Logging`, `Validation`, `GraphConnection`, `Helpers`) — no copy-pasted boilerplate
- 🎨 **Colored, leveled console output** (INFO / SUCCESS / WARNING / ERROR) plus persistent file logs per run
- ✅ **Input validation** (email format, required modules, CSV schema checks) before any Graph call is made
- 🛟 **Graceful error handling** with try/catch and standardized exit codes for automation pipelines
- 📊 **CSV reporting** written to `/Reports` for every reporting script
- 📈 **Progress bars** (`Write-Progress`) on long-running and bulk operations
- 🧪 **CI/CD**: PSScriptAnalyzer linting, Pester tests, format checks, automated releases, and doc generation via GitHub Actions
- 📚 **Full documentation set** — installation, authentication model, usage examples, troubleshooting

---

## 🖼️ Screenshots

> Screenshots are illustrative placeholders — replace with real terminal captures from your tenant.

| Console Output | CSV Report |
|---|---|
| `[INFO] Connecting to Microsoft Graph...`<br>`[SUCCESS] Connected to tenant: contoso.onmicrosoft.com` | `Reports/Users_20260722_190000.csv` |

---

## 🚀 Installation

```powershell
# 1. Install the Microsoft Graph SDK
Install-Module Microsoft.Graph -Scope CurrentUser

# 2. Clone the repository
git clone https://github.com/mohammedbenchaban-lang/Microsoft365-PowerShell-Toolkit.git
cd Microsoft365-PowerShell-Toolkit/Scripts

# 3. Connect and run
.\Connect-M365.ps1
.\Export-Users.ps1
```

See [`Docs/Installation.md`](Docs/Installation.md) for full setup, including Exchange Online and CI prerequisites.

---

## 📦 Prerequisites

| Requirement | Notes |
|---|---|
| PowerShell 7.0+ | Cross-platform (Windows/macOS/Linux) |
| Microsoft.Graph SDK | `Install-Module Microsoft.Graph` |
| ExchangeOnlineManagement | Only for `Create-SharedMailbox.ps1`, `Archive-Mailbox.ps1` |
| Entra ID role | User Administrator (write scripts) or Global Reader (reporting scripts) |

Full detail in [`requirements.md`](requirements.md).

---

## 🔑 Microsoft Graph Permissions

| Scope | Used By |
|---|---|
| `User.ReadWrite.All` | Create/Remove/Disable/Enable/Reset-Password |
| `Directory.ReadWrite.All` | License assignment, group membership |
| `AuditLog.Read.All` | Audit-Log-Search, MFA-Status |
| `Reports.Read.All` | Mailbox-Report, Teams-User-Report |
| `Mail.Read` | Mailbox-related reporting |

See [`Docs/Authentication.md`](Docs/Authentication.md) for the full modern-auth flow and app-only setup for automation.

---

## 💡 Examples

```powershell
.\Create-User.ps1 -DisplayName "Jane Doe" -UserPrincipalName "jane.doe@contoso.com" -MailNickname "jane.doe"
.\Assign-License.ps1 -UserPrincipalName "jane.doe@contoso.com" -SkuPartNumber "ENTERPRISEPACK"
.\Bulk-Create-Users.ps1 -CsvPath "..\Reports\SampleUsers.csv"
.\Inactive-Users.ps1 -InactiveDaysThreshold 60
.\MFA-Status.ps1 -NotRegisteredOnly
.\Security-Report.ps1
```

More in [`Docs/Examples.md`](Docs/Examples.md).

---

## 📁 Folder Structure

```
Microsoft365-PowerShell-Toolkit/
├── Scripts/      → 21 standalone, executable admin/reporting scripts
├── Modules/      → Shared Logging, Validation, GraphConnection, Helpers modules
├── Reports/      → Generated CSV reports + sample data
├── Logs/         → Per-run execution logs
├── Docs/         → Installation, Authentication, Examples, Troubleshooting
├── Tests/        → Pester tests for shared modules
└── .github/workflows/ → CI: lint, test, format-check, release, doc-gen
```

---

## 🗺️ Roadmap

- [ ] Conditional Access policy reporting script
- [ ] Intune device compliance report
- [ ] Parallel processing for bulk scripts (`ForEach-Object -Parallel`)
- [ ] Pester test coverage for every script (not just modules)
- [ ] PowerShell Gallery module packaging

---

## 🤝 Contributing

Contributions are welcome — see [`CONTRIBUTING.md`](CONTRIBUTING.md) for coding standards, the PR process, and how CI validates changes.

---

## 📄 License

MIT — see [`LICENSE`](LICENSE).

---

## 🔮 Future Improvements

- Azure Key Vault integration for app-only credential storage
- Dashboard (Power BI / HTML) consuming the CSV reports directly
- Scheduled execution examples via Azure Automation / GitHub Actions cron

---

<div align="center">

**Author:** Mohammed Chems Eddine Benchabane — Materials Design and Logistics student, exploring Microsoft 365 / Support Engineering roles

[![LinkedIn](https://img.shields.io/badge/LINKEDIN-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/mohammed-chems-eddine-benchabane-6ba123388)

</div>

<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:00A4EF,100:0078D4&height=100&section=footer" />
</div>
