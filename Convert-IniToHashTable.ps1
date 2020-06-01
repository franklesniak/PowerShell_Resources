# Convert-IniToHashTable.ps1 is designed to take the ini files and convert then to hash tables
# (key-value pairs). In doing so, the ini files can be accessed in a performant, hierarchical
# manner that avoids slow string-parsing techniques.

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

function Convert-IniToHashTable {
    # This function reads an .ini file and converts it to a hashtable
    #
    # Five or six positional arguments are required:
    #
    # The first argument is a reference to an object that will be used to store output
    # The second argument is a string representing the file path to the ini file
    # The third argument is an array of characters that represent the characters allowed to
    #   indicate the start of a comment. Usually, this should be set to @(";"), but if hashtags
    #   are also allowed as comments for a given application, then it should be set to
    #   @(";", "#") or @("#")
    # The fourth argument is a boolean value that indicates whether comments should be ignored.
    #   Normally, comments should be ignored, and so this should be set to $true
    # The fifth argument is a boolean value that indicates whether comments must be on their
    #   own line in order to be considered a comment. If set to $false, and if the semicolon
    #   is the character allowed to indicate the start of a comment, then the text after the
    #   semicolon in this example would not be considered a comment:
    #   key=value ; this text would not be considered a comment
    #   in this example, the value would be:
    #   value ; this text would not be considered a comment
    # The sixth argument is a string representation of the null section name. In other words,
    #   if a key-value pair is found outside of a section, what should be used as its fake
    #   section name? As an example, this can be set to "NoSection" as long as their is no
    #   section in the ini file like [NoSection]
    # The seventh argument is a boolean value that indicates whether it is permitted for keys
    #   in the ini file to be supplied without an equal sign (if $true, the key is ingested but
    #   the value is regarded as $null). If set to false, lines that lack an equal sign are
    #   considered invalid and ignored.
    # If supplied, the eighth argument is a string representation of the comment prefix and is
    #   to being the name of the "key" representing the comment (and appended with an index
    #   number beginning with 1). If argument four is set to $false, then this argument is
    #   required. Usually "Comment" is OK to use, unless there are keys in the file named like
    #   "Comment1", "Comment2", etc.
    #
    # The function returns a 0 if successful, non-zero otherwise.
    #
    # Example usage:
    # $hashtableConfigIni = $null
    # $intReturnCode = Convert-IniToHashTable ([ref]$hashtableConfigIni) ".\config.ini" @(";") $true $true "NoSection" $true
    #
    # This function is derived from Get-IniContent at the website:
    # https://github.com/lipkau/PsIni/blob/master/PSIni/Functions/Get-IniContent.ps1
    # retrieved on 2020-05-30
    #region OriginalLicense
    # Although substantial modifications have been made, the original portions of
    # Get-IniContent that are incorporated into Convert-IniToHashTable are subject to the
    # following license:
    ###############################################################################################
    # Copyright 2019 Oliver Lipkau

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
    #endregion OriginalLicense

    $refOutput = $args[0]
    $strFilePath = $args[1]
    $arrCharCommentIndicator = $args[2]
    $boolIgnoreComments = $args[3]
    $boolCommentsMustBeOnOwnLine = $args[4]
    $strNullSectionName = $args[5]
    $boolAllowKeysWithoutValuesThatOmitEqualSign = $args[6]
    if ($boolIgnoreComments -ne $true) {
        $strCommentPrefix = $args[7]
    }

    # Initialize regex matching patterns
    $arrCharCommentIndicator = $arrCharCommentIndicator | ForEach-Object {
        [regex]::Escape($_)
    }
    $strRegexComment = "^\s*([$($arrCharCommentIndicator -join '')].*)$"
    $strRegexCommentAnywhere = "\s*([$($arrCharCommentIndicator -join '')].*)$"
    $strRegexSection = "^\s*\[(.+)\]\s*$"
    $strRegexKey = "^\s*(.+?)\s*=\s*(['`"]?)(.*)\2\s*$"

    $hashtableIni = New-BackwardCompatibleCaseInsensitiveHashtable

    if ((Test-Path $strFilePath) -eq $false) {
        Write-Error ("Could not process INI file; the specified file was not found: " + $strFilePath)
        1 # return failure code
    } else {
        $intCommentCount = 0
        $strSection = $null
        switch -regex -file $strFilePath {
            $strRegexSection {
                $strSection = $Matches[1]
                if ($hashtableIni.ContainsKey($strSection) -eq $false) {
                    $hashtableIni.Add($strSection, (New-BackwardCompatibleCaseInsensitiveHashtable))
                }
                $intCommentCount = 0
                continue
            }

            $strRegexComment {
                if ($boolIgnoreComments -ne $true) {
                    if ($null -eq $strSection) {
                        $strEffectiveSection = $strNullSectionName
                        if ($hashtableIni.ContainsKey($strEffectiveSection) -eq $false) {
                            $hashtableIni.Add($strEffectiveSection, (New-BackwardCompatibleCaseInsensitiveHashtable))
                        }
                    } else {
                        $strEffectiveSection = $strSection
                    }
                    $intCommentCount++
                    if (($hashtableIni.Item($strEffectiveSection)).ContainsKey($strCommentPrefix + ([string]$intCommentCount))) {
                        Write-Warning ("File `"" + $strFilePath + "`", section `"" + $strEffectiveSection + "`" already unexpectedly contains a key `"" + ($strCommentPrefix + ([string]$intCommentCount)) + "`" with value `"" + ($hashtableIni.Item($strEffectiveSection)).Item($strCommentPrefix + ([string]$intCommentCount)) + "`". Key's value will be changed to: `"" + $Matches[1] + "`"")
                        ($hashtableIni.Item($strEffectiveSection)).Item($strCommentPrefix + ([string]$intCommentCount)) = $Matches[1]
                    } else {
                        ($hashtableIni.Item($strEffectiveSection)).Add($strCommentPrefix + ([string]$intCommentCount), $Matches[1])
                    }
                }
                continue
            }

            default {
                $strLine = $_
                if ($null -eq $strSection) {
                    $strEffectiveSection = $strNullSectionName
                    if ($hashtableIni.ContainsKey($strEffectiveSection) -eq $false) {
                        $hashtableIni.Add($strEffectiveSection, (New-BackwardCompatibleCaseInsensitiveHashtable))
                    }
                } else {
                    $strEffectiveSection = $strSection
                }

                $strKey = $null
                $strValue = $null
                if ($boolCommentsMustBeOnOwnLine) {
                    $arrLine = @([regex]::Split($strLine, $strRegexKey))
                    if ($arrLine.Count -ge 4) {
                        # Key-Value Pair found
                        $strKey = $arrLine[1]
                        $strValue = $arrLine[3]
                    } else {
                        # No key-value pair found
                        if ($boolAllowKeysWithoutValuesThatOmitEqualSign) {
                            if (($null -ne $arrLine[0]) -and ("" -ne $arrLine[0])) {
                                $strKey = $arrLine[0]
                            }
                        }
                    }
                } else {
                    # Comments do not have to be on their own line
                    $arrLine = @([regex]::Split($strLine, $strRegexCommentAnywhere))
                    # $arrLine[0] is the line before any comments
                    $arrLineKeyValue = @([regex]::Split($arrLine[0], $strRegexKey))
                    if ($arrLineKeyValue.Count -ge 4) {
                        # Key-Value Pair found
                        $strKey = $arrLineKeyValue[1]
                        $strValue = $arrLineKeyValue[3]
                    } else {
                        # No key-value pair found
                        if ($boolAllowKeysWithoutValuesThatOmitEqualSign) {
                            if (($null -ne $arrLineKeyValue[0]) -and ("" -ne $arrLineKeyValue[0])) {
                                $strKey = $arrLineKeyValue[0]
                            }
                        }
                    }
                    # if $arrLine.Count -gt 1, $arrLine[1] is the comment portion of the line
                    if ($arrLine.Count -gt 1) {
                        if ($boolIgnoreComments -ne $true) {
                            $intCommentCount++
                            if (($hashtableIni.Item($strEffectiveSection)).ContainsKey($strCommentPrefix + ([string]$intCommentCount))) {
                                Write-Warning ("File `"" + $strFilePath + "`", section `"" + $strEffectiveSection + "`" already unexpectedly contains a key `"" + ($strCommentPrefix + ([string]$intCommentCount)) + "`" with value `"" + ($hashtableIni.Item($strEffectiveSection)).Item($strCommentPrefix + ([string]$intCommentCount)) + "`". Key's value will be changed to: `"" + $Matches[1] + "`"")
                                ($hashtableIni.Item($strEffectiveSection)).Item($strCommentPrefix + ([string]$intCommentCount)) = $Matches[1]
                            } else {
                                ($hashtableIni.Item($strEffectiveSection)).Add($strCommentPrefix + ([string]$intCommentCount), $Matches[1])
                            }
                        }
                    }
                }

                if ($null -ne $strKey) {
                    if (($hashtableIni.Item($strEffectiveSection)).ContainsKey($strKey)) {
                        Write-Warning ("File `"" + $strFilePath + "`", section `"" + $strEffectiveSection + "`" already unexpectedly contains a key `"" + $strKey + "`" with value `"" + ($hashtableIni.Item($strEffectiveSection)).Item($strKey) + "`". Key's value will be changed to: null")
                        ($hashtableIni.Item($strEffectiveSection)).Item($strKey) = $strValue
                    } else {
                        ($hashtableIni.Item($strEffectiveSection)).Add($strKey, $strValue)
                    }
                }
                continue
            }
        }
        $refOutput.Value = $hashtableIni
        0 # return success code
    }
}
