# Troubleshooting

## "No active Microsoft Graph session"

Run `Scripts/Connect-M365.ps1` before any other script in the same PowerShell session.

## "Missing required module(s)"

Install the module named in the error:
```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

## Consent / Permission Errors

Your account (or the app registration, for app-only auth) needs the scopes listed
in `Docs/Authentication.md` and `requirements.md`. An Entra ID admin may need to
grant consent the first time a scope is requested.

## Script Exits with Code 1

Check the corresponding log file in `/Logs/<ScriptName>_<timestamp>.log` — every
script logs the full exception message on failure.

## PSScriptAnalyzer Failures in CI

Run locally before pushing:
```powershell
Invoke-ScriptAnalyzer -Path . -Recurse -Severity Warning,Error
```

## Rate Limiting (429 Too Many Requests)

Microsoft Graph throttles high-volume requests. Bulk scripts (`Bulk-Create-Users.ps1`)
process rows sequentially with progress reporting; for very large tenants, consider
batching via `Invoke-MgGraphRequest` batch endpoints.
