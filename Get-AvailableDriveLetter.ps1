function Get-AvailableDriveLetter {
    # .SYNOPSIS
    # Gets a list of available drive letters on the local system.
    #
    # .DESCRIPTION
    # This function evaluates the list of drive letters that are in use on the
    # local system and returns an array of those that are available. The list of
    # available drive letters is returned as an array of uppercase letters
    #
    # .PARAMETER PSVersion
    # This parameter is optional; if supplied, it must be the version number of the
    # running version of PowerShell. If the version of PowerShell is already known,
    # it can be passed in to this function to avoid the overhead of unnecessarily
    # determining the version of PowerShell. If this parameter is not supplied, the
    # function will determine the version of PowerShell that is running as part of
    # its processing.
    #
    # .PARAMETER AssumeWindows
    # By default, this function will determine if the running system is Windows or
    # not. If this switch parameter is supplied, then the function will assume that
    # the running system is Windows. This can be useful if you have already
    # determined that the system is Windows and you want to avoid the overhead of
    # determining the system type again.
    #
    # .PARAMETER DoNotConsiderMappedDriveLettersAsInUse
    # By default, if this function encounters a drive letter that is mapped to a
    # network share, it will consider that drive letter to be in use. However, if
    # this switch parameter is supplied, then mapped drives will be ignored and
    # their drive letters will be considered available.
    #
    # .PARAMETER DoNotConsiderPSDriveLettersAsInUse
    # By default, if this function encounters a drive letter that is mapped to a
    # PowerShell drive, it will consider that drive letter to be in use. However,
    # if this switch parameter is supplied, then PowerShell drives will be ignored
    # and their drive letters will be considered available.
    #
    # .PARAMETER ConsiderFloppyDriveLettersAsEligible
    # By default, this function will not consider A: or B: drive letters as
    # available. If this switch parameter is supplied, then A: and B: drive letters
    # will be considered available if they are not in use.
    #
    # .EXAMPLE
    # $arrAvailableDriveLetters = Get-AvailableDriveLetter
    #
    # This example returns an array of available drive letters, excluding A: and B:
    # drive, and excluding drive letters that are mapped to network shares or
    # PowerShell drives (PSDrives).
    #
    # In this example, to access the alphabetically-first available drive letter,
    # use:
    # $arrAvailableDriveLetters[0]
    # To access the alphabetically-last available drive letter, use:
    # $arrAvailableDriveLetters[-1]
    #
    # .INPUTS
    # None. You can't pipe objects to Get-AvailableDriveLetter.
    #
    # .OUTPUTS
    # System.Char[]. Get-AvailableDriveLetter returns an array of uppercase letters
    # (System.Char) representing available drive letters.
    #
    # Note that on non-Windows systems, this function will return an empty array
    # because drive letters are a Windows-specific concept. It will also issue a
    # warning to alert the user that the function is only supported on Windows.
    #
    # .NOTES
    # It is conventional that A: and B: drives be reserved for floppy drives,
    # and that C: be reserved for the system drive.
    #
    # This function also supports the use of one positional parameter instead of
    # named parameters. If the positional parameter is used intead of named
    # parameters, then one positional parameters is required: it must be the
    # version number of the running version of PowerShell. If the version of
    # PowerShell is already known, it can be passed in to this function to avoid
    # the overhead of unnecessarily determining the version of PowerShell. If this
    # parameter is not supplied, the function will determine the version of
    # PowerShell that is running as part of its processing.
    #
    # Version: 1.1.20241227.0

    #region License ############################################################
    # Copyright (c) 2024 Frank Lesniak
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy
    # of this software and associated documentation files (the "Software"), to deal
    # in the Software without restriction, including without limitation the rights
    # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    # copies of the Software, and to permit persons to whom the Software is
    # furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in
    # all copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    # SOFTWARE.
    #endregion License ############################################################

    param (
        [version]$PSVersion = ([version]'0.0'),
        [switch]$AssumeWindows,
        [switch]$DoNotConsiderMappedDriveLettersAsInUse,
        [switch]$DoNotConsiderPSDriveLettersAsInUse,
        [switch]$ConsiderFloppyDriveLettersAsEligible
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

    function Test-Windows {
        # .SYNOPSIS
        # Returns $true if PowerShell is running on Windows; otherwise, returns $false.
        #
        # .DESCRIPTION
        # Returns a boolean ($true or $false) indicating whether the current PowerShell
        # session is running on Windows. This function is useful for writing scripts
        # that need to behave differently on Windows and non-Windows platforms (Linux,
        # macOS, etc.). Additionally, this function is useful because it works on
        # Windows PowerShell 1.0 through 5.1, which do not have the $IsWindows global
        # variable.
        #
        # .PARAMETER PSVersion
        # This parameter is optional; if supplied, it must be the version number of the
        # running version of PowerShell. If the version of PowerShell is already known,
        # it can be passed in to this function to avoid the overhead of unnecessarily
        # determining the version of PowerShell. If this parameter is not supplied, the
        # function will determine the version of PowerShell that is running as part of
        # its processing.
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
        # PowerShell is running on Windows. $true means that PowerShell is running on
        # Windows; $false means that PowerShell is not running on Windows.
        #
        # .NOTES
        # This function also supports the use of a positional parameter instead of a
        # named parameter. If a positional parameter is used intead of a named
        # parameter, then one positional parameters is required: it must be the version
        # number of the running version of PowerShell. If the version of PowerShell is
        # already known, it can be passed in to this function to avoid the overhead of
        # unnecessarily determining the version of PowerShell. If this parameter is not
        # supplied, the function will determine the version of PowerShell that is
        # running as part of its processing.
        #
        # Version: 1.1.20241225.0

        #region License ############################################################
        # Copyright (c) 2024 Frank Lesniak
        #
        # Permission is hereby granted, free of charge, to any person obtaining a copy
        # of this software and associated documentation files (the "Software"), to deal
        # in the Software without restriction, including without limitation the rights
        # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        # copies of the Software, and to permit persons to whom the Software is
        # furnished to do so, subject to the following conditions:
        #
        # The above copyright notice and this permission notice shall be included in
        # all copies or substantial portions of the Software.
        #
        # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        # SOFTWARE.
        #endregion License ############################################################

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

    #region Process Input ######################################################
    if ($null -ne $PSVersion) {
        if ($PSVersion -eq ([version]'0.0')) {
            $versionPS = Get-PSVersion
        } else {
            $versionPS = $PSVersion
        }
    } else {
        $versionPS = Get-PSVersion
    }

    $boolIsWindows = $null
    if ($null -ne $AssumeWindows) {
        if ($AssumeWindows.IsPresent -eq $true) {
            $boolIsWindows = $true
        }
    }
    if ($null -eq $boolIsWindows) {
        $boolIsWindows = Test-Windows -PSVersion $versionPS
    }

    $boolExcludeMappedDriveLetters = $true
    if ($null -ne $DoNotConsiderMappedDriveLettersAsInUse) {
        if ($DoNotConsiderMappedDriveLettersAsInUse.IsPresent -eq $true) {
            $boolExcludeMappedDriveLetters = $false
        }
    }

    $boolExcludePSDriveLetters = $true
    if ($null -ne $DoNotConsiderPSDriveLettersAsInUse) {
        if ($DoNotConsiderPSDriveLettersAsInUse.IsPresent -eq $true) {
            $boolExcludePSDriveLetters = $false
        }
    }

    $boolExcludeFloppyDriveLetters = $true
    if ($null -ne $ConsiderFloppyDriveLettersAsEligible) {
        if ($ConsiderFloppyDriveLettersAsEligible.IsPresent -eq $true) {
            $boolExcludeFloppyDriveLetters = $false
        }
    }
    #endregion Process Input ######################################################

    $VerbosePreferenceAtStartOfFunction = $VerbosePreference

    if (-not $boolIsWindows) {
        Write-Warning "Get-AvailableDriveLetter is only supported on Windows."
        return , @()
    } else {
        # System is Windows
        $arrAllPossibleLetters = @(65..90 | ForEach-Object { [char]$_ })

        if ($versionPS.Major -ge 3) {
            # Use Get-CimInstance
            $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            $arrUsedLogicalDriveLetters = @(Get-CimInstance -ClassName 'Win32_LogicalDisk' |
                    ForEach-Object { $_.DeviceID } |
                    Where-Object { $_.Length -eq 2 } |
                    Where-Object { $_[1] -eq ':' } |
                    ForEach-Object { $_.ToUpper() } |
                    ForEach-Object { $_[0] } |
                    Where-Object { $arrAllPossibleLetters -contains $_ })
            # fifth-, fourth-, and third-to-last bits of pipeline ensures that we
            # have a device ID like "C:"; second-to-last bit of pipeline strips off
            # the ':', leaving just the capital drive letter; last bit of pipeline
            # ensure that the drive letter is actually a letter; addresses legacy
            # Netware edge cases.
            $VerbosePreference = $VerbosePreferenceAtStartOfFunction

            if ($boolExcludeMappedDriveLetters -eq $true) {
                $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                $arrUsedMappedDriveLetters = @(Get-CimInstance -ClassName 'Win32_NetworkConnection' |
                        ForEach-Object { $_.LocalName } |
                        Where-Object { $_.Length -eq 2 } |
                        Where-Object { $_[1] -eq ':' } |
                        ForEach-Object { $_.ToUpper() } |
                        ForEach-Object { $_[0] } |
                        Where-Object { $arrAllPossibleLetters -contains $_ })
                # fifth-, fourth-, and third-to-last bits of pipeline ensures that
                # we have a LocalName like "C:"; second-to-last bit of pipeline
                # strips off the ':', leaving just the capital drive letter; last
                # bit of pipeline ensure that the drive letter is actually a
                # letter; addresses legacy Netware edge cases.
                $VerbosePreference = $VerbosePreferenceAtStartOfFunction
            } else {
                $arrUsedMappedDriveLetters = $null
            }
        } else {
            # Use Get-WmiObject
            $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            $arrUsedLogicalDriveLetters = @(Get-WmiObject -Class 'Win32_LogicalDisk' |
                    ForEach-Object { $_.DeviceID } |
                    Where-Object { $_.Length -eq 2 } |
                    Where-Object { $_[1] -eq ':' } |
                    ForEach-Object { $_.ToUpper() } |
                    ForEach-Object { $_[0] } |
                    Where-Object { $arrAllPossibleLetters -contains $_ })
            # fifth-, fourth-, and third-to-last bits of pipeline ensures that we
            # have a device ID like "C:"; second-to-last bit of pipeline strips off
            # the ':', leaving just the capital drive letter; last bit of pipeline
            # ensure that the drive letter is actually a letter; addresses legacy
            # Netware edge cases.
            $VerbosePreference = $VerbosePreferenceAtStartOfFunction

            if ($boolExcludeMappedDriveLetters -eq $true) {
                $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                $arrUsedMappedDriveLetters = @(Get-WmiObject -Class 'Win32_NetworkConnection' |
                        ForEach-Object { $_.LocalName } |
                        Where-Object { $_.Length -eq 2 } |
                        Where-Object { $_[1] -eq ':' } |
                        ForEach-Object { $_.ToUpper() } |
                        ForEach-Object { $_[0] } |
                        Where-Object { $arrAllPossibleLetters -contains $_ })
                # fifth-, fourth-, and third-to-last bits of pipeline ensures that
                # we have a LocalName like "C:"; second-to-last bit of pipeline
                # strips off the ':', leaving just the capital drive letter; last
                # bit of pipeline ensure that the drive letter is actually a
                # letter; addresses legacy Netware edge cases.
                $VerbosePreference = $VerbosePreferenceAtStartOfFunction
            } else {
                $arrUsedMappedDriveLetters = $null
            }
        }

        if ($boolExcludePSDriveLetters -eq $true) {
            $arrUsedPSDriveLetters = @(Get-PSDrive | ForEach-Object { $_.Name } |
                    Where-Object { $_.Length -eq 1 } |
                    ForEach-Object { $_.ToUpper() } |
                    Where-Object { $arrAllPossibleLetters -contains $_ })
            # Checking for a length of 1 strips out most PSDrives that are not
            # drive letters; making sure that each item in the resultant set
            # matches something in $arrAllPossibleLetters filters out edge cases,
            # like a PSDrive named '1'.
        } else {
            $arrUsedPSDriveLetters = $null
        }

        if ($boolExcludeFloppyDriveLetters -eq $true) {
            $arrFloppyDriveLetters = @('A', 'B')
        } else {
            $arrFloppyDriveLetters = $null
        }

        $arrResult = @($arrAllPossibleLetters |
                Where-Object { $arrUsedLogicalDriveLetters -notcontains $_ } |
                Where-Object { $arrUsedMappedDriveLetters -notcontains $_ } |
                Where-Object { $arrUsedPSDriveLetters -notcontains $_ } |
                Where-Object { $arrFloppyDriveLetters -notcontains $_ } |
                Where-Object { $arrBlacklistedDriveLetters -notcontains $_ })

        # The following code forces the function to return an array, always, even
        # when there are zero or one elements in the array.
        $intElementCount = 1
        if ($null -ne $arrResult) {
            if ($arrResult.GetType().FullName.Contains('[]')) {
                if (($arrResult.Count -ge 2) -or ($arrResult.Count -eq 0)) {
                    $intElementCount = $arrResult.Count
                }
            }
        }
        $strLowercaseFunctionName = $MyInvocation.InvocationName.ToLower()
        $boolArrayEncapsulation = $MyInvocation.Line.ToLower().Contains('@(' + $strLowercaseFunctionName + ')') -or $MyInvocation.Line.ToLower().Contains('@(' + $strLowercaseFunctionName + ' ')
        if ($boolArrayEncapsulation) {
            return $arrResult
        } elseif ($intElementCount -eq 0) {
            return , @()
        } elseif ($intElementCount -eq 1) {
            return , (, ($arrResult[0]))
        } else {
            return $arrResult
        }
    }
}
