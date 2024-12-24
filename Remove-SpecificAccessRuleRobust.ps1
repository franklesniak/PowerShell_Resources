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
    # The specified access rule being removed must not be inherited. If the access
    # rule is inherited, the function will attempt to remove the access rule but
    # will not succeed in doing so; yet will not throw an error. See the example
    # for a demonstration of how to handle inherited access rules.
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
    # $boolCheckForType = $true
    # $boolRunGetAcl = $true
    # $strPath = 'D:\Shared\Human_Resources'
    # if ($strPath.Length -gt 248) {
    #     if ($strPath.Substring(0, 2) -eq '\\') {
    #         $strPath = '\\?\UNC\' + $strPath.Substring(2)
    #     } else {
    #         $strPath = '\\?\' + $strPath
    #     }
    # }
    # $objDirectoryInfo = Get-Item -Path $strPath
    # if (@(@($objDirectoryInfo.PSObject.Methods) | Where-Object { $_.Name -eq 'GetAccessControl' }).Count -ge 1) {
    #     # The GetAccessControl() method is available on .NET Framework 2.x - 4.x
    #     $objDirectorySecurity = $objDirectoryInfo.GetAccessControl()
    # } else {
    #     # The GetAccessControl() method is not available - this is expected on
    #     # PowerShell Core 6.x and later
    #     if ($boolCheckForType) {
    #         $boolTypeNameAvailable = @([System.AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object { $_.GetType('System.IO.FileSystemAclExtensions') } | Where-Object { $_ }).Count -ge 1
    #         if (-not $boolTypeNameAvailable) {
    #             Add-Type -AssemblyName System.IO.FileSystem.AccessControl
    #             $boolCheckForType = $false
    #         }
    #     }
    #     $objDirectorySecurity = [System.IO.FileSystemAclExtensions]::GetAccessControl($objDirectoryInfo)
    #     # $objDirectorySecurity is created but may appear empty/uninitialized.
    #     # This is because the object is missing additional properties that
    #     # correspond to the way that PowerShell displays this object. You can fix
    #     # this by running Get-Acl on any other object that has an ACL; once you
    #     # do that, the $objDirectorySecurity object will have the "missing"
    #     # properties and will display correctly in the console.
    #     if ($boolRunGetAcl) {
    #         $arrCommands = @(Get-Command -Name 'Get-Acl' -ErrorAction SilentlyContinue)
    #         if ($arrCommands.Count -gt 0) {
    #             [void](Get-Acl -Path $HOME)
    #         }
    #         $boolRunGetAcl = $false
    #     }
    # }
    # $arrFileSystemAccessRules = @($objDirectorySecurity.Access)
    #
    # # Pick a random access control entry to remove:
    # $objAccessRuleToRemove = $arrFileSystemAccessRules[0]
    #
    # if ($objAccessRuleToRemove.IsInherited) {
    #     # If the access rule is inherited, we need to disable inheritance in the
    #     # access control list first
    #     $objDirectorySecurity.SetAccessRuleProtection($true, $true)
    #     if (@(@($objDirectoryInfo.PSObject.Methods) | Where-Object { $_.Name -eq 'SetAccessControl' }).Count -ge 1) {
    #         # The SetAccessControl() method is available on .NET Framework 2.x - 4.x
    #         # Disable inheritance
    #         $objDirectoryInfo.SetAccessControl($objDirectorySecurity)
    #         # Re-fetch the access control list
    #         $objDirectorySecurity = $objDirectoryInfo.GetAccessControl()
    #         # Re-choose the access control entry to remove
    #         $arrFileSystemAccessRules = @($objDirectorySecurity.Access)
    #         $objAccessRuleToRemove = $arrFileSystemAccessRules[0]
    #     } else {
    #         # The SetAccessControl() method is not available - this is expected on
    #         # PowerShell Core 6.x and later
    #         if ($boolCheckForType) {
    #             $boolTypeNameAvailable = @([System.AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object { $_.GetType('System.IO.FileSystemAclExtensions') } | Where-Object { $_ }).Count -ge 1
    #             if (-not $boolTypeNameAvailable) {
    #                 Add-Type -AssemblyName System.IO.FileSystem.AccessControl
    #             }
    #         }
    #         # Disable inheritance
    #         [System.IO.FileSystemAclExtensions]::SetAccessControl($objDirectoryInfo, $objDirectorySecurity)
    #         # Re-fetch the access control list
    #         $objDirectorySecurity = [System.IO.FileSystemAclExtensions]::GetAccessControl($objDirectoryInfo)
    #         # $objDirectorySecurity is created but may appear empty/uninitialized.
    #         # This is because the object is missing additional properties that
    #         # correspond to the way that PowerShell displays this object. You can fix
    #         # this by running Get-Acl on any other object that has an ACL; once you
    #         # do that, the $objDirectorySecurity object will have the "missing"
    #         # properties and will display correctly in the console.
    #         if ($boolRunGetAcl) {
    #             $arrCommands = @(Get-Command -Name 'Get-Acl' -ErrorAction SilentlyContinue)
    #             if ($arrCommands.Count -gt 0) {
    #                 [void](Get-Acl -Path $HOME)
    #             }
    #             $boolRunGetAcl = $false
    #         }
    #         # Re-choose the access control entry to remove
    #         $arrFileSystemAccessRules = @($objDirectorySecurity.Access)
    #         $objAccessRuleToRemove = $arrFileSystemAccessRules[0]
    #     }
    # }
    #
    # # Remove the access rule
    # $boolSuccess = Remove-SpecificAccessRuleRobust -CurrentAttemptNumber 1 -MaxAttempts 8 -ReferenceToAccessControlListObject ([ref]$objDirectorySecurity) -ReferenceToAccessRuleObject ([ref]$objAccessRuleToRemove)
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
    # Version: 1.1.20241223.2

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
        # .SYNOPSIS
        # Gets a reference (memory pointer) to the last error that occurred.
        #
        # .DESCRIPTION
        # Returns a reference (memory pointer) to $null ([ref]$null) if no
        # errors on on the $error stack; otherwise, returns a reference to the
        # last error that occurred.
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
        #     # So:
        #     # If both are null, no error
        #     # If $refLastKnownError is null and $refNewestCurrentError is
        #     # non-null, error
        #     # If $refLastKnownError is non-null and $refNewestCurrentError is
        #     # null, no error
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
        # Get-ReferenceToLastError returns a reference (memory pointer) to the
        # last error that occurred. It returns a reference to $null
        # ([ref]$null) if there are no errors on on the $error stack.
        #
        # .NOTES
        # Version: 2.0.20241223.0

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
            return ([ref]$null)
        }
    }

    function Test-ErrorOccurred {
        # .SYNOPSIS
        # Checks to see if an error occurred during a time period, i.e., during
        # the execution of a command.
        #
        # .DESCRIPTION
        # Using two references (memory pointers) to errors, this function
        # checks to see if an error occurred based on differences between the
        # two errors.
        #
        # To use this function, you must first retrieve a reference to the last
        # error that occurred prior to the command you are about to run. Then,
        # run the command. After the command completes, retrieve a reference to
        # the last error that occurred. Pass these two references to this
        # function to determine if an error occurred.
        #
        # .PARAMETER ReferenceToEarlierError
        # This parameter is required; it is a reference (memory pointer) to a
        # System.Management.Automation.ErrorRecord that represents the newest
        # error on the stack earlier in time, i.e., prior to running the
        # command for which you wish to determine whether an error occurred.
        #
        # If no error was on the stack at this time, ReferenceToEarlierError
        # must be a reference to $null ([ref]$null).
        #
        # .PARAMETER ReferenceToLaterError
        # This parameter is required; it is a reference (memory pointer) to a
        # System.Management.Automation.ErrorRecord that represents the newest
        # error on the stack later in time, i.e., after to running the command
        # for which you wish to determine whether an error occurred.
        #
        # If no error was on the stack at this time, ReferenceToLaterError
        # must be a reference to $null ([ref]$null).
        #
        # .EXAMPLE
        # # Intentionally empty trap statement to prevent terminating errors
        # # from halting processing
        # trap { }
        #
        # # Retrieve the newest error on the stack prior to doing work
        # if ($Error.Count -gt 0) {
        #     $refLastKnownError = ([ref]($Error[0]))
        # } else {
        #     $refLastKnownError = ([ref]$null)
        # }
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
        # System.Boolean. Test-ErrorOccurred returns a boolean value indicating
        # whether an error occurred during the time period in question. $true
        # indicates an error occurred; $false indicates no error occurred.
        #
        # .NOTES
        # This function also supports the use of positional parameters instead
        # of named parameters. If positional parameters are used intead of
        # named parameters, then two positional parameters are required:
        #
        # The first positional parameter is a reference (memory pointer) to a
        # System.Management.Automation.ErrorRecord that represents the newest
        # error on the stack earlier in time, i.e., prior to running the
        # command for which you wish to determine whether an error occurred. If
        # no error was on the stack at this time, the first positional
        # parameter must be a reference to $null ([ref]$null).
        #
        # The second positional parameter is a reference (memory pointer) to a
        # System.Management.Automation.ErrorRecord that represents the newest
        # error on the stack later in time, i.e., after to running the command
        # for which you wish to determine whether an error occurred. If no
        # error was on the stack at this time, ReferenceToLaterError must be
        # a reference to $null ([ref]$null).
        #
        # Version: 2.0.20241223.0

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
            # $ReferenceToLaterError could be null if $error was cleared; this
            # does not indicate an error.
            # So:
            # - If both are null, no error
            # - If $ReferenceToEarlierError is null and $ReferenceToLaterError
            #   is non-null, error
            # - If $ReferenceToEarlierError is non-null and
            #   $ReferenceToLaterError is null, no error
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

    if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
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
