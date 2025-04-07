function Get-CommandPromptPath {
    # .SYNOPSIS
    # Gets the path to the command prompt executable (cmd.exe).
    #
    # .DESCRIPTION
    # This function retrieves the path to the command prompt executable
    # (cmd.exe) and returns it as a string. If the path was determined
    # successfully, the function returns $true; otherwise, it returns $false.
    #
    # .PARAMETER ReferenceToCommandPromptPath
    # This parameter is required; it is a reference to a string that will be
    # used to store the path to the command prompt executable (cmd.exe).
    #
    # .EXAMPLE
    # $strCommandPromptPath = ''
    # $intReturnCode = Get-CommandPromptPath -ReferenceToCommandPromptPath ([ref]$strCommandPromptPath)
    #
    # .EXAMPLE
    # $strCommandPromptPath = ''
    # $intReturnCode = Get-CommandPromptPath ([ref]$strCommandPromptPath)
    #
    # .INPUTS
    # None. You can't pipe objects to Get-CommandPromptPath.
    #
    # .OUTPUTS
    # System.Boolean. Get-CommandPromptPath returns a boolean value indiciating
    # whether the path to the command prompt was retrieved successfully. $true
    # means the path was retrieved successfully; $false means the path was not
    # retrieved successfully.
    #
    # .NOTES
    # This function also supports the use of a single positional parameter
    # instead of its named parameter. If a positional parameter is used instead
    # of the named parameter, then exactly one positional parameter is
    # required: it is a reference to a string that will be used to store the
    # path to the command prompt executable (cmd.exe)
    #
    # Version: 1.0.20250406.0

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
        [ref]$ReferenceToCommandPromptPath = ([ref]$null)
    )

    if (-not [string]::IsNullOrEmpty($env:ComSpec)) {
        $strCommandPromptPath = $env:ComSpec
    } elseif (-not [string]::IsNullOrEmpty([System.Environment]::SystemDirectory)) {
        $strSystemDirectory = [System.Environment]::SystemDirectory
        $strCommandPromptPath = Join-Path -Path $strSystemDirectory -ChildPath 'cmd.exe'
    } else {
        return $false
    }

    if (Test-Path -Path $strCommandPromptPath) {
        $ReferenceToCommandPromptPath.Value = $strCommandPromptPath
        return $true
    } else {
        return $false
    }
}
