#region License ####################################################################
# Copyright 2024 Frank Lesniak
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

# Function template version: 2.0.20241219.0

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
    # $boolSuccess = Get-DataFromCloudServiceCmdletRobust -Parameter1 ([ref]$hashtableConfigIni) -CurrentAttemptNumber 1 -MaxAttempts 4 -Parameter4 '.\config.ini' -Parameter5 @(';') -Parameter6 $true -Parameter7 $true -Parameter8 'NoSection' -Parameter9 $true
    #
    # .EXAMPLE
    # $hashtableConfigIni = $null
    # $boolSuccess = Get-DataFromCloudServiceCmdletRobust ([ref]$hashtableConfigIni) 1 4 '.\config.ini' @(';') $true $true 'NoSection' $true
    #
    # .INPUTS
    # None. You can't pipe objects to Get-DataFromCloudServiceCmdletRobust.
    #
    # .OUTPUTS
    # System.Boolean. Get-DataFromCloudServiceCmdletRobust returns a boolean value
    # indiciating whether the process completed successfully. $true means the
    # process completed successfully; $false means there was an error.
    #
    # .NOTES
    ################### IF PARAMETERS ARE BEING USED FOR THIS FUNCTION, THEN THIS BLURB SHOULD BE INCLUDED. HOWEVER, BE MINDFUL THAT [SWITCH] PARAMETERS ARE NOT INCLUDED IN POSITIONAL PARAMETERS BY DEFAULT ###################
    # This function also supports the use of positional parameters instead of named
    # parameters. If positional parameters are used intead of named parameters,
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
    ################### IF YOU ARE USING ARGUMENTS INSTEAD OF PARAMETERS, THEN INCLUDE THIS BLOCK; OTHERWISE, DELETE IT ###################
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

    ################### UPDATE PARAMETER LIST AS NECESSARY; SET DEFAULT VALUES IF YOU WANT TO DEFAULT TO SOMETHING OTHER THAN NULL IF THE PARAMETER IS OMITTED ###################
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

    #region FunctionsToSupportErrorHandling ####################################
    function Get-ReferenceToLastError {
        #region FunctionHeader #############################################
        # Function returns $null if no errors on on the $error stack;
        # Otherwise, function returns a reference (memory pointer) to the last
        # error that occurred.
        #
        # Version: 1.0.20241211.0
        #endregion FunctionHeader #############################################

        #region License ####################################################
        # Copyright (c) 2024 Frank Lesniak
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

        #region DownloadLocationNotice #####################################
        # The most up-to-date version of this script can be found on the
        # author's GitHub repository at:
        # https://github.com/franklesniak/PowerShell_Resources
        #endregion DownloadLocationNotice #####################################

        if ($Error.Count -gt 0) {
            return ([ref]($Error[0]))
        } else {
            return $null
        }
    }

    function Test-ErrorOccurred {
        #region FunctionHeader #############################################
        # Function accepts two positional arguments:
        #
        # The first argument is a reference (memory pointer) to the last error
        # that had occurred prior to calling the command in question - that is,
        # the command that we want to test to see if an error occurred.
        #
        # The second argument is a reference to the last error that had
        # occurred as-of the completion of the command in question.
        #
        # Function returns $true if it appears that an error occurred; $false
        # otherwise
        #
        # Version: 1.0.20241211.0
        #endregion FunctionHeader #############################################

        #region License ####################################################
        # Copyright (c) 2024 Frank Lesniak
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

        #region DownloadLocationNotice #####################################
        # The most up-to-date version of this script can be found on the
        # author's GitHub repository at:
        # https://github.com/franklesniak/PowerShell_Resources
        #endregion DownloadLocationNotice #####################################

        # TO-DO: Validate input

        $boolErrorOccurred = $false
        if (($null -ne ($args[0])) -and ($null -ne ($args[1]))) {
            # Both not $null
            if ((($args[0]).Value) -ne (($args[1]).Value)) {
                $boolErrorOccurred = $true
            }
        } else {
            # One is $null, or both are $null
            # NOTE: ($args[0]) could be non-null, while ($args[1])
            # could be null if $error was cleared; this does not indicate an
            # error.
            # So:
            # If both are null, no error
            # If ($args[0]) is null and ($args[1]) is non-null, error
            # If ($args[0]) is non-null and ($args[1]) is null, no error
            if (($null -eq ($args[0])) -and ($null -ne ($args[1]))) {
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

    ################### IF YOU ARE USING ARGUMENTS INSTEAD OF PARAMETERS, THEN INCLUDE THIS BLOCK; OTHERWISE, DELETE IT ###################
    #region Assign Arguments to Internally-Used Variables ######################
    if (($args.Count -lt 9) -or ($args.Count -gt 10)) {
        # Error condition; return failure indicator:
        ################### UPDATE WITH WHATEVER WE WANT TO RETURN INDICATING A FAILURE ###################
        return $false
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

    ################### IF WARRANTED, VALIDATE INPUT HERE ###################

    ################### THE FOLLOWING LINES CONTROL SIMPLE ERROR/WARNING/VERBOSE/ETC OUTPUT; REPLACE OR DELETE AS NECESSARY ###################

    ################### REPLACE THIS WITH A DESCRIPTION OF WHAT THIS FUNCTION IS DOING; IT'S USED IN ERROR/WARNING OUTPUT ###################
    $strDescriptionOfWhatWeAreDoingInThisFunction = "getting some data"

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT A NON-TERMINATING ERROR (Write-Error) WHEN THE FUNCTION RETRIES ###################
    $boolOutputErrorOnFunctionRetry = $false

    ################### SET THIS TO $false IF YOU DO NOT WANT TO OUTPUT A WARNING (Write-Warning) WHEN THE FUNCTION RETRIES ###################
    $boolOutputWarningOnFunctionRetry = $true

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT VERBOSE INFORMATION (Write-Verbose) WHEN THE FUNCTION RETRIES ###################
    $boolOutputVerboseOnFunctionRetry = $false

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT DEBUGGING INFORMATION (Write-Debug) WHEN THE FUNCTION RETRIES ###################
    $boolOutputDebugOnFunctionRetry = $false

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT A NON-TERMINATING ERROR (Write-Error) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP ###################
    $boolOutputErrorOnFunctionMaximumAttemptsExceeded = $true

    ################### SET THIS TO $false IF YOU DO NOT WANT TO OUTPUT A WARNING (Write-Warning) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP ###################
    $boolOutputWarningOnFunctionMaximumAttemptsExceeded = $false

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT VERBOSE INFORMATION (Write-Verbose) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP ###################
    $boolOutputVerboseOnFunctionMaximumAttemptsExceeded = $false

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT DEBUGGING INFORMATION (Write-Debug) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP ###################
    $boolOutputDebugOnFunctionMaximumAttemptsExceeded = $false

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
    $output = @(Get-DataFromCloudServiceCmdlet $objPlaceHolderInputObject)

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        # Error occurred
        if ($CurrentAttemptNumber -lt $MaxAttempts) {
            if ($boolOutputErrorOnFunctionRetry) {
                Write-Error ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Waiting for " + [string]([math]::Pow(2, ($args[1]))) + " seconds, then retrying...")
            } elseif ($boolOutputWarningOnFunctionRetry) {
                Write-Warning ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Waiting for " + [string]([math]::Pow(2, ($args[1]))) + " seconds, then retrying...")
            } elseif ($boolOutputVerboseOnFunctionRetry) {
                Write-Verbose ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Waiting for " + [string]([math]::Pow(2, ($args[1]))) + " seconds, then retrying...")
            } elseif ($boolOutputDebugOnFunctionRetry) {
                Write-Debug ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Waiting for " + [string]([math]::Pow(2, ($args[1]))) + " seconds, then retrying...")
            }
            Start-Sleep -Seconds ([math]::Pow(2, $CurrentAttemptNumber))

            ################### REPLACE THIS CALL WITH A RECURSIVE CALL TO THIS SAME FUNCTION; PAY ATTENTION TO THE PARAMETERS ###################
            $objResultIndicator = Get-DataFromCloudServiceCmdletRobust -Parameter1 $refOutput -CurrentAttemptNumber ($CurrentAttemptNumber + 1) -MaxAttempts $MaxAttempts -Parameter4 $strFilePath -Parameter5 $arrCharDriveLetters -Parameter6 $boolUsePSDrive -Parameter7 $boolRefreshPSDrive -Parameter8 $strSecondaryPath -Parameter9 $boolQuitOnError -Parameter10 $strServerName
            return $objResultIndicator
        } else {
            # Number of attempts exceeded maximum
            if ($boolOutputErrorOnFunctionMaximumAttemptsExceeded) {
                if ($MaxAttempts -ge 2) {
                    Write-Error ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Giving up after too many attempts!")
                } else {
                    Write-Error ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
                }
            } elseif ($boolOutputWarningOnFunctionMaximumAttemptsExceeded) {
                if ($MaxAttempts -ge 2) {
                    Write-Warning ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Giving up after too many attempts!")
                } else {
                    Write-Warning ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
                }
            } elseif ($boolOutputVerboseOnFunctionMaximumAttemptsExceeded) {
                if ($MaxAttempts -ge 2) {
                    Write-Verbose ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Giving up after too many attempts!")
                } else {
                    Write-Verbose ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
                }
            } elseif ($boolOutputDebugOnFunctionMaximumAttemptsExceeded) {
                if ($MaxAttempts -ge 2) {
                    Write-Debug ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Giving up after too many attempts!")
                } else {
                    Write-Debug ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
                }
            }

            ################### PLACE ANY RELIABLE CODE HERE THAT NEEDS TO RUN AFTER THE WORK IN THIS FUNCTION WAS *NOT* SUCCESSFULLY EXECUTED ###################
            # <Placeholder>

            # Return failure indicator:
            ################### UPDATE WITH WHATEVER WE WANT TO RETURN INDICATING A FAILURE ###################
            return $false
        }
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
