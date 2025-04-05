function Test-RegistryValue {
    # .SYNOPSIS
    # Tests to determine whether a registry value exists in the Windows
    # registry.
    #
    # .DESCRIPTION
    # This function tests to determine whether a registry value exists in the
    # Windows registry. It returns a boolean value indicating whether the
    # registry value exists. $true indicates the registry value exists; $false
    # indicates the registry value does not exist.
    #
    # .PARAMETER RefPathToRegistryKey
    # Either this parameter or PathToRegistryKey are required; if
    # RefPathToRegistryKey is specified, it is a reference to a string that
    # contains the path to the registry key. If this parameter is not
    # specified, then PathToRegistryKey must be specified. If both are
    # specified, then RefPathToRegistryKey takes precedence over
    # PathToRegistryKey.
    #
    # .PARAMETER PathToRegistryKey
    # Either this parameter or RefPathToRegistryKey are required; if
    # PathToRegistryKey is specified, it is a string that contains the path to
    # the registry key. If this parameter is not specified, then
    # RefPathToRegistryKey must be specified. If both are specified, then
    # RefPathToRegistryKey takes precedence over PathToRegistryKey.
    #
    # .PARAMETER RefNameOfRegistryValue
    # Either this parameter or NameOfRegistryValue are required; if
    # RefNameOfRegistryValue is specified, it is a reference to a string that
    # contains the name of the registry value to be tested. If this parameter
    # is not specified, then NameOfRegistryValue must be specified. If both are
    # specified, then RefNameOfRegistryValue takes precedence over
    # NameOfRegistryValue.
    #
    # .PARAMETER NameOfRegistryValue
    # Either this parameter or RefNameOfRegistryValue are required; if
    # NameOfRegistryValue is specified, it is a string that contains the name
    # of the registry value to be tested. If this parameter is not specified,
    # then RefNameOfRegistryValue must be specified. If both are specified,
    # then RefNameOfRegistryValue takes precedence over NameOfRegistryValue.
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
    # System.Boolean. Test-RegistryValue returns a boolean value indiciating
    # whether the registry value exists. $true indicates the registry value
    # exists; $false indicates the registry value does not exist, or that the
    # specified registry key does not exist.
    #
    # .NOTES
    # Oddly enough, it seems that passing string parameters by reference is not
    # faster than passing them by value. I thought that passing by reference
    # would be faster, but it seems that passing by value is faster. I don't
    # know why this is the case, but it is.
    #
    # Version: 1.0.20250405.0

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
        [ref]$RefPathToRegistryKey = ([ref]$null),
        [string]$PathToRegistryKey = '',
        [ref]$RefNameOfRegistryValue = ([ref]$null),
        [string]$NameOfRegistryValue = ''
    )

    if ([string]::IsNullOrEmpty($RefPathToRegistryKey.Value) -and [string]::IsNullOrEmpty($PathToRegistryKey)) {
        Write-Error -Message 'Either RefPathToRegistryKey or PathToRegistryKey must be specified.'
        return $false
    }

    # Specifying an empty string for the name of the registry value is valid;
    # it would mean the "default" value of the registry key.
    # However, if both RefNameOfRegistryValue and NameOfRegistryValue are
    # empty, then we have a problem.
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
