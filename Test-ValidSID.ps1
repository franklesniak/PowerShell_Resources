function Test-ValidSID {
    <#
    .SYNOPSIS
    Tests whether the supplied parameter is a valid security identifier (SID)

    .DESCRIPTION
    The function tests whether the supplied arugment is a security identifier (SID).
    If the supplied argument is a SID, the function returns $true. If the supplied
    argument is not a SID, the function returns $false.

    .EXAMPLE
    Test-ValidSID -ObjectToTest 'S-1-5-21-1234567890-1234567890-1234567890-1000'

    .NOTES
    The function was written by Frank Lesniak, licensed under the MIT license, and is
    available on GitHub at https://github.com/franklesniak/PowerShell_Resources
    #>

    #region License ################################################################
    # Copyright 2022 Frank Lesniak

    # Permission is hereby granted, free of charge, to any person obtaining a copy of
    # this software and associated documentation files (the "Software"), to deal in the
    # Software without restriction, including without limitation the rights to use,
    # copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
    # Software, and to permit persons to whom the Software is furnished to do so,
    # subject to the following conditions:

    # The above copyright notice and this permission notice shall be included in all
    # copies or substantial portions of the Software.

    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    # FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    # COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
    # AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #endregion License ################################################################

    [cmdletbinding()]
    [OutputType([Boolean])]
    param (
        [Parameter(Mandatory = $true)]$ObjectToTest
    )

    #region FunctionsToSupportErrorHandling ########################################
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
    #endregion FunctionsToSupportErrorHandling ########################################

    trap {
        # Intentionally left empty to prevent terminating errors from halting processing
    }

    # Retrieve the newest error on the stack prior to running the command to determine
    # if the object is a SID
    $refLastKnownError = Get-ReferenceToLastError

    # Store current error preference; we will restore it after we call the command
    $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

    # Set ErrorActionPreference to SilentlyContinue; this will suppress error output.
    # Terminating errors will not output anything, kick to the empty trap statement and
    # then continue on. Likewise, non-terminating errors will also not output anything,
    # but they do not kick to the trap statement; they simply continue on.
    $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    # Run the command to determine if the object is a SID
    $objSID = New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList $ObjectToTest

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        return $false
    } else {
        return $true
    }
}
