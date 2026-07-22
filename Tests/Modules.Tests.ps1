#Requires -Module Pester
<#
.SYNOPSIS
    Sample Pester tests validating the shared toolkit modules load and export expected functions.
#>

BeforeAll {
    $ModuleRoot = Join-Path -Path $PSScriptRoot -ChildPath "../Modules"
    Import-Module (Join-Path $ModuleRoot "Logging.psm1") -Force
    Import-Module (Join-Path $ModuleRoot "Validation.psm1") -Force
    Import-Module (Join-Path $ModuleRoot "Helpers.psm1") -Force
}

Describe "Validation module" {
    It "Recognizes a valid email address" {
        Test-EmailFormat -EmailAddress "jane.doe@contoso.com" | Should -Be $true
    }

    It "Rejects an invalid email address" {
        Test-EmailFormat -EmailAddress "not-an-email" | Should -Be $false
    }

    It "Throws on empty required parameter" {
        { Assert-NotNullOrEmpty -Value "" -ParameterName "Test" } | Should -Throw
    }
}

Describe "Helpers module" {
    It "Returns the correct Success exit code" {
        Get-ToolkitExitCode -Name "Success" | Should -Be 0
    }

    It "Returns the correct GeneralError exit code" {
        Get-ToolkitExitCode -Name "GeneralError" | Should -Be 1
    }
}
