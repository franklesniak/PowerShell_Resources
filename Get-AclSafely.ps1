function Get-AclSafely {
    # .SYNOPSIS
    # Gets the access control list (ACL) in a way that suppresses errors, should an
    # error occur.
    #
    # .DESCRIPTION
    # Gets and returns the access control list (ACL) from a path or object. This
    # function is intended to be used in situations where the Get-Acl cmdlet may
    # fail due to a variety of reasons. This function is designed to suppress
    # errors and return a boolean value indicating whether the operation was
    # successful.
    #
    # .PARAMETER ReferenceToACL
    # This parameter is required; it is a reference to an object (the specific
    # object type will vary depending on the type of object/path supplied in the
    # PathToObject parameter; for example, a directory/folder will be a
    # System.Security.AccessControl.DirectorySecurity object, a registry key will
    # be a System.Security.AccessControl.RegistrySecurity, etc.). If the operation
    # was successful, the referenced object will be populated with the object
    # resulting from Get-Acl. If the operation was unsuccessful, the referenced
    # object is undefined.
    #
    # .PARAMETER ReferenceToInfoObject
    # This parameter is required; it is a reference to an object (the specific
    # object type will vary depending on the type of object/path supplied in the
    # PathToObject parameter; for example, a directory/folder will be a
    # System.IO.DirectoryInfo object, a registry key will be a
    # Microsoft.Win32.RegistryKey object, etc.). In cases where this function needs
    # to retrieve the object (using Get-Item) to retrieve the access control entry
    # (ACL), the referenced object will be populated with the object resulting from
    # Get-Item. If the function did not need to use Get-Item, the referenced object
    # is undefined.
    #
    # .PARAMETER PathToObject
    # This parameter is required; it is a string representing the path to the
    # object for which the ACL is to be retrieved. This path can be a file or
    # folder path, or it can be a registry path (for example).
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
    # $objThisFolderPermission = $null
    # $objThis = $null
    # $strThisObjectPath = 'D:\Shares\Share\Accounting'
    # $boolSuccess = Get-AclSafely -ReferenceToACL ([ref]$objThisFolderPermission) -ReferenceToInfoObject ([ref]$objThis) -PathToObject $strThisObjectPath
    #
    # .EXAMPLE
    # $objThisFolderPermission = $null
    # $objThis = $null
    # $strThisObjectPath = 'D:\Shares\Share\Accounting'
    # $boolSuccess = Get-AclSafely ([ref]$objThisFolderPermission) ([ref]$objThis) $strThisObjectPath
    #
    # .INPUTS
    # None. You can't pipe objects to Get-AclSafely.
    #
    # .OUTPUTS
    # System.Boolean. Get-AclSafely returns a boolean value indiciating whether the
    # process completed successfully. $true means the process completed
    # successfully; $false means there was an error.
    #
    # .NOTES
    # This function also supports the use of positional parameters instead of named
    # parameters. If positional parameters are used instead of named parameters,
    # then three or four positional parameters are required:
    #
    # The first positional parameter is a reference to an object (the specific
    # object type will vary depending on the type of object/path supplied in the
    # PathToObject parameter; for example, a directory/folder will be a
    # System.Security.AccessControl.DirectorySecurity object, a registry key will
    # be a System.Security.AccessControl.RegistrySecurity, etc.). If the operation
    # was successful, the referenced object will be populated with the object
    # resulting from Get-Acl. If the operation was unsuccessful, the referenced
    # object is undefined.
    #
    # The second positional parameter is a reference to an object (the specific
    # object type will vary depending on the type of object/path supplied in the
    # PathToObject parameter; for example, a directory/folder will be a
    # System.IO.DirectoryInfo object, a registry key will be a
    # Microsoft.Win32.RegistryKey object, etc.). In cases where this function needs
    # to retrieve the object (using Get-Item) to retrieve the access control entry
    # (ACL), the referenced object will be populated with the object resulting from
    # Get-Item. If the function did not need to use Get-Item, the referenced object
    # is undefined.
    #
    # The third positional parameter is a string representing the path to the
    # object for which the ACL is to be retrieved. This path can be a file or
    # folder path, or it can be a registry path (for example).
    #
    # The fourth positional parameter is optional; if supplied, it must be the
    # version number of the running version of PowerShell. If the version of
    # PowerShell is already known, it can be passed in to this function to avoid
    # the overhead of unnecessarily determining the version of PowerShell. If this
    # parameter is not supplied, the function will determine the version of
    # PowerShell that is running as part of its processing.
    #
    # Version: 2.1.20250215.0

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
        [ref]$ReferenceToACL = ([ref]$null),
        [ref]$ReferenceToInfoObject = ([ref]$null),
        [string]$PathToObject = '',
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

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    #region Process Input ######################################################
    if ($null -ne $PSVersion) {
        if ($PSVersion -eq ([version]'0.0')) {
            $versionPS = Get-PSVersion
        } else {
            $versionPS = $PSVersion
        }
    } else {
        $versionPS = Get-PSVersion
    }

    if ($versionPS.Major -ge 3) {
        # PowerShell 3.0 runs on .NET Framework 4.0, which supports the
        # IsNullOrWhitespace method
        if ([string]::IsNullOrWhiteSpace($PathToObject)) {
            Write-Warning 'For the Get-AclSafely function, the PathToObject parameter is required and cannot be null, empty, or solely containing whitespace.'
            return $false
        }
    } else {
        # PowerShell 1.0 and 2.0 run on .NET Framework 2.0, which does not support
        # the IsNullOrWhitespace method; fall back to IsNullOrEmpty and check for a
        # string that contains only whitespace
        if ([string]::IsNullOrEmpty($PathToObject)) {
            Write-Warning 'For the Get-AclSafely function, the PathToObject parameter is required and cannot be null or empty.'
            return $false
        } else {
            # Not null or empty; check for whitespace
            if ($PathToObject -match '^\s*$') {
                Write-Warning 'For the Get-AclSafely function, the PathToObject parameter is required and cannot solely contain whitespace.'
                return $false
            }
        }
    }
    #endregion Process Input ######################################################

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

    # This needs to be a one-liner for error handling to work!:
    if ($PathToObject.Contains('[') -or $PathToObject.Contains(']') -or $PathToObject.Contains('`')) { if ($versionPS.Major -ge 3) { ($ReferenceToInfoObject.Value) = Get-Item -LiteralPath $PathToObject -Force; if ($versionPS -ge ([version]'7.3')) { if (@(Get-Module Microsoft.PowerShell.Security).Count -eq 0) { Import-Module Microsoft.PowerShell.Security }; ($ReferenceToACL.Value) = [System.IO.FileSystemAclExtensions]::GetAccessControl($ReferenceToInfoObject.Value) } else { ($ReferenceToACL.Value) = ($ReferenceToInfoObject.Value).GetAccessControl() } } elseif ($versionPS.Major -eq 2) { ($ReferenceToInfoObject.Value) = Get-Item -Path ((($PathToObject.Replace('[', '`[')).Replace(']', '`]')).Replace('`', '``')) -Force; ($ReferenceToACL.Value) = ($ReferenceToInfoObject.Value).GetAccessControl() } else { ($ReferenceToACL.Value) = Get-Acl -Path ($PathToObject.Replace('`', '``')) } } else { ($ReferenceToACL.Value) = Get-Acl -Path $PathToObject }
    # The above one-liner is a messy variant of the following, which had to be
    # converted to one line to prevent PowerShell v3 from throwing errors on the
    # stack when copy-pasted into the shell (despite there not being any apparent
    # error):
    ###############################################################################
    # TODO: Get-Acl is slow if there is latency between the folder structure and
    # the domain controller, probably because of SID lookups. See if there is a way
    # to speed this up without introducing external dependencies.
    # TODO: Get-Acl allegedly does not exist on PowerShell on Linux (specifically
    # at least not on PowerShell Core v6.2.4 on Ubuntu 18.04.4 or PowerShell v7.0.0
    # on Ubuntu 18.04.4). Confirm this and then re-work the below to get around the
    # issue.
    # if ($PathToObject.Contains('[') -or $PathToObject.Contains(']') -or $PathToObject.Contains('`')) {
    #     # Can't use Get-Acl because Get-Acl doesn't support paths with brackets
    #     # or grave accent marks (backticks). So, we need to use Get-Item and then
    #     # GetAccessControl() or [System.IO.FileSystemAclExtensions]::GetAccessControl()
    #     if ($versionPS.Major -ge 3) {
    #         # PowerShell v3 and newer supports -LiteralPath
    #         ($ReferenceToInfoObject.Value) = Get-Item -LiteralPath $PathToObject -Force # -Force parameter is required to get hidden items
    #         if ($versionPS -ge ([version]'7.3')) {
    #             # PowerShell v7.3 and newer do not have
    #             # Microsoft.PowerShell.Security automatically loaded; likewise,
    #             # the .GetAccessControl() method of a folder or file object is
    #             # missing. So, we need to load the Microsoft.PowerShell.Security
    #             # module and then call
    #             # [System.IO.FileSystemAclExtensions]::GetAccessControl()
    #             if (@(Get-Module Microsoft.PowerShell.Security).Count -eq 0) {
    #                 Import-Module Microsoft.PowerShell.Security
    #             }
    #             ($ReferenceToACL.Value) = [System.IO.FileSystemAclExtensions]::GetAccessControl($ReferenceToInfoObject.Value)
    #         } else {
    #             # PowerShell v3 through v7.2
    #             ($ReferenceToACL.Value) = ($ReferenceToInfoObject.Value).GetAccessControl()
    #         }
    #     } elseif ($versionPS.Major -eq 2) {
    #         # We don't need to escape the right square bracket based on testing,
    #         # but we do need to escape the left square bracket. Nevertheless,
    #         # escaping both brackets does work and seems like the safest option.
    #         # Additionally, escape the grave accent mark (backtick).
    #         ($ReferenceToInfoObject.Value) = Get-Item -Path ((($PathToObject.Replace('[', '`[')).Replace(']', '`]')).Replace('`', '``')) -Force # -Force parameter is required to get hidden items
    #         ($ReferenceToACL.Value) = ($ReferenceToInfoObject.Value).GetAccessControl()
    #     } else {
    #         # PowerShell v1
    #         # Get-Item -> GetAccessControl() does not work and returns $null on
    #         # PowerShell v1 for some reason.
    #         # And, unfortunately, there is no apparent way to escape left square
    #         # brackets with Get-Acl. However, we can escape the grave accent mark
    #         # (backtick).
    #         ($ReferenceToACL.Value) = Get-Acl -Path ($PathToObject.Replace('`', '``'))
    #     }
    # } else {
    #     # No square brackets or grave accent marks (backticks); use Get-Acl
    #     ($ReferenceToACL.Value) = Get-Acl -Path $PathToObject
    # }
    ###############################################################################

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
