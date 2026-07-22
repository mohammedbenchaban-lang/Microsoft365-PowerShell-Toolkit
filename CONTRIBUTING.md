# Contributing to Microsoft365-PowerShell-Toolkit

Thanks for considering a contribution! This project welcomes issues and pull requests.

## Getting Started

1. Fork the repository and create a feature branch from `main`.
2. Install PowerShell 7+ and the Microsoft Graph PowerShell SDK:
   ```powershell
   Install-Module Microsoft.Graph -Scope CurrentUser
   ```
3. Follow the existing script structure (see any file in `/Scripts` as a reference):
   - Comment-based help (`SYNOPSIS`, `DESCRIPTION`, `EXAMPLE`, `NOTES`)
   - `[CmdletBinding(SupportsShouldProcess = $true)]`
   - Input validation via `Modules/Validation.psm1`
   - Logging via `Modules/Logging.psm1`
   - Try/catch with a meaningful exit code from `Modules/Helpers.psm1`

## Code Style

- Run `Invoke-ScriptAnalyzer -Path . -Recurse` before submitting a PR and resolve all warnings.
- Use approved PowerShell verbs (`Get-`, `Set-`, `New-`, `Remove-`, etc.).
- Keep functions single-purpose; prefer composing existing module functions over duplicating logic.

## Submitting Changes

1. Ensure your branch passes the `PSScriptAnalyzer` and `Tests` GitHub Actions workflows.
2. Update `CHANGELOG.md` under an `[Unreleased]` section.
3. Open a pull request describing the change, the motivation, and how it was tested.

## Reporting Issues

Please include:
- PowerShell version (`$PSVersionTable`)
- Microsoft.Graph module version (`Get-Module Microsoft.Graph -ListAvailable`)
- Steps to reproduce and the full error output (redact tenant-specific data)
