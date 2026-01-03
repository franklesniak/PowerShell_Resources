function Get-PowerShellModuleUsingHashtable {
    # .SYNOPSIS
    # Gets a list of installed PowerShell modules for each entry in a hashtable.
    #
    # .DESCRIPTION
    # The Get-PowerShellModuleUsingHashtable function steps through each entry in
    # the supplied hashtable and gets a list of installed PowerShell modules for
    # each entry. The list of installed PowerShell modules for each entry is stored
    # in the value of the hashtable entry for that module (as an array).
    #
    # By default, the function operates silently and returns an integer status code
    # without emitting any errors or warnings. Optional switch parameters can be
    # used to output error or warning messages when the operation fails.
    #
    # .PARAMETER ReferenceToHashtable
    # This parameter is required; it is a reference (memory pointer) to a
    # hashtable. The referenced hashtable must have keys that are the names of
    # PowerShell modules and values that are initialized to be empty arrays (@()).
    # After running this function, the list of installed PowerShell modules for
    # each entry is stored in the value of the hashtable entry as a populated
    # array.
    #
    # .PARAMETER DoNotCheckPowerShellVersion
    # This parameter is optional. If this switch is present, the function will not
    # check the version of PowerShell that is running. This is useful if you are
    # running this function in a script and the script has already validated that
    # the version of PowerShell supports Get-Module -ListAvailable.
    #
    # .PARAMETER WriteErrorOnFailure
    # This parameter is optional; it is a switch parameter. If this parameter is
    # specified, a non-terminating error is written via Write-Error when the
    # function fails. If this parameter is not specified, no error is written.
    #
    # .PARAMETER WriteWarningOnFailure
    # This parameter is optional; it is a switch parameter. If this parameter is
    # specified, a warning is written via Write-Warning when the function fails. If
    # this parameter is not specified, or if the WriteErrorOnFailure parameter was
    # specified, no warning is written.
    #
    # .EXAMPLE
    # $hashtableModuleNameToInstalledModules = @{}
    # $hashtableModuleNameToInstalledModules.Add('PnP.PowerShell', @())
    # $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Authentication', @())
    # $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Groups', @())
    # $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Users', @())
    # $refHashtableModuleNameToInstalledModules = [ref]$hashtableModuleNameToInstalledModules
    # $intReturnCode = Get-PowerShellModuleUsingHashtable -ReferenceToHashtable $refHashtableModuleNameToInstalledModules
    # if ($intReturnCode -ne 0) {
    #     Write-Host 'Failed to get the list of installed PowerShell modules.'
    #     return
    # }
    #
    # This example gets the list of installed PowerShell modules for each of the
    # four modules listed in the hashtable using named parameters. The list of each
    # respective module is stored in the value of the hashtable entry for that
    # module. The function returns 0 on success or -1 on failure, which is captured
    # and checked to ensure the operation completed successfully. No errors or
    # warnings are emitted by the function itself.
    #
    # .EXAMPLE
    # $hashtableModuleNameToInstalledModules = @{}
    # $hashtableModuleNameToInstalledModules.Add('PnP.PowerShell', @())
    # $refHashtableModuleNameToInstalledModules = [ref]$hashtableModuleNameToInstalledModules
    # $intReturnCode = Get-PowerShellModuleUsingHashtable $refHashtableModuleNameToInstalledModules
    # if ($intReturnCode -eq 0) {
    #     Write-Host 'Successfully retrieved module information.'
    # }
    #
    # This example demonstrates using positional parameters instead of named
    # parameters. The first positional parameter is the reference to the hashtable.
    # The function returns 0 on success, which is captured and checked.
    #
    # .EXAMPLE
    # $hashtableModuleNameToInstalledModules = @{}
    # $hashtableModuleNameToInstalledModules.Add('NonExistentModule', @())
    # $refHashtableModuleNameToInstalledModules = [ref]$hashtableModuleNameToInstalledModules
    # $intReturnCode = Get-PowerShellModuleUsingHashtable -ReferenceToHashtable $refHashtableModuleNameToInstalledModules -WriteWarningOnFailure
    # if ($intReturnCode -ne 0) {
    #     Write-Host 'Function returned an error status'
    # }
    #
    # This example demonstrates using the WriteWarningOnFailure switch parameter. If
    # the function fails (e.g., invalid hashtable or PowerShell version check
    # failure), a warning message is displayed. The function returns -1 on failure.
    #
    # .EXAMPLE
    # $hashtableModuleNameToInstalledModules = @{}
    # $hashtableModuleNameToInstalledModules.Add('PnP.PowerShell', @())
    # $refHashtableModuleNameToInstalledModules = [ref]$hashtableModuleNameToInstalledModules
    # $intReturnCode = Get-PowerShellModuleUsingHashtable -ReferenceToHashtable $refHashtableModuleNameToInstalledModules -WriteErrorOnFailure
    # if ($intReturnCode -ne 0) {
    #     exit 1
    # }
    #
    # This example demonstrates using the WriteErrorOnFailure switch parameter. If
    # the function fails, a non-terminating error is written via Write-Error. The
    # function returns -1 on failure and the script exits with code 1.
    #
    # .INPUTS
    # None. You can't pipe objects to Get-PowerShellModuleUsingHashtable.
    #
    # .OUTPUTS
    # System.Int32. Returns an integer status code:
    #   0 = Success. All module queries completed successfully
    #  -1 = Failure. Invalid input or PowerShell version check failed
    #
    # The list of installed PowerShell modules for each key in the referenced
    # hashtable is stored in the respective entry's value as an array.
    #
    # .NOTES
    # This function also supports the use of a positional parameter instead of a
    # named parameter. If a positional parameter is used instead of a named
    # parameter, then exactly one positional parameter is required: a reference
    # (memory pointer) to a hashtable. The referenced hashtable must have keys that
    # are the names of PowerShell modules and values that are initialized to be
    # empty arrays (@()). After running this function, the list of installed
    # PowerShell modules for each entry is stored in the value of the hashtable
    # entry as a populated array.
    #
    # Note: Switch parameters (WriteErrorOnFailure and WriteWarningOnFailure) are
    # not included in positional parameters by default.
    #
    # This function requires Windows PowerShell 2.0 with .NET Framework 2.0 or
    # newer (minimum runtime requirement), and supports newer versions of Windows
    # PowerShell (at least up to and including Windows PowerShell 5.1 with .NET
    # Framework 4.8 or newer), PowerShell Core 6.x, and PowerShell 7.x. This
    # function supports Windows and, when run on PowerShell Core 6.x or PowerShell
    # 7.x, also supports macOS and Linux. While the function requires PowerShell
    # 2.0+ at runtime, the syntax is compatible with Windows PowerShell 1.0
    # parsing to avoid parser errors when loaded as a library function in older
    # environments.
    #
    # Version: 2.0.20260103.2

    param (
        [ref]$ReferenceToHashtable = ([ref]$null),
        [switch]$DoNotCheckPowerShellVersion,
        [switch]$WriteErrorOnFailure,
        [switch]$WriteWarningOnFailure
    )

    #region License ############################################################
    # Copyright (c) 2026 Frank Lesniak
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
        # .EXAMPLE
        # # This example demonstrates the function returning $false when no
        # # error occurs during the operation. A command that executes
        # # successfully is run, and the function correctly identifies that
        # # no error occurred.
        #
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
        # # Set ErrorActionPreference to SilentlyContinue
        # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        #
        # # Do something that will succeed
        # Get-Item -Path $env:TEMP
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
        #     # No error occurred - this branch executes because Get-Item
        #     # succeeded
        # }
        #
        # .EXAMPLE
        # # This example demonstrates a scenario where
        # # ReferenceToEarlierError is non-null but ReferenceToLaterError
        # # is null, simulating that $Error was cleared. The function
        # # returns $false because this does not indicate a new error
        # # occurred.
        #
        # # Intentionally empty trap statement to prevent terminating errors
        # # from halting processing
        # trap { }
        #
        # # Generate an error so that $Error has an entry
        # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        # Get-Item -Path 'C:\DoesNotExist-ErrorClearing-Example.txt'
        # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::Continue
        #
        # # Capture reference to the error
        # if ($Error.Count -gt 0) {
        #     $refLastKnownError = ([ref]($Error[0]))
        # } else {
        #     $refLastKnownError = ([ref]$null)
        # }
        #
        # # Clear the $Error array
        # $Error.Clear()
        #
        # # Capture reference after clearing (will be null)
        # if ($Error.Count -gt 0) {
        #     $refNewestCurrentError = ([ref]($Error[0]))
        # } else {
        #     $refNewestCurrentError = ([ref]$null)
        # }
        #
        # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
        #     # Error occurred
        # } else {
        #     # No error occurred - this branch executes because clearing
        #     # $Error does not indicate a new error
        # }
        #
        # .EXAMPLE
        # # This example demonstrates using the function with positional
        # # parameters instead of named parameters. Both approaches work
        # # correctly.
        #
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
        # # Store current error preference
        # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
        #
        # # Set ErrorActionPreference to SilentlyContinue
        # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        #
        # # Do something that might trigger an error
        # Get-Item -Path 'C:\MayNotExist-Positional-Example.txt'
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
        # # Note: Using positional parameters - first parameter is
        # # ReferenceToEarlierError, second is ReferenceToLaterError
        # if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
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

    #region HelperFunctions ####################################################
    function Get-PSVersion {
        # .SYNOPSIS
        # Returns the version of PowerShell that is running.
        #
        # .DESCRIPTION
        # The function outputs a [version] object representing the version of
        # PowerShell that is running. This function detects the PowerShell
        # runtime version but does not detect the underlying .NET Framework or
        # .NET Core version.
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
        # .EXAMPLE
        # $versionPS = Get-PSVersion
        # if ($versionPS.Major -ge 2) {
        #     Write-Host "PowerShell 2.0 or later detected"
        # } else {
        #     Write-Host "PowerShell 1.0 detected"
        # }
        # # This example demonstrates storing the returned version object in a
        # # variable and using it to make conditional decisions based on
        # # PowerShell version. The returned [version] object has properties
        # # like Major, Minor, Build, and Revision that can be used for
        # # version-based logic.
        #
        # .INPUTS
        # None. You can't pipe objects to Get-PSVersion.
        #
        # .OUTPUTS
        # System.Version. Get-PSVersion returns a [version] value indicating
        # the version of PowerShell that is running.
        #
        # .NOTES
        # Version: 1.0.20251226.0
        #
        # This function is compatible with all versions of PowerShell: Windows
        # PowerShell (v1.0 - 5.1), PowerShell Core 6.x, and PowerShell 7.x and
        # newer. It is compatible with Windows, macOS, and Linux.
        #
        # This function has no parameters.

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
    #endregion HelperFunctions ####################################################

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    #region Process input ######################################################
    # Validate that the required parameter was supplied:
    if ($null -eq $ReferenceToHashtable) {
        $strMessage = 'The Get-PowerShellModuleUsingHashtable function requires a parameter (-ReferenceToHashtable), which must reference a hashtable.'
        if ($boolWriteErrorOnFailure) {
            Write-Error -Message $strMessage
        } elseif ($boolWriteWarningOnFailure) {
            Write-Warning -Message $strMessage
        }
        return -1
    }
    if ($null -eq $ReferenceToHashtable.Value) {
        $strMessage = 'The Get-PowerShellModuleUsingHashtable function requires a parameter (-ReferenceToHashtable), which must reference a hashtable.'
        if ($boolWriteErrorOnFailure) {
            Write-Error -Message $strMessage
        } elseif ($boolWriteWarningOnFailure) {
            Write-Warning -Message $strMessage
        }
        return -1
    }
    if ($ReferenceToHashtable.Value.GetType().FullName -ne 'System.Collections.Hashtable') {
        $strMessage = 'The Get-PowerShellModuleUsingHashtable function requires a parameter (-ReferenceToHashtable), which must reference a hashtable.'
        if ($boolWriteErrorOnFailure) {
            Write-Error -Message $strMessage
        } elseif ($boolWriteWarningOnFailure) {
            Write-Warning -Message $strMessage
        }
        return -1
    }

    $boolCheckForPowerShellVersion = $true
    if ($null -ne $DoNotCheckPowerShellVersion) {
        if ($DoNotCheckPowerShellVersion.IsPresent) {
            $boolCheckForPowerShellVersion = $false
        }
    }

    $boolWriteErrorOnFailure = $false
    $boolWriteWarningOnFailure = $false
    if ($null -ne $WriteErrorOnFailure) {
        if ($WriteErrorOnFailure.IsPresent -eq $true) {
            $boolWriteErrorOnFailure = $true
        }
    }
    if (-not $boolWriteErrorOnFailure) {
        if ($null -ne $WriteWarningOnFailure) {
            if ($WriteWarningOnFailure.IsPresent -eq $true) {
                $boolWriteWarningOnFailure = $true
            }
        }
    }
    #endregion Process input ######################################################

    #region Verify environment #################################################
    if ($boolCheckForPowerShellVersion) {
        $versionPS = Get-PSVersion
        if ($versionPS.Major -lt 2) {
            $strMessage = 'The Get-PowerShellModuleUsingHashtable function requires PowerShell version 2.0 or greater.'
            if ($boolWriteErrorOnFailure) {
                Write-Error -Message $strMessage
            } elseif ($boolWriteWarningOnFailure) {
                Write-Warning -Message $strMessage
            }
            return -1
        }
    }
    #endregion Verify environment #################################################

    #region Main Processing ################################################
    $actionPreferenceVerboseAtStartOfFunction = $VerbosePreference

    $arrModulesToGet = @(($ReferenceToHashtable.Value).Keys)
    $intCountOfModules = $arrModulesToGet.Count

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

    # Get the list of installed modules for each module name in the hashtable
    ###############################################################################
    # # The following code is commented out and converted to a one-liner
    # # intentionally so that error handling works correctly.
    # for ($intCounter = 0; $intCounter -lt $intCountOfModules; $intCounter++) {
    #     Write-Verbose ('Checking for {0} module...' -f $arrModulesToGet[$intCounter])
    #     # Suppress verbose output from Get-Module (v1.0 compatible approach)
    #     $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
    #     ($ReferenceToHashtable.Value).Item($arrModulesToGet[$intCounter]) = @(Get-Module -Name ($arrModulesToGet[$intCounter]) -ListAvailable)
    #     $VerbosePreference = $actionPreferenceVerboseAtStartOfFunction
    # }
    ###############################################################################
    # Here is the one-liner version of the above code:
    for ($intCounter = 0; $intCounter -lt $intCountOfModules; $intCounter++) { Write-Verbose ('Checking for {0} module...' -f $arrModulesToGet[$intCounter]); $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue; ($ReferenceToHashtable.Value).Item($arrModulesToGet[$intCounter]) = @(Get-Module -Name ($arrModulesToGet[$intCounter]) -ListAvailable); $VerbosePreference = $actionPreferenceVerboseAtStartOfFunction; }

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
        # Error occurred

        # Return failure indicator:
        return -1
    } else {
        # No error occurred

        # Return success indicator:
        return 0
    }

    #endregion Main Processing ################################################
}
