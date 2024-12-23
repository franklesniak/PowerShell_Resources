function Write-ACLToObject {
    # .SYNOPSIS
    # Writes an access control list to an object
    #
    # .DESCRIPTION
    # After making changes to an access control list (ACL), it must be written back
    # to its source object for it to take effect. This function calls the
    # .SetAccessControl() method of an object to set the ACL. If the process fails,
    # this script supresses the error from being displayed on screen and, instead,
    # returns a failure result code.
    #
    # .PARAMETER CurrentAttemptNumber
    # This parameter is required; it is an integer indicating the current attempt
    # number. When calling this function for the first time, it should be 1.
    #
    # .PARAMETER MaxAttempts
    # This parameter is required; it is an integer representing the maximum number
    # of attempts that the function will observe before giving up.
    #
    # .PARAMETER ReferenceToTargetObject
    # This parameter is required; it is a reference to a System.IO.DirectoryInfo,
    # System.IO.FileInfo, or similar object where the access control list (ACL)
    # will be written.
    #
    # .PARAMETER ReferenceToACL
    # This parameter is required; it is a reference to a
    # System.Security.AccessControl.DirectorySecurity,
    # System.Security.AccessControl.FileSecurity, or similar object that will be
    # written to the target object.
    #
    # .PARAMETER DoNotCheckForType
    # This parameter is an optional switch statement. If supplied, it prevents this
    # function for checking for the availability of the
    # System.IO.FileSystemAclExtensions type, which can improve performance when it
    # is known to be available
    #
    # .EXAMPLE
    # $strPath = 'C:\Users\Public\Documents'
    # $objDirectoryInfo = Get-Item -Path $strPath
    # $objDirectorySecurity = Get-Acl -Path $strPath
    # # Do something to change the ACL here...
    # $boolSucccess = Write-ACLToObject -CurrentAttemptNumber 1 -MaxAttempts 4 -ReferenceToTargetObject ([ref]$objDirectoryInfo) -ReferenceToACL ([ref]$objDirectorySecurity)
    #
    # .EXAMPLE
    # $boolCheckForType = $true
    # $boolRunGetAcl = $true
    # $strPath = 'C:\Users\Public\Documents'
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
    # # <Do something to change the ACL here...>
    # $boolSucccess = Write-ACLToObject -CurrentAttemptNumber 1 -MaxAttempts 4 -ReferenceToTargetObject ([ref]$objDirectoryInfo) -ReferenceToACL ([ref]$objDirectorySecurity)
    #
    # .EXAMPLE
    # $hashtableConfigIni = $null
    # $intReturnCode = Write-ACLToObject ([ref]$hashtableConfigIni) 1 4 '.\config.ini' @(';') $true $true 'NoSection' $true
    #
    # .INPUTS
    # None. You can't pipe objects to Write-ACLToObject.
    #
    # .OUTPUTS
    # System.Boolean. Write-ACLToObject returns a boolean value indiciating whether
    # the process completed successfully. $true means the process completed
    # successfully; $false means there was an error.
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
    # The third positional parameter is a reference to a System.IO.DirectoryInfo,
    # System.IO.FileInfo, or similar object where the access control list (ACL)
    # will be written.
    #
    # The fourth positional parameter is a reference to a
    # System.Security.AccessControl.DirectorySecurity,
    # System.Security.AccessControl.FileSecurity, or similar object that will be
    # written to the target object.
    #
    # Version: 2.0.20241223.0

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
    # One of the examples in the function header is derived from several chats with
    # OpenAI's ChatGPT. Link 1:
    # https://chatgpt.com/share/67688673-1e5c-8006-b5a3-f931e0b0e19f. Link 2:
    # https://chatgpt.com/share/676886a1-0514-8006-abb0-71e0194ce39f.
    # Both links accessed on 2024-12-22.
    #endregion Acknowledgements ###################################################

    param (
        [int]$CurrentAttemptNumber = 1,
        [int]$MaxAttempts = 1,
        [ref]$ReferenceToTargetObject = [ref]$null,
        [ref]$ReferenceToACL = [ref]$null,
        [switch]$DoNotCheckForType
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

    function Test-TypeNameAvailability {
        # .SYNOPSIS
        # Tests to see if a type is available.
        #
        # .DESCRIPTION
        # Determines if a type name is available for use. Returns $true if the type
        # name is available in the current context; returns $false if it is not
        # available.
        #
        # .PARAMETER TypeName
        # This parameter is required; it is a string that contains the name of the type
        # for which the function will determine availability.
        #
        # .EXAMPLE
        # $boolTypeAvailable = Test-TypeNameAvailability -TypeName 'Microsoft.Exchange.Data.RecipientAccessRight'
        #
        # .EXAMPLE
        # $boolTypeAvailable = Test-TypeNameAvailability 'Microsoft.Exchange.Data.RecipientAccessRight'
        #
        # .INPUTS
        # None. You can't pipe objects to Test-TypeNameAvailability.
        #
        # .OUTPUTS
        # System.Boolean. Test-TypeNameAvailability returns a boolean value indicating
        # whether the type is available in the current context. The function returns
        # $true if the type name is available in the current context; $false otherwise.
        #
        # .NOTES
        # This function also supports the use of a positional parameter instead of a
        # named parameter. If a positional parameter is used intead of a named
        # parameter, then exactly one positional parameters is required: it is a string
        # that contains the name of the type for which the function will determine
        # availability.
        #
        # Version: 2.0.20241220.0

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
        # This function is derived from a chat with OpenAI's ChatGPT:
        # https://chatgpt.com/share/67659f90-1d90-8006-a127-8d2d0b897054
        # retrieved on 2024-12-20
        #endregion Acknowledgements ###################################################

        param (
            [string]$TypeName = ''
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

        # TODO: Perform additional input validation
        if ([string]::IsNullOrEmpty($TypeName)) {
            return $false
        }

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

        # Test to see if the type name is available
        $boolTypeNameAvailable = @([System.AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object { $_.GetType($TypeName) } | Where-Object { $_ }).Count -ge 1

        # Restore the former error preference
        $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

        # Retrieve the newest error on the error stack
        $refNewestCurrentError = Get-ReferenceToLastError

        if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
            # Error occurred; we're not returning a failure indicator, though.

            return $boolTypeNameAvailable
        } else {
            # No error occurred; but, again, we're not returning a success code.

            return $boolTypeNameAvailable
        }
    }

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    # TODO: Validate input

    $boolCheckForType = $true
    if ($null -ne $DoNotCheckForType) {
        if ($DoNotCheckForType.IsPresent) {
            $boolCheckForType = $false
        }
    }

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

    # The following code is representative of what we are trying to do, but it's
    # commented-out because PowerShell v1-style error handling requires that all
    # code you want to error-handle be on one line
    ###############################################################################
    # # Set the ACL on the target object
    # if (@(@(($ReferenceToTargetObject.Value).PSObject.Methods) | Where-Object { $_.Name -eq 'SetAccessControl' }).Count -ge 1) {
    #     # The SetAccessControl() method is available on .NET Framework 2.x - 4.x
    #     ($ReferenceToTargetObject.Value).SetAccessControl($ReferenceToACL.Value)
    # } else {
    #     # The SetAccessControl() method is not available - this is expected on
    #     # PowerShell Core 6.x and later
    #     if ($boolCheckForType) {
    #         $boolTypeNameAvailable = Test-TypeNameAvailability -TypeName 'System.IO.FileSystemAclExtensions'
    #         if (-not $boolTypeNameAvailable) {
    #             Add-Type -AssemblyName System.IO.FileSystem.AccessControl
    #         }
    #     }
    #     [System.IO.FileSystemAclExtensions]::SetAccessControl($ReferenceToTargetObject.Value, $ReferenceToACL.Value)
    # }
    ###############################################################################
    # Here is the above code translated to a represenative one-liner:
    if (@(@(($ReferenceToTargetObject.Value).PSObject.Methods) | Where-Object { $_.Name -eq 'SetAccessControl' }).Count -ge 1) { ($ReferenceToTargetObject.Value).SetAccessControl($ReferenceToACL.Value) } else { if ($boolCheckForType) { $boolTypeNameAvailable = Test-TypeNameAvailability -TypeName 'System.IO.FileSystemAclExtensions'; if (-not $boolTypeNameAvailable) { Add-Type -AssemblyName System.IO.FileSystem.AccessControl } }; [System.IO.FileSystemAclExtensions]::SetAccessControl($ReferenceToTargetObject.Value, $ReferenceToACL.Value) }

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        # Error occurred
        if ($CurrentAttemptNumber -lt $MaxAttempts) {
            Start-Sleep -Seconds ([math]::Pow(2, $CurrentAttemptNumber))

            $objResultIndicator = Write-ACLToObject -CurrentAttemptNumber ($CurrentAttemptNumber + 1) -MaxAttempts $MaxAttempts -ReferenceToTargetObject $ReferenceToTargetObject -ReferenceToACL $ReferenceToACL
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
