function Get-DLLPathsForPackagesUsingHashtable {
    <#
    .SYNOPSIS
    Using a hashtable of installed software package metadata, gets the path to the
    .dll file(s) within each software package that is most appropriate to use

    .DESCRIPTION
    Software packages contain .dll files for different .NET Framework versions. This
    function steps through each entry in the supplied hashtable. If a corresponding
    package is installed, then the path to the .dll file(s) within the package that is
    most appropriate to use is stored in the value of the hashtable entry corresponding
    to the software package.

    .PARAMETER ReferenceToHashtableOfInstalledPackages
    Is a reference to a hashtable. The hashtable must have keys that are the names of
    software packages with each key's value populated with
    Microsoft.PackageManagement.Packaging.SoftwareIdentity objects (the result of
    Get-Package). If a software package is not installed, the value of the hashtable
    entry should be $null.

    .PARAMETER ReferenceToHashtableOfSpecifiedDotNETVersions
    Is an optional parameter. If supplied, it must be a reference to a hashtable. The
    hashtable must have keys that are the names of software packages with each key's
    value populated with a string that is the version of .NET Framework that the
    software package is to be used with. If a key-value pair is not supplied in the
    hashtable for a given software package, the function will default to doing its best
    to select the most appropriate version of the software package given the current
    operating environment and PowerShell version.

    .PARAMETER ReferenceToHashtableOfEffectiveDotNETVersions
    Is initially a reference to an empty hashtable. When execution completes, the
    hashtable will be populated with keys that are the names of the software packages
    specified in the hashtable referenced by the
    ReferenceToHashtableOfInstalledPackages parameter. The value of each entry will be
    a string that is the folder corresponding to the version of .NET that makes the
    most sense given the current platform and .NET Framework version. If no suitable
    folder is found, the value of the hashtable entry remains an empty string.

    For example, reference the following folder name taxonomy at nuget.org:
    https://www.nuget.org/packages/System.Text.Json#supportedframeworks-body-tab

    .PARAMETER ReferenceToHashtableOfDLLPaths
    Is initially a reference to an empty hashtable. When execution completes, the
    hashtable will be populated with keys that are the names of the software packages
    specified in the hashtable referenced by the
    ReferenceToHashtableOfInstalledPackages parameter. The value of each entry will be
    an array populated with the path to the .dll file(s) within the package that are
    most appropriate to use, given the current platform and .NET Framework version.
    If no suitable DLL file is found, the array will be empty.

    .EXAMPLE
    $hashtablePackageNameToInstalledPackageMetadata = @{}
    $hashtablePackageNameToInstalledPackageMetadata.Add('Azure.Core', $null)
    $hashtablePackageNameToInstalledPackageMetadata.Add('Microsoft.Identity.Client', $null)
    $hashtablePackageNameToInstalledPackageMetadata.Add('Azure.Identity', $null)
    $hashtablePackageNameToInstalledPackageMetadata.Add('Accord', $null)
    $refHashtablePackageNameToInstalledPackages = [ref]$hashtablePackageNameToInstalledPackageMetadata
    Get-PackagesUsingHashtable -ReferenceToHashtable $refHashtablePackageNameToInstalledPackages
    $hashtableCustomNotInstalledMessageToPackageNames = @{}
    $strAzureIdentityNotInstalledMessage = 'Azure.Core, Microsoft.Identity.Client, and/or Azure.Identity packages were not found. Please install the Azure.Identity package and its dependencies and then try again.' + [System.Environment]::NewLine + 'You can install the Azure.Identity package and its dependencies by running the following command:' + [System.Environment]::NewLine + 'Install-Package -ProviderName NuGet -Name 'Azure.Identity' -Force -Scope CurrentUser;' + [System.Environment]::NewLine + [System.Environment]::NewLine
    $hashtableCustomNotInstalledMessageToPackageNames.Add($strAzureIdentityNotInstalledMessage, @('Azure.Core', 'Microsoft.Identity.Client', 'Azure.Identity'))
    $refhashtableCustomNotInstalledMessageToPackageNames = [ref]$hashtableCustomNotInstalledMessageToPackageNames
    $boolResult = Test-PackageInstalledUsingHashtable -ReferenceToHashtableOfInstalledPackages $refHashtablePackageNameToInstalledPackages -ThrowErrorIfPackageNotInstalled -ReferenceToHashtableOfCustomNotInstalledMessages $refhashtableCustomNotInstalledMessageToPackageNames
    if ($boolResult -eq $false) { return }
    $hashtablePackageNameToEffectiveDotNETVersions = @{}
    $refHashtablePackageNameToEffectiveDotNETVersions = [ref]$hashtablePackageNameToEffectiveDotNETVersions
    $hashtablePackageNameToDLLPaths = @{}
    $refHashtablePackageNameToDLLPaths = [ref]$hashtablePackageNameToDLLPaths
    Get-DLLPathsForPackagesUsingHashtable -ReferenceToHashtableOfInstalledPackages $refHashtablePackageNameToInstalledPackages -ReferenceToHashtableOfEffectiveDotNETVersions $refHashtablePackageNameToEffectiveDotNETVersions -ReferenceToHashtableOfDLLPaths $refHashtablePackageNameToDLLPaths

    This example checks each of the four software packages specified. For each software
    package specified, if the software package is installed, the value of the hashtable
    entry will be set to the path to the .dll file(s) within the package that are most
    appropriate to use, given the current platform and .NET Framework version. If no
    suitable DLL file is found, the value of the hashtable entry remains an empty array
    (@()).

    .OUTPUTS
    None

    .NOTES
    Requires PowerShell v5.0 or newer
    #>

    #region License ################################################################
    # Copyright (c) 2024 Frank Lesniak
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy of
    # this software and associated documentation files (the "Software"), to deal in the
    # Software without restriction, including without limitation the rights to use,
    # copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
    # Software, and to permit persons to whom the Software is furnished to do so,
    # subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all
    # copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    # FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    # COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
    # AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #endregion License ################################################################

    #region DownloadLocationNotice  ################################################
    # The most up-to-date version of this script can be found on the author's GitHub
    # repository at https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice  ################################################

    # Version 1.1.20241225.0

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][ref]$ReferenceToHashtableOfInstalledPackages,
        [Parameter(Mandatory = $false)][ref]$ReferenceToHashtableOfSpecifiedDotNETVersions,
        [Parameter(Mandatory = $true)][ref]$ReferenceToHashtableOfEffectiveDotNETVersions,
        [Parameter(Mandatory = $true)][ref]$ReferenceToHashtableOfDLLPaths
    )

    function Get-PSVersion {
        # .SYNOPSIS
        # Returns the version of PowerShell that is running.
        #
        # .DESCRIPTION
        # The function outputs a [version] object representing the version of
        # PowerShell that is running.
        #
        # On versions of PowerShell greater than or equal to version 2.0, this
        # function returns the equivalent of $PSVersionTable.PSVersion
        #
        # PowerShell 1.0 does not have a $PSVersionTable variable, so this function
        # returns [version]('1.0') on PowerShell 1.0.
        #
        # .EXAMPLE
        # $versionPS = Get-PSVersion
        # # $versionPS now contains the version of PowerShell that is running. On
        # # versions of PowerShell greater than or equal to version 2.0, this
        # # function returns the equivalent of $PSVersionTable.PSVersion
        #
        # .INPUTS
        # None. You can't pipe objects to Get-PSVersion.
        #
        # .OUTPUTS
        # System.Version. Get-PSVersion returns a [version] value indiciating
        # the version of PowerShell that is running.
        #
        # .NOTES
        # Version: 1.0.20241225.0

        #region License ########################################################
        # Copyright (c) 2024 Frank Lesniak
        #
        # Permission is hereby granted, free of charge, to any person obtaining a
        # copy of this software and associated documentation files (the
        # "Software"), to deal in the Software without restriction, including
        # without limitation the rights to use, copy, modify, merge, publish,
        # distribute, sublicense, and/or sell copies of the Software, and to permit
        # persons to whom the Software is furnished to do so, subject to the
        # following conditions:
        #
        # The above copyright notice and this permission notice shall be included
        # in all copies or substantial portions of the Software.
        #
        # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
        # OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
        # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
        # NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
        # DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
        # OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
        # USE OR OTHER DEALINGS IN THE SOFTWARE.
        #endregion License ########################################################

        if (Test-Path variable:\PSVersionTable) {
            return ($PSVersionTable.PSVersion)
        } else {
            return ([version]('1.0'))
        }
    }

    $versionPS = Get-PSVersion
    if ($versionPS -lt ([version]'5.0')) {
        Write-Warning 'Get-DLLPathsForPackagesUsingHashtable requires PowerShell version 5.0 or newer.'
        return
    }

    $arrPackageNames = @(($ReferenceToHashtableOfInstalledPackages.Value).Keys)
    foreach ($strPackageName in $arrPackageNames) {
        ($ReferenceToHashtableOfEffectiveDotNETVersions.Value).Add($strPackageName, '')
        ($ReferenceToHashtableOfDLLPaths.Value).Add($strPackageName, @())
    }

    # Get the base folder path for each package
    $hashtablePackageNameToBaseFolderPath = @{}
    foreach ($strPackageName in $arrPackageNames) {
        if ($null -ne ($ReferenceToHashtableOfInstalledPackages.Value).Item($strPackageName)) {
            $strPackageFilePath = ($ReferenceToHashtableOfInstalledPackages.Value).Item($strPackageName).Source
            $strPackageFilePath = $strPackageFilePath.Replace('file:///', '')
            $strPackageFileParentFolderPath = [System.IO.Path]::GetDirectoryName($strPackageFilePath)

            $hashtablePackageNameToBaseFolderPath.Add($strPackageName, $strPackageFileParentFolderPath)
        }
    }

    # Determine the current platform
    $boolIsLinux = $false
    if (Test-Path variable:\IsLinux) {
        if ($IsLinux -eq $true) {
            $boolIsLinux = $true
        }
    }

    $boolIsMacOS = $false
    if (Test-Path variable:\IsMacOS) {
        if ($IsMacOS -eq $true) {
            $boolIsMacOS = $true
        }
    }

    if ($boolIsLinux -eq $true) {
        if (($versionPS -ge [version]'7.5') -and ($versionPS -lt [version]'7.6')) {
            # .NET 9.0
            $arrDotNETVersionPreferenceOrder = @('net9.0', 'net8.0', 'net7.0', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.4') -and ($versionPS -lt [version]'7.5')) {
            # .NET 8.0
            $arrDotNETVersionPreferenceOrder = @('net8.0', 'net7.0', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.3') -and ($versionPS -lt [version]'7.4')) {
            # .NET 7.0
            $arrDotNETVersionPreferenceOrder = @('net7.0', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.2') -and ($versionPS -lt [version]'7.3')) {
            # .NET 6.0
            $arrDotNETVersionPreferenceOrder = @('net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.1') -and ($versionPS -lt [version]'7.2')) {
            # .NET 5.0
            $arrDotNETVersionPreferenceOrder = @('net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.0') -and ($versionPS -lt [version]'7.1')) {
            # .NET Core 3.1
            $arrDotNETVersionPreferenceOrder = @('netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'6.2') -and ($versionPS -lt [version]'7.0')) {
            # .NET Core 2.1
            $arrDotNETVersionPreferenceOrder = @('netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'6.1') -and ($versionPS -lt [version]'6.2')) {
            # .NET Core 2.1
            $arrDotNETVersionPreferenceOrder = @('netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'6.0') -and ($versionPS -lt [version]'6.1')) {
            # .NET Core 2.0
            $arrDotNETVersionPreferenceOrder = @('netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } else {
            # A future, undefined version of PowerShell
            $arrDotNETVersionPreferenceOrder = @('net15.0', 'net14.0', 'net13.0', 'net12.0', 'net11.0', 'net10.0', 'net9.0', 'net8.0', 'net7.0', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        }
    } elseif ($boolIsMacOS -eq $true) {
        if (($versionPS -ge [version]'7.5') -and ($versionPS -lt [version]'7.6')) {
            # .NET 9.0
            $arrDotNETVersionPreferenceOrder = @('net9.0-macos', 'net9.0', 'net8.0-macos', 'net8.0', 'net7.0-macos', 'net7.0', 'net6.0-macos', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.4') -and ($versionPS -lt [version]'7.5')) {
            # .NET 8.0
            $arrDotNETVersionPreferenceOrder = @('net8.0-macos', 'net8.0', 'net7.0-macos', 'net7.0', 'net6.0-macos', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.3') -and ($versionPS -lt [version]'7.4')) {
            # .NET 7.0
            $arrDotNETVersionPreferenceOrder = @('net7.0-macos', 'net7.0', 'net6.0-macos', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.2') -and ($versionPS -lt [version]'7.3')) {
            # .NET 6.0
            $arrDotNETVersionPreferenceOrder = @('net6.0-macos', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.1') -and ($versionPS -lt [version]'7.2')) {
            # .NET 5.0
            $arrDotNETVersionPreferenceOrder = @('net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.0') -and ($versionPS -lt [version]'7.1')) {
            # .NET Core 3.1
            $arrDotNETVersionPreferenceOrder = @('netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'6.2') -and ($versionPS -lt [version]'7.0')) {
            # .NET Core 2.1
            $arrDotNETVersionPreferenceOrder = @('netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'6.1') -and ($versionPS -lt [version]'6.2')) {
            # .NET Core 2.1
            $arrDotNETVersionPreferenceOrder = @('netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'6.0') -and ($versionPS -lt [version]'6.1')) {
            # .NET Core 2.0
            $arrDotNETVersionPreferenceOrder = @('netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } else {
            # A future, undefined version of PowerShell
            $arrDotNETVersionPreferenceOrder = @('net15.0-macos', 'net15.0', 'net14.0-macos', 'net14.0', 'net13.0-macos', 'net13.0', 'net12.0-macos', 'net12.0', 'net11.0-macos', 'net11.0', 'net10.0-macos', 'net10.0', 'net9.0-macos', 'net9.0', 'net8.0-macos', 'net8.0', 'net7.0-macos', 'net7.0', 'net6.0-macos', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        }
    } else {
        # Windows
        if (($versionPS -ge [version]'7.5') -and ($versionPS -lt [version]'7.6')) {
            # .NET 9.0
            $arrDotNETVersionPreferenceOrder = @('net9.0-windows', 'net9.0', 'net8.0-windows', 'net8.0', 'net7.0-windows', 'net7.0', 'net6.0-windows', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.4') -and ($versionPS -lt [version]'7.5')) {
            # .NET 8.0
            $arrDotNETVersionPreferenceOrder = @('net8.0-windows', 'net8.0', 'net7.0-windows', 'net7.0', 'net6.0-windows', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.3') -and ($versionPS -lt [version]'7.4')) {
            # .NET 7.0
            $arrDotNETVersionPreferenceOrder = @('net7.0-windows', 'net7.0', 'net6.0-windows', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.2') -and ($versionPS -lt [version]'7.3')) {
            # .NET 6.0
            $arrDotNETVersionPreferenceOrder = @('net6.0-windows', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.1') -and ($versionPS -lt [version]'7.2')) {
            # .NET 5.0
            $arrDotNETVersionPreferenceOrder = @('net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'7.0') -and ($versionPS -lt [version]'7.1')) {
            # .NET Core 3.1
            $arrDotNETVersionPreferenceOrder = @('netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'6.2') -and ($versionPS -lt [version]'7.0')) {
            # .NET Core 2.1
            $arrDotNETVersionPreferenceOrder = @('netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'6.1') -and ($versionPS -lt [version]'6.2')) {
            # .NET Core 2.1
            $arrDotNETVersionPreferenceOrder = @('netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'6.0') -and ($versionPS -lt [version]'6.1')) {
            # .NET Core 2.0
            $arrDotNETVersionPreferenceOrder = @('netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        } elseif (($versionPS -ge [version]'5.0') -and ($versionPS -lt [version]'6.0')) {
            if ((Test-Path 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full') -eq $true) {
                $intDotNETFrameworkRelease = (Get-ItemPropertyValue -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release)
                # if ($intDotNETFrameworkRelease -ge 533320) {
                #     # .NET Framework 4.8.1
                #     $arrDotNETVersionPreferenceOrder = @('net481', 'net48', 'net472', 'net471', 'netstandard2.0', 'net47', 'net463', 'net462', 'net461', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4', 'net46', 'net452', 'net451', 'net45', 'net40')
                # } elseif ($intDotNETFrameworkRelease -ge 528040) {
                #     # .NET Framework 4.8
                #     $arrDotNETVersionPreferenceOrder = @('net48', 'net472', 'net471', 'netstandard2.0', 'net47', 'net463', 'net462', 'net461', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4', 'net46', 'net452', 'net451', 'net45', 'net40')
                # } elseif ($intDotNETFrameworkRelease -ge 461808) {
                #     # .NET Framework 4.7.2
                #     $arrDotNETVersionPreferenceOrder = @('net472', 'net471', 'netstandard2.0', 'net47', 'net463', 'net462', 'net461', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4', 'net46', 'net452', 'net451', 'net45', 'net40')
                # } elseif ($intDotNETFrameworkRelease -ge 461308) {
                #     # .NET Framework 4.7.1
                #     $arrDotNETVersionPreferenceOrder = @('net471', 'netstandard2.0', 'net47', 'net463', 'net462', 'net461', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4', 'net46', 'net452', 'net451', 'net45', 'net40')
                # } elseif ($intDotNETFrameworkRelease -ge 460798) {
                #     # .NET Framework 4.7
                #     $arrDotNETVersionPreferenceOrder = @('net47', 'net463', 'net462', 'net461', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4', 'net46', 'net452', 'net451', 'net45', 'net40')
                # } elseif ($intDotNETFrameworkRelease -ge 394802) {
                #     # .NET Framework 4.6.2
                #     $arrDotNETVersionPreferenceOrder = @('net462', 'net461', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4', 'net46', 'net452', 'net451', 'net45', 'net40')
                # } elseif ($intDotNETFrameworkRelease -ge 394254) {
                #     # .NET Framework 4.6.1
                #     $arrDotNETVersionPreferenceOrder = @('net461', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4', 'net46', 'net452', 'net451', 'net45', 'net40')
                # } elseif ($intDotNETFrameworkRelease -ge 393295) {
                #     # .NET Framework 4.6
                #     $arrDotNETVersionPreferenceOrder = @('net46', 'net452', 'net451', 'net45', 'net40')
                # } elseif ($intDotNETFrameworkRelease -ge 379893) {
                #     # .NET Framework 4.5.2
                #     $arrDotNETVersionPreferenceOrder = @('net452', 'net451', 'net45', 'net40')
                # } elseif ($intDotNETFrameworkRelease -ge 378675) {
                #     # .NET Framework 4.5.1
                #     $arrDotNETVersionPreferenceOrder = @('net451', 'net45', 'net40')
                # } elseif ($intDotNETFrameworkRelease -ge 378389) {
                #     # .NET Framework 4.5
                #     $arrDotNETVersionPreferenceOrder = @('net45', 'net40')
                # } else {
                #     # .NET Framework 4.5 or newer not found?
                #     # This should not be possible since this function requires
                #     # PowerShell 5.0 or newer, PowerShell 5.0 requires WMF 5.0, and
                #     # WMF 5.0 requires .NET Framework 4.5 or newer.
                #     Write-Warning 'The .NET Framework 4.5 or newer was not found. This should not be possible since this function requires PowerShell 5.0 or newer, PowerShell 5.0 requires WMF 5.0, and WMF 5.0 requires .NET Framework 4.5 or newer.'
                #     return
                # }
                if ($intDotNETFrameworkRelease -ge 533320) {
                    # .NET Framework 4.8.1
                    $arrDotNETVersionPreferenceOrder = @('net481', 'net48', 'net472', 'net471', 'net47', 'net463', 'net462', 'net461', 'net46', 'net452', 'net451', 'net45', 'net40', 'netstandard2.0', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4')
                } elseif ($intDotNETFrameworkRelease -ge 528040) {
                    # .NET Framework 4.8
                    $arrDotNETVersionPreferenceOrder = @('net48', 'net472', 'net471', 'net47', 'net463', 'net462', 'net461', 'net46', 'net452', 'net451', 'net45', 'net40', 'netstandard2.0', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4')
                } elseif ($intDotNETFrameworkRelease -ge 461808) {
                    # .NET Framework 4.7.2
                    $arrDotNETVersionPreferenceOrder = @('net472', 'net471', 'net47', 'net463', 'net462', 'net461', 'net46', 'net452', 'net451', 'net45', 'net40', 'netstandard2.0', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4')
                } elseif ($intDotNETFrameworkRelease -ge 461308) {
                    # .NET Framework 4.7.1
                    $arrDotNETVersionPreferenceOrder = @('net471', 'net47', 'net463', 'net462', 'net461', 'net46', 'net452', 'net451', 'net45', 'net40', 'netstandard2.0', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4')
                } elseif ($intDotNETFrameworkRelease -ge 460798) {
                    # .NET Framework 4.7
                    $arrDotNETVersionPreferenceOrder = @('net47', 'net463', 'net462', 'net461', 'net46', 'net452', 'net451', 'net45', 'net40', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4')
                } elseif ($intDotNETFrameworkRelease -ge 394802) {
                    # .NET Framework 4.6.2
                    $arrDotNETVersionPreferenceOrder = @('net462', 'net461', 'net46', 'net452', 'net451', 'net45', 'net40', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4')
                } elseif ($intDotNETFrameworkRelease -ge 394254) {
                    # .NET Framework 4.6.1
                    $arrDotNETVersionPreferenceOrder = @('net461', 'net46', 'net452', 'net451', 'net45', 'net40', 'netstandard1.6', 'netstandard1.5', 'netstandard1.4')
                } elseif ($intDotNETFrameworkRelease -ge 393295) {
                    # .NET Framework 4.6
                    $arrDotNETVersionPreferenceOrder = @('net46', 'net452', 'net451', 'net45', 'net40')
                } elseif ($intDotNETFrameworkRelease -ge 379893) {
                    # .NET Framework 4.5.2
                    $arrDotNETVersionPreferenceOrder = @('net452', 'net451', 'net45', 'net40')
                } elseif ($intDotNETFrameworkRelease -ge 378675) {
                    # .NET Framework 4.5.1
                    $arrDotNETVersionPreferenceOrder = @('net451', 'net45', 'net40')
                } elseif ($intDotNETFrameworkRelease -ge 378389) {
                    # .NET Framework 4.5
                    $arrDotNETVersionPreferenceOrder = @('net45', 'net40')
                } else {
                    # .NET Framework 4.5 or newer not found?
                    # This should not be possible since this function requires
                    # PowerShell 5.0 or newer, PowerShell 5.0 requires WMF 5.0, and
                    # WMF 5.0 requires .NET Framework 4.5 or newer.
                    Write-Warning 'The .NET Framework 4.5 or newer was not found. This should not be possible since this function requires PowerShell 5.0 or newer, PowerShell 5.0 requires WMF 5.0, and WMF 5.0 requires .NET Framework 4.5 or newer.'
                    return
                }
            }
        } else {
            # A future, undefined version of PowerShell
            $arrDotNETVersionPreferenceOrder = @('net15.0-windows', 'net15.0', 'net14.0-windows', 'net14.0', 'net13.0-windows', 'net13.0', 'net12.0-windows', 'net12.0', 'net11.0-windows', 'net11.0', 'net10.0-windows', 'net10.0', 'net9.0-windows', 'net9.0', 'net8.0-windows', 'net8.0', 'net7.0-windows', 'net7.0', 'net6.0-windows', 'net6.0', 'net5.0', 'netcoreapp3.1', 'netcoreapp3.0', 'netstandard2.1', 'netcoreapp2.2', 'netcoreapp2.1', 'netcoreapp2.0', 'netstandard2.0', 'netcoreapp1.1', 'netcoreapp1.0', 'netstandard1.6')
        }
    }

    foreach ($strPackageName in $arrPackageNames) {
        if ($null -ne $hashtablePackageNameToBaseFolderPath.Item($strPackageName)) {
            $strBaseFolderPath = ($hashtablePackageNameToBaseFolderPath.Item($strPackageName))

            $strDLLFolderPath = ''
            if ($null -ne $ReferenceToHashtableOfSpecifiedDotNETVersions) {
                if ($null -ne ($ReferenceToHashtableOfSpecifiedDotNETVersions.Value).Item($strPackageName)) {
                    $strDotNETVersion = ($ReferenceToHashtableOfSpecifiedDotNETVersions.Value).Item($strPackageName)

                    if ([string]::IsNullOrEmpty($strDotNETVersion) -eq $false) {
                        $strDLLFolderPath = Join-Path -Path $strBaseFolderPath -ChildPath 'lib'
                        $strDLLFolderPath = Join-Path -Path $strDLLFolderPath -ChildPath $strDotNETVersion

                        # Search this folder for .dll files and add them to the array
                        if (Test-Path -Path $strDLLFolderPath -PathType Container) {
                            $arrDLLFiles = @(Get-ChildItem -Path $strDLLFolderPath -Filter '*.dll' -File -Recurse)
                            if ($arrDLLFiles.Count -gt 0) {
                                # One or more DLL files found
                                ($ReferenceToHashtableOfEffectiveDotNETVersions.Value).Item($strPackageName) = $strDotNETVersion
                                ($ReferenceToHashtableOfDLLPaths.Value).Item($strPackageName) = @($arrDLLFiles | ForEach-Object {
                                        $_.FullName
                                    })
                            }
                        } else {
                            # The specified .NET version folder does not exist
                            # Set the DLL folder path to an empty string to then do a
                            # search for a usable folder
                            $strDLLFolderPath = ''
                        }
                    }
                }
            }

            if ([string]::IsNullOrEmpty($strDLLFolderPath)) {
                # Do a search for a usable folder

                foreach ($strDotNETVersion in $arrDotNETVersionPreferenceOrder) {
                    $strDLLFolderPath = Join-Path -Path $strBaseFolderPath -ChildPath 'lib'
                    $strDLLFolderPath = Join-Path -Path $strDLLFolderPath -ChildPath $strDotNETVersion

                    if (Test-Path -Path $strDLLFolderPath -PathType Container) {
                        $arrDLLFiles = @(Get-ChildItem -Path $strDLLFolderPath -Filter '*.dll' -File -Recurse)
                        if ($arrDLLFiles.Count -gt 0) {
                            # One or more DLL files found
                            ($ReferenceToHashtableOfEffectiveDotNETVersions.Value).Item($strPackageName) = $strDotNETVersion
                            ($ReferenceToHashtableOfDLLPaths.Value).Item($strPackageName) = @($arrDLLFiles | ForEach-Object {
                                    $_.FullName
                                })
                            break
                        }
                    }
                }
            }
        }
    }
}
