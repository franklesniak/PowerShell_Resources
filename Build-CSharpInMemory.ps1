# Build-CSharpInMemory is for compiling C# in memory on PowerShell v1
#
# On PowerShell v2 and later, you do not need to use Build-CSharpInMemory; instead, use syntax
# like: Add-Type -Language CSharp -TypeDefinition $strCSharpCode

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

function Get-PathToDotNetRuntimeEnvironment {
    $strPathToDotNetRuntimeEnvironment = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
    # We have the path, but it has a trailing backslash. Let's remove it
    $guid = [guid]::NewGuid()
    $strGUID = $guid.Guid
    $strWorkingPath = Join-Path $strPathToDotNetRuntimeEnvironment $strGUID
    $arrPath = Split-StringOnLiteralString $strWorkingPath $strGUID
    $strPathWithSeparatorButWithoutGUID = $arrPath[0]
    $strScrubbedPath = $strPathWithSeparatorButWithoutGUID.Substring(0, $strPathWithSeparatorButWithoutGUID.Length - 1)
    $strScrubbedPath
}

function Build-CSharpInMemory {
    Param (
        [string]$strCSharpCodeToCompile,
        [array]$arrAdditionalReferences
    )

    $CSharpCodeProvider = New-Object Microsoft.CSharp.CSharpCodeProvider

    $ArrayListReferences = New-Object Collections.ArrayList
    $ArrayListReferences.AddRange( `
        @( `
            (Join-Path (Get-PathToDotNetRuntimeEnvironment) "System.dll"),
            [PSObject].Assembly.Location
        )
    )
    if ($arrAdditionalReferences -ne $null)	{
        if ($arrAdditionalReferences.Count -ge 1) {
            $ArrayListReferences.AddRange($arrAdditionalReferences)
        }
    }

    $CompilerParameters = New-Object System.CodeDom.Compiler.CompilerParameters
    $CompilerParameters.GenerateInMemory = $true
    $CompilerParameters.GenerateExecutable = $false
    $CompilerParameters.OutputAssembly = "custom"
    $CompilerParameters.ReferencedAssemblies.AddRange($ArrayListReferences)
    $CompilerResults = $CSharpCodeProvider.CompileAssemblyFromSource($CompilerParameters, $strCSharpCodeToCompile)

    if ($CompilerResults.Errors.Count) {
        $arrCSharpCodeLines = $strCSharpCodeToCompile.Split("`n")
        foreach ($CompilerError in $CompilerResults.Errors) {
            Write-Host "Error: $($arrCSharpCodeLines[$($CompilerError.Line - 1)])"
            $CompilerError | Out-Default
        }
        Throw "INVALID DATA: Errors encountered while compiling code"
    }
}