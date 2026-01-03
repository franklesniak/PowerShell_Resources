function New-File {
    # .SYNOPSIS
    # Creates or overwrites a file at the specified path to test write access.
    #
    # .DESCRIPTION
    # This helper function attempts to create or overwrite a file at the
    # specified path. It uses .NET Framework methods to ensure cross-platform
    # compatibility and proper resource cleanup. The function is designed to
    # detect write permission issues, locked files, invalid paths, and other IO
    # errors.
    #
    # .PARAMETER Path
    # This parameter is required; it is a string representing the file path where
    # the file should be created or overwritten.
    #
    # .PARAMETER ReferenceToErrorRecord
    # This parameter is optional; if supplied, it is a reference to an
    # ErrorRecord object. If the file creation fails, this reference will be
    # populated with the error details. If the creation succeeds, this reference
    # will be set to $null.
    #
    # .EXAMPLE
    # $intReturnCode = New-File -Path 'C:\Temp\test.txt'
    # if ($intReturnCode -eq 0) {
    #     Write-Host 'File created successfully'
    # } else {
    #     Write-Host 'File creation failed'
    # }
    #
    # .INPUTS
    # None. You can't pipe objects to New-File.
    #
    # .OUTPUTS
    # System.Int32. New-File returns an integer status code indicating whether
    # the file creation completed successfully. 0 means success. The file was
    # created or overwritten successfully. -1 means failure. An error occurred
    # during the file creation operation.
    #
    # .NOTES
    # This function supports Windows PowerShell 1.0 with .NET Framework 2.0 or
    # newer, newer versions of Windows PowerShell (at least up to and including
    # Windows PowerShell 5.1 with .NET Framework 4.8 or newer), PowerShell Core
    # 6.x, and PowerShell 7.x. This function supports Windows and, when run on
    # PowerShell Core 6.x or PowerShell 7.x, also supports macOS and Linux.
    #
    # This function also supports the use of positional parameters instead of
    # named parameters. If positional parameters are used instead of named
    # parameters, then two positional parameters are required:
    #
    # The first positional parameter is a string representing the file path.
    #
    # The second positional parameter is a reference to an ErrorRecord object.
    #
    # Version: 1.0.20260103.0

    param (
        [string]$Path = '',
        [ref]$ReferenceToErrorRecord = ([ref]$null)
    )

    #region License ########################################################
    # Copyright (c) 2026 Frank Lesniak
    #
    # Permission is hereby granted, free of charge, to any person obtaining a
    # copy of this software and associated documentation files (the
    # "Software"), to deal in the Software without restriction, including
    # without limitation the rights to use, copy, modify, merge, publish,
    # distribute, sublicense, and/or sell copies of the Software, and to
    # permit persons to whom the Software is furnished to do so, subject to
    # the following conditions:
    #
    # The above copyright notice and this permission notice shall be included
    # in all copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    # OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    # IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    # CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    # TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    # SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #endregion License ########################################################

    #region FunctionsToSupportErrorHandling ####################################
    function Get-ReferenceToLastError {
        # .SYNOPSIS
        # Gets a reference (memory pointer) to the last error that
        # occurred.
        #
        # .DESCRIPTION
        # Returns a reference (memory pointer) to $null ([ref]$null) if no
        # errors on the $error stack; otherwise, returns a reference to
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
        #     # If $refLastKnownError is non-null and
        #     # $refNewestCurrentError is null, no error.
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
        # ([ref]$null) if there are no errors on the $error stack.
        #
        # .NOTES
        # This function accepts no parameters.
        #
        # This function is compatible with Windows PowerShell 1.0+ (with
        # .NET Framework 2.0 or newer), PowerShell Core 6.x, and PowerShell
        # 7.x on Windows, macOS, and Linux.
        #
        # Design Note: This function returns a [ref] object directly rather
        # than following the author's standard v1.0 pattern of returning an
        # integer status code. This design is intentional, as the
        # function's sole purpose is to provide a reference for error
        # tracking. Requiring a [ref] parameter would add unnecessary
        # complexity to the calling pattern.
        #
        # Version: 2.0.20251226.0

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

        param()

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
        # Version: 2.0.20251226.0

        param (
            [ref]$ReferenceToEarlierError = ([ref]$null),
            [ref]$ReferenceToLaterError = ([ref]$null)
        )

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

    #region HelperFunctions ####################################################
    function Remove-File {
        # .SYNOPSIS
        # Deletes a file at the specified path.
        #
        # .DESCRIPTION
        # This helper function attempts to delete a file at the specified path. It
        # uses .NET Framework methods to ensure cross-platform compatibility. If the
        # file does not exist, the function treats this as a successful operation (no
        # error). The function is designed to detect permission issues, locked files,
        # and other IO errors.
        #
        # .PARAMETER Path
        # This parameter is required; it is a string representing the file path to
        # delete.
        #
        # .PARAMETER ReferenceToErrorRecord
        # This parameter is optional; if supplied, it is a reference to an
        # ErrorRecord object. If the file deletion fails, this reference will be
        # populated with the error details. If the deletion succeeds, this reference
        # will be set to $null.
        #
        # .EXAMPLE
        # $intReturnCode = Remove-File -Path 'C:\Temp\test.txt'
        # if ($intReturnCode -eq 0) {
        #     Write-Host 'File deleted successfully'
        # } else {
        #     Write-Host 'File deletion failed'
        # }
        #
        # .EXAMPLE
        # $intReturnCode = Remove-File -Path 'C:\Temp\nonexistent.txt'
        # # Returns 0 because the file does not exist (treated as success)
        #
        # .EXAMPLE
        # $errRecord = $null
        # $intReturnCode = Remove-File -Path 'C:\Temp\locked.txt' -ReferenceToErrorRecord ([ref]$errRecord)
        # if ($intReturnCode -ne 0) {
        #     Write-Warning "Failed to delete file: $($errRecord.Exception.Message)"
        # }
        # # Demonstrates capturing error details when deletion fails (e.g., file is locked
        # # or permissions are insufficient)
        #
        # .EXAMPLE
        # $errRecord = $null
        # $intReturnCode = Remove-File 'C:\Temp\test.txt' ([ref]$errRecord)
        # # Demonstrates using positional parameters. First positional parameter is the
        # # file path, second is the reference to error record.
        #
        # .INPUTS
        # None. You can't pipe objects to Remove-File.
        #
        # .OUTPUTS
        # System.Int32. Remove-File returns an integer status code indicating whether
        # the file deletion completed successfully. 0 means success. The file was
        # deleted successfully, or the file did not exist. -1 means failure. An error
        # occurred during the file deletion operation.
        #
        # .NOTES
        # This function supports Windows PowerShell 1.0 with .NET Framework 2.0 or
        # newer, newer versions of Windows PowerShell (at least up to and including
        # Windows PowerShell 5.1 with .NET Framework 4.8 or newer), PowerShell Core
        # 6.x, and PowerShell 7.x. This function supports Windows and, when run on
        # PowerShell Core 6.x or PowerShell 7.x, also supports macOS and Linux.
        #
        # This function also supports the use of positional parameters instead of
        # named parameters. If positional parameters are used instead of named
        # parameters, then two positional parameters are required:
        #
        # The first positional parameter is a string representing the file path.
        #
        # The second positional parameter is a reference to an ErrorRecord object.
        #
        # Version: 1.0.20260102.1

        param (
            [string]$Path,
            [ref]$ReferenceToErrorRecord = ([ref]$null)
        )

        #region License ########################################################
        # Copyright (c) 2026 Frank Lesniak
        #
        # Permission is hereby granted, free of charge, to any person obtaining a
        # copy of this software and associated documentation files (the
        # "Software"), to deal in the Software without restriction, including
        # without limitation the rights to use, copy, modify, merge, publish,
        # distribute, sublicense, and/or sell copies of the Software, and to
        # permit persons to whom the Software is furnished to do so, subject to
        # the following conditions:
        #
        # The above copyright notice and this permission notice shall be included
        # in all copies or substantial portions of the Software.
        #
        # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
        # OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
        # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
        # IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
        # CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
        # TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
        # SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
        #endregion License ########################################################

        #region FunctionsToSupportErrorHandling ####################################
        function Get-ReferenceToLastError {
            # .SYNOPSIS
            # Gets a reference (memory pointer) to the last error that
            # occurred.
            #
            # .DESCRIPTION
            # Returns a reference (memory pointer) to $null ([ref]$null) if no
            # errors on the $error stack; otherwise, returns a reference to
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
            #     # If $refLastKnownError is non-null and
            #     # $refNewestCurrentError is null, no error.
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
            # ([ref]$null) if there are no errors on the $error stack.
            #
            # .NOTES
            # This function accepts no parameters.
            #
            # This function is compatible with Windows PowerShell 1.0+ (with
            # .NET Framework 2.0 or newer), PowerShell Core 6.x, and PowerShell
            # 7.x on Windows, macOS, and Linux.
            #
            # Design Note: This function returns a [ref] object directly rather
            # than following the author's standard v1.0 pattern of returning an
            # integer status code. This design is intentional, as the
            # function's sole purpose is to provide a reference for error
            # tracking. Requiring a [ref] parameter would add unnecessary
            # complexity to the calling pattern.
            #
            # Version: 2.0.20251226.0

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

            param()

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
            # Version: 2.0.20251226.0

            param (
                [ref]$ReferenceToEarlierError = ([ref]$null),
                [ref]$ReferenceToLaterError = ([ref]$null)
            )

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

        #region HelperFunctions ####################################################
        function Test-FileExistence {
            # .SYNOPSIS
            # Tests whether a file exists at the specified path.
            #
            # .DESCRIPTION
            # This helper function checks whether a file exists at the specified path using
            # .NET Framework methods to ensure cross-platform compatibility. The function
            # returns a boolean value indicating the file's existence. If an error occurs
            # during the check, the function returns $false.
            #
            # .PARAMETER Path
            # This parameter is required; it is a string representing the file path to
            # test.
            #
            # .EXAMPLE
            # $boolExists = Test-FileExistence -Path 'C:\Temp\test.txt'
            # if ($boolExists) {
            #     Write-Host 'File exists'
            # } else {
            #     Write-Host 'File does not exist'
            # }
            #
            # .EXAMPLE
            # $boolExists = Test-FileExistence 'C:\Temp\test.txt'
            # # Demonstrates using positional parameters. The positional parameter is the
            # # file path.
            #
            # .INPUTS
            # None. You can't pipe objects to Test-FileExistence.
            #
            # .OUTPUTS
            # System.Boolean. Test-FileExistence returns a boolean value indicating whether
            # the file exists. $true means the file exists. $false means the file does not
            # exist or an error occurred during the check.
            #
            # .NOTES
            # This function supports Windows PowerShell 1.0 with .NET Framework 2.0 or
            # newer, newer versions of Windows PowerShell (at least up to and including
            # Windows PowerShell 5.1 with .NET Framework 4.8 or newer), PowerShell Core
            # 6.x, and PowerShell 7.x. This function supports Windows and, when run on
            # PowerShell Core 6.x or PowerShell 7.x, also supports macOS and Linux.
            #
            # This function also supports the use of positional parameters instead of
            # named parameters. If positional parameters are used instead of named
            # parameters, then one positional parameter is required:
            #
            # The first positional parameter is a string representing the file path.
            #
            # Version: 1.0.20260102.1

            param (
                [string]$Path
            )

            #region License ########################################################
            # Copyright (c) 2026 Frank Lesniak
            #
            # Permission is hereby granted, free of charge, to any person obtaining a
            # copy of this software and associated documentation files (the
            # "Software"), to deal in the Software without restriction, including
            # without limitation the rights to use, copy, modify, merge, publish,
            # distribute, sublicense, and/or sell copies of the Software, and to
            # permit persons to whom the Software is furnished to do so, subject to
            # the following conditions:
            #
            # The above copyright notice and this permission notice shall be included
            # in all copies or substantial portions of the Software.
            #
            # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
            # OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
            # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
            # IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
            # CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
            # TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
            # SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
            #endregion License ########################################################

            #region FunctionsToSupportErrorHandling ####################################
            function Get-ReferenceToLastError {
                # .SYNOPSIS
                # Gets a reference (memory pointer) to the last error that
                # occurred.
                #
                # .DESCRIPTION
                # Returns a reference (memory pointer) to $null ([ref]$null) if no
                # errors on the $error stack; otherwise, returns a reference to
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
                #     # If $refLastKnownError is non-null and
                #     # $refNewestCurrentError is null, no error.
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
                # ([ref]$null) if there are no errors on the $error stack.
                #
                # .NOTES
                # This function accepts no parameters.
                #
                # This function is compatible with Windows PowerShell 1.0+ (with
                # .NET Framework 2.0 or newer), PowerShell Core 6.x, and PowerShell
                # 7.x on Windows, macOS, and Linux.
                #
                # Design Note: This function returns a [ref] object directly rather
                # than following the author's standard v1.0 pattern of returning an
                # integer status code. This design is intentional, as the
                # function's sole purpose is to provide a reference for error
                # tracking. Requiring a [ref] parameter would add unnecessary
                # complexity to the calling pattern.
                #
                # Version: 2.0.20251226.0

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

                param()

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
                # This function supports Windows PowerShell 1.0 with .NET Framework
                # 2.0 or newer, newer versions of Windows PowerShell (at least up
                # to and including Windows PowerShell 5.1 with .NET Framework 4.8
                # or newer), PowerShell Core 6.x, and PowerShell 7.x. This function
                # supports Windows and, when run on PowerShell Core 6.x or
                # PowerShell 7.x, also supports macOS and Linux.
                #
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
                # Version: 2.0.20251226.0

                param (
                    [ref]$ReferenceToEarlierError = ([ref]$null),
                    [ref]$ReferenceToLaterError = ([ref]$null)
                )

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

            trap {
                # Intentionally left empty to prevent terminating errors from halting
                # processing
            }

            # Validate input
            if ([string]::IsNullOrEmpty($Path)) {
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

            # Check if file exists using .NET method
            $boolFileExists = [System.IO.File]::Exists($Path)

            # Restore the former error preference
            $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

            # Retrieve the newest error on the error stack
            $refNewestCurrentError = Get-ReferenceToLastError

            if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
                # Error occurred
                return $false
            } else {
                # No error occurred
                return $boolFileExists
            }
        }
        #endregion HelperFunctions ####################################################

        trap {
            # Intentionally left empty to prevent terminating errors from halting
            # processing
        }

        # Validate input
        if ([string]::IsNullOrEmpty($Path)) {
            return -1
        }

        # Check if file exists before attempting deletion
        $boolFileExists = Test-FileExistence -Path $Path

        if ($boolFileExists -eq $false) {
            # File does not exist; treat as success
            $ReferenceToErrorRecord.Value = $null
            return 0
        }

        # File exists; attempt to delete it
        # Retrieve the newest error on the stack prior to doing work
        $refLastKnownError = Get-ReferenceToLastError

        # Store current error preference
        $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

        # Set ErrorActionPreference to SilentlyContinue
        $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

        # Attempt to delete the file using .NET method
        [System.IO.File]::Delete($Path)

        # Restore the former error preference
        $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

        # Retrieve the newest error on the error stack
        $refNewestCurrentError = Get-ReferenceToLastError

        if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
            # Error occurred
            $ReferenceToErrorRecord.Value = $refNewestCurrentError.Value
            return -1
        } else {
            # No error occurred
            $ReferenceToErrorRecord.Value = $null
            return 0
        }
    }
    #endregion HelperFunctions ####################################################

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    # Validate input
    if ([string]::IsNullOrEmpty($Path)) {
        return -1
    }

    # Retrieve the newest error on the stack prior to doing work
    $refLastKnownError = Get-ReferenceToLastError

    # Store current error preference; we will restore it after we do the work
    $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

    # Set ErrorActionPreference to SilentlyContinue; this will suppress error
    # output. Terminating errors will not output anything, kick to the empty
    # trap statement and then continue on. Likewise, non-terminating errors
    # will also not output anything, but they do not kick to the trap
    # statement; they simply continue on.
    $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    # Attempt to create the file using .NET FileStream with FileMode.Create
    # This will overwrite the file if it exists, or create it if it doesn't
    $objFileStream = New-Object System.IO.FileStream($Path, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        # Error occurred during file creation
        $ReferenceToErrorRecord.Value = $refNewestCurrentError.Value

        if ($null -ne $objFileStream) {
            # If the FileStream object was partially created, attempt cleanup

            # Retrieve the newest error on the stack prior to closing the file stream
            $refLastKnownError = Get-ReferenceToLastError

            # Store current error preference
            $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

            # Set ErrorActionPreference to SilentlyContinue
            $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

            # Close and dispose of the file stream
            $objFileStream.Close(); $objFileStream.Dispose()

            # Restore the former error preference
            $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

            # Retrieve the newest error on the error stack
            $refNewestCurrentError = Get-ReferenceToLastError

            if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
                # Error occurred during file stream closure; write to debug stream
                # This is a non-critical error as the file was already created successfully
                Write-Debug ("Failed to close file stream cleanly: {0}" -f ($refNewestCurrentError.Value.Exception.Message))
            }
        }

        # Best-effort cleanup: if a partial file was created, try to remove it
        # using Remove-File helper function
        $refDummyError = $null
        [void](Remove-File -Path $Path -ReferenceToErrorRecord ([ref]$refDummyError))

        return -1
    } else {
        # No error occurred; close the file stream
        if ($null -ne $objFileStream) {
            # Retrieve the newest error on the stack prior to closing the file stream
            $refLastKnownError = Get-ReferenceToLastError

            # Store current error preference
            $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference

            # Set ErrorActionPreference to SilentlyContinue
            $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

            # Close and dispose of the file stream
            $objFileStream.Close(); $objFileStream.Dispose()

            # Restore the former error preference
            $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

            # Retrieve the newest error on the error stack
            $refNewestCurrentError = Get-ReferenceToLastError

            if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
                # Error occurred during file stream closure; write to debug stream
                # This is a non-critical error as the file was already created successfully
                Write-Debug ("Failed to close file stream cleanly: {0}" -f ($refNewestCurrentError.Value.Exception.Message))
            }
        }

        # Clear error record reference if provided
        $ReferenceToErrorRecord.Value = $null

        return 0
    }
}
