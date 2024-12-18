function Get-ExportedTypesFromRuntimeAssemblySafely {
    # .SYNOPSIS
    # Obtains the exported types from a RuntimeAssembly object.
    #
    # .DESCRIPTION
    # Given a RuntimeAssembly object, this function retrieves the exported
    # types from the assembly, but does so in a way that suppresses errors from
    # being displayed to the console. This function is useful when you want to
    # obtain the exported types from an assembly, but you don't want to see any
    # errors that may occur during the process. The function returns $true if
    # no errors occurred; otherwise, it returns $false.
    #
    # .PARAMETER ReferenceToArrayOfExportedTypes
    # This parameter is required; it is a reference to a System.Object[]
    # (array) that will be used to store output. If the export of types is
    # successful, the function guarantees that the referenced object will
    # always be an array, even when a single item is returned. If the export of
    # types is unsuccessful, the referenced object is undefined.
    #
    # .PARAMETER ReferenceToSystemReflectionRuntimeAssembly
    # This parameter is a reference (pointer) to a
    # System.Reflection.RuntimeAssembly object from which the function will get
    # its exported types.
    #
    # .EXAMPLE
    # $arrReturnData = @()
    # $arrAssemblies = @([AppDomain]::CurrentDomain.GetAssemblies())
    # $boolSuccess = Get-ExportedTypesFromRuntimeAssemblySafely -ReferenceToArrayOfExportedTypes ([ref]$arrReturnData) -ReferenceToSystemReflectionRuntimeAssembly ([ref]($arrAssemblies[0]))
    #
    # .EXAMPLE
    # $arrReturnData = @()
    # $arrAssemblies = @([AppDomain]::CurrentDomain.GetAssemblies())
    # $boolSuccess = Get-ExportedTypesFromRuntimeAssemblySafely ([ref]$arrReturnData) ([ref]($arrAssemblies[0]))
    #
    # .INPUTS
    # None. You can't pipe objects to
    # Get-ExportedTypesFromRuntimeAssemblySafely.
    #
    # .OUTPUTS
    # System.Boolean. Get-ExportedTypesFromRuntimeAssemblySafely returns a
    # boolean value indiciating whether the process completed successfully.
    # $true means the process completed successfully; $false means there was an
    # error.
    #
    # .NOTES
    # This function also supports the use of arguments, which can be used
    # instead of parameters. If arguments are used instead of parameters, then
    # two positional arguments are required:
    #
    # The first argument is a reference to a System.Object[] (array) that will
    # be used to store output. The function guarantees that the output will
    # always be an array, even when a single item is returned.
    #
    # The second argument is a reference (pointer) to a
    # System.Reflection.RuntimeAssembly object from which the function will get
    # its exported types.
    #
    # Version: 2.0.20241218.0

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
        [ref]$ReferenceToArrayOfExportedTypes = ([ref]$null),
        [ref]$ReferenceToSystemReflectionRuntimeAssembly = ([ref]$null)
    )

    #region FunctionsToSupportErrorHandling ################################
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
    #endregion FunctionsToSupportErrorHandling ################################

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    #region Assign Parameters and Arguments to Internally-Used Variables ###
    $boolUseArguments = $false
    if ($args.Count -eq 2) {
        # Arguments may have been supplied instead of parameters
        if (($null -eq $ReferenceToArrayOfExportedTypes.Value) -and ($null -eq $ReferenceToSystemReflectionRuntimeAssembly.Value)) {
            # Parameters were all uninitialized; use arguments
            $boolUseArguments = $true
        }
    }

    if (-not $boolUseArguments) {
        # Use parameters
        $refArrayOfExportedTypes = $ReferenceToArrayOfExportedTypes
        $refSystemReflectionRuntimeAssembly = $ReferenceToSystemReflectionRuntimeAssembly
    } else {
        # Use positional arguments
        $refArrayOfExportedTypes = $args[0]
        $refSystemReflectionRuntimeAssembly = $args[1]
    }
    #endregion Assign Parameters and Arguments to Internally-Used Variables ###

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

    # Export the types from the System.Reflection.RuntimeAssembly object
    $refArrayOfExportedTypes.Value = @(($refSystemReflectionRuntimeAssembly.Value).GetExportedTypes())

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        # Error occurred; return failure indicator:
        return $false
    } else {
        # No error occurred; return success indicator:
        return $true
    }
}
