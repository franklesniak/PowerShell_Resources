# Build-CSharpInMemory is for compiling C# in memory on PowerShell v1
#
# On PowerShell v2 and later, you do not need to use Build-CSharpInMemory; instead, use syntax
# like: Add-Type -Language CSharp -TypeDefinition $strCSharpCode

function Get-PathToDotNetRuntimeEnvironment {
    $strThisFunctionVersionNumber = [version]'1.0.20200729.0'

    #region License ################################################################
    # Copyright 2020 Frank Lesniak

    # Permission is hereby granted, free of charge, to any person obtaining a copy of
    # this software and associated documentation files (the "Software"), to deal in the
    # Software without restriction, including without limitation the rights to use,
    # copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
    # Software, and to permit persons to whom the Software is furnished to do so,
    # subject to the following conditions:

    # The above copyright notice and this permission notice shall be included in all
    # copies or substantial portions of the Software.

    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    # FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    # COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
    # AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #endregion License ################################################################

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
    # Build-CSharpInMemory is for compiling C# in memory on PowerShell v1
    #
    # On PowerShell v2 and later, you do not need to use Build-CSharpInMemory; instead,
    # use syntax like: Add-Type -Language CSharp -TypeDefinition $strCSharpCode

    $strThisFunctionVersionNumber = [version]'1.0.20220618.0'

    #region License ################################################################
    # Copyright 2020 Frank Lesniak

    # Permission is hereby granted, free of charge, to any person obtaining a copy of
    # this software and associated documentation files (the "Software"), to deal in the
    # Software without restriction, including without limitation the rights to use,
    # copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
    # Software, and to permit persons to whom the Software is furnished to do so,
    # subject to the following conditions:

    # The above copyright notice and this permission notice shall be included in all
    # copies or substantial portions of the Software.

    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    # FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    # COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
    # AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #endregion License ################################################################

    param (
        [string]$strCSharpCodeToCompile,
        [array]$arrAdditionalReferences
    )

    $cSharpCodeProvider = New-Object Microsoft.CSharp.CSharpCodeProvider

    $arrayListReferences = New-Object Collections.ArrayList
    $arrayListReferences.AddRange( `
        @( `
            (Join-Path (Get-PathToDotNetRuntimeEnvironment) "System.dll"),
            [PSObject].Assembly.Location
        )
    )
    if ($null -ne $arrAdditionalReferences)	{
        if ($arrAdditionalReferences.Count -ge 1) {
            $arrayListReferences.AddRange($arrAdditionalReferences)
        }
    }

    $compilerParameters = New-Object System.CodeDom.Compiler.CompilerParameters
    $compilerParameters.GenerateInMemory = $true
    $compilerParameters.GenerateExecutable = $false
    $compilerParameters.OutputAssembly = "custom"
    $compilerParameters.ReferencedAssemblies.AddRange($ArrayListReferences)
    $compilerResults = $cSharpCodeProvider.CompileAssemblyFromSource($compilerParameters, $strCSharpCodeToCompile)

    if ($CompilerResults.Errors.Count) {
        $arrCSharpCodeLines = $strCSharpCodeToCompile.Split("`n")
        foreach ($compilerError in $compilerResults.Errors) {
            Write-Host "Error: $($arrCSharpCodeLines[$($compilerError.Line - 1)])"
            $compilerError | Out-Default
        }
        throw 'INVALID DATA: Errors encountered while compiling code'
    }
}
