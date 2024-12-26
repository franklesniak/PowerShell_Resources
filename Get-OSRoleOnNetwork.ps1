#region License
###############################################################################################
# Copyright 2024 Frank Lesniak

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

function Test-Windows {
    $versionPS = Get-PSVersion
    if ($versionPS.Major -ge 6) {
        $IsWindows
    } else {
        $true
    }
}

function Get-OSRoleOnNetwork {
    # Returns 1 if the system is a workstation
    # Returns 2 if the system is an Active Directory Domain Services (AD DS) Domain Controller
    # Returns 3 if the system is a server (but not a Domain Controller)
    # NOTE: Returns $null if system is non-Windows or if an error occurred

    # TO-DO: Add logic for FreeBSD/Linux systems
    $boolWindows = Test-Windows
    if ($boolWindows) {
        $versionPS = Get-PSVersion
        if ($versionPS.Major -ge 3) {
            $arrCIMInstanceOS = @(Get-CimInstance -Query "Select ProductType from Win32_OperatingSystem")
            if ($arrCIMInstanceOS.Count -eq 0) {
                Write-Error "No instances of Win32_OperatingSystem found!"
                $null
            }
            if ($arrCIMInstanceOS.Count -gt 1) {
                Write-Warning "More than one instance of Win32_OperatingSystem returned. Will only use first instance."
            }
            if ($arrCIMInstanceOS.Count -ge 1) {
                ($arrCIMInstanceOS[0]).ProductType
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
                ($arrManagementObjectOS[0]).ProductType
            }
        }
    } else {
        $null
    }
}
