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

function Test-ThisSystemIsAHyperVVM {
    # TODO: Add optional parameter to allow the version of PowerShell to be specified
    #       as a parameter to this function, which can improve performance by avoiding
    #       the overhead of determining the version of PowerShell if it is already
    #       known.
    # TODO: Add optional parameter to skip the check to determine if the current
    #       PowerShell session is running on Windows. This can be useful if the
    #       caller already knows that the current PowerShell session is running on
    #       Windows and wants to avoid the overhead of checking again.

    # Version: 1.0.20250106.1

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

    function Get-HardwareModel {
        # TODO: Add optional parameter to allow the version of PowerShell to be specified
        #       as a parameter to this function, which can improve performance by avoiding
        #       the overhead of determining the version of PowerShell if it is already
        #       known.
        # TODO: Add optional parameter to skip the check to determine if the current
        #       PowerShell session is running on Windows. This can be useful if the
        #       caller already knows that the current PowerShell session is running on
        #       Windows and wants to avoid the overhead of checking again.

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

        $versionPS = Get-PSVersion
        $boolWindows = Test-Windows -PSVersion $versionPS
        if ($boolWindows) {
            if ($versionPS.Major -ge 3) {
                $arrCIMInstanceComputerSystem = @(Get-CimInstance -Query "Select Model from Win32_ComputerSystem")
                if ($arrCIMInstanceComputerSystem.Count -eq 0) {
                    Write-Error "No instances of Win32_ComputerSystem found!"
                    $null
                }
                if ($arrCIMInstanceComputerSystem.Count -gt 1) {
                    Write-Warning "More than one instance of Win32_ComputerSystem returned. Will only use first instance."
                }
                if ($arrCIMInstanceComputerSystem.Count -ge 1) {
                    ($arrCIMInstanceComputerSystem[0]).Model
                }
            } else {
                $arrManagementObjectComputerSystem = @(Get-WmiObject -Query "Select Model from Win32_ComputerSystem")
                if ($arrManagementObjectComputerSystem.Count -eq 0) {
                    Write-Error "No instances of Win32_ComputerSystem found!"
                    $null
                }
                if ($arrManagementObjectComputerSystem.Count -gt 1) {
                    Write-Warning "More than one instance of Win32_ComputerSystem returned. Will only use first instance."
                }
                if ($arrManagementObjectComputerSystem.Count -ge 1) {
                    ($arrManagementObjectComputerSystem[0]).Model
                }
            }
        } else {
            # TO-DO: Find a way to do this on FreeBSD/Linux
            # Return $null for now
            $null
        }
    }

    $boolWindows = Test-Windows
    if ($boolWindows) {
        $strModel = Get-HardwareModel
        if ($null -ne $strModel) {
            if ($strModel -eq "Virtual Machine") {
                $true
            } else {
                $false
            }
        } else {
            $null # Error condition
        }
    } else {
        # TO-DO: Find a way to do this on FreeBSD/Linux
        # Return $null for now
        $null
    }
}
