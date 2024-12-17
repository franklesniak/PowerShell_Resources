function Test-ValidSID {
    # .SYNOPSIS
    # Tests to see if the supplied, referenced object is a SID
    #
    # .DESCRIPTION
    # Validates whether the referenced object is a security identifier (SID).
    # An object is considered to be a SID if it is or can be converted to type
    # System.Security.Principal.SecurityIdentifier. If an object is a SID, this
    # function returns $true; otherwise, it returns $false.
    #
    # .PARAMETER ReferenceToObject
    # This parameter is required; it is a reference to an object that will be
    # tested to determine if it is a SID.
    #
    # .EXAMPLE
    # $boolResult = Test-ValidSID -ReferenceToObject ([ref]'S-1-5-21-1234567890-1234567890-1234567890-1000')
    #
    # .EXAMPLE
    # $boolResult = Test-ValidSID ([ref]'S-1-5-21-1234567890-1234567890-1234567890-1000')
    #
    # .INPUTS
    # None. You can't pipe objects to Test-ValidSID.
    #
    # .OUTPUTS
    # System.Boolean. Test-ValidSID returns a boolean value indiciating
    # whether the supplied object was a SID. $true means the object was a SID;
    # $false means the supplied object was not a SID.
    #
    # .NOTES
    # This function also supports the use of an argument instead of a
    # parameter. If an argument is supplied instead of the parameter, then one
    # positional argument is required: it is a reference to an object that will
    # be tested to determine if it is a SID.
    #
    # Version: 3.0.20241217.0

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

    #region Acknowledgements ###################################################
    # Thanks to Friedrich Weinmann who suggested an alternative way to test for a
    # SID:
    # https://twitter.com/FredWeinmann/status/1675513443615404032?s=20
    # retrieved on 2023-07-19
    #endregion Acknowledgements ###################################################

    param (
        [ref]$ReferenceToObject = ([ref]$null)
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

    #region Assign Parameters and Arguments to Internally-Used Variables #######
    $boolUseArguments = $false
    if ($args.Count -eq 1) {
        # Arguments may have been supplied instead of parameters
        if ($null -eq $ReferenceToObject.Value) {
            # No valid data was supplied via a parameter, so assume arguments
            # were used
            $boolUseArguments = $true
        }
    }

    if (-not $boolUseArguments) {
        # Use parameters
        $refObjectToTest = $ReferenceToObject
    } else {
        # Use positional arguments
        $refObjectToTest = $args[0]
    }
    #endregion Assign Parameters and Arguments to Internally-Used Variables #######

    # TODO: Validate input

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

    # This shouldn't error, even if the referenced object is not a SID, but we play
    # it safe and store the result in $objSID. $objSID should be $null if the
    # referenced object is not a SID
    $objSID = ($refObjectToTest.Value) -as [System.Security.Principal.SecurityIdentifier]

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        # Error occurred; return indicator that object is not a SID:
        return $false
    } else {
        # No error occurred
        # If $objSID is not $null, then the referenced object was a SID
        # If $objSID is $null, then the referenced object was not a SID
        return ($null -ne $objSID)
    }
}
