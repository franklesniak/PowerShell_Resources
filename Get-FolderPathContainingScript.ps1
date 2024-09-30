function Get-FolderPathContainingScript {
    # Returns the path to the folder containing the running script. If no script is
    # running, the function returns the current path
    #
    # Example:
    # Get-FolderPathContainingScript
    #
    # This example returns the folder that contains the currently running script. Or,
    # if no script is running, the function returns the current folder
    #
    # The function outputs a [string] object representing the path to the folder
    #
    # PowerShell v1 - v2 do not have a $PSScriptRoot variable, so this function uses
    # other methods to determine the script directory
    #
    # Version 1.0.20240930.1

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

    function Get-PSVersion {
        # Returns the version of PowerShell that is running, including on the original
        # release of Windows PowerShell (version 1.0)
        #
        # Example:
        # Get-PSVersion
        #
        # This example returns the version of PowerShell that is running. On versions
        # of PowerShell greater than or equal to version 2.0, this function returns the
        # equivalent of $PSVersionTable.PSVersion
        #
        # The function outputs a [version] object representing the version of
        # PowerShell that is running
        #
        # PowerShell 1.0 does not have a $PSVersionTable variable, so this function
        # returns [version]('1.0') on PowerShell 1.0
        #
        # Version 1.0.20240917.0

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

        if (Test-Path variable:\PSVersionTable) {
            return ($PSVersionTable.PSVersion)
        } else {
            return ([version]('1.0'))
        }
    }

    $strFolderPathContainingScript = ''
    if (Test-Path variable:\PSScriptRoot) {
        # $PSScriptRoot exists
        if (-not [string]::IsNullOrEmpty($PSScriptRoot)) {
            $strFolderPathContainingScript = $PSScriptRoot
        }
    }

    if ([string]::IsNullOrEmpty($strFolderPathContainingScript)) {
        # $PSScriptRoot does not exist or is empty
        # Either PowerShell v1 or v2 is running, or there may not be a script running

        $strScriptPath = ''
        if (Test-Path variable:\hostinvocation) {
            $strScriptPath = $hostinvocation.MyCommand.Path
        } elseif (Test-Path variable:script:MyInvocation) {
            $strScriptPath = (Get-Variable MyInvocation -Scope Script).Value.MyCommand.Definition
        }

        if (-not [string]::IsNullOrEmpty($strScriptPath)) {
            if (Test-Path $strScriptPath) {
                $strFolderPathContainingScript = (Split-Path $strScriptPath)
            }
        }

        if ([string]::IsNullOrEmpty($strFolderPathContainingScript)) {
            $strFolderPathContainingScript = (Get-Location).Path
            if ($Host.Name -eq 'ConsoleHost' -or $Host.Name -eq 'ServerRemoteHost' -or $Host.Name -eq 'Windows PowerShell ISE Host' -or $Host.Name -eq 'Visual Studio Code Host') {
                $versionPS = Get-PSVersion
                $strMessage = 'Get-FolderPathContainingScript: There does not appear to be a script running; the current directory <' + $strFolderPathContainingScript + '> will be used.'
                if ($versionPS.Major -ge 5) {
                    Write-Information $strMessage
                } else {
                    Write-Host $strMessage
                }
            } else {
                Write-Warning ('Get-FolderPathContainingScript: Powershell Host <' + $Host.Name + '> may not be compatible with this function, the current directory <' + $strFolderPathContainingScript + '> will be used.')
            }
        }
    }

    return $strFolderPathContainingScript
}
