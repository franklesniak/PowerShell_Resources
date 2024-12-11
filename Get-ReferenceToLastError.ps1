function Get-ReferenceToLastError {
    #region FunctionHeader #############################################
    # Function returns $null if no errors on on the $error stack;
    # Otherwise, function returns a reference (memory pointer) to the last
    # error that occurred.
    #
    # Version: 1.0.20241211.0
    #endregion FunctionHeader #############################################

    #region License ####################################################
    # Copyright (c) 2024 Frank Lesniak
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

    #region DownloadLocationNotice #####################################
    # The most up-to-date version of this script can be found on the
    # author's GitHub repository at:
    # https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice #####################################

    if ($Error.Count -gt 0) {
        return ([ref]($Error[0]))
    } else {
        return $null
    }
}
