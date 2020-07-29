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

function Do-SimpleFunction {
    ################### PUT A DESCRIPTION OF THIS FUNCTION ON THE FOLLLOWING LINE; ADD LINES AS NECESSARY ###################
    # Description of Function
    #
    ################### DESCRIBE THE NUMBER OF POSITIONAL ARGUMENTS REQUIRED ###################
    # X positional arguments are required:
    #
    ################### DESCRIBE WHAT EACH ARGUMENT IS ###################
    # The first argument is a reference to an object that will be used to store output
    # The second argument is a string representing ...
    # The third argument is an array of characters that represent ...
    # The fourth argument is a boolean value that indicates whether ...
    # The fifth argument is a boolean value that indicates whether ...
    # The sixth argument is a string representation of ...
    # The seventh argument is a boolean value that indicates whether ...
    # If supplied, the eighth argument is a string representation of ...
    #
    ################### DESCRIBE WHAT THE FUNCTION RETURNS ###################
    # The function returns a 0 if successful, non-zero otherwise.
    #
    ################### PROVIDE EXAMPLE USAGE ###################
    # Example usage:
    # $hashtableConfigIni = $null
    # $intReturnCode = Do-SimpleFunction ([ref]$hashtableConfigIni) ".\config.ini" @(";") $true $true "NoSection" $true
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
    $strFilePath = $args[1]

    ################### IF WARRANTED, VALIDATE INPUT HERE ###################

    ################### THE FOLLOWING LINES DO REAL SIMPLE ERROR/WARNING/VERBOSE/ETC OUTPUT; REPLACE OR DELETE AS NECESSARY ###################

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

    # Store current error preference; we will restore it after we do our work
    $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

    # Set ErrorActionPreference to SilentlyContinue; this will suppress error output.
    # Terminating errors will not output anything, kick to the empty trap statement and then
    # continue on. Likewise, non-terminating errors will also not output anything, but they
    # do not kick to the trap statement; they simply continue on.
    $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    # Do the work of this function...
    ################### REPLACE THIS WITH WHATEVER COMMANDS YOU NEED FOR THE FUNCTION TO DO ITS JOB ###################
    $output = @(Get-DataFromSampleUnreliableCmdlet $strFilePath)

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
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

        ################### UPDATE WITH WHATEVER WE WANT TO RETURN INDICATING A FAILURE ###################
        $false
    } else {
        # No error occurred
        ################### PLACE ANY RELIABLE CODE HERE THAT NEEDS TO RUN AFTER THE WORK IN THIS FUNCTION WAS SUCCESSFULLY EXECUTED BUT BEFORE THE OUTPUT OBJECT IS COPIED ###################
        # <Placeholder>

        # Return data by reference:
        $refOutput.Value = $output

        ################### PLACE ANY RELIABLE CODE HERE THAT NEEDS TO RUN AFTER THE WORK IN THIS FUNCTION WAS SUCCESSFULLY EXECUTED AND AFTER THE OUTPUT OBJECT IS COPIED ###################
        # <Placeholder>

        ################### UPDATE WITH WHATEVER WE WANT TO RETURN INDICATING A SUCCESS ###################
        $true
    }
}
