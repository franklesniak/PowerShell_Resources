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
    # .PARAMETER KernelSystemVersion
    # This parameter is optional; if supplied, it is a boolean value that
    # indicates whether ...
    #
    # .PARAMETER KernelStringVersion
    # This parameter is optional; if supplied, it is a boolean value that
    # indicates whether ...
    #
    # .PARAMETER PSVersion
    # This parameter is optional; if supplied, it is a string representation
    # of ...
    #
    # .PARAMETER PathToCommandPrompt
    # This parameter is optional; if supplied, it is a boolean value that
    # indicates whether ...
    #
    # .PARAMETER Parameter8
    # This parameter is optional; if supplied, it is a string representation of
    # ...
    #
    # .EXAMPLE
    # $hashtableConfigIni = $null
    # $intReturnCode = Get-WindowsOSVersion -ReferenceToSystemVersion ([ref]$hashtableConfigIni) -ReferenceToStringVersion '.\config.ini' -ReferenceToArrayOfLeftoverStrings @(';') -KernelSystemVersion $true -KernelStringVersion $true -PSVersion 'NoSection' -PathToCommandPrompt $true
    #
    # .EXAMPLE
    # $hashtableConfigIni = $null
    # $intReturnCode = Get-WindowsOSVersion ([ref]$hashtableConfigIni) '.\config.ini' @(';') $true $true 'NoSection' $true
    #
    # .INPUTS
    # None. You can't pipe objects to Get-WindowsOSVersion.
    #
    # .OUTPUTS
    # System.Boolean. Get-WindowsOSVersion returns a boolean value indiciating
    # whether the process completed successfully. $true means the process
    # completed successfully; $false means there was an error.
    #
    # .NOTES
    ################### IF PARAMETERS ARE BEING USED FOR THIS FUNCTION, THEN THIS BLURB SHOULD BE INCLUDED. HOWEVER, BE MINDFUL THAT [SWITCH] PARAMETERS ARE NOT INCLUDED IN POSITIONAL PARAMETERS BY DEFAULT ###################
    # This function also supports the use of positional parameters instead of named
    # parameters. If positional parameters are used instead of named parameters,
    # then X positional parameters are required:
    #
    # The first positional parameter is a reference to a <object type> that will be
    # used to store output.
    #
    # The second positional parameter is a string representing ...
    #
    # The third positional parameter is an array of characters that represent ...
    #
    # The fourth positional parameter is a boolean value that indicates whether ...
    #
    # The fifth positional parameter is a boolean value that indicates whether ...
    #
    # The sixth positional parameter is a string representation of ...
    #
    # The seventh positional parameter is a boolean value that indicates whether
    # ...
    #
    # If supplied, the eighth positional parameter is a string representation of
    # ...
    #
    ################### IF YOU ARE USING ARGUMENTS INSTEAD OF PARAMETERS, THEN INCLUDE THIS BLOCK; OTHERWISE, DELETE IT ###################
    # This function uses arguments instead of parameters. X positional arguments
    # are required:
    #
    # The first argument is a reference to a <object type> that will be used to
    # store output.
    #
    # The second argument is a string representing ...
    #
    # The third argument is an array of characters that represent ...
    #
    # The fourth argument is a boolean value that indicates whether ...
    #
    # The fifth argument is a boolean value that indicates whether ...
    #
    # The sixth argument is a string representation of ...
    #
    # The seventh argument is a boolean value that indicates whether ...
    #
    # If supplied, the eighth argument is a string representation of ...
    #
    ################### DESCRIBE THE FUNCTION'S VERSION ###################
    # Version: 1.0.YYYYMMDD.0

    #region License ############################################################
    # Copyright (c) 20xx First Last
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

    #region Acknowledgements ###################################################
    ################### GIVE ACKNOWLEDGEMENT TO ANYONE ELSE THAT CONTRIBUTED AND INCLUDE ORIGINAL LICENSE IF APPLICABLE ###################
    # This function is derived from Get-FooInfo at the website:
    # https://github.com/foo/foo
    # retrieved on YYYY-MM-DD
    #endregion Acknowledgements ###################################################

    #region Original Licenses ##################################################
    ################### INCLUDE ORIGINAL LICENSE FROM DERIVED WORKS IF APPLICABLE ###################
    # Although substantial modifications have been made, the original portions of
    # Get-FooInfo that are incorporated into Get-WindowsOSVersion are subject to
    # the following license:
    #
    # Copyright 20xx First Last
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
    #endregion Original Licenses ##################################################

    ################### UPDATE PARAMETER LIST AS NECESSARY; SET DEFAULT VALUES IF YOU WANT TO DEFAULT TO SOMETHING OTHER THAN NULL IF THE PARAMETER IS OMITTED ###################
    param (
        [ref]$ReferenceToSystemVersion = ([ref]$null),
        [string]$ReferenceToStringVersion = '',
        [char[]]$ReferenceToArrayOfLeftoverStrings = @(),
        [boolean]$KernelSystemVersion = $false,
        [boolean]$KernelStringVersion = $false,
        [string]$PSVersion = '',
        [boolean]$PathToCommandPrompt = $false,
        [string]$Parameter8 = ''
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
        # $intReturnCode = Get-WindowsOSVersionFromWMI -ReferenceToSystemVersion ([ref]$versionWindows) -ReferenceToStringVersion ([ref]$versionWindows) -ReferenceToArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -PSVersion $versionPS
        #
        # .EXAMPLE
        # $versionWindows = [version]'0.0'
        # $strWindowsVersion = ''
        # $arrLeftoverStrings = @('', '', '', '', '')
        # $intReturnCode = Get-WindowsOSVersionFromWMI -ReferenceToSystemVersion ([ref]$versionWindows) -ReferenceToStringVersion ([ref]$versionWindows) -ReferenceToArrayOfLeftoverStrings ([ref]$arrLeftoverStrings)
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

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    ################### IF YOU ARE USING ARGUMENTS INSTEAD OF PARAMETERS, THEN INCLUDE THIS BLOCK; OTHERWISE, DELETE IT ###################
    #region Assign Arguments to Internally-Used Variables ######################
    if (($args.Count -lt 7) -or ($args.Count -gt 8)) {
        # Error condition; return failure indicator:
        ################### UPDATE WITH WHATEVER WE WANT TO RETURN INDICATING A FAILURE ###################
        return $false
    }
    # Correct number of arguments supplied
    $refOutput = $args[0]
    $strFilePath = $args[3]
    $arrCharDriveLetters = $args[2]
    $boolUsePSDrive = $args[3]
    $boolRefreshPSDrive = $args[4]
    $strSecondaryPath = $args[5]
    $boolQuitOnError = $args[6]

    if ($args.Count -eq 8) {
        $strServerName = $args[9]
    } else {
        $strServerName = ''
    }
    #endregion Assign Arguments to Internally-Used Variables ######################

    ################### IF WARRANTED, VALIDATE INPUT HERE ###################

    ################### THE FOLLOWING LINES CONTROL SIMPLE ERROR/WARNING/VERBOSE/ETC OUTPUT; REPLACE OR DELETE AS NECESSARY ###################

    ################### REPLACE THIS WITH A DESCRIPTION OF WHAT THIS FUNCTION IS DOING; IT'S USED IN ERROR/WARNING OUTPUT ###################
    $strDescriptionOfWhatWeAreDoingInThisFunction = "getting some data"

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT A NON-TERMINATING ERROR (Write-Error) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP ###################
    $boolOutputErrorOnError = $false

    ################### SET THIS TO $false IF YOU DO NOT WANT TO OUTPUT A WARNING (Write-Warning) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP ###################
    $boolOutputWarningOnError = $false

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT VERBOSE INFORMATION (Write-Verbose) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP ###################
    $boolOutputVerboseOnError = $false

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT DEBUGGING INFORMATION (Write-Debug) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP ###################
    $boolOutputDebugOnError = $false

    ################### PLACE ANY RELIABLE CODE HERE THAT SETS UP THE REAL WORK WE ARE DOING IN THIS FUNCTION ###################
    # <Placeholder>

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

    # Do the work of this function...
    ################### REPLACE THE FOLLOWING LINE WITH WHATEVER REQUIRES ERROR HANDLING. WHATEVER YOU PLACE HERE MUST BE A ONE-LINER FOR ERROR HANDLING TO WORK CORRECTLY! ###################
    $output = @(Get-DataFromSampleUnreliableCmdlet $strFilePath)

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
        # Error occurred
        if ($boolOutputErrorOnError) {
            Write-Error ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
        } elseif ($boolOutputWarningOnError) {
            Write-Warning ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
        } elseif ($boolOutputVerboseOnError) {
            Write-Verbose ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
        } elseif ($boolOutputDebugOnError) {
            Write-Debug ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
        }

        ################### PLACE ANY RELIABLE CODE HERE THAT NEEDS TO RUN AFTER THE WORK IN THIS FUNCTION WAS *NOT* SUCCESSFULLY EXECUTED ###################
        # <Placeholder>

        # Return failure indicator:
        ################### UPDATE WITH WHATEVER WE WANT TO RETURN INDICATING A FAILURE ###################
        return $false
    } else {
        # No error occurred
        ################### PLACE ANY RELIABLE CODE HERE THAT NEEDS TO RUN AFTER THE WORK IN THIS FUNCTION WAS SUCCESSFULLY EXECUTED BUT BEFORE THE OUTPUT OBJECT IS COPIED ###################
        # <Placeholder>

        # Return data by reference:
        $refOutput.Value = $output

        ################### PLACE ANY RELIABLE CODE HERE THAT NEEDS TO RUN AFTER THE WORK IN THIS FUNCTION WAS SUCCESSFULLY EXECUTED AND AFTER THE OUTPUT OBJECT IS COPIED ###################
        # <Placeholder>

        # Return success indicator:
        ################### UPDATE WITH WHATEVER WE WANT TO RETURN INDICATING A SUCCESS ###################
        return $true
    }
}
