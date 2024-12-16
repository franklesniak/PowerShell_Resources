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
    # ReferenceToJoinedPath
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

    # Version: 1.0.20241216.1

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
        #region FunctionHeader #################################################
        # Combines two paths into a single path. This function is intended to be
        # used in situations where the Join-Path cmdlet may fail due to a variety
        # of reasons. This function is designed to suppress errors and return a
        # boolean value indicating whether the operation was successful.
        #
        # Three positional arguments are required:
        #
        # The first argument is a reference to a string object that will be
        # populated with the joined path (parent path + child path). If the
        # operation was successful, the referenced string object will be populated
        # with the joined path. If the operation was unsuccessful, the referenced
        # string will be left unchanged.
        #
        # The second argument is a string representing the parent part of the path.
        #
        # The third argument is the child part of the path.
        #
        # The function returns a boolean value indicating whether the operation was
        # successful. If the operation was successful, the joined path will be
        # populated in the string object referenced in the first argument. If the
        # operation was unsuccessful, the referenced string object will be left
        # unchanged.
        #
        # Example usage:
        # $strParentPartOfPath = 'Z:'
        # $strChildPartOfPath = '####FAKE####'
        # $strJoinedPath = $null
        # $boolSuccess = Join-PathSafely ([ref]$strJoinedPath) $strParentPartOfPath $strChildPartOfPath
        #
        # Version 1.0.20241211.1
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

        trap {
            # Intentionally left empty to prevent terminating errors from halting
            # processing
        }

        $refOutputJoinedPath = $args[0]
        $strParentPartOfPath = $args[1]
        $strChildPartOfPath = $args[2]

        $strJoinedPath = $null

        # Retrieve the newest error on the stack prior to doing work
        $refLastKnownError = Get-ReferenceToLastError

        # Store current error preference; we will restore it after we do our work
        $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

        # Set ErrorActionPreference to SilentlyContinue; this will suppress error
        # output. Terminating errors will not output anything, kick to the empty
        # trap statement and then continue on. Likewise, non-terminating errors
        # will also not output anything, but they do not kick to the trap
        # statement; they simply continue on.
        $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

        # Attempt to join the path
        $strJoinedPath = Join-Path $strParentPartOfPath $strChildPartOfPath

        # Restore the former error preference
        $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

        # Retrieve the newest error on the error stack
        $refNewestCurrentError = Get-ReferenceToLastError

        if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
            return $false
        } else {
            $refOutputJoinedPath.Value = $strJoinedPath
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
            $boolSuccess = Join-PathSafely ([ref]$strJoinedPath) $Path $strWorkingChildItemPath

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
                        $boolSuccess = Join-PathSafely ([ref]$strJoinedPath) $Path $strWorkingChildItemPath

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
