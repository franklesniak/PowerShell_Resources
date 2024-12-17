function Get-FolderObjectSafelyUsingScriptingFileSystemObject {
    # .SYNOPSIS
    # Get's a Folder object using the Scripting.FileSystemObject COM object.
    #
    # .DESCRIPTION
    # This function gets a Folder object using the Scripting.FileSystemObject COM
    # object. If the Folder object is successfully created, then the function
    # returns $true; otherwise, the function returns $false. If the function
    # returns $false, then the Folder object is not created, and the referenced
    # Folder object is undefined.
    #
    # .PARAMETER ReferenceToFolderObject
    # This parameter is required; it is a reference to an object that will become
    # the Folder COM object created using Scripting.FileSystemObject. If the object
    # is created successfully, then the referenced object will be updated, storing
    # the Folder COM object. If the object is not created successfully, then the
    # referenced variable becomes undefined.
    #
    # .PARAMETER ReferenceToScriptingFileSystemObject
    # This parameter is required; it is a reference to a Scripting.FileSystemObject
    # COM object, which has already been initialized.
    #
    # .PARAMETER Path
    # This parameter is required; it is a string containing the path to the folder
    # for which this function will obtain the Folder COM object.
    #
    # .EXAMPLE
    # $strPath = 'D:\Shares\Human Resources\Personnel Information\Employee Files\John Doe'
    # $objScriptingFileSystemObject = New-Object -ComObject Scripting.FileSystemObject
    # $objFSOFolderObject = $null
    # $boolSuccess = Get-FolderObjectSafelyUsingScriptingFileSystemObject -ReferenceToFolderObject ([ref]$objFSOFolderObject) -ReferenceToScriptingFileSystemObject ([ref]$objScriptingFileSystemObject) -Path $strPath
    #
    # .EXAMPLE
    # $strPath = 'D:\Shares\Human Resources\Personnel Information\Employee Files\John Doe'
    # $objScriptingFileSystemObject = New-Object -ComObject Scripting.FileSystemObject
    # $objFSOFolderObject = $null
    # $boolSuccess = Get-FolderObjectSafelyUsingScriptingFileSystemObject ([ref]$objFSOFolderObject) ([ref]$objScriptingFileSystemObject) $strPath
    #
    # .INPUTS
    # None. You can't pipe objects to
    # Get-FolderObjectSafelyUsingScriptingFileSystemObject.
    #
    # .OUTPUTS
    # System.Boolean. Get-FolderObjectSafelyUsingScriptingFileSystemObject returns
    # a boolean value indiciating whether the process completed successfully. $true
    # means the process completed successfully; $false means there was an error.
    #
    # .NOTES
    # This function also supports the use of arguments, which can be used
    # instead of parameters. If arguments are used instead of parameters, then
    # three positional arguments are required:
    #
    # The first argument is a reference to an object that will become the Folder
    # COM object created using Scripting.FileSystemObject. If the object is created
    # successfully, then the referenced object will be updated, storing the Folder
    # COM object. If the object is not created successfully, then the referenced
    # variable becomes undefined.
    #
    # The second argument is a reference to a Scripting.FileSystemObject COM
    # object, which has already been initialized.
    #
    # The third argument is a string containing the path to the folder for which
    # this function will obtain the Folder COM object.
    #
    # Version: 1.1.20241216.0

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
        [ref]$ReferenceToFolderObject = ([ref]$null),
        [ref]$ReferenceToScriptingFileSystemObject = ([ref]$null),
        [string]$Path = ''
    )

    #region FunctionsToSupportErrorHandling ####################################
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
    #endregion FunctionsToSupportErrorHandling ####################################

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    #region Assign Parameters and Arguments to Internally-Used Variables #######
    $boolUseArguments = $false
    if ($args.Count -eq 3) {
        # Arguments may have been supplied instead of parameters
        if (($null -eq $ReferenceToFolderObject.Value) -and ($null -eq $ReferenceToScriptingFileSystemObject.Value) -and [string]::IsNullOrEmpty($Path)) {
            # Parameters were not supplied; use arguments
            $boolUseArguments = $true
        }
    }

    if (-not $boolUseArguments) {
        # Use parameters
        $refFSOFolderObject = $ReferenceToFolderObject
        $refScriptingFileSystemObject = $ReferenceToScriptingFileSystemObject
        $strPath = $Path
    } else {
        # Use positional arguments
        $refFSOFolderObject = $args[0]
        $refScriptingFileSystemObject = $args[1]
        $strPath = $args[2]
    }
    #endregion Assign Parameters and Arguments to Internally-Used Variables #######

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

    # Get the folder object
    $refFSOFolderObject.Value = ($refScriptingFileSystemObject.Value).GetFolder($strPath)

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