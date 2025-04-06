function Test-ProcessorArchitectureIs64Bit {
    # .SYNOPSIS
    # Tests a string that contains the processor architecture to determine if it is
    # 64-bit.
    #
    # .DESCRIPTION
    # This function tests a string that contains the processor architecture to
    # determine if it is 64-bit. It updates a reference to a boolean that
    # indicates whether the processor architecture is 64-bit. It returns an integer
    # indicating whether the process completed successfully. 0 means the process
    # completed successfully; any other value means there was an error.
    #
    # .PARAMETER ReferenceToProcessorArchitectureIs64Bit
    # This parameter is required; it is a reference to a boolean that will be used
    # to store whether or not the processor architecture is 64-bit. This parameter
    # is passed by reference, so the value of the boolean will be updated in the
    # calling function. The value of this parameter is set to $true if the
    # processor architecture is 64-bit; otherwise, it is set to $false.
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
    # System.Int64. Test-ProcessorArchitectureIs64Bit returns an integer value
    # indiciating whether the process completed successfully. 0 means the processor
    # architecture was evaluated successfully; any other number indicates an error
    # occurred.
    #
    # .NOTES
    # This function also supports the use of positional parameters instead of named
    # parameters. If positional parameters are used instead of named parameters,
    # then two positional parameters are required:
    #
    # The first positional parameter is a reference to a boolean that will be used
    # to store whether or not the processor architecture is 64-bit. This parameter
    # is passed by reference, so the value of the boolean will be updated in the
    # calling function. The value of this parameter is set to $true if the
    # processor architecture is 64-bit; otherwise, it is set to $false.
    #
    # The second positional parameter is a string representing the processor
    # architecture to be evaluated (e.g., "ARM64", "x86", "AMD64").
    #
    # Version: 1.0.20250405.0

    #region License ############################################################
    # Copyright (c) 2025 Frank Lesniak
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
    # Microsoft, for providing a current reference on the SYSTEM_INFO struct, used
    # by the GetSystemInfo Win32 function. This reference does not show the exact
    # text of the PROCESSOR_ARCHITECTURE environment variable, but shows the
    # universe of what's possible on a core system API:
    # https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info#members
    #
    # Microsoft, for including in the MSDN Library Jan 2003 information on this
    # same SYSTEM_INFO struct that pre-dates Windows 2000 and enumerates additional
    # processor architectures (MIPS, ALPHA, PowerPC, IA32_ON_WIN64). The MSDN
    # Library Jan 2003 also lists SHX and ARM, explains nuiances in accessing
    # environment variables on pre-Windows 2000 operating systems (namely that
    # VBScript in Windows 9x can only access per-process environment variables),
    # and that the PROCESSOR_ARCHITECTURE system environment variable is not
    # available on Windows 98/ME.
    # (link unavailable, check Internet Archive for source)
    #
    # "guga" for the first post in this thread that tipped me off to the
    # SYSTEM_INFO struct and additional architectures:
    # http://masm32.com/board/index.php?topic=3401.0
    #endregion Acknowledgements ###################################################

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
