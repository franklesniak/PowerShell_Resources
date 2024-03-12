function Test-NuGetDotOrgRegisteredAsPackageSource {
    <#
    .SYNOPSIS
    Tests to see nuget.org is registered as a package source. If it is not, the
    function can optionally throw an error or warning

    .DESCRIPTION
    The Test-NuGetDotOrgRegisteredAsPackageSource function tests to see if nuget.org is
    registered as a package source. If it is not, the function can optionally throw an
    error or warning that gives the user instructions to register nuget.org as a
    package source.

    .PARAMETER $ThrowErrorIfNuGetDotOrgNotRegistered
    Is a switch parameter. If this parameter is specified, an error is thrown to tell
    the user that nuget.org is not registered as a package source, and the user is
    given instructions on how to register it. If this parameter is not specified, no
    error is thrown.

    .PARAMETER $ThrowWarningIfNuGetDotOrgNotRegistered
    Is a switch parameter. If this parameter is specified, a warning is thrown to tell
    the user that nuget.org is not registered as a package source, and the user is
    given instructions on how to register it. If this parameter is not specified, or if
    the ThrowErrorIfNuGetDotOrgNotRegistered parameter was specified, no warning is
    thrown.

    .EXAMPLE
    $boolResult = Test-NuGetDotOrgRegisteredAsPackageSource -ThrowErrorIfNuGetDotOrgNotRegistered

    This example checks to see if nuget.org is registered as a package source. If it is
    not, an error is thrown to tell the user that nuget.org is not registered as a
    package source, and the user is given instructions on how to register it.

    .OUTPUTS
    [boolean] - Returns $true if nuget.org is registered as a package source; otherwise, returns $false.

    .NOTES
    Requires PowerShell v5.0 or newer
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

    # Version 1.1.20240312.0

    [CmdletBinding()]
    [OutputType([Boolean])]
    param (
        [Parameter(Mandatory = $false)][switch]$ThrowErrorIfNuGetDotOrgNotRegistered,
        [Parameter(Mandatory = $false)][switch]$ThrowWarningIfNuGetDotOrgNotRegistered
    )

    $WarningPreferenceAtStartOfFunction = $WarningPreference
    $VerbosePreferenceAtStartOfFunction = $VerbosePreference
    $DebugPreferenceAtStartOfFunction = $DebugPreference

    $boolThrowErrorForMissingPackageSource = $false
    $boolThrowWarningForMissingPackageSource = $false

    if ($ThrowErrorIfNuGetDotOrgNotRegistered.IsPresent -eq $true) {
        $boolThrowErrorForMissingPackageSource = $true
    } elseif ($ThrowWarningIfNuGetDotOrgNotRegistered.IsPresent -eq $true) {
        $boolThrowWarningForMissingPackageSource = $true
    }

    $boolPackageSourceFound = $true
    Write-Debug ('Checking for registered package sources (Get-PackageSource)...')
    $WarningPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
    $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
    $DebugPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
    $arrPackageSources = @(Get-PackageSource)
    $WarningPreference = $WarningPreferenceAtStartOfFunction
    $VerbosePreference = $VerbosePreferenceAtStartOfFunction
    $DebugPreference = $DebugPreferenceAtStartOfFunction
    if (@($arrPackageSources | Where-Object { $_.Location -eq 'https://api.nuget.org/v3/index.json' }).Count -eq 0) {
        $boolPackageSourceFound = $false
    }

    if ($boolPackageSourceFound -eq $false) {
        $strMessage = 'The nuget.org package source is not registered. Please register it and then try again.' + [System.Environment]::NewLine + 'You can register it by running the following command: ' + [System.Environment]::NewLine + '[void](Register-PackageSource -Name NuGetOrg -Location https://api.nuget.org/v3/index.json -ProviderName NuGet);'

        if ($boolThrowErrorForMissingPackageSource -eq $true) {
            Write-Error $strMessage
        } elseif ($boolThrowWarningForMissingPackageSource -eq $true) {
            Write-Warning $strMessage
        }
    }

    return $boolPackageSourceFound
}
