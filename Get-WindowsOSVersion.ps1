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

function Get-WindowsOSVersion {
    $boolWindows = Test-Windows
    if ($boolWindows) {
        $versionPS = Get-PSVersion
        if ($versionPS.Major -ge 3) {
            $arrCIMInstanceOS = @(Get-CimInstance -Query "Select Version from Win32_OperatingSystem")
            if ($arrCIMInstanceOS.Count -eq 0) {
                Write-Error "No instances of Win32_OperatingSystem found!"
                $null
            }
            if ($arrCIMInstanceOS.Count -gt 1) {
                Write-Warning "More than one instance of Win32_OperatingSystem returned. Will only use first instance."
            }
            if ($arrCIMInstanceOS.Count -ge 1) {
                [System.Version](($arrCIMInstanceOS[0]).Version)
            }
        } else {
            $arrManagementObjectOS = @(Get-WmiObject -Query "Select Version from Win32_OperatingSystem")
            if ($arrManagementObjectOS.Count -eq 0) {
                Write-Error "No instances of Win32_OperatingSystem found!"
                $null
            }
            if ($arrManagementObjectOS.Count -gt 1) {
                Write-Warning "More than one instance of Win32_OperatingSystem returned. Will only use first instance."
            }
            if ($arrManagementObjectOS.Count -ge 1) {
                [System.Version](($arrManagementObjectOS[0]).Version)
            }
        }
    } else {
        $null
    }
}
