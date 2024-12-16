function Wait-PathToBeNotReady {
    <#
    .SYNOPSIS
    Waits for the specified path to be unavailable. Also tests that a Join-Path
    operation can be performed on the specified path and a child item

    .DESCRIPTION
    This function waits for the specified path to be unavailable. It also tests that a
    Join-Path operation can be performed on the specified path and a child item

    .PARAMETER ReferenceToUseGetPSDriveWorkaround
    This parameter is a memory reference to a boolean variable that indicates whether
    or not the Get-PSDrive workaround should be used. If the Get-PSDrive workaround is
    used, then the function will use the Get-PSDrive cmdlet to refresh PowerShell's
    "understanding" of the available drive letters. This variable is passed by
    reference to ensure that this function can set the variable to $true if the
    Get-PSDrive workaround is successful - which improves performance of subsequent
    runs.

    .PARAMETER Path
    This parameter is the path to be tested for availability, and the parent path to
    be used in the join-path operation. If no child path is specified, then the
    this path will populated into the variable referenced in the parameter
    ReferenceToJoinedPath

    .PARAMETER MaximumWaitTimeInSeconds
    This parameter is the maximum amount of seconds to wait for the path to be ready.
    If the path is not ready within this time, then the function will return $false.
    By default, this parameter is set to 10 seconds.

    .PARAMETER DoNotAttemptGetPSDriveWorkaround
    This parameter is a switch that indicates whether or not the Get-PSDrive
    workaround should be attempted. If this switch is specified, then the Get-PSDrive
    workaround will not be attempted. This switch is useful if you know that the
    Get-PSDrive workaround will not work on your system, or if you know that the
    Get-PSDrive workaround is not necessary on your system.

    .EXAMPLE
    $boolUseGetPSDriveWorkaround = $false
    $boolPathUnavailable = Wait-PathToBeNotReady -Path 'D:\Shares\Share\Data' -ReferenceToUseGetPSDriveWorkaround ([ref]$boolUseGetPSDriveWorkaround)

    .OUTPUTS
    A boolean value indiciating whether the path is unavailable
    #>

    [CmdletBinding()]
    [OutputType([System.Boolean])]

    param (
        [Parameter(Mandatory = $false)][System.Management.Automation.PSReference]$ReferenceToUseGetPSDriveWorkaround = ([ref]$null),
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $false)][int]$MaximumWaitTimeInSeconds = 10,
        [Parameter(Mandatory = $false)][switch]$DoNotAttemptGetPSDriveWorkaround
    )

    #region License ################################################################
    # Copyright (c) 2023 Frank Lesniak
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy of
    # this software and associated documentation files (the "Software"), to deal in the
    # Software without restriction, including without limitation the rights to use,
    # copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
    # Software, and to permit persons to whom the Software is furnished to do so,
    # subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all
    # copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    # FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    # COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
    # AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #endregion License ################################################################

    $versionThisFunction = [version]('1.0.20231111.0')

    #region Process Input ##########################################################
    if ($DoNotAttemptGetPSDriveWorkaround.IsPresent -eq $true) {
        $boolAttemptGetPSDriveWorkaround = $false
    } else {
        $boolAttemptGetPSDriveWorkaround = $true
    }
    #endregion Process Input ##########################################################

    $boolFunctionReturn = $false

    if ($null -ne ($ReferenceToUseGetPSDriveWorkaround.Value)) {
        if (($ReferenceToUseGetPSDriveWorkaround.Value) -eq $true) {
            # Use workaround for drives not refreshing in current PowerShell session
            Get-PSDrive | Out-Null
        }
    }

    $doubleSecondsCounter = 0

    # Try Join-Path and sleep for up to $MaximumWaitTimeInSeconds seconds until it's successful
    while ($doubleSecondsCounter -le $MaximumWaitTimeInSeconds -and $boolFunctionReturn -eq $false) {
        if (Test-Path $Path) {
            Start-Sleep 0.2
            $doubleSecondsCounter += 0.2
        } else {
            $boolFunctionReturn = $true
        }
    }

    if ($boolFunctionReturn -eq $false) {
        if ($null -eq ($ReferenceToUseGetPSDriveWorkaround.Value) -or ($ReferenceToUseGetPSDriveWorkaround.Value) -eq $false) {
            # Either a variable was not passed in, or the variable was passed in and it was set to false
            if ($boolAttemptGetPSDriveWorkaround -eq $true) {
                # Try workaround for drives not refreshing in current PowerShell session
                Get-PSDrive | Out-Null

                # Restart counter and try waiting again
                $doubleSecondsCounter = 0

                # Try Join-Path and sleep for up to $MaximumWaitTimeInSeconds seconds until it's successful
                while ($doubleSecondsCounter -le $MaximumWaitTimeInSeconds -and $boolFunctionReturn -eq $false) {
                    if (Test-Path $Path) {
                        Start-Sleep 0.2
                        $doubleSecondsCounter += 0.2
                    } else {
                        $boolFunctionReturn = $true
                    }
                }
            }
        }
    }

    return $boolFunctionReturn
}
