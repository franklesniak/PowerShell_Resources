# Get-COMObjectsProgIDsAllowedToLaunch.ps1 contains a function
# (Get-COMObjectsProgIDsAllowedToLaunch) that enumerates all of the COM objects on a Windows
# system that have ProgIds (friendly names). Each one of these COM objects is instantiated.
# Those that are successful are returned.

$strThisScriptVersionNumber = [version]'1.0.20210116.0'

#region License
###############################################################################################
# Copyright 2020 Frank Lesniak

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###############################################################################################
#endregion License

#region Acknowledgements
# I would like to thank "bohops", who pointed me in the right direction on the blog:
# https://bohops.com/2019/01/10/com-xsl-transformation-bypassing-microsoft-application-control-solutions-cve-2018-8492/
#endregion Acknowledgements

#region DownloadLocationNotice
# The most up-to-date version of this script can be found on the author's GitHub repository
# at https://github.com/franklesniak/PowerShell_Resources
#endregion DownloadLocationNotice

function Get-PSVersion {
    if (Test-Path variable:\PSVersionTable) {
        $PSVersionTable.PSVersion
    } else {
        [version]("1.0")
    }
}

function Test-Windows {
    $versionPS = Get-PSVersion
    if ($versionPS.Major -ge 6) {
        $IsWindows
    } else {
        $true
    }
}

function Get-COMObjectsProgIDsAllowedToLaunch {
    if (Test-Windows) {
        $versionPS = Get-PSVersion

        if ($versionPS.Major -ge 3) {
            $arrInstances = @(Get-CimInstance -ClassName 'Win32_COMSetting')
        } else {
            $arrInstances = @(Get-WMIObject -ClassName 'Win32_COMSetting')
        }

        $arrCOMObjectProgIDs = @($arrInstances | Where-Object { $null -ne $_.ProgId } |
            ForEach-Object { $_.ProgId })

        $ActionPreferenceFormerError = $ErrorActionPreference
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        $result = @($arrCOMObjectProgIDs | ForEach-Object { if (New-Object -ComObject $_) { $_ } })
        $ErrorActionPreference = $ActionPreferenceFormerError
    } else {
        $result = @()
    }

    # The following code forces the function to return an array, always, even when there are
    # zero or one elements in the array
    $intElementCount = 1
    if ($null -ne $result) {
        if ($result.GetType().FullName.Contains('[]')) {
            if (($result.Count -ge 2) -or ($result.Count -eq 0)) {
                $intElementCount = $result.Count
            }
        }
    }
    $strLowercaseFunctionName = $MyInvocation.InvocationName.ToLower()
    $boolArrayEncapsulation = $MyInvocation.Line.ToLower().Contains('@(' + $strLowercaseFunctionName + ')') -or $MyInvocation.Line.ToLower().Contains('@(' + $strLowercaseFunctionName + ' ')
    if ($boolArrayEncapsulation) {
        $result
    } elseif ($intElementCount -eq 0) {
        , @()
    } elseif ($intElementCount -eq 1) {
        , (, ($args[0]))
    } else {
        $result
    }
}
