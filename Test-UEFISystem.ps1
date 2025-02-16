
#region License
###############################################################################################
# Copyright 2025 Frank Lesniak

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###############################################################################################
#endregion License

# Version: 1.0.20250106.1

function Split-StringOnLiteralString {
    # .SYNOPSIS
    # Splits a string into an array using a literal string as the splitter.
    #
    # .DESCRIPTION
    # Splits a string using a literal string (as opposed to regex). The
    # function is designed to be backward-compatible with all versions of
    # PowerShell and has been tested successfully on PowerShell v1. This
    # function behaves more like VBScript's Split() function than other
    # string splitting-approaches in PowerShell while avoiding the use of
    # RegEx.
    #
    # .PARAMETER StringToSplit
    # This parameter is required; it is the string to be split into an
    # array.
    #
    # .PARAMETER Splitter
    # This parameter is required; it is the string that will be used to
    # split the string specified in the StringToSplit parameter.
    #
    # .EXAMPLE
    # $result = Split-StringOnLiteralString -StringToSplit 'What do you think of this function?' -Splitter ' '
    # # $result.Count is 7
    # # $result[2] is 'you'
    #
    # .EXAMPLE
    # $result = Split-StringOnLiteralString 'What do you think of this function?' ' '
    # # $result.Count is 7
    #
    # .EXAMPLE
    # $result = Split-StringOnLiteralString -StringToSplit 'foo' -Splitter ' '
    # # $result.GetType().FullName is System.Object[]
    # # $result.Count is 1
    #
    # .EXAMPLE
    # $result = Split-StringOnLiteralString -StringToSplit 'foo' -Splitter ''
    # # $result.GetType().FullName is System.Object[]
    # # $result.Count is 5 because of how .NET handles a split using an
    # # empty string:
    # # $result[0] is ''
    # # $result[1] is 'f'
    # # $result[2] is 'o'
    # # $result[3] is 'o'
    # # $result[4] is ''
    #
    # .INPUTS
    # None. You can't pipe objects to Split-StringOnLiteralString.
    #
    # .OUTPUTS
    # System.String[]. Split-StringOnLiteralString returns an array of
    # strings, with each string being an element of the resulting array
    # from the split operation. This function always returns an array, even
    # when there is zero elements or one element in it.
    #
    # .NOTES
    # This function also supports the use of positional parameters instead
    # of named parameters. If positional parameters are used instead of
    # named parameters, then two positional parameters are required:
    #
    # The first positional parameter is the string to be split into an
    # array.
    #
    # The second positional parameter is the string that will be used to
    # split the string specified in the first positional parameter.
    #
    # Also, please note that if -StringToSplit (or the first positional
    # parameter) is $null, then the function will return an array with one
    # element, which is an empty string. This is because the function
    # converts $null to an empty string before splitting the string.
    #
    # Version: 3.0.20250211.1

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

    param (
        [string]$StringToSplit = '',
        [string]$Splitter = ''
    )

    $strSplitterInRegEx = [regex]::Escape($Splitter)
    $result = @([regex]::Split($StringToSplit, $strSplitterInRegEx))

    # The following code forces the function to return an array, always,
    # even when there are zero or one elements in the array
    $intElementCount = 1
    if ($null -ne $result) {
        if ($result.GetType().FullName.Contains('[]')) {
            if (($result.Count -ge 2) -or ($result.Count -eq 0)) {
                $intElementCount = $result.Count
            }
        }
    }
    $strLowercaseFunctionName = $MyInvocation.InvocationName.ToLower()
    $boolArrayEncapsulation = $MyInvocation.Line.ToLower().Contains('@(' + $strLowercaseFunctionName + ')') -or $MyInvocation.Line.ToLower().Contains('@(' + $strLowercaseFunctionName + ' ')
    if ($boolArrayEncapsulation) {
        return ($result)
    } elseif ($intElementCount -eq 0) {
        return (, @())
    } elseif ($intElementCount -eq 1) {
        return (, (, $StringToSplit))
    } else {
        return ($result)
    }
}

