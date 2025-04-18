#region License
###############################################################################################
# Copyright 2025 Frank Lesniak

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

# Version: 1.0.20250106.1

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
    # PowerShell 1.0 does not have a $PSVersionTable variable, so this
    # function returns [version]('1.0') on PowerShell 1.0.
    #
    # .EXAMPLE
    # $versionPS = Get-PSVersion
    # # $versionPS now contains the version of PowerShell that is running.
    # # On versions of PowerShell greater than or equal to version 2.0,
    # # this function returns the equivalent of $PSVersionTable.PSVersion.
    #
    # .INPUTS
    # None. You can't pipe objects to Get-PSVersion.
    #
    # .OUTPUTS
    # System.Version. Get-PSVersion returns a [version] value indiciating
    # the version of PowerShell that is running.
    #
    # .NOTES
    # Version: 1.0.20250106.0

    #region License ####################################################
    # Copyright (c) 2025 Frank Lesniak
    #
    # Permission is hereby granted, free of charge, to any person obtaining
    # a copy of this software and associated documentation files (the
    # "Software"), to deal in the Software without restriction, including
    # without limitation the rights to use, copy, modify, merge, publish,
    # distribute, sublicense, and/or sell copies of the Software, and to
    # permit persons to whom the Software is furnished to do so, subject to
    # the following conditions:
    #
    # The above copyright notice and this permission notice shall be
    # included in all copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
    # BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
    # ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    # CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    # SOFTWARE.
    #endregion License ####################################################

    if (Test-Path variable:\PSVersionTable) {
        return ($PSVersionTable.PSVersion)
    } else {
        return ([version]('1.0'))
    }
}

function Test-Windows {
    # .SYNOPSIS
    # Returns $true if PowerShell is running on Windows; otherwise, returns
    # $false.
    #
    # .DESCRIPTION
    # Returns a boolean ($true or $false) indicating whether the current
    # PowerShell session is running on Windows. This function is useful for
    # writing scripts that need to behave differently on Windows and non-
    # Windows platforms (Linux, macOS, etc.). Additionally, this function is
    # useful because it works on Windows PowerShell 1.0 through 5.1, which do
    # not have the $IsWindows global variable.
    #
    # .PARAMETER PSVersion
    # This parameter is optional; if supplied, it must be the version number of
    # the running version of PowerShell. If the version of PowerShell is
    # already known, it can be passed in to this function to avoid the overhead
    # of unnecessarily determining the version of PowerShell. If this parameter
    # is not supplied, the function will determine the version of PowerShell
    # that is running as part of its processing.
    #
    # .EXAMPLE
    # $boolIsWindows = Test-Windows
    #
    # .EXAMPLE
    # # The version of PowerShell is known to be 2.0 or above:
    # $boolIsWindows = Test-Windows -PSVersion $PSVersionTable.PSVersion
    #
    # .INPUTS
    # None. You can't pipe objects to Test-Windows.
    #
    # .OUTPUTS
    # System.Boolean. Test-Windows returns a boolean value indiciating whether
    # PowerShell is running on Windows. $true means that PowerShell is running
    # on Windows; $false means that PowerShell is not running on Windows.
    #
    # .NOTES
    # This function also supports the use of a positional parameter instead of
    # a named parameter. If a positional parameter is used instead of a named
    # parameter, then one positional parameter is required: it must be the
    # version number of the running version of PowerShell. If the version of
    # PowerShell is already known, it can be passed in to this function to
    # avoid the overhead of unnecessarily determining the version of
    # PowerShell. If this parameter is not supplied, the function will
    # determine the version of PowerShell that is running as part of its
    # processing.
    #
    # Version: 1.1.20250106.1

    #region License ########################################################
    # Copyright (c) 2025 Frank Lesniak
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

    param (
        [version]$PSVersion = ([version]'0.0')
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
        # PowerShell 1.0 does not have a $PSVersionTable variable, so this
        # function returns [version]('1.0') on PowerShell 1.0.
        #
        # .EXAMPLE
        # $versionPS = Get-PSVersion
        # # $versionPS now contains the version of PowerShell that is running.
        # # On versions of PowerShell greater than or equal to version 2.0,
        # # this function returns the equivalent of $PSVersionTable.PSVersion.
        #
        # .INPUTS
        # None. You can't pipe objects to Get-PSVersion.
        #
        # .OUTPUTS
        # System.Version. Get-PSVersion returns a [version] value indiciating
        # the version of PowerShell that is running.
        #
        # .NOTES
        # Version: 1.0.20250106.0

        #region License ####################################################
        # Copyright (c) 2025 Frank Lesniak
        #
        # Permission is hereby granted, free of charge, to any person obtaining
        # a copy of this software and associated documentation files (the
        # "Software"), to deal in the Software without restriction, including
        # without limitation the rights to use, copy, modify, merge, publish,
        # distribute, sublicense, and/or sell copies of the Software, and to
        # permit persons to whom the Software is furnished to do so, subject to
        # the following conditions:
        #
        # The above copyright notice and this permission notice shall be
        # included in all copies or substantial portions of the Software.
        #
        # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
        # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
        # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
        # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
        # BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
        # ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
        # CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        # SOFTWARE.
        #endregion License ####################################################

        if (Test-Path variable:\PSVersionTable) {
            return ($PSVersionTable.PSVersion)
        } else {
            return ([version]('1.0'))
        }
    }

    if ($PSVersion -ne ([version]'0.0')) {
        if ($PSVersion.Major -ge 6) {
            return $IsWindows
        } else {
            return $true
        }
    } else {
        $versionPS = Get-PSVersion
        if ($versionPS.Major -ge 6) {
            return $IsWindows
        } else {
            return $true
        }
    }
}

function Get-OSRoleOnNetwork {
    # Returns 1 if the system is a workstation
    # Returns 2 if the system is an Active Directory Domain Services (AD DS) Domain Controller
    # Returns 3 if the system is a server (but not a Domain Controller)
    # NOTE: Returns $null if system is non-Windows or if an error occurred

    # TO-DO: Add logic for FreeBSD/Linux systems
    $versionPS = Get-PSVersion
    $boolWindows = Test-Windows -PSVersion $versionPS
    if ($boolWindows) {
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
