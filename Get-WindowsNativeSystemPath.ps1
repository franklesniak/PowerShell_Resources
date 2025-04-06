function Get-WindowsNativeSystemPath {
    # .SYNOPSIS
    # On Windows, gets the OS-native, non-redirected system path (e.g.,
    # C:\Windows\System32 or C:\Windows\Sysnative)
    #
    # .DESCRIPTION
    # This function retrieves the OS-native, non-redirected system path (e.g.,
    # C:\Windows\System32 or C:\Windows\Sysnative) on Windows. It does this by
    # determining if the running process is a 32-bit or 64-bit process, then
    # comparing that to the operating system architecture. If the "bit width"
    # of the operating system and the process are the same, it returns the
    # equivalent of 'C:\Windows\System32'. If the "bit width" of the operating
    # system is 64 but the process is 32, it returns the equivalent of
    # 'C:\Windows\Sysnative', assuming 'C:\Windows\Sysnative' exists.
    #
    # .PARAMETER ReferenceToSystemPath
    # This parameter is required; it is a reference to a string object that
    # will be used to store the OS-native, non-redirected system path.
    #
    # .PARAMETER OSProcessorArchitecture
    # This parameter is optional; if supplied, it is a string representing the
    # Windows operating system processor architecture. It is used to determine
    # the "bit width" of the operating system. If not supplied, this function
    # will automatically attempt to retrieve the OS processor architecture.
    #
    # .PARAMETER ProcessProcessorArchitecture
    # This parameter is optional; if supplied, it is a string representing the
    # current process's processor architecture. It is used to determine the
    # "bit width" of the code for the running process. If not supplied, this
    # function will automatically attempt to retrieve the process processor
    # architecture.
    #
    # .EXAMPLE
    # $strRegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    # $strValueName = 'PROCESSOR_ARCHITECTURE'
    # $strOSArchitecture = (Get-ItemProperty -Path $strRegistryPath -Name $strValueName).$strValueName
    # $strProcessArchitecture = $env:PROCESSOR_ARCHITECTURE
    # $strNativeSystemPath = ''
    # $intReturnCode = Get-WindowsNativeSystemPath -ReferenceToSystemPath ([ref]$strNativeSystemPath) -OSProcessorArchitecture $strOSArchitecture -ProcessProcessorArchitecture $strProcessArchitecture
    #
    # .EXAMPLE
    # $strNativeSystemPath = ''
    # $intReturnCode = Get-WindowsNativeSystemPath -ReferenceToSystemPath ([ref]$strNativeSystemPath)
    #
    # .EXAMPLE
    # $strNativeSystemPath = ''
    # $intReturnCode = Get-WindowsNativeSystemPath ([ref]$strNativeSystemPath)
    #
    # .INPUTS
    # None. You can't pipe objects to Get-WindowsNativeSystemPath.
    #
    # .OUTPUTS
    # System.Int32. Get-WindowsNativeSystemPath returns an integer value
    # indiciating whether the process completed successfully. 0 means the
    # process completed successfully; any other value means that an error
    # occurred.
    #
    # .NOTES
    # Note: on Windows XP and Windows Server 2003, it is possible that the
    # "Sysnative" folder does not exist (this functionality was added to
    # Windows XP and Windows Server 2003 via a hotfix--KB942589). If the
    # "Sysnative" folder does not exist and PowerShell is running as a 32-bit
    # process on 64-bit Windows this function will return an error code. The
    # user will either need to relaunch PowerShell as a system-native process,
    # install KB942589, or upgrade their operating system.
    #
    # This function also supports the use of positional parameters instead of
    # named parameters. If positional parameters are used instead of named
    # parameters, then 1-3 positional parameters are required:
    #
    # The first positional parameter is a reference to a string object that
    # will be used to store the OS-native, non-redirected system path.
    #
    # If supplied, the second positional parameter is a string representing the
    # Windows operating system processor architecture. It is used to determine
    # the "bit width" of the operating system. If not supplied, this function
    # will automatically attempt to retrieve the OS processor architecture.
    #
    # If supplied, the third positional parameter is a string representing the
    # current process's processor architecture. It is used to determine the
    # "bit width" of the code for the running process. If not supplied, this
    # function will automatically attempt to retrieve the process processor
    # architecture.
    #
    # Version: 1.0.20250406.1

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
        [ref]$ReferenceToSystemPath = ([ref]$null),
        [string]$OSProcessorArchitecture = '',
        [string]$ProcessProcessorArchitecture = ''
    )

    function Get-WindowsOSProcessorArchitecture {
        # .SYNOPSIS
        # Determines the processor architecture (instruction set) of the
        # operating system.
        #
        # .DESCRIPTION
        # This function determines the processor architecture (instruction set)
        # of the operating system. It reads this value from the registry and
        # returns it via a referenced string object. The processor architecture
        # is the instruction set that the operating system is using to run. On
        # Windows versions that support PowerShell, known values are:
        #
        # - x86 (i.e., 32-bit x86)
        # - AMD64 (i.e., x86-64 or 64-bit x86)
        # - ARM (i.e., 32-bit ARM)
        # - ARM64 (i.e., 64-bit ARM)
        # - IA64 (i.e., Itanium)
        #
        # .PARAMETER ReferenceToOSProcessorArchitecture
        # This parameter is required; it is a reference to a string that will
        # be used to store output if the function completes successfully. The
        # string will be set to the processor architecture (instruction set) of
        # the operating system.
        #
        # .EXAMPLE
        # $strOSProcessorArchitecture = ''
        # $boolSuccess = Get-WindowsOSProcessorArchitecture -ReferenceToOSProcessorArchitecture ([ref]$strOSProcessorArchitecture)
        #
        # .EXAMPLE
        # $strOSProcessorArchitecture = ''
        # $boolSuccess = Get-WindowsOSProcessorArchitecture ([ref]$strOSProcessorArchitecture)
        #
        # .INPUTS
        # None. You can't pipe objects to Get-WindowsOSProcessorArchitecture.
        #
        # .OUTPUTS
        # System.Boolean. Get-WindowsOSProcessorArchitecture returns a boolean
        # value indiciating whether the operating system processor architecture
        # was retrieved successfully. $true means the operating system
        # processor architecture was determined successfully; $false means
        # there was an error.
        #
        # .NOTES
        # This function also supports the use of a positional parameter instead
        # of a named parameter. If a positional parameter is used instead of a
        # named parameter, then exactly one positional parameter is required: a
        # reference to a string that will be used to store output if the
        # function completes successfully. The string will be set to the
        # processor architecture (instruction set) of the operating system.
        #
        # Version: 1.0.20250406.1

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

        #region Acknowledgements ###########################################
        # Microsoft, for providing a current reference on the SYSTEM_INFO
        # struct, used by the GetSystemInfo Win32 function. This reference does
        # not show the exact text of the PROCESSOR_ARCHITECTURE environment
        # variable, but shows the universe of what's possible on a core system
        # API:
        # https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info#members
        #
        # Microsoft, for including in the MSDN Library Jan 2003 information on
        # this same SYSTEM_INFO struct that pre-dates Windows 2000 and
        # enumerates additional processor architectures (MIPS, ALPHA, PowerPC,
        # IA32_ON_WIN64). The MSDN Library Jan 2003 also lists SHX and ARM,
        # explains nuiances in accessing environment variables on pre-Windows
        # 2000 operating systems (namely that VBScript in Windows 9x can only
        # access per-process environment variables), and that the
        # PROCESSOR_ARCHITECTURE system environment variable is not available
        # on Windows 98/ME.
        # (link unavailable, check Internet Archive for source)
        #
        # "guga" for the first post in this thread that tipped me off to the
        # SYSTEM_INFO struct and additional architectures:
        # http://masm32.com/board/index.php?topic=3401.0
        #endregion Acknowledgements ###########################################

        param (
            [ref]$ReferenceToOSProcessorArchitecture = ([ref]$null)
        )

        function Test-RegistryValue {
            # .SYNOPSIS
            # Tests to determine whether a registry value exists in the Windows
            # registry.
            #
            # .DESCRIPTION
            # This function tests to determine whether a registry value exists
            # in the Windows registry. It returns a boolean value indicating
            # whether the registry value exists. $true indicates the registry
            # value exists; $false indicates the registry value does not exist.
            #
            # .PARAMETER RefPathToRegistryKey
            # Either this parameter or PathToRegistryKey are required; if
            # RefPathToRegistryKey is specified, it is a reference to a string
            # that contains the path to the registry key. If this parameter is
            # not specified, then PathToRegistryKey must be specified. If both
            # are specified, then RefPathToRegistryKey takes precedence over
            # PathToRegistryKey.
            #
            # .PARAMETER PathToRegistryKey
            # Either this parameter or RefPathToRegistryKey are required; if
            # PathToRegistryKey is specified, it is a string that contains the
            # path to the registry key. If this parameter is not specified,
            # then RefPathToRegistryKey must be specified. If both are
            # specified, then RefPathToRegistryKey takes precedence over
            # PathToRegistryKey.
            #
            # .PARAMETER RefNameOfRegistryValue
            # Either this parameter or NameOfRegistryValue are required; if
            # RefNameOfRegistryValue is specified, it is a reference to a
            # string that contains the name of the registry value to be tested.
            # If this parameter is not specified, then NameOfRegistryValue must
            # be specified. If both are specified, then RefNameOfRegistryValue
            # takes precedence over NameOfRegistryValue.
            #
            # .PARAMETER NameOfRegistryValue
            # Either this parameter or RefNameOfRegistryValue are required; if
            # NameOfRegistryValue is specified, it is a string that contains
            # the name of the registry value to be tested. If this parameter is
            # not specified, then RefNameOfRegistryValue must be specified. If
            # both are specified, then RefNameOfRegistryValue takes precedence
            # over NameOfRegistryValue.
            #
            # .EXAMPLE
            # $strRegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
            # $strRegistryValue = 'PROCESSOR_ARCHITECTURE'
            # $boolRegistryValueExists = Test-RegistryValue -RefPathToRegistryKey ([ref]$strRegistryPath) -RefNameOfRegistryValue ([ref]$strRegistryValue)
            #
            # .EXAMPLE
            # $strRegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
            # $strRegistryValue = 'PROCESSOR_ARCHITECTURE'
            # $boolRegistryValueExists = Test-RegistryValue -PathToRegistryKey $strRegistryPath -NameOfRegistryValue $strRegistryValue
            #
            # .INPUTS
            # None. You can't pipe objects to Test-RegistryValue.
            #
            # .OUTPUTS
            # System.Boolean. Test-RegistryValue returns a boolean value
            # indiciating whether the registry value exists. $true indicates
            # the registry value exists; $false indicates the registry value
            # does not exist, or that the specified registry key does not
            # exist.
            #
            # .NOTES
            # Oddly enough, it seems that passing string parameters by
            # reference is not faster than passing them by value. I thought
            # that passing by reference would be faster, but it seems that
            # passing by value is faster. I don't know why this is the case,
            # but it is.
            #
            # Version: 1.0.20250406.1

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

            param (
                [ref]$RefPathToRegistryKey = ([ref]$null),
                [string]$PathToRegistryKey = '',
                [ref]$RefNameOfRegistryValue = ([ref]$null),
                [string]$NameOfRegistryValue = ''
            )

            if ([string]::IsNullOrEmpty($RefPathToRegistryKey.Value) -and [string]::IsNullOrEmpty($PathToRegistryKey)) {
                Write-Error -Message 'Either RefPathToRegistryKey or PathToRegistryKey must be specified.'
                return $false
            }

            # Specifying an empty string for the name of the registry value is
            # valid; it would mean the "default" value of the registry key.
            # However, if both RefNameOfRegistryValue and NameOfRegistryValue
            # are empty, then we have a problem.
            if (($null -eq $RefNameOfRegistryValue.Value) -and ($null -eq $NameOfRegistryValue)) {
                Write-Error -Message 'Either RefNameOfRegistryValue or NameOfRegistryValue must be specified.'
                return $false
            }

            if (-not [string]::IsNullOrEmpty($RefPathToRegistryKey.Value)) {
                $refActualPathToRegistryKey = $RefPathToRegistryKey
            } else {
                $refActualPathToRegistryKey = [ref]$PathToRegistryKey
            }
            if (-not [string]::IsNullOrEmpty($RefNameOfRegistryValue.Value)) {
                $refActualNameOfRegistryValue = $RefNameOfRegistryValue
            } else {
                $refActualNameOfRegistryValue = [ref]$NameOfRegistryValue
            }

            if (Test-Path -LiteralPath $refActualPathToRegistryKey.Value) {
                $registryKey = Get-Item -LiteralPath $refActualPathToRegistryKey.Value
                if ($null -ne $registryKey.GetValue($refActualNameOfRegistryValue.Value, $null)) {
                    return $true
                } else {
                    return $false
                }
            } else {
                return $false
            }
        }

        $strRegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
        $strValueName = 'PROCESSOR_ARCHITECTURE'
        if (Test-RegistryValue -PathToRegistryKey $strRegistryPath -NameOfRegistryValue $strValueName) {
            # The registry value exists; get the value and return it.
            $ReferenceToOSProcessorArchitecture.Value = ((Get-ItemProperty -Path $strRegistryPath -Name $strValueName).PSObject.Properties |
                    Where-Object { $_.Name -eq $strValueName }).Value
            return $true
        } else {
            # The registry value does not exist; return an error.
            return $false
        }
    }

    function Get-WindowsProcessProcessorArchitecture {
        # .SYNOPSIS
        # Gets the processor architecture of the current process, assuming the
        # current process is running on Windows.
        #
        # .DESCRIPTION
        # This function determines the processor architecture (instruction set)
        # of the current process, assuming it is running on Windows. It reads
        # this value from the environment variables and returns it via a
        # referenced string object. The processor architecture is the
        # instruction set that the process is using to run. On Windows versions
        # that support PowerShell, known values are:
        #
        # - x86 (i.e., 32-bit x86)
        # - AMD64 (i.e., x86-64 or 64-bit x86)
        # - ARM (i.e., 32-bit ARM)
        # - ARM64 (i.e., 64-bit ARM)
        # - IA64 (i.e., Itanium)
        #
        # .PARAMETER ReferenceToProcessProcessorArchitecture
        # This parameter is required; it is a reference to a string that will
        # be used to store output if the function completes successfully. The
        # string will be set to the processor architecture (instruction set) of
        # the currently running process.
        #
        # .EXAMPLE
        # $strProcessProcessorArchitecture = ''
        # $boolSuccess = Get-WindowsProcessProcessorArchitecture -ReferenceToProcessProcessorArchitecture ([ref]$strProcessProcessorArchitecture)
        #
        # .EXAMPLE
        # $strProcessProcessorArchitecture = ''
        # $boolSuccess = Get-WindowsProcessProcessorArchitecture ([ref]$strProcessProcessorArchitecture)
        #
        # .INPUTS
        # None. You can't pipe objects to
        # Get-WindowsProcessProcessorArchitecture.
        #
        # .OUTPUTS
        # System.Boolean. Get-WindowsProcessProcessorArchitecture returns a
        # boolean value indiciating whether the process processor architecture
        # was retrieved successfully. $true means the process processor
        # architecture was retrieved successfully; $false means there was an
        # error.
        #
        # .NOTES
        # This function also supports the use of a positional parameter instead
        # of a named parameter. If a positional parameter is used instead of a
        # named parameter, then exactly one positional parameter is required: a
        # reference to a string that will be used to store output if the
        # function completes successfully. The string will be set to the
        # processor architecture (instruction set) of the currently running
        # process.
        #
        # Version: 1.0.20250406.1

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

        #region Acknowledgements ###########################################
        # Microsoft, for providing a current reference on the SYSTEM_INFO
        # struct, used by the GetSystemInfo Win32 function. This reference does
        # not show the exact text of the PROCESSOR_ARCHITECTURE environment
        # variable, but shows the universe of what's possible on a core system
        # API:
        # https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info#members
        #
        # Microsoft, for including in the MSDN Library Jan 2003 information on
        # this same SYSTEM_INFO struct that pre-dates Windows 2000 and
        # enumerates additional processor architectures (MIPS, ALPHA, PowerPC,
        # IA32_ON_WIN64). The MSDN Library Jan 2003 also lists SHX and ARM,
        # explains nuiances in accessing environment variables on pre-Windows
        # 2000 operating systems (namely that VBScript in Windows 9x can only
        # access per-process environment variables), and that the
        # PROCESSOR_ARCHITECTURE system environment variable is not available
        # on Windows 98/ME.
        # (link unavailable, check Internet Archive for source)
        #
        # "guga" for the first post in this thread that tipped me off to the
        # SYSTEM_INFO struct and additional architectures:
        # http://masm32.com/board/index.php?topic=3401.0
        #endregion Acknowledgements ###########################################

        param (
            [ref]$ReferenceToProcessProcessorArchitecture = ([ref]$null)
        )

        if ($null -ne $env:PROCESSOR_ARCHITECTURE) {
            $ReferenceToProcessProcessorArchitecture.Value = $env:PROCESSOR_ARCHITECTURE
            return $true
        } else {
            return $false
        }
    }

    function Test-ProcessorArchitectureIs32Bit {
        # .SYNOPSIS
        # Tests a string that contains the processor architecture to determine
        # if it is 32-bit.
        #
        # .DESCRIPTION
        # This function tests a string that contains the processor architecture
        # to determine if it is 32-bit. It updates a reference to a boolean
        # that indicates whether the processor architecture is 32-bit. It
        # returns an integer indicating whether the process completed
        # successfully. 0 means the process completed successfully; any other
        # value means there was an error.
        #
        # .PARAMETER ReferenceToProcessorArchitectureIs32Bit
        # This parameter is required; it is a reference to a boolean that will
        # be used to store whether or not the processor architecture is 32-bit.
        # This parameter is passed by reference, so the value of the boolean
        # will be updated in the calling function. The value of this parameter
        # is set to $true if the processor architecture is 32-bit; otherwise,
        # it is set to $false.
        #
        # .PARAMETER ProcessorArchitecture
        # This parameter is required; it is a string representing the processor
        # architecture to be evaluated (e.g., "ARM64", "x86", "AMD64").
        #
        # .EXAMPLE
        # $bool32BitProcessorArchitecture = $false
        # $strProcessorArchitecture = $env:PROCESSOR_ARCHITECTURE
        # $intReturnCode = Test-ProcessorArchitectureIs32Bit -ReferenceToProcessorArchitectureIs32Bit ([ref]$bool32BitProcessorArchitecture) -ProcessorArchitecture $strProcessorArchitecture
        # if ($intReturnCode -eq 0) {
        #     if ($bool32BitProcessorArchitecture) {
        #         Write-Host "The processor architecture is 32-bit."
        #     } else {
        #         Write-Host "The processor architecture is not 32-bit."
        #     }
        # } else {
        #     Write-Host "An error occurred while testing the processor architecture."
        # }
        #
        # .EXAMPLE
        # $bool32BitProcessorArchitecture = $false
        # $strProcessorArchitecture = $env:PROCESSOR_ARCHITECTURE
        # $intReturnCode = Test-ProcessorArchitectureIs32Bit ([ref]$bool32BitProcessorArchitecture) $strProcessorArchitecture
        # if ($intReturnCode -eq 0) {
        #     if ($bool32BitProcessorArchitecture) {
        #         Write-Host "The processor architecture is 32-bit."
        #     } else {
        #         Write-Host "The processor architecture is not 32-bit."
        #     }
        # } else {
        #     Write-Host "An error occurred while testing the processor architecture."
        # }
        #
        # .INPUTS
        # None. You can't pipe objects to Test-ProcessorArchitectureIs32Bit.
        #
        # .OUTPUTS
        # System.Int32. Test-ProcessorArchitectureIs32Bit returns an integer
        # value indiciating whether the process completed successfully. 0 means
        # the processor architecture was evaluated successfully; any other
        # number indicates an error occurred.
        #
        # .NOTES
        # This function also supports the use of positional parameters instead
        # of named parameters. If positional parameters are used instead of
        # named parameters, then two positional parameters are required:
        #
        # The first positional parameter is a reference to a boolean that will
        # be used to store whether or not the processor architecture is 32-bit.
        # This parameter is passed by reference, so the value of the boolean
        # will be updated in the calling function. The value of this parameter
        # is set to $true if the processor architecture is 32-bit; otherwise,
        # it is set to $false.
        #
        # The second positional parameter is a string representing the
        # processor architecture to be evaluated (e.g., "ARM64", "x86",
        # "AMD64").
        #
        # Version: 1.0.20250406.1

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

        #region Acknowledgements ###########################################
        # Microsoft, for providing a current reference on the SYSTEM_INFO
        # struct, used by the GetSystemInfo Win32 function. This reference does
        # not show the exact text of the PROCESSOR_ARCHITECTURE environment
        # variable, but shows the universe of what's possible on a core system
        # API:
        # https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info#members
        #
        # Microsoft, for including in the MSDN Library Jan 2003 information on
        # this same SYSTEM_INFO struct that pre-dates Windows 2000 and
        # enumerates additional processor architectures (MIPS, ALPHA, PowerPC,
        # IA32_ON_WIN64). The MSDN Library Jan 2003 also lists SHX and ARM,
        # explains nuiances in accessing environment variables on pre-Windows
        # 2000 operating systems (namely that VBScript in Windows 9x can only
        # access per-process environment variables), and that the
        # PROCESSOR_ARCHITECTURE system environment variable is not available
        # on Windows 98/ME.
        # (link unavailable, check Internet Archive for source)
        #
        # "guga" for the first post in this thread that tipped me off to the
        # SYSTEM_INFO struct and additional architectures:
        # http://masm32.com/board/index.php?topic=3401.0
        #endregion Acknowledgements ###########################################

        param (
            [ref]$ReferenceToProcessorArchitectureIs32Bit = ([ref]$null),
            [string]$ProcessorArchitecture = ''
        )

        if ([string]::IsNullOrEmpty($ProcessorArchitecture)) {
            return -1
        }

        switch ($ProcessorArchitecture.ToUpper()) {
            'X86' {
                $ReferenceToProcessorArchitectureIs32Bit.Value = $true
                return 0
            }
            'AMD64' {
                $ReferenceToProcessorArchitectureIs32Bit.Value = $false
                return 0
            }
            'IA64' {
                $ReferenceToProcessorArchitectureIs32Bit.Value = $false
                return 0
            }
            'ARM' {
                $ReferenceToProcessorArchitectureIs32Bit.Value = $true
                return 0
            }
            'ARM64' {
                $ReferenceToProcessorArchitectureIs32Bit.Value = $false
                return 0
            }
            default {
                return -2
            }
        }
    }

    function Test-ProcessorArchitectureIs64Bit {
        # .SYNOPSIS
        # Tests a string that contains the processor architecture to determine
        # if it is 64-bit.
        #
        # .DESCRIPTION
        # This function tests a string that contains the processor architecture
        # to determine if it is 64-bit. It updates a reference to a boolean
        # that indicates whether the processor architecture is 64-bit. It
        # returns an integer indicating whether the process completed
        # successfully. 0 means the process completed successfully; any other
        # value means there was an error.
        #
        # .PARAMETER ReferenceToProcessorArchitectureIs64Bit
        # This parameter is required; it is a reference to a boolean that will
        # be used to store whether or not the processor architecture is 64-bit.
        # This parameter is passed by reference, so the value of the boolean
        # will be updated in the calling function. The value of this parameter
        # is set to $true if the processor architecture is 64-bit; otherwise,
        # it is set to $false.
        #
        # .PARAMETER ProcessorArchitecture
        # This parameter is required; it is a string representing the processor
        # architecture to be evaluated (e.g., "ARM64", "x86", "AMD64").
        #
        # .EXAMPLE
        # $bool64BitProcessorArchitecture = $false
        # $strProcessorArchitecture = $env:PROCESSOR_ARCHITECTURE
        # $intReturnCode = Test-ProcessorArchitectureIs64Bit -ReferenceToProcessorArchitectureIs64Bit ([ref]$bool64BitProcessorArchitecture) -ProcessorArchitecture $strProcessorArchitecture
        # if ($intReturnCode -eq 0) {
        #     if ($bool64BitProcessorArchitecture) {
        #         Write-Host "The processor architecture is 64-bit."
        #     } else {
        #         Write-Host "The processor architecture is not 64-bit."
        #     }
        # } else {
        #     Write-Host "An error occurred while testing the processor architecture."
        # }
        #
        # .EXAMPLE
        # $bool64BitProcessorArchitecture = $false
        # $strProcessorArchitecture = $env:PROCESSOR_ARCHITECTURE
        # $intReturnCode = Test-ProcessorArchitectureIs64Bit ([ref]$bool64BitProcessorArchitecture) $strProcessorArchitecture
        # if ($intReturnCode -eq 0) {
        #     if ($bool64BitProcessorArchitecture) {
        #         Write-Host "The processor architecture is 64-bit."
        #     } else {
        #         Write-Host "The processor architecture is not 64-bit."
        #     }
        # } else {
        #     Write-Host "An error occurred while testing the processor architecture."
        # }
        #
        # .INPUTS
        # None. You can't pipe objects to Test-ProcessorArchitectureIs64Bit.
        #
        # .OUTPUTS
        # System.Int32. Test-ProcessorArchitectureIs64Bit returns an integer
        # value indiciating whether the process completed successfully. 0 means
        # the processor architecture was evaluated successfully; any other
        # number indicates an error occurred.
        #
        # .NOTES
        # This function also supports the use of positional parameters instead
        # of named parameters. If positional parameters are used instead of
        # named parameters, then two positional parameters are required:
        #
        # The first positional parameter is a reference to a boolean that will
        # be used to store whether or not the processor architecture is 64-bit.
        # This parameter is passed by reference, so the value of the boolean
        # will be updated in the calling function. The value of this parameter
        # is set to $true if the processor architecture is 64-bit; otherwise,
        # it is set to $false.
        #
        # The second positional parameter is a string representing the
        # processor architecture to be evaluated (e.g., "ARM64", "x86",
        # "AMD64").
        #
        # Version: 1.0.20250406.1

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

        #region Acknowledgements ###########################################
        # Microsoft, for providing a current reference on the SYSTEM_INFO
        # struct, used by the GetSystemInfo Win32 function. This reference does
        # not show the exact text of the PROCESSOR_ARCHITECTURE environment
        # variable, but shows the universe of what's possible on a core system
        # API:
        # https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info#members
        #
        # Microsoft, for including in the MSDN Library Jan 2003 information on
        # this same SYSTEM_INFO struct that pre-dates Windows 2000 and
        # enumerates additional processor architectures (MIPS, ALPHA, PowerPC,
        # IA32_ON_WIN64). The MSDN Library Jan 2003 also lists SHX and ARM,
        # explains nuiances in accessing environment variables on pre-Windows
        # 2000 operating systems (namely that VBScript in Windows 9x can only
        # access per-process environment variables), and that the
        # PROCESSOR_ARCHITECTURE system environment variable is not available
        # on Windows 98/ME.
        # (link unavailable, check Internet Archive for source)
        #
        # "guga" for the first post in this thread that tipped me off to the
        # SYSTEM_INFO struct and additional architectures:
        # http://masm32.com/board/index.php?topic=3401.0
        #endregion Acknowledgements ###########################################

        param (
            [ref]$ReferenceToProcessorArchitectureIs64Bit = ([ref]$null),
            [string]$ProcessorArchitecture = ''
        )

        if ([string]::IsNullOrEmpty($ProcessorArchitecture)) {
            return -1
        }

        switch ($ProcessorArchitecture.ToUpper()) {
            'X86' {
                $ReferenceToProcessorArchitectureIs64Bit.Value = $false
                return 0
            }
            'AMD64' {
                $ReferenceToProcessorArchitectureIs64Bit.Value = $true
                return 0
            }
            'IA64' {
                $ReferenceToProcessorArchitectureIs64Bit.Value = $true
                return 0
            }
            'ARM' {
                $ReferenceToProcessorArchitectureIs64Bit.Value = $false
                return 0
            }
            'ARM64' {
                $ReferenceToProcessorArchitectureIs64Bit.Value = $true
                return 0
            }
            default {
                return -2
            }
        }
    }

    if ([string]::IsNullOrEmpty($OSProcessorArchitecture)) {
        $strOSProcessorArchitecture = ''
        $boolSuccess = Get-WindowsOSProcessorArchitecture -ReferenceToOSProcessorArchitecture ([ref]$strOSProcessorArchitecture)
        if (-not $boolSuccess) {
            return -1
        }
        $refOSProcessorArchitecture = [ref]$strOSProcessorArchitecture
    } else {
        $refOSProcessorArchitecture = [ref]$OSProcessorArchitecture
    }

    if ([string]::IsNullOrEmpty($ProcessProcessorArchitecture)) {
        $strProcessProcessorArchitecture = ''
        $boolSuccess = Get-WindowsProcessProcessorArchitecture -ReferenceToProcessProcessorArchitecture ([ref]$strProcessProcessorArchitecture)
        if (-not $boolSuccess) {
            return -2
        }
        $refProcessProcessorArchitecture = [ref]$strProcessProcessorArchitecture
    } else {
        $refProcessProcessorArchitecture = [ref]$ProcessProcessorArchitecture
    }

    #region Determine OS bit width #########################################
    $bool64BitOSProcessorArchitecture = $false
    $intReturnCode = Test-ProcessorArchitectureIs64Bit -ReferenceToProcessorArchitectureIs64Bit ([ref]$bool64BitOSProcessorArchitecture) -ProcessorArchitecture ($refOSProcessorArchitecture.Value)
    if ($intReturnCode -ne 0) {
        return -3
    }

    $bool32BitOSProcessorArchitecture = $false
    if (-not $bool64BitOSProcessorArchitecture) {
        $intReturnCode = Test-ProcessorArchitectureIs32Bit -ReferenceToProcessorArchitectureIs32Bit ([ref]$bool32BitOSProcessorArchitecture) -ProcessorArchitecture ($refOSProcessorArchitecture.Value)
        if ($intReturnCode -ne 0) {
            return -4
        }
    }

    if ((-not $bool64BitOSProcessorArchitecture) -and (-not $bool32BitOSProcessorArchitecture)) {
        # OS is both not 32-bit and not 64-bit--wut?
        return -5
    }
    #endregion Determine OS bit width #########################################

    #region Determine process bit width ####################################
    $bool64BitProcessProcessorArchitecture = $false
    $intReturnCode = Test-ProcessorArchitectureIs64Bit -ReferenceToProcessorArchitectureIs64Bit ([ref]$bool64BitProcessProcessorArchitecture) -ProcessorArchitecture ($refProcessProcessorArchitecture.Value)
    if ($intReturnCode -ne 0) {
        return -6
    }

    $bool32BitProcessProcessorArchitecture = $false
    if (-not $bool64BitProcessProcessorArchitecture) {
        $intReturnCode = Test-ProcessorArchitectureIs32Bit -ReferenceToProcessorArchitectureIs32Bit ([ref]$bool32BitProcessProcessorArchitecture) -ProcessorArchitecture ($refProcessProcessorArchitecture.Value)
        if ($intReturnCode -ne 0) {
            return -7
        }
    }

    if ((-not $bool64BitProcessProcessorArchitecture) -and (-not $bool32BitProcessProcessorArchitecture)) {
        # Process is both not 32-bit and not 64-bit--wut?
        return -8
    }
    #endregion Determine process bit width ####################################

    if ($bool64BitOSProcessorArchitecture -and $bool32BitProcessProcessorArchitecture) {
        # 32-bit process on 64-bit OS
        # Need to get and return sysnative folder
        if (-not [string]::IsNullOrEmpty($env:SystemRoot)) {
            $strWindowsPath = $env:SystemRoot
        } elseif (-not [string]::IsNullOrEmpty($env:windir)) {
            $strWindowsPath = $env:windir
        } elseif (-not [string]::IsNullOrEmpty([System.Environment]::GetFolderPath('Windows'))) {
            $strWindowsPath = [System.Environment]::GetFolderPath('Windows')
        } else {
            return -9
        }

        $strSysnativePath = Join-Path -Path $strWindowsPath -ChildPath 'Sysnative'
        if (-not (Test-Path -LiteralPath $strSysnativePath)) {
            # The C:\Windows\Sysnative path did not exist. This could happen on
            # Windows XP or Windows Server 2003 systems that are missing
            # KB942615
            return -10
        }

        $ReferenceToSystemPath.Value = $strSysnativePath
        return 0
    } else {
        # Either 32-bit process on 32-bit OS, or 64-bit process on 64-bit OS
        # Need to get and return the system32 folder

        if (-not [string]::IsNullOrEmpty([System.Environment]::SystemDirectory)) {
            $strWindowsSystemPath = [System.Environment]::SystemDirectory
        } elseif (-not [string]::IsNullOrEmpty($env:windir)) {
            $strWindowsSystemPath = Join-Path -Path $env:windir -ChildPath 'System32'
        } elseif (-not [string]::IsNullOrEmpty($env:SystemRoot)) {
            $strWindowsSystemPath = Join-Path -Path $env:SystemRoot -ChildPath 'System32'
        } else {
            return -11
        }

        if (-not (Test-Path -LiteralPath $strWindowsSystemPath)) {
            # The C:\Windows\System32 path did not exist.
            return -12
        }

        $ReferenceToSystemPath.Value = [System.Environment]::SystemDirectory
        return 0
    }
}
