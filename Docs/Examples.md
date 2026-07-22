# Examples

## Connect once per session

```powershell
.\Connect-M365.ps1
```

## User Lifecycle

```powershell
.\Create-User.ps1 -DisplayName "Jane Doe" -UserPrincipalName "jane.doe@contoso.com" -MailNickname "jane.doe"
.\Assign-License.ps1 -UserPrincipalName "jane.doe@contoso.com" -SkuPartNumber "ENTERPRISEPACK"
.\Reset-Password.ps1 -UserPrincipalName "jane.doe@contoso.com"
.\Disable-User.ps1 -UserPrincipalName "jane.doe@contoso.com"
.\Remove-User.ps1 -UserPrincipalName "jane.doe@contoso.com" -WhatIf
```

## Bulk Onboarding

```powershell
.\Bulk-Create-Users.ps1 -CsvPath "..\Reports\SampleUsers.csv"
```

## Reporting

```powershell
.\Export-Users.ps1
.\Export-Licenses.ps1
.\Inactive-Users.ps1 -InactiveDaysThreshold 60
.\MFA-Status.ps1 -NotRegisteredOnly
.\Mailbox-Report.ps1 -Period D30
.\Teams-User-Report.ps1 -Period D30
.\OneDrive-Storage.ps1 -UserPrincipalName "jane.doe@contoso.com"
```

## Security & Audit

```powershell
.\Audit-Log-Search.ps1 -StartDate (Get-Date).AddDays(-7)
.\Security-Report.ps1
```

All reports are written as CSVs to `/Reports`; every action is logged to `/Logs`.
