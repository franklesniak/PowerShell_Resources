#region License ####################################################################
# Copyright 2025 Frank Lesniak
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be included in all copies
# or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#endregion License ####################################################################

# Function template version: 2.0.20251228.0

# TEMPLATE FILE NOTICE:
# This is a template file. Before use, you MUST:
# 1. Replace all placeholder comments (marked with TODO:)
# 2. Replace generic parameter names (Parameter1, Parameter2, etc.) with descriptive names
# 3. Update all documentation with actual function-specific content
# 4. Replace placeholder code with actual implementation
# 5. Update version number to current date (YYYYMMDD format)
# 6. Update function name to match your use case
# 7. Update licensing information if this will be distributed
# 8. Remove this notice once the template has been fully customized

function Get-DataFromCloudServiceCmdletRobust {
    # .SYNOPSIS
    # Very brief description of the function here. Limit the character width to
    # 88 characters if the function will not be nested within another function,
    # 84 characters if it will be nested once, 80 characters if it will be
    # nested twice, etc.
    #
    # .DESCRIPTION
    # Longer-form description of the function here.
    #
    # .PARAMETER Parameter1
    # This parameter is required; it is a reference to a <object type> that
    # will be used to store output.
    #
    # .PARAMETER CurrentAttemptNumber
    # This parameter is required; it is an integer indicating the current attempt
    # number. When calling this function for the first time, it should be 1.
    #
    # .PARAMETER MaxAttempts
    # This parameter is required; it is an integer representing the maximum number
    # of attempts that the function will observe before giving up.
    #
    # .PARAMETER Parameter4
    # This parameter is required; it is a string representing ...
    #
    # .PARAMETER Parameter5
    # This parameter is optional; if supplied, it is an array of characters
    # that represent ...
    #
    # .PARAMETER Parameter6
    # This parameter is optional; if supplied, it is a boolean value that
    # indicates whether ...
    #
    # .PARAMETER Parameter7
    # This parameter is optional; if supplied, it is a boolean value that
    # indicates whether ...
    #
    # .PARAMETER Parameter8
    # This parameter is optional; if supplied, it is a string representation
    # of ...
    #
    # .PARAMETER Parameter9
    # This parameter is optional; if supplied, it is a boolean value that
    # indicates whether ...
    #
    # .PARAMETER Parameter10
    # This parameter is optional; if supplied, it is a string representation of
    # ...
    #
    # .EXAMPLE
    # $hashtableConfigIni = $null
    # $intReturnCode = Get-DataFromCloudServiceCmdletRobust -Parameter1 ([ref]$hashtableConfigIni) -CurrentAttemptNumber 1 -MaxAttempts 4 -Parameter4 '.\config.ini' -Parameter5 @(';') -Parameter6 $true -Parameter7 $true -Parameter8 'NoSection' -Parameter9 $true
    #
    # .EXAMPLE
    # $hashtableConfigIni = $null
    # $intReturnCode = Get-DataFromCloudServiceCmdletRobust ([ref]$hashtableConfigIni) 1 4 '.\config.ini' @(';') $true $true 'NoSection' $true
    #
    # .INPUTS
    # None. You can't pipe objects to Get-DataFromCloudServiceCmdletRobust.
    #
    # .OUTPUTS
    # System.Int32. Get-DataFromCloudServiceCmdletRobust returns an integer status
    # code indicating whether the process completed successfully.
    # - 0 indicates full success
    # - -1 indicates failure
    #
    # .NOTES
    # TODO: IF PARAMETERS ARE BEING USED FOR THIS FUNCTION, THEN THIS BLURB SHOULD BE INCLUDED. HOWEVER, BE MINDFUL THAT [SWITCH] PARAMETERS ARE NOT INCLUDED IN POSITIONAL PARAMETERS BY DEFAULT
    # This function also supports the use of positional parameters instead of named
    # parameters. If positional parameters are used instead of named parameters,
    # then X positional parameters are required:
    #
    # The first positional parameter is a reference to a <object type> that will be
    # used to store output.
    #
    # The second positional parameter is an integer indicating the current attempt
    # number. When calling this function for the first time, it should be 1.
    #
    # The third positional parameter is an integer representing the maximum number
    # of attempts that the function will observe before giving up.
    #
    # The fourth positional parameter is a string representing ...
    #
    # The fifth positional parameter is an array of characters that represent ...
    #
    # The sixth positional parameter is a boolean value that indicates whether ...
    #
    # The seventh positional parameter is a boolean value that indicates whether
    # ...
    #
    # The eighth positional parameter is a string representation of ...
    #
    # The nineth positional parameter is a boolean value that indicates whether ...
    #
    # If supplied, the tenth positional parameter is a string representation of ...
    #
    # TODO: IF YOU ARE USING ARGUMENTS INSTEAD OF PARAMETERS, THEN INCLUDE THIS BLOCK; OTHERWISE, DELETE IT
    # This function uses arguments instead of parameters. X positional arguments
    # are required:
    #
    # The first argument is a reference to a <object type> that will be used to
    # store output.
    #
    # The second argument is an integer indicating the current attempt number. When
    # calling this function for the first time, it should be 1.
    #
    # The third argument is an integer representing the maximum number of attempts
    # that the function will observe before giving up.
    #
    # The fourth argument is a string representing ...
    #
    # The fifth argument is an array of characters that represent ...
    #
    # The sixth argument is a boolean value that indicates whether ...
    #
    # The seventh argument is a boolean value that indicates whether ...
    #
    # The eighth argument is a string representation of ...
    #
    # The ninth argument is a boolean value that indicates whether ...
    #
    # If supplied, the tenth argument is a string representation of ...
    #
    # TODO: DESCRIBE THE FUNCTION'S VERSION
    # This function supports Windows PowerShell 1.0 with .NET Framework 2.0 or
    # newer, newer versions of Windows PowerShell (at least up to and including
    # Windows PowerShell 5.1 with .NET Framework 4.8 or newer), PowerShell Core
    # 6.x, and PowerShell 7.x. This function supports Windows and, when run on
    # PowerShell Core 6.x or PowerShell 7.x, also supports macOS and Linux.
    #
    # Version: 1.0.YYYYMMDD.0

    # TODO: UPDATE PARAMETER LIST AS NECESSARY; SET DEFAULT VALUES IF YOU WANT TO DEFAULT TO SOMETHING OTHER THAN NULL IF THE PARAMETER IS OMITTED
    param (
        [ref]$Parameter1 = ([ref]$null),
        [int]$CurrentAttemptNumber = 1,
        [int]$MaxAttempts = 1,
        [string]$Parameter4 = '',
        [char[]]$Parameter5 = @(),
        [boolean]$Parameter6 = $false,
        [boolean]$Parameter7 = $false,
        [string]$Parameter8 = '',
        [boolean]$Parameter9 = $false,
        [string]$Parameter10 = ''
    )

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
    # TODO: GIVE ACKNOWLEDGEMENT TO ANYONE ELSE THAT CONTRIBUTED AND INCLUDE ORIGINAL LICENSE IF APPLICABLE
    # This function is derived from Get-FooInfo at the website:
    # https://github.com/foo/foo
    # retrieved on YYYY-MM-DD
    #endregion Acknowledgements ###################################################

    #region Original Licenses ##################################################
    # TODO: INCLUDE ORIGINAL LICENSE FROM DERIVED WORKS IF APPLICABLE
    # Although substantial modifications have been made, the original portions of
    # Get-FooInfo that are incorporated into Get-DataFromCloudServiceCmdletRobust
    # are subject to the following license:
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

    #region FunctionsToSupportErrorHandling ####################################
    function Get-ReferenceToLastError {
        # .SYNOPSIS
        # Gets a reference (memory pointer) to the last error that
        # occurred.
        #
        # .DESCRIPTION
        # Returns a reference (memory pointer) to $null ([ref]$null) if no
        # errors on the $error stack; otherwise, returns a reference to
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
        # ([ref]$null) if there are no errors on the $error stack.
        #
        # .NOTES
        # This function accepts no parameters.
        #
        # This function is compatible with Windows PowerShell 1.0+ (with
        # .NET Framework 2.0 or newer), PowerShell Core 6.x, and PowerShell
        # 7.x on Windows, macOS, and Linux.
        #
        # Design Note: This function returns a [ref] object directly rather
        # than following the author's standard v1.0 pattern of returning an
        # integer status code. This design is intentional, as the
        # function's sole purpose is to provide a reference for error
        # tracking. Requiring a [ref] parameter would add unnecessary
        # complexity to the calling pattern.
        #
        # Version: 2.0.20251226.0

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

        param()

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
        # .EXAMPLE
        # # This example demonstrates the function returning $false when no
        # # error occurs during the operation. A command that executes
        # # successfully is run, and the function correctly identifies that
        # # no error occurred.
        #
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
        # # Set ErrorActionPreference to SilentlyContinue
        # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        #
        # # Do something that will succeed
        # Get-Item -Path $env:TEMP
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
        #     # No error occurred - this branch executes because Get-Item
        #     # succeeded
        # }
        #
        # .EXAMPLE
        # # This example demonstrates a scenario where
        # # ReferenceToEarlierError is non-null but ReferenceToLaterError
        # # is null, simulating that $Error was cleared. The function
        # # returns $false because this does not indicate a new error
        # # occurred.
        #
        # # Intentionally empty trap statement to prevent terminating errors
        # # from halting processing
        # trap { }
        #
        # # Generate an error so that $Error has an entry
        # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        # Get-Item -Path 'C:\DoesNotExist-ErrorClearing-Example.txt'
        # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::Continue
        #
        # # Capture reference to the error
        # if ($Error.Count -gt 0) {
        #     $refLastKnownError = ([ref]($Error[0]))
        # } else {
        #     $refLastKnownError = ([ref]$null)
        # }
        #
        # # Clear the $Error array
        # $Error.Clear()
        #
        # # Capture reference after clearing (will be null)
        # if ($Error.Count -gt 0) {
        #     $refNewestCurrentError = ([ref]($Error[0]))
        # } else {
        #     $refNewestCurrentError = ([ref]$null)
        # }
        #
        # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
        #     # Error occurred
        # } else {
        #     # No error occurred - this branch executes because clearing
        #     # $Error does not indicate a new error
        # }
        #
        # .EXAMPLE
        # # This example demonstrates using the function with positional
        # # parameters instead of named parameters. Both approaches work
        # # correctly.
        #
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
        # # Store current error preference
        # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
        #
        # # Set ErrorActionPreference to SilentlyContinue
        # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        #
        # # Do something that might trigger an error
        # Get-Item -Path 'C:\MayNotExist-Positional-Example.txt'
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
        # # Note: Using positional parameters - first parameter is
        # # ReferenceToEarlierError, second is ReferenceToLaterError
        # if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
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
        # This function supports Windows PowerShell 1.0 with .NET Framework
        # 2.0 or newer, newer versions of Windows PowerShell (at least up
        # to and including Windows PowerShell 5.1 with .NET Framework 4.8
        # or newer), PowerShell Core 6.x, and PowerShell 7.x. This function
        # supports Windows and, when run on PowerShell Core 6.x or
        # PowerShell 7.x, also supports macOS and Linux.
        #
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
        # Version: 2.0.20251226.0

        param (
            [ref]$ReferenceToEarlierError = ([ref]$null),
            [ref]$ReferenceToLaterError = ([ref]$null)
        )

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

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    # TODO: IF YOU ARE USING ARGUMENTS INSTEAD OF PARAMETERS, THEN INCLUDE THIS BLOCK; OTHERWISE, DELETE IT
    #region Assign Arguments to Internally-Used Variables ######################
    if (($args.Count -lt 9) -or ($args.Count -gt 10)) {
        # Error condition; return failure indicator:
        # TODO: UPDATE WITH WHATEVER WE WANT TO RETURN INDICATING A FAILURE
        return -1
    }
    # Correct number of arguments supplied
    $refOutput = $args[0]
    $intCurrentAttemptNumber = $args[1]
    $intMaximumAttempts = $args[2]
    $strFilePath = $args[3]
    $arrCharDriveLetters = $args[4]
    $boolUsePSDrive = $args[5]
    $boolRefreshPSDrive = $args[6]
    $strSecondaryPath = $args[7]
    $boolQuitOnError = $args[8]

    if ($args.Count -eq 10) {
        $strServerName = $args[9]
    } else {
        $strServerName = ''
    }
    #endregion Assign Arguments to Internally-Used Variables ######################

    # TODO: IF WARRANTED, VALIDATE INPUT HERE

    # TODO: THE FOLLOWING LINES CONTROL SIMPLE ERROR/WARNING/VERBOSE/ETC OUTPUT; REPLACE OR DELETE AS NECESSARY

    # TODO: REPLACE THIS WITH A DESCRIPTION OF WHAT THIS FUNCTION IS DOING; IT'S USED IN ERROR/WARNING OUTPUT
    $strDescriptionOfWhatWeAreDoingInThisFunction = "getting some data"

    # TODO: SET THIS TO $true IF YOU WANT TO OUTPUT A NON-TERMINATING ERROR (Write-Error) WHEN THE FUNCTION RETRIES
    $boolOutputErrorOnFunctionRetry = $false

    # TODO: SET THIS TO $false IF YOU DO NOT WANT TO OUTPUT A WARNING (Write-Warning) WHEN THE FUNCTION RETRIES
    $boolOutputWarningOnFunctionRetry = $true

    # TODO: SET THIS TO $true IF YOU WANT TO OUTPUT VERBOSE INFORMATION (Write-Verbose) WHEN THE FUNCTION RETRIES
    $boolOutputVerboseOnFunctionRetry = $false

    # TODO: SET THIS TO $true IF YOU WANT TO OUTPUT DEBUGGING INFORMATION (Write-Debug) WHEN THE FUNCTION RETRIES
    $boolOutputDebugOnFunctionRetry = $false

    # TODO: SET THIS TO $true IF YOU WANT TO OUTPUT A NON-TERMINATING ERROR (Write-Error) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP
    $boolOutputErrorOnFunctionMaximumAttemptsExceeded = $true

    # TODO: SET THIS TO $false IF YOU DO NOT WANT TO OUTPUT A WARNING (Write-Warning) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP
    $boolOutputWarningOnFunctionMaximumAttemptsExceeded = $false

    # TODO: SET THIS TO $true IF YOU WANT TO OUTPUT VERBOSE INFORMATION (Write-Verbose) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP
    $boolOutputVerboseOnFunctionMaximumAttemptsExceeded = $false

    # TODO: SET THIS TO $true IF YOU WANT TO OUTPUT DEBUGGING INFORMATION (Write-Debug) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP
    $boolOutputDebugOnFunctionMaximumAttemptsExceeded = $false

    # TODO: PLACE ANY RELIABLE CODE HERE THAT SETS UP THE REAL WORK WE ARE DOING IN THIS FUNCTION
    # TODO: Add initialization code here

    # Retrieve the newest error on the stack prior to doing work
    $refLastKnownError = Get-ReferenceToLastError

    # Store current error preference; we will restore it after we do the work of
    # this function
    $actionpreferenceFormerErrorPreference = $global:ErrorActionPreference

    # Set ErrorActionPreference to SilentlyContinue; this will suppress error
    # output. Terminating errors will not output anything, kick to the empty trap
    # statement and then continue on. Likewise, non-terminating errors will also
    # not output anything, but they do not kick to the trap statement; they simply
    # continue on.
    $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    # Do the work of this function...
    # TODO: REPLACE THE FOLLOWING LINE WITH WHATEVER REQUIRES ERROR HANDLING. WHATEVER YOU PLACE HERE MUST BE A ONE-LINER FOR ERROR HANDLING TO WORK CORRECTLY!
    $arrOutput = @(Get-DataFromCloudServiceCmdlet $objPlaceHolderInputObject)

    # Restore the former error preference
    $global:ErrorActionPreference = $actionpreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
        # Error occurred
        if ($CurrentAttemptNumber -lt $MaxAttempts) {
            if ($boolOutputErrorOnFunctionRetry) {
                Write-Error ("An error occurred {0}. Waiting for {1} seconds, then retrying..." -f $strDescriptionOfWhatWeAreDoingInThisFunction, [string]([math]::Pow(2, $CurrentAttemptNumber)))
            } elseif ($boolOutputWarningOnFunctionRetry) {
                Write-Warning ("An error occurred {0}. Waiting for {1} seconds, then retrying..." -f $strDescriptionOfWhatWeAreDoingInThisFunction, [string]([math]::Pow(2, $CurrentAttemptNumber)))
            } elseif ($boolOutputVerboseOnFunctionRetry) {
                Write-Verbose ("An error occurred {0}. Waiting for {1} seconds, then retrying..." -f $strDescriptionOfWhatWeAreDoingInThisFunction, [string]([math]::Pow(2, $CurrentAttemptNumber)))
            } elseif ($boolOutputDebugOnFunctionRetry) {
                Write-Debug ("An error occurred {0}. Waiting for {1} seconds, then retrying..." -f $strDescriptionOfWhatWeAreDoingInThisFunction, [string]([math]::Pow(2, $CurrentAttemptNumber)))
            }
            Start-Sleep -Seconds ([math]::Pow(2, $CurrentAttemptNumber))

            # TODO: REPLACE THIS CALL WITH A RECURSIVE CALL TO THIS SAME FUNCTION; PAY ATTENTION TO THE PARAMETERS
            $objResultIndicator = Get-DataFromCloudServiceCmdletRobust -Parameter1 $refOutput -CurrentAttemptNumber ($CurrentAttemptNumber + 1) -MaxAttempts $MaxAttempts -Parameter4 $strFilePath -Parameter5 $arrCharDriveLetters -Parameter6 $boolUsePSDrive -Parameter7 $boolRefreshPSDrive -Parameter8 $strSecondaryPath -Parameter9 $boolQuitOnError -Parameter10 $strServerName
            return $objResultIndicator
        } else {
            # Number of attempts exceeded maximum
            if ($boolOutputErrorOnFunctionMaximumAttemptsExceeded) {
                if ($MaxAttempts -ge 2) {
                    Write-Error ("An error occurred {0}. Giving up after too many attempts!" -f $strDescriptionOfWhatWeAreDoingInThisFunction)
                } else {
                    Write-Error ("An error occurred {0}." -f $strDescriptionOfWhatWeAreDoingInThisFunction)
                }
            } elseif ($boolOutputWarningOnFunctionMaximumAttemptsExceeded) {
                if ($MaxAttempts -ge 2) {
                    Write-Warning ("An error occurred {0}. Giving up after too many attempts!" -f $strDescriptionOfWhatWeAreDoingInThisFunction)
                } else {
                    Write-Warning ("An error occurred {0}." -f $strDescriptionOfWhatWeAreDoingInThisFunction)
                }
            } elseif ($boolOutputVerboseOnFunctionMaximumAttemptsExceeded) {
                if ($MaxAttempts -ge 2) {
                    Write-Verbose ("An error occurred {0}. Giving up after too many attempts!" -f $strDescriptionOfWhatWeAreDoingInThisFunction)
                } else {
                    Write-Verbose ("An error occurred {0}." -f $strDescriptionOfWhatWeAreDoingInThisFunction)
                }
            } elseif ($boolOutputDebugOnFunctionMaximumAttemptsExceeded) {
                if ($MaxAttempts -ge 2) {
                    Write-Debug ("An error occurred {0}. Giving up after too many attempts!" -f $strDescriptionOfWhatWeAreDoingInThisFunction)
                } else {
                    Write-Debug ("An error occurred {0}." -f $strDescriptionOfWhatWeAreDoingInThisFunction)
                }
            }

            # TODO: PLACE ANY RELIABLE CODE HERE THAT NEEDS TO RUN AFTER THE WORK IN THIS FUNCTION WAS *NOT* SUCCESSFULLY EXECUTED
            # TODO: Add failure cleanup code here

            # Return failure indicator:
            # TODO: UPDATE WITH WHATEVER WE WANT TO RETURN INDICATING A FAILURE
            return -1
        }
    } else {
        # No error occurred
        # TODO: PLACE ANY RELIABLE CODE HERE THAT NEEDS TO RUN AFTER THE WORK IN THIS FUNCTION WAS SUCCESSFULLY EXECUTED BUT BEFORE THE OUTPUT OBJECT IS COPIED
        # TODO: Add success processing code here

        # Return data by reference:
        $refOutput.Value = $arrOutput

        # TODO: PLACE ANY RELIABLE CODE HERE THAT NEEDS TO RUN AFTER THE WORK IN THIS FUNCTION WAS SUCCESSFULLY EXECUTED AND AFTER THE OUTPUT OBJECT IS COPIED
        # TODO: Add success finalization code here

        # Return success indicator:
        # TODO: UPDATE WITH WHATEVER WE WANT TO RETURN INDICATING A SUCCESS
        return 0
    }
}
