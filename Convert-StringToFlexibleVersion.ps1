function Convert-StringToFlexibleVersion {
    # .SYNOPSIS
    # Converts a string to a version object. However, when the string contains
    # characters not allowed in a version object, this function will attempt to
    # convert the string to a version object by removing the characters that are
    # not allowed, identifying the portions of the version object that are
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
    # $arrLeftoverStrings = @('','','','','')
    # $strVersion = '1.2.3.4'
    # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
    # # $intReturnCode will be 0 because the string is in a valid format for a
    # # version object.
    # # $version will be a System.Version object with Major=1, Minor=2,
    # # Build=3, Revision=4.
    # # All strings in $arrLeftoverStrings will be empty.
    #
    # .EXAMPLE
    # $version = $null
    # $arrLeftoverStrings = @('','','','','')
    # $strVersion = '1.2.3.4-beta3'
    # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
    # # $intReturnCode will be 4 because the string is not in a valid format
    # # for a version object. The 4 indicates that the revision version portion
    # # of the string could not be converted to a version object.
    # # $version will be a System.Version object with Major=1, Minor=2,
    # # Build=3, Revision=4.
    # # $arrLeftoverStrings[3] will be 'beta3'. All other elements of
    # # $arrLeftoverStrings will be empty.
    #
    # .EXAMPLE
    # $version = $null
    # $arrLeftoverStrings = @('','','','','')
    # $strVersion = '1.2.2147483700.4'
    # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
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
    # $arrLeftoverStrings = @('','','','','')
    # $strVersion = '1.2.2147483700-beta5.4'
    # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
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
    # $arrLeftoverStrings = @('','','','','')
    # $strVersion = '1.2.3.4.5'
    # $intReturnCode = Convert-StringToFlexibleVersion -ReferenceArrayOfLeftoverStrings ([ref]$arrLeftoverStrings) -StringToConvert $strVersion
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
    # Version: 1.0.20250215.0

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

    #region FunctionsToSupportErrorHandling ################################
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
        # # Set ErrorActionPreference to SilentlyContinue; this will suppress
        # # error output. Terminating errors will not output anything, kick
        # # to the empty trap statement and then continue on. Likewise, non-
        # # terminating errors will also not output anything, but they do not
        # # kick to the trap statement; they simply continue on.
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
        #     # If $refLastKnownError is non-null and $refNewestCurrentError
        #     # is null, no error.
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
    #endregion FunctionsToSupportErrorHandling ################################

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
            # # Set ErrorActionPreference to SilentlyContinue; this will suppress
            # # error output. Terminating errors will not output anything, kick
            # # to the empty trap statement and then continue on. Likewise, non-
            # # terminating errors will also not output anything, but they do not
            # # kick to the trap statement; they simply continue on.
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
            #     # If $refLastKnownError is non-null and $refNewestCurrentError
            #     # is null, no error.
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

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    $boolResult = Convert-StringToVersionSafely -ReferenceToVersionObject $ReferenceToVersionObject -StringToConvert $StringToConvert

    if ($boolResult) {
        return 0
    }

    # If we are still here, the conversion was not successful.






    

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
