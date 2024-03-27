function Test-PackageInstalledUsingHashtable {
    <#
    .SYNOPSIS
    Tests to see if a software package (typically a NuGet package) is installed based
    on entries in a hashtable. If the software package is not installed, an error or
    warning message may optionally be displayed.

    .DESCRIPTION
    The Test-PackageInstalledUsingHashtable function steps through each entry in the
    supplied hashtable and, if there are any software packages not installed, it
    optionally throws an error or warning for each software package that is not
    installed. If all software packages are installed, the function returns $true;
    otherwise, if any software package is not installed, the function returns $false.

    .PARAMETER ReferenceToHashtableOfInstalledPackages
    Is a reference to a hashtable. The hashtable must have keys that are the names of
    software packages with each key's value populated with
    Microsoft.PackageManagement.Packaging.SoftwareIdentity objects (the result of
    Get-Package). If a software package is not installed, the value of the hashtable
    entry should be $null.

    .PARAMETER ReferenceToHashtableOfSkippingDependencies
    Is a reference to a hashtable. The hashtable must have keys that are the names of
    software packages with each key's value populated with a boolean value. The boolean
    indicates whether the software package should be installed without its
    dependencies. Generally, dependencies should not be skipped, so the default value
    for each key should be $false. However, sometimes the Install-Package command
    throws an erroneous dependency loop error, but in investigating its dependencies in
    the package's .nuspec file, you may find that the version of .NET that you will use
    has no dependencies. In this case, it's safe to use -SkipDependencies.

    This can also be verified here:
    https://www.nuget.org/packages/<PackageName>/#dependencies-body-tab

    If this parameter is not supplied, or if a key-value pair is not supplied in the
    hashtable for a given software package, the script will default to not skipping the
    software package's dependencies.

    .PARAMETER ThrowErrorIfPackageNotInstalled
    Is a switch parameter. If this parameter is specified, an error is thrown for each
    software package that is not installed. If this parameter is not specified, no
    error is thrown.

    .PARAMETER ThrowWarningIfPackageNotInstalled
    Is a switch parameter. If this parameter is specified, a warning is thrown for each
    software package that is not installed. If this parameter is not specified, or if
    the ThrowErrorIfPackageNotInstalled parameter was specified, no warning is thrown.

    .PARAMETER ReferenceToHashtableOfCustomNotInstalledMessages
    Is a reference to a hashtable. The hashtable must have keys that are custom error
    or warning messages (string) to be displayed if one or more software packages are
    not installed. The value for each key must be an array of software package names
    (strings) relevant to that error or warning message.

    If this parameter is not supplied, or if a custom error or warning message is not
    supplied in the hashtable for a given software package, the script will default to
    using the following message:

    <PACKAGENAME> software package not found. Please install it and then try again.
    You can install the <PACKAGENAME> software package by running the following
    command:
    Install-Package -ProviderName NuGet -Name <PACKAGENAME> -Force -Scope CurrentUser;

    .PARAMETER ReferenceToArrayOfMissingPackages
    Is a reference to an array. The array must be initialized to be empty. If any
    software packages are not installed, the names of those software packages are added
    to the array.

    .EXAMPLE
    $hashtablePackageNameToInstalledPackageMetadata = @{}
    $hashtablePackageNameToInstalledPackageMetadata.Add('Azure.Core', $null)
    $hashtablePackageNameToInstalledPackageMetadata.Add('Microsoft.Identity.Client', $null)
    $hashtablePackageNameToInstalledPackageMetadata.Add('Azure.Identity', $null)
    $hashtablePackageNameToInstalledPackageMetadata.Add('Accord', $null)
    $refHashtablePackageNameToInstalledPackages = [ref]$hashtablePackageNameToInstalledPackageMetadata
    Get-PackagesUsingHashtable -ReferenceToHashtable $refHashtablePackageNameToInstalledPackages
    $hashtableCustomNotInstalledMessageToPackageNames = @{}
    $strAzureIdentityNotInstalledMessage = 'Azure.Core, Microsoft.Identity.Client, and/or Azure.Identity packages were not found. Please install the Azure.Identity package and its dependencies and then try again.' + [System.Environment]::NewLine + 'You can install the Azure.Identity package and its dependencies by running the following command:' + [System.Environment]::NewLine + 'Install-Package -ProviderName NuGet -Name ''Azure.Identity'' -Force -Scope CurrentUser;' + [System.Environment]::NewLine + [System.Environment]::NewLine
    $hashtableCustomNotInstalledMessageToPackageNames.Add($strAzureIdentityNotInstalledMessage, @('Azure.Core', 'Microsoft.Identity.Client', 'Azure.Identity'))
    $refhashtableCustomNotInstalledMessageToPackageNames = [ref]$hashtableCustomNotInstalledMessageToPackageNames
    $boolResult = Test-PackageInstalledUsingHashtable -ReferenceToHashtableOfInstalledPackages $refHashtablePackageNameToInstalledPackages -ThrowErrorIfPackageNotInstalled -ReferenceToHashtableOfCustomNotInstalledMessages $refhashtableCustomNotInstalledMessageToPackageNames

    This example checks to see if the Azure.Core, Microsoft.Identity.Client,
    Azure.Identity, and Accord packages are installed. If any of these packages are not
    installed, an error is thrown and $boolResult is set to $false. Because a custom
    error message was specified for the Azure.Core, Microsoft.Identity.Client, and
    Azure.Identity packages, if any one of those is missing, the custom error message
    is thrown just once. However, if Accord is missing, a separate error message would
    be thrown. If all packages are installed, $boolResult is set to $true.

    .OUTPUTS
    [boolean] - Returns $true if all Packages are installed; otherwise, returns $false.
    #>

    #region License
    # Copyright 2024 Frank Lesniak
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy of this
    # software and associated documentation files (the “Software”), to deal in the
    # Software without restriction, including without limitation the rights to use, copy,
    # modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
    # and to permit persons to whom the Software is furnished to do so, subject to the
    # following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all
    # copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    # INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
    # PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
    # CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    # OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #endregion License

    #region DownloadLocationNotice
    # The most up-to-date version of this script can be found on the author's GitHub repository
    # at https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice

    # Version 1.0.20240326.0

    [CmdletBinding()]
    [OutputType([Boolean])]
    param (
        [Parameter(Mandatory = $true)][ref]$ReferenceToHashtableOfInstalledPackages,
        [Parameter(Mandatory = $false)][ref]$ReferenceToHashtableOfSkippingDependencies,
        [Parameter(Mandatory = $false)][switch]$ThrowErrorIfPackageNotInstalled,
        [Parameter(Mandatory = $false)][switch]$ThrowWarningIfPackageNotInstalled,
        [Parameter(Mandatory = $false)][ref]$ReferenceToHashtableOfCustomNotInstalledMessages,
        [Parameter(Mandatory = $false)][ref]$ReferenceToArrayOfMissingPackages
    )

    $boolThrowErrorForMissingPackage = $false
    $boolThrowWarningForMissingPackage = $false

    if ($ThrowErrorIfPackageNotInstalled.IsPresent -eq $true) {
        $boolThrowErrorForMissingPackage = $true
    } elseif ($ThrowWarningIfPackageNotInstalled.IsPresent -eq $true) {
        $boolThrowWarningForMissingPackage = $true
    }

    $boolResult = $true

    $hashtableMessagesToThrowForMissingPackage = @{}
    $hashtablePackageNameToCustomMessageToThrowForMissingPackage = @{}
    if ($null -ne $ReferenceToHashtableOfCustomNotInstalledMessages) {
        $arrMessages = @(($ReferenceToHashtableOfCustomNotInstalledMessages.Value).Keys)
        foreach ($strMessage in $arrMessages) {
            $hashtableMessagesToThrowForMissingPackage.Add($strMessage, $false)

            ($ReferenceToHashtableOfCustomNotInstalledMessages.Value).Item($strMessage) | ForEach-Object {
                $hashtablePackageNameToCustomMessageToThrowForMissingPackage.Add($_, $strMessage)
            }
        }
    }

    $arrPackageNames = @(($ReferenceToHashtableOfInstalledPackages.Value).Keys)
    foreach ($strPackageName in $arrPackageNames) {
        if ($null -eq ($ReferenceToHashtableOfInstalledPackages.Value).Item($strPackageName)) {
            # Package not installed
            $boolResult = $false

            if ($hashtablePackageNameToCustomMessageToThrowForMissingPackage.ContainsKey($strPackageName) -eq $true) {
                $strMessage = $hashtablePackageNameToCustomMessageToThrowForMissingPackage.Item($strPackageName)
                $hashtableMessagesToThrowForMissingPackage.Item($strMessage) = $true
            } else {
                if ($null -ne $ReferenceToHashtableOfSkippingDependencies) {
                    if (($ReferenceToHashtableOfSkippingDependencies.Value).ContainsKey($strPackageName) -eq $true) {
                        $boolSkipDependencies = ($ReferenceToHashtableOfSkippingDependencies.Value).Item($strPackageName)
                    } else {
                        $boolSkipDependencies = $false
                    }
                } else {
                    $boolSkipDependencies = $false
                }

                if ($boolSkipDependencies -eq $true) {
                    $strMessage = $strPackageName + ' software package not found. Please install it and then try again.' + [System.Environment]::NewLine + 'You can install the ' + $strPackageName + ' package by running the following command:' + [System.Environment]::NewLine + 'Install-Package -ProviderName NuGet -Name ''' + $strPackageName + ''' -Force -Scope CurrentUser -SkipDependencies;' + [System.Environment]::NewLine + [System.Environment]::NewLine
                } else {
                    $strMessage = $strPackageName + ' software package not found. Please install it and then try again.' + [System.Environment]::NewLine + 'You can install the ' + $strPackageName + ' package by running the following command:' + [System.Environment]::NewLine + 'Install-Package -ProviderName NuGet -Name ''' + $strPackageName + ''' -Force -Scope CurrentUser;' + [System.Environment]::NewLine + [System.Environment]::NewLine
                }

                $hashtableMessagesToThrowForMissingPackage.Add($strMessage, $true)
            }

            if ($null -ne $ReferenceToArrayOfMissingPackages) {
                ($ReferenceToArrayOfMissingPackages.Value) += $strPackageName
            }
        }
    }

    if ($boolThrowErrorForMissingPackage -eq $true) {
        $arrMessages = @($hashtableMessagesToThrowForMissingPackage.Keys)
        foreach ($strMessage in $arrMessages) {
            if ($hashtableMessagesToThrowForMissingPackage.Item($strMessage) -eq $true) {
                Write-Error $strMessage
            }
        }
    } elseif ($boolThrowWarningForMissingPackage -eq $true) {
        $arrMessages = @($hashtableMessagesToThrowForMissingPackage.Keys)
        foreach ($strMessage in $arrMessages) {
            if ($hashtableMessagesToThrowForMissingPackage.Item($strMessage) -eq $true) {
                Write-Warning $strMessage
            }
        }
    }

    return $boolResult
}
