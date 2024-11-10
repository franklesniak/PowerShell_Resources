function Get-AclSafely {
    #region FunctionHeader #####################################################
    # Gets and returns the access control list (ACL) from a path or object. This
    # function is intended to be used in situations where the Get-Acl cmdlet may
    # fail due to a variety of reasons. This function is designed to suppress
    # errors and return a boolean value indicating whether the operation was
    # successful.
    #
    # Three positional arguments are required:
    #
    # The first argument is a reference to an object (the specific object type will
    # vary depending on the type of object/path supplied in the third argument). If
    # the operation was successful, the referenced object will be populated with
    # the object resulting from Get-Acl. If the operation was unsuccessful, the
    # referenced object will be left unchanged.
    #
    # The second argument is a reference to an object (the specific object type will
    # vary depending on the type of object/path supplied in the third argument). In
    # cases where this function needs to retrieve the object (using Get-Item) to
    # retrieve the access control entry (ACL), the referenced object will be
    # populated with the object resulting from Get-Item. If the function did not
    # need to use Get-Item, the referenced object will be left unchanged.
    #
    # The third argument is a string representing the path to the object for which
    # the ACL is to be retrieved. This path can be a file or folder path, or it can
    # be a registry path (for example).
    #
    # The function returns a boolean value indicating whether the operation was
    # successful. If the operation was successful, the object referenced in the
    # first argument will be populated with the ACL (otherwise the object
    # referenced in the first argument is not changed). If the function needed to
    # retrieve the object (using Get-Item) to get its access control list (ACL),
    # the object referenced in the second argument will be populated with the
    # object (from Get-Item), otherwise the object referenced in the second
    # argument is not changed.
    #
    # Example usage:
    # $objThisFolderPermission = $null
    # $objThis = $null
    # $strThisObjectPath = 'D:\Shares\Share\Accounting'
    # $boolSuccess = Get-AclSafely ([ref]$objThisFolderPermission) ([ref]$objThis) $strThisObjectPath
    #
    # Version 1.0.20241110.0
    #endregion FunctionHeader #####################################################

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

    #region DownloadLocationNotice #########################################
    # The most up-to-date version of this script can be found on the author's
    # GitHub repository at:
    # https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice #########################################

    function Get-ReferenceToLastError {
        #region FunctionHeader #################################################
        # Function returns $null if no errors on on the $error stack;
        # Otherwise, function returns a reference (memory pointer) to the last
        # error that occurred.
        #
        # Version: 1.0.20241105.0
        #endregion FunctionHeader #################################################

        #region License ########################################################
        # Copyright (c) 2024 Frank Lesniak
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

        #region DownloadLocationNotice #########################################
        # The most up-to-date version of this script can be found on the author's
        # GitHub repository at:
        # https://github.com/franklesniak/PowerShell_Resources
        #endregion DownloadLocationNotice #########################################

        if ($Error.Count -gt 0) {
            return ([ref]($Error[0]))
        } else {
            return $null
        }
    }

    function Test-ErrorOccurred {
        #region FunctionHeader #################################################
        # Function accepts two positional arguments:
        #
        # The first argument is a reference (memory pointer) to the last error that
        # had occurred prior to calling the command in question - that is, the
        # command that we want to test to see if an error occurred.
        #
        # The second argument is a reference to the last error that had occurred
        # as-of the completion of the command in question.
        #
        # Function returns $true if it appears that an error occurred; $false
        # otherwise
        #
        # Version: 1.0.20241105.0
        #endregion FunctionHeader #################################################

        #region License ########################################################
        # Copyright (c) 2024 Frank Lesniak
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

        #region DownloadLocationNotice #########################################
        # The most up-to-date version of this script can be found on the author's
        # GitHub repository at:
        # https://github.com/franklesniak/PowerShell_Resources
        #endregion DownloadLocationNotice #########################################

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
                $boolErrorOccurred = $true
            }
        }

        return $boolErrorOccurred
    }

    function Get-PSVersion {
        #region FunctionHeader #################################################
        # Returns the version of PowerShell that is running, including on the
        # original release of Windows PowerShell (version 1.0)
        #
        # Example:
        # Get-PSVersion
        #
        # This example returns the version of PowerShell that is running. On
        # versions of PowerShell greater than or equal to version 2.0, this
        # function returns the equivalent of $PSVersionTable.PSVersion
        #
        # The function outputs a [version] object representing the version of
        # PowerShell that is running
        #
        # PowerShell 1.0 does not have a $PSVersionTable variable, so this function
        # returns [version]('1.0') on PowerShell 1.0
        #
        # Version 1.0.20241105.0
        #endregion FunctionHeader #################################################

        #region License ########################################################
        # Copyright (c) 2024 Frank Lesniak
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

        #region DownloadLocationNotice #########################################
        # The most up-to-date version of this script can be found on the author's
        # GitHub repository at:
        # https://github.com/franklesniak/PowerShell_Resources
        #endregion DownloadLocationNotice #########################################

        if (Test-Path variable:\PSVersionTable) {
            return ($PSVersionTable.PSVersion)
        } else {
            return ([version]('1.0'))
        }
    }

    trap {
        # Intentionally left empty to prevent terminating errors from halting processing
    }

    $refOutputObjThisFolderPermission = $args[0]
    $refOutputObjThis = $args[1]
    $strThisObjectPath = $args[2]

    $objThisFolderPermission = $null
    $objThis = $null

    # Retrieve the newest error on the stack prior to doing work
    $refLastKnownError = Get-ReferenceToLastError

    # Store current error preference; we will restore it after we do our work
    $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

    # Set ErrorActionPreference to SilentlyContinue; this will suppress error output.
    # Terminating errors will not output anything, kick to the empty trap statement and then
    # continue on. Likewise, non-terminating errors will also not output anything, but they
    # do not kick to the trap statement; they simply continue on.
    $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    # This needs to be a one-liner for error handling to work!:
    if ($strThisObjectPath.Contains('[') -or $strThisObjectPath.Contains(']') -or $strThisObjectPath.Contains('`')) { $versionPS = Get-PSVersion; if ($versionPS.Major -ge 3) { $objThis = Get-Item -LiteralPath $strThisObjectPath -Force; if ($versionPS -ge ([version]'7.3')) { if (@(Get-Module Microsoft.PowerShell.Security).Count -eq 0) { Import-Module Microsoft.PowerShell.Security } $objThisFolderPermission = [System.IO.FileSystemAclExtensions]::GetAccessControl($objThis) } else { $objThisFolderPermission = $objThis.GetAccessControl() } } elseif ($versionPS.Major -eq 2) { $objThis = Get-Item -Path ((($strThisObjectPath.Replace('[', '`[')).Replace(']', '`]')).Replace('`', '``')) -Force; $objThisFolderPermission = $objThis.GetAccessControl() } else { $objThisFolderPermission = Get-Acl -Path ($strThisObjectPath.Replace('`', '``')) } } else { $objThisFolderPermission = Get-Acl -Path $strThisObjectPath }
    # The above one-liner is a messy variant of the following, which had to be
    # converted to one line to prevent PowerShell v3 from throwing errors on the stack
    # when copy-pasted into the shell (despite there not being any apparent error):
    ###################################################################################
    # TODO: Get-Acl is slow if there is latency between the folder structure and the domain controller, probably because of SID lookups. See if there is a way to speed this up without introducing external dependencies.
    # TODO: Get-Acl allegedly does not exist on PowerShell on Linux (specifically at least not on PowerShell Core v6.2.4 on Ubuntu 18.04.4 or PowerShell v7.0.0 on Ubuntu 18.04.4). Confirm this and then re-work the below to get around the issue.
    # if ($strThisObjectPath.Contains('[') -or $strThisObjectPath.Contains(']') -or $strThisObjectPath.Contains('`')) {
    #     # Can't use Get-Acl because Get-Acl doesn't support paths with brackets
    #     # or grave accent marks (backticks)
    #     $versionPS = Get-PSVersion
    #     if ($versionPS.Major -ge 3) {
    #         # PowerShell v3 and newer supports -LiteralPath
    #         $objThis = Get-Item -LiteralPath $strThisObjectPath -Force # -Force parameter is required to get hidden items
    #         if ($versionPS -ge ([version]'7.3')) {
    #             # PowerShell v7.3 and newer do not have Microsoft.PowerShell.Security
    #             # automatically loaded; likewise, the .GetAccessControl() method of
    #             # a folder or file object is missing. So, we need to load the
    #             # Microsoft.PowerShell.Security module and then call
    #             # [System.IO.FileSystemAclExtensions]::GetAccessControl()
    #             if (@(Get-Module Microsoft.PowerShell.Security).Count -eq 0) {
    #                 Import-Module Microsoft.PowerShell.Security
    #             }
    #             $objThisFolderPermission = [System.IO.FileSystemAclExtensions]::GetAccessControl($objThis)
    #         } else {
    #             # PowerShell v3 through v7.2
    #             $objThisFolderPermission = $objThis.GetAccessControl()
    #         }
    #     } elseif ($versionPS.Major -eq 2) {
    #         # We don't need to escape the right square bracket based on testing, but
    #         # we do need to escape the left square bracket. Nevertheless, escaping
    #         # both brackets does work and seems like the safest option.
    #         # Additionally, escape the grave accent mark (backtick).
    #         $objThis = Get-Item -Path ((($strThisObjectPath.Replace('[', '`[')).Replace(']', '`]')).Replace('`', '``')) -Force # -Force parameter is required to get hidden items
    #         $objThisFolderPermission = $objThis.GetAccessControl()
    #     } else {
    #         # PowerShell v1
    #         # Get-Item -> GetAccessControl() does not work and returns $null on
    #         # PowerShell v1 for some reason.
    #         # And, unfortunately, there is no apparent way to escape left square
    #         # brackets with Get-Acl. However, we can escape the grave accent mark
    #         # (backtick).
    #         $objThisFolderPermission = Get-Acl -Path ($strThisObjectPath.Replace('`', '``'))
    #     }
    # } else {
    #     # No square brackets or grave accent marks (backticks); use Get-Acl
    #     $objThisFolderPermission = Get-Acl -Path $strThisObjectPath
    # }
    ###################################################################################

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        if ($null -ne $objThis) {
            $refOutputObjThis.Value = $objThis
        }
        return $false
    } else {
        $refOutputObjThisFolderPermission.Value = $objThisFolderPermission
        if ($null -ne $objThis) {
            $refOutputObjThis.Value = $objThis
        }
        return $true
    }
}
