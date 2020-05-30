# New-BackwardCompatibleCaseInsensitiveHashtable.ps1 contains one function
# (New-BackwardCompatibleCaseInsensitiveHashtable) that is designed to create a case-
# insensitive hashtable that is backward-compatible all the way to PowerShell v1, yet forward-
# compatible to all versions of PowerShell. It replaces other constructors on newer versions of
# PowerShell such as:
# $hashtable = @{{}}
# This function is useful if you need to work with hashtables (key-value pairs), but also need
# your code to be able to run on any version of PowerShell.

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

function New-BackwardCompatibleCaseInsensitiveHashtable {
    # Usage:
    # $hashtable = New-BackwardCompatibleCaseInsensitiveHashtable
    $cultureDoNotCare = [System.Globalization.CultureInfo]::InvariantCulture
    $caseInsensitiveHashCodeProvider = New-Object -TypeName "System.Collections.CaseInsensitiveHashCodeProvider" -ArgumentList @($cultureDoNotCare)
    $caseInsensitiveComparer = New-Object -TypeName "System.Collections.CaseInsensitiveComparer" -ArgumentList @($cultureDoNotCare)
    New-Object -TypeName "System.Collections.Hashtable" -ArgumentList @($caseInsensitiveHashCodeProvider, $caseInsensitiveComparer)
}
