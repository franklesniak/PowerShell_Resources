# Get-PSVersion
$strThisScriptLoadedFlagVariableName = "__FRANKLESNIAK__GETPSVERSION__LOADED"
$strThisScriptVersionNumberVariableName = "__FRANKLESNIAK__GETPSVERSION__NUMBER"
$strThisScriptVersionNumber = [version]"1.0.0.20200730"

#region License
###############################################################################################
# Copyright 2020 Frank Lesniak

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

#region PreventReruns
if (Test-Path ("variable:\" + $strThisScriptLoadedFlagVariableName)) {
    if (Test-Path ("variable:\" + $strThisScriptVersionNumberVariableName)) {
        if ((Get-Variable -Name $strThisScriptVersionNumberVariableName).Value -ge $strThisScriptVersionNumber) {
            break
        } else {
            (Get-Variable -Name $strThisScriptVersionNumberVariableName).Value = $strThisScriptVersionNumber
        }
    } else {
        New-Variable -Name $strThisScriptVersionNumberVariableName -Value $strThisScriptVersionNumber
    }
} else {
    New-Variable -Name $strThisScriptLoadedFlagVariableName -Value $true
    if (Test-Path ("variable:\" + $strThisScriptVersionNumberVariableName)) {
        (Get-Variable -Name $strThisScriptVersionNumberVariableName).Value = $strThisScriptVersionNumber
    } else {
        New-Variable -Name $strThisScriptVersionNumberVariableName -Value $strThisScriptVersionNumber
    }
}
#endregion PreventReruns

function Get-PSVersion {
    if (Test-Path variable:\PSVersionTable) {
        $PSVersionTable.PSVersion
    } else {
        [version]("1.0")
    }
}
