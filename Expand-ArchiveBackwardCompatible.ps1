function Expand-ArchiveBackwardCompatible {
    # This function takes 1-2 positional arguments
    #
    # If two arguments are specified:
    #   The first argument is the destination path, i.e., the path to which we extract the ZIP.
    #   The second argument is the path to the ZIP file
    #
    # If one argument is specified, it is the path to the ZIP file. In this case, the
    #   destination path will be the current working directory plus a subfolder named the same
    #   as the ZIP file (minus the .ZIP extension, if one exists)
    #
    # The function does not return anything
    #
    # Version 0.1.20241001.0

    #region License ############################################################
    # Copyright (c) 2024 Frank Lesniak
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

    #region DownloadLocationNotice #############################################
    # The most up-to-date version of this script can be found on the author's
    # GitHub repository at https://github.com/franklesniak/PowerShell_Resources
    #endregion DownloadLocationNotice #############################################

    $strZIPPath = $null
    $strDestinationPath = $null
    if ($args.Count -ge 2) {
        if (($args[0]).GetType().FullName -eq "System.String") {
            $strDestinationPath = ([string]($args[0]))
        }
        if (($args[1]).GetType().FullName -eq "System.String") {
            $strZIPPath = ([string]($args[1]))
        }
    } elseif ($args.Count -eq 1) {
        if (($args[0]).GetType().FullName -eq "System.String") {
            $strZIPPath = ([string]($args[0]))
        }
        $strDestinationPath = (Get-Location).Path
        if ($null -ne $strZIPPath) {
            # Append folder with name of ZIP (pre-extension) to match behavior of Expand-Archive

            # First, get ZIP file name
            $strProviderZIPPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($strZIPPath)
            $strZIPFileName = Split-Path -Path $strProviderZIPPath -Leaf

            # Remove the .zip extension from the file name, if there is one
            $arrFileName = @(Split-StringOnLiteralString $strZIPFileName ".")
            if ($arrFileName[$arrFileName.Count - 1] -eq "zip") {
                # ZIP file has .zip extension as usual
                $strZIPWithoutExtension = $arrFileName[0]
                for ($intCounter = 1; $intCounter -le ($arrFileName.Count - 2); $intCounter++) {
                    $strZIPWithoutExtension = $strZIPWithoutExtension + "." + $arrFileName[$intCounter]
                }
            } else {
                # ZIP file did not contain .zip extension
                $strZIPWithoutExtension = $strZIPFileName
            }

            # Build the destination path
            $strDestinationPath = Join-Path $strDestinationPath $strZIPWithoutExtension
        }
    }

    if ($null -eq $strZIPPath) {
        Write-Error "Invalid ZIP path specified in Expand-ZIPBackwardCompatible"
    } elseif ($null -eq $strDestinationPath) {
        Write-Error "Invalid destination path specified in Expand-ZIPBackwardCompatible"
    } else {
        # TO-DO: check for existence of ZIP file
        if (Test-PowerShellCommand "Expand-Archive") {
            Expand-Archive -Path $strZIPPath -DestinationPath $strDestinationPath
        } else {
            $strProviderZIPPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($strZIPPath)
            $strProviderDestinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($strDestinationPath)

            if ((Test-Path $strDestinationPath) -ne $true) {
                New-Item -Path $strDestinationPath -ItemType Directory | Out-Null
            }

            # Check to see if System.IO.Compression.ZipFile is available
            $boolZipFileTypeNameAvailable = $false
            if (Test-TypeNameAvailability "System.IO.Compression.ZipFile" $true) {
                $boolZipFileTypeNameAvailable = $true
            } else {
                # System.IO.Compression.ZipFile was not available; attempt to load it and then re-check

                # Load the assembly
                if ($versionPowerShell.Major -ge 2) {
                    # Add-Type is available
                    Add-Type -AssemblyName "System.IO.Compression.FileSystem"
                } else {
                    # Add-Type is not available; use [system.reflection.assembly]
                    $reflectionAssemblyResult = [system.reflection.assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
                }

                # Re-check to make sure it's present
                if (Test-TypeNameAvailability "System.IO.Compression.ZipFile" $false) {
                    $boolZipFileTypeNameAvailable = $true
                }
            }

            if ($boolZipFileTypeNameAvailable) {
                [System.IO.Compression.ZipFile]::ExtractToDirectory($strProviderZIPPath, $strProviderDestinationPath)
            } else {
                if (Test-Windows) {
                    # Is Windows; use the Shell.Application COM object
                    $comObjectShellApplication = New-Object -ComObject "Shell.Application"
                    $comObjectShellApplicationNamespaceZIP = $comObjectShellApplication.Namespace($strProviderZIPPath)
                    $comObjectShellApplicationNamespaceZIPItems = @($comObjectShellApplicationNamespaceZIP.Items())
                    $comObjectShellApplicationNamespaceDestinationFolder = $comObjectShellApplication.Namespace($strProviderDestinationPath)
                    $intCounter = 1
                    $strTempFolderPath = [System.IO.Path]::GetTempPath()
                    $strZIPFileName = Split-Path -Path $strProviderZIPPath -Leaf
                    $comObjectShellApplicationNamespaceZIPItems |
                        ForEach-Object {
                            $comObjectShellApplicationNamespaceDestinationFolder.CopyHere($_, (4 + 16 + 256))

                            # Clean-up temp folder that sometimes gets created
                            $strTempPathToCleanup = Join-Path $strTempFolderPath ("Temporary Directory " + ([string]$intCounter) + " for " + $strZIPFileName)
                            if (Test-Path $strTempPathToCleanup) {
                                # Remove the folder
                                Remove-Item -Path $strTempPathToCleanup -Recurse -Force
                            }
                        }
                } else {
                    # Is not Windows, and all other approaches have failed. Give up!
                    Write-Error "Unable to extract ZIP file; no interfaces available to perform this operation."
                }
            }
        }
    }
}
