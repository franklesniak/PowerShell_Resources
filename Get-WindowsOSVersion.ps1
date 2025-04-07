function Get-WindowsOSVersion {
    # .SYNOPSIS
    # Gets the Windows operating system version.
    #
    # .DESCRIPTION
    # This function retrieves the Windows operating system version.
    #
    # .PARAMETER ReferenceToSystemVersion
    # This parameter is required; it is a reference to a System.Version object that
    # will be modified to contain the version of the Windows kernel. If the
    # conversion from string to System.Version object is successful, the version
    # object will be stored in this reference. If the conversion is not
    # successful, a warning will be returned and the referenced object will be
    # unmodified.
    #
    # .PARAMETER ReferenceToStringVersion
    # This parameter is required; it is a reference to a string that will be
    # modified to contain the version of the Windows kernel.
    #
    # .PARAMETER OSSystemVersionFromWMI
    # This parameter is optional; if supplied, is a System.Version object that
    # contains the version of Windows as determined using WMI
    # (Win32_OperatingSystem -> Version). If this parameter is not supplied, the
    # function will attempt to retrieve the version of Windows using WMI. If the
    # version of the Windows as reported by WMI is already known, it can be passed
    # in to this function to avoid the overhead of unnecessarily determining the
    # version of Windows using WMI.
    #
    # .PARAMETER KernelSystemVersion
    # This parameter is optional; if supplied, is a System.Version object that
    # contains the version of the Windows kernel. If this parameter is not
    # supplied, the function will attempt to retrieve the version of the Windows
    # kernel. If the version of the Windows kernel is already known, it can be
    # passed in to this function to avoid the overhead of unnecessarily
    # determining the version of the Windows kernel.
    #
    # .PARAMETER OSSystemVersionFromVerCommand
    # This parameter is optional; if supplied, is a System.Version object that
    # contains the version of Windows as determined using the "ver" command in a
    # command prompt. If this parameter is not supplied, the function will attempt
    # to retrieve the version of Windows using the ver command. If the version of
    # Windows as reported by the ver command is already known, it can be passed in
    # to this function to avoid the overhead of unnecessarily determining the
    # version of Windows using the ver command.
    #
    # .PARAMETER PSVersion
    # This parameter is optional; if supplied, it must be the version number of the
    # running version of PowerShell. If the version of PowerShell is already known,
    # it can be passed in to this function to avoid the overhead of unnecessarily
    # determining the version of PowerShell. If this parameter is not supplied, the
    # function will determine the version of PowerShell that is running as part of
    # its processing.
    #
    # .PARAMETER PathToCommandPrompt
    # This parameter is optional; if supplied, it is a string that represents the
    # path to the command prompt executable (cmd.exe). If this parameter is not
    # supplied, the function will automatically attempt to determine the path.
    #
    # .PARAMETER OSNativeSystemPath
    # This parameter is optional; if supplied, it is a string representing the
    # path to the OS processor architecture-native System32 folder path (e.g,
    # C:\Windows\System32 or C:\Windows\Sysnative). It is used to determine the
    # path to the Windows kernel. If not supplied, this function will automatically
    # attempt to retrieve the OS native System32 folder path.
    #
    # .PARAMETER OSProcessorArchitecture
    # This parameter is optional; if supplied, it is a string representing the
    # Windows operating system processor architecture. It is used to determine the
    # "bit width" of the operating system. If not supplied, this function will
    # automatically attempt to retrieve the OS processor architecture.
    #
    # .PARAMETER ProcessProcessorArchitecture
    # This parameter is optional; if supplied, it is a string representing the
    # current process's processor architecture. It is used to determine the "bit
    # width" of the code for the running process. If not supplied, this function
    # will automatically attempt to retrieve the process processor architecture.
    #
    # .EXAMPLE
    # $versionWindows = [version]'0.0'
    # $strWindowsVersion = ''
    # $intReturnCode = Get-WindowsOSVersion -ReferenceToSystemVersion ([ref]$versionWindows) -ReferenceToStringVersion ([ref]$strWindowsVersion)
    #
    # .INPUTS
    # None. You can't pipe objects to Get-WindowsOSVersion.
    #
    # .OUTPUTS
    # System.Int32. Get-WindowsOSVersion returns an integer value indiciating
    # whether the process completed successfully. 0 or a positive number means the
    # process completed successfully; a negative number means there was an error.
    #
    # .NOTES
    # This function is a work in progress; it will undergo significant
    # modifications to bring it up to feature parity with
    # GetWindowsOperatingSystemVersionNumberAsString.vbs from SysadminAccelerator:
    # https://github.com/franklesniak/sysadmin-accelerator/blob/99bb8b23bca51a118d39df0ee440e731498cf115/VBScript/02_Upfront_Encapsulated_Code_With_No_Dependencies/GetWindowsOperatingSystemVersionNumberAsString.vbs
    #
    # Version: 0.1.20250406.0

    #region License ############################################################
    # Copyright (c) 2025 Frank Lesniak
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
        [ref]$ReferenceToSystemVersion = ([ref]$null),
        [ref]$ReferenceToStringVersion = ([ref]$null),
        [version]$OSSystemVersionFromWMI = ([version]'0.0'),
        [version]$KernelSystemVersion = ([version]'0.0'),
        [version]$OSSystemVersionFromVerCommand = ([version]'0.0'),
        [version]$PSVersion = ([version]'0.0'),
        [string]$PathToCommandPrompt = '',
        [string]$OSNativeSystemPath = '',
        [string]$OSProcessorArchitecture = '',
        [string]$ProcessProcessorArchitecture = ''
    )

    function Get-WindowsOSVersionFromWMI {
        # .SYNOPSIS
        # Gets the Windows operating system version from WMI.
        #
        # .DESCRIPTION
        # This function retrieves the Windows operating system version from WMI.
        # It uses the Win32_OperatingSystem class to get the version information. The
        # function attempts a conversion of the operating system version from string to
        # .NET version (System.Version) object. If the conversion is successful, the
        # function returns the version as a System.Version object.
        #
        # .PARAMETER ReferenceToSystemVersion
        # This parameter is required; it is a reference to a System.Version object that
        # will be modified to contain the version of the Windows kernel. If the
        # conversion from string to System.Version object is successful, the version
        # object will be stored in this reference. If the conversion is not
        # successful, a warning will be returned and the referenced object will be
        # unmodified.
        #
        # .PARAMETER ReferenceToStringVersion
        # This parameter is required; it is a reference to a string that will be
        # modified to contain the version of the Windows kernel.
        #
        # .PARAMETER ReferenceToArrayOfLeftoverStrings
        # This parameter is required; it is a reference to an array of five
        # elements. Each element is a string; One or more of the elements may be
        # modified if the string could not be converted to a version object. If the
        # string could not be converted to a version object, any portions of the
        # string that exceed the major, minor, build, and revision version portions
        # will be stored in the elements of the array.
        #
        # The first element of the array will be modified if the major version
        # portion of the string could not be converted to a version object. If the
        # major version portion of the string could not be converted to a version
        # object, the left-most numerical-only portion of the major version will be
        # used to generate the version object. The remaining portion of the major
        # version will be stored in the first element of the array.
        #
        # The second element of the array will be modified if the minor version
        # portion of the string could not be converted to a version object. If the
        # minor version portion of the string could not be converted to a version
        # object, the left-most numerical-only portion of the minor version will be
        # used to generate the version object. The remaining portion of the minor
        # version will be stored in second element of the array.
        #
        # If the major version portion of the string could not be converted to a
        # version object, the entire minor version portion of the string will be
        # stored in the second element, and no portion of the supplied minor
        # version reference will be used to generate the version object.
        #
        # The third element of the array will be modified if the build version
        # portion of the string could not be converted to a version object. If the
        # build version portion of the string could not be converted to a version
        # object, the left-most numerical-only portion of the build version will be
        # used to generate the version object. The remaining portion of the build
        # version will be stored in the third element of the array.
        #
        # If the major or minor version portions of the string could not be
        # converted to a version object, the entire build version portion of the
        # string will be stored in the third element, and no portion of the
        # supplied build version reference will be used to generate the version
        # object.
        #
        # The fourth element of the array will be modified if the revision version
        # portion of the string could not be converted to a version object. If the
        # revision version portion of the string could not be converted to a
        # version object, the left-most numerical-only portion of the revision
        # version will be used to generate the version object. The remaining
        # portion of the revision version will be stored in the fourth element of
        # the array.
        #
        # If the major, minor, or build version portions of the string could not be
        # converted to a version object, the entire revision version portion of the
        # string will be stored in the fourth element, and no portion of the
        # supplied revision version reference will be used to generate the version
        # object.
        #
        # The fifth element of the array will be modified if the string could not
        # be converted to a version object. If the string could not be converted to
        # a version object, any portions of the string that exceed the major,
        # minor, build, and revision version portions will be stored in the string
        # reference.
        #
        # For example, if the string is '1.2.3.4.5', the fifth element in the array
        # will be '5'. If the string is '1.2.3.4.5.6', the fifth element of the
        # array will be '5.6'.
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
        # $versionPS = $PSVersionTable.PSVersion
        # $versionWindows = [version]'0.0'
        # $strWindowsVersion = ''
        # $arrLeftoverStrings = @('', '', '', '', '')
        # $intReturnCode = Get-WindowsOSVersionFromWMI -ReferenceToSystemVersion ([ref]$versionWindows) -ReferenceToStringVersion ([ref]$strWindowsVersion) -ReferenceToArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -PSVersion $versionPS
        #
        # .EXAMPLE
        # $versionWindows = [version]'0.0'
        # $strWindowsVersion = ''
        # $arrLeftoverStrings = @('', '', '', '', '')
        # $intReturnCode = Get-WindowsOSVersionFromWMI -ReferenceToSystemVersion ([ref]$versionWindows) -ReferenceToStringVersion ([ref]$strWindowsVersion) -ReferenceToArrayOfLeftoverStrings ([ref]$arrLeftoverStrings)
        #
        # .INPUTS
        # None. You can't pipe objects to Get-WindowsOSVersionFromWMI.
        #
        # .OUTPUTS
        # System.Int32. Get-WindowsOSVersionFromWMI returns an integer value indicating
        # whether the process completed successfully. 0 means the process completed
        # successfully, a negative value indicates that an error occurred, and a
        # positive value indicates that the process completed but there was one or more
        # warnings.
        #
        # .NOTES
        # Version: 1.0.20250406.2

        #region License ############################################################
        # Copyright (c) 2025 Frank Lesniak
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
            [ref]$ReferenceToSystemVersion = ([ref]$null),
            [ref]$ReferenceToStringVersion = ([ref]$null),
            [ref]$ReferenceToArrayOfLeftoverStrings = ([ref]$null),
            [version]$PSVersion = ([version]'0.0')
        )

        #region FunctionsToSupportErrorHandling ####################################
        function Get-ReferenceToLastError {
            # .SYNOPSIS
            # Gets a reference (memory pointer) to the last error that
            # occurred.
            #
            # .DESCRIPTION
            # Returns a reference (memory pointer) to $null ([ref]$null) if no
            # errors on on the $error stack; otherwise, returns a reference to
            # the last error that occurred.
            #
            # .EXAMPLE
            # # Intentionally empty trap statement to prevent terminating
            # # errors from halting processing
            # trap { }
            #
            # # Retrieve the newest error on the stack prior to doing work:
            # $refLastKnownError = Get-ReferenceToLastError
            #
            # # Store current error preference; we will restore it after we do
            # # some work:
            # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
            #
            # # Set ErrorActionPreference to SilentlyContinue; this will
            # # suppress error output. Terminating errors will not output
            # # anything, kick to the empty trap statement and then continue
            # # on. Likewise, non- terminating errors will also not output
            # # anything, but they do not kick to the trap statement; they
            # # simply continue on.
            # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            #
            # # Do something that might trigger an error
            # Get-Item -Path 'C:\MayNotExist.txt'
            #
            # # Restore the former error preference
            # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
            #
            # # Retrieve the newest error on the error stack
            # $refNewestCurrentError = Get-ReferenceToLastError
            #
            # $boolErrorOccurred = $false
            # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
            #     # Both not $null
            #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
            #         $boolErrorOccurred = $true
            #     }
            # } else {
            #     # One is $null, or both are $null
            #     # NOTE: $refLastKnownError could be non-null, while
            #     # $refNewestCurrentError could be null if $error was cleared;
            #     # this does not indicate an error.
            #     #
            #     # So:
            #     # If both are null, no error.
            #     # If $refLastKnownError is null and $refNewestCurrentError is
            #     # non-null, error.
            #     # If $refLastKnownError is non-null and
            #     # $refNewestCurrentError is null, no error.
            #     #
            #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
            #         $boolErrorOccurred = $true
            #     }
            # }
            #
            # .INPUTS
            # None. You can't pipe objects to Get-ReferenceToLastError.
            #
            # .OUTPUTS
            # System.Management.Automation.PSReference ([ref]).
            # Get-ReferenceToLastError returns a reference (memory pointer) to
            # the last error that occurred. It returns a reference to $null
            # ([ref]$null) if there are no errors on on the $error stack.
            #
            # .NOTES
            # Version: 2.0.20250215.1

            #region License ################################################
            # Copyright (c) 2025 Frank Lesniak
            #
            # Permission is hereby granted, free of charge, to any person
            # obtaining a copy of this software and associated documentation
            # files (the "Software"), to deal in the Software without
            # restriction, including without limitation the rights to use,
            # copy, modify, merge, publish, distribute, sublicense, and/or sell
            # copies of the Software, and to permit persons to whom the
            # Software is furnished to do so, subject to the following
            # conditions:
            #
            # The above copyright notice and this permission notice shall be
            # included in all copies or substantial portions of the Software.
            #
            # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
            # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
            # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
            # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
            # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
            # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
            # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
            # OTHER DEALINGS IN THE SOFTWARE.
            #endregion License ################################################

            if ($Error.Count -gt 0) {
                return ([ref]($Error[0]))
            } else {
                return ([ref]$null)
            }
        }

        function Test-ErrorOccurred {
            # .SYNOPSIS
            # Checks to see if an error occurred during a time period, i.e.,
            # during the execution of a command.
            #
            # .DESCRIPTION
            # Using two references (memory pointers) to errors, this function
            # checks to see if an error occurred based on differences between
            # the two errors.
            #
            # To use this function, you must first retrieve a reference to the
            # last error that occurred prior to the command you are about to
            # run. Then, run the command. After the command completes, retrieve
            # a reference to the last error that occurred. Pass these two
            # references to this function to determine if an error occurred.
            #
            # .PARAMETER ReferenceToEarlierError
            # This parameter is required; it is a reference (memory pointer) to
            # a System.Management.Automation.ErrorRecord that represents the
            # newest error on the stack earlier in time, i.e., prior to running
            # the command for which you wish to determine whether an error
            # occurred.
            #
            # If no error was on the stack at this time,
            # ReferenceToEarlierError must be a reference to $null
            # ([ref]$null).
            #
            # .PARAMETER ReferenceToLaterError
            # This parameter is required; it is a reference (memory pointer) to
            # a System.Management.Automation.ErrorRecord that represents the
            # newest error on the stack later in time, i.e., after to running
            # the command for which you wish to determine whether an error
            # occurred.
            #
            # If no error was on the stack at this time, ReferenceToLaterError
            # must be a reference to $null ([ref]$null).
            #
            # .EXAMPLE
            # # Intentionally empty trap statement to prevent terminating
            # # errors from halting processing
            # trap { }
            #
            # # Retrieve the newest error on the stack prior to doing work
            # if ($Error.Count -gt 0) {
            #     $refLastKnownError = ([ref]($Error[0]))
            # } else {
            #     $refLastKnownError = ([ref]$null)
            # }
            #
            # # Store current error preference; we will restore it after we do
            # # some work:
            # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
            #
            # # Set ErrorActionPreference to SilentlyContinue; this will
            # # suppress error output. Terminating errors will not output
            # # anything, kick to the empty trap statement and then continue
            # # on. Likewise, non- terminating errors will also not output
            # # anything, but they do not kick to the trap statement; they
            # # simply continue on.
            # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            #
            # # Do something that might trigger an error
            # Get-Item -Path 'C:\MayNotExist.txt'
            #
            # # Restore the former error preference
            # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
            #
            # # Retrieve the newest error on the error stack
            # if ($Error.Count -gt 0) {
            #     $refNewestCurrentError = ([ref]($Error[0]))
            # } else {
            #     $refNewestCurrentError = ([ref]$null)
            # }
            #
            # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
            #     # Error occurred
            # } else {
            #     # No error occurred
            # }
            #
            # .INPUTS
            # None. You can't pipe objects to Test-ErrorOccurred.
            #
            # .OUTPUTS
            # System.Boolean. Test-ErrorOccurred returns a boolean value
            # indicating whether an error occurred during the time period in
            # question. $true indicates an error occurred; $false indicates no
            # error occurred.
            #
            # .NOTES
            # This function also supports the use of positional parameters
            # instead of named parameters. If positional parameters are used
            # instead of named parameters, then two positional parameters are
            # required:
            #
            # The first positional parameter is a reference (memory pointer) to
            # a System.Management.Automation.ErrorRecord that represents the
            # newest error on the stack earlier in time, i.e., prior to running
            # the command for which you wish to determine whether an error
            # occurred. If no error was on the stack at this time, the first
            # positional parameter must be a reference to $null ([ref]$null).
            #
            # The second positional parameter is a reference (memory pointer)
            # to a System.Management.Automation.ErrorRecord that represents the
            # newest error on the stack later in time, i.e., after to running
            # the command for which you wish to determine whether an error
            # occurred. If no error was on the stack at this time,
            # ReferenceToLaterError must be a reference to $null ([ref]$null).
            #
            # Version: 2.0.20250215.0

            #region License ################################################
            # Copyright (c) 2025 Frank Lesniak
            #
            # Permission is hereby granted, free of charge, to any person
            # obtaining a copy of this software and associated documentation
            # files (the "Software"), to deal in the Software without
            # restriction, including without limitation the rights to use,
            # copy, modify, merge, publish, distribute, sublicense, and/or sell
            # copies of the Software, and to permit persons to whom the
            # Software is furnished to do so, subject to the following
            # conditions:
            #
            # The above copyright notice and this permission notice shall be
            # included in all copies or substantial portions of the Software.
            #
            # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
            # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
            # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
            # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
            # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
            # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
            # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
            # OTHER DEALINGS IN THE SOFTWARE.
            #endregion License ################################################
            param (
                [ref]$ReferenceToEarlierError = ([ref]$null),
                [ref]$ReferenceToLaterError = ([ref]$null)
            )

            # TODO: Validate input

            $boolErrorOccurred = $false
            if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                # Both not $null
                if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                    $boolErrorOccurred = $true
                }
            } else {
                # One is $null, or both are $null
                # NOTE: $ReferenceToEarlierError could be non-null, while
                # $ReferenceToLaterError could be null if $error was cleared;
                # this does not indicate an error.
                # So:
                # - If both are null, no error.
                # - If $ReferenceToEarlierError is null and
                #   $ReferenceToLaterError is non-null, error.
                # - If $ReferenceToEarlierError is non-null and
                #   $ReferenceToLaterError is null, no error.
                if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                    $boolErrorOccurred = $true
                }
            }

            return $boolErrorOccurred
        }
        #endregion FunctionsToSupportErrorHandling ####################################

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

        function Convert-StringToFlexibleVersion {
            # .SYNOPSIS
            # Converts a string to a version object. However, when the string contains
            # characters not allowed in a version object, this function will attempt to
            # convert the string to a version object by removing the characters that
            # are not allowed, identifying the portions of the version object that are
            # not allowed, which can be evaluated further if needed.
            #
            # .DESCRIPTION
            # First attempts to convert a string to a version object. If the string
            # contains characters not allowed in a version object, this function will
            # iteratively attempt to convert the string to a version object by removing
            # period-separated substrings, working right to left, until the version is
            # successfully converted. Then, for the portions that could not be
            # converted, the function will select the numerical-only portions of the
            # problematic substrings and use those to generate a "best effort" version
            # object. The leftover portions of the substrings that could not be
            # converted will be returned by reference.
            #
            # .PARAMETER ReferenceToVersionObject
            # This parameter is required; it is a reference to a System.Version object
            # that will be used to store the version object that is generated from the
            # string. If the string is successfully converted to a version object, the
            # version object will be stored in this reference. If one or more portions
            # of the string could not be converted to a version object, the version
            # object will be generated from the portions that could be converted, and
            # the portions that could not be converted will be stored in the
            # other reference parameters.
            #
            # .PARAMETER ReferenceArrayOfLeftoverStrings
            # This parameter is required; it is a reference to an array of five
            # elements. Each element is a string; One or more of the elements may be
            # modified if the string could not be converted to a version object. If the
            # string could not be converted to a version object, any portions of the
            # string that exceed the major, minor, build, and revision version portions
            # will be stored in the elements of the array.
            #
            # The first element of the array will be modified if the major version
            # portion of the string could not be converted to a version object. If the
            # major version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the major version will be
            # used to generate the version object. The remaining portion of the major
            # version will be stored in the first element of the array.
            #
            # The second element of the array will be modified if the minor version
            # portion of the string could not be converted to a version object. If the
            # minor version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the minor version will be
            # used to generate the version object. The remaining portion of the minor
            # version will be stored in second element of the array.
            #
            # If the major version portion of the string could not be converted to a
            # version object, the entire minor version portion of the string will be
            # stored in the second element, and no portion of the supplied minor
            # version reference will be used to generate the version object.
            #
            # The third element of the array will be modified if the build version
            # portion of the string could not be converted to a version object. If the
            # build version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the build version will be
            # used to generate the version object. The remaining portion of the build
            # version will be stored in the third element of the array.
            #
            # If the major or minor version portions of the string could not be
            # converted to a version object, the entire build version portion of the
            # string will be stored in the third element, and no portion of the
            # supplied build version reference will be used to generate the version
            # object.
            #
            # The fourth element of the array will be modified if the revision version
            # portion of the string could not be converted to a version object. If the
            # revision version portion of the string could not be converted to a
            # version object, the left-most numerical-only portion of the revision
            # version will be used to generate the version object. The remaining
            # portion of the revision version will be stored in the fourth element of
            # the array.
            #
            # If the major, minor, or build version portions of the string could not be
            # converted to a version object, the entire revision version portion of the
            # string will be stored in the fourth element, and no portion of the
            # supplied revision version reference will be used to generate the version
            # object.
            #
            # The fifth element of the array will be modified if the string could not
            # be converted to a version object. If the string could not be converted to
            # a version object, any portions of the string that exceed the major,
            # minor, build, and revision version portions will be stored in the string
            # reference.
            #
            # For example, if the string is '1.2.3.4.5', the fifth element in the array
            # will be '5'. If the string is '1.2.3.4.5.6', the fifth element of the
            # array will be '5.6'.
            #
            # .PARAMETER StringToConvert
            # This parameter is required; it is string that will be converted to a
            # version object. If the string contains characters not allowed in a
            # version object, this function will attempt to convert the string to a
            # version object by removing the characters that are not allowed,
            # identifying the portions of the version object that are not allowed,
            # which can be evaluated further if needed.
            #
            # .PARAMETER PSVersion
            # This parameter is optional; it is a version object that represents the
            # version of PowerShell that is running the script. If this parameter is
            # supplied, it will improve the performance of the function by allowing it
            # to skip the determination of the PowerShell engine version.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.3.4'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 0 because the string is in a valid format for a
            # # version object.
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=3, Revision=4.
            # # All strings in $arrLeftoverStrings will be empty.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.3.4-beta3'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 4 because the string is not in a valid format
            # # for a version object. The 4 indicates that the revision version portion
            # # of the string could not be converted to a version object.
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=3, Revision=4.
            # # $arrLeftoverStrings[3] will be '-beta3'. All other elements of
            # # $arrLeftoverStrings will be empty.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.2147483700.4'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 3 because the string is not in a valid format
            # # for a version object. The 3 indicates that the build version portion of
            # # the string could not be converted to a version object (the value
            # # exceeds the maximum value for a version element - 2147483647).
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=2147483647, Revision=-1.
            # # $arrLeftoverStrings[2] will be '53' (2147483700 - 2147483647) and
            # # $arrLeftoverStrings[3] will be '4'. All other elements of
            # # $arrLeftoverStrings will be empty.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.2147483700-beta5.4'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 3 because the string is not in a valid format
            # # for a version object. The 3 indicates that the build version portion of
            # # the string could not be converted to a version object (the value
            # # exceeds the maximum value for a version element - 2147483647).
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=2147483647, Revision=-1.
            # # $arrLeftoverStrings[2] will be '53-beta5' (2147483700 - 2147483647)
            # # plus the non-numeric portion of the string ('-beta5') and
            # # $arrLeftoverStrings[3] will be '4'. All other elements of
            # # $arrLeftoverStrings will be empty.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.3.4.5'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 5 because the string is in a valid format for a
            # # version object. The 5 indicates that there were excess portions of the
            # # string that could not be converted to a version object.
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=3, Revision=4.
            # # $arrLeftoverStrings[4] will be '5'. All other elements of
            # # $arrLeftoverStrings will be empty.
            #
            # .INPUTS
            # None. You can't pipe objects to Convert-StringToFlexibleVersion.
            #
            # .OUTPUTS
            # System.Int32. Convert-StringToFlexibleVersion returns an integer value
            # indicating whether the string was successfully converted to a version
            # object. The return value is as follows:
            # 0: The string was successfully converted to a version object.
            # 1: The string could not be converted to a version object because the
            #    major version portion of the string contained characters that made it
            #    impossible to convert to a version object. With these characters
            #    removed, the major version portion of the string was converted to a
            #    version object.
            # 2: The string could not be converted to a version object because the
            #    minor version portion of the string contained characters that made it
            #    impossible to convert to a version object. With these characters
            #    removed, the minor version portion of the string was converted to a
            #    version object.
            # 3: The string could not be converted to a version object because the
            #    build version portion of the string contained characters that made it
            #    impossible to convert to a version object. With these characters
            #    removed, the build version portion of the string was converted to a
            #    version object.
            # 4: The string could not be converted to a version object because the
            #    revision version portion of the string contained characters that made
            #    it impossible to convert to a version object. With these characters
            #    removed, the revision version portion of the string was converted to a
            #    version object.
            # 5: The string was successfully converted to a version object, but there
            #    were excess portions of the string that could not be converted to a
            #    version object.
            # -1: The string could not be converted to a version object because the
            #     string did not begin with numerical characters.
            #
            # .NOTES
            # This function also supports the use of positional parameters instead of
            # named parameters. If positional parameters are used instead of named
            # parameters, then three or four positional parameters are required:
            #
            # The first positional parameter is a reference to a System.Version object
            # that will be used to store the version object that is generated from the
            # string. If the string is successfully converted to a version object, the
            # version object will be stored in this reference. If one or more portions
            # of the string could not be converted to a version object, the version
            # object will be generated from the portions that could be converted, and
            # the portions that could not be converted will be stored in the
            # other reference parameters.
            #
            # The second positional parameter is a reference to an array of five
            # elements. Each element is a string; One or more of the elements may be
            # modified if the string could not be converted to a version object. If the
            # string could not be converted to a version object, any portions of the
            # string that exceed the major, minor, build, and revision version portions
            # will be stored in the elements of the array.
            #
            # The first element of the array will be modified if the major version
            # portion of the string could not be converted to a version object. If the
            # major version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the major version will be
            # used to generate the version object. The remaining portion of the major
            # version will be stored in the first element of the array.
            #
            # The second element of the array will be modified if the minor version
            # portion of the string could not be converted to a version object. If the
            # minor version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the minor version will be
            # used to generate the version object. The remaining portion of the minor
            # version will be stored in second element of the array.
            #
            # If the major version portion of the string could not be converted to a
            # version object, the entire minor version portion of the string will be
            # stored in the second element, and no portion of the supplied minor
            # version reference will be used to generate the version object.
            #
            # The third element of the array will be modified if the build version
            # portion of the string could not be converted to a version object. If the
            # build version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the build version will be
            # used to generate the version object. The remaining portion of the build
            # version will be stored in the third element of the array.
            #
            # If the major or minor version portions of the string could not be
            # converted to a version object, the entire build version portion of the
            # string will be stored in the third element, and no portion of the
            # supplied build version reference will be used to generate the version
            # object.
            #
            # The fourth element of the array will be modified if the revision version
            # portion of the string could not be converted to a version object. If the
            # revision version portion of the string could not be converted to a
            # version object, the left-most numerical-only portion of the revision
            # version will be used to generate the version object. The remaining
            # portion of the revision version will be stored in the fourth element of
            # the array.
            #
            # If the major, minor, or build version portions of the string could not be
            # converted to a version object, the entire revision version portion of the
            # string will be stored in the fourth element, and no portion of the
            # supplied revision version reference will be used to generate the version
            # object.
            #
            # The fifth element of the array will be modified if the string could not
            # be converted to a version object. If the string could not be converted to
            # a version object, any portions of the string that exceed the major,
            # minor, build, and revision version portions will be stored in the string
            # reference.
            #
            # For example, if the string is '1.2.3.4.5', the fifth element in the array
            # will be '5'. If the string is '1.2.3.4.5.6', the fifth element of the
            # array will be '5.6'.
            #
            # The third positional parameter is string that will be converted to a
            # version object. If the string contains characters not allowed in a
            # version object, this function will attempt to convert the string to a
            # version object by removing the characters that are not allowed,
            # identifying the portions of the version object that are not allowed,
            # which can be evaluated further if needed.
            #
            # If supplied, the fourth positional parameter is a version object that
            # represents the version of PowerShell that is running the script. If this
            # parameter is supplied, it will improve the performance of the function by
            # allowing it to skip the determination of the PowerShell engine version.
            #
            # Version: 1.0.20250218.0

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
                [ref]$ReferenceToVersionObject = ([ref]$null),
                [ref]$ReferenceArrayOfLeftoverStrings = ([ref]$null),
                [string]$StringToConvert = '',
                [version]$PSVersion = ([version]'0.0')
            )

            function Convert-StringToVersionSafely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Version object.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Version object. If the
                # string cannot be converted to a System.Version object, the function
                # suppresses the error and returns $false. If the string can be
                # converted to a version object, the function returns $true and passes
                # the version object by reference to the caller.
                #
                # .PARAMETER ReferenceToVersionObject
                # This parameter is required; it is a reference to a System.Version
                # object that will be used to store the converted version object if the
                # conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Version object.
                #
                # .EXAMPLE
                # $version = $null
                # $strVersion = '1.2.3.4'
                # $boolSuccess = Convert-StringToVersionSafely -ReferenceToVersionObject ([ref]$version) -StringToConvert $strVersion
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $version will contain a System.Version object with major version 1,
                # # minor version 2, build version 3, and revision version 4.
                #
                # .EXAMPLE
                # $version = $null
                # $strVersion = '1'
                # $boolSuccess = Convert-StringToVersionSafely -ReferenceToVersionObject ([ref]$version) -StringToConvert $strVersion
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $version is undefined in this instance.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToVersionSafely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToVersionSafely returns a boolean value
                # indiciating whether the process completed successfully. $true means
                # the conversion completed successfully; $false means there was an
                # error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a System.Version
                # object that will be used to store the converted version object if the
                # conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Version object.
                #
                # Version: 1.0.20250215.0

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

                param (
                    [ref]$ReferenceToVersionObject = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToVersionObject.Value = [version]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

            function Split-StringOnLiteralString {
                # .SYNOPSIS
                # Splits a string into an array using a literal string as the splitter.
                #
                # .DESCRIPTION
                # Splits a string using a literal string (as opposed to regex). The
                # function is designed to be backward-compatible with all versions of
                # PowerShell and has been tested successfully on PowerShell v1. This
                # function behaves more like VBScript's Split() function than other
                # string splitting-approaches in PowerShell while avoiding the use of
                # RegEx.
                #
                # .PARAMETER StringToSplit
                # This parameter is required; it is the string to be split into an
                # array.
                #
                # .PARAMETER Splitter
                # This parameter is required; it is the string that will be used to
                # split the string specified in the StringToSplit parameter.
                #
                # .EXAMPLE
                # $result = Split-StringOnLiteralString -StringToSplit 'What do you think of this function?' -Splitter ' '
                # # $result.Count is 7
                # # $result[2] is 'you'
                #
                # .EXAMPLE
                # $result = Split-StringOnLiteralString 'What do you think of this function?' ' '
                # # $result.Count is 7
                #
                # .EXAMPLE
                # $result = Split-StringOnLiteralString -StringToSplit 'foo' -Splitter ' '
                # # $result.GetType().FullName is System.Object[]
                # # $result.Count is 1
                #
                # .EXAMPLE
                # $result = Split-StringOnLiteralString -StringToSplit 'foo' -Splitter ''
                # # $result.GetType().FullName is System.Object[]
                # # $result.Count is 5 because of how .NET handles a split using an
                # # empty string:
                # # $result[0] is ''
                # # $result[1] is 'f'
                # # $result[2] is 'o'
                # # $result[3] is 'o'
                # # $result[4] is ''
                #
                # .INPUTS
                # None. You can't pipe objects to Split-StringOnLiteralString.
                #
                # .OUTPUTS
                # System.String[]. Split-StringOnLiteralString returns an array of
                # strings, with each string being an element of the resulting array
                # from the split operation. This function always returns an array, even
                # when there is zero elements or one element in it.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is the string to be split into an
                # array.
                #
                # The second positional parameter is the string that will be used to
                # split the string specified in the first positional parameter.
                #
                # Also, please note that if -StringToSplit (or the first positional
                # parameter) is $null, then the function will return an array with one
                # element, which is an empty string. This is because the function
                # converts $null to an empty string before splitting the string.
                #
                # Version: 3.0.20250211.1

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

                param (
                    [string]$StringToSplit = '',
                    [string]$Splitter = ''
                )

                $strSplitterInRegEx = [regex]::Escape($Splitter)
                $result = @([regex]::Split($StringToSplit, $strSplitterInRegEx))

                # The following code forces the function to return an array, always,
                # even when there are zero or one elements in the array
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
                    return ($result)
                } elseif ($intElementCount -eq 0) {
                    return (, @())
                } elseif ($intElementCount -eq 1) {
                    return (, (, $StringToSplit))
                } else {
                    return ($result)
                }
            }

            function Convert-StringToInt32Safely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Int32.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Int32. If the string
                # cannot be converted to a System.Int32, the function suppresses the
                # error and returns $false. If the string can be converted to an
                # int32, the function returns $true and passes the int32 by
                # reference to the caller.
                #
                # .PARAMETER ReferenceToInt32
                # This parameter is required; it is a reference to a System.Int32
                # object that will be used to store the converted int32 object if the
                # conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Int32 object.
                #
                # .EXAMPLE
                # $int = $null
                # $strInt = '1234'
                # $boolSuccess = Convert-StringToInt32Safely -ReferenceToInt32 ([ref]$int) -StringToConvert $strInt
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $int will contain a System.Int32 object equal to 1234.
                #
                # .EXAMPLE
                # $int = $null
                # $strInt = 'abc'
                # $boolSuccess = Convert-StringToInt32Safely -ReferenceToInt32 ([ref]$int) -StringToConvert $strInt
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $int will be undefined in this case.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToInt32Safely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToInt32Safely returns a boolean value
                # indiciating whether the process completed successfully. $true means
                # the conversion completed successfully; $false means there was an
                # error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a System.Int32
                # object that will be used to store the converted int32 object if the
                # conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Int32 object.
                #
                # Version: 1.0.20250215.0

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

                param (
                    [ref]$ReferenceToInt32 = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToInt32.Value = [int32]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

            function Convert-StringToInt64Safely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Int64.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Int64. If the string
                # cannot be converted to a System.Int64, the function suppresses the
                # error and returns $false. If the string can be converted to an
                # int64, the function returns $true and passes the int64 by
                # reference to the caller.
                #
                # .PARAMETER ReferenceToInt64
                # This parameter is required; it is a reference to a System.Int64
                # object that will be used to store the converted int64 object if the
                # conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Int64 object.
                #
                # .EXAMPLE
                # $int = $null
                # $strInt = '1234'
                # $boolSuccess = Convert-StringToInt64Safely -ReferenceToInt64 ([ref]$int) -StringToConvert $strInt
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $int will contain a System.Int64 object equal to 1234.
                #
                # .EXAMPLE
                # $int = $null
                # $strInt = 'abc'
                # $boolSuccess = Convert-StringToInt64Safely -ReferenceToInt64 ([ref]$int) -StringToConvert $strInt
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $int will be undefined in this case.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToInt64Safely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToInt64Safely returns a boolean value
                # indiciating whether the process completed successfully. $true means
                # the conversion completed successfully; $false means there was an
                # error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a System.Int64
                # object that will be used to store the converted int64 object if the
                # conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Int64 object.
                #
                # Version: 1.0.20250215.0

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

                param (
                    [ref]$ReferenceToInt64 = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToInt64.Value = [int64]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

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

            function Convert-StringToBigIntegerSafely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Numerics.BigInteger object.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Numerics.BigInteger object.
                # If the string cannot be converted to a System.Numerics.BigInteger
                # object, the function suppresses the error and returns $false. If the
                # string can be converted to a bigint object, the function returns
                # $true and passes the bigint object by reference to the caller.
                #
                # .PARAMETER ReferenceToBigIntegerObject
                # This parameter is required; it is a reference to a
                # System.Numerics.BigInteger object that will be used to store the
                # converted bigint object if the conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Numerics.BigInteger object.
                #
                # .EXAMPLE
                # $bigint = $null
                # $strBigInt = '100000000000000000000000000000'
                # $boolSuccess = Convert-StringToBigIntegerSafely -ReferenceToBigIntegerObject ([ref]$bigint) -StringToConvert $strBigInt
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $bigint will contain a System.Numerics.BigInteger object equal to
                # # 100000000000000000000000000000.
                #
                # .EXAMPLE
                # $bigint = $null
                # $strBigInt = 'abc'
                # $boolSuccess = Convert-StringToBigIntegerSafely -ReferenceToBigIntegerObject ([ref]$bigint) -StringToConvert $strBigInt
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $bigint will be undefined in this case.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToBigIntegerSafely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToBigIntegerSafely returns a boolean
                # value indiciating whether the process completed successfully. $true
                # means the conversion completed successfully; $false means there was
                # an error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a
                # System.Numerics.BigInteger object that will be used to store the
                # converted bigint object if the conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Numerics.BigInteger object.
                #
                # Version: 1.0.20250216.0

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

                param (
                    [ref]$ReferenceToBigIntegerObject = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToBigIntegerObject.Value = [System.Numerics.BigInteger]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

            function Convert-StringToDoubleSafely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Double.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Double. If the string
                # cannot be converted to a System.Double, the function suppresses the
                # error and returns $false. If the string can be converted to an
                # double, the function returns $true and passes the double by
                # reference to the caller.
                #
                # .PARAMETER ReferenceToDouble
                # This parameter is required; it is a reference to a System.Double
                # object that will be used to store the converted double object if the
                # conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Double object.
                #
                # .EXAMPLE
                # $double = $null
                # $str = '100000000000000000000000'
                # $boolSuccess = Convert-StringToDoubleSafely -ReferenceToDouble ([ref]$double) -StringToConvert $str
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $double will contain a System.Double object equal to 1E+23
                #
                # .EXAMPLE
                # $double = $null
                # $str = 'abc'
                # $boolSuccess = Convert-StringToDoubleSafely -ReferenceToDouble ([ref]$double) -StringToConvert $str
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $double will undefined in this case.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToDoubleSafely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToDoubleSafely returns a boolean value
                # indiciating whether the process completed successfully. $true means
                # the conversion completed successfully; $false means there was an
                # error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a System.Double
                # object that will be used to store the converted double object if the
                # conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Double object.
                #
                # Version: 1.0.20250216.0

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

                param (
                    [ref]$ReferenceToDouble = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToDouble.Value = [double]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

            $ReferenceArrayOfLeftoverStrings.Value = @('', '', '', '', '')

            $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $StringToConvert

            if ($boolResult) {
                return 0
            }

            # If we are still here, the conversion was not successful.

            $arrVersionElements = Split-StringOnLiteralString -StringToSplit $StringToConvert -Splitter '.'
            $intCountOfVersionElements = $arrVersionElements.Count

            if ($intCountOfVersionElements -lt 2) {
                # You can't have a version with less than two elements
                return -1
            }

            if ($intCountOfVersionElements -ge 5) {
                $strExcessVersionElements = [string]::join('.', $arrVersionElements[4..($intCountOfVersionElements - 1)])
            } else {
                $strExcessVersionElements = ''
            }

            if ($intCountOfVersionElements -ge 3) {
                $intElementInQuestion = 3
            } else {
                $intElementInQuestion = $intCountOfVersionElements
            }

            $boolConversionSuccessful = $false

            # See if excess elements are our only problem
            if (-not [string]::IsNullOrEmpty($strExcessVersionElements)) {
                $strAttemptedVersion = [string]::join('.', $arrVersionElements[0..$intElementInQuestion])
                $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersion
                if ($boolResult) {
                    # Conversion successful; the only problem was the excess elements
                    $boolConversionSuccessful = $true
                    $intReturnValue = 5
                    ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                }
            }

            while ($intElementInQuestion -gt 0 -and -not $boolConversionSuccessful) {
                $strAttemptedVersion = [string]::join('.', $arrVersionElements[0..($intElementInQuestion - 1)])
                $boolResult = $false
                if ($intElementInQuestion -gt 1) {
                    $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersion
                }
                if ($boolResult -or $intElementInQuestion -eq 1) {
                    # Conversion successful or we're on the second element
                    # See if we can trim out non-numerical characters
                    $strRegexFirstNumericalCharacters = '^\d+'
                    $strFirstNumericalCharacters = [regex]::Match($arrVersionElements[$intElementInQuestion], $strRegexFirstNumericalCharacters).Value
                    if ([string]::IsNullOrEmpty($strFirstNumericalCharacters)) {
                        # No numerical characters found
                        ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = $arrVersionElements[$intElementInQuestion]
                        for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                            ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                        }
                        $boolConversionSuccessful = $true
                        $intReturnValue = $intElementInQuestion + 1
                        ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                    } else {
                        # Numerical characters found
                        $boolResult = Convert-StringToInt32Safely -ReferenceToInt32 ([ref]$null) -StringToConvert $strFirstNumericalCharacters
                        if ($boolResult) {
                            # Append the first numerical characters to the version
                            $strAttemptedVersionNew = $strAttemptedVersion + '.' + $strFirstNumericalCharacters
                            $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersionNew
                            if ($boolResult) {
                                # Conversion successful
                                $strExcessCharactersInThisElement = ($arrVersionElements[$intElementInQuestion]).Substring($strFirstNumericalCharacters.Length)
                                ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = $strExcessCharactersInThisElement
                                for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                    ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                }
                                $boolConversionSuccessful = $true
                                $intReturnValue = $intElementInQuestion + 1
                                ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                            } else {
                                # Conversion was not successful even though we just
                                # tried converting using numbers we know are
                                # convertable to an int32. This makes no sense.
                                # Throw warning:
                                $strMessage = 'Conversion of string "' + $strAttemptedVersionNew + '" to a version object failed even though "' + $strAttemptedVersion + '" converted to a version object just fine, and we proved that "' + $strFirstNumericalCharacters + '" was converted to an int32 object successfully. This should not be possible!'
                                Write-Warning -Message $strMessage
                            }
                        } else {
                            # The string of numbers could not be converted to an int32;
                            # this is probably because the represented number is too
                            # large.
                            # Try converting to int64:
                            $int64 = $null
                            $boolResult = Convert-StringToInt64Safely -ReferenceToInt64 ([ref]$int64) -StringToConvert $strFirstNumericalCharacters
                            if ($boolResult) {
                                # Converted to int64 but not int32
                                $intRemainder = $int64 - [int32]::MaxValue
                                $strAttemptedVersionNew = $strAttemptedVersion + '.' + [int32]::MaxValue
                                $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersionNew
                                if ($boolResult) {
                                    # Conversion successful
                                    $strExcessCharactersInThisElement = ($arrVersionElements[$intElementInQuestion]).Substring($strFirstNumericalCharacters.Length)
                                    ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = ([string]$intRemainder) + $strExcessCharactersInThisElement
                                    for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                        ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                    }
                                    $boolConversionSuccessful = $true
                                    $intReturnValue = $intElementInQuestion + 1
                                    ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                                } else {
                                    # Conversion was not successful even though we just
                                    # tried converting using numbers we know are
                                    # convertable to an int32. This makes no sense.
                                    # Throw warning:
                                    $strMessage = 'Conversion of string "' + $strAttemptedVersionNew + '" to a version object failed even though "' + $strAttemptedVersion + '" converted to a version object just fine, and we know that "' + ([string]([int32]::MaxValue)) + '" is a valid int32 number. This should not be possible!'
                                    Write-Warning -Message $strMessage
                                }
                            } else {
                                # Conversion to int64 failed; this is probably because
                                # the represented number is too large.
                                if ($PSVersion -eq ([version]'0.0')) {
                                    $versionPS = Get-PSVersion
                                } else {
                                    $versionPS = $PSVersion
                                }

                                if ($versionPS.Major -ge 3) {
                                    # Use bigint
                                    $bigint = $null
                                    $boolResult = Convert-StringToBigIntegerSafely -ReferenceToBigIntegerObject ([ref]$bigint) -StringToConvert $strFirstNumericalCharacters
                                    if ($boolResult) {
                                        # Converted to bigint but not int32 or
                                        # int64
                                        $bigintRemainder = $bigint - [int32]::MaxValue
                                        $strAttemptedVersionNew = $strAttemptedVersion + '.' + [int32]::MaxValue
                                        $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersionNew
                                        if ($boolResult) {
                                            # Conversion successful
                                            $strExcessCharactersInThisElement = ($arrVersionElements[$intElementInQuestion]).Substring($strFirstNumericalCharacters.Length)
                                            ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = ([string]$bigintRemainder) + $strExcessCharactersInThisElement
                                            for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                                ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                            }
                                            $boolConversionSuccessful = $true
                                            $intReturnValue = $intElementInQuestion + 1
                                            ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                                        } else {
                                            # Conversion was not successful even though
                                            # we just tried converting using numbers we
                                            # know are convertable to an int32. This
                                            # makes no sense. Throw warning:
                                            $strMessage = 'Conversion of string "' + $strAttemptedVersionNew + '" to a version object failed even though "' + $strAttemptedVersion + '" converted to a version object just fine, and we know that "' + ([string]([int32]::MaxValue)) + '" is a valid int32 number. This should not be possible!'
                                            Write-Warning -Message $strMessage
                                        }
                                    } else {
                                        # Conversion to bigint failed; given that we
                                        # know that the string is all numbers, this
                                        # should not be possible. Throw warning
                                        $strMessage = 'The string "' + $strFirstNumericalCharacters + '" could not be converted to an int32, int64, or bigint number. This should not be possible!'
                                        Write-Warning -Message $strMessage
                                    }
                                } else {
                                    # Use double
                                    $double = $null
                                    $boolResult = Convert-StringToDoubleSafely -ReferenceToDouble ([ref]$double) -StringToConvert $strFirstNumericalCharacters
                                    if ($boolResult) {
                                        # Converted to double but not int32 or
                                        # int64
                                        $doubleRemainder = $double - [int32]::MaxValue
                                        $strAttemptedVersionNew = $strAttemptedVersion + '.' + [int32]::MaxValue
                                        $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersionNew
                                        if ($boolResult) {
                                            # Conversion successful
                                            $strExcessCharactersInThisElement = ($arrVersionElements[$intElementInQuestion]).Substring($strFirstNumericalCharacters.Length)
                                            ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = ([string]$doubleRemainder) + $strExcessCharactersInThisElement
                                            for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                                ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                            }
                                            $boolConversionSuccessful = $true
                                            $intReturnValue = $intElementInQuestion + 1
                                            ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                                        } else {
                                            # Conversion was not successful even though
                                            # we just tried converting using numbers we
                                            # know are convertable to an int32. This
                                            # makes no sense. Throw warning:
                                            $strMessage = 'Conversion of string "' + $strAttemptedVersionNew + '" to a version object failed even though "' + $strAttemptedVersion + '" converted to a version object just fine, and we know that "' + ([string]([int32]::MaxValue)) + '" is a valid int32 number. This should not be possible!'
                                            Write-Warning -Message $strMessage
                                        }
                                    } else {
                                        # Conversion to double failed; given that we
                                        # know that the string is all numbers, this
                                        # should not be possible unless the string of
                                        # numbers exceeded the maximum size allowed
                                        # for a double. This is possible, so don't
                                        # throw a warning.
                                        # Treat like no numerical characters found
                                        ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = $arrVersionElements[$intElementInQuestion]
                                        for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                            ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                        }
                                        $boolConversionSuccessful = $true
                                        $intReturnValue = $intElementInQuestion + 1
                                        ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                                    }
                                }
                            }
                        }
                    }
                }
                $intElementInQuestion--
            }

            if (-not $boolConversionSuccessful) {
                # Conversion was not successful
                return -1
            } else {
                return $intReturnValue
            }
        }

        trap {
            # Intentionally left empty to prevent terminating errors from halting
            # processing
        }

        if ($PSVersion -ne ([version]'0.0')) {
            $refPSVersion = [ref]$PSVersion
        } else {
            $versionPS = Get-PSVersion
            $refPSVersion = [ref]$versionPS
        }

        # Retrieve the newest error on the stack prior to doing work
        $refLastKnownError = Get-ReferenceToLastError

        # Store current error preference; we will restore it after we do the work of
        # this function
        $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

        # Set ErrorActionPreference to SilentlyContinue; this will suppress error
        # output. Terminating errors will not output anything, kick to the empty trap
        # statement and then continue on. Likewise, non-terminating errors will also
        # not output anything, but they do not kick to the trap statement; they simply
        # continue on.
        $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

        # The below line is a "one liner" version of the following code; it must be one
        # line in order for error handling to work correctly!
        ###############################################################################
        # $intFunctionReturn = 0
        # if (($refPSVersion.Value).Major -ge 3) {
        #     $arrCIMInstanceOS = @(Get-CimInstance -Query "Select Version from Win32_OperatingSystem")
        #     if ($arrCIMInstanceOS.Count -eq 0) {
        #         return -1
        #     }
        #     $ReferenceToStringVersion.Value = ($arrCIMInstanceOS[0]).Version
        #     if ($arrCIMInstanceOS.Count -gt 1) {
        #         $intFunctionReturn += 1
        #     }
        # } else {
        #     $arrManagementObjectOS = @(Get-WmiObject -Query "Select Version from Win32_OperatingSystem")
        #     if ($arrManagementObjectOS.Count -eq 0) {
        #         return -2
        #     }
        #     $ReferenceToStringVersion.Value = ($arrManagementObjectOS[0]).Version
        #     if ($arrManagementObjectOS.Count -gt 1) {
        #         $intFunctionReturn += 2
        #     }
        # }
        ###############################################################################
        $intFunctionReturn = 0; if (($refPSVersion.Value).Major -ge 3) { $arrCIMInstanceOS = @(Get-CimInstance -Query "Select Version from Win32_OperatingSystem"); if ($arrCIMInstanceOS.Count -eq 0) { return -1 }; $ReferenceToStringVersion.Value = ($arrCIMInstanceOS[0]).Version; if ($arrCIMInstanceOS.Count -gt 1) { $intFunctionReturn += 1 } } else { $arrManagementObjectOS = @(Get-WmiObject -Query "Select Version from Win32_OperatingSystem"); if ($arrManagementObjectOS.Count -eq 0) { return -2 }; $ReferenceToStringVersion.Value = ($arrManagementObjectOS[0]).Version; if ($arrManagementObjectOS.Count -gt 1) { $intFunctionReturn += 2 } }

        # Restore the former error preference
        $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

        # Retrieve the newest error on the error stack
        $refNewestCurrentError = Get-ReferenceToLastError

        if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
            # Error occurred

            # Return failure indicator:
            return -3
        } else {
            # No error occurred

            # Operating system version string is stored in
            # $ReferenceToStringVersion.Value
            if ([string]::IsNullOrEmpty($ReferenceToStringVersion.Value)) {
                # No version information found; this is an error
                return -4
            }

            # Version information found; convert to a version object
            $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject $ReferenceToSystemVersion -ReferenceArrayOfLeftoverStrings $ReferenceToArrayOfLeftoverStrings -StringToConvert $ReferenceToStringVersion.Value
            if ($intReturnCode -lt 0) {
                # Conversion failed; return failure indicator
                return -4
            }
            return (($intReturnCode * 4) + $intFunctionReturn)
        }
    }

    function Get-WindowsOSVersionFromVerCommand {
        # .SYNOPSIS
        # Gets the version of the Windows operating system from the ver command.
        #
        # .DESCRIPTION
        # This function retrieves the version of the Windows operating system from the
        # ver command. It uses the ver command to get the version information and then
        # parses the output to extract the version number. The function attempts a
        # conversion of the operating system version from string to .NET version
        # (System.Version) object. If the conversion is successful, the function
        # returns the version as a System.Version object.
        #
        # .PARAMETER ReferenceToSystemVersion
        # This parameter is required; it is a reference to a System.Version object that
        # will be modified to contain the version of the Windows kernel. If the
        # conversion from string to System.Version object is successful, the version
        # object will be stored in this reference. If the conversion is not
        # successful, a warning will be returned and the referenced object will be
        # unmodified.
        #
        # .PARAMETER ReferenceToStringVersion
        # This parameter is required; it is a reference to a string that will be
        # modified to contain the version of the Windows kernel.
        #
        # .PARAMETER ReferenceToArrayOfLeftoverStrings
        # This parameter is required; it is a reference to an array of five
        # elements. Each element is a string; One or more of the elements may be
        # modified if the string could not be converted to a version object. If the
        # string could not be converted to a version object, any portions of the
        # string that exceed the major, minor, build, and revision version portions
        # will be stored in the elements of the array.
        #
        # The first element of the array will be modified if the major version
        # portion of the string could not be converted to a version object. If the
        # major version portion of the string could not be converted to a version
        # object, the left-most numerical-only portion of the major version will be
        # used to generate the version object. The remaining portion of the major
        # version will be stored in the first element of the array.
        #
        # The second element of the array will be modified if the minor version
        # portion of the string could not be converted to a version object. If the
        # minor version portion of the string could not be converted to a version
        # object, the left-most numerical-only portion of the minor version will be
        # used to generate the version object. The remaining portion of the minor
        # version will be stored in second element of the array.
        #
        # If the major version portion of the string could not be converted to a
        # version object, the entire minor version portion of the string will be
        # stored in the second element, and no portion of the supplied minor
        # version reference will be used to generate the version object.
        #
        # The third element of the array will be modified if the build version
        # portion of the string could not be converted to a version object. If the
        # build version portion of the string could not be converted to a version
        # object, the left-most numerical-only portion of the build version will be
        # used to generate the version object. The remaining portion of the build
        # version will be stored in the third element of the array.
        #
        # If the major or minor version portions of the string could not be
        # converted to a version object, the entire build version portion of the
        # string will be stored in the third element, and no portion of the
        # supplied build version reference will be used to generate the version
        # object.
        #
        # The fourth element of the array will be modified if the revision version
        # portion of the string could not be converted to a version object. If the
        # revision version portion of the string could not be converted to a
        # version object, the left-most numerical-only portion of the revision
        # version will be used to generate the version object. The remaining
        # portion of the revision version will be stored in the fourth element of
        # the array.
        #
        # If the major, minor, or build version portions of the string could not be
        # converted to a version object, the entire revision version portion of the
        # string will be stored in the fourth element, and no portion of the
        # supplied revision version reference will be used to generate the version
        # object.
        #
        # The fifth element of the array will be modified if the string could not
        # be converted to a version object. If the string could not be converted to
        # a version object, any portions of the string that exceed the major,
        # minor, build, and revision version portions will be stored in the string
        # reference.
        #
        # For example, if the string is '1.2.3.4.5', the fifth element in the array
        # will be '5'. If the string is '1.2.3.4.5.6', the fifth element of the
        # array will be '5.6'.
        #
        # .PARAMETER PathToCommandPrompt
        # This parameter is optional; if supplied, it is a string that represents the
        # path to the command prompt executable (cmd.exe). If this parameter is not
        # supplied, the function will automatically attempt to determine the path.
        #
        # .EXAMPLE
        # # The following line is an example; don't hard-code paths IRL!
        # $strPathToCommandPrompt = 'C:\Windows\System32\cmd.exe'
        # $versionWindows = [version]'0.0'
        # $strWindowsVersion = ''
        # $arrLeftoverStrings = @('', '', '', '', '')
        # $intReturnCode = Get-WindowsOSVersionFromVerCommand -ReferenceToSystemVersion ([ref]$versionWindows) -ReferenceToStringVersion ([ref]$versionWindows) -ReferenceToArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -PathToCommandPrompt $strPathToCommandPrompt
        #
        # .EXAMPLE
        # $versionWindows = [version]'0.0'
        # $strWindowsVersion = ''
        # $arrLeftoverStrings = @('', '', '', '', '')
        # $intReturnCode = Get-WindowsOSVersionFromVerCommand -ReferenceToSystemVersion ([ref]$versionWindows) -ReferenceToStringVersion ([ref]$versionWindows) -ReferenceToArrayOfLeftoverStrings ([ref]$arrLeftoverStrings)
        #
        # .INPUTS
        # None. You can't pipe objects to Get-WindowsOSVersionFromVerCommand.
        #
        # .OUTPUTS
        # System.Int32. Get-WindowsOSVersionFromVerCommand returns an integer value
        # indiciating whether the process completed successfully. 0 means the process
        # completed successfully, a negative value indicates that an error occurred,
        # and a positive value indicates that the process completed but there was one
        # or more warnings.
        #
        # .NOTES
        # Version: 1.0.20250406.1

        #region License ############################################################
        # Copyright (c) 2025 Frank Lesniak
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
            [ref]$ReferenceToSystemVersion = ([ref]$null),
            [ref]$ReferenceToStringVersion = ([ref]$null),
            [ref]$ReferenceToArrayOfLeftoverStrings = ([ref]$null),
            [string]$PathToCommandPrompt = ''
        )

        function Get-CommandPromptPath {
            # .SYNOPSIS
            # Gets the path to the command prompt executable (cmd.exe).
            #
            # .DESCRIPTION
            # This function retrieves the path to the command prompt executable
            # (cmd.exe) and returns it as a string. If the path was determined
            # successfully, the function returns $true; otherwise, it returns $false.
            #
            # .PARAMETER ReferenceToCommandPromptPath
            # This parameter is required; it is a reference to a string that will be
            # used to store the path to the command prompt executable (cmd.exe).
            #
            # .EXAMPLE
            # $strCommandPromptPath = ''
            # $boolSuccess = Get-CommandPromptPath -ReferenceToCommandPromptPath ([ref]$strCommandPromptPath)
            #
            # .EXAMPLE
            # $strCommandPromptPath = ''
            # $boolSuccess = Get-CommandPromptPath ([ref]$strCommandPromptPath)
            #
            # .INPUTS
            # None. You can't pipe objects to Get-CommandPromptPath.
            #
            # .OUTPUTS
            # System.Boolean. Get-CommandPromptPath returns a boolean value indiciating
            # whether the path to the command prompt was retrieved successfully. $true
            # means the path was retrieved successfully; $false means the path was not
            # retrieved successfully.
            #
            # .NOTES
            # This function also supports the use of a single positional parameter
            # instead of its named parameter. If a positional parameter is used instead
            # of the named parameter, then exactly one positional parameter is
            # required: it is a reference to a string that will be used to store the
            # path to the command prompt executable (cmd.exe)
            #
            # Version: 1.0.20250406.1

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
                [ref]$ReferenceToCommandPromptPath = ([ref]$null)
            )

            if (-not [string]::IsNullOrEmpty($env:ComSpec)) {
                $strCommandPromptPath = $env:ComSpec
            } elseif (-not [string]::IsNullOrEmpty([System.Environment]::SystemDirectory)) {
                $strSystemDirectory = [System.Environment]::SystemDirectory
                $strCommandPromptPath = Join-Path -Path $strSystemDirectory -ChildPath 'cmd.exe'
            } else {
                return $false
            }

            if (Test-Path -Path $strCommandPromptPath) {
                $ReferenceToCommandPromptPath.Value = $strCommandPromptPath
                return $true
            } else {
                return $false
            }
        }

        function Convert-StringToFlexibleVersion {
            # .SYNOPSIS
            # Converts a string to a version object. However, when the string contains
            # characters not allowed in a version object, this function will attempt to
            # convert the string to a version object by removing the characters that
            # are not allowed, identifying the portions of the version object that are
            # not allowed, which can be evaluated further if needed.
            #
            # .DESCRIPTION
            # First attempts to convert a string to a version object. If the string
            # contains characters not allowed in a version object, this function will
            # iteratively attempt to convert the string to a version object by removing
            # period-separated substrings, working right to left, until the version is
            # successfully converted. Then, for the portions that could not be
            # converted, the function will select the numerical-only portions of the
            # problematic substrings and use those to generate a "best effort" version
            # object. The leftover portions of the substrings that could not be
            # converted will be returned by reference.
            #
            # .PARAMETER ReferenceToVersionObject
            # This parameter is required; it is a reference to a System.Version object
            # that will be used to store the version object that is generated from the
            # string. If the string is successfully converted to a version object, the
            # version object will be stored in this reference. If one or more portions
            # of the string could not be converted to a version object, the version
            # object will be generated from the portions that could be converted, and
            # the portions that could not be converted will be stored in the
            # other reference parameters.
            #
            # .PARAMETER ReferenceArrayOfLeftoverStrings
            # This parameter is required; it is a reference to an array of five
            # elements. Each element is a string; One or more of the elements may be
            # modified if the string could not be converted to a version object. If the
            # string could not be converted to a version object, any portions of the
            # string that exceed the major, minor, build, and revision version portions
            # will be stored in the elements of the array.
            #
            # The first element of the array will be modified if the major version
            # portion of the string could not be converted to a version object. If the
            # major version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the major version will be
            # used to generate the version object. The remaining portion of the major
            # version will be stored in the first element of the array.
            #
            # The second element of the array will be modified if the minor version
            # portion of the string could not be converted to a version object. If the
            # minor version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the minor version will be
            # used to generate the version object. The remaining portion of the minor
            # version will be stored in second element of the array.
            #
            # If the major version portion of the string could not be converted to a
            # version object, the entire minor version portion of the string will be
            # stored in the second element, and no portion of the supplied minor
            # version reference will be used to generate the version object.
            #
            # The third element of the array will be modified if the build version
            # portion of the string could not be converted to a version object. If the
            # build version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the build version will be
            # used to generate the version object. The remaining portion of the build
            # version will be stored in the third element of the array.
            #
            # If the major or minor version portions of the string could not be
            # converted to a version object, the entire build version portion of the
            # string will be stored in the third element, and no portion of the
            # supplied build version reference will be used to generate the version
            # object.
            #
            # The fourth element of the array will be modified if the revision version
            # portion of the string could not be converted to a version object. If the
            # revision version portion of the string could not be converted to a
            # version object, the left-most numerical-only portion of the revision
            # version will be used to generate the version object. The remaining
            # portion of the revision version will be stored in the fourth element of
            # the array.
            #
            # If the major, minor, or build version portions of the string could not be
            # converted to a version object, the entire revision version portion of the
            # string will be stored in the fourth element, and no portion of the
            # supplied revision version reference will be used to generate the version
            # object.
            #
            # The fifth element of the array will be modified if the string could not
            # be converted to a version object. If the string could not be converted to
            # a version object, any portions of the string that exceed the major,
            # minor, build, and revision version portions will be stored in the string
            # reference.
            #
            # For example, if the string is '1.2.3.4.5', the fifth element in the array
            # will be '5'. If the string is '1.2.3.4.5.6', the fifth element of the
            # array will be '5.6'.
            #
            # .PARAMETER StringToConvert
            # This parameter is required; it is string that will be converted to a
            # version object. If the string contains characters not allowed in a
            # version object, this function will attempt to convert the string to a
            # version object by removing the characters that are not allowed,
            # identifying the portions of the version object that are not allowed,
            # which can be evaluated further if needed.
            #
            # .PARAMETER PSVersion
            # This parameter is optional; it is a version object that represents the
            # version of PowerShell that is running the script. If this parameter is
            # supplied, it will improve the performance of the function by allowing it
            # to skip the determination of the PowerShell engine version.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.3.4'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 0 because the string is in a valid format for a
            # # version object.
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=3, Revision=4.
            # # All strings in $arrLeftoverStrings will be empty.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.3.4-beta3'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 4 because the string is not in a valid format
            # # for a version object. The 4 indicates that the revision version portion
            # # of the string could not be converted to a version object.
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=3, Revision=4.
            # # $arrLeftoverStrings[3] will be '-beta3'. All other elements of
            # # $arrLeftoverStrings will be empty.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.2147483700.4'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 3 because the string is not in a valid format
            # # for a version object. The 3 indicates that the build version portion of
            # # the string could not be converted to a version object (the value
            # # exceeds the maximum value for a version element - 2147483647).
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=2147483647, Revision=-1.
            # # $arrLeftoverStrings[2] will be '53' (2147483700 - 2147483647) and
            # # $arrLeftoverStrings[3] will be '4'. All other elements of
            # # $arrLeftoverStrings will be empty.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.2147483700-beta5.4'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 3 because the string is not in a valid format
            # # for a version object. The 3 indicates that the build version portion of
            # # the string could not be converted to a version object (the value
            # # exceeds the maximum value for a version element - 2147483647).
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=2147483647, Revision=-1.
            # # $arrLeftoverStrings[2] will be '53-beta5' (2147483700 - 2147483647)
            # # plus the non-numeric portion of the string ('-beta5') and
            # # $arrLeftoverStrings[3] will be '4'. All other elements of
            # # $arrLeftoverStrings will be empty.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.3.4.5'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 5 because the string is in a valid format for a
            # # version object. The 5 indicates that there were excess portions of the
            # # string that could not be converted to a version object.
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=3, Revision=4.
            # # $arrLeftoverStrings[4] will be '5'. All other elements of
            # # $arrLeftoverStrings will be empty.
            #
            # .INPUTS
            # None. You can't pipe objects to Convert-StringToFlexibleVersion.
            #
            # .OUTPUTS
            # System.Int32. Convert-StringToFlexibleVersion returns an integer value
            # indicating whether the string was successfully converted to a version
            # object. The return value is as follows:
            # 0: The string was successfully converted to a version object.
            # 1: The string could not be converted to a version object because the
            #    major version portion of the string contained characters that made it
            #    impossible to convert to a version object. With these characters
            #    removed, the major version portion of the string was converted to a
            #    version object.
            # 2: The string could not be converted to a version object because the
            #    minor version portion of the string contained characters that made it
            #    impossible to convert to a version object. With these characters
            #    removed, the minor version portion of the string was converted to a
            #    version object.
            # 3: The string could not be converted to a version object because the
            #    build version portion of the string contained characters that made it
            #    impossible to convert to a version object. With these characters
            #    removed, the build version portion of the string was converted to a
            #    version object.
            # 4: The string could not be converted to a version object because the
            #    revision version portion of the string contained characters that made
            #    it impossible to convert to a version object. With these characters
            #    removed, the revision version portion of the string was converted to a
            #    version object.
            # 5: The string was successfully converted to a version object, but there
            #    were excess portions of the string that could not be converted to a
            #    version object.
            # -1: The string could not be converted to a version object because the
            #     string did not begin with numerical characters.
            #
            # .NOTES
            # This function also supports the use of positional parameters instead of
            # named parameters. If positional parameters are used instead of named
            # parameters, then three or four positional parameters are required:
            #
            # The first positional parameter is a reference to a System.Version object
            # that will be used to store the version object that is generated from the
            # string. If the string is successfully converted to a version object, the
            # version object will be stored in this reference. If one or more portions
            # of the string could not be converted to a version object, the version
            # object will be generated from the portions that could be converted, and
            # the portions that could not be converted will be stored in the
            # other reference parameters.
            #
            # The second positional parameter is a reference to an array of five
            # elements. Each element is a string; One or more of the elements may be
            # modified if the string could not be converted to a version object. If the
            # string could not be converted to a version object, any portions of the
            # string that exceed the major, minor, build, and revision version portions
            # will be stored in the elements of the array.
            #
            # The first element of the array will be modified if the major version
            # portion of the string could not be converted to a version object. If the
            # major version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the major version will be
            # used to generate the version object. The remaining portion of the major
            # version will be stored in the first element of the array.
            #
            # The second element of the array will be modified if the minor version
            # portion of the string could not be converted to a version object. If the
            # minor version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the minor version will be
            # used to generate the version object. The remaining portion of the minor
            # version will be stored in second element of the array.
            #
            # If the major version portion of the string could not be converted to a
            # version object, the entire minor version portion of the string will be
            # stored in the second element, and no portion of the supplied minor
            # version reference will be used to generate the version object.
            #
            # The third element of the array will be modified if the build version
            # portion of the string could not be converted to a version object. If the
            # build version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the build version will be
            # used to generate the version object. The remaining portion of the build
            # version will be stored in the third element of the array.
            #
            # If the major or minor version portions of the string could not be
            # converted to a version object, the entire build version portion of the
            # string will be stored in the third element, and no portion of the
            # supplied build version reference will be used to generate the version
            # object.
            #
            # The fourth element of the array will be modified if the revision version
            # portion of the string could not be converted to a version object. If the
            # revision version portion of the string could not be converted to a
            # version object, the left-most numerical-only portion of the revision
            # version will be used to generate the version object. The remaining
            # portion of the revision version will be stored in the fourth element of
            # the array.
            #
            # If the major, minor, or build version portions of the string could not be
            # converted to a version object, the entire revision version portion of the
            # string will be stored in the fourth element, and no portion of the
            # supplied revision version reference will be used to generate the version
            # object.
            #
            # The fifth element of the array will be modified if the string could not
            # be converted to a version object. If the string could not be converted to
            # a version object, any portions of the string that exceed the major,
            # minor, build, and revision version portions will be stored in the string
            # reference.
            #
            # For example, if the string is '1.2.3.4.5', the fifth element in the array
            # will be '5'. If the string is '1.2.3.4.5.6', the fifth element of the
            # array will be '5.6'.
            #
            # The third positional parameter is string that will be converted to a
            # version object. If the string contains characters not allowed in a
            # version object, this function will attempt to convert the string to a
            # version object by removing the characters that are not allowed,
            # identifying the portions of the version object that are not allowed,
            # which can be evaluated further if needed.
            #
            # If supplied, the fourth positional parameter is a version object that
            # represents the version of PowerShell that is running the script. If this
            # parameter is supplied, it will improve the performance of the function by
            # allowing it to skip the determination of the PowerShell engine version.
            #
            # Version: 1.0.20250218.0

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
                [ref]$ReferenceToVersionObject = ([ref]$null),
                [ref]$ReferenceArrayOfLeftoverStrings = ([ref]$null),
                [string]$StringToConvert = '',
                [version]$PSVersion = ([version]'0.0')
            )

            function Convert-StringToVersionSafely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Version object.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Version object. If the
                # string cannot be converted to a System.Version object, the function
                # suppresses the error and returns $false. If the string can be
                # converted to a version object, the function returns $true and passes
                # the version object by reference to the caller.
                #
                # .PARAMETER ReferenceToVersionObject
                # This parameter is required; it is a reference to a System.Version
                # object that will be used to store the converted version object if the
                # conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Version object.
                #
                # .EXAMPLE
                # $version = $null
                # $strVersion = '1.2.3.4'
                # $boolSuccess = Convert-StringToVersionSafely -ReferenceToVersionObject ([ref]$version) -StringToConvert $strVersion
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $version will contain a System.Version object with major version 1,
                # # minor version 2, build version 3, and revision version 4.
                #
                # .EXAMPLE
                # $version = $null
                # $strVersion = '1'
                # $boolSuccess = Convert-StringToVersionSafely -ReferenceToVersionObject ([ref]$version) -StringToConvert $strVersion
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $version is undefined in this instance.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToVersionSafely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToVersionSafely returns a boolean value
                # indiciating whether the process completed successfully. $true means
                # the conversion completed successfully; $false means there was an
                # error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a System.Version
                # object that will be used to store the converted version object if the
                # conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Version object.
                #
                # Version: 1.0.20250215.0

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

                param (
                    [ref]$ReferenceToVersionObject = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToVersionObject.Value = [version]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

            function Split-StringOnLiteralString {
                # .SYNOPSIS
                # Splits a string into an array using a literal string as the splitter.
                #
                # .DESCRIPTION
                # Splits a string using a literal string (as opposed to regex). The
                # function is designed to be backward-compatible with all versions of
                # PowerShell and has been tested successfully on PowerShell v1. This
                # function behaves more like VBScript's Split() function than other
                # string splitting-approaches in PowerShell while avoiding the use of
                # RegEx.
                #
                # .PARAMETER StringToSplit
                # This parameter is required; it is the string to be split into an
                # array.
                #
                # .PARAMETER Splitter
                # This parameter is required; it is the string that will be used to
                # split the string specified in the StringToSplit parameter.
                #
                # .EXAMPLE
                # $result = Split-StringOnLiteralString -StringToSplit 'What do you think of this function?' -Splitter ' '
                # # $result.Count is 7
                # # $result[2] is 'you'
                #
                # .EXAMPLE
                # $result = Split-StringOnLiteralString 'What do you think of this function?' ' '
                # # $result.Count is 7
                #
                # .EXAMPLE
                # $result = Split-StringOnLiteralString -StringToSplit 'foo' -Splitter ' '
                # # $result.GetType().FullName is System.Object[]
                # # $result.Count is 1
                #
                # .EXAMPLE
                # $result = Split-StringOnLiteralString -StringToSplit 'foo' -Splitter ''
                # # $result.GetType().FullName is System.Object[]
                # # $result.Count is 5 because of how .NET handles a split using an
                # # empty string:
                # # $result[0] is ''
                # # $result[1] is 'f'
                # # $result[2] is 'o'
                # # $result[3] is 'o'
                # # $result[4] is ''
                #
                # .INPUTS
                # None. You can't pipe objects to Split-StringOnLiteralString.
                #
                # .OUTPUTS
                # System.String[]. Split-StringOnLiteralString returns an array of
                # strings, with each string being an element of the resulting array
                # from the split operation. This function always returns an array, even
                # when there is zero elements or one element in it.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is the string to be split into an
                # array.
                #
                # The second positional parameter is the string that will be used to
                # split the string specified in the first positional parameter.
                #
                # Also, please note that if -StringToSplit (or the first positional
                # parameter) is $null, then the function will return an array with one
                # element, which is an empty string. This is because the function
                # converts $null to an empty string before splitting the string.
                #
                # Version: 3.0.20250211.1

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

                param (
                    [string]$StringToSplit = '',
                    [string]$Splitter = ''
                )

                $strSplitterInRegEx = [regex]::Escape($Splitter)
                $result = @([regex]::Split($StringToSplit, $strSplitterInRegEx))

                # The following code forces the function to return an array, always,
                # even when there are zero or one elements in the array
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
                    return ($result)
                } elseif ($intElementCount -eq 0) {
                    return (, @())
                } elseif ($intElementCount -eq 1) {
                    return (, (, $StringToSplit))
                } else {
                    return ($result)
                }
            }

            function Convert-StringToInt32Safely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Int32.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Int32. If the string
                # cannot be converted to a System.Int32, the function suppresses the
                # error and returns $false. If the string can be converted to an
                # int32, the function returns $true and passes the int32 by
                # reference to the caller.
                #
                # .PARAMETER ReferenceToInt32
                # This parameter is required; it is a reference to a System.Int32
                # object that will be used to store the converted int32 object if the
                # conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Int32 object.
                #
                # .EXAMPLE
                # $int = $null
                # $strInt = '1234'
                # $boolSuccess = Convert-StringToInt32Safely -ReferenceToInt32 ([ref]$int) -StringToConvert $strInt
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $int will contain a System.Int32 object equal to 1234.
                #
                # .EXAMPLE
                # $int = $null
                # $strInt = 'abc'
                # $boolSuccess = Convert-StringToInt32Safely -ReferenceToInt32 ([ref]$int) -StringToConvert $strInt
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $int will be undefined in this case.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToInt32Safely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToInt32Safely returns a boolean value
                # indiciating whether the process completed successfully. $true means
                # the conversion completed successfully; $false means there was an
                # error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a System.Int32
                # object that will be used to store the converted int32 object if the
                # conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Int32 object.
                #
                # Version: 1.0.20250215.0

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

                param (
                    [ref]$ReferenceToInt32 = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToInt32.Value = [int32]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

            function Convert-StringToInt64Safely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Int64.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Int64. If the string
                # cannot be converted to a System.Int64, the function suppresses the
                # error and returns $false. If the string can be converted to an
                # int64, the function returns $true and passes the int64 by
                # reference to the caller.
                #
                # .PARAMETER ReferenceToInt64
                # This parameter is required; it is a reference to a System.Int64
                # object that will be used to store the converted int64 object if the
                # conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Int64 object.
                #
                # .EXAMPLE
                # $int = $null
                # $strInt = '1234'
                # $boolSuccess = Convert-StringToInt64Safely -ReferenceToInt64 ([ref]$int) -StringToConvert $strInt
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $int will contain a System.Int64 object equal to 1234.
                #
                # .EXAMPLE
                # $int = $null
                # $strInt = 'abc'
                # $boolSuccess = Convert-StringToInt64Safely -ReferenceToInt64 ([ref]$int) -StringToConvert $strInt
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $int will be undefined in this case.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToInt64Safely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToInt64Safely returns a boolean value
                # indiciating whether the process completed successfully. $true means
                # the conversion completed successfully; $false means there was an
                # error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a System.Int64
                # object that will be used to store the converted int64 object if the
                # conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Int64 object.
                #
                # Version: 1.0.20250215.0

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

                param (
                    [ref]$ReferenceToInt64 = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToInt64.Value = [int64]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

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

            function Convert-StringToBigIntegerSafely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Numerics.BigInteger object.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Numerics.BigInteger object.
                # If the string cannot be converted to a System.Numerics.BigInteger
                # object, the function suppresses the error and returns $false. If the
                # string can be converted to a bigint object, the function returns
                # $true and passes the bigint object by reference to the caller.
                #
                # .PARAMETER ReferenceToBigIntegerObject
                # This parameter is required; it is a reference to a
                # System.Numerics.BigInteger object that will be used to store the
                # converted bigint object if the conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Numerics.BigInteger object.
                #
                # .EXAMPLE
                # $bigint = $null
                # $strBigInt = '100000000000000000000000000000'
                # $boolSuccess = Convert-StringToBigIntegerSafely -ReferenceToBigIntegerObject ([ref]$bigint) -StringToConvert $strBigInt
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $bigint will contain a System.Numerics.BigInteger object equal to
                # # 100000000000000000000000000000.
                #
                # .EXAMPLE
                # $bigint = $null
                # $strBigInt = 'abc'
                # $boolSuccess = Convert-StringToBigIntegerSafely -ReferenceToBigIntegerObject ([ref]$bigint) -StringToConvert $strBigInt
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $bigint will be undefined in this case.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToBigIntegerSafely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToBigIntegerSafely returns a boolean
                # value indiciating whether the process completed successfully. $true
                # means the conversion completed successfully; $false means there was
                # an error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a
                # System.Numerics.BigInteger object that will be used to store the
                # converted bigint object if the conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Numerics.BigInteger object.
                #
                # Version: 1.0.20250216.0

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

                param (
                    [ref]$ReferenceToBigIntegerObject = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToBigIntegerObject.Value = [System.Numerics.BigInteger]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

            function Convert-StringToDoubleSafely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Double.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Double. If the string
                # cannot be converted to a System.Double, the function suppresses the
                # error and returns $false. If the string can be converted to an
                # double, the function returns $true and passes the double by
                # reference to the caller.
                #
                # .PARAMETER ReferenceToDouble
                # This parameter is required; it is a reference to a System.Double
                # object that will be used to store the converted double object if the
                # conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Double object.
                #
                # .EXAMPLE
                # $double = $null
                # $str = '100000000000000000000000'
                # $boolSuccess = Convert-StringToDoubleSafely -ReferenceToDouble ([ref]$double) -StringToConvert $str
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $double will contain a System.Double object equal to 1E+23
                #
                # .EXAMPLE
                # $double = $null
                # $str = 'abc'
                # $boolSuccess = Convert-StringToDoubleSafely -ReferenceToDouble ([ref]$double) -StringToConvert $str
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $double will undefined in this case.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToDoubleSafely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToDoubleSafely returns a boolean value
                # indiciating whether the process completed successfully. $true means
                # the conversion completed successfully; $false means there was an
                # error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a System.Double
                # object that will be used to store the converted double object if the
                # conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Double object.
                #
                # Version: 1.0.20250216.0

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

                param (
                    [ref]$ReferenceToDouble = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToDouble.Value = [double]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

            $ReferenceArrayOfLeftoverStrings.Value = @('', '', '', '', '')

            $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $StringToConvert

            if ($boolResult) {
                return 0
            }

            # If we are still here, the conversion was not successful.

            $arrVersionElements = Split-StringOnLiteralString -StringToSplit $StringToConvert -Splitter '.'
            $intCountOfVersionElements = $arrVersionElements.Count

            if ($intCountOfVersionElements -lt 2) {
                # You can't have a version with less than two elements
                return -1
            }

            if ($intCountOfVersionElements -ge 5) {
                $strExcessVersionElements = [string]::join('.', $arrVersionElements[4..($intCountOfVersionElements - 1)])
            } else {
                $strExcessVersionElements = ''
            }

            if ($intCountOfVersionElements -ge 3) {
                $intElementInQuestion = 3
            } else {
                $intElementInQuestion = $intCountOfVersionElements
            }

            $boolConversionSuccessful = $false

            # See if excess elements are our only problem
            if (-not [string]::IsNullOrEmpty($strExcessVersionElements)) {
                $strAttemptedVersion = [string]::join('.', $arrVersionElements[0..$intElementInQuestion])
                $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersion
                if ($boolResult) {
                    # Conversion successful; the only problem was the excess elements
                    $boolConversionSuccessful = $true
                    $intReturnValue = 5
                    ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                }
            }

            while ($intElementInQuestion -gt 0 -and -not $boolConversionSuccessful) {
                $strAttemptedVersion = [string]::join('.', $arrVersionElements[0..($intElementInQuestion - 1)])
                $boolResult = $false
                if ($intElementInQuestion -gt 1) {
                    $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersion
                }
                if ($boolResult -or $intElementInQuestion -eq 1) {
                    # Conversion successful or we're on the second element
                    # See if we can trim out non-numerical characters
                    $strRegexFirstNumericalCharacters = '^\d+'
                    $strFirstNumericalCharacters = [regex]::Match($arrVersionElements[$intElementInQuestion], $strRegexFirstNumericalCharacters).Value
                    if ([string]::IsNullOrEmpty($strFirstNumericalCharacters)) {
                        # No numerical characters found
                        ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = $arrVersionElements[$intElementInQuestion]
                        for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                            ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                        }
                        $boolConversionSuccessful = $true
                        $intReturnValue = $intElementInQuestion + 1
                        ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                    } else {
                        # Numerical characters found
                        $boolResult = Convert-StringToInt32Safely -ReferenceToInt32 ([ref]$null) -StringToConvert $strFirstNumericalCharacters
                        if ($boolResult) {
                            # Append the first numerical characters to the version
                            $strAttemptedVersionNew = $strAttemptedVersion + '.' + $strFirstNumericalCharacters
                            $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersionNew
                            if ($boolResult) {
                                # Conversion successful
                                $strExcessCharactersInThisElement = ($arrVersionElements[$intElementInQuestion]).Substring($strFirstNumericalCharacters.Length)
                                ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = $strExcessCharactersInThisElement
                                for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                    ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                }
                                $boolConversionSuccessful = $true
                                $intReturnValue = $intElementInQuestion + 1
                                ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                            } else {
                                # Conversion was not successful even though we just
                                # tried converting using numbers we know are
                                # convertable to an int32. This makes no sense.
                                # Throw warning:
                                $strMessage = 'Conversion of string "' + $strAttemptedVersionNew + '" to a version object failed even though "' + $strAttemptedVersion + '" converted to a version object just fine, and we proved that "' + $strFirstNumericalCharacters + '" was converted to an int32 object successfully. This should not be possible!'
                                Write-Warning -Message $strMessage
                            }
                        } else {
                            # The string of numbers could not be converted to an int32;
                            # this is probably because the represented number is too
                            # large.
                            # Try converting to int64:
                            $int64 = $null
                            $boolResult = Convert-StringToInt64Safely -ReferenceToInt64 ([ref]$int64) -StringToConvert $strFirstNumericalCharacters
                            if ($boolResult) {
                                # Converted to int64 but not int32
                                $intRemainder = $int64 - [int32]::MaxValue
                                $strAttemptedVersionNew = $strAttemptedVersion + '.' + [int32]::MaxValue
                                $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersionNew
                                if ($boolResult) {
                                    # Conversion successful
                                    $strExcessCharactersInThisElement = ($arrVersionElements[$intElementInQuestion]).Substring($strFirstNumericalCharacters.Length)
                                    ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = ([string]$intRemainder) + $strExcessCharactersInThisElement
                                    for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                        ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                    }
                                    $boolConversionSuccessful = $true
                                    $intReturnValue = $intElementInQuestion + 1
                                    ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                                } else {
                                    # Conversion was not successful even though we just
                                    # tried converting using numbers we know are
                                    # convertable to an int32. This makes no sense.
                                    # Throw warning:
                                    $strMessage = 'Conversion of string "' + $strAttemptedVersionNew + '" to a version object failed even though "' + $strAttemptedVersion + '" converted to a version object just fine, and we know that "' + ([string]([int32]::MaxValue)) + '" is a valid int32 number. This should not be possible!'
                                    Write-Warning -Message $strMessage
                                }
                            } else {
                                # Conversion to int64 failed; this is probably because
                                # the represented number is too large.
                                if ($PSVersion -eq ([version]'0.0')) {
                                    $versionPS = Get-PSVersion
                                } else {
                                    $versionPS = $PSVersion
                                }

                                if ($versionPS.Major -ge 3) {
                                    # Use bigint
                                    $bigint = $null
                                    $boolResult = Convert-StringToBigIntegerSafely -ReferenceToBigIntegerObject ([ref]$bigint) -StringToConvert $strFirstNumericalCharacters
                                    if ($boolResult) {
                                        # Converted to bigint but not int32 or
                                        # int64
                                        $bigintRemainder = $bigint - [int32]::MaxValue
                                        $strAttemptedVersionNew = $strAttemptedVersion + '.' + [int32]::MaxValue
                                        $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersionNew
                                        if ($boolResult) {
                                            # Conversion successful
                                            $strExcessCharactersInThisElement = ($arrVersionElements[$intElementInQuestion]).Substring($strFirstNumericalCharacters.Length)
                                            ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = ([string]$bigintRemainder) + $strExcessCharactersInThisElement
                                            for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                                ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                            }
                                            $boolConversionSuccessful = $true
                                            $intReturnValue = $intElementInQuestion + 1
                                            ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                                        } else {
                                            # Conversion was not successful even though
                                            # we just tried converting using numbers we
                                            # know are convertable to an int32. This
                                            # makes no sense. Throw warning:
                                            $strMessage = 'Conversion of string "' + $strAttemptedVersionNew + '" to a version object failed even though "' + $strAttemptedVersion + '" converted to a version object just fine, and we know that "' + ([string]([int32]::MaxValue)) + '" is a valid int32 number. This should not be possible!'
                                            Write-Warning -Message $strMessage
                                        }
                                    } else {
                                        # Conversion to bigint failed; given that we
                                        # know that the string is all numbers, this
                                        # should not be possible. Throw warning
                                        $strMessage = 'The string "' + $strFirstNumericalCharacters + '" could not be converted to an int32, int64, or bigint number. This should not be possible!'
                                        Write-Warning -Message $strMessage
                                    }
                                } else {
                                    # Use double
                                    $double = $null
                                    $boolResult = Convert-StringToDoubleSafely -ReferenceToDouble ([ref]$double) -StringToConvert $strFirstNumericalCharacters
                                    if ($boolResult) {
                                        # Converted to double but not int32 or
                                        # int64
                                        $doubleRemainder = $double - [int32]::MaxValue
                                        $strAttemptedVersionNew = $strAttemptedVersion + '.' + [int32]::MaxValue
                                        $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersionNew
                                        if ($boolResult) {
                                            # Conversion successful
                                            $strExcessCharactersInThisElement = ($arrVersionElements[$intElementInQuestion]).Substring($strFirstNumericalCharacters.Length)
                                            ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = ([string]$doubleRemainder) + $strExcessCharactersInThisElement
                                            for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                                ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                            }
                                            $boolConversionSuccessful = $true
                                            $intReturnValue = $intElementInQuestion + 1
                                            ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                                        } else {
                                            # Conversion was not successful even though
                                            # we just tried converting using numbers we
                                            # know are convertable to an int32. This
                                            # makes no sense. Throw warning:
                                            $strMessage = 'Conversion of string "' + $strAttemptedVersionNew + '" to a version object failed even though "' + $strAttemptedVersion + '" converted to a version object just fine, and we know that "' + ([string]([int32]::MaxValue)) + '" is a valid int32 number. This should not be possible!'
                                            Write-Warning -Message $strMessage
                                        }
                                    } else {
                                        # Conversion to double failed; given that we
                                        # know that the string is all numbers, this
                                        # should not be possible unless the string of
                                        # numbers exceeded the maximum size allowed
                                        # for a double. This is possible, so don't
                                        # throw a warning.
                                        # Treat like no numerical characters found
                                        ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = $arrVersionElements[$intElementInQuestion]
                                        for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                            ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                        }
                                        $boolConversionSuccessful = $true
                                        $intReturnValue = $intElementInQuestion + 1
                                        ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                                    }
                                }
                            }
                        }
                    }
                }
                $intElementInQuestion--
            }

            if (-not $boolConversionSuccessful) {
                # Conversion was not successful
                return -1
            } else {
                return $intReturnValue
            }
        }

        if ([string]::IsNullOrEmpty($PathToCommandPrompt)) {
            # No path to command prompt specified
            $strCommandPromptPath = ''
            $boolSuccess = Get-CommandPromptPath -ReferenceToCommandPromptPath ([ref]$strCommandPromptPath)
            if (-not $boolSuccess) {
                # Failed to get path to command prompt
                return -1
            }
            $refCommandPromptPath = [ref]$strCommandPromptPath
        } else {
            # Path to command prompt specified
            $refCommandPromptPath = [ref]$PathToCommandPrompt
        }

        if (-not (Test-Path -Path $refCommandPromptPath.Value)) {
            # Path to command prompt does not exist
            return -2
        }

        $strCommand = $refCommandPromptPath.Value + ' /c ver 2>&1'
        # Capture cmd /c ver output:
        $result = & ([ScriptBlock]::Create($strCommand))

        # Check for command execution success:
        if ($LASTEXITCODE -ne 0) {
            exit -3
        }

        # Ensure $result is a single string:
        if ($result -is [array]) {
            $result = [String]::Join(' ', $result)
        }

        if ([string]::IsNullOrEmpty($result)) {
            # No output from cmd /c ver command
            return -4
        }

        # Parse the version number
        $strVersion = [regex]::Match($result, '\d+\.\d+\.\d+(\.\d+)?').Value

        if ([string]::IsNullOrEmpty($strVersion)) {
            # No version number found in cmd /c ver output
            return -5
        }

        # Validate the result further
        if ($strVersion -and $strVersion -match '^\d+\.\d+\.\d+(\.\d+)?$') {
            $ReferenceToStringVersion.Value = $strVersion
        } else {
            # Invalid version number format
            return -6
        }

        $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject $ReferenceToSystemVersion -ReferenceArrayOfLeftoverStrings $ReferenceToArrayOfLeftoverStrings -StringToConvert $ReferenceToStringVersion.Value
        if ($intReturnCode -lt 0) {
            # Conversion failed; return failure indicator
            return -7
        }
        return $intReturnCode
    }

    function Get-WindowsKernelVersion {
        # .SYNOPSIS
        # Gets the version of the Windows kernel.
        #
        # .DESCRIPTION
        # This function retrieves the version of the Windows kernel by reading the
        # "product version" from C:\Windows\System32\ntoskrnl.exe (or an equivalent
        # path). The function attempts a conversion of the kernel version from string
        # to .NET version (System.Version) object. If the conversion is successful, the
        # function returns the version as a System.Version object.
        #
        # .PARAMETER ReferenceToSystemVersion
        # This parameter is required; it is a reference to a System.Version object that
        # will be modified to contain the version of the Windows kernel. If the
        # conversion from string to System.Version object is successful, the version
        # object will be stored in this reference. If the conversion is not
        # successful, a warning will be returned and the referenced object will be
        # unmodified.
        #
        # .PARAMETER ReferenceToStringVersion
        # This parameter is required; it is a reference to a string that will be
        # modified to contain the version of the Windows kernel.
        #
        # .PARAMETER ReferenceToArrayOfLeftoverStrings
        # This parameter is required; it is a reference to an array of five
        # elements. Each element is a string; One or more of the elements may be
        # modified if the string could not be converted to a version object. If the
        # string could not be converted to a version object, any portions of the
        # string that exceed the major, minor, build, and revision version portions
        # will be stored in the elements of the array.
        #
        # The first element of the array will be modified if the major version
        # portion of the string could not be converted to a version object. If the
        # major version portion of the string could not be converted to a version
        # object, the left-most numerical-only portion of the major version will be
        # used to generate the version object. The remaining portion of the major
        # version will be stored in the first element of the array.
        #
        # The second element of the array will be modified if the minor version
        # portion of the string could not be converted to a version object. If the
        # minor version portion of the string could not be converted to a version
        # object, the left-most numerical-only portion of the minor version will be
        # used to generate the version object. The remaining portion of the minor
        # version will be stored in second element of the array.
        #
        # If the major version portion of the string could not be converted to a
        # version object, the entire minor version portion of the string will be
        # stored in the second element, and no portion of the supplied minor
        # version reference will be used to generate the version object.
        #
        # The third element of the array will be modified if the build version
        # portion of the string could not be converted to a version object. If the
        # build version portion of the string could not be converted to a version
        # object, the left-most numerical-only portion of the build version will be
        # used to generate the version object. The remaining portion of the build
        # version will be stored in the third element of the array.
        #
        # If the major or minor version portions of the string could not be
        # converted to a version object, the entire build version portion of the
        # string will be stored in the third element, and no portion of the
        # supplied build version reference will be used to generate the version
        # object.
        #
        # The fourth element of the array will be modified if the revision version
        # portion of the string could not be converted to a version object. If the
        # revision version portion of the string could not be converted to a
        # version object, the left-most numerical-only portion of the revision
        # version will be used to generate the version object. The remaining
        # portion of the revision version will be stored in the fourth element of
        # the array.
        #
        # If the major, minor, or build version portions of the string could not be
        # converted to a version object, the entire revision version portion of the
        # string will be stored in the fourth element, and no portion of the
        # supplied revision version reference will be used to generate the version
        # object.
        #
        # The fifth element of the array will be modified if the string could not
        # be converted to a version object. If the string could not be converted to
        # a version object, any portions of the string that exceed the major,
        # minor, build, and revision version portions will be stored in the string
        # reference.
        #
        # For example, if the string is '1.2.3.4.5', the fifth element in the array
        # will be '5'. If the string is '1.2.3.4.5.6', the fifth element of the
        # array will be '5.6'.
        #
        # .PARAMETER OSNativeSystemPath
        # This parameter is optional; if supplied, it is a string representing the
        # path to the OS processor architecture-native System32 folder path (e.g,
        # C:\Windows\System32 or C:\Windows\Sysnative). It is used to determine the
        # path to the Windows kernel. If not supplied, this function will automatically
        # attempt to retrieve the OS native System32 folder path.
        #
        # .PARAMETER OSProcessorArchitecture
        # This parameter is optional; if supplied, it is a string representing the
        # Windows operating system processor architecture. It is used to determine the
        # "bit width" of the operating system. If not supplied, this function will
        # automatically attempt to retrieve the OS processor architecture.
        #
        # .PARAMETER ProcessProcessorArchitecture
        # This parameter is optional; if supplied, it is a string representing the
        # current process's processor architecture. It is used to determine the "bit
        # width" of the code for the running process. If not supplied, this function
        # will automatically attempt to retrieve the process processor architecture.
        #
        # .EXAMPLE
        # $strOSNativeSystemPath = 'C:\Windows\System32' # Example; don't do this IRL!
        # $versionWindowsKernel = [version]'0.0'
        # $strWindowsKernelVersion = ''
        # $arrLeftoverStrings = @('', '', '', '', '')
        # $intReturnCode = Get-WindowsKernelVersion -ReferenceToSystemVersion ([ref]$versionWindowsKernel) -ReferenceToStringVersion ([ref]$strWindowsKernelVersion) -ReferenceToArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -OSNativeSystemPath $strOSNativeSystemPath
        #
        # .EXAMPLE
        # $strRegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
        # $strValueName = 'PROCESSOR_ARCHITECTURE'
        # $strOSArchitecture = (Get-ItemProperty -Path $strRegistryPath -Name $strValueName).$strValueName
        # $strProcessArchitecture = $env:PROCESSOR_ARCHITECTURE
        # $versionWindowsKernel = [version]'0.0'
        # $strWindowsKernelVersion = ''
        # $arrLeftoverStrings = @('', '', '', '', '')
        # $intReturnCode = Get-WindowsKernelVersion -ReferenceToSystemVersion ([ref]$versionWindowsKernel) -ReferenceToStringVersion ([ref]$strWindowsKernelVersion) -ReferenceToArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -OSProcessorArchitecture $strOSArchitecture -ProcessProcessorArchitecture $strProcessArchitecture
        #
        # .EXAMPLE
        # $versionWindowsKernel = [version]'0.0'
        # $strWindowsKernelVersion = ''
        # $arrLeftoverStrings = @('', '', '', '', '')
        # $intReturnCode = Get-WindowsKernelVersion -ReferenceToSystemVersion ([ref]$versionWindowsKernel) -ReferenceToStringVersion ([ref]$strWindowsKernelVersion) -ReferenceToArrayOfLeftoverStrings ([ref]$arrLeftoverStrings)
        #
        # .INPUTS
        # None. You can't pipe objects to Get-WindowsKernelVersion.
        #
        # .OUTPUTS
        # System.Int32. Get-WindowsKernelVersion returns an integer value indiciating
        # whether the process completed successfully. 0 means the process completed
        # successfully, a negative value indicates that an error occurred, and a
        # positive value indicates that the process completed but there was one or more
        # warnings.
        #
        # .NOTES
        # Version: 1.0.20250406.0

        #region License ############################################################
        # Copyright (c) 2025 Frank Lesniak
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
            [ref]$ReferenceToSystemVersion = ([ref]$null),
            [ref]$ReferenceToStringVersion = ([ref]$null),
            [ref]$ReferenceToArrayOfLeftoverStrings = ([ref]$null),
            [string]$OSNativeSystemPath = '',
            [string]$OSProcessorArchitecture = '',
            [string]$ProcessProcessorArchitecture = ''
        )

        #region FunctionsToSupportErrorHandling ####################################
        function Get-ReferenceToLastError {
            # .SYNOPSIS
            # Gets a reference (memory pointer) to the last error that
            # occurred.
            #
            # .DESCRIPTION
            # Returns a reference (memory pointer) to $null ([ref]$null) if no
            # errors on on the $error stack; otherwise, returns a reference to
            # the last error that occurred.
            #
            # .EXAMPLE
            # # Intentionally empty trap statement to prevent terminating
            # # errors from halting processing
            # trap { }
            #
            # # Retrieve the newest error on the stack prior to doing work:
            # $refLastKnownError = Get-ReferenceToLastError
            #
            # # Store current error preference; we will restore it after we do
            # # some work:
            # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
            #
            # # Set ErrorActionPreference to SilentlyContinue; this will
            # # suppress error output. Terminating errors will not output
            # # anything, kick to the empty trap statement and then continue
            # # on. Likewise, non- terminating errors will also not output
            # # anything, but they do not kick to the trap statement; they
            # # simply continue on.
            # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            #
            # # Do something that might trigger an error
            # Get-Item -Path 'C:\MayNotExist.txt'
            #
            # # Restore the former error preference
            # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
            #
            # # Retrieve the newest error on the error stack
            # $refNewestCurrentError = Get-ReferenceToLastError
            #
            # $boolErrorOccurred = $false
            # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
            #     # Both not $null
            #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
            #         $boolErrorOccurred = $true
            #     }
            # } else {
            #     # One is $null, or both are $null
            #     # NOTE: $refLastKnownError could be non-null, while
            #     # $refNewestCurrentError could be null if $error was cleared;
            #     # this does not indicate an error.
            #     #
            #     # So:
            #     # If both are null, no error.
            #     # If $refLastKnownError is null and $refNewestCurrentError is
            #     # non-null, error.
            #     # If $refLastKnownError is non-null and
            #     # $refNewestCurrentError is null, no error.
            #     #
            #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
            #         $boolErrorOccurred = $true
            #     }
            # }
            #
            # .INPUTS
            # None. You can't pipe objects to Get-ReferenceToLastError.
            #
            # .OUTPUTS
            # System.Management.Automation.PSReference ([ref]).
            # Get-ReferenceToLastError returns a reference (memory pointer) to
            # the last error that occurred. It returns a reference to $null
            # ([ref]$null) if there are no errors on on the $error stack.
            #
            # .NOTES
            # Version: 2.0.20250215.1

            #region License ################################################
            # Copyright (c) 2025 Frank Lesniak
            #
            # Permission is hereby granted, free of charge, to any person
            # obtaining a copy of this software and associated documentation
            # files (the "Software"), to deal in the Software without
            # restriction, including without limitation the rights to use,
            # copy, modify, merge, publish, distribute, sublicense, and/or sell
            # copies of the Software, and to permit persons to whom the
            # Software is furnished to do so, subject to the following
            # conditions:
            #
            # The above copyright notice and this permission notice shall be
            # included in all copies or substantial portions of the Software.
            #
            # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
            # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
            # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
            # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
            # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
            # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
            # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
            # OTHER DEALINGS IN THE SOFTWARE.
            #endregion License ################################################

            if ($Error.Count -gt 0) {
                return ([ref]($Error[0]))
            } else {
                return ([ref]$null)
            }
        }

        function Test-ErrorOccurred {
            # .SYNOPSIS
            # Checks to see if an error occurred during a time period, i.e.,
            # during the execution of a command.
            #
            # .DESCRIPTION
            # Using two references (memory pointers) to errors, this function
            # checks to see if an error occurred based on differences between
            # the two errors.
            #
            # To use this function, you must first retrieve a reference to the
            # last error that occurred prior to the command you are about to
            # run. Then, run the command. After the command completes, retrieve
            # a reference to the last error that occurred. Pass these two
            # references to this function to determine if an error occurred.
            #
            # .PARAMETER ReferenceToEarlierError
            # This parameter is required; it is a reference (memory pointer) to
            # a System.Management.Automation.ErrorRecord that represents the
            # newest error on the stack earlier in time, i.e., prior to running
            # the command for which you wish to determine whether an error
            # occurred.
            #
            # If no error was on the stack at this time,
            # ReferenceToEarlierError must be a reference to $null
            # ([ref]$null).
            #
            # .PARAMETER ReferenceToLaterError
            # This parameter is required; it is a reference (memory pointer) to
            # a System.Management.Automation.ErrorRecord that represents the
            # newest error on the stack later in time, i.e., after to running
            # the command for which you wish to determine whether an error
            # occurred.
            #
            # If no error was on the stack at this time, ReferenceToLaterError
            # must be a reference to $null ([ref]$null).
            #
            # .EXAMPLE
            # # Intentionally empty trap statement to prevent terminating
            # # errors from halting processing
            # trap { }
            #
            # # Retrieve the newest error on the stack prior to doing work
            # if ($Error.Count -gt 0) {
            #     $refLastKnownError = ([ref]($Error[0]))
            # } else {
            #     $refLastKnownError = ([ref]$null)
            # }
            #
            # # Store current error preference; we will restore it after we do
            # # some work:
            # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
            #
            # # Set ErrorActionPreference to SilentlyContinue; this will
            # # suppress error output. Terminating errors will not output
            # # anything, kick to the empty trap statement and then continue
            # # on. Likewise, non- terminating errors will also not output
            # # anything, but they do not kick to the trap statement; they
            # # simply continue on.
            # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
            #
            # # Do something that might trigger an error
            # Get-Item -Path 'C:\MayNotExist.txt'
            #
            # # Restore the former error preference
            # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
            #
            # # Retrieve the newest error on the error stack
            # if ($Error.Count -gt 0) {
            #     $refNewestCurrentError = ([ref]($Error[0]))
            # } else {
            #     $refNewestCurrentError = ([ref]$null)
            # }
            #
            # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
            #     # Error occurred
            # } else {
            #     # No error occurred
            # }
            #
            # .INPUTS
            # None. You can't pipe objects to Test-ErrorOccurred.
            #
            # .OUTPUTS
            # System.Boolean. Test-ErrorOccurred returns a boolean value
            # indicating whether an error occurred during the time period in
            # question. $true indicates an error occurred; $false indicates no
            # error occurred.
            #
            # .NOTES
            # This function also supports the use of positional parameters
            # instead of named parameters. If positional parameters are used
            # instead of named parameters, then two positional parameters are
            # required:
            #
            # The first positional parameter is a reference (memory pointer) to
            # a System.Management.Automation.ErrorRecord that represents the
            # newest error on the stack earlier in time, i.e., prior to running
            # the command for which you wish to determine whether an error
            # occurred. If no error was on the stack at this time, the first
            # positional parameter must be a reference to $null ([ref]$null).
            #
            # The second positional parameter is a reference (memory pointer)
            # to a System.Management.Automation.ErrorRecord that represents the
            # newest error on the stack later in time, i.e., after to running
            # the command for which you wish to determine whether an error
            # occurred. If no error was on the stack at this time,
            # ReferenceToLaterError must be a reference to $null ([ref]$null).
            #
            # Version: 2.0.20250215.0

            #region License ################################################
            # Copyright (c) 2025 Frank Lesniak
            #
            # Permission is hereby granted, free of charge, to any person
            # obtaining a copy of this software and associated documentation
            # files (the "Software"), to deal in the Software without
            # restriction, including without limitation the rights to use,
            # copy, modify, merge, publish, distribute, sublicense, and/or sell
            # copies of the Software, and to permit persons to whom the
            # Software is furnished to do so, subject to the following
            # conditions:
            #
            # The above copyright notice and this permission notice shall be
            # included in all copies or substantial portions of the Software.
            #
            # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
            # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
            # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
            # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
            # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
            # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
            # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
            # OTHER DEALINGS IN THE SOFTWARE.
            #endregion License ################################################
            param (
                [ref]$ReferenceToEarlierError = ([ref]$null),
                [ref]$ReferenceToLaterError = ([ref]$null)
            )

            # TODO: Validate input

            $boolErrorOccurred = $false
            if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                # Both not $null
                if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                    $boolErrorOccurred = $true
                }
            } else {
                # One is $null, or both are $null
                # NOTE: $ReferenceToEarlierError could be non-null, while
                # $ReferenceToLaterError could be null if $error was cleared;
                # this does not indicate an error.
                # So:
                # - If both are null, no error.
                # - If $ReferenceToEarlierError is null and
                #   $ReferenceToLaterError is non-null, error.
                # - If $ReferenceToEarlierError is non-null and
                #   $ReferenceToLaterError is null, no error.
                if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                    $boolErrorOccurred = $true
                }
            }

            return $boolErrorOccurred
        }
        #endregion FunctionsToSupportErrorHandling ####################################

        function Get-WindowsNativeSystemPath {
            # .SYNOPSIS
            # On Windows, gets the OS-native, non-redirected system path (e.g.,
            # C:\Windows\System32 or C:\Windows\Sysnative)
            #
            # .DESCRIPTION
            # This function retrieves the OS-native, non-redirected system path (e.g.,
            # C:\Windows\System32 or C:\Windows\Sysnative) on Windows. It does this by
            # determining if the running process is a 32-bit or 64-bit process, then
            # comparing that to the operating system architecture. If the "bit width"
            # of the operating system and the process are the same, it returns the
            # equivalent of 'C:\Windows\System32'. If the "bit width" of the operating
            # system is 64 but the process is 32, it returns the equivalent of
            # 'C:\Windows\Sysnative', assuming 'C:\Windows\Sysnative' exists.
            #
            # .PARAMETER ReferenceToSystemPath
            # This parameter is required; it is a reference to a string object that
            # will be used to store the OS-native, non-redirected system path.
            #
            # .PARAMETER OSProcessorArchitecture
            # This parameter is optional; if supplied, it is a string representing the
            # Windows operating system processor architecture. It is used to determine
            # the "bit width" of the operating system. If not supplied, this function
            # will automatically attempt to retrieve the OS processor architecture.
            #
            # .PARAMETER ProcessProcessorArchitecture
            # This parameter is optional; if supplied, it is a string representing the
            # current process's processor architecture. It is used to determine the
            # "bit width" of the code for the running process. If not supplied, this
            # function will automatically attempt to retrieve the process processor
            # architecture.
            #
            # .EXAMPLE
            # $strRegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
            # $strValueName = 'PROCESSOR_ARCHITECTURE'
            # $strOSArchitecture = (Get-ItemProperty -Path $strRegistryPath -Name $strValueName).$strValueName
            # $strProcessArchitecture = $env:PROCESSOR_ARCHITECTURE
            # $strNativeSystemPath = ''
            # $intReturnCode = Get-WindowsNativeSystemPath -ReferenceToSystemPath ([ref]$strNativeSystemPath) -OSProcessorArchitecture $strOSArchitecture -ProcessProcessorArchitecture $strProcessArchitecture
            #
            # .EXAMPLE
            # $strNativeSystemPath = ''
            # $intReturnCode = Get-WindowsNativeSystemPath -ReferenceToSystemPath ([ref]$strNativeSystemPath)
            #
            # .EXAMPLE
            # $strNativeSystemPath = ''
            # $intReturnCode = Get-WindowsNativeSystemPath ([ref]$strNativeSystemPath)
            #
            # .INPUTS
            # None. You can't pipe objects to Get-WindowsNativeSystemPath.
            #
            # .OUTPUTS
            # System.Int32. Get-WindowsNativeSystemPath returns an integer value
            # indiciating whether the process completed successfully. 0 means the
            # process completed successfully; any other value means that an error
            # occurred.
            #
            # .NOTES
            # Note: on Windows XP and Windows Server 2003, it is possible that the
            # "Sysnative" folder does not exist (this functionality was added to
            # Windows XP and Windows Server 2003 via a hotfix--KB942589). If the
            # "Sysnative" folder does not exist and PowerShell is running as a 32-bit
            # process on 64-bit Windows this function will return an error code. The
            # user will either need to relaunch PowerShell as a system-native process,
            # install KB942589, or upgrade their operating system.
            #
            # This function also supports the use of positional parameters instead of
            # named parameters. If positional parameters are used instead of named
            # parameters, then 1-3 positional parameters are required:
            #
            # The first positional parameter is a reference to a string object that
            # will be used to store the OS-native, non-redirected system path.
            #
            # If supplied, the second positional parameter is a string representing the
            # Windows operating system processor architecture. It is used to determine
            # the "bit width" of the operating system. If not supplied, this function
            # will automatically attempt to retrieve the OS processor architecture.
            #
            # If supplied, the third positional parameter is a string representing the
            # current process's processor architecture. It is used to determine the
            # "bit width" of the code for the running process. If not supplied, this
            # function will automatically attempt to retrieve the process processor
            # architecture.
            #
            # Version: 1.0.20250406.1

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
                [ref]$ReferenceToSystemPath = ([ref]$null),
                [string]$OSProcessorArchitecture = '',
                [string]$ProcessProcessorArchitecture = ''
            )

            function Get-WindowsOSProcessorArchitecture {
                # .SYNOPSIS
                # Determines the processor architecture (instruction set) of the
                # operating system.
                #
                # .DESCRIPTION
                # This function determines the processor architecture (instruction set)
                # of the operating system. It reads this value from the registry and
                # returns it via a referenced string object. The processor architecture
                # is the instruction set that the operating system is using to run. On
                # Windows versions that support PowerShell, known values are:
                #
                # - x86 (i.e., 32-bit x86)
                # - AMD64 (i.e., x86-64 or 64-bit x86)
                # - ARM (i.e., 32-bit ARM)
                # - ARM64 (i.e., 64-bit ARM)
                # - IA64 (i.e., Itanium)
                #
                # .PARAMETER ReferenceToOSProcessorArchitecture
                # This parameter is required; it is a reference to a string that will
                # be used to store output if the function completes successfully. The
                # string will be set to the processor architecture (instruction set) of
                # the operating system.
                #
                # .EXAMPLE
                # $strOSProcessorArchitecture = ''
                # $boolSuccess = Get-WindowsOSProcessorArchitecture -ReferenceToOSProcessorArchitecture ([ref]$strOSProcessorArchitecture)
                #
                # .EXAMPLE
                # $strOSProcessorArchitecture = ''
                # $boolSuccess = Get-WindowsOSProcessorArchitecture ([ref]$strOSProcessorArchitecture)
                #
                # .INPUTS
                # None. You can't pipe objects to Get-WindowsOSProcessorArchitecture.
                #
                # .OUTPUTS
                # System.Boolean. Get-WindowsOSProcessorArchitecture returns a boolean
                # value indiciating whether the operating system processor architecture
                # was retrieved successfully. $true means the operating system
                # processor architecture was determined successfully; $false means
                # there was an error.
                #
                # .NOTES
                # This function also supports the use of a positional parameter instead
                # of a named parameter. If a positional parameter is used instead of a
                # named parameter, then exactly one positional parameter is required: a
                # reference to a string that will be used to store output if the
                # function completes successfully. The string will be set to the
                # processor architecture (instruction set) of the operating system.
                #
                # Version: 1.0.20250406.1

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

                #region Acknowledgements ###########################################
                # Microsoft, for providing a current reference on the SYSTEM_INFO
                # struct, used by the GetSystemInfo Win32 function. This reference does
                # not show the exact text of the PROCESSOR_ARCHITECTURE environment
                # variable, but shows the universe of what's possible on a core system
                # API:
                # https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info#members
                #
                # Microsoft, for including in the MSDN Library Jan 2003 information on
                # this same SYSTEM_INFO struct that pre-dates Windows 2000 and
                # enumerates additional processor architectures (MIPS, ALPHA, PowerPC,
                # IA32_ON_WIN64). The MSDN Library Jan 2003 also lists SHX and ARM,
                # explains nuiances in accessing environment variables on pre-Windows
                # 2000 operating systems (namely that VBScript in Windows 9x can only
                # access per-process environment variables), and that the
                # PROCESSOR_ARCHITECTURE system environment variable is not available
                # on Windows 98/ME.
                # (link unavailable, check Internet Archive for source)
                #
                # "guga" for the first post in this thread that tipped me off to the
                # SYSTEM_INFO struct and additional architectures:
                # http://masm32.com/board/index.php?topic=3401.0
                #endregion Acknowledgements ###########################################

                param (
                    [ref]$ReferenceToOSProcessorArchitecture = ([ref]$null)
                )

                function Test-RegistryValue {
                    # .SYNOPSIS
                    # Tests to determine whether a registry value exists in the Windows
                    # registry.
                    #
                    # .DESCRIPTION
                    # This function tests to determine whether a registry value exists
                    # in the Windows registry. It returns a boolean value indicating
                    # whether the registry value exists. $true indicates the registry
                    # value exists; $false indicates the registry value does not exist.
                    #
                    # .PARAMETER RefPathToRegistryKey
                    # Either this parameter or PathToRegistryKey are required; if
                    # RefPathToRegistryKey is specified, it is a reference to a string
                    # that contains the path to the registry key. If this parameter is
                    # not specified, then PathToRegistryKey must be specified. If both
                    # are specified, then RefPathToRegistryKey takes precedence over
                    # PathToRegistryKey.
                    #
                    # .PARAMETER PathToRegistryKey
                    # Either this parameter or RefPathToRegistryKey are required; if
                    # PathToRegistryKey is specified, it is a string that contains the
                    # path to the registry key. If this parameter is not specified,
                    # then RefPathToRegistryKey must be specified. If both are
                    # specified, then RefPathToRegistryKey takes precedence over
                    # PathToRegistryKey.
                    #
                    # .PARAMETER RefNameOfRegistryValue
                    # Either this parameter or NameOfRegistryValue are required; if
                    # RefNameOfRegistryValue is specified, it is a reference to a
                    # string that contains the name of the registry value to be tested.
                    # If this parameter is not specified, then NameOfRegistryValue must
                    # be specified. If both are specified, then RefNameOfRegistryValue
                    # takes precedence over NameOfRegistryValue.
                    #
                    # .PARAMETER NameOfRegistryValue
                    # Either this parameter or RefNameOfRegistryValue are required; if
                    # NameOfRegistryValue is specified, it is a string that contains
                    # the name of the registry value to be tested. If this parameter is
                    # not specified, then RefNameOfRegistryValue must be specified. If
                    # both are specified, then RefNameOfRegistryValue takes precedence
                    # over NameOfRegistryValue.
                    #
                    # .EXAMPLE
                    # $strRegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
                    # $strRegistryValue = 'PROCESSOR_ARCHITECTURE'
                    # $boolRegistryValueExists = Test-RegistryValue -RefPathToRegistryKey ([ref]$strRegistryPath) -RefNameOfRegistryValue ([ref]$strRegistryValue)
                    #
                    # .EXAMPLE
                    # $strRegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
                    # $strRegistryValue = 'PROCESSOR_ARCHITECTURE'
                    # $boolRegistryValueExists = Test-RegistryValue -PathToRegistryKey $strRegistryPath -NameOfRegistryValue $strRegistryValue
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-RegistryValue.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-RegistryValue returns a boolean value
                    # indiciating whether the registry value exists. $true indicates
                    # the registry value exists; $false indicates the registry value
                    # does not exist, or that the specified registry key does not
                    # exist.
                    #
                    # .NOTES
                    # Oddly enough, it seems that passing string parameters by
                    # reference is not faster than passing them by value. I thought
                    # that passing by reference would be faster, but it seems that
                    # passing by value is faster. I don't know why this is the case,
                    # but it is.
                    #
                    # Version: 1.0.20250406.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    param (
                        [ref]$RefPathToRegistryKey = ([ref]$null),
                        [string]$PathToRegistryKey = '',
                        [ref]$RefNameOfRegistryValue = ([ref]$null),
                        [string]$NameOfRegistryValue = ''
                    )

                    if ([string]::IsNullOrEmpty($RefPathToRegistryKey.Value) -and [string]::IsNullOrEmpty($PathToRegistryKey)) {
                        Write-Error -Message 'Either RefPathToRegistryKey or PathToRegistryKey must be specified.'
                        return $false
                    }

                    # Specifying an empty string for the name of the registry value is
                    # valid; it would mean the "default" value of the registry key.
                    # However, if both RefNameOfRegistryValue and NameOfRegistryValue
                    # are empty, then we have a problem.
                    if (($null -eq $RefNameOfRegistryValue.Value) -and ($null -eq $NameOfRegistryValue)) {
                        Write-Error -Message 'Either RefNameOfRegistryValue or NameOfRegistryValue must be specified.'
                        return $false
                    }

                    if (-not [string]::IsNullOrEmpty($RefPathToRegistryKey.Value)) {
                        $refActualPathToRegistryKey = $RefPathToRegistryKey
                    } else {
                        $refActualPathToRegistryKey = [ref]$PathToRegistryKey
                    }
                    if (-not [string]::IsNullOrEmpty($RefNameOfRegistryValue.Value)) {
                        $refActualNameOfRegistryValue = $RefNameOfRegistryValue
                    } else {
                        $refActualNameOfRegistryValue = [ref]$NameOfRegistryValue
                    }

                    if (Test-Path -LiteralPath $refActualPathToRegistryKey.Value) {
                        $registryKey = Get-Item -LiteralPath $refActualPathToRegistryKey.Value
                        if ($null -ne $registryKey.GetValue($refActualNameOfRegistryValue.Value, $null)) {
                            return $true
                        } else {
                            return $false
                        }
                    } else {
                        return $false
                    }
                }

                $strRegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
                $strValueName = 'PROCESSOR_ARCHITECTURE'
                if (Test-RegistryValue -PathToRegistryKey $strRegistryPath -NameOfRegistryValue $strValueName) {
                    # The registry value exists; get the value and return it.
                    $ReferenceToOSProcessorArchitecture.Value = ((Get-ItemProperty -Path $strRegistryPath -Name $strValueName).PSObject.Properties |
                            Where-Object { $_.Name -eq $strValueName }).Value
                    return $true
                } else {
                    # The registry value does not exist; return an error.
                    return $false
                }
            }

            function Get-WindowsProcessProcessorArchitecture {
                # .SYNOPSIS
                # Gets the processor architecture of the current process, assuming the
                # current process is running on Windows.
                #
                # .DESCRIPTION
                # This function determines the processor architecture (instruction set)
                # of the current process, assuming it is running on Windows. It reads
                # this value from the environment variables and returns it via a
                # referenced string object. The processor architecture is the
                # instruction set that the process is using to run. On Windows versions
                # that support PowerShell, known values are:
                #
                # - x86 (i.e., 32-bit x86)
                # - AMD64 (i.e., x86-64 or 64-bit x86)
                # - ARM (i.e., 32-bit ARM)
                # - ARM64 (i.e., 64-bit ARM)
                # - IA64 (i.e., Itanium)
                #
                # .PARAMETER ReferenceToProcessProcessorArchitecture
                # This parameter is required; it is a reference to a string that will
                # be used to store output if the function completes successfully. The
                # string will be set to the processor architecture (instruction set) of
                # the currently running process.
                #
                # .EXAMPLE
                # $strProcessProcessorArchitecture = ''
                # $boolSuccess = Get-WindowsProcessProcessorArchitecture -ReferenceToProcessProcessorArchitecture ([ref]$strProcessProcessorArchitecture)
                #
                # .EXAMPLE
                # $strProcessProcessorArchitecture = ''
                # $boolSuccess = Get-WindowsProcessProcessorArchitecture ([ref]$strProcessProcessorArchitecture)
                #
                # .INPUTS
                # None. You can't pipe objects to
                # Get-WindowsProcessProcessorArchitecture.
                #
                # .OUTPUTS
                # System.Boolean. Get-WindowsProcessProcessorArchitecture returns a
                # boolean value indiciating whether the process processor architecture
                # was retrieved successfully. $true means the process processor
                # architecture was retrieved successfully; $false means there was an
                # error.
                #
                # .NOTES
                # This function also supports the use of a positional parameter instead
                # of a named parameter. If a positional parameter is used instead of a
                # named parameter, then exactly one positional parameter is required: a
                # reference to a string that will be used to store output if the
                # function completes successfully. The string will be set to the
                # processor architecture (instruction set) of the currently running
                # process.
                #
                # Version: 1.0.20250406.1

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

                #region Acknowledgements ###########################################
                # Microsoft, for providing a current reference on the SYSTEM_INFO
                # struct, used by the GetSystemInfo Win32 function. This reference does
                # not show the exact text of the PROCESSOR_ARCHITECTURE environment
                # variable, but shows the universe of what's possible on a core system
                # API:
                # https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info#members
                #
                # Microsoft, for including in the MSDN Library Jan 2003 information on
                # this same SYSTEM_INFO struct that pre-dates Windows 2000 and
                # enumerates additional processor architectures (MIPS, ALPHA, PowerPC,
                # IA32_ON_WIN64). The MSDN Library Jan 2003 also lists SHX and ARM,
                # explains nuiances in accessing environment variables on pre-Windows
                # 2000 operating systems (namely that VBScript in Windows 9x can only
                # access per-process environment variables), and that the
                # PROCESSOR_ARCHITECTURE system environment variable is not available
                # on Windows 98/ME.
                # (link unavailable, check Internet Archive for source)
                #
                # "guga" for the first post in this thread that tipped me off to the
                # SYSTEM_INFO struct and additional architectures:
                # http://masm32.com/board/index.php?topic=3401.0
                #endregion Acknowledgements ###########################################

                param (
                    [ref]$ReferenceToProcessProcessorArchitecture = ([ref]$null)
                )

                if ($null -ne $env:PROCESSOR_ARCHITECTURE) {
                    $ReferenceToProcessProcessorArchitecture.Value = $env:PROCESSOR_ARCHITECTURE
                    return $true
                } else {
                    return $false
                }
            }

            function Test-ProcessorArchitectureIs32Bit {
                # .SYNOPSIS
                # Tests a string that contains the processor architecture to determine
                # if it is 32-bit.
                #
                # .DESCRIPTION
                # This function tests a string that contains the processor architecture
                # to determine if it is 32-bit. It updates a reference to a boolean
                # that indicates whether the processor architecture is 32-bit. It
                # returns an integer indicating whether the process completed
                # successfully. 0 means the process completed successfully; any other
                # value means there was an error.
                #
                # .PARAMETER ReferenceToProcessorArchitectureIs32Bit
                # This parameter is required; it is a reference to a boolean that will
                # be used to store whether or not the processor architecture is 32-bit.
                # This parameter is passed by reference, so the value of the boolean
                # will be updated in the calling function. The value of this parameter
                # is set to $true if the processor architecture is 32-bit; otherwise,
                # it is set to $false.
                #
                # .PARAMETER ProcessorArchitecture
                # This parameter is required; it is a string representing the processor
                # architecture to be evaluated (e.g., "ARM64", "x86", "AMD64").
                #
                # .EXAMPLE
                # $bool32BitProcessorArchitecture = $false
                # $strProcessorArchitecture = $env:PROCESSOR_ARCHITECTURE
                # $intReturnCode = Test-ProcessorArchitectureIs32Bit -ReferenceToProcessorArchitectureIs32Bit ([ref]$bool32BitProcessorArchitecture) -ProcessorArchitecture $strProcessorArchitecture
                # if ($intReturnCode -eq 0) {
                #     if ($bool32BitProcessorArchitecture) {
                #         Write-Host "The processor architecture is 32-bit."
                #     } else {
                #         Write-Host "The processor architecture is not 32-bit."
                #     }
                # } else {
                #     Write-Host "An error occurred while testing the processor architecture."
                # }
                #
                # .EXAMPLE
                # $bool32BitProcessorArchitecture = $false
                # $strProcessorArchitecture = $env:PROCESSOR_ARCHITECTURE
                # $intReturnCode = Test-ProcessorArchitectureIs32Bit ([ref]$bool32BitProcessorArchitecture) $strProcessorArchitecture
                # if ($intReturnCode -eq 0) {
                #     if ($bool32BitProcessorArchitecture) {
                #         Write-Host "The processor architecture is 32-bit."
                #     } else {
                #         Write-Host "The processor architecture is not 32-bit."
                #     }
                # } else {
                #     Write-Host "An error occurred while testing the processor architecture."
                # }
                #
                # .INPUTS
                # None. You can't pipe objects to Test-ProcessorArchitectureIs32Bit.
                #
                # .OUTPUTS
                # System.Int32. Test-ProcessorArchitectureIs32Bit returns an integer
                # value indiciating whether the process completed successfully. 0 means
                # the processor architecture was evaluated successfully; any other
                # number indicates an error occurred.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a boolean that will
                # be used to store whether or not the processor architecture is 32-bit.
                # This parameter is passed by reference, so the value of the boolean
                # will be updated in the calling function. The value of this parameter
                # is set to $true if the processor architecture is 32-bit; otherwise,
                # it is set to $false.
                #
                # The second positional parameter is a string representing the
                # processor architecture to be evaluated (e.g., "ARM64", "x86",
                # "AMD64").
                #
                # Version: 1.0.20250406.1

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

                #region Acknowledgements ###########################################
                # Microsoft, for providing a current reference on the SYSTEM_INFO
                # struct, used by the GetSystemInfo Win32 function. This reference does
                # not show the exact text of the PROCESSOR_ARCHITECTURE environment
                # variable, but shows the universe of what's possible on a core system
                # API:
                # https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info#members
                #
                # Microsoft, for including in the MSDN Library Jan 2003 information on
                # this same SYSTEM_INFO struct that pre-dates Windows 2000 and
                # enumerates additional processor architectures (MIPS, ALPHA, PowerPC,
                # IA32_ON_WIN64). The MSDN Library Jan 2003 also lists SHX and ARM,
                # explains nuiances in accessing environment variables on pre-Windows
                # 2000 operating systems (namely that VBScript in Windows 9x can only
                # access per-process environment variables), and that the
                # PROCESSOR_ARCHITECTURE system environment variable is not available
                # on Windows 98/ME.
                # (link unavailable, check Internet Archive for source)
                #
                # "guga" for the first post in this thread that tipped me off to the
                # SYSTEM_INFO struct and additional architectures:
                # http://masm32.com/board/index.php?topic=3401.0
                #endregion Acknowledgements ###########################################

                param (
                    [ref]$ReferenceToProcessorArchitectureIs32Bit = ([ref]$null),
                    [string]$ProcessorArchitecture = ''
                )

                if ([string]::IsNullOrEmpty($ProcessorArchitecture)) {
                    return -1
                }

                switch ($ProcessorArchitecture.ToUpper()) {
                    'X86' {
                        $ReferenceToProcessorArchitectureIs32Bit.Value = $true
                        return 0
                    }
                    'AMD64' {
                        $ReferenceToProcessorArchitectureIs32Bit.Value = $false
                        return 0
                    }
                    'IA64' {
                        $ReferenceToProcessorArchitectureIs32Bit.Value = $false
                        return 0
                    }
                    'ARM' {
                        $ReferenceToProcessorArchitectureIs32Bit.Value = $true
                        return 0
                    }
                    'ARM64' {
                        $ReferenceToProcessorArchitectureIs32Bit.Value = $false
                        return 0
                    }
                    default {
                        return -2
                    }
                }
            }

            function Test-ProcessorArchitectureIs64Bit {
                # .SYNOPSIS
                # Tests a string that contains the processor architecture to determine
                # if it is 64-bit.
                #
                # .DESCRIPTION
                # This function tests a string that contains the processor architecture
                # to determine if it is 64-bit. It updates a reference to a boolean
                # that indicates whether the processor architecture is 64-bit. It
                # returns an integer indicating whether the process completed
                # successfully. 0 means the process completed successfully; any other
                # value means there was an error.
                #
                # .PARAMETER ReferenceToProcessorArchitectureIs64Bit
                # This parameter is required; it is a reference to a boolean that will
                # be used to store whether or not the processor architecture is 64-bit.
                # This parameter is passed by reference, so the value of the boolean
                # will be updated in the calling function. The value of this parameter
                # is set to $true if the processor architecture is 64-bit; otherwise,
                # it is set to $false.
                #
                # .PARAMETER ProcessorArchitecture
                # This parameter is required; it is a string representing the processor
                # architecture to be evaluated (e.g., "ARM64", "x86", "AMD64").
                #
                # .EXAMPLE
                # $bool64BitProcessorArchitecture = $false
                # $strProcessorArchitecture = $env:PROCESSOR_ARCHITECTURE
                # $intReturnCode = Test-ProcessorArchitectureIs64Bit -ReferenceToProcessorArchitectureIs64Bit ([ref]$bool64BitProcessorArchitecture) -ProcessorArchitecture $strProcessorArchitecture
                # if ($intReturnCode -eq 0) {
                #     if ($bool64BitProcessorArchitecture) {
                #         Write-Host "The processor architecture is 64-bit."
                #     } else {
                #         Write-Host "The processor architecture is not 64-bit."
                #     }
                # } else {
                #     Write-Host "An error occurred while testing the processor architecture."
                # }
                #
                # .EXAMPLE
                # $bool64BitProcessorArchitecture = $false
                # $strProcessorArchitecture = $env:PROCESSOR_ARCHITECTURE
                # $intReturnCode = Test-ProcessorArchitectureIs64Bit ([ref]$bool64BitProcessorArchitecture) $strProcessorArchitecture
                # if ($intReturnCode -eq 0) {
                #     if ($bool64BitProcessorArchitecture) {
                #         Write-Host "The processor architecture is 64-bit."
                #     } else {
                #         Write-Host "The processor architecture is not 64-bit."
                #     }
                # } else {
                #     Write-Host "An error occurred while testing the processor architecture."
                # }
                #
                # .INPUTS
                # None. You can't pipe objects to Test-ProcessorArchitectureIs64Bit.
                #
                # .OUTPUTS
                # System.Int32. Test-ProcessorArchitectureIs64Bit returns an integer
                # value indiciating whether the process completed successfully. 0 means
                # the processor architecture was evaluated successfully; any other
                # number indicates an error occurred.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a boolean that will
                # be used to store whether or not the processor architecture is 64-bit.
                # This parameter is passed by reference, so the value of the boolean
                # will be updated in the calling function. The value of this parameter
                # is set to $true if the processor architecture is 64-bit; otherwise,
                # it is set to $false.
                #
                # The second positional parameter is a string representing the
                # processor architecture to be evaluated (e.g., "ARM64", "x86",
                # "AMD64").
                #
                # Version: 1.0.20250406.1

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

                #region Acknowledgements ###########################################
                # Microsoft, for providing a current reference on the SYSTEM_INFO
                # struct, used by the GetSystemInfo Win32 function. This reference does
                # not show the exact text of the PROCESSOR_ARCHITECTURE environment
                # variable, but shows the universe of what's possible on a core system
                # API:
                # https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info#members
                #
                # Microsoft, for including in the MSDN Library Jan 2003 information on
                # this same SYSTEM_INFO struct that pre-dates Windows 2000 and
                # enumerates additional processor architectures (MIPS, ALPHA, PowerPC,
                # IA32_ON_WIN64). The MSDN Library Jan 2003 also lists SHX and ARM,
                # explains nuiances in accessing environment variables on pre-Windows
                # 2000 operating systems (namely that VBScript in Windows 9x can only
                # access per-process environment variables), and that the
                # PROCESSOR_ARCHITECTURE system environment variable is not available
                # on Windows 98/ME.
                # (link unavailable, check Internet Archive for source)
                #
                # "guga" for the first post in this thread that tipped me off to the
                # SYSTEM_INFO struct and additional architectures:
                # http://masm32.com/board/index.php?topic=3401.0
                #endregion Acknowledgements ###########################################

                param (
                    [ref]$ReferenceToProcessorArchitectureIs64Bit = ([ref]$null),
                    [string]$ProcessorArchitecture = ''
                )

                if ([string]::IsNullOrEmpty($ProcessorArchitecture)) {
                    return -1
                }

                switch ($ProcessorArchitecture.ToUpper()) {
                    'X86' {
                        $ReferenceToProcessorArchitectureIs64Bit.Value = $false
                        return 0
                    }
                    'AMD64' {
                        $ReferenceToProcessorArchitectureIs64Bit.Value = $true
                        return 0
                    }
                    'IA64' {
                        $ReferenceToProcessorArchitectureIs64Bit.Value = $true
                        return 0
                    }
                    'ARM' {
                        $ReferenceToProcessorArchitectureIs64Bit.Value = $false
                        return 0
                    }
                    'ARM64' {
                        $ReferenceToProcessorArchitectureIs64Bit.Value = $true
                        return 0
                    }
                    default {
                        return -2
                    }
                }
            }

            if ([string]::IsNullOrEmpty($OSProcessorArchitecture)) {
                $strOSProcessorArchitecture = ''
                $boolSuccess = Get-WindowsOSProcessorArchitecture -ReferenceToOSProcessorArchitecture ([ref]$strOSProcessorArchitecture)
                if (-not $boolSuccess) {
                    return -1
                }
                $refOSProcessorArchitecture = [ref]$strOSProcessorArchitecture
            } else {
                $refOSProcessorArchitecture = [ref]$OSProcessorArchitecture
            }

            if ([string]::IsNullOrEmpty($ProcessProcessorArchitecture)) {
                $strProcessProcessorArchitecture = ''
                $boolSuccess = Get-WindowsProcessProcessorArchitecture -ReferenceToProcessProcessorArchitecture ([ref]$strProcessProcessorArchitecture)
                if (-not $boolSuccess) {
                    return -2
                }
                $refProcessProcessorArchitecture = [ref]$strProcessProcessorArchitecture
            } else {
                $refProcessProcessorArchitecture = [ref]$ProcessProcessorArchitecture
            }

            #region Determine OS bit width #########################################
            $bool64BitOSProcessorArchitecture = $false
            $intReturnCode = Test-ProcessorArchitectureIs64Bit -ReferenceToProcessorArchitectureIs64Bit ([ref]$bool64BitOSProcessorArchitecture) -ProcessorArchitecture ($refOSProcessorArchitecture.Value)
            if ($intReturnCode -ne 0) {
                return -3
            }

            $bool32BitOSProcessorArchitecture = $false
            if (-not $bool64BitOSProcessorArchitecture) {
                $intReturnCode = Test-ProcessorArchitectureIs32Bit -ReferenceToProcessorArchitectureIs32Bit ([ref]$bool32BitOSProcessorArchitecture) -ProcessorArchitecture ($refOSProcessorArchitecture.Value)
                if ($intReturnCode -ne 0) {
                    return -4
                }
            }

            if ((-not $bool64BitOSProcessorArchitecture) -and (-not $bool32BitOSProcessorArchitecture)) {
                # OS is both not 32-bit and not 64-bit--wut?
                return -5
            }
            #endregion Determine OS bit width #########################################

            #region Determine process bit width ####################################
            $bool64BitProcessProcessorArchitecture = $false
            $intReturnCode = Test-ProcessorArchitectureIs64Bit -ReferenceToProcessorArchitectureIs64Bit ([ref]$bool64BitProcessProcessorArchitecture) -ProcessorArchitecture ($refProcessProcessorArchitecture.Value)
            if ($intReturnCode -ne 0) {
                return -6
            }

            $bool32BitProcessProcessorArchitecture = $false
            if (-not $bool64BitProcessProcessorArchitecture) {
                $intReturnCode = Test-ProcessorArchitectureIs32Bit -ReferenceToProcessorArchitectureIs32Bit ([ref]$bool32BitProcessProcessorArchitecture) -ProcessorArchitecture ($refProcessProcessorArchitecture.Value)
                if ($intReturnCode -ne 0) {
                    return -7
                }
            }

            if ((-not $bool64BitProcessProcessorArchitecture) -and (-not $bool32BitProcessProcessorArchitecture)) {
                # Process is both not 32-bit and not 64-bit--wut?
                return -8
            }
            #endregion Determine process bit width ####################################

            if ($bool64BitOSProcessorArchitecture -and $bool32BitProcessProcessorArchitecture) {
                # 32-bit process on 64-bit OS
                # Need to get and return sysnative folder
                if (-not [string]::IsNullOrEmpty($env:SystemRoot)) {
                    $strWindowsPath = $env:SystemRoot
                } elseif (-not [string]::IsNullOrEmpty($env:windir)) {
                    $strWindowsPath = $env:windir
                } elseif (-not [string]::IsNullOrEmpty([System.Environment]::GetFolderPath('Windows'))) {
                    $strWindowsPath = [System.Environment]::GetFolderPath('Windows')
                } else {
                    return -9
                }

                $strSysnativePath = Join-Path -Path $strWindowsPath -ChildPath 'Sysnative'
                if (-not (Test-Path -LiteralPath $strSysnativePath)) {
                    # The C:\Windows\Sysnative path did not exist. This could happen on
                    # Windows XP or Windows Server 2003 systems that are missing
                    # KB942615
                    return -10
                }

                $ReferenceToSystemPath.Value = $strSysnativePath
                return 0
            } else {
                # Either 32-bit process on 32-bit OS, or 64-bit process on 64-bit OS
                # Need to get and return the system32 folder

                if (-not [string]::IsNullOrEmpty([System.Environment]::SystemDirectory)) {
                    $strWindowsSystemPath = [System.Environment]::SystemDirectory
                } elseif (-not [string]::IsNullOrEmpty($env:windir)) {
                    $strWindowsSystemPath = Join-Path -Path $env:windir -ChildPath 'System32'
                } elseif (-not [string]::IsNullOrEmpty($env:SystemRoot)) {
                    $strWindowsSystemPath = Join-Path -Path $env:SystemRoot -ChildPath 'System32'
                } else {
                    return -11
                }

                if (-not (Test-Path -LiteralPath $strWindowsSystemPath)) {
                    # The C:\Windows\System32 path did not exist.
                    return -12
                }

                $ReferenceToSystemPath.Value = [System.Environment]::SystemDirectory
                return 0
            }
        }

        function Convert-StringToFlexibleVersion {
            # .SYNOPSIS
            # Converts a string to a version object. However, when the string contains
            # characters not allowed in a version object, this function will attempt to
            # convert the string to a version object by removing the characters that
            # are not allowed, identifying the portions of the version object that are
            # not allowed, which can be evaluated further if needed.
            #
            # .DESCRIPTION
            # First attempts to convert a string to a version object. If the string
            # contains characters not allowed in a version object, this function will
            # iteratively attempt to convert the string to a version object by removing
            # period-separated substrings, working right to left, until the version is
            # successfully converted. Then, for the portions that could not be
            # converted, the function will select the numerical-only portions of the
            # problematic substrings and use those to generate a "best effort" version
            # object. The leftover portions of the substrings that could not be
            # converted will be returned by reference.
            #
            # .PARAMETER ReferenceToVersionObject
            # This parameter is required; it is a reference to a System.Version object
            # that will be used to store the version object that is generated from the
            # string. If the string is successfully converted to a version object, the
            # version object will be stored in this reference. If one or more portions
            # of the string could not be converted to a version object, the version
            # object will be generated from the portions that could be converted, and
            # the portions that could not be converted will be stored in the
            # other reference parameters.
            #
            # .PARAMETER ReferenceArrayOfLeftoverStrings
            # This parameter is required; it is a reference to an array of five
            # elements. Each element is a string; One or more of the elements may be
            # modified if the string could not be converted to a version object. If the
            # string could not be converted to a version object, any portions of the
            # string that exceed the major, minor, build, and revision version portions
            # will be stored in the elements of the array.
            #
            # The first element of the array will be modified if the major version
            # portion of the string could not be converted to a version object. If the
            # major version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the major version will be
            # used to generate the version object. The remaining portion of the major
            # version will be stored in the first element of the array.
            #
            # The second element of the array will be modified if the minor version
            # portion of the string could not be converted to a version object. If the
            # minor version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the minor version will be
            # used to generate the version object. The remaining portion of the minor
            # version will be stored in second element of the array.
            #
            # If the major version portion of the string could not be converted to a
            # version object, the entire minor version portion of the string will be
            # stored in the second element, and no portion of the supplied minor
            # version reference will be used to generate the version object.
            #
            # The third element of the array will be modified if the build version
            # portion of the string could not be converted to a version object. If the
            # build version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the build version will be
            # used to generate the version object. The remaining portion of the build
            # version will be stored in the third element of the array.
            #
            # If the major or minor version portions of the string could not be
            # converted to a version object, the entire build version portion of the
            # string will be stored in the third element, and no portion of the
            # supplied build version reference will be used to generate the version
            # object.
            #
            # The fourth element of the array will be modified if the revision version
            # portion of the string could not be converted to a version object. If the
            # revision version portion of the string could not be converted to a
            # version object, the left-most numerical-only portion of the revision
            # version will be used to generate the version object. The remaining
            # portion of the revision version will be stored in the fourth element of
            # the array.
            #
            # If the major, minor, or build version portions of the string could not be
            # converted to a version object, the entire revision version portion of the
            # string will be stored in the fourth element, and no portion of the
            # supplied revision version reference will be used to generate the version
            # object.
            #
            # The fifth element of the array will be modified if the string could not
            # be converted to a version object. If the string could not be converted to
            # a version object, any portions of the string that exceed the major,
            # minor, build, and revision version portions will be stored in the string
            # reference.
            #
            # For example, if the string is '1.2.3.4.5', the fifth element in the array
            # will be '5'. If the string is '1.2.3.4.5.6', the fifth element of the
            # array will be '5.6'.
            #
            # .PARAMETER StringToConvert
            # This parameter is required; it is string that will be converted to a
            # version object. If the string contains characters not allowed in a
            # version object, this function will attempt to convert the string to a
            # version object by removing the characters that are not allowed,
            # identifying the portions of the version object that are not allowed,
            # which can be evaluated further if needed.
            #
            # .PARAMETER PSVersion
            # This parameter is optional; it is a version object that represents the
            # version of PowerShell that is running the script. If this parameter is
            # supplied, it will improve the performance of the function by allowing it
            # to skip the determination of the PowerShell engine version.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.3.4'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 0 because the string is in a valid format for a
            # # version object.
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=3, Revision=4.
            # # All strings in $arrLeftoverStrings will be empty.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.3.4-beta3'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 4 because the string is not in a valid format
            # # for a version object. The 4 indicates that the revision version portion
            # # of the string could not be converted to a version object.
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=3, Revision=4.
            # # $arrLeftoverStrings[3] will be '-beta3'. All other elements of
            # # $arrLeftoverStrings will be empty.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.2147483700.4'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 3 because the string is not in a valid format
            # # for a version object. The 3 indicates that the build version portion of
            # # the string could not be converted to a version object (the value
            # # exceeds the maximum value for a version element - 2147483647).
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=2147483647, Revision=-1.
            # # $arrLeftoverStrings[2] will be '53' (2147483700 - 2147483647) and
            # # $arrLeftoverStrings[3] will be '4'. All other elements of
            # # $arrLeftoverStrings will be empty.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.2147483700-beta5.4'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 3 because the string is not in a valid format
            # # for a version object. The 3 indicates that the build version portion of
            # # the string could not be converted to a version object (the value
            # # exceeds the maximum value for a version element - 2147483647).
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=2147483647, Revision=-1.
            # # $arrLeftoverStrings[2] will be '53-beta5' (2147483700 - 2147483647)
            # # plus the non-numeric portion of the string ('-beta5') and
            # # $arrLeftoverStrings[3] will be '4'. All other elements of
            # # $arrLeftoverStrings will be empty.
            #
            # .EXAMPLE
            # $version = $null
            # $arrLeftoverStrings = @('', '', '', '', '')
            # $strVersion = '1.2.3.4.5'
            # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject ([ref]$version) -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
            # # $intReturnCode will be 5 because the string is in a valid format for a
            # # version object. The 5 indicates that there were excess portions of the
            # # string that could not be converted to a version object.
            # # $version will be a System.Version object with Major=1, Minor=2,
            # # Build=3, Revision=4.
            # # $arrLeftoverStrings[4] will be '5'. All other elements of
            # # $arrLeftoverStrings will be empty.
            #
            # .INPUTS
            # None. You can't pipe objects to Convert-StringToFlexibleVersion.
            #
            # .OUTPUTS
            # System.Int32. Convert-StringToFlexibleVersion returns an integer value
            # indicating whether the string was successfully converted to a version
            # object. The return value is as follows:
            # 0: The string was successfully converted to a version object.
            # 1: The string could not be converted to a version object because the
            #    major version portion of the string contained characters that made it
            #    impossible to convert to a version object. With these characters
            #    removed, the major version portion of the string was converted to a
            #    version object.
            # 2: The string could not be converted to a version object because the
            #    minor version portion of the string contained characters that made it
            #    impossible to convert to a version object. With these characters
            #    removed, the minor version portion of the string was converted to a
            #    version object.
            # 3: The string could not be converted to a version object because the
            #    build version portion of the string contained characters that made it
            #    impossible to convert to a version object. With these characters
            #    removed, the build version portion of the string was converted to a
            #    version object.
            # 4: The string could not be converted to a version object because the
            #    revision version portion of the string contained characters that made
            #    it impossible to convert to a version object. With these characters
            #    removed, the revision version portion of the string was converted to a
            #    version object.
            # 5: The string was successfully converted to a version object, but there
            #    were excess portions of the string that could not be converted to a
            #    version object.
            # -1: The string could not be converted to a version object because the
            #     string did not begin with numerical characters.
            #
            # .NOTES
            # This function also supports the use of positional parameters instead of
            # named parameters. If positional parameters are used instead of named
            # parameters, then three or four positional parameters are required:
            #
            # The first positional parameter is a reference to a System.Version object
            # that will be used to store the version object that is generated from the
            # string. If the string is successfully converted to a version object, the
            # version object will be stored in this reference. If one or more portions
            # of the string could not be converted to a version object, the version
            # object will be generated from the portions that could be converted, and
            # the portions that could not be converted will be stored in the
            # other reference parameters.
            #
            # The second positional parameter is a reference to an array of five
            # elements. Each element is a string; One or more of the elements may be
            # modified if the string could not be converted to a version object. If the
            # string could not be converted to a version object, any portions of the
            # string that exceed the major, minor, build, and revision version portions
            # will be stored in the elements of the array.
            #
            # The first element of the array will be modified if the major version
            # portion of the string could not be converted to a version object. If the
            # major version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the major version will be
            # used to generate the version object. The remaining portion of the major
            # version will be stored in the first element of the array.
            #
            # The second element of the array will be modified if the minor version
            # portion of the string could not be converted to a version object. If the
            # minor version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the minor version will be
            # used to generate the version object. The remaining portion of the minor
            # version will be stored in second element of the array.
            #
            # If the major version portion of the string could not be converted to a
            # version object, the entire minor version portion of the string will be
            # stored in the second element, and no portion of the supplied minor
            # version reference will be used to generate the version object.
            #
            # The third element of the array will be modified if the build version
            # portion of the string could not be converted to a version object. If the
            # build version portion of the string could not be converted to a version
            # object, the left-most numerical-only portion of the build version will be
            # used to generate the version object. The remaining portion of the build
            # version will be stored in the third element of the array.
            #
            # If the major or minor version portions of the string could not be
            # converted to a version object, the entire build version portion of the
            # string will be stored in the third element, and no portion of the
            # supplied build version reference will be used to generate the version
            # object.
            #
            # The fourth element of the array will be modified if the revision version
            # portion of the string could not be converted to a version object. If the
            # revision version portion of the string could not be converted to a
            # version object, the left-most numerical-only portion of the revision
            # version will be used to generate the version object. The remaining
            # portion of the revision version will be stored in the fourth element of
            # the array.
            #
            # If the major, minor, or build version portions of the string could not be
            # converted to a version object, the entire revision version portion of the
            # string will be stored in the fourth element, and no portion of the
            # supplied revision version reference will be used to generate the version
            # object.
            #
            # The fifth element of the array will be modified if the string could not
            # be converted to a version object. If the string could not be converted to
            # a version object, any portions of the string that exceed the major,
            # minor, build, and revision version portions will be stored in the string
            # reference.
            #
            # For example, if the string is '1.2.3.4.5', the fifth element in the array
            # will be '5'. If the string is '1.2.3.4.5.6', the fifth element of the
            # array will be '5.6'.
            #
            # The third positional parameter is string that will be converted to a
            # version object. If the string contains characters not allowed in a
            # version object, this function will attempt to convert the string to a
            # version object by removing the characters that are not allowed,
            # identifying the portions of the version object that are not allowed,
            # which can be evaluated further if needed.
            #
            # If supplied, the fourth positional parameter is a version object that
            # represents the version of PowerShell that is running the script. If this
            # parameter is supplied, it will improve the performance of the function by
            # allowing it to skip the determination of the PowerShell engine version.
            #
            # Version: 1.0.20250218.0

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
                [ref]$ReferenceToVersionObject = ([ref]$null),
                [ref]$ReferenceArrayOfLeftoverStrings = ([ref]$null),
                [string]$StringToConvert = '',
                [version]$PSVersion = ([version]'0.0')
            )

            function Convert-StringToVersionSafely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Version object.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Version object. If the
                # string cannot be converted to a System.Version object, the function
                # suppresses the error and returns $false. If the string can be
                # converted to a version object, the function returns $true and passes
                # the version object by reference to the caller.
                #
                # .PARAMETER ReferenceToVersionObject
                # This parameter is required; it is a reference to a System.Version
                # object that will be used to store the converted version object if the
                # conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Version object.
                #
                # .EXAMPLE
                # $version = $null
                # $strVersion = '1.2.3.4'
                # $boolSuccess = Convert-StringToVersionSafely -ReferenceToVersionObject ([ref]$version) -StringToConvert $strVersion
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $version will contain a System.Version object with major version 1,
                # # minor version 2, build version 3, and revision version 4.
                #
                # .EXAMPLE
                # $version = $null
                # $strVersion = '1'
                # $boolSuccess = Convert-StringToVersionSafely -ReferenceToVersionObject ([ref]$version) -StringToConvert $strVersion
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $version is undefined in this instance.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToVersionSafely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToVersionSafely returns a boolean value
                # indiciating whether the process completed successfully. $true means
                # the conversion completed successfully; $false means there was an
                # error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a System.Version
                # object that will be used to store the converted version object if the
                # conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Version object.
                #
                # Version: 1.0.20250215.0

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

                param (
                    [ref]$ReferenceToVersionObject = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToVersionObject.Value = [version]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

            function Split-StringOnLiteralString {
                # .SYNOPSIS
                # Splits a string into an array using a literal string as the splitter.
                #
                # .DESCRIPTION
                # Splits a string using a literal string (as opposed to regex). The
                # function is designed to be backward-compatible with all versions of
                # PowerShell and has been tested successfully on PowerShell v1. This
                # function behaves more like VBScript's Split() function than other
                # string splitting-approaches in PowerShell while avoiding the use of
                # RegEx.
                #
                # .PARAMETER StringToSplit
                # This parameter is required; it is the string to be split into an
                # array.
                #
                # .PARAMETER Splitter
                # This parameter is required; it is the string that will be used to
                # split the string specified in the StringToSplit parameter.
                #
                # .EXAMPLE
                # $result = Split-StringOnLiteralString -StringToSplit 'What do you think of this function?' -Splitter ' '
                # # $result.Count is 7
                # # $result[2] is 'you'
                #
                # .EXAMPLE
                # $result = Split-StringOnLiteralString 'What do you think of this function?' ' '
                # # $result.Count is 7
                #
                # .EXAMPLE
                # $result = Split-StringOnLiteralString -StringToSplit 'foo' -Splitter ' '
                # # $result.GetType().FullName is System.Object[]
                # # $result.Count is 1
                #
                # .EXAMPLE
                # $result = Split-StringOnLiteralString -StringToSplit 'foo' -Splitter ''
                # # $result.GetType().FullName is System.Object[]
                # # $result.Count is 5 because of how .NET handles a split using an
                # # empty string:
                # # $result[0] is ''
                # # $result[1] is 'f'
                # # $result[2] is 'o'
                # # $result[3] is 'o'
                # # $result[4] is ''
                #
                # .INPUTS
                # None. You can't pipe objects to Split-StringOnLiteralString.
                #
                # .OUTPUTS
                # System.String[]. Split-StringOnLiteralString returns an array of
                # strings, with each string being an element of the resulting array
                # from the split operation. This function always returns an array, even
                # when there is zero elements or one element in it.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is the string to be split into an
                # array.
                #
                # The second positional parameter is the string that will be used to
                # split the string specified in the first positional parameter.
                #
                # Also, please note that if -StringToSplit (or the first positional
                # parameter) is $null, then the function will return an array with one
                # element, which is an empty string. This is because the function
                # converts $null to an empty string before splitting the string.
                #
                # Version: 3.0.20250211.1

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

                param (
                    [string]$StringToSplit = '',
                    [string]$Splitter = ''
                )

                $strSplitterInRegEx = [regex]::Escape($Splitter)
                $result = @([regex]::Split($StringToSplit, $strSplitterInRegEx))

                # The following code forces the function to return an array, always,
                # even when there are zero or one elements in the array
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
                    return ($result)
                } elseif ($intElementCount -eq 0) {
                    return (, @())
                } elseif ($intElementCount -eq 1) {
                    return (, (, $StringToSplit))
                } else {
                    return ($result)
                }
            }

            function Convert-StringToInt32Safely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Int32.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Int32. If the string
                # cannot be converted to a System.Int32, the function suppresses the
                # error and returns $false. If the string can be converted to an
                # int32, the function returns $true and passes the int32 by
                # reference to the caller.
                #
                # .PARAMETER ReferenceToInt32
                # This parameter is required; it is a reference to a System.Int32
                # object that will be used to store the converted int32 object if the
                # conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Int32 object.
                #
                # .EXAMPLE
                # $int = $null
                # $strInt = '1234'
                # $boolSuccess = Convert-StringToInt32Safely -ReferenceToInt32 ([ref]$int) -StringToConvert $strInt
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $int will contain a System.Int32 object equal to 1234.
                #
                # .EXAMPLE
                # $int = $null
                # $strInt = 'abc'
                # $boolSuccess = Convert-StringToInt32Safely -ReferenceToInt32 ([ref]$int) -StringToConvert $strInt
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $int will be undefined in this case.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToInt32Safely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToInt32Safely returns a boolean value
                # indiciating whether the process completed successfully. $true means
                # the conversion completed successfully; $false means there was an
                # error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a System.Int32
                # object that will be used to store the converted int32 object if the
                # conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Int32 object.
                #
                # Version: 1.0.20250215.0

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

                param (
                    [ref]$ReferenceToInt32 = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToInt32.Value = [int32]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

            function Convert-StringToInt64Safely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Int64.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Int64. If the string
                # cannot be converted to a System.Int64, the function suppresses the
                # error and returns $false. If the string can be converted to an
                # int64, the function returns $true and passes the int64 by
                # reference to the caller.
                #
                # .PARAMETER ReferenceToInt64
                # This parameter is required; it is a reference to a System.Int64
                # object that will be used to store the converted int64 object if the
                # conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Int64 object.
                #
                # .EXAMPLE
                # $int = $null
                # $strInt = '1234'
                # $boolSuccess = Convert-StringToInt64Safely -ReferenceToInt64 ([ref]$int) -StringToConvert $strInt
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $int will contain a System.Int64 object equal to 1234.
                #
                # .EXAMPLE
                # $int = $null
                # $strInt = 'abc'
                # $boolSuccess = Convert-StringToInt64Safely -ReferenceToInt64 ([ref]$int) -StringToConvert $strInt
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $int will be undefined in this case.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToInt64Safely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToInt64Safely returns a boolean value
                # indiciating whether the process completed successfully. $true means
                # the conversion completed successfully; $false means there was an
                # error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a System.Int64
                # object that will be used to store the converted int64 object if the
                # conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Int64 object.
                #
                # Version: 1.0.20250215.0

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

                param (
                    [ref]$ReferenceToInt64 = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToInt64.Value = [int64]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

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

            function Convert-StringToBigIntegerSafely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Numerics.BigInteger object.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Numerics.BigInteger object.
                # If the string cannot be converted to a System.Numerics.BigInteger
                # object, the function suppresses the error and returns $false. If the
                # string can be converted to a bigint object, the function returns
                # $true and passes the bigint object by reference to the caller.
                #
                # .PARAMETER ReferenceToBigIntegerObject
                # This parameter is required; it is a reference to a
                # System.Numerics.BigInteger object that will be used to store the
                # converted bigint object if the conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Numerics.BigInteger object.
                #
                # .EXAMPLE
                # $bigint = $null
                # $strBigInt = '100000000000000000000000000000'
                # $boolSuccess = Convert-StringToBigIntegerSafely -ReferenceToBigIntegerObject ([ref]$bigint) -StringToConvert $strBigInt
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $bigint will contain a System.Numerics.BigInteger object equal to
                # # 100000000000000000000000000000.
                #
                # .EXAMPLE
                # $bigint = $null
                # $strBigInt = 'abc'
                # $boolSuccess = Convert-StringToBigIntegerSafely -ReferenceToBigIntegerObject ([ref]$bigint) -StringToConvert $strBigInt
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $bigint will be undefined in this case.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToBigIntegerSafely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToBigIntegerSafely returns a boolean
                # value indiciating whether the process completed successfully. $true
                # means the conversion completed successfully; $false means there was
                # an error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a
                # System.Numerics.BigInteger object that will be used to store the
                # converted bigint object if the conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Numerics.BigInteger object.
                #
                # Version: 1.0.20250216.0

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

                param (
                    [ref]$ReferenceToBigIntegerObject = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToBigIntegerObject.Value = [System.Numerics.BigInteger]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

            function Convert-StringToDoubleSafely {
                # .SYNOPSIS
                # Attempts to convert a string to a System.Double.
                #
                # .DESCRIPTION
                # Attempts to convert a string to a System.Double. If the string
                # cannot be converted to a System.Double, the function suppresses the
                # error and returns $false. If the string can be converted to an
                # double, the function returns $true and passes the double by
                # reference to the caller.
                #
                # .PARAMETER ReferenceToDouble
                # This parameter is required; it is a reference to a System.Double
                # object that will be used to store the converted double object if the
                # conversion is successful.
                #
                # .PARAMETER StringToConvert
                # This parameter is required; it is a string that is to be converted to
                # a System.Double object.
                #
                # .EXAMPLE
                # $double = $null
                # $str = '100000000000000000000000'
                # $boolSuccess = Convert-StringToDoubleSafely -ReferenceToDouble ([ref]$double) -StringToConvert $str
                # # $boolSuccess will be $true, indicating that the conversion was
                # # successful.
                # # $double will contain a System.Double object equal to 1E+23
                #
                # .EXAMPLE
                # $double = $null
                # $str = 'abc'
                # $boolSuccess = Convert-StringToDoubleSafely -ReferenceToDouble ([ref]$double) -StringToConvert $str
                # # $boolSuccess will be $false, indicating that the conversion was
                # # unsuccessful.
                # # $double will undefined in this case.
                #
                # .INPUTS
                # None. You can't pipe objects to Convert-StringToDoubleSafely.
                #
                # .OUTPUTS
                # System.Boolean. Convert-StringToDoubleSafely returns a boolean value
                # indiciating whether the process completed successfully. $true means
                # the conversion completed successfully; $false means there was an
                # error.
                #
                # .NOTES
                # This function also supports the use of positional parameters instead
                # of named parameters. If positional parameters are used instead of
                # named parameters, then two positional parameters are required:
                #
                # The first positional parameter is a reference to a System.Double
                # object that will be used to store the converted double object if the
                # conversion is successful.
                #
                # The second positional parameter is a string that is to be converted
                # to a System.Double object.
                #
                # Version: 1.0.20250216.0

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

                param (
                    [ref]$ReferenceToDouble = ([ref]$null),
                    [string]$StringToConvert = ''
                )

                #region FunctionsToSupportErrorHandling ############################
                function Get-ReferenceToLastError {
                    # .SYNOPSIS
                    # Gets a reference (memory pointer) to the last error that
                    # occurred.
                    #
                    # .DESCRIPTION
                    # Returns a reference (memory pointer) to $null ([ref]$null) if no
                    # errors on on the $error stack; otherwise, returns a reference to
                    # the last error that occurred.
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work:
                    # $refLastKnownError = Get-ReferenceToLastError
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # $refNewestCurrentError = Get-ReferenceToLastError
                    #
                    # $boolErrorOccurred = $false
                    # if (($null -ne $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #     # Both not $null
                    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # } else {
                    #     # One is $null, or both are $null
                    #     # NOTE: $refLastKnownError could be non-null, while
                    #     # $refNewestCurrentError could be null if $error was cleared;
                    #     # this does not indicate an error.
                    #     #
                    #     # So:
                    #     # If both are null, no error.
                    #     # If $refLastKnownError is null and $refNewestCurrentError is
                    #     # non-null, error.
                    #     # If $refLastKnownError is non-null and
                    #     # $refNewestCurrentError is null, no error.
                    #     #
                    #     if (($null -eq $refLastKnownError.Value) -and ($null -ne $refNewestCurrentError.Value)) {
                    #         $boolErrorOccurred = $true
                    #     }
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Get-ReferenceToLastError.
                    #
                    # .OUTPUTS
                    # System.Management.Automation.PSReference ([ref]).
                    # Get-ReferenceToLastError returns a reference (memory pointer) to
                    # the last error that occurred. It returns a reference to $null
                    # ([ref]$null) if there are no errors on on the $error stack.
                    #
                    # .NOTES
                    # Version: 2.0.20250215.1

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################

                    if ($Error.Count -gt 0) {
                        return ([ref]($Error[0]))
                    } else {
                        return ([ref]$null)
                    }
                }

                function Test-ErrorOccurred {
                    # .SYNOPSIS
                    # Checks to see if an error occurred during a time period, i.e.,
                    # during the execution of a command.
                    #
                    # .DESCRIPTION
                    # Using two references (memory pointers) to errors, this function
                    # checks to see if an error occurred based on differences between
                    # the two errors.
                    #
                    # To use this function, you must first retrieve a reference to the
                    # last error that occurred prior to the command you are about to
                    # run. Then, run the command. After the command completes, retrieve
                    # a reference to the last error that occurred. Pass these two
                    # references to this function to determine if an error occurred.
                    #
                    # .PARAMETER ReferenceToEarlierError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time,
                    # ReferenceToEarlierError must be a reference to $null
                    # ([ref]$null).
                    #
                    # .PARAMETER ReferenceToLaterError
                    # This parameter is required; it is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred.
                    #
                    # If no error was on the stack at this time, ReferenceToLaterError
                    # must be a reference to $null ([ref]$null).
                    #
                    # .EXAMPLE
                    # # Intentionally empty trap statement to prevent terminating
                    # # errors from halting processing
                    # trap { }
                    #
                    # # Retrieve the newest error on the stack prior to doing work
                    # if ($Error.Count -gt 0) {
                    #     $refLastKnownError = ([ref]($Error[0]))
                    # } else {
                    #     $refLastKnownError = ([ref]$null)
                    # }
                    #
                    # # Store current error preference; we will restore it after we do
                    # # some work:
                    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
                    #
                    # # Set ErrorActionPreference to SilentlyContinue; this will
                    # # suppress error output. Terminating errors will not output
                    # # anything, kick to the empty trap statement and then continue
                    # # on. Likewise, non- terminating errors will also not output
                    # # anything, but they do not kick to the trap statement; they
                    # # simply continue on.
                    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
                    #
                    # # Do something that might trigger an error
                    # Get-Item -Path 'C:\MayNotExist.txt'
                    #
                    # # Restore the former error preference
                    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
                    #
                    # # Retrieve the newest error on the error stack
                    # if ($Error.Count -gt 0) {
                    #     $refNewestCurrentError = ([ref]($Error[0]))
                    # } else {
                    #     $refNewestCurrentError = ([ref]$null)
                    # }
                    #
                    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    #     # Error occurred
                    # } else {
                    #     # No error occurred
                    # }
                    #
                    # .INPUTS
                    # None. You can't pipe objects to Test-ErrorOccurred.
                    #
                    # .OUTPUTS
                    # System.Boolean. Test-ErrorOccurred returns a boolean value
                    # indicating whether an error occurred during the time period in
                    # question. $true indicates an error occurred; $false indicates no
                    # error occurred.
                    #
                    # .NOTES
                    # This function also supports the use of positional parameters
                    # instead of named parameters. If positional parameters are used
                    # instead of named parameters, then two positional parameters are
                    # required:
                    #
                    # The first positional parameter is a reference (memory pointer) to
                    # a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack earlier in time, i.e., prior to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time, the first
                    # positional parameter must be a reference to $null ([ref]$null).
                    #
                    # The second positional parameter is a reference (memory pointer)
                    # to a System.Management.Automation.ErrorRecord that represents the
                    # newest error on the stack later in time, i.e., after to running
                    # the command for which you wish to determine whether an error
                    # occurred. If no error was on the stack at this time,
                    # ReferenceToLaterError must be a reference to $null ([ref]$null).
                    #
                    # Version: 2.0.20250215.0

                    #region License ################################################
                    # Copyright (c) 2025 Frank Lesniak
                    #
                    # Permission is hereby granted, free of charge, to any person
                    # obtaining a copy of this software and associated documentation
                    # files (the "Software"), to deal in the Software without
                    # restriction, including without limitation the rights to use,
                    # copy, modify, merge, publish, distribute, sublicense, and/or sell
                    # copies of the Software, and to permit persons to whom the
                    # Software is furnished to do so, subject to the following
                    # conditions:
                    #
                    # The above copyright notice and this permission notice shall be
                    # included in all copies or substantial portions of the Software.
                    #
                    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                    # OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                    # HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                    # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                    # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                    # OTHER DEALINGS IN THE SOFTWARE.
                    #endregion License ################################################
                    param (
                        [ref]$ReferenceToEarlierError = ([ref]$null),
                        [ref]$ReferenceToLaterError = ([ref]$null)
                    )

                    # TODO: Validate input

                    $boolErrorOccurred = $false
                    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                        # Both not $null
                        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    } else {
                        # One is $null, or both are $null
                        # NOTE: $ReferenceToEarlierError could be non-null, while
                        # $ReferenceToLaterError could be null if $error was cleared;
                        # this does not indicate an error.
                        # So:
                        # - If both are null, no error.
                        # - If $ReferenceToEarlierError is null and
                        #   $ReferenceToLaterError is non-null, error.
                        # - If $ReferenceToEarlierError is non-null and
                        #   $ReferenceToLaterError is null, no error.
                        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
                            $boolErrorOccurred = $true
                        }
                    }

                    return $boolErrorOccurred
                }
                #endregion FunctionsToSupportErrorHandling ############################

                trap {
                    # Intentionally left empty to prevent terminating errors from
                    # halting processing
                }

                # Retrieve the newest error on the stack prior to doing work
                $refLastKnownError = Get-ReferenceToLastError

                # Store current error preference; we will restore it after we do the
                # work of this function
                $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

                # Set ErrorActionPreference to SilentlyContinue; this will suppress
                # error output. Terminating errors will not output anything, kick to
                # the empty trap statement and then continue on. Likewise, non-
                # terminating errors will also not output anything, but they do not
                # kick to the trap statement; they simply continue on.
                $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

                $ReferenceToDouble.Value = [double]$StringToConvert

                # Restore the former error preference
                $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

                # Retrieve the newest error on the error stack
                $refNewestCurrentError = Get-ReferenceToLastError

                if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                    # Error occurred; return failure indicator:
                    return $false
                } else {
                    # No error occurred; return success indicator:
                    return $true
                }
            }

            $ReferenceArrayOfLeftoverStrings.Value = @('', '', '', '', '')

            $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $StringToConvert

            if ($boolResult) {
                return 0
            }

            # If we are still here, the conversion was not successful.

            $arrVersionElements = Split-StringOnLiteralString -StringToSplit $StringToConvert -Splitter '.'
            $intCountOfVersionElements = $arrVersionElements.Count

            if ($intCountOfVersionElements -lt 2) {
                # You can't have a version with less than two elements
                return -1
            }

            if ($intCountOfVersionElements -ge 5) {
                $strExcessVersionElements = [string]::join('.', $arrVersionElements[4..($intCountOfVersionElements - 1)])
            } else {
                $strExcessVersionElements = ''
            }

            if ($intCountOfVersionElements -ge 3) {
                $intElementInQuestion = 3
            } else {
                $intElementInQuestion = $intCountOfVersionElements
            }

            $boolConversionSuccessful = $false

            # See if excess elements are our only problem
            if (-not [string]::IsNullOrEmpty($strExcessVersionElements)) {
                $strAttemptedVersion = [string]::join('.', $arrVersionElements[0..$intElementInQuestion])
                $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersion
                if ($boolResult) {
                    # Conversion successful; the only problem was the excess elements
                    $boolConversionSuccessful = $true
                    $intReturnValue = 5
                    ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                }
            }

            while ($intElementInQuestion -gt 0 -and -not $boolConversionSuccessful) {
                $strAttemptedVersion = [string]::join('.', $arrVersionElements[0..($intElementInQuestion - 1)])
                $boolResult = $false
                if ($intElementInQuestion -gt 1) {
                    $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersion
                }
                if ($boolResult -or $intElementInQuestion -eq 1) {
                    # Conversion successful or we're on the second element
                    # See if we can trim out non-numerical characters
                    $strRegexFirstNumericalCharacters = '^\d+'
                    $strFirstNumericalCharacters = [regex]::Match($arrVersionElements[$intElementInQuestion], $strRegexFirstNumericalCharacters).Value
                    if ([string]::IsNullOrEmpty($strFirstNumericalCharacters)) {
                        # No numerical characters found
                        ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = $arrVersionElements[$intElementInQuestion]
                        for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                            ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                        }
                        $boolConversionSuccessful = $true
                        $intReturnValue = $intElementInQuestion + 1
                        ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                    } else {
                        # Numerical characters found
                        $boolResult = Convert-StringToInt32Safely -ReferenceToInt32 ([ref]$null) -StringToConvert $strFirstNumericalCharacters
                        if ($boolResult) {
                            # Append the first numerical characters to the version
                            $strAttemptedVersionNew = $strAttemptedVersion + '.' + $strFirstNumericalCharacters
                            $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersionNew
                            if ($boolResult) {
                                # Conversion successful
                                $strExcessCharactersInThisElement = ($arrVersionElements[$intElementInQuestion]).Substring($strFirstNumericalCharacters.Length)
                                ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = $strExcessCharactersInThisElement
                                for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                    ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                }
                                $boolConversionSuccessful = $true
                                $intReturnValue = $intElementInQuestion + 1
                                ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                            } else {
                                # Conversion was not successful even though we just
                                # tried converting using numbers we know are
                                # convertable to an int32. This makes no sense.
                                # Throw warning:
                                $strMessage = 'Conversion of string "' + $strAttemptedVersionNew + '" to a version object failed even though "' + $strAttemptedVersion + '" converted to a version object just fine, and we proved that "' + $strFirstNumericalCharacters + '" was converted to an int32 object successfully. This should not be possible!'
                                Write-Warning -Message $strMessage
                            }
                        } else {
                            # The string of numbers could not be converted to an int32;
                            # this is probably because the represented number is too
                            # large.
                            # Try converting to int64:
                            $int64 = $null
                            $boolResult = Convert-StringToInt64Safely -ReferenceToInt64 ([ref]$int64) -StringToConvert $strFirstNumericalCharacters
                            if ($boolResult) {
                                # Converted to int64 but not int32
                                $intRemainder = $int64 - [int32]::MaxValue
                                $strAttemptedVersionNew = $strAttemptedVersion + '.' + [int32]::MaxValue
                                $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersionNew
                                if ($boolResult) {
                                    # Conversion successful
                                    $strExcessCharactersInThisElement = ($arrVersionElements[$intElementInQuestion]).Substring($strFirstNumericalCharacters.Length)
                                    ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = ([string]$intRemainder) + $strExcessCharactersInThisElement
                                    for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                        ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                    }
                                    $boolConversionSuccessful = $true
                                    $intReturnValue = $intElementInQuestion + 1
                                    ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                                } else {
                                    # Conversion was not successful even though we just
                                    # tried converting using numbers we know are
                                    # convertable to an int32. This makes no sense.
                                    # Throw warning:
                                    $strMessage = 'Conversion of string "' + $strAttemptedVersionNew + '" to a version object failed even though "' + $strAttemptedVersion + '" converted to a version object just fine, and we know that "' + ([string]([int32]::MaxValue)) + '" is a valid int32 number. This should not be possible!'
                                    Write-Warning -Message $strMessage
                                }
                            } else {
                                # Conversion to int64 failed; this is probably because
                                # the represented number is too large.
                                if ($PSVersion -eq ([version]'0.0')) {
                                    $versionPS = Get-PSVersion
                                } else {
                                    $versionPS = $PSVersion
                                }

                                if ($versionPS.Major -ge 3) {
                                    # Use bigint
                                    $bigint = $null
                                    $boolResult = Convert-StringToBigIntegerSafely -ReferenceToBigIntegerObject ([ref]$bigint) -StringToConvert $strFirstNumericalCharacters
                                    if ($boolResult) {
                                        # Converted to bigint but not int32 or
                                        # int64
                                        $bigintRemainder = $bigint - [int32]::MaxValue
                                        $strAttemptedVersionNew = $strAttemptedVersion + '.' + [int32]::MaxValue
                                        $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersionNew
                                        if ($boolResult) {
                                            # Conversion successful
                                            $strExcessCharactersInThisElement = ($arrVersionElements[$intElementInQuestion]).Substring($strFirstNumericalCharacters.Length)
                                            ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = ([string]$bigintRemainder) + $strExcessCharactersInThisElement
                                            for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                                ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                            }
                                            $boolConversionSuccessful = $true
                                            $intReturnValue = $intElementInQuestion + 1
                                            ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                                        } else {
                                            # Conversion was not successful even though
                                            # we just tried converting using numbers we
                                            # know are convertable to an int32. This
                                            # makes no sense. Throw warning:
                                            $strMessage = 'Conversion of string "' + $strAttemptedVersionNew + '" to a version object failed even though "' + $strAttemptedVersion + '" converted to a version object just fine, and we know that "' + ([string]([int32]::MaxValue)) + '" is a valid int32 number. This should not be possible!'
                                            Write-Warning -Message $strMessage
                                        }
                                    } else {
                                        # Conversion to bigint failed; given that we
                                        # know that the string is all numbers, this
                                        # should not be possible. Throw warning
                                        $strMessage = 'The string "' + $strFirstNumericalCharacters + '" could not be converted to an int32, int64, or bigint number. This should not be possible!'
                                        Write-Warning -Message $strMessage
                                    }
                                } else {
                                    # Use double
                                    $double = $null
                                    $boolResult = Convert-StringToDoubleSafely -ReferenceToDouble ([ref]$double) -StringToConvert $strFirstNumericalCharacters
                                    if ($boolResult) {
                                        # Converted to double but not int32 or
                                        # int64
                                        $doubleRemainder = $double - [int32]::MaxValue
                                        $strAttemptedVersionNew = $strAttemptedVersion + '.' + [int32]::MaxValue
                                        $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $strAttemptedVersionNew
                                        if ($boolResult) {
                                            # Conversion successful
                                            $strExcessCharactersInThisElement = ($arrVersionElements[$intElementInQuestion]).Substring($strFirstNumericalCharacters.Length)
                                            ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = ([string]$doubleRemainder) + $strExcessCharactersInThisElement
                                            for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                                ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                            }
                                            $boolConversionSuccessful = $true
                                            $intReturnValue = $intElementInQuestion + 1
                                            ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                                        } else {
                                            # Conversion was not successful even though
                                            # we just tried converting using numbers we
                                            # know are convertable to an int32. This
                                            # makes no sense. Throw warning:
                                            $strMessage = 'Conversion of string "' + $strAttemptedVersionNew + '" to a version object failed even though "' + $strAttemptedVersion + '" converted to a version object just fine, and we know that "' + ([string]([int32]::MaxValue)) + '" is a valid int32 number. This should not be possible!'
                                            Write-Warning -Message $strMessage
                                        }
                                    } else {
                                        # Conversion to double failed; given that we
                                        # know that the string is all numbers, this
                                        # should not be possible unless the string of
                                        # numbers exceeded the maximum size allowed
                                        # for a double. This is possible, so don't
                                        # throw a warning.
                                        # Treat like no numerical characters found
                                        ($ReferenceArrayOfLeftoverStrings.Value)[$intElementInQuestion] = $arrVersionElements[$intElementInQuestion]
                                        for ($intCounterA = $intElementInQuestion + 1; $intCounterA -le 3; $intCounterA++) {
                                            ($ReferenceArrayOfLeftoverStrings.Value)[$intCounterA] = $arrVersionElements[$intCounterA]
                                        }
                                        $boolConversionSuccessful = $true
                                        $intReturnValue = $intElementInQuestion + 1
                                        ($ReferenceArrayOfLeftoverStrings.Value)[4] = $strExcessVersionElements
                                    }
                                }
                            }
                        }
                    }
                }
                $intElementInQuestion--
            }

            if (-not $boolConversionSuccessful) {
                # Conversion was not successful
                return -1
            } else {
                return $intReturnValue
            }
        }

        trap {
            # Intentionally left empty to prevent terminating errors from halting
            # processing
        }

        if ([string]::IsNullOrEmpty($OSNativeSystemPath)) {
            $strNativeSystemPath = ''
            $intReturnCode = Get-WindowsNativeSystemPath -ReferenceToSystemPath ([ref]$strNativeSystemPath) -OSProcessorArchitecture $OSProcessorArchitecture -ProcessProcessorArchitecture $ProcessProcessorArchitecture
            if ($intReturnCode -ne 0) {
                return -1
            }
            $refNativeSystemPath = [ref]$strNativeSystemPath
        } else {
            $refNativeSystemPath = [ref]$OSNativeSystemPath
        }

        $strPathToNTOSKrnl = Join-Path -Path ($refNativeSystemPath.Value) -ChildPath 'ntoskrnl.exe'

        # Retrieve the newest error on the stack prior to doing work
        $refLastKnownError = Get-ReferenceToLastError

        # Store current error preference; we will restore it after we do the work of
        # this function
        $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

        # Set ErrorActionPreference to SilentlyContinue; this will suppress error
        # output. Terminating errors will not output anything, kick to the empty trap
        # statement and then continue on. Likewise, non-terminating errors will also
        # not output anything, but they do not kick to the trap statement; they simply
        # continue on.
        $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

        # Attempt to get the product version from ntoskrnl.exe
        $ReferenceToStringVersion.Value = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($strPathToNTOSKrnl).ProductVersion

        # Restore the former error preference
        $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

        # Retrieve the newest error on the error stack
        $refNewestCurrentError = Get-ReferenceToLastError

        if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
            # Error occurred

            return -2
        } else {
            # No error occurred
            if ([string]::IsNullOrEmpty($ReferenceToStringVersion.Value)) {
                # No version information found; this is an error
                return -3
            }

            # Version information found; convert to a version object
            $intReturnCode = Convert-StringToFlexibleVersion -ReferenceToVersionObject $ReferenceToSystemVersion -ReferenceArrayOfLeftoverStrings $ReferenceToArrayOfLeftoverStrings -StringToConvert $ReferenceToStringVersion.Value
            if ($intReturnCode -lt 0) {
                # Conversion failed; return failure indicator
                return -4
            }
            return $intReturnCode
        }
    }

    # TODO: Move these to parameters
    $intRequirementForMajorVersionNumber = 6
    $intRequirementForMinorVersionNumber = 6
    $intRequirementForBuildVersionNumber = 6
    $intRequirementForRevisionVersionNumber = 4

    $boolMethod1 = $true
    $boolMethod2 = $true
    $boolMethod3 = $true
    $boolMethod4 = $true
    $boolMethod5 = $true
    $boolMethod6 = $true
    $boolMethod7 = $true
    $boolMethod8 = $true
    $boolMethod9 = $true

    $intFunctionReturn = 0
    $strOSVersionStaging = ''
    $intOSMajor = -1
    $intOSMajorCurrentLevelOfAccuracy = -1
    $intOSMinor = -1
    $intOSMinorCurrentLevelOfAccuracy = -1
    $intOSBuild = -1
    $intOSBuildCurrentLevelOfAccuracy = -1
    $intOSRevision = -1
    $intOSRevisionCurrentLevelOfAccuracy = -1

    $intWorkingAccuracyTargetForMajor = $intRequirementForMajorVersionNumber
    $intWorkingAccuracyTargetForMinor = $intRequirementForMinorVersionNumber
    $intWorkingAccuracyTargetForBuild = $intRequirementForBuildVersionNumber
    $intWorkingAccuracyTargetForRevision = $intRequirementForRevisionVersionNumber

    if ($intWorkingAccuracyTargetForMajor -eq -1 -and $intWorkingAccuracyTargetForMinor -ge 0) {
        # Can't do minor without major
        $intFunctionReturn = -1
    } elseif ($intWorkingAccuracyTargetForMajor -ge 0 -and $intWorkingAccuracyTargetForMinor -eq -1) {
        # Can't do major without minor
        $intFunctionReturn = -1
    } elseif ($intWorkingAccuracyTargetForMajor -eq -1 -and $intWorkingAccuracyTargetForMinor -eq -1 -and $intWorkingAccuracyTargetForBuild -lt 1 -and $intWorkingAccuracyTargetForRevision -lt 1) {
        # Can't omit major and minor without making build or revision mandatory
        $intFunctionReturn = -1
    } elseif ($intWorkingAccuracyTargetForMajor -eq -1 -and $intWorkingAccuracyTargetForMinor -eq -1 -and $intWorkingAccuracyTargetForBuild -ge 1 -and $intWorkingAccuracyTargetForRevision -ge 1) {
        # Can't omit major and minor and make *both* build and revision mandatory
        $intFunctionReturn = -1
    } elseif ($intWorkingAccuracyTargetForMajor -ge 0 -and $intWorkingAccuracyTargetForMinor -ge 0 -and $intWorkingAccuracyTargetForBuild -eq -1 -and $intWorkingAccuracyTargetForRevision -ge 0) {
        # If major and minor are in play, can't omit build but allow revision
        $intFunctionReturn = -1
    }

    # #############################################################################
    $intThisMethodNumber = 1 # (Win32 -> RtlGetVersion)
    if ($intFunctionReturn -ge 0) {
        if ($boolMethod1) {
            # Possibly attempt method
            $boolMethodSucceeded = $False # Not implemented
        }
    }

    # #############################################################################
    $intThisMethodNumber = 2 # (WMI -> Win32_OperatingSystem)
    $intThisMethodMajorLevelOfAccuracy = 7
    $intThisMethodMinorLevelOfAccuracy = 7
    $intThisMethodBuildLevelOfAccuracy = 7
    $intThisMethodRevisionLevelOfAccuracy = -1
    if ($intFunctionReturn -ge 0) {
        if ($boolMethod2) {
            # Possibly attempt method
            if ($intOSMajorCurrentLevelOfAccuracy -lt $intThisMethodMajorLevelOfAccuracy -or $intOSMinorCurrentLevelOfAccuracy -lt $intThisMethodMinorLevelOfAccuracy -or $intOSBuildCurrentLevelOfAccuracy -lt $intThisMethodBuildLevelOfAccuracy -or $intOSRevisionCurrentLevelOfAccuracy -lt $intThisMethodRevisionLevelOfAccuracy) {
                $boolMethodSucceeded = $true
                if ($OSSystemVersionFromWMI -ne ([version]'0.0')) {
                    # We already have a version object; use it
                    $refOSSystemVersionFromWMI = [ref]$OSSystemVersionFromWMI
                } else {
                    # Get the OS version from WMI
                    $versionWindowsWMI = [version]'0.0'
                    $strWindowsVersionWMI = ''
                    $arrLeftoverStringsWMI = @('', '', '', '', '')
                    $intReturnCode = Get-WindowsOSVersionFromWMI -ReferenceToSystemVersion ([ref]$versionWindowsWMI) -ReferenceToStringVersion ([ref]$strWindowsVersionWMI) -ReferenceToArrayOfLeftoverStrings ([ref]$arrLeftoverStringsWMI) -PSVersion $PSVersion
                    if ($intReturnCode -lt 0) {
                        $boolMethodSucceeded = $false
                    } else {
                        $refOSSystemVersionFromWMI = [ref]$versionWindowsWMI
                    }
                }
                if ($boolMethodSucceeded) {
                    if ($refOSSystemVersionFromWMI.Value.Major -ne -1) {
                        # Major version obtained
                        if ($intOSMajorCurrentLevelOfAccuracy -lt $intThisMethodMajorLevelOfAccuracy) {
                            $intOSMajor = $refOSSystemVersionFromWMI.Value.Major
                            $intOSMajorCurrentLevelOfAccuracy = $intThisMethodMajorLevelOfAccuracy
                        } elseif ($intOSMajorCurrentLevelOfAccuracy -eq $intThisMethodMajorLevelOfAccuracy) {
                            if ($refOSSystemVersionFromWMI.Value.Major -gt $intOSMajor) {
                                $intOSMajor = $refOSSystemVersionFromWMI.Value.Major
                            }
                        }
                    }
                    if ($refOSSystemVersionFromWMI.Value.Minor -ne -1) {
                        # Minor version obtained
                        if ($intOSMinorCurrentLevelOfAccuracy -lt $intThisMethodMinorLevelOfAccuracy) {
                            $intOSMinor = $refOSSystemVersionFromWMI.Value.Minor
                            $intOSMinorCurrentLevelOfAccuracy = $intThisMethodMinorLevelOfAccuracy
                        } elseif ($intOSMinorCurrentLevelOfAccuracy -eq $intThisMethodMinorLevelOfAccuracy) {
                            if ($refOSSystemVersionFromWMI.Value.Minor -gt $intOSMinor) {
                                $intOSMinor = $refOSSystemVersionFromWMI.Value.Minor
                            }
                        }
                    }
                    if ($refOSSystemVersionFromWMI.Value.Build -ne -1) {
                        # Build version obtained
                        if ($intOSBuildCurrentLevelOfAccuracy -lt $intThisMethodBuildLevelOfAccuracy) {
                            $intOSBuild = $refOSSystemVersionFromWMI.Value.Build
                            $intOSBuildCurrentLevelOfAccuracy = $intThisMethodBuildLevelOfAccuracy
                        } elseif ($intOSBuildCurrentLevelOfAccuracy -eq $intThisMethodBuildLevelOfAccuracy) {
                            if ($refOSSystemVersionFromWMI.Value.Build -gt $intOSBuild) {
                                $intOSBuild = $refOSSystemVersionFromWMI.Value.Build
                            }
                        }
                    }
                    if ($refOSSystemVersionFromWMI.Value.Revision -ne -1) {
                        # Revision version obtained
                        if ($intOSRevisionCurrentLevelOfAccuracy -lt $intThisMethodRevisionLevelOfAccuracy) {
                            $intOSRevision = $refOSSystemVersionFromWMI.Value.Revision
                            $intOSRevisionCurrentLevelOfAccuracy = $intThisMethodRevisionLevelOfAccuracy
                        } elseif ($intOSRevisionCurrentLevelOfAccuracy -eq $intThisMethodRevisionLevelOfAccuracy) {
                            if ($refOSSystemVersionFromWMI.Value.Revision -gt $intOSRevision) {
                                $intOSRevision = $refOSSystemVersionFromWMI.Value.Revision
                            }
                        }
                    }
                }
            }
        }
    }

    # #############################################################################
    $intThisMethodNumber = 3 # ("Product version" of the file
    #                           C:\Windows\Sysnative\ntoskrnl.exe or
    #                           C:\Windows\System32\ntoskrnl.exe)
    $intThisMethodMajorLevelOfAccuracy = 7
    $intThisMethodMinorLevelOfAccuracy = 7
    $intThisMethodBuildLevelOfAccuracy = 7 # (If Major < 10, 7/7; If Major = 10,
    #                                        Minor = 0, and Build < 18362, 7/7;
    #                                        else 3/7)
    $intThisMethodRevisionLevelOfAccuracy = 7
    if ($intFunctionReturn -ge 0) {
        if ($boolMethod3) {
            # Possibly attempt method
            if ($intOSMajorCurrentLevelOfAccuracy -lt $intThisMethodMajorLevelOfAccuracy -or $intOSMinorCurrentLevelOfAccuracy -lt $intThisMethodMinorLevelOfAccuracy -or $intOSBuildCurrentLevelOfAccuracy -lt $intThisMethodBuildLevelOfAccuracy -or $intOSRevisionCurrentLevelOfAccuracy -lt $intThisMethodRevisionLevelOfAccuracy) {
                $boolMethodSucceeded = $true
                if ($KernelSystemVersion -ne ([version]'0.0')) {
                    # We already have a version object; use it
                    $refKernelSystemVersion = [ref]$KernelSystemVersion
                } else {
                    # Get the kernel version
                    $versionWindowsKernel = [version]'0.0'
                    $strWindowsKernelVersion = ''
                    $arrLeftoverStringsKernel = @('', '', '', '', '')
                    $intReturnCode = Get-WindowsKernelVersion -ReferenceToSystemVersion ([ref]$versionWindowsKernel) -ReferenceToStringVersion ([ref]$strWindowsKernelVersion) -ReferenceToArrayOfLeftoverStrings ([ref]$arrLeftoverStringsKernel) -OSNativeSystemPath $OSNativeSystemPath -OSProcessorArchitecture $OSProcessorArchitecture -ProcessProcessorArchitecture $ProcessProcessorArchitecture
                    if ($intReturnCode -lt 0) {
                        $boolMethodSucceeded = $false
                    } else {
                        $refKernelSystemVersion = [ref]$versionWindowsKernel
                    }
                }
                if ($boolMethodSucceeded) {
                    if ($refKernelSystemVersion.Value.Major -ne -1) {
                        # Major version obtained
                        if ($intOSMajorCurrentLevelOfAccuracy -lt $intThisMethodMajorLevelOfAccuracy) {
                            $intOSMajor = $refKernelSystemVersion.Value.Major
                            $intOSMajorCurrentLevelOfAccuracy = $intThisMethodMajorLevelOfAccuracy
                        } elseif ($intOSMajorCurrentLevelOfAccuracy -eq $intThisMethodMajorLevelOfAccuracy) {
                            if ($refKernelSystemVersion.Value.Major -gt $intOSMajor) {
                                $intOSMajor = $refKernelSystemVersion.Value.Major
                            }
                        }
                    }
                    if ($refKernelSystemVersion.Value.Minor -ne -1) {
                        # Minor version obtained
                        if ($intOSMinorCurrentLevelOfAccuracy -lt $intThisMethodMinorLevelOfAccuracy) {
                            $intOSMinor = $refKernelSystemVersion.Value.Minor
                            $intOSMinorCurrentLevelOfAccuracy = $intThisMethodMinorLevelOfAccuracy
                        } elseif ($intOSMinorCurrentLevelOfAccuracy -eq $intThisMethodMinorLevelOfAccuracy) {
                            if ($refKernelSystemVersion.Value.Minor -gt $intOSMinor) {
                                $intOSMinor = $refKernelSystemVersion.Value.Minor
                            }
                        }
                    }
                    if ($refKernelSystemVersion.Value.Build -ne -1) {
                        # Build version obtained
                        # Adjust accuracy if needed:
                        # (If Major < 10, 7/7; If Major = 10, Minor = 0, and
                        # Build < 18362, 7/7; else 3/7)
                        if ($intOSMajor -eq 10 -and $intOSMinor -eq 0 -and (($intOSBuild -ne -1 -and $intOSBuild -ge 18362) -or ($refKernelSystemVersion.Value.Build -ne -1 -and $refKernelSystemVersion.Value.Build -ge 18362))) {
                            $intThisMethodBuildLevelOfAccuracy = 3
                        } elseif (($intOSMajor -eq 10 -and $intOSMinor -gt 0) -or $intOSMajor -gt 10) {
                            $intThisMethodBuildLevelOfAccuracy = 3
                        }
                        if ($intOSBuildCurrentLevelOfAccuracy -lt $intThisMethodBuildLevelOfAccuracy) {
                            $intOSBuild = $refKernelSystemVersion.Value.Build
                            $intOSBuildCurrentLevelOfAccuracy = $intThisMethodBuildLevelOfAccuracy
                        } elseif ($intOSBuildCurrentLevelOfAccuracy -eq $intThisMethodBuildLevelOfAccuracy) {
                            if ($refKernelSystemVersion.Value.Build -gt $intOSBuild) {
                                $intOSBuild = $refKernelSystemVersion.Value.Build
                            }
                        }
                    }
                    if ($refKernelSystemVersion.Value.Revision -ne -1) {
                        # Revision version obtained
                        if ($intOSRevisionCurrentLevelOfAccuracy -lt $intThisMethodRevisionLevelOfAccuracy) {
                            $intOSRevision = $refKernelSystemVersion.Value.Revision
                            $intOSRevisionCurrentLevelOfAccuracy = $intThisMethodRevisionLevelOfAccuracy
                        } elseif ($intOSRevisionCurrentLevelOfAccuracy -eq $intThisMethodRevisionLevelOfAccuracy) {
                            if ($refKernelSystemVersion.Value.Revision -gt $intOSRevision) {
                                $intOSRevision = $refKernelSystemVersion.Value.Revision
                            }
                        }
                    }
                }
            }
        }
    }

    # #############################################################################
    $intThisMethodNumber = 4 # cmd /c ver > temp file
    $intThisMethodMajorLevelOfAccuracy = 6
    $intThisMethodMinorLevelOfAccuracy = 6
    $intThisMethodBuildLevelOfAccuracy = 6
    $intThisMethodRevisionLevelOfAccuracy = 4
    if ($intFunctionReturn -ge 0) {
        if ($boolMethod4) {
            # Possibly attempt method
            if ($intOSMajorCurrentLevelOfAccuracy -lt $intThisMethodMajorLevelOfAccuracy -or $intOSMinorCurrentLevelOfAccuracy -lt $intThisMethodMinorLevelOfAccuracy -or $intOSBuildCurrentLevelOfAccuracy -lt $intThisMethodBuildLevelOfAccuracy -or $intOSRevisionCurrentLevelOfAccuracy -lt $intThisMethodRevisionLevelOfAccuracy) {
                $boolMethodSucceeded = $true
                if ($OSSystemVersionFromVerCommand -ne ([version]'0.0')) {
                    # We already have a version object; use it
                    $refOSSystemVersionFromVerCommand = [ref]$OSSystemVersionFromVerCommand
                } else {
                    # Get the OS version from the ver command
                    $versionWindowsVerCommand = [version]'0.0'
                    $strWindowsVerCommandVersion = ''
                    $arrLeftoverStringsVerCommand = @('', '', '', '', '')
                    $intReturnCode = Get-WindowsOSVersionFromVerCommand -ReferenceToSystemVersion ([ref]$versionWindowsVerCommand) -ReferenceToStringVersion ([ref]$strWindowsVerCommandVersion) -ReferenceToArrayOfLeftoverStrings ([ref]$arrLeftoverStringsVerCommand) -PathToCommandPrompt $PathToCommandPrompt
                    if ($intReturnCode -lt 0) {
                        $boolMethodSucceeded = $false
                    } else {
                        $refOSSystemVersionFromVerCommand = [ref]$OSSystemVersionFromVerCommand
                    }
                }
                if ($boolMethodSucceeded) {
                    if ($refOSSystemVersionFromWMI.Value.Major -ne -1) {
                        # Major version obtained
                        if ($intOSMajorCurrentLevelOfAccuracy -lt $intThisMethodMajorLevelOfAccuracy) {
                            $intOSMajor = $refOSSystemVersionFromWMI.Value.Major
                            $intOSMajorCurrentLevelOfAccuracy = $intThisMethodMajorLevelOfAccuracy
                        } elseif ($intOSMajorCurrentLevelOfAccuracy -eq $intThisMethodMajorLevelOfAccuracy) {
                            if ($refOSSystemVersionFromWMI.Value.Major -gt $intOSMajor) {
                                $intOSMajor = $refOSSystemVersionFromWMI.Value.Major
                            }
                        }
                    }
                    if ($refOSSystemVersionFromWMI.Value.Minor -ne -1) {
                        # Minor version obtained
                        if ($intOSMinorCurrentLevelOfAccuracy -lt $intThisMethodMinorLevelOfAccuracy) {
                            $intOSMinor = $refOSSystemVersionFromWMI.Value.Minor
                            $intOSMinorCurrentLevelOfAccuracy = $intThisMethodMinorLevelOfAccuracy
                        } elseif ($intOSMinorCurrentLevelOfAccuracy -eq $intThisMethodMinorLevelOfAccuracy) {
                            if ($refOSSystemVersionFromWMI.Value.Minor -gt $intOSMinor) {
                                $intOSMinor = $refOSSystemVersionFromWMI.Value.Minor
                            }
                        }
                    }
                    if ($refOSSystemVersionFromWMI.Value.Build -ne -1) {
                        # Build version obtained
                        if ($intOSBuildCurrentLevelOfAccuracy -lt $intThisMethodBuildLevelOfAccuracy) {
                            $intOSBuild = $refOSSystemVersionFromWMI.Value.Build
                            $intOSBuildCurrentLevelOfAccuracy = $intThisMethodBuildLevelOfAccuracy
                        } elseif ($intOSBuildCurrentLevelOfAccuracy -eq $intThisMethodBuildLevelOfAccuracy) {
                            if ($refOSSystemVersionFromWMI.Value.Build -gt $intOSBuild) {
                                $intOSBuild = $refOSSystemVersionFromWMI.Value.Build
                            }
                        }
                    }
                    if ($refOSSystemVersionFromWMI.Value.Revision -ne -1) {
                        # Revision version obtained
                        if ($intOSRevisionCurrentLevelOfAccuracy -lt $intThisMethodRevisionLevelOfAccuracy) {
                            $intOSRevision = $refOSSystemVersionFromWMI.Value.Revision
                            $intOSRevisionCurrentLevelOfAccuracy = $intThisMethodRevisionLevelOfAccuracy
                        } elseif ($intOSRevisionCurrentLevelOfAccuracy -eq $intThisMethodRevisionLevelOfAccuracy) {
                            if ($refOSSystemVersionFromWMI.Value.Revision -gt $intOSRevision) {
                                $intOSRevision = $refOSSystemVersionFromWMI.Value.Revision
                            }
                        }
                    }
                }
            }
        }
    }

    # #############################################################################
    $intThisMethodNumber = 5 # (Version of the file
    #                          C:\Windows\Sysnative\ntoskrnl.exe or
    #                          C:\Windows\System32\ntoskrnl.exe)
    $intThisMethodMajorLevelOfAccuracy = 3
    $intThisMethodMinorLevelOfAccuracy = 3
    $intThisMethodBuildLevelOfAccuracy = 3 # (If Major < 10, 3/7; If Major = 10,
    #                                        Minor = 0, and Build < 18362, 3/7;
    #                                        else 2/7)
    $intThisMethodRevisionLevelOfAccuracy = 3

    # TODO: Implement this

    # #############################################################################
    $intThisMethodNumber = 6 #6a: "Product version" of
    #                             C:\Windows\Sysnative\kernel32.dll or
    #                             C:\Windows\System32\kernel32.dll
    $intThisMethodMajorLevelOfAccuracy = 7
    $intThisMethodMinorLevelOfAccuracy = 7
    $intThisMethodBuildLevelOfAccuracy = 7 # (If Major < 10, 7/7; If Major = 10,
    #                                        Minor = 0, and Build < 18362, 7/7;
    #                                        else 3/7)
    $intThisMethodRevisionLevelOfAccuracy = 4

    # TODO: Implement this

    # #############################################################################
    $intThisMethodNumber = 6 #6b: "Product version" of
    #                             C:\Windows\Sysnative\ntdll.dll or
    #                             C:\Windows\System32\ntdll.dll
    $intThisMethodMajorLevelOfAccuracy = 7
    $intThisMethodMinorLevelOfAccuracy = 7
    $intThisMethodBuildLevelOfAccuracy = 7 # (If Major < 10, 7/7; If Major = 10,
    #                                        Minor = 0, and Build < 18362, 7/7;
    #                                        else 3/7)
    $intThisMethodRevisionLevelOfAccuracy = 3

    # TODO: Implement this

    # #############################################################################
    $intThisMethodNumber = 6 #6c: "Product version" of C:\Windows\Sysnative\hal.dll
    #                             or C:\Windows\System32\hal.dll
    $intThisMethodMajorLevelOfAccuracy = 7
    $intThisMethodMinorLevelOfAccuracy = 7
    $intThisMethodBuildLevelOfAccuracy = 7 # (If Major < 10, 7/7; If Major = 10,
    #                                        Minor = 0, and Build < 18362, 7/7;
    #                                        else 3/7)
    $intThisMethodRevisionLevelOfAccuracy = 2

    # TODO: Implement this

    # #############################################################################
    $intThisMethodNumber = 7 #7a: File version of C:\Windows\Sysnative\kernel32.dll
    #                             or C:\Windows\System32\kernel32.dll
    $intThisMethodMajorLevelOfAccuracy = 3
    $intThisMethodMinorLevelOfAccuracy = 3
    $intThisMethodBuildLevelOfAccuracy = 3 # (If Major < 10, 3/7; If Major = 10,
    #                                        Minor = 0, and Build < 18362, 3/7;
    #                                        else 2/7)
    $intThisMethodRevisionLevelOfAccuracy = 2

    # TODO: Implement this

    # #############################################################################
    $intThisMethodNumber = 7 #7b: File version of C:\Windows\Sysnative\ntdll.dll or
    #                             C:\Windows\System32\ntdll.dll
    $intThisMethodMajorLevelOfAccuracy = 3
    $intThisMethodMinorLevelOfAccuracy = 3
    $intThisMethodBuildLevelOfAccuracy = 3 # (If Major < 10, 3/7; If Major = 10,
    #                                        Minor = 0, and Build < 18362, 3/7;
    #                                        else 2/7)
    $intThisMethodRevisionLevelOfAccuracy = 1

    # TODO: Implement this

    # #############################################################################
    $intThisMethodNumber = 7 #7c: File version of C:\Windows\Sysnative\hal.dll or
    #                             C:\Windows\System32\hal.dll
    $intThisMethodMajorLevelOfAccuracy = 3
    $intThisMethodMinorLevelOfAccuracy = 3
    $intThisMethodBuildLevelOfAccuracy = 3 # (If Major < 10, 3/7; If Major = 10,
    #                                        Minor = 0, and Build < 18362, 3/7;
    #                                        else 2/7)
    $intThisMethodRevisionLevelOfAccuracy = 1

    # TODO: Implement registry: https://superuser.com/a/1160428/334370
    # HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion ->
    #       CurrentMajorVersionNumber (DWORD, not tamper-proof, Windows 10 only)
    #       CurrentMinorVersionNumber (DWORD, not tamper-proof, Windows 10 only)
    #       CurrentBuildNumber (String, not tamper-proof)
    #       If successful:
    #       - Major version is supplied, but is NOT tamper-proof, and may be inaccurate if
    #         tampered (3/7)
    #       - Minor version is supplied, but is NOT tamper-proof, and may be inaccurate if
    #         tampered (3/7)
    #       - Build is supplied, but is NOT tamper-proof, and may be inaccurate if tampered
    #         (3/7)
    # 9. (Revision number, Windows 10 only):
    #       HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion ->
    #       UBR (DWORD, not tamper-proof)
    #       If successful:
    #       - Revision is NOT tamper-proof, and may be inaccurate if tampered. (3/7)
    #
    #
    # Other reference:
    #   https://gist.github.com/SevenLayerJedi/c0415c03cab1ff51aa49d2f4d708f265

    if ($intFunctionReturn -ge 0) {
        # No error has occurred
        # Check for failures to deliver required accuracy levels
        if ($intWorkingAccuracyTargetForMajor -ge 0) {
            $intReturnMultiplier = 0x00000800
            if ($intOSMajorCurrentLevelOfAccuracy -eq -1 -or $intOSMajorCurrentLevelOfAccuracy -lt $intWorkingAccuracyTargetForMajor) {
                if ($intFunctionReturn -gt 0) {
                    $intFunctionReturn = 0
                }
                $intFunctionReturn = $intFunctionReturn + (-1 * $intReturnMultiplier)
            }
        }
        if ($intWorkingAccuracyTargetForMinor -ge 0) {
            $intReturnMultiplier = 0x00000400
            if ($intOSMinorCurrentLevelOfAccuracy -eq -1 -or $intOSMinorCurrentLevelOfAccuracy -lt $intWorkingAccuracyTargetForMinor) {
                if ($intFunctionReturn -gt 0) {
                    $intFunctionReturn = 0
                }
                $intFunctionReturn = $intFunctionReturn + (-1 * $intReturnMultiplier)
            }
        }
        if ($intWorkingAccuracyTargetForBuild -ge 1) {
            $intReturnMultiplier = 0x00000200
            if ($intOSBuildCurrentLevelOfAccuracy -eq -1 -or $intOSBuildCurrentLevelOfAccuracy -lt $intWorkingAccuracyTargetForBuild) {
                if ($intFunctionReturn -gt 0) {
                    $intFunctionReturn = 0
                }
                $intFunctionReturn = $intFunctionReturn + (-1 * $intReturnMultiplier)
            }
        }
        if ($intWorkingAccuracyTargetForRevision -ge 1) {
            $intReturnMultiplier = 0x00000100
            if ($intOSRevisionCurrentLevelOfAccuracy -eq -1 -or $intOSRevisionCurrentLevelOfAccuracy -lt $intWorkingAccuracyTargetForRevision) {
                if ($intFunctionReturn -gt 0) {
                    $intFunctionReturn = 0
                }
                $intFunctionReturn = $intFunctionReturn + (-1 * $intReturnMultiplier)
            }
        }
    }

    if ($intFunctionReturn -ge 0) {
        # No error has occurred
        # Build positive return code that conveys accuracy levels
        $intReturnMultiplier = 0x01000000
        if ($intOSMajorCurrentLevelOfAccuracy -eq -1) {
            $intTempLevelOfAccuracy = 0
        } else {
            $intTempLevelOfAccuracy = $intOSMajorCurrentLevelOfAccuracy
        }
        $intFunctionReturn = $intFunctionReturn + ($intReturnMultiplier * $intTempLevelOfAccuracy)

        $intReturnMultiplier = 0x00100000
        if ($intOSMinorCurrentLevelOfAccuracy -eq -1) {
            $intTempLevelOfAccuracy = 0
        } else {
            $intTempLevelOfAccuracy = $intOSMinorCurrentLevelOfAccuracy
        }
        $intFunctionReturn = $intFunctionReturn + ($intReturnMultiplier * $intTempLevelOfAccuracy)

        $intReturnMultiplier = 0x00010000
        if ($intOSBuildCurrentLevelOfAccuracy -eq -1) {
            $intTempLevelOfAccuracy = 0
        } else {
            $intTempLevelOfAccuracy = $intOSBuildCurrentLevelOfAccuracy
        }
        $intFunctionReturn = $intFunctionReturn + ($intReturnMultiplier * $intTempLevelOfAccuracy)

        $intReturnMultiplier = 0x00001000
        if ($intOSRevisionCurrentLevelOfAccuracy -eq -1) {
            $intTempLevelOfAccuracy = 0
        } else {
            $intTempLevelOfAccuracy = $intOSRevisionCurrentLevelOfAccuracy
        }
        $intFunctionReturn = $intFunctionReturn + ($intReturnMultiplier * $intTempLevelOfAccuracy)
    }

    if ($intFunctionReturn -ge 0) {
        # No error has occurred
        # Build version string to return
        if ($intWorkingAccuracyTargetForMajor -eq -1) {
            # Build or Revision, only
            if ($intWorkingAccuracyTargetForBuild -ge 1) {
                $strOSVersionStaging = $intOSBuild.ToString()
            } else {
                $strOSVersionStaging = $intOSRevision.ToString()
            }
        } else {
            $strOSVersionStaging = $intOSMajor.ToString() + '.' + $intOSMinor.ToString()
            if ($intOSBuildCurrentLevelOfAccuracy -ge 1) {
                $strOSVersionStaging = $strOSVersionStaging + '.' + $intOSBuild.ToString()
                if ($intOSRevisionCurrentLevelOfAccuracy -ge 1) {
                    $strOSVersionStaging = $strOSVersionStaging + '.' + $intOSRevision.ToString()
                    $ReferenceToSystemVersion.Value = New-Object -TypeName 'System.Version' -ArgumentList @($intOSMajor, $intOSMinor, $intOSBuild, $intOSRevision)
                } else {
                    $ReferenceToSystemVersion.Value = New-Object -TypeName 'System.Version' -ArgumentList @($intOSMajor, $intOSMinor, $intOSBuild)
                }
            } else {
                $ReferenceToSystemVersion.Value = New-Object -TypeName 'System.Version' -ArgumentList @($intOSMajor, $intOSMinor)
            }
        }
    }

    if ($intFunctionReturn -ge 0) {
        $ReferenceToStringVersion.Value = $strOSVersionStaging
    }

    return $intFunctionReturn
}
