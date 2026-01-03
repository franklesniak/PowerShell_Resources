function Test-PowerShellModuleInstalledUsingHashtable {
    # .SYNOPSIS
    # Tests to see if a PowerShell module is installed based on entries in a
    # hashtable. If the PowerShell module is not installed, an error or warning
    # message may optionally be displayed.
    #
    # .DESCRIPTION
    # The Test-PowerShellModuleInstalledUsingHashtable function steps through each
    # entry in the supplied hashtable and, if there are any modules not installed,
    # it optionally throws an error or warning for each module that is not
    # installed. If all modules are installed, the function returns $true;
    # otherwise, if any module is not installed, the function returns $false.
    #
    # .PARAMETER HashtableOfInstalledModules
    # This parameter is required; it is a hashtable. The hashtable must have keys
    # that are the names of PowerShell modules with each hashtable entry's value
    # (in the key-value pair) populated with arrays of ModuleInfoGrouping objects
    # (i.e., the object returned from Get-Module).
    #
    # .PARAMETER HashtableOfCustomNotInstalledMessages
    # This parameter is optional; if supplied, it is a hashtable. The hashtable
    # must have keys that are custom error or warning messages (string) to be
    # displayed if one or more modules are not installed. The value for each key
    # must be an array of PowerShell module names (strings) relevant to that error
    # or warning message.
    #
    # If this parameter is not supplied, or if a custom error or warning message is
    # not supplied in the hashtable for a given module, the script will default to
    # using the following message:
    #
    # <MODULENAME> module not found. Please install it and then try again.
    # You can install the <MODULENAME> PowerShell module from the PowerShell
    # Gallery by running the following command:
    # Install-Module <MODULENAME>;
    #
    # If the installation command fails, you may need to upgrade the version of
    # PowerShellGet. To do so, run the following commands, then restart PowerShell:
    # Set-ExecutionPolicy Bypass -Scope Process -Force;
    # [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    # Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;
    # Install-Module PowerShellGet -MinimumVersion 2.2.4 -SkipPublisherCheck -Force -AllowClobber;
    #
    # .PARAMETER ThrowErrorIfModuleNotInstalled
    # This parameter is optional; it is a switch parameter. If this parameter is
    # specified, an error is thrown for each module that is not installed. If this
    # parameter is not specified, no error is thrown.
    #
    # .PARAMETER ThrowWarningIfModuleNotInstalled
    # This parameter is optional; it is a switch parameter. If this parameter is
    # specified, a warning is thrown for each module that is not installed. If this
    # parameter is not specified, or if the ThrowErrorIfModuleNotInstalled
    # parameter was specified, no warning is thrown.
    #
    # .PARAMETER ReferenceToArrayOfMissingModules
    # This parameter is optional; if supplied, it is a reference to an array. The
    # array must be initialized to be empty. If any modules are not installed, the
    # names of those modules are added to the array.
    #
    # .EXAMPLE
    # $hashtableModuleNameToInstalledModules = @{}
    # $hashtableModuleNameToInstalledModules.Add('PnP.PowerShell', @())
    # $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Authentication', @())
    # $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Groups', @())
    # $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Users', @())
    # $refHashtableModuleNameToInstalledModules = [ref]$hashtableModuleNameToInstalledModules
    # $intReturnCode = Get-PowerShellModuleUsingHashtable -ReferenceToHashtable $refHashtableModuleNameToInstalledModules
    # if ($intReturnCode -ne 0) {
    #     Write-Error 'Failed to get the list of installed PowerShell modules.'
    #     return
    # }
    #
    # $hashtableCustomNotInstalledMessageToModuleNames = @{}
    # $strGraphNotInstalledMessage = 'Microsoft.Graph.Authentication, Microsoft.Graph.Groups, and/or Microsoft.Graph.Users modules were not found. Please install the full Microsoft.Graph module and then try again.' + [System.Environment]::NewLine + 'You can install the Microsoft.Graph PowerShell module from the PowerShell Gallery by running the following command:' + [System.Environment]::NewLine + 'Install-Module Microsoft.Graph;' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'If the installation command fails, you may need to upgrade the version of PowerShellGet. To do so, run the following commands, then restart PowerShell:' + [System.Environment]::NewLine + 'Set-ExecutionPolicy Bypass -Scope Process -Force;' + [System.Environment]::NewLine + '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;' + [System.Environment]::NewLine + 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;' + [System.Environment]::NewLine + 'Install-Module PowerShellGet -MinimumVersion 2.2.4 -SkipPublisherCheck -Force -AllowClobber;' + [System.Environment]::NewLine + [System.Environment]::NewLine
    # $hashtableCustomNotInstalledMessageToModuleNames.Add($strGraphNotInstalledMessage, @('Microsoft.Graph.Authentication', 'Microsoft.Graph.Groups', 'Microsoft.Graph.Users'))
    #
    # $boolResult = Test-PowerShellModuleInstalledUsingHashtable -HashtableOfInstalledModules $hashtableModuleNameToInstalledModules -HashtableOfCustomNotInstalledMessages $hashtableCustomNotInstalledMessageToModuleNames -ThrowErrorIfModuleNotInstalled
    # if ($boolResult -eq $false) {
    #     Write-Warning 'One or more required modules are not installed.'
    #     return
    # }
    #
    # This example checks to see if the PnP.PowerShell,
    # Microsoft.Graph.Authentication, Microsoft.Graph.Groups, and
    # Microsoft.Graph.Users modules are installed using named parameters. If any of
    # these modules are not installed, an error is thrown for the PnP.PowerShell
    # module or the group of Microsoft.Graph modules, respectively, and $boolResult
    # is set to $false. If all modules are installed, $boolResult is set to $true.
    # The function returns a boolean value indicating whether all modules are
    # installed.
    #
    # .EXAMPLE
    # $hashtableModuleNameToInstalledModules = @{}
    # $hashtableModuleNameToInstalledModules.Add('PnP.PowerShell', @())
    # $refHashtableModuleNameToInstalledModules = [ref]$hashtableModuleNameToInstalledModules
    # $intReturnCode = Get-PowerShellModuleUsingHashtable $refHashtableModuleNameToInstalledModules
    # if ($intReturnCode -ne 0) {
    #     Write-Error 'Failed to get the list of installed PowerShell modules.'
    #     return
    # }
    #
    # $boolResult = Test-PowerShellModuleInstalledUsingHashtable $hashtableModuleNameToInstalledModules $null $true
    # if ($boolResult -eq $false) {
    #     Write-Warning 'PnP.PowerShell module is not installed.'
    #     return
    # }
    #
    # This example demonstrates using positional parameters instead of named
    # parameters. The first positional parameter is the hashtable of installed
    # modules, the second is the hashtable of custom messages (null in this case),
    # and the third is the switch to throw an error if a module is not installed.
    # The function returns $true if the module is installed, $false otherwise.
    #
    # .INPUTS
    # None. You can't pipe objects to Test-PowerShellModuleInstalledUsingHashtable.
    #
    # .OUTPUTS
    # System.Boolean. Test-PowerShellModuleInstalledUsingHashtable returns a
    # boolean value indiciating whether all modules were installed. $true means
    # that every module specified in the hashtable (i.e., the one passed in the
    # HashtableOfInstalledModules parameter) was installed; $false means that at
    # least one module was not installed.
    #
    # .NOTES
    # Version: 3.0.20251231.1
    #
    # This function supports Windows PowerShell 1.0 with .NET Framework 2.0 or
    # newer, newer versions of Windows PowerShell (at least up to and including
    # Windows PowerShell 5.1 with .NET Framework 4.8 or newer), PowerShell Core
    # 6.x, and PowerShell 7.x. This function supports Windows and, when run on
    # PowerShell Core 6.x or PowerShell 7.x, also supports macOS and Linux.
    #
    # This function also supports the use of positional parameters instead of named
    # parameters. If positional parameters are used instead of named parameters,
    # then five positional parameters are supported in the following order:
    # 1. HashtableOfInstalledModules (required)
    # 2. HashtableOfCustomNotInstalledMessages (optional)
    # 3. ThrowErrorIfModuleNotInstalled (optional switch)
    # 4. ThrowWarningIfModuleNotInstalled (optional switch)
    # 5. ReferenceToArrayOfMissingModules (optional)

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
        [hashtable]$HashtableOfInstalledModules = $null,
        [hashtable]$HashtableOfCustomNotInstalledMessages = $null,
        [switch]$ThrowErrorIfModuleNotInstalled,
        [switch]$ThrowWarningIfModuleNotInstalled,
        [ref]$ReferenceToArrayOfMissingModules = ([ref]$null)
    )

    trap {
        # Intentionally left empty to prevent terminating errors from halting
        # processing
    }

    #region Process input ######################################################
    # Validate that the required parameter was supplied:
    if ($null -eq $HashtableOfInstalledModules) {
        $strMessage = 'The Test-PowerShellModuleInstalledUsingHashtable function requires a parameter (-HashtableOfInstalledModules), which must be a hashtable.'
        Write-Error -Message $strMessage
        return $false
    }
    if ($HashtableOfInstalledModules.GetType().FullName -ne 'System.Collections.Hashtable') {
        $strMessage = 'The Test-PowerShellModuleInstalledUsingHashtable function requires a parameter (-HashtableOfInstalledModules), which must be a hashtable.'
        Write-Error -Message $strMessage
        return $false
    }

    $boolThrowErrorForMissingModule = $false
    if ($null -ne $ThrowErrorIfModuleNotInstalled) {
        if ($ThrowErrorIfModuleNotInstalled.IsPresent) {
            $boolThrowErrorForMissingModule = $true
        }
    }
    $boolThrowWarningForMissingModule = $false
    if (-not $boolThrowErrorForMissingModule) {
        if ($null -ne $ThrowWarningIfModuleNotInstalled) {
            if ($ThrowWarningIfModuleNotInstalled.IsPresent) {
                $boolThrowWarningForMissingModule = $true
            }
        }
    }
    #endregion Process input ######################################################

    $boolResult = $true

    $hashtableMessagesToThrowForMissingModule = @{}
    $hashtableModuleNameToCustomMessageToThrowForMissingModule = @{}
    if ($null -ne $HashtableOfCustomNotInstalledMessages) {
        if ($HashtableOfCustomNotInstalledMessages.GetType().FullName -eq 'System.Collections.Hashtable') {
            $arrMessages = @($HashtableOfCustomNotInstalledMessages.Keys)
            foreach ($strMessage in $arrMessages) {
                $hashtableMessagesToThrowForMissingModule.Add($strMessage, $false)

                $HashtableOfCustomNotInstalledMessages.Item($strMessage) | ForEach-Object {
                    $hashtableModuleNameToCustomMessageToThrowForMissingModule.Add($_, $strMessage)
                }
            }
        }
    }

    $arrModuleNames = @($HashtableOfInstalledModules.Keys)
    foreach ($strModuleName in $arrModuleNames) {
        $arrInstalledModules = @($HashtableOfInstalledModules.Item($strModuleName))
        if ($arrInstalledModules.Count -eq 0) {
            $boolResult = $false

            if ($hashtableModuleNameToCustomMessageToThrowForMissingModule.ContainsKey($strModuleName) -eq $true) {
                $strMessage = $hashtableModuleNameToCustomMessageToThrowForMissingModule.Item($strModuleName)
                $hashtableMessagesToThrowForMissingModule.Item($strMessage) = $true
            } else {
                $strMessage = $strModuleName + ' module not found. Please install it and then try again.' + [System.Environment]::NewLine + 'You can install the ' + $strModuleName + ' PowerShell module from the PowerShell Gallery by running the following command:' + [System.Environment]::NewLine + 'Install-Module ' + $strModuleName + ';' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'If the installation command fails, you may need to upgrade the version of PowerShellGet. To do so, run the following commands, then restart PowerShell:' + [System.Environment]::NewLine + 'Set-ExecutionPolicy Bypass -Scope Process -Force;' + [System.Environment]::NewLine + '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;' + [System.Environment]::NewLine + 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;' + [System.Environment]::NewLine + 'Install-Module PowerShellGet -MinimumVersion 2.2.4 -SkipPublisherCheck -Force -AllowClobber;' + [System.Environment]::NewLine + [System.Environment]::NewLine
                $hashtableMessagesToThrowForMissingModule.Add($strMessage, $true)
            }

            if ($null -ne $ReferenceToArrayOfMissingModules) {
                if ($null -ne $ReferenceToArrayOfMissingModules.Value) {
                    ($ReferenceToArrayOfMissingModules.Value) += $strModuleName
                }
            }
        }
    }

    if ($boolThrowErrorForMissingModule) {
        $arrMessages = @($hashtableMessagesToThrowForMissingModule.Keys)
        foreach ($strMessage in $arrMessages) {
            if ($hashtableMessagesToThrowForMissingModule.Item($strMessage)) {
                Write-Error $strMessage
            }
        }
    } elseif ($boolThrowWarningForMissingModule) {
        $arrMessages = @($hashtableMessagesToThrowForMissingModule.Keys)
        foreach ($strMessage in $arrMessages) {
            if ($hashtableMessagesToThrowForMissingModule.Item($strMessage)) {
                Write-Warning $strMessage
            }
        }
    }

    return $boolResult
}
