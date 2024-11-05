function Get-AvailableDriveLetter {
    #region FunctionHeader #####################################################
    # This function evaluates the list of drive letters that are in use on the
    # local system and returns an array of those that are available. The list of
    # available drive letters is returned as an array of uppercase letters
    #
    # The function returns an array of uppercase letters (strings) representing
    # available drive letters
    #
    # This function supports three parameters:
    #
    # Parameter 1: DoNotConsiderMappedDriveLettersAsInUse
    # By default, if this function encounters a drive letter that is mapped to a
    # network share, it will consider that drive letter to be in use. However, if
    # this switch parameter is supplied, then mapped drives will be ignored and
    # their drive letters will be considered available.
    #
    # Parameter 2: DoNotConsiderPSDriveLettersAsInUse
    # By default, if this function encounters a drive letter that is mapped to a
    # PowerShell drive, it will consider that drive letter to be in use. However,
    # if this switch parameter is supplied, then PowerShell drives will be ignored
    # and their drive letters will be considered available.
    #
    # Parameter 3: ConsiderFloppyDriveLettersAsEligible
    # By default, this function will not consider A: or B: drive letters as
    # available. If this switch parameter is supplied, then A: and B: drive letters
    # will be considered available if they are not in use.
    #
    # Example:
    # $arrAvailableDriveLetters = @(Get-AvailableDriveLetter)
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
    # Note: it is conventional that A: and B: drives be reserved for floppy drives,
    # and that C: be reserved for the system drive.
    #
    # Version 1.0.20241105.0
    #endregion FunctionHeader #####################################################

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

    #region DownloadLocationNotice #############################################
    # The most up-to-date version of this script can be found on the author's
    # GitHub repository at https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice #############################################

    param (
        [switch]$DoNotConsiderMappedDriveLettersAsInUse,
        [switch]$DoNotConsiderPSDriveLettersAsInUse,
        [switch]$ConsiderFloppyDriveLettersAsEligible
    )

    function Get-PSVersion {
        #region FunctionHeader #################################################
        # Returns the version of PowerShell that is running, including on the
        # original release of Windows PowerShell (version 1.0)
        #
        # Example:
        # Get-PSVersion
        #
        # This example returns the version of PowerShell that is running. On
        # versions of PowerShell greater than or equal to version 2.0, this
        # function returns the equivalent of $PSVersionTable.PSVersion
        #
        # The function outputs a [version] object representing the version of
        # PowerShell that is running
        #
        # PowerShell 1.0 does not have a $PSVersionTable variable, so this function
        # returns [version]('1.0') on PowerShell 1.0
        #
        # Version 1.0.20241105.0
        #endregion FunctionHeader #################################################

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

        #region DownloadLocationNotice #########################################
        # The most up-to-date version of this script can be found on the author's
        # GitHub repository at:
        # https://github.com/franklesniak/PowerShell_Resources
        #endregion DownloadLocationNotice #########################################

        if (Test-Path variable:\PSVersionTable) {
            return ($PSVersionTable.PSVersion)
        } else {
            return ([version]('1.0'))
        }
    }

    function Test-Windows {
        #region FunctionHeader #################################################
        # Returns a boolean ($true or $false) indicating whether the current
        # PowerShell session is running on Windows. This function is useful for
        # writing scripts that need to behave differently on Windows and non-
        # Windows platforms (Linux, macOS, etc.). Additionally, this function is
        # useful because it works on Windows PowerShell 1.0 through 5.1, which do
        # not have the $IsWindows global variable.
        #
        # Example:
        # $boolIsWindows = Test-Windows
        #
        # This example returns $true if the current PowerShell session is running
        # on Windows, and $false if the current PowerShell session is running on a
        # non-Windows platform (Linux, macOS, etc.)
        #
        # Version 1.0.20241105.0
        #endregion FunctionHeader #################################################

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

        #region DownloadLocationNotice #########################################
        # The most up-to-date version of this script can be found on the author's
        # GitHub repository at:
        # https://github.com/franklesniak/PowerShell_Resources
        #endregion DownloadLocationNotice #########################################

        function Get-PSVersion {
            #region FunctionHeader #################################################
            # Returns the version of PowerShell that is running, including on the
            # original release of Windows PowerShell (version 1.0)
            #
            # Example:
            # Get-PSVersion
            #
            # This example returns the version of PowerShell that is running. On
            # versions of PowerShell greater than or equal to version 2.0, this
            # function returns the equivalent of $PSVersionTable.PSVersion
            #
            # The function outputs a [version] object representing the version of
            # PowerShell that is running
            #
            # PowerShell 1.0 does not have a $PSVersionTable variable, so this function
            # returns [version]('1.0') on PowerShell 1.0
            #
            # Version 1.0.20241105.0
            #endregion FunctionHeader #################################################

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

            #region DownloadLocationNotice #########################################
            # The most up-to-date version of this script can be found on the author's
            # GitHub repository at:
            # https://github.com/franklesniak/PowerShell_Resources
            #endregion DownloadLocationNotice #########################################

            if (Test-Path variable:\PSVersionTable) {
                return ($PSVersionTable.PSVersion)
            } else {
                return ([version]('1.0'))
            }
        }

        $versionPS = Get-PSVersion
        if ($versionPS.Major -ge 6) {
            $IsWindows
        } else {
            $true
        }
    }

    #region Process Input ######################################################
    if ($DoNotConsiderMappedDriveLettersAsInUse.IsPresent -eq $true) {
        $boolExcludeMappedDriveLetters = $false
    } else {
        $boolExcludeMappedDriveLetters = $true
    }

    if ($DoNotConsiderPSDriveLettersAsInUse.IsPresent -eq $true) {
        $boolExcludePSDriveLetters = $false
    } else {
        $boolExcludePSDriveLetters = $true
    }

    if ($ConsiderFloppyDriveLettersAsEligible.IsPresent -eq $true) {
        $boolExcludeFloppyDriveLetters = $false
    } else {
        $boolExcludeFloppyDriveLetters = $true
    }
    #endregion Process Input ######################################################

    $VerbosePreferenceAtStartOfFunction = $VerbosePreference

    if ((Test-Windows) -eq $true) {

        $arrAllPossibleLetters = 65..90 | ForEach-Object { [char]$_ }

        $versionPS = Get-PSVersion

        If ($versionPS.Major -ge 3) {
            $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            $arrUsedLogicalDriveLetters = Get-CimInstance -ClassName 'Win32_LogicalDisk' |
                ForEach-Object { $_.DeviceID } | Where-Object { $_.Length -eq 2 } |
                Where-Object { $_[1] -eq ':' } | ForEach-Object { $_.ToUpper() } |
                ForEach-Object { $_[0] } | Where-Object { $arrAllPossibleLetters -contains $_ }
            # fifth-, fourth-, and third-to-last bits of pipeline ensures that we have a device ID like
            # "C:" second-to-last bit of pipeline strips off the ':', leaving just the capital drive
            # letter last bit of pipeline ensure that the drive letter is actually a letter; addresses
            # legacy Netware edge cases
            $VerbosePreference = $VerbosePreferenceAtStartOfFunction

            if ($boolExcludeMappedDriveLetters -eq $true) {
                $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                $arrUsedMappedDriveLetters = Get-CimInstance -ClassName 'Win32_NetworkConnection' |
                    ForEach-Object { $_.LocalName } | Where-Object { $_.Length -eq 2 } |
                    Where-Object { $_[1] -eq ':' } | ForEach-Object { $_.ToUpper() } |
                    ForEach-Object { $_[0] } |
                    Where-Object { $private.arrAllPossibleLetters -contains $_ }
                # fifth-, fourth-, and third-to-last bits of pipeline ensures that we have a LocalName like "C:"
                # second-to-last bit of pipeline strips off the ':', leaving just the capital drive letter
                # last bit of pipeline ensure that the drive letter is actually a letter; addresses legacy
                # Netware edge cases
                $VerbosePreference = $VerbosePreferenceAtStartOfFunction
            } else {
                $arrUsedMappedDriveLetters = $null
            }
        } else {
            $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            $arrUsedLogicalDriveLetters = Get-WmiObject -Class 'Win32_LogicalDisk' |
                ForEach-Object { $_.DeviceID } | Where-Object { $_.Length -eq 2 } |
                Where-Object { $_[1] -eq ':' } | ForEach-Object { $_.ToUpper() } |
                ForEach-Object { $_[0] } | Where-Object { $arrAllPossibleLetters -contains $_ }
            # fifth-, fourth-, and third-to-last bits of pipeline ensures that we have a device ID like
            # "C:" second-to-last bit of pipeline strips off the ':', leaving just the capital drive
            # letter last bit of pipeline ensure that the drive letter is actually a letter; addresses
            # legacy Netware edge cases
            $VerbosePreference = $VerbosePreferenceAtStartOfFunction

            if ($boolExcludeMappedDriveLetters -eq $true) {
                $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                $arrUsedMappedDriveLetters = Get-WmiObject -Class 'Win32_NetworkConnection' |
                    ForEach-Object { $_.LocalName } | Where-Object { $_.Length -eq 2 } |
                    Where-Object { $_[1] -eq ':' } | ForEach-Object { $_.ToUpper() } |
                    ForEach-Object { $_[0] } |
                    Where-Object { $private.arrAllPossibleLetters -contains $_ }
                # fifth-, fourth-, and third-to-last bits of pipeline ensures that we have a LocalName like "C:"
                # second-to-last bit of pipeline strips off the ':', leaving just the capital drive letter
                # last bit of pipeline ensure that the drive letter is actually a letter; addresses legacy
                # Netware edge cases
                $VerbosePreference = $VerbosePreferenceAtStartOfFunction
            } else {
                $arrUsedMappedDriveLetters = $null
            }
        }

        if ($boolExcludePSDriveLetters -eq $true) {
            $arrUsedPSDriveLetters = Get-PSDrive | ForEach-Object { $_.Name } | `
                    Where-Object { $_.Length -eq 1 } | ForEach-Object { $_.ToUpper() } | `
                    Where-Object { $private.arrAllPossibleLetters -contains $_ }
            # Checking for a length of 1 strips out most PSDrives that are not drive letters
            # Making sure that each item in the resultant set matches something in
            # $arrAllPossibleLetters filters out edge cases, like a PSDrive named '1'
        } else {
            $arrUsedPSDriveLetters = $null
        }

        if ($boolExcludeFloppyDriveLetters -eq $true) {
            $arrFloppyDriveLetters = @('A', 'B')
        } else {
            $arrFloppyDriveLetters = $null
        }

        $arrAllPossibleLetters | Where-Object { $arrUsedLogicalDriveLetters -notcontains $_ } |
            Where-Object { $arrUsedMappedDriveLetters -notcontains $_ } |
            Where-Object { $arrUsedPSDriveLetters -notcontains $_ } |
            Where-Object { $arrFloppyDriveLetters -notcontains $_ } |
            Where-Object { $arrBlacklistedDriveLetters -notcontains $_ }
    } else {
        Write-Warning "This function is only supported on Windows."
    }
}
