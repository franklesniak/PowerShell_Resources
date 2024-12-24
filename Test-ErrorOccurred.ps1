function Test-ErrorOccurred {
    # .SYNOPSIS
    # Checks to see if an error occurred during a time period, i.e., during
    # the execution of a command.
    #
    # .DESCRIPTION
    # Using two references (memory pointers) to errors, this function
    # checks to see if an error occurred based on differences between the
    # two errors.
    #
    # To use this function, you must first retrieve a reference to the last
    # error that occurred prior to the command you are about to run. Then,
    # run the command. After the command completes, retrieve a reference to
    # the last error that occurred. Pass these two references to this
    # function to determine if an error occurred.
    #
    # .PARAMETER ReferenceToEarlierError
    # This parameter is required; it is a reference (memory pointer) to a
    # System.Management.Automation.ErrorRecord that represents the newest
    # error on the stack earlier in time, i.e., prior to running the
    # command for which you wish to determine whether an error occurred.
    #
    # If no error was on the stack at this time, ReferenceToEarlierError
    # must be a reference to $null ([ref]$null).
    #
    # .PARAMETER ReferenceToLaterError
    # This parameter is required; it is a reference (memory pointer) to a
    # System.Management.Automation.ErrorRecord that represents the newest
    # error on the stack later in time, i.e., after to running the command
    # for which you wish to determine whether an error occurred.
    #
    # If no error was on the stack at this time, ReferenceToLaterError
    # must be a reference to $null ([ref]$null).
    #
    # .EXAMPLE
    # # Intentionally empty trap statement to prevent terminating errors
    # # from halting processing
    # trap { }
    #
    # # Retrieve the newest error on the stack prior to doing work
    # if ($Error.Count -gt 0) {
    #     $refLastKnownError = ([ref]($Error[0]))
    # } else {
    #     $refLastKnownError = ([ref]$null)
    # }
    #
    # # Store current error preference; we will restore it after we do some
    # # work:
    # $actionPreferenceFormerErrorPreference = $global:ErrorActionPreference
    #
    # # Set ErrorActionPreference to SilentlyContinue; this will suppress
    # # error output. Terminating errors will not output anything, kick to
    # # the empty trap statement and then continue on. Likewise, non-
    # # terminating errors will also not output anything, but they do not
    # # kick to the trap statement; they simply continue on.
    # $global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
    #
    # # Do something that might trigger an error
    # Get-Item -Path 'C:\MayNotExist.txt'
    #
    # # Restore the former error preference
    # $global:ErrorActionPreference = $actionPreferenceFormerErrorPreference
    #
    # # Retrieve the newest error on the error stack
    # if ($Error.Count -gt 0) {
    #     $refNewestCurrentError = ([ref]($Error[0]))
    # } else {
    #     $refNewestCurrentError = ([ref]$null)
    # }
    #
    # if (Test-ErrorOccurred -ReferenceToEarlierError $refLastKnownError -ReferenceToLaterError $refNewestCurrentError) {
    #     # Error occurred
    # } else {
    #     # No error occurred
    # }
    #
    # .INPUTS
    # None. You can't pipe objects to Test-ErrorOccurred.
    #
    # .OUTPUTS
    # System.Boolean. Test-ErrorOccurred returns a boolean value indicating
    # whether an error occurred during the time period in question. $true
    # indicates an error occurred; $false indicates no error occurred.
    #
    # .NOTES
    # This function also supports the use of positional parameters instead
    # of named parameters. If positional parameters are used intead of
    # named parameters, then two positional parameters are required:
    #
    # The first positional parameter is a reference (memory pointer) to a
    # System.Management.Automation.ErrorRecord that represents the newest
    # error on the stack earlier in time, i.e., prior to running the
    # command for which you wish to determine whether an error occurred. If
    # no error was on the stack at this time, the first positional
    # parameter must be a reference to $null ([ref]$null).
    #
    # The second positional parameter is a reference (memory pointer) to a
    # System.Management.Automation.ErrorRecord that represents the newest
    # error on the stack later in time, i.e., after to running the command
    # for which you wish to determine whether an error occurred. If no
    # error was on the stack at this time, ReferenceToLaterError must be
    # a reference to $null ([ref]$null).
    #
    # Version: 2.0.20241223.0

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
    param (
        [ref]$ReferenceToEarlierError = ([ref]$null),
        [ref]$ReferenceToLaterError = ([ref]$null)
    )

    # TODO: Validate input

    $boolErrorOccurred = $false
    if (($null -ne $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
        # Both not $null
        if (($ReferenceToEarlierError.Value) -ne ($ReferenceToLaterError.Value)) {
            $boolErrorOccurred = $true
        }
    } else {
        # One is $null, or both are $null
        # NOTE: $ReferenceToEarlierError could be non-null, while
        # $ReferenceToLaterError could be null if $error was cleared; this
        # does not indicate an error.
        # So:
        # - If both are null, no error
        # - If $ReferenceToEarlierError is null and $ReferenceToLaterError
        #   is non-null, error
        # - If $ReferenceToEarlierError is non-null and
        #   $ReferenceToLaterError is null, no error
        if (($null -eq $ReferenceToEarlierError.Value) -and ($null -ne $ReferenceToLaterError.Value)) {
            $boolErrorOccurred = $true
        }
    }

    return $boolErrorOccurred
}
