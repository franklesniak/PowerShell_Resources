function Remove-SpecificAccessRuleRobust {
    # .SYNOPSIS
    # Removes an access rule from an object.
    #
    # .DESCRIPTION
    # This function removes a specific access rule from a
    # System.Security.AccessControl.DirectorySecurity or similar object "safely"
    # (i.e., without throwing any errors should the process fail) and in a way that
    # automaticaly retries if an error occurs.
    #
    # .PARAMETER CurrentAttemptNumber
    # This parameter is required; it is an integer indicating the current attempt
    # number. When calling this function for the first time, it should be 1.
    #
    # .PARAMETER MaxAttempts
    # This parameter is required; it is an integer representing the maximum number
    # of attempts that the function will observe before giving up.
    #
    # .PARAMETER ReferenceToAccessControlListObject
    # This parameter is required; it is a reference to a
    # System.Security.AccessControl.DirectorySecurity or similar object from
    # which the access control entry will be removed.
    #
    # .PARAMETER ReferenceToAccessRuleObject
    # This parameter is required; it is a reference to a
    # System.Security.AccessControl.FileSystemAccessRule or similar object that
    # will be removed from the access control list.
    #
    # .EXAMPLE
    # $item = Get-Item 'D:\Shared\Human_Resources'
    # $directorySecurity = $item.GetAccessControl()
    # $arrFileSystemAccessRules = @($directorySecurity.Access)
    # $boolSuccess = Remove-SpecificAccessRuleRobust -CurrentAttemptNumber 1 -MaxAttempts 8 -ReferenceToAccessControlListObject ([ref]$directorySecurity) -ReferenceToAccessRuleObject ([ref]($arrFileSystemAccessRules[0]))
    #
    # .EXAMPLE
    # $item = Get-Item 'D:\Shared\Human_Resources'
    # $directorySecurity = $item.GetAccessControl()
    # $arrFileSystemAccessRules = @($directorySecurity.Access)
    # $boolSuccess = Remove-SpecificAccessRuleRobust 1 8 ([ref]$directorySecurity) ([ref]($arrFileSystemAccessRules[0]))
    #
    # .INPUTS
    # None. You can't pipe objects to Remove-SpecificAccessRuleRobust.
    #
    # .OUTPUTS
    # System.Boolean. Remove-SpecificAccessRuleRobust returns a boolean value
    # indiciating whether the process completed successfully. $true means the
    # process completed successfully; $false means there was an error.
    #
    # .NOTES
    # This function also supports the use of positional parameters instead of named
    # parameters. If positional parameters are used intead of named parameters,
    # then four positional parameters are required:
    #
    # The first positional parameter is an integer indicating the current attempt
    # number. When calling this function for the first time, it should be 1.
    #
    # The second positional parameter is an integer representing the maximum number
    # of attempts that the function will observe before giving up.
    #
    # The third positional parameter is a reference to a
    # System.Security.AccessControl.DirectorySecurity or similar object from which
    # the access control entry will be removed.
    #
    # The fourth positional parameter is a reference to a
    # System.Security.AccessControl.FileSystemAccessRule or similar object that
    # will be removed from the access control list.
    #
    # Version: 1.1.20241219.0

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

    param (
        [int]$CurrentAttemptNumber = 1,
        [int]$MaxAttempts = 1,
        [ref]$ReferenceToAccessControlListObject = ([ref]$null),
        [ref]$ReferenceToAccessRuleObject = ([ref]$null)
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

    # Remove the access rule/access control entry from the list
    ($ReferenceToAccessControlListObject.Value).RemoveAccessRuleSpecific($ReferenceToAccessRuleObject.Value)

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        # Error occurred
        if ($CurrentAttemptNumber -lt $MaxAttempts) {
            Start-Sleep -Seconds ([math]::Pow(2, $CurrentAttemptNumber))

            $objResultIndicator = Remove-SpecificAccessRuleRobust -CurrentAttemptNumber ($CurrentAttemptNumber + 1) -MaxAttempts $MaxAttempts -ReferenceToAccessControlListObject $ReferenceToAccessControlListObject -ReferenceToAccessRuleObject $ReferenceToAccessRuleObject
            return $objResultIndicator
        } else {
            # Number of attempts exceeded maximum; return failure indicator:
            return $false
        }
    } else {
        # No error occurred; return success indicator:
        return $true
    }
}
