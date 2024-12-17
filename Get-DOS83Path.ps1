function Get-DOS83Path {
    # .SYNOPSIS
    # Retrieves the DOS 8.3 path (short path) for a given file or folder path.
    #
    # .DESCRIPTION
    # Given a path to a folder or file, translates the path to its DOS-
    # compatible "8.3" formatted path. DOS did not support long file/folder
    # paths, so, since long file paths were introduced, by default, Windows
    # maintains a DOS-compatible 8.3 file name side-by-side with modern long
    # file/folder names. This function gets the short 8.3 path.
    #
    # .PARAMETER ReferenceToDOS8Dot3Path
    # This parameter is required; it is a reference to a string. If the process
    # was successful, the referenced string will be updated to contain the
    # short DOS 8.3 path. If the process is not successful, then the contents
    # of the string are undefined.
    #
    # .PARAMETER Path
    # This parameter is required; it is a string containing the path of the
    # folder or file for which we want to retrieve its DOS 8.3 file path.
    #
    # .PARAMETER ReferenceToScriptingFileSystemObject
    # This parameter is optional; if specified, it is a reference to a
    # Scripting.FileSystemObject object. Supplying this parameter can speed up
    # performance by avoiding to have to create the Scripting.FileSystemObject
    # every time this function is called.
    #
    # .EXAMPLE
    # $strPath = 'D:\Shares\Human Resources\Personnel Information\Employee Files\John Doe.docx'
    # $strDOS83Path = ''
    # $boolSuccess = Get-DOS83Path -ReferenceToDOS8Dot3Path ([ref]$strDOS83Path) -Path $strPath
    #
    # .EXAMPLE
    # $objFSO = New-Object -ComObject Scripting.FileSystemObject
    # $strPath = 'D:\Shares\Human Resources\Personnel Information\Employee Files\John Doe.docx'
    # $strDOS83Path = ''
    # $boolSuccess = Get-DOS83Path -ReferenceToDOS8Dot3Path ([ref]$strDOS83Path) -Path $strPath -ReferenceToScriptingFileSystemObject ([ref]$objFSO)
    #
    # .EXAMPLE
    # $strPath = 'D:\Shares\Human Resources\Personnel Information\Employee Files\John Doe.docx'
    # $strDOS83Path = ''
    # $boolSuccess = Get-DOS83Path ([ref]$strDOS83Path) $strPath
    #
    # .INPUTS
    # None. You can't pipe objects to Get-DOS83Path.
    #
    # .OUTPUTS
    # System.Boolean. Get-DOS83Path returns a boolean value indiciating
    # whether the process completed successfully. $true means the process
    # completed successfully; $false means there was an error.
    #
    # .NOTES
    # This function also supports the use of arguments, which can be used
    # instead of parameters. If arguments are used instead of parameters, then
    # two or three positional arguments are required:
    #
    # The first argument is a reference to a string. If the process was
    # successful, the referenced string will be updated to contain the short
    # DOS 8.3 path. If the process is not successful, then the contents of the
    # string are undefined.
    #
    # The second argument is a string containing the path of the folder or file
    # for which we want to retrieve its DOS 8.3 file path.
    #
    # The third argument is optional. If supplied, it is a reference to a
    # Scripting.FileSystemObject object. Supplying this parameter can speed up
    # performance by avoiding to have to create the Scripting.FileSystemObject
    # every time this function is called.
    #
    # Version: 1.1.20241217.0

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
        [ref]$ReferenceToDOS8Dot3Path = ([ref]$null),
        [string]$Path = '',
        [ref]$ReferenceToScriptingFileSystemObject = ([ref]$null)
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

    function Get-ScriptingFileSystemObjectSafely {
        # .SYNOPSIS
        # Creates a COM object for Scripting.FileSystemObject.
        #
        # .DESCRIPTION
        # Creates a COM object for Scripting.FileSystemObject. If the object cannot be
        # created, then the function will return $false. If the object is created
        # successfully, then the function will return $true.
        #
        # .PARAMETER ReferenceToStoreObject
        # This parameter is required; it is a reference to an object that will become
        # the FileSystemObject COM object. If the object is created successfully, then
        # the referenced object will be updated, storing the FileSystemObject COM
        # object. If the object is not created successfully, then the referenced
        # variable becomes undefined.
        #
        # .EXAMPLE
        # $objScriptingFileSystemObject = $null
        # $boolSuccess = Get-ScriptingFileSystemObjectSafely -ReferenceToStoreObject ([ref]$objScriptingFileSystemObject)
        #
        # .EXAMPLE
        # $objScriptingFileSystemObject = $null
        # $boolSuccess = Get-ScriptingFileSystemObjectSafely ([ref]$objScriptingFileSystemObject)
        #
        # .INPUTS
        # None. You can't pipe objects to Get-ScriptingFileSystemObjectSafely.
        #
        # .OUTPUTS
        # System.Boolean. Get-ScriptingFileSystemObjectSafely returns a boolean value
        # indiciating whether the Scripting.FileSystemObject object was created
        # successfully. $true means the object was created successfully; $false means
        # there was an error.
        #
        # .NOTES
        # This function also supports the use of an argument, which can be used
        # instead of the parameter.
        #
        # The first argument and only argument is a reference to an object that will
        # become the FileSystemObject COM object. If the object is created
        # successfully, then the referenced object will be updated, storing the
        # FileSystemObject COM object. If the object is not created successfully, then
        # the referenced variable becomes undefined.
        #
        # Version: 1.1.20241217.0

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
            [ref]$ReferenceToStoreObject = ([ref]$null)
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

        #region Assign Parameters and Arguments to Internally-Used Variables #######
        $boolUseArguments = $false
        if ($args.Count -eq 1) {
            # Arguments may have been supplied instead of parameters
            if ($null -eq $ReferenceToStoreObject.Value) {
                # We have one argument and nothing supplied in the parameter
                $boolUseArguments = $true
            }
        }

        if (-not $boolUseArguments) {
            # Use parameters
            $refOutput = $ReferenceToStoreObject
        } else {
            # Use positional arguments
            $refOutput = $args[0]
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

        # Do the work of this function...
        $refOutput.Value = New-Object -ComObject Scripting.FileSystemObject

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

    function Get-FolderObjectSafelyUsingScriptingFileSystemObject {
        # .SYNOPSIS
        # Get's a Folder object using the Scripting.FileSystemObject COM object.
        #
        # .DESCRIPTION
        # This function gets a Folder object using the Scripting.FileSystemObject
        # COM object. If the Folder object is successfully created, then the
        # function returns $true; otherwise, the function returns $false. If the
        # function returns $false, then the Folder object is not created, and the
        # referenced Folder object is undefined.
        #
        # .PARAMETER ReferenceToFolderObject
        # This parameter is required; it is a reference to an object that will
        # become the Folder COM object created using Scripting.FileSystemObject. If
        # the object is created successfully, then the referenced object will be
        # updated, storing the Folder COM object. If the object is not created
        # successfully, then the referenced variable becomes undefined.
        #
        # .PARAMETER ReferenceToScriptingFileSystemObject
        # This parameter is required; it is a reference to a
        # Scripting.FileSystemObject COM object, which has already been
        # initialized.
        #
        # .PARAMETER Path
        # This parameter is required; it is a string containing the path to the
        # folder for which this function will obtain the Folder COM object.
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
        # System.Boolean. Get-FolderObjectSafelyUsingScriptingFileSystemObject
        # returns a boolean value indiciating whether the process completed
        # successfully. $true means the process completed successfully; $false
        # means there was an error.
        #
        # .NOTES
        # This function also supports the use of arguments, which can be used
        # instead of parameters. If arguments are used instead of parameters, then
        # three positional arguments are required:
        #
        # The first argument is a reference to an object that will become the
        # Folder COM object created using Scripting.FileSystemObject. If the object
        # is created successfully, then the referenced object will be updated,
        # storing the Folder COM object. If the object is not created successfully,
        # then the referenced variable becomes undefined.
        #
        # The second argument is a reference to a Scripting.FileSystemObject COM
        # object, which has already been initialized.
        #
        # The third argument is a string containing the path to the folder for
        # which this function will obtain the Folder COM object.
        #
        # Version: 1.1.20241217.0

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
            [ref]$ReferenceToFolderObject = ([ref]$null),
            [ref]$ReferenceToScriptingFileSystemObject = ([ref]$null),
            [string]$Path = ''
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
        #endregion Assign Parameters and Arguments to Internally-Used Variables ###

        # TODO: Validate input

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

    function Get-FileObjectSafelyUsingScriptingFileSystemObject {
        # .SYNOPSIS
        # Get's a File object using the Scripting.FileSystemObject COM object.
        #
        # .DESCRIPTION
        # This function gets a File object using the Scripting.FileSystemObject COM
        # object. If the File object is successfully created, then the function
        # returns $true; otherwise, the function returns $false. If the function
        # returns $false, then the File object is not created, and the referenced
        # File object is undefined.
        #
        # .PARAMETER ReferenceToFileObject
        # This parameter is required; it is a reference to an object that will
        # become the File COM object created using Scripting.FileSystemObject. If
        # the object is created successfully, then the referenced object will be
        # updated, storing the File COM object. If the object is not created
        # successfully, then the referenced variable becomes undefined.
        #
        # .PARAMETER ReferenceToScriptingFileSystemObject
        # This parameter is required; it is a reference to a
        # Scripting.FileSystemObject COM object, which has already been
        # initialized.
        #
        # .PARAMETER Path
        # This parameter is required; it is a string containing the path to the
        # file for which this function will obtain the File COM object.
        #
        # .EXAMPLE
        # $strPath = 'D:\Shares\Human Resources\Personnel Information\Employee Files\John Doe\Expenses.xlsx'
        # $objScriptingFileSystemObject = New-Object -ComObject Scripting.FileSystemObject
        # $objFSOFileObject = $null
        # $boolSuccess = Get-FileObjectSafelyUsingScriptingFileSystemObject -ReferenceToFileObject ([ref]$objFSOFileObject) -ReferenceToScriptingFileSystemObject ([ref]$objScriptingFileSystemObject) -Path $strPath
        #
        # .EXAMPLE
        # $strPath = 'D:\Shares\Human Resources\Personnel Information\Employee Files\John Doe\Expenses.xlsx'
        # $objScriptingFileSystemObject = New-Object -ComObject Scripting.FileSystemObject
        # $objFSOFileObject = $null
        # $boolSuccess = Get-FileObjectSafelyUsingScriptingFileSystemObject ([ref]$objFSOFileObject) ([ref]$objScriptingFileSystemObject) $strPath
        #
        # .INPUTS
        # None. You can't pipe objects to
        # Get-FileObjectSafelyUsingScriptingFileSystemObject.
        #
        # .OUTPUTS
        # System.Boolean. Get-FileObjectSafelyUsingScriptingFileSystemObject
        # returns a boolean value indiciating whether the process completed
        # successfully. $true means the process completed successfully; $false
        # means there was an error.
        #
        # .NOTES
        # This function also supports the use of arguments, which can be used
        # instead of parameters. If arguments are used instead of parameters, then
        # three positional arguments are required:
        #
        # The first argument is a reference to an object that will become the File
        # COM object created using Scripting.FileSystemObject. If the object is
        # created successfully, then the referenced object will be updated, storing
        # the File COM object. If the object is not created successfully, then the
        # referenced variable becomes undefined.
        #
        # The second argument is a reference to a Scripting.FileSystemObject COM
        # object, which has already been initialized.
        #
        # The third argument is a string containing the path to the file for which
        # this function will obtain the File COM object.
        #
        # Version: 1.1.20241217.0

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
            [ref]$ReferenceToFileObject = ([ref]$null),
            [ref]$ReferenceToScriptingFileSystemObject = ([ref]$null),
            [string]$Path = ''
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
        if ($args.Count -eq 3) {
            # Arguments may have been supplied instead of parameters
            if (($null -eq $ReferenceToFileObject.Value) -and ($null -eq $ReferenceToScriptingFileSystemObject.Value) -and [string]::IsNullOrEmpty($Path)) {
                # Parameters were not supplied; use arguments
                $boolUseArguments = $true
            }
        }

        if (-not $boolUseArguments) {
            # Use parameters
            $refFSOFileObject = $ReferenceToFileObject
            $refScriptingFileSystemObject = $ReferenceToScriptingFileSystemObject
            $strPath = $Path
        } else {
            # Use positional arguments
            $refFSOFileObject = $args[0]
            $refScriptingFileSystemObject = $args[1]
            $strPath = $args[2]
        }
        #endregion Assign Parameters and Arguments to Internally-Used Variables ###

        # TODO: Validate input

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

        # Get the file object
        $refFSOFileObject.Value = ($refScriptingFileSystemObject.Value).GetFile($strPath)

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

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    #region Assign Parameters and Arguments to Internally-Used Variables #######
    $boolUseArguments = $false
    if (($args.Count -ge 2) -or ($args.Count -le 3)) {
        # Arguments may have been supplied instead of parameters
        if (($null -eq $ReferenceToDOS8Dot3Path.Value) -and ([string]::IsNullOrEmpty($Path)) -and ($null -eq $ReferenceToScriptingFileSystemObject.Value)) {
            # All parameters are uninitialized; arguments were definitely used
            $boolUseArguments = $true
        }
    }

    if (-not $boolUseArguments) {
        # Use parameters
        $refDOS83Path = $ReferenceToDOS8Dot3Path
        $strPath = $Path
        $refScriptingFileSystemObject = $ReferenceToScriptingFileSystemObject
    } else {
        # Use positional arguments
        $refDOS83Path = $args[0]
        $strPath = $args[1]
        if ($args.Count -gt 2) {
            $refScriptingFileSystemObject = $args[2]
        }
    }
    #endregion Assign Parameters and Arguments to Internally-Used Variables #######

    # Get the Scripting.FileSystemObject if necessary
    if ($null -eq $refScriptingFileSystemObject.Value) {
        $boolUseReferencedFSO = $false
        $objScriptingFileSystemObject = $null
        $boolSuccess = Get-ScriptingFileSystemObjectSafely -ReferenceToStoreObject ([ref]$objScriptingFileSystemObject)
        if ($boolSuccess -eq $false) {
            # Error occurred
            # TODO: Use alternate method following P/invoke - see below
            return $false
        }
    } else {
        $boolUseReferencedFSO = $true
    }

    # Get the folder or file object from Scripting.FileSystemObject
    $objFSOFolderOrFileObject = $null
    # Try to retrieve a folder object first
    if ($boolUseReferencedFSO) {
        $boolSuccess = Get-FolderObjectSafelyUsingScriptingFileSystemObject -ReferenceToFolderObject ([ref]$objFSOFolderOrFileObject) -ReferenceToScriptingFileSystemObject $refScriptingFileSystemObject -Path $strPath
    } else {
        $boolSuccess = Get-FolderObjectSafelyUsingScriptingFileSystemObject -ReferenceToFolderObject ([ref]$objFSOFolderOrFileObject) -ReferenceToScriptingFileSystemObject ([ref]$objScriptingFileSystemObject) -Path $strPath
    }
    if ($boolSuccess -eq $false) {
        # Failed to retrieve folder object; perhaps it's a file?
        if ($boolUseReferencedFSO) {
            $boolSuccess = Get-FileObjectSafelyUsingScriptingFileSystemObject -ReferenceToFileObject ([ref]$objFSOFolderOrFileObject) -ReferenceToScriptingFileSystemObject $refScriptingFileSystemObject -Path $strPath
        } else {
            $boolSuccess = Get-FileObjectSafelyUsingScriptingFileSystemObject -ReferenceToFileObject ([ref]$objFSOFolderOrFileObject) -ReferenceToScriptingFileSystemObject ([ref]$objScriptingFileSystemObject) -Path $strPath
        }
        if ($boolSuccess -eq $false) {
            # Error occurred
            # TODO: Use alternate method following P/invoke - see below
            return $false
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

    # Access the short path
    $refDOS83Path.Value = $objFSOFolderOrFileObject.ShortPath

    # Restore the former error preference
    $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference

    # Retrieve the newest error on the error stack
    $refNewestCurrentError = Get-ReferenceToLastError

    if (Test-ErrorOccurred $refLastKnownError $refNewestCurrentError) {
        # TODO: Try P/invoke approach
        # if (-not ([System.Management.Automation.PSTypeName]'Util.NativeMethods').Type) {
        # Add-Type -Namespace Util -Name NativeMethods -MemberDefinition @"
        #     using System;
        #     using System.Text;
        #     using System.Runtime.InteropServices;

        #     public static class NativeMethods {
        #         [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        #         public static extern int GetShortPathName(string lpszLongPath, StringBuilder lpszShortPath, int cchBuffer);

        #         public static string GetShortPath(string longPath) {
        #             if (string.IsNullOrEmpty(longPath))
        #                 throw new ArgumentException("Path cannot be null or empty.", nameof(longPath));

        #             // First call to get the required buffer size
        #             int size = GetShortPathName(longPath, null, 0);
        #             if (size == 0)
        #                 throw new System.ComponentModel.Win32Exception();

        #             StringBuilder shortPath = new StringBuilder(size);
        #             int result = GetShortPathName(longPath, shortPath, shortPath.Capacity);
        #             if (result == 0)
        #                 throw new System.ComponentModel.Win32Exception();

        #             return shortPath.ToString();
        #         }
        #     }
        #     "@
        # }
        # # Add-Type steps moved out of the function to a separate script or module for clarity and performance.

        # <#
        # .SYNOPSIS
        # Retrieves the DOS 8.3 short path for a given file or folder.

        # .DESCRIPTION
        # This function uses the Win32 GetShortPathName API to return the DOS 8.3 format of a given path.
        # The path must exist on the filesystem. If the path does not exist, an exception will be thrown.

        # .PARAMETER Path
        # The full path to a file or directory.

        # .EXAMPLE
        # Get-ShortPathName -Path "C:\Program Files\Microsoft Office"

        # .EXAMPLE
        # Get-ShortPathName -Path "C:\Windows\System32"

        # .NOTES
        # Requires the Util.NativeMethods class to be defined beforehand.
        # #>
        # function Get-ShortPathName {
        #     [CmdletBinding()]
        #     param(
        #         [Parameter(Mandatory=$true)]
        #         [string]$Path
        #     )

        #     # Validate input
        #     if ([string]::IsNullOrWhiteSpace($Path)) {
        #         throw [System.ArgumentException]::new("Path cannot be empty or whitespace.", "Path")
        #     }

        #     # Ensure path exists before attempting to retrieve short path
        #     if (-not (Test-Path $Path)) {
        #         throw [System.IO.FileNotFoundException]::new("The specified path does not exist.", $Path)
        #     }

        #     # Retrieve and return the short path
        #     try {
        #         return [Util.NativeMethods]::GetShortPath($Path)
        #     }
        #     catch [System.ComponentModel.Win32Exception] {
        #         # Provide a more descriptive error if the native call fails
        #         throw [System.InvalidOperationException]::new("Failed to retrieve the short path name for the specified path.", $_.Exception)
        #     }
        # }

        # Error occurred; return failure indicator:
        return $false
    } else {
        # No error occurred; return success indicator:
        return $true
    }
}