function Get-PathToDotNetRuntimeEnvironment {
    $strPathToDotNetRuntimeEnvironment = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
    # We have the path, but it has a trailing backslash. Let's remove it
    $guid = [guid]::NewGuid()
    $strGUID = $guid.Guid
    $strWorkingPath = Join-Path $strPathToDotNetRuntimeEnvironment $strGUID
    $arrPath = Split-StringOnLiteralString -StringToSplit $strWorkingPath -Splitter $strGUID
    $strPathWithSeparatorButWithoutGUID = $arrPath[0]
    $strScrubbedPath = $strPathWithSeparatorButWithoutGUID.Substring(0, $strPathWithSeparatorButWithoutGUID.Length - 1)
    $strScrubbedPath
}

function Build-CSharpInMemory {
    Param (
        [string]$strCSharpCodeToCompile,
        [array]$arrAdditionalReferences
    )

    $CSharpCodeProvider = New-Object Microsoft.CSharp.CSharpCodeProvider

    $ArrayListReferences = New-Object Collections.ArrayList
    $ArrayListReferences.AddRange( `
        @( `
            (Join-Path (Get-PathToDotNetRuntimeEnvironment) "System.dll"),
            [PSObject].Assembly.Location
        )
    )
    if ($arrAdditionalReferences -ne $null)	{
        if ($arrAdditionalReferences.Count -ge 1) {
            $ArrayListReferences.AddRange($arrAdditionalReferences)
        }
    }

    $CompilerParameters = New-Object System.CodeDom.Compiler.CompilerParameters
    $CompilerParameters.GenerateInMemory = $true
    $CompilerParameters.GenerateExecutable = $false
    $CompilerParameters.OutputAssembly = "custom"
    $CompilerParameters.ReferencedAssemblies.AddRange($ArrayListReferences)
    $CompilerResults = $CSharpCodeProvider.CompileAssemblyFromSource($CompilerParameters, $strCSharpCodeToCompile)

    if ($CompilerResults.Errors.Count) {
        $arrCSharpCodeLines = $strCSharpCodeToCompile.Split("`n")
        foreach ($CompilerError in $CompilerResults.Errors) {
            Write-Host "Error: $($arrCSharpCodeLines[$($CompilerError.Line - 1)])"
            $CompilerError | Out-Default
        }
        Throw "INVALID DATA: Errors encountered while compiling code"
    }
}

