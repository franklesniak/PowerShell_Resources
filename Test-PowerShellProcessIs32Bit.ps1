function Test-PowerShellProcessIs32Bit {
    # Returns $true if the PowerShell process is 32-bit, $false otherwise
    # Works on Windows PowerShell v1.0 through the newest versions of PowerShell
    #
    # The function returns a boolean value indicating whether the current
    # PowerShell process is 32-bit or 64-bit. This function works on all versions
    # of PowerShell, including PowerShell 1.0, 2.0, 3.0, 4.0, 5.0, 5.1, 6.0,
    # 7.0, and 7.1. The function works on both Windows PowerShell and PowerShell
    # Core.
    #
    # Example:
    # $boolIs32Bit = Test-PowerShellProcessIs32Bit
    # if ($boolIs32Bit) {
    #     Write-Host "This PowerShell process is 32-bit"
    # } else {
    #     Write-Host "This PowerShell process is 64-bit"
    # }
    #
    # This example will output "This PowerShell process is 32-bit" if the
    # PowerShell process is 32-bit, and "This PowerShell process is 64-bit" if
    # the PowerShell process is 64-bit
    #
    # Version 1.0.20240826.0
    #
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
    # GitHub repository at https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice #############################################

    if ([System.IntPtr]::Size -eq 4) {
        return $true
    } else {
        return $false
    }
}
