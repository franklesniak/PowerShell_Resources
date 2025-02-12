function Split-StringOnLiteralString {
    # .SYNOPSIS
    # Splits a string into an array using a literal string as the splitter.
    #
    # .DESCRIPTION
    # Splits a string using a literal string (as opposed to regex). The
    # function is designed to be backward-compatible with all versions of
    # PowerShell and has been tested successfully on PowerShell v1. This
    # function behaves more like VBScript's Split() function than other
    # string splitting-approaches in PowerShell while avoiding the use of
    # RegEx.
    #
    # .PARAMETER StringToSplit
    # This parameter is required; it is the string to be split into an
    # array.
    #
    # .PARAMETER Splitter
    # This parameter is required; it is the string that will be used to
    # split the string specified in the StringToSplit parameter.
    #
    # .EXAMPLE
    # $result = Split-StringOnLiteralString -StringToSplit 'What do you think of this function?' -Splitter ' '
    # # $result.Count is 7
    # # $result[2] is 'you'
    #
    # .EXAMPLE
    # $result = Split-StringOnLiteralString 'What do you think of this function?' ' '
    # # $result.Count is 7
    #
    # .EXAMPLE
    # $result = Split-StringOnLiteralString -StringToSplit 'foo' -Splitter ' '
    # # $result.GetType().FullName is System.Object[]
    # # $result.Count is 1
    #
    # .EXAMPLE
    # $result = Split-StringOnLiteralString -StringToSplit 'foo' -Splitter ''
    # # $result.GetType().FullName is System.Object[]
    # # $result.Count is 5 because of how .NET handles a split using an
    # # empty string:
    # # $result[0] is ''
    # # $result[1] is 'f'
    # # $result[2] is 'o'
    # # $result[3] is 'o'
    # # $result[4] is ''
    #
    # .INPUTS
    # None. You can't pipe objects to Split-StringOnLiteralString.
    #
    # .OUTPUTS
    # System.String[]. Split-StringOnLiteralString returns an array of
    # strings, with each string being an element of the resulting array
    # from the split operation. This function always returns an array, even
    # when there is zero elements or one element in it.
    #
    # .NOTES
    # This function also supports the use of positional parameters instead
    # of named parameters. If positional parameters are used intead of
    # named parameters, then two positional parameters are required:
    #
    # The first positional parameter is the string to be split into an
    # array.
    #
    # The second positional parameter is the string that will be used to
    # split the string specified in the first positional parameter.
    #
    # Also, please note that if -StringToSplit (or the first positional
    # parameter) is $null, then the function will return an array with one
    # element, which is an empty string. This is because the function
    # converts $null to an empty string before splitting the string.
    #
    # Version: 3.0.20250211.0

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

    param (
        [string]$StringToSplit = '',
        [string]$Splitter = ''
    )

    $strSplitterInRegEx = [regex]::Escape($Splitter)
    $result = @([regex]::Split($StringToSplit, $strSplitterInRegEx))

    # The following code forces the function to return an array, always,
    # even when there are zero or one elements in the array
    $intElementCount = 1
    if ($null -ne $result) {
        if ($result.GetType().FullName.Contains('[]')) {
            if (($result.Count -ge 2) -or ($result.Count -eq 0)) {
                $intElementCount = $result.Count
            }
        }
    }
    $strLowercaseFunctionName = $MyInvocation.InvocationName.ToLower()
    $boolArrayEncapsulation = $MyInvocation.Line.ToLower().Contains('@(' + $strLowercaseFunctionName + ')') -or $MyInvocation.Line.ToLower().Contains('@(' + $strLowercaseFunctionName + ' ')
    if ($boolArrayEncapsulation) {
        return ($result)
    } elseif ($intElementCount -eq 0) {
        return (, @())
    } elseif ($intElementCount -eq 1) {
        return (, (, $StringToSplit))
    } else {
        return ($result)
    }
}