function Get-PSVersion {
    # .SYNOPSIS
    # Returns the version of PowerShell that is running.
    #
    # .DESCRIPTION
    # The function outputs a [version] object representing the version of
    # PowerShell that is running.
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
    # .INPUTS
    # None. You can't pipe objects to Get-PSVersion.
    #
    # .OUTPUTS
    # System.Version. Get-PSVersion returns a [version] value indiciating
    # the version of PowerShell that is running.
    #
    # .NOTES
    # Version: 1.0.20250106.0

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

function Test-Windows {
    # .SYNOPSIS
    # Returns $true if PowerShell is running on Windows; otherwise, returns
    # $false.
    #
    # .DESCRIPTION
    # Returns a boolean ($true or $false) indicating whether the current
    # PowerShell session is running on Windows. This function is useful for
    # writing scripts that need to behave differently on Windows and non-
    # Windows platforms (Linux, macOS, etc.). Additionally, this function is
    # useful because it works on Windows PowerShell 1.0 through 5.1, which do
    # not have the $IsWindows global variable.
    #
    # .PARAMETER PSVersion
    # This parameter is optional; if supplied, it must be the version number of
    # the running version of PowerShell. If the version of PowerShell is
    # already known, it can be passed in to this function to avoid the overhead
    # of unnecessarily determining the version of PowerShell. If this parameter
    # is not supplied, the function will determine the version of PowerShell
    # that is running as part of its processing.
    #
    # .EXAMPLE
    # $boolIsWindows = Test-Windows
    #
    # .EXAMPLE
    # # The version of PowerShell is known to be 2.0 or above:
    # $boolIsWindows = Test-Windows -PSVersion $PSVersionTable.PSVersion
    #
    # .INPUTS
    # None. You can't pipe objects to Test-Windows.
    #
    # .OUTPUTS
    # System.Boolean. Test-Windows returns a boolean value indiciating whether
    # PowerShell is running on Windows. $true means that PowerShell is running
    # on Windows; $false means that PowerShell is not running on Windows.
    #
    # .NOTES
    # This function also supports the use of a positional parameter instead of
    # a named parameter. If a positional parameter is used instead of a named
    # parameter, then one positional parameter is required: it must be the
    # version number of the running version of PowerShell. If the version of
    # PowerShell is already known, it can be passed in to this function to
    # avoid the overhead of unnecessarily determining the version of
    # PowerShell. If this parameter is not supplied, the function will
    # determine the version of PowerShell that is running as part of its
    # processing.
    #
    # Version: 1.1.20250106.1

    #region License ########################################################
    # Copyright (c) 2025 Frank Lesniak
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
        [version]$PSVersion = ([version]'0.0')
    )

    function Get-PSVersion {
        # .SYNOPSIS
        # Returns the version of PowerShell that is running.
        #
        # .DESCRIPTION
        # The function outputs a [version] object representing the version of
        # PowerShell that is running.
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
        # .INPUTS
        # None. You can't pipe objects to Get-PSVersion.
        #
        # .OUTPUTS
        # System.Version. Get-PSVersion returns a [version] value indiciating
        # the version of PowerShell that is running.
        #
        # .NOTES
        # Version: 1.0.20250106.0

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

    if ($PSVersion -ne ([version]'0.0')) {
        if ($PSVersion.Major -ge 6) {
            return $IsWindows
        } else {
            return $true
        }
    } else {
        $versionPS = Get-PSVersion
        if ($versionPS.Major -ge 6) {
            return $IsWindows
        } else {
            return $true
        }
    }
}

function Get-WindowsOSVersion {
    # TODO: Add optional parameter to allow the version of PowerShell to be specified
    #       as a parameter to this function, which can improve performance by avoiding
    #       the overhead of determining the version of PowerShell if it is already
    #       known.
    # TODO: Add optional parameter to skip the check to determine if the current
    #       PowerShell session is running on Windows. This can be useful if the
    #       caller already knows that the current PowerShell session is running on
    #       Windows and wants to avoid the overhead of checking again.

    $strThisScriptVersionNumber = [version]'1.0.20250106.1'

    function Get-PSVersion {
        # .SYNOPSIS
        # Returns the version of PowerShell that is running.
        #
        # .DESCRIPTION
        # The function outputs a [version] object representing the version of
        # PowerShell that is running.
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
        # .INPUTS
        # None. You can't pipe objects to Get-PSVersion.
        #
        # .OUTPUTS
        # System.Version. Get-PSVersion returns a [version] value indiciating
        # the version of PowerShell that is running.
        #
        # .NOTES
        # Version: 1.0.20250106.0

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

    function Test-Windows {
        # .SYNOPSIS
        # Returns $true if PowerShell is running on Windows; otherwise, returns
        # $false.
        #
        # .DESCRIPTION
        # Returns a boolean ($true or $false) indicating whether the current
        # PowerShell session is running on Windows. This function is useful for
        # writing scripts that need to behave differently on Windows and non-
        # Windows platforms (Linux, macOS, etc.). Additionally, this function is
        # useful because it works on Windows PowerShell 1.0 through 5.1, which do
        # not have the $IsWindows global variable.
        #
        # .PARAMETER PSVersion
        # This parameter is optional; if supplied, it must be the version number of
        # the running version of PowerShell. If the version of PowerShell is
        # already known, it can be passed in to this function to avoid the overhead
        # of unnecessarily determining the version of PowerShell. If this parameter
        # is not supplied, the function will determine the version of PowerShell
        # that is running as part of its processing.
        #
        # .EXAMPLE
        # $boolIsWindows = Test-Windows
        #
        # .EXAMPLE
        # # The version of PowerShell is known to be 2.0 or above:
        # $boolIsWindows = Test-Windows -PSVersion $PSVersionTable.PSVersion
        #
        # .INPUTS
        # None. You can't pipe objects to Test-Windows.
        #
        # .OUTPUTS
        # System.Boolean. Test-Windows returns a boolean value indiciating whether
        # PowerShell is running on Windows. $true means that PowerShell is running
        # on Windows; $false means that PowerShell is not running on Windows.
        #
        # .NOTES
        # This function also supports the use of a positional parameter instead of
        # a named parameter. If a positional parameter is used instead of a named
        # parameter, then one positional parameter is required: it must be the
        # version number of the running version of PowerShell. If the version of
        # PowerShell is already known, it can be passed in to this function to
        # avoid the overhead of unnecessarily determining the version of
        # PowerShell. If this parameter is not supplied, the function will
        # determine the version of PowerShell that is running as part of its
        # processing.
        #
        # Version: 1.1.20250106.1

        #region License ########################################################
        # Copyright (c) 2025 Frank Lesniak
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
            [version]$PSVersion = ([version]'0.0')
        )

        function Get-PSVersion {
            # .SYNOPSIS
            # Returns the version of PowerShell that is running.
            #
            # .DESCRIPTION
            # The function outputs a [version] object representing the version of
            # PowerShell that is running.
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
            # .INPUTS
            # None. You can't pipe objects to Get-PSVersion.
            #
            # .OUTPUTS
            # System.Version. Get-PSVersion returns a [version] value indiciating
            # the version of PowerShell that is running.
            #
            # .NOTES
            # Version: 1.0.20250106.0

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

        if ($PSVersion -ne ([version]'0.0')) {
            if ($PSVersion.Major -ge 6) {
                return $IsWindows
            } else {
                return $true
            }
        } else {
            $versionPS = Get-PSVersion
            if ($versionPS.Major -ge 6) {
                return $IsWindows
            } else {
                return $true
            }
        }
    }

    $versionPS = Get-PSVersion
    $boolWindows = Test-Windows -PSVersion $versionPS
    if ($boolWindows) {
        if ($versionPS.Major -ge 3) {
            $arrCIMInstanceOS = @(Get-CimInstance -Query "Select Version from Win32_OperatingSystem" -ErrorAction Ignore)
            if ($arrCIMInstanceOS.Count -eq 0) {
                Write-Error "No instances of Win32_OperatingSystem found!"
                $null
            }
            if ($arrCIMInstanceOS.Count -gt 1) {
                Write-Warning "More than one instance of Win32_OperatingSystem returned. Will only use first instance."
            }
            if ($arrCIMInstanceOS.Count -ge 1) {
                [System.Version](($arrCIMInstanceOS[0]).Version)
            }
        } else {
            $arrManagementObjectOS = @(Get-WmiObject -Query "Select Version from Win32_OperatingSystem" -ErrorAction SilentlyContinue)
            if ($arrManagementObjectOS.Count -eq 0) {
                Write-Error "No instances of Win32_OperatingSystem found!"
                $null
            }
            if ($arrManagementObjectOS.Count -gt 1) {
                Write-Warning "More than one instance of Win32_OperatingSystem returned. Will only use first instance."
            }
            if ($arrManagementObjectOS.Count -ge 1) {
                [System.Version](($arrManagementObjectOS[0]).Version)
            }
        }
    } else {
        $null
    }
}

function Get-PathToWindowsFolder {
    # TODO: Add optional parameter to allow the version of PowerShell to be specified
    #       as a parameter to this function, which can improve performance by avoiding
    #       the overhead of determining the version of PowerShell if it is already
    #       known.
    # TODO: Add optional parameter to skip the check to determine if the current
    #       PowerShell session is running on Windows. This can be useful if the
    #       caller already knows that the current PowerShell session is running on
    #       Windows and wants to avoid the overhead of checking again.

    # Version: 1.0.20250106.1

    function Test-Windows {
        # .SYNOPSIS
        # Returns $true if PowerShell is running on Windows; otherwise, returns
        # $false.
        #
        # .DESCRIPTION
        # Returns a boolean ($true or $false) indicating whether the current
        # PowerShell session is running on Windows. This function is useful for
        # writing scripts that need to behave differently on Windows and non-
        # Windows platforms (Linux, macOS, etc.). Additionally, this function is
        # useful because it works on Windows PowerShell 1.0 through 5.1, which do
        # not have the $IsWindows global variable.
        #
        # .PARAMETER PSVersion
        # This parameter is optional; if supplied, it must be the version number of
        # the running version of PowerShell. If the version of PowerShell is
        # already known, it can be passed in to this function to avoid the overhead
        # of unnecessarily determining the version of PowerShell. If this parameter
        # is not supplied, the function will determine the version of PowerShell
        # that is running as part of its processing.
        #
        # .EXAMPLE
        # $boolIsWindows = Test-Windows
        #
        # .EXAMPLE
        # # The version of PowerShell is known to be 2.0 or above:
        # $boolIsWindows = Test-Windows -PSVersion $PSVersionTable.PSVersion
        #
        # .INPUTS
        # None. You can't pipe objects to Test-Windows.
        #
        # .OUTPUTS
        # System.Boolean. Test-Windows returns a boolean value indiciating whether
        # PowerShell is running on Windows. $true means that PowerShell is running
        # on Windows; $false means that PowerShell is not running on Windows.
        #
        # .NOTES
        # This function also supports the use of a positional parameter instead of
        # a named parameter. If a positional parameter is used instead of a named
        # parameter, then one positional parameter is required: it must be the
        # version number of the running version of PowerShell. If the version of
        # PowerShell is already known, it can be passed in to this function to
        # avoid the overhead of unnecessarily determining the version of
        # PowerShell. If this parameter is not supplied, the function will
        # determine the version of PowerShell that is running as part of its
        # processing.
        #
        # Version: 1.1.20250106.1

        #region License ########################################################
        # Copyright (c) 2025 Frank Lesniak
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
            [version]$PSVersion = ([version]'0.0')
        )

        function Get-PSVersion {
            # .SYNOPSIS
            # Returns the version of PowerShell that is running.
            #
            # .DESCRIPTION
            # The function outputs a [version] object representing the version of
            # PowerShell that is running.
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
            # .INPUTS
            # None. You can't pipe objects to Get-PSVersion.
            #
            # .OUTPUTS
            # System.Version. Get-PSVersion returns a [version] value indiciating
            # the version of PowerShell that is running.
            #
            # .NOTES
            # Version: 1.0.20250106.0

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

        if ($PSVersion -ne ([version]'0.0')) {
            if ($PSVersion.Major -ge 6) {
                return $IsWindows
            } else {
                return $true
            }
        } else {
            $versionPS = Get-PSVersion
            if ($versionPS.Major -ge 6) {
                return $IsWindows
            } else {
                return $true
            }
        }
    }

    $boolWindows = Test-Windows
    if ($boolWindows) {
        $env:windir
    } else {
        $null
    }
}

function Get-PathToWindowsSetupLog {
    $strWindowsPath = Get-PathToWindowsFolder
    if ($null -ne $strWindowsPath) {
        $strWorkingPath = Join-Path $strWindowsPath "Panther"
        $strWorkingPath = Join-Path $strWorkingPath "setupact.log"
        $strWorkingPath
    } else {
        $null
    }
}

function Get-DetectedBootEnvironmentFromWindowsSetupLog {
    # Returns a string containing the "detected boot environment" from the Windows Setup log.
    # If the log could not be read, or if this function is run on non-Windows, the function
    # returns $null
    #
    #region OriginalLicense
    # Although substantial modifications have been made, the original portions of
    # Get-LogFileFirmwareType that are incorporated into
    # Get-DetectedBootEnvironmentFromWindowsSetupLog are subject to the following license:
    ###########################################################################################
    # Copyright (c) 2015 Chris Warwick
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy of this
    # software and associated documentation files (the "Software"), to deal in the Software
    # without restriction, including without limitation the rights to use, copy, modify, merge,
    # publish, distribute, sublicense, and/or sell copies of the Software, and to permit
    # persons to whom the Software is furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all copies or
    # substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    # INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
    # PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
    # FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
    # OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    # DEALINGS IN THE SOFTWARE.
    ###########################################################################################
    #endregion OriginalLicense

    $versionPS = Get-PSVersion
    $strPathToWindowsSetupLog = Get-PathToWindowsSetupLog
    if ($null -ne $strPathToWindowsSetupLog) {
        if ($versionPS.Major -ge 3) {
            $arrMatchInfo = @(Select-String 'Detected boot environment' $strPathToWindowsSetupLog -AllMatches -ErrorAction Ignore)
        } else {
            $arrMatchInfo = @(Select-String 'Detected boot environment' $strPathToWindowsSetupLog -AllMatches -ErrorAction SilentlyContinue)
        }
        if ($arrMatchInfo.Count -ge 1) {
            $arrStrBootEnvironments = @($arrMatchInfo | ForEach-Object {
                    ($_.Line) -replace ".*:\s+"
                })

            if ($arrStrBootEnvironments.Count -gt 1) {
                Write-Warning ("More than one detected boot environment found in Windows Setup Log (" + $strPathToWindowsSetupLog + "). Returning only first one.")
            }

            $arrStrBootEnvironments[0]
        } else {
            Write-Warning ("Read access to file " + $strPathToWindowsSetupLog + " was denied; try running PowerShell as an administrator (elevated)")
            $null
        }
    } else {
        $null
    }
}

function Test-FirmwareEnvironmentVariableAWin32API {
    # Returns $true if the GetFirmwareEnvironmentVariableA Win32 API is able to be called,
    # which indicates that the system is UEFI. Returns $false otherwise.
    #
    # NOTE: Returns $null if run on non-Windows system
    #
    #region OriginalLicense
    # Although substantial modifications have been made, the original portions of
    # Get-FirmwareEnvironmentVariableAPI that are incorporated into
    # Test-FirmwareEnvironmentVariableAWin32API are subject to the following license:
    ###########################################################################################
    # Copyright (c) 2015 Chris Warwick
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy of this
    # software and associated documentation files (the "Software"), to deal in the Software
    # without restriction, including without limitation the rights to use, copy, modify, merge,
    # publish, distribute, sublicense, and/or sell copies of the Software, and to permit
    # persons to whom the Software is furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all copies or
    # substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    # INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
    # PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
    # FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
    # OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    # DEALINGS IN THE SOFTWARE.
    ###########################################################################################
    #endregion OriginalLicense

    # Use the GetFirmwareEnvironmentVariable Win32 API.
    # From MSDN
    # (http://msdn.microsoft.com/en-ca/library/windows/desktop/ms724325%28v=vs.85%29.aspx):
    # "Firmware variables are not supported on a legacy BIOS-based system. The
    # GetFirmwareEnvironmentVariable function will always fail on a legacy BIOS-based system,
    # or if Windows was installed using legacy BIOS on a system that supports both legacy BIOS
    # and UEFI."
    # "To identify these conditions, call the function with a dummy firmware environment name
    # such as an empty string ("") for the lpName parameter and a dummy GUID such as
    # "{00000000-0000-0000-0000-000000000000}" for the lpGuid parameter. On a legacy BIOS-based
    # system, or on a system that supports both legacy BIOS and UEFI where Windows was
    # installed using legacy BIOS, the function will fail with ERROR_INVALID_FUNCTION. On a
    # UEFI-based system, the function will fail with an error specific to the firmware, such as
    # ERROR_NOACCESS, to indicate that the dummy GUID namespace does not exist."
    #
    # From PowerShell, we can call the API via P/Invoke from a compiled C# class using
    # Add-Type.  In Win32 any resulting API error is retrieved using GetLastError(), however,
    # this is not reliable in .Net (see
    # blogs.msdn.com/b/adam_nathan/archive/2003/04/25/56643.aspx), instead we mark the pInvoke
    # signature for GetFirmwareEnvironmentVariableA with SetLastError=true and use
    # Marshal.GetLastWin32Error()
    #
    # Note: The GetFirmwareEnvironmentVariable API requires the SE_SYSTEM_ENVIRONMENT_NAME
    # privilege.  In the Security Policy editor this equates to "User Rights Assignment":
    # "Modify firmware environment values" and is granted to Administrators by default. Because
    # we don't actually read any variables this permission appears to be optional.

    $versionPS = Get-PSVersion
    $boolWindows = Test-Windows -PSVersion $versionPS

    if ($boolWindows) {
        $versionWindows = Get-WindowsOSVersion
        if ($versionWindows -ge ([System.Version]"6.1")) {
            $strCSharpCode = @"
using System;
using System.Runtime.InteropServices;
namespace FrankLesniak
{
    public class CheckUEFI
    {
        [DllImport("kernel32.dll", SetLastError=true)]
        static extern UInt32
        GetFirmwareEnvironmentVariableA(string lpName, string lpGuid, IntPtr pBuffer, UInt32 nSize);
        const int ERROR_INVALID_FUNCTION = 1;
        public static bool IsUEFI()
        {
            // Try to call the GetFirmwareEnvironmentVariable API.  This is invalid on legacy BIOS.
            GetFirmwareEnvironmentVariableA("","{00000000-0000-0000-0000-000000000000}",IntPtr.Zero,0);
            if (Marshal.GetLastWin32Error() == ERROR_INVALID_FUNCTION)
                return false;     // API not supported (INVALID_FUNCTION); this is a legacy BIOS
            else
                return true;      // Call to API is supported.  This is UEFI.
        }
    }
}
"@
            if ($versionPS.Major -ge 2) {
                Add-Type -Language CSharp -TypeDefinition $strCSharpCode
            } else {
                Build-CSharpInMemory $strCSharpCode
            }

            [FrankLesniak.CheckUEFI]::IsUEFI()
        } else {
            # Is Windows, but is a version that does not support
            # GetFirmwareEnvironmentVariableA API
            $null
        }
    } else {
        # Not Windows
        $null
    }
}

function Get-FirmwareTypeFromGetFirmwareTypeWin32API {
    # Returns an integer that indicates the firmware type on the system.
    # Returns:
    #   0 if the type is unknown
    #   1 if the type is BIOS
    #   2 if the type is UEFI
    #   3 if the type is "Max"
    #
    # NOTE: Returns $null if run on non-Windows system
    #
    #region OriginalLicense
    # Although substantial modifications have been made, the original portions of
    # Get-FirmwareTypeAPI that are incorporated into
    # Get-FirmwareTypeFromGetFirmwareTypeWin32API are subject to the following license:
    ###########################################################################################
    # Copyright (c) 2015 Chris Warwick
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy of this
    # software and associated documentation files (the "Software"), to deal in the Software
    # without restriction, including without limitation the rights to use, copy, modify, merge,
    # publish, distribute, sublicense, and/or sell copies of the Software, and to permit
    # persons to whom the Software is furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all copies or
    # substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    # INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
    # PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
    # FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
    # OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    # DEALINGS IN THE SOFTWARE.
    ###########################################################################################
    #endregion OriginalLicense
    #
    # In Windows 8/Server 2012 and above there's an API that directly returns the firmware type
    # and doesn't rely on a hack. GetFirmwareType() in kernel32.dll
    # (http://msdn.microsoft.com/en-us/windows/desktop/hh848321%28v=vs.85%29.aspx) returns a
    # pointer to a FirmwareType enum that defines the following:
    #
    # typedef enum _FIRMWARE_TYPE {
    #   FirmwareTypeUnknown = 0,
    #   FirmwareTypeBios = 1,
    #   FirmwareTypeUefi = 2,
    #   FirmwareTypeMax = 3
    # } FIRMWARE_TYPE, *PFIRMWARE_TYPE;
    # This API call can be called in .Net via P/Invoke.

    $versionPS = Get-PSVersion
    $boolWindows = Test-Windows -PSVersion $versionPS

    if ($boolWindows) {
        $versionWindows = Get-WindowsOSVersion
        if ($versionWindows -ge ([System.Version]"6.2")) {
            $strCSharpCode = @"
using System;
using System.Runtime.InteropServices;
namespace FrankLesniak
{
    public class FirmwareType
    {
        [DllImport("kernel32.dll")]
        static extern bool GetFirmwareType(ref uint FirmwareType);
        public static uint GetFirmwareType()
        {
            uint firmwaretype = 0;
            if (GetFirmwareType(ref firmwaretype))
                return firmwaretype;
            else
                return 0;   // API call failed, just return 'unknown'
        }
    }
}
"@
            if ($versionPS.Major -ge 2) {
                Add-Type -Language CSharp -TypeDefinition $strCSharpCode
            } else {
                Build-CSharpInMemory $strCSharpCode
            }

            [FrankLesniak.FirmwareType]::GetFirmwareType()
        } else {
            # Is Windows, but is a version that does not support
            # GetFirmwareEnvironmentVariableA API
            $null
        }
    } else {
        # Not Windows
        $null
    }
}

function Test-UEFISystem {
    # Returns $true if the system is UEFI
    # Returns $false if the system is not UEFI (i.e., it is BIOS)
    # Returns $null if the system type could not be determined
    #
    #region OriginalLicense
    # Although substantial modifications have been made, the original portions of
    # Get-FirmwareType that are incorporated into Test-UEFISystem are subject to the following
    # license:
    ###########################################################################################
    # Copyright (c) 2015 Chris Warwick
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy of this
    # software and associated documentation files (the "Software"), to deal in the Software
    # without restriction, including without limitation the rights to use, copy, modify, merge,
    # publish, distribute, sublicense, and/or sell copies of the Software, and to permit
    # persons to whom the Software is furnished to do so, subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all copies or
    # substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    # INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
    # PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
    # FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
    # OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    # DEALINGS IN THE SOFTWARE.
    ###########################################################################################
    #endregion OriginalLicense
    $boolWindows = Test-Windows
    if ($boolWindows) {
        $versionWindowsOS = Get-WindowsOSVersion
        if ($versionWindowsOS -lt ([System.Version]"6.0")) {
            # Windows 5.x running PowerShell - these do not support UEFI
            $false
        } elseif ($versionWindowsOS -ge ([System.Version]"6.2")) {
            # Windows 8 / Windows Server 2012, or newer
            $intFirmwareType = Get-FirmwareTypeFromGetFirmwareTypeWin32API
            if ($null -ne $intFirmwareType) {
                if ($intFirmwareType -eq 2) {
                    $true # UEFI
                } else {
                    $false # Not UEFI, must be BIOS
                }
            } else {
                # Error condition
                $null
            }
        } elseif ($versionWindowsOS -ge ([System.Version]"6.1")) {
            # Windows 7 / Windows Server 2008 R2
            Test-FirmwareEnvironmentVariableAWin32API
        } else {
            $strDetectedBootEnvironment = Get-DetectedBootEnvironmentFromWindowsSetupLog
            switch -Regex ($strDetectedBootEnvironment) {
                "^U?EFI$" {
                    $true
                }
                default {
                    $false
                }
            }
        }
    } else {
        # TO-DO: write code for FreeBSD/Linux
        # return $null for now
        $null
    }
}
