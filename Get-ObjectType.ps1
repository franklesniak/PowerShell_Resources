#region FunctionsToSupportErrorHandling
function Get-ReferenceToLastError {
    # .SYNOPSIS
    # Gets a reference (memory pointer) to the last error that occurred.
    #
    # .DESCRIPTION
    # Returns $null if no errors on on the $error stack; otherwise, returns
    # a reference (memory pointer) to the last error that occurred.
    #
    # .EXAMPLE
    # # Intentionally empty trap statement to prevent terminating errors
    # # from halting processing
    # trap { }
    #
    # # Retrieve the newest error on the stack prior to doing work:
    # $refLastKnownError = Get-ReferenceToLastError
    #
    # # Store current error preference; we will restore it after we do some
    # # work:
    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
    #
    # # Set ErrorActionPreference to SilentlyContinue; this will suppress
    # # error output. Terminating errors will not output anything, kick to
    # # the empty trap statement and then continue on. Likewise, non-
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
    # if (($null -ne $refLastKnownError) -and ($null -ne $refNewestCurrentError)) {
    #     # Both not $null
    #     if (($refLastKnownError.Value) -ne ($refNewestCurrentError.Value)) {
    #         $boolErrorOccurred = $true
    #     }
    # } else {
    #     # One is $null, or both are $null
    #     # NOTE: $refLastKnownError could be non-null, while
    #     # $refNewestCurrentError could be null if $error was cleared;
    #     # this does not indicate an error.
    #     # So:
    #     # If both are null, no error
    #     # If $refLastKnownError is null and $refNewestCurrentError is
    #     # non-null, error
    #     # If $refLastKnownError is non-null and $refNewestCurrentError is
    #     # null, no error
    #     if (($null -eq $refLastKnownError) -and ($null -ne $refNewestCurrentError)) {
    #         $boolErrorOccurred = $true
    #     }
    # }
    #
    # .INPUTS
    # None. You can't pipe objects to Get-ReferenceToLastError.
    #
    # .OUTPUTS
    # System.Management.Automation.PSReference ([ref]).
    # Get-ReferenceToLastError returns a reference (memory pointer) to the
    # last error that occurred.
    #
    # .NOTES
    # Version: 1.0.20241223.0

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

    if ($Error.Count -gt 0) {
        return ([ref]($Error[0]))
    } else {
        return $null
    }
}

function Test-ErrorOccurred {
    #region FunctionHeader ####################################################
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
    #
    # Version: 1.0.20210105.0
    #endregion FunctionHeader ####################################################

    #region License ####################################################
    # Copyright (c) 2021 Frank Lesniak
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy of this
    # software and associated documentation files (the "Software"), to deal in the Software
    # without restriction, including without limitation the rights to use, copy, modify, merge,
    # publish, distribute, sublicense, and/or sell copies of the Software, and to permit
    # persons to whom the Software is furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all copies or
    # substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    # INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
    # PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
    # FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
    # OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    # DEALINGS IN THE SOFTWARE.
    #endregion License ####################################################

    #region DownloadLocationNotice ####################################################
    # The most up-to-date version of this script can be found on the author's GitHub repository
    # at https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice ####################################################

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

function Get-ObjectType {
    #region FunctionHeader ####################################################
    # This function is a "safer" way to call .GetType() on an object; if the object is $null
    # or void/nothing/uninitialized and has no type, this function returns an empty string ('')
    # and avoids generating an error.
    #
    # For example, the following would normally generate an error, which we can avoid by using
    # this function in place of .GetType:
    # function Get-Nothing {}
    # (Get-Nothing).GetType()
    #
    # This function takes one positional parameter: a reference to an object.
    #
    # Example usage:
    # $objectSomething = Do-SomeFunction
    # $strObjectType = Get-ObjectType ([ref]$objectSomething)
    # if ($strObjectType -eq '') {
    #   # $strObjectType has no type
    # } else {
    #   # $strObjectType contains the result of $objectSomething.GetType().TypeName
    # }
    #
    # Version: 1.0.20210105.0
    #endregion FunctionHeader ####################################################

    #region License ####################################################
    # Copyright (c) 2021 Frank Lesniak
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy of this
    # software and associated documentation files (the "Software"), to deal in the Software
    # without restriction, including without limitation the rights to use, copy, modify, merge,
    # publish, distribute, sublicense, and/or sell copies of the Software, and to permit
    # persons to whom the Software is furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all copies or
    # substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    # INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
    # PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
    # FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
    # OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    # DEALINGS IN THE SOFTWARE.
    #endregion License ####################################################

    #region DownloadLocationNotice ####################################################
    # The most up-to-date version of this script can be found on the author's GitHub repository
    # at https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice ####################################################

    trap {
        # Intentionally left empty to prevent terminating errors from halting processing
    }

    $refObjectToTest = $args[0]

    # Retrieve the newest error on the stack prior to doing work
    $refLastKnownError = Get-ReferenceToLastError

    # Store current error preference; we will restore it after we do our work
    $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

    # Set ErrorActionPreference to SilentlyContinue; this will suppress error output.
    # Terminating errors will not output anything, kick to the empty trap statement and then
    # continue on. Likewise, non-terminating errors will also not output anything, but they
    # do not kick to the trap statement; they simply continue on.
    $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    $PSTypeInfo = $null
    $PSTypeInfo = ($refObjectToTest.Value).GetType()

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        # Error occurred
        '' # Return empty string
    } else {
        if ($null -eq $PSTypeInfo) {
            '' # Return empty string
        } else {
            $refLastKnownError = $null
            # Retrieve the newest error on the stack prior to doing work
            $refLastKnownError = Get-ReferenceToLastError

            # Store current error preference; we will restore it after we do our work
            $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

            # Set ErrorActionPreference to SilentlyContinue; this will suppress error output.
            # Terminating errors will not output anything, kick to the empty trap statement and then
            # continue on. Likewise, non-terminating errors will also not output anything, but they
            # do not kick to the trap statement; they simply continue on.
            $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

            $strTypeName = $PSTypeInfo.Name

            # Restore the former error preference
            $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

            $refNewestCurrentError = $null
            # Retrieve the newest error on the error stack
            $refNewestCurrentError = Get-ReferenceToLastError

            if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
                # Error occurred
                '' # Return empty string
            } else {
                if ([string]::IsNullOrEmpty($strTypeName)) {
                    '' # Return empty string
                } else {
                    $strTypeName
                }
            }
        }
    }
}
