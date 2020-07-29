#region License
###############################################################################################
# Copyright 2020 Frank Lesniak

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

#region FunctionsToSupportErrorHandling
function Get-ReferenceToLastError {
    # Function returns $null if no errors on on the $error stack;
    # Otherwise, function returns a reference (memory pointer) to the last error that occurred.
    if ($error.Count -gt 0) {
        [ref]($error[0])
    } else {
        $null
    }
}

function Test-ErrorOccurred {
    # Function accepts two positional arguments:
    #
    # The first argument is a reference (memory pointer) to the last error that had occurred
    #   prior to calling the command in question - that is, the command that we want to test
    #   to see if an error occurred.
    #
    # The second argument is a reference to the last error that had occurred as-of the
    #   completion of the command in question
    #
    # Function returns $true if it appears that an error occurred; $false otherwise

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
        # could be null if $error was cleared; this does not indicate an error.
        # So:
        # If both are null, no error
        # If ($args[0]) is null and ($args[1]) is non-null, error
        # If ($args[0]) is non-null and ($args[1]) is null, no error
        if (($null -eq ($args[0])) -and ($null -ne ($args[1]))) {
            $boolErrorOccurred
        }
    }

    $boolErrorOccurred
}
#endregion FunctionsToSupportErrorHandling

function Get-DataFromSampleUnreliableCmdletRobust {
    ################### PUT A DESCRIPTION OF THIS FUNCTION ON THE FOLLLOWING LINE; ADD LINES AS NECESSARY ###################
    # Description of Function
    #
    ################### DESCRIBE THE NUMBER OF POSITIONAL ARGUMENTS REQUIRED ###################
    # X positional arguments are required:
    #
    ################### DESCRIBE WHAT EACH ARGUMENT IS ###################
    # The first argument is a reference to a System.Object[] (array) that will be used to store
    #   output. The function guarantees that the output will always be an array, even when a
    #   single item is returned.
    # The second argument is an integer indicating the current attempt number. When calling
    #   this function for the first time, it should be 1
    # The third argument is the maximum number of attempts that the function will observe
    #   before giving up
    # The fourth argument is the path to the file
    ################### DESCRIBE ANY OTHER INPUT ARGUMENTS ###################
    #
    ################### MODIFY THE FOLLOWING LINE TO DESCRIBE THE EXPECTED OUTPUT, WHICH SHOULD BE USED TO INDICATE SUCCESS OR FAILURE; ###################
    ################### $true/$false works well for a binary situation; otherwise an integer may be more appropriate with 0 indicating success ###################
    # The function returns $true if the process completed successfully; $false otherwise
    #
    # Example usage:
    #
    ################### MODIFY THE FOLLOWING LINES TO PROVIDE AN EXAMPLE OF HOW TO CALL THIS FUNCTION ###################
    # $arrReturnData = @()
    # $boolSuccess = Get-DataFromSampleUnreliableCmdletRobust ([ref]$arrReturnData) 1 8
    #
    ################### GIVE ACKNOWLEDGEMENT TO ANYONE ELSE THAT CONTRIBUTED AND INCLUDE ORIGINAL LICENSE IF APPLICABLE ###################
    # This function is derived from Get-FooInfo at the website:
    # https://github.com/foo/foo
    # retrieved on YYYY-MM-DD
    #region OriginalLicense
    # Although substantial modifications have been made, the original portions of
    # Get-FooInfo that are incorporated into Do-SimpleFunction are subject to the
    # following license:
    ###############################################################################################
    # Copyright 20xx First Last

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
    #endregion OriginalLicense

    trap {
        # Intentionally left empty to prevent terminating errors from halting processing
    }

    ################### ASSIGN EACH POSITIONAL ARGUMENT TO A VARIABLE TO AVOID SCOPING ISSUES ###################
    $refOutput = $args[0]
    $intCurrentAttemptNumber = $args[1]
    $intMaximumAttempts = $args[2]
    $objPlaceHolderInputObject = $args[3]

    ################### IF WARRANTED, VALIDATE INPUT HERE ###################

    ################### THE FOLLOWING LINES DO REAL SIMPLE ERROR/WARNING/VERBOSE/ETC OUTPUT; REPLACE OR DELETE AS NECESSARY ###################

    ################### REPLACE THIS WITH A DESCRIPTION OF WHAT THIS FUNCTION IS DOING; IT'S USED IN ERROR/WARNING OUTPUT ###################
    $strDescriptionOfWhatWeAreDoingInThisFunction = "getting unreliable cmdlet data"

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT A NON-TERMINATING ERROR (Write-Error) WHEN THE FUNCTION RETRIES ###################
    $boolOutputErrorOnUnreliableCommandRetry = $false

    ################### SET THIS TO $false IF YOU DO NOT WANT TO OUTPUT A WARNING (Write-Warning) WHEN THE FUNCTION RETRIES ###################
    $boolOutputWarningOnUnreliableCommandRetry = $true

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT VERBOSE INFORMATION (Write-Verbose) WHEN THE FUNCTION RETRIES ###################
    $boolOutputVerboseOnUnreliableCommandRetry = $false

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT DEBUGGING INFORMATION (Write-Debug) WHEN THE FUNCTION RETRIES ###################
    $boolOutputDebugOnUnreliableCommandRetry = $false

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT A NON-TERMINATING ERROR (Write-Error) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP ###################
    $boolOutputErrorOnUnreliableCommandMaximumAttemptsExceeded = $true

    ################### SET THIS TO $false IF YOU DO NOT WANT TO OUTPUT A WARNING (Write-Warning) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP ###################
    $boolOutputWarningOnUnreliableCommandMaximumAttemptsExceeded = $false

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT VERBOSE INFORMATION (Write-Verbose) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP ###################
    $boolOutputVerboseOnUnreliableCommandMaximumAttemptsExceeded = $false

    ################### SET THIS TO $true IF YOU WANT TO OUTPUT DEBUGGING INFORMATION (Write-Debug) WHEN THE FUNCTION RUNS OUT OF RETRIES AND GIVES UP ###################
    $boolOutputDebugOnUnreliableCommandMaximumAttemptsExceeded = $false

    ################### PLACE ANY RELIABLE CODE HERE THAT SETS UP THE UNRELIABLE COMMAND/FUNCTION/CMDLET ###################
    # <Placeholder>

    # Retrieve the newest error on the stack prior to calling the unreliable command
    $refLastKnownError = Get-ReferenceToLastError

    # Store current error preference; we will restore it after we call the unreliable command
    $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

    # Set ErrorActionPreference to SilentlyContinue; this will suppress error output.
    # Terminating errors will not output anything, kick to the empty trap statement and then
    # continue on. Likewise, non-terminating errors will also not output anything, but they
    # do not kick to the trap statement; they simply continue on.
    $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    # Call the unreliable command
    ################### REPLACE THIS WITH WHATEVER UNRELIABLE COMMAND/FUNCTION/CMDLET YOU ARE USING ###################
    $output = @(Get-DataFromSampleUnreliableCmdlet $objPlaceHolderInputObject)

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        if ($intCurrentAttemptNumber -lt $intMaximumAttempts) {
            if ($boolOutputErrorOnUnreliableCommandRetry) {
                Write-Error ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Waiting for " + [string]([math]::Pow(2, ($args[1]))) + " seconds, then retrying...")
            } elseif ($boolOutputWarningOnUnreliableCommandRetry) {
                Write-Warning ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Waiting for " + [string]([math]::Pow(2, ($args[1]))) + " seconds, then retrying...")
            } elseif ($boolOutputVerboseOnUnreliableCommandRetry) {
                Write-Verbose ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Waiting for " + [string]([math]::Pow(2, ($args[1]))) + " seconds, then retrying...")
            } elseif ($boolOutputDebugOnUnreliableCommandRetry) {
                Write-Debug ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Waiting for " + [string]([math]::Pow(2, ($args[1]))) + " seconds, then retrying...")
            }
            Start-Sleep -Seconds ([math]::Pow(2, $intCurrentAttemptNumber))

            ################### REPLACE THIS CALL WITH A RECURSIVE CALL TO THIS SAME FUNCTION; PAY ATTENTION TO THE NUMBER OF ARGUMENTS ###################
            $objResultIndicator = Get-DataFromSampleUnreliableCmdletRobust $refOutput ($intCurrentAttemptNumber + 1) $intMaximumAttempts $objPlaceHolderInputObject
            $objResultIndicator
        } else {
            # Number of attempts exceeded maximum
            if ($boolOutputErrorOnUnreliableCommandMaximumAttemptsExceeded) {
                if ($intMaximumAttempts -ge 2) {
                    Write-Error ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Giving up after too many attempts!")
                } else {
                    Write-Error ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
                }
            } elseif ($boolOutputWarningOnUnreliableCommandMaximumAttemptsExceeded) {
                if ($intMaximumAttempts -ge 2) {
                    Write-Warning ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Giving up after too many attempts!")
                } else {
                    Write-Warning ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
                }
            } elseif ($boolOutputVerboseOnUnreliableCommandMaximumAttemptsExceeded) {
                if ($intMaximumAttempts -ge 2) {
                    Write-Verbose ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Giving up after too many attempts!")
                } else {
                    Write-Verbose ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
                }
            } elseif ($boolOutputDebugOnUnreliableCommandMaximumAttemptsExceeded) {
                if ($intMaximumAttempts -ge 2) {
                    Write-Debug ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ". Giving up after too many attempts!")
                } else {
                    Write-Debug ("An error occurred " + $strDescriptionOfWhatWeAreDoingInThisFunction + ".")
                }
            }

            ################### PLACE ANY RELIABLE CODE HERE THAT NEEDS TO RUN AFTER THE UNRELIABLE CODE WAS *NOT* SUCCESSFULLY EXECUTED ###################
            # <Placeholder>

            ################### UPDATE WITH WHATEVER WE WANT TO RETURN INDICATING A FAILURE ###################
            $false
        }
    } else {
        ################### PLACE ANY RELIABLE CODE HERE THAT NEEDS TO RUN AFTER THE UNRELIABLE CODE WAS SUCCESSFULLY EXECUTED BUT BEFORE THE OUTPUT OBJECT IS COPIED ###################
        # <Placeholder>

        $refOutput.Value = $output

        ################### PLACE ANY RELIABLE CODE HERE THAT NEEDS TO RUN AFTER THE UNRELIABLE CODE WAS SUCCESSFULLY EXECUTED AND AFTER THE OUTPUT OBJECT IS COPIED ###################
        # <Placeholder>

        ################### UPDATE WITH WHATEVER WE WANT TO RETURN INDICATING A SUCCESS ###################
        $true
    }
}
