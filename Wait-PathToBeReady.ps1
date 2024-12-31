function Wait-PathToBeReady {
    # .SYNOPSIS
    # Waits for the specified path to be available. Also tests that a Join-Path
    # operation can be performed on the specified path and a child item
    #
    # .DESCRIPTION
    # This function waits for the specified path to be available. It also tests that a
    # Join-Path operation can be performed on the specified path and a child item
    #
    # .PARAMETER ReferenceToJoinedPath
    # This parameter is a memory reference to a string variable that will be populated
    # with the joined path (parent path + child path). If no child path was specified,
    # then the parent path will be populated in the referenced variable.
    #
    # .PARAMETER ReferenceToUseGetPSDriveWorkaround
    # This parameter is a memory reference to a boolean variable that indicates whether
    # or not the Get-PSDrive workaround should be used. If the Get-PSDrive workaround
    # is used, then the function will use the Get-PSDrive cmdlet to refresh
    # PowerShell's "understanding" of the available drive letters. This variable is
    # passed by reference to ensure that this function can set the variable to $true if
    # the Get-PSDrive workaround is successful - which improves performance of
    # subsequent runs.
    #
    # .PARAMETER Path
    # This parameter is a string containing the path to be tested for availability, and
    # the parent path to be used in the Join-Path operation. If no child path is
    # specified in the parameter ChildItemPath, then the contents of the Path parameter
    # will populated into the variable referenced in the parameter
    # ReferenceToJoinedPath.
    #
    # .PARAMETER ChildItemPath
    # This parameter is a string containing the child path to be used in the Join-Path
    # operation. If ChildItemPath is not specified, or if it contains $null or a blank
    # string, then the path specified by the Path parameter will be populated into the
    # variable referenced in the parameter ReferenceToJoinedPath. However, if
    # ChildItemPath contains a string containing data, then the path specified by the
    # Path parameter will be used as the parent path in the Join-Path operation, and
    # the ChildItemPath will be used as the child path in the Join-Path operation. The
    # joined path will be populated into the variable referenced in the parameter
    # ReferenceToJoinedPath.
    #
    # .PARAMETER MaximumWaitTimeInSeconds
    # This parameter is the maximum amount of seconds to wait for the path to be ready.
    # If the path is not ready within this time, then the function will return $false.
    # By default, this parameter is set to 10 seconds.
    #
    # .PARAMETER DoNotAttemptGetPSDriveWorkaround
    # This parameter is a switch that indicates that the Get-PSDrive workaround should
    # not be attempted. This switch is useful if you know that the Get-PSDrive
    # workaround will not work on your system, or if you know that the Get-PSDrive
    # workaround is not necessary on your system.
    #
    # .EXAMPLE
    # $strJoinedPath = ''
    # $boolUseGetPSDriveWorkaround = $false
    # $boolPathAvailable = Wait-PathToBeReady -Path 'D:\Shares\Share\Data' -ChildItemPath 'Subfolder' -ReferenceToJoinedPath ([ref]$strJoinedPath) -ReferenceToUseGetPSDriveWorkaround ([ref]$boolUseGetPSDriveWorkaround)
    #
    # .OUTPUTS
    # A boolean value indiciating whether the path is available
    #
    # .NOTES
    # This function also supports the use of positional parameters instead of named
    # parameters. If positional parameters are used intead of named parameters,
    # then three to five positional parameters are required:
    #
    # The first positional parameter is a memory reference to a string variable
    # that will be populated with the joined path (parent path + child path). If no
    # child path was specified, then the parent path will be populated in the
    # referenced variable.
    #
    # The second positional parameter is a memory reference to a boolean variable
    # that indicates whether or not the Get-PSDrive workaround should be used. If
    # the Get-PSDrive workaround is used, then the function will use the
    # Get-PSDrive cmdlet to refresh PowerShell's "understanding" of the available
    # drive letters. This variable is passed by reference to ensure that this
    # function can set the variable to $true if the Get-PSDrive workaround is
    # successful - which improves performance of subsequent runs.
    #
    # The third positional parameter is a string containing the path to be tested
    # for availability, and the parent path to be used in the Join-Path operation.
    # If no child path is specified in the fourth positional parameter, then the
    # contents of the Path parameter will populated into the variable referenced in
    # the first positional parameter.
    #
    # The fourth positional parameter is optional; if supplied, it is a string
    # containing the child path to be used in the Join-Path operation. If it is not
    # specified, or if it contains $null or a blank string, then the path specified
    # by the third positional parameter will be populated into the variable
    # referenced in the first positional parameter. However, if this fourth
    # positional parameter contains a string containing data, then the path
    # specified by the third positional parameter will be used as the parent path
    # in the Join-Path operation, and this fourth positional parameter will be used
    # as the child path in the Join-Path operation. The joined path will be
    # populated into the variable referenced in the first positional parameter.
    #
    # The fifth positional parameter is optional; if supplied, it is the maximum
    # amount of seconds to wait for the path to be ready. If the path is not ready
    # within this time, then the function will return $false. By default, this
    # parameter is set to 10 seconds.
    #
    # Version: 1.0.20241231.0

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

    #region DownloadLocationNotice #############################################
    # The most up-to-date version of this script can be found on the author's
    # GitHub repository at:
    # https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice #############################################

    param (
        [System.Management.Automation.PSReference]$ReferenceToJoinedPath = ([ref]$null),
        [System.Management.Automation.PSReference]$ReferenceToUseGetPSDriveWorkaround = ([ref]$null),
        [string]$Path,
        [string]$ChildItemPath = '',
        [int]$MaximumWaitTimeInSeconds = 10,
        [switch]$DoNotAttemptGetPSDriveWorkaround
    )

    function Join-PathSafely {
        # .SYNOPSIS
        # Joins two path parts together and suppresses any errors that may occur.
        #
        # .DESCRIPTION
        # Combines two paths parts (parent and child) into a single path. This
        # function is intended to be used in situations where the Join-Path cmdlet
        # may fail due to a variety of reasons. This function is designed to
        # suppress errors and return a boolean value indicating whether the
        # operation was successful.
        #
        # .PARAMETER ReferenceToJoinedPath
        # This parameter is required; it is a reference to a string object that
        # will be populated with the joined path (parent path + child path). If the
        # operation was successful, the referenced string object will be populated
        # with the joined path. If the operation was unsuccessful, the referenced
        # string is undefined.
        #
        # .PARAMETER ParentPath
        # This parameter is required; it is a string representing the parent part
        # of the path.
        #
        # .PARAMETER ChildPath
        # This parameter is required; it is the child part of the path.
        #
        # .EXAMPLE
        # $strParentPartOfPath = 'Z:'
        # $strChildPartOfPath = '####FAKE####'
        # $strJoinedPath = $null
        # $boolSuccess = Join-PathSafely -ReferenceToJoinedPath ([ref]$strJoinedPath) -ParentPath $strParentPartOfPath -ChildPath $strChildPartOfPath
        #
        # .EXAMPLE
        # $strParentPartOfPath = 'Z:'
        # $strChildPartOfPath = '####FAKE####'
        # $strJoinedPath = $null
        # $boolSuccess = Join-PathSafely ([ref]$strJoinedPath) $strParentPartOfPath $strChildPartOfPath
        #
        # .INPUTS
        # None. You can't pipe objects to Join-PathSafely.
        #
        # .OUTPUTS
        # System.Boolean. Join-PathSafely returns a boolean value indiciating
        # whether the process completed successfully. $true means the process
        # completed successfully; $false means there was an error.
        #
        # .NOTES
        # This function also supports the use of positional parameters instead of
        # named parameters. If positional parameters are used intead of named
        # parameters, then three positional parameters are required:
        #
        # The first positional parameter is a reference to a string object that
        # will be populated with the joined path (parent path + child path). If the
        # operation was successful, the referenced string object will be populated
        # with the joined path. If the operation was unsuccessful, the referenced
        # string is undefined.
        #
        # The second positional parameter is a string representing the parent part
        # of the path.
        #
        # The third positional parameter is the child part of the path.
        #
        # Version: 2.0.20241231.0

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

        param (
            [ref]$ReferenceToJoinedPath = ([ref]$null),
            [string]$ParentPath = '',
            [string]$ChildPath = ''
        )

        #region FunctionsToSupportErrorHandling ################################
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
        #endregion FunctionsToSupportErrorHandling ################################

        trap {
            # Intentionally left empty to prevent terminating errors from halting
            # processing
        }

        #region Process Input ##################################################
        if ([string]::IsNullOrEmpty($ParentPath)) {
            Write-Warning "In the function Join-PathSafely(), the ParentPath parameter is required and cannot be null or empty."
            return $false
        }
        #endregion Process Input ##################################################

        # Retrieve the newest error on the stack prior to doing work
        $refLastKnownError = Get-ReferenceToLastError

        # Store current error preference; we will restore it after we do the work
        # of this function
        $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

        # Set ErrorActionPreference to SilentlyContinue; this will suppress error
        # output. Terminating errors will not output anything, kick to the empty
        # trap statement and then continue on. Likewise, non-terminating errors
        # will also not output anything, but they do not kick to the trap
        # statement; they simply continue on.
        $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

        # Attempt to join the path
        ($ReferenceToJoinedPath.Value) = Join-Path -Path $ParentPath -ChildPath $ChildPath

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

    #region Process Input ######################################################
    if ([string]::IsNullOrEmpty($Path) -eq $true) {
        Write-Error 'When calling Wait-PathToBeReady, the Path parameter cannot be null or empty'
        return $false
    }

    if ($DoNotAttemptGetPSDriveWorkaround.IsPresent -eq $true) {
        $boolAttemptGetPSDriveWorkaround = $false
    } else {
        $boolAttemptGetPSDriveWorkaround = $true
    }
    #endregion Process Input ######################################################

    $NONEXISTENT_CHILD_FOLDER = '###FAKE###'
    $boolFunctionReturn = $false

    if ([string]::IsNullOrEmpty($ChildItemPath) -eq $true) {
        $strWorkingChildItemPath = $NONEXISTENT_CHILD_FOLDER
    } else {
        $strWorkingChildItemPath = $ChildItemPath
    }

    if ($null -ne ($ReferenceToUseGetPSDriveWorkaround.Value)) {
        if (($ReferenceToUseGetPSDriveWorkaround.Value) -eq $true) {
            # Use workaround for drives not refreshing in current PowerShell
            # session
            Get-PSDrive | Out-Null
        }
    }

    $doubleSecondsCounter = 0

    # Try Join-Path and sleep for up to $MaximumWaitTimeInSeconds seconds until
    # it's successful
    while ($doubleSecondsCounter -le $MaximumWaitTimeInSeconds -and $boolFunctionReturn -eq $false) {
        if (Test-Path $Path) {
            $strJoinedPath = $null
            $boolSuccess = Join-PathSafely -ReferenceToJoinedPath ([ref]$strJoinedPath) -ParentPath $Path -ChildPath $strWorkingChildItemPath

            if ($boolSuccess -eq $false) {
                Start-Sleep 0.2
                $doubleSecondsCounter += 0.2
            } else {
                $boolFunctionReturn = $true
            }
        } else {
            Start-Sleep 0.2
            $doubleSecondsCounter += 0.2
        }
    }

    if ($boolFunctionReturn -eq $false) {
        if ($null -eq ($ReferenceToUseGetPSDriveWorkaround.Value) -or ($ReferenceToUseGetPSDriveWorkaround.Value) -eq $false) {
            # Either a variable was not passed in, or the variable was passed in
            # and it was set to false
            if ($boolAttemptGetPSDriveWorkaround -eq $true) {
                # Try workaround for drives not refreshing in current PowerShell
                # session
                Get-PSDrive | Out-Null

                # Restart counter and try waiting again
                $doubleSecondsCounter = 0

                # Try Join-Path and sleep for up to $MaximumWaitTimeInSeconds
                # seconds until it's successful
                while ($doubleSecondsCounter -le $MaximumWaitTimeInSeconds -and $boolFunctionReturn -eq $false) {
                    if (Test-Path $Path) {
                        $strJoinedPath = $null
                        $boolSuccess = Join-PathSafely -ReferenceToJoinedPath ([ref]$strJoinedPath) -ParentPath $Path -ChildPath $strWorkingChildItemPath

                        if ($boolSuccess -eq $false) {
                            Start-Sleep 0.2
                            $doubleSecondsCounter += 0.2
                        } else {
                            $boolFunctionReturn = $true
                            if ($null -ne ($ReferenceToUseGetPSDriveWorkaround.Value)) {
                                $ReferenceToUseGetPSDriveWorkaround.Value = $true
                            }
                        }
                    } else {
                        Start-Sleep 0.2
                        $doubleSecondsCounter += 0.2
                    }
                }
            }
        }
    }

    if ([string]::IsNullOrEmpty($strChildFolderOfTarget) -eq $true) {
        $strJoinedPath = $Path
    }

    if ($null -ne $ReferenceToJoinedPath.Value) {
        $ReferenceToJoinedPath.Value = $strJoinedPath
    }

    return $boolFunctionReturn
}
