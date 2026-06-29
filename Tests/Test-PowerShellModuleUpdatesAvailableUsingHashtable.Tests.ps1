[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', '', Justification = 'Pester commands are test-time dependencies loaded by Invoke-Pester.')]
param ()

BeforeAll {
    $strParentPath = Split-Path -Path $PSScriptRoot -Parent
    . (Join-Path -Path $strParentPath -ChildPath 'Test-PowerShellModuleUpdatesAvailableUsingHashtable.ps1')

    function Get-InstalledModuleFixture {
        param (
            [version]$Version
        )

        [pscustomobject]@{
            Version = $Version
        }
    }
}

Describe 'Test-PowerShellModuleUpdatesAvailableUsingHashtable' {
    BeforeEach {
        $script:FindModuleVersions = @{}

        Mock -CommandName Find-Module -MockWith {
            param (
                [string]$Name
            )

            if ($script:FindModuleVersions.ContainsKey($Name)) {
                [pscustomobject]@{
                    Version = $script:FindModuleVersions.Item($Name)
                }
            }
        }
    }

    It 'leaves fresh output arrays empty when no modules are supplied' {
        $hashtableModuleNameToInstalledModules = @{}
        $arrMissingModule = @()
        $arrOutOfDateModule = @()

        $boolResult = Test-PowerShellModuleUpdatesAvailableUsingHashtable -ReferenceToHashtableOfInstalledModules ([ref]$hashtableModuleNameToInstalledModules) -ReferenceToArrayOfMissingModules ([ref]$arrMissingModule) -ReferenceToArrayOfOutOfDateModules ([ref]$arrOutOfDateModule) -DoNotCheckPowerShellVersion

        $boolResult | Should -BeTrue
        @($arrMissingModule).Count | Should -Be 0
        @($arrOutOfDateModule).Count | Should -Be 0
    }

    It 'adds one missing module to a fresh output array' {
        $hashtableModuleNameToInstalledModules = @{
            'Missing.Module' = @()
        }
        $arrMissingModule = @()
        $arrOutOfDateModule = @()

        $boolResult = Test-PowerShellModuleUpdatesAvailableUsingHashtable -ReferenceToHashtableOfInstalledModules ([ref]$hashtableModuleNameToInstalledModules) -ReferenceToArrayOfMissingModules ([ref]$arrMissingModule) -ReferenceToArrayOfOutOfDateModules ([ref]$arrOutOfDateModule) -DoNotCheckPowerShellVersion

        $boolResult | Should -BeFalse
        @($arrMissingModule).Count | Should -Be 1
        $arrMissingModule[0] | Should -Be 'Missing.Module'
        @($arrOutOfDateModule).Count | Should -Be 0
    }

    It 'adds one out-of-date module to a fresh output array' {
        $script:FindModuleVersions = @{
            'Old.Module' = '2.0.0'
        }
        $hashtableModuleNameToInstalledModules = @{
            'Old.Module' = @(Get-InstalledModuleFixture -Version ([version]'1.0.0'))
        }
        $arrMissingModule = @()
        $arrOutOfDateModule = @()

        $boolResult = Test-PowerShellModuleUpdatesAvailableUsingHashtable -ReferenceToHashtableOfInstalledModules ([ref]$hashtableModuleNameToInstalledModules) -ReferenceToArrayOfMissingModules ([ref]$arrMissingModule) -ReferenceToArrayOfOutOfDateModules ([ref]$arrOutOfDateModule) -DoNotCheckPowerShellVersion

        $boolResult | Should -BeFalse
        @($arrMissingModule).Count | Should -Be 0
        @($arrOutOfDateModule).Count | Should -Be 1
        $arrOutOfDateModule[0] | Should -Be 'Old.Module'
    }

    It 'appends module names after caller-seeded array contents' {
        $script:FindModuleVersions = @{
            'Old.Module' = '2.0.0'
        }
        $hashtableModuleNameToInstalledModules = @{
            'Old.Module' = @(Get-InstalledModuleFixture -Version ([version]'1.0.0'))
        }
        $arrMissingModule = @('Already.Missing')
        $arrOutOfDateModule = @('Already.OutOfDate')

        $boolResult = Test-PowerShellModuleUpdatesAvailableUsingHashtable -ReferenceToHashtableOfInstalledModules ([ref]$hashtableModuleNameToInstalledModules) -ReferenceToArrayOfMissingModules ([ref]$arrMissingModule) -ReferenceToArrayOfOutOfDateModules ([ref]$arrOutOfDateModule) -DoNotCheckPowerShellVersion

        $boolResult | Should -BeFalse
        @($arrMissingModule).Count | Should -Be 1
        $arrMissingModule[0] | Should -Be 'Already.Missing'
        @($arrOutOfDateModule).Count | Should -Be 2
        $arrOutOfDateModule[0] | Should -Be 'Already.OutOfDate'
        $arrOutOfDateModule[1] | Should -Be 'Old.Module'
    }

    It 'does not write when output references point to null' {
        $hashtableModuleNameToInstalledModules = @{
            'Missing.Module' = @()
        }
        $arrMissingModule = $null
        $arrOutOfDateModule = $null

        {
            Test-PowerShellModuleUpdatesAvailableUsingHashtable -ReferenceToHashtableOfInstalledModules ([ref]$hashtableModuleNameToInstalledModules) -ReferenceToArrayOfMissingModules ([ref]$arrMissingModule) -ReferenceToArrayOfOutOfDateModules ([ref]$arrOutOfDateModule) -DoNotCheckPowerShellVersion
        } | Should -Not -Throw

        $arrMissingModule | Should -BeNullOrEmpty
        $arrOutOfDateModule | Should -BeNullOrEmpty
    }
}
