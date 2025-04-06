function Get-WindowsProcessProcessorArchitecture {
    # .SYNOPSIS
    # Gets the processor architecture of the current process, assuming the current
    # process is running on Windows.
    #
    # .DESCRIPTION
    # This function determines the processor architecture (instruction set) of the
    # current process, assuming it is running on Windows. It reads this value from
    # the environment variables and returns it via a referenced string object. The
    # processor architecture is the instruction set that the process is using to
    # run. On Windows versions that support PowerShell, known values are:
    #
    # - x86 (i.e., 32-bit x86)
    # - AMD64 (i.e., x86-64 or 64-bit x86)
    # - ARM (i.e., 32-bit ARM)
    # - ARM64 (i.e., 64-bit ARM)
    # - IA64 (i.e., Itanium)
    #
    # .PARAMETER ReferenceToProcessProcessorArchitecture
    # This parameter is required; it is a reference to a string that will be
    # used to store output if the function completes successfully. The string
    # will be set to the processor architecture (instruction set) of the
    # currently running process.
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
    # None. You can't pipe objects to Get-WindowsProcessProcessorArchitecture.
    #
    # .OUTPUTS
    # System.Boolean. Get-WindowsProcessProcessorArchitecture returns a boolean
    # value indiciating whether the process processor architecture was retrieved
    # successfully. $true means the process processor architecture was retrieved
    # successfully; $false means there was an error.
    #
    # .NOTES
    # This function also supports the use of a positional parameter instead of a
    # named parameter. If a positional parameter is used instead of a named
    # parameter, then exactly one positional parameter is required: a reference to
    # a string that will be used to store output if the function completes
    # successfully. The string will be set to the processor architecture
    # (instruction set) of the currently running process.
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
