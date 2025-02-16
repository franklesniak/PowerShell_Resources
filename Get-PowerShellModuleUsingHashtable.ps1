function Get-PowerShellModuleUsingHashtable {
    # .SYNOPSIS
    # Gets a list of installed PowerShell modules for each entry in a hashtable.
    #
    # .DESCRIPTION
    # The Get-PowerShellModuleUsingHashtable function steps through each entry in
    # the supplied hashtable and gets a list of installed PowerShell modules for
    # each entry. The list of installed PowerShell modules for each entry is stored
    # in the value of the hashtable entry for that module (as an array).
    #
    # .PARAMETER ReferenceToHashtable
    # This parameter is required; it is a reference (memory pointer) to a
    # hashtable. The referenced hashtable must have keys that are the names of
    # PowerShell modules and values that are initialized to be enpty arrays (@()).
    # After running this function, the list of installed PowerShell modules for
    # each entry will is stored in the value of the hashtable entry as a populated
    # array.
    #
    # .PARAMETER DoNotCheckPowerShellVersion
    # This parameter is optional. If this switch is present, the function will not
    # check the version of PowerShell that is running. This is useful if you are
    # running this function in a script and the script has already validated that
    # the version of PowerShell supports Get-Module -ListAvailable.
    #
    # .EXAMPLE
    # $hashtableModuleNameToInstalledModules = @{}
    # $hashtableModuleNameToInstalledModules.Add('PnP.PowerShell', @())
    # $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Authentication', @())
    # $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Groups', @())
    # $hashtableModuleNameToInstalledModules.Add('Microsoft.Graph.Users', @())
    # $refHashtableModuleNameToInstalledModules = [ref]$hashtableModuleNameToInstalledModules
    # Get-PowerShellModuleUsingHashtable -ReferenceToHashtable $refHashtableModuleNameToInstalledModules
    #
    # This example gets the list of installed PowerShell modules for each of the
    # four modules listed in the hashtable. The list of each respective module is
    # stored in the value of the hashtable entry for that module.
    #
    # .INPUTS
    # None. You can't pipe objects to Get-PowerShellModuleUsingHashtable.
    #
    # .OUTPUTS
    # None. This function does not generate any output. The list of installed
    # PowerShell modules for each key in the referenced hashtable is stored in the
    # respective entry's value.
    #
    # .NOTES
    # This function also supports the use of a positional parameter instead of a
    # named parameter. If a positional parameter is used intead of named
    # parameters, then the first and only positional parameters must be a reference
    # (memory pointer) to a hashtable. The referenced hashtable must have keys that
    # are the names of PowerShell modules and values that are initialized to be
    # enpty arrays (@()). After running this function, the list of installed
    # PowerShell modules for each entry will is stored in the value of the
    # hashtable entry as a populated array.
    #
    # Version: 1.1.20250123.4

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
        [ref]$ReferenceToHashtable = ([ref]$null),
        [switch]$DoNotCheckPowerShellVersion
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

    if ($null -eq $ReferenceToHashtable) {
        Write-Error ('The Get-PowerShellModuleUsingHashtable function requires a parameter (-ReferenceToHashtable), which must reference a hashtable.')
        return
    } else {
        if ($null -eq $ReferenceToHashtable.Value) {
            Write-Error ('The Get-PowerShellModuleUsingHashtable function requires a parameter (-ReferenceToHashtable), which must reference a hashtable.')
            return
        }
    }

    $boolCheckForPowerShellVersion = $true
    if ($null -ne $DoNotCheckPowerShellVersion) {
        if ($DoNotCheckPowerShellVersion.IsPresent) {
            $boolCheckForPowerShellVersion = $false
        }
    }

    if ($boolCheckForPowerShellVersion) {
        $versionPS = Get-PSVersion
        if ($versionPS.Major -lt 2) {
            Write-Error ('The Get-PowerShellModuleUsingHashtable function requires PowerShell version 2.0 or greater.')
            return
        }
    }

    $VerbosePreferenceAtStartOfFunction = $VerbosePreference

    $arrModulesToGet = @(($ReferenceToHashtable.Value).Keys)
    $intCountOfModules = $arrModulesToGet.Count

    for ($intCounter = 0; $intCounter -lt $intCountOfModules; $intCounter++) {
        Write-Verbose ('Checking for ' + $arrModulesToGet[$intCounter] + ' module...')
        $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        ($ReferenceToHashtable.Value).Item($arrModulesToGet[$intCounter]) = @(Get-Module -Name ($arrModulesToGet[$intCounter]) -ListAvailable)
        $VerbosePreference = $VerbosePreferenceAtStartOfFunction
    }

    return
}
