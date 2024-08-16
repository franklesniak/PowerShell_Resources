# Measures internet quality to Azure regions by downloading a file from Azure Blob
# Storage and measuring the time it takes to download it.

# Adapted from https://github.com/blrchen/azure-speed-test, which is copyright (c) 2014 blchen
# Thanks also to https://www.azurespeed.com/

# TODO: Make these parameters
$doubleNumberOfSecondsBetweenTests = [double]2.5
$doubleNumberOfMinutesOfTesting = [double]5

$boolCentralUS = $true
$boolEastUS = $true
$boolEastUS2 = $true
$boolNorthCentralUS = $true
$boolSouthCentralUS = $true
$boolWestCentralUS = $true
$boolWestUS = $true
$boolWestUS2 = $true
$boolWestUS3 = $true

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

function Get-PSVersion {
    <#
    .SYNOPSIS
    Returns the version of PowerShell that is running

    .DESCRIPTION
    Returns the version of PowerShell that is running, including on the original
    release of Windows PowerShell (version 1.0)

    .EXAMPLE
    Get-PSVersion

    This example returns the version of PowerShell that is running. On versions of
    PowerShell greater than or equal to version 2.0, this function returns the
    equivalent of $PSVersionTable.PSVersion

    .OUTPUTS
    A [version] object representing the version of PowerShell that is running

    .NOTES
    PowerShell 1.0 does not have a $PSVersionTable variable, so this function returns
    [version]('1.0') on PowerShell 1.0
    #>

    [CmdletBinding()]
    [OutputType([version])]

    param ()

    #region License ################################################################
    # Copyright (c) 2023 Frank Lesniak
    #
    # Permission is hereby granted, free of charge, to any person obtaining a copy of
    # this software and associated documentation files (the "Software"), to deal in the
    # Software without restriction, including without limitation the rights to use,
    # copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
    # Software, and to permit persons to whom the Software is furnished to do so,
    # subject to the following conditions:
    #
    # The above copyright notice and this permission notice shall be included in all
    # copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    # FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    # COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
    # AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #endregion License ################################################################

    $versionThisFunction = [version]('1.0.20230613.0')

    if (Test-Path variable:\PSVersionTable) {
        $PSVersionTable.PSVersion
    } else {
        [version]('1.0')
    }
}

$versionPS = Get-PSVersion

if ($versionPS -le ([version]'2.0')) {
    Write-Error 'This script requires PowerShell 2.0 or later'
    return
}

$strCSharpCode = @"
using System;
using System.Diagnostics;
using System.Net.Http;
using System.Threading.Tasks;

public class LatencyTester
{
    private static readonly HttpClient httpClient = new HttpClient();

    public double PingUrl(string url)
    {
        return PingUrlInternal(url).GetAwaiter().GetResult();
    }

    private async Task<double> PingUrlInternal(string url)
    {
        var request = new HttpRequestMessage
        {
            RequestUri = new Uri(url),
            Method = HttpMethod.Get,
        };
        request.Headers.Add("Cache-Control", "no-cache");
        request.Headers.Add("Accept", "*/*");

        var pingStartTime = Stopwatch.GetTimestamp();

        try
        {
            var response = await httpClient.SendAsync(request);
            response.EnsureSuccessStatusCode();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error pinging URL: {url}, Error: {ex.Message}");
            return -1; // Indicate failure
        }

        var pingEndTime = Stopwatch.GetTimestamp();
        var pingDuration = (pingEndTime - pingStartTime) * 1000.0 / Stopwatch.Frequency;

        return pingDuration;
    }
}
"@

# Compile the C# code
Add-Type -Language CSharp -TypeDefinition $strCSharpCode

# Create an instance of the LatencyTester class
$latencyTester = New-Object LatencyTester

# Build hashtable of URIs and results
# Based on https://www.azurespeed.com/Azure/Latency
$hashtableRegionNamesToURIs = @{}
$hashtableURIsToTestResults = @{}

# Central US
if ($boolCentralUS -eq $true) {
    $strRegionName = 'Central US'
    $strURI = 'https://s8centralus.blob.core.windows.net/public/latency-test.json'
    $hashtableRegionNamesToURIs.Add($strRegionName, $strURI)
    if ($versionPS -ge ([version]'6.0')) {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.Generic.List[System.Double]))
    } else {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.ArrayList))
    }
}

# East US
if ($boolEastUS -eq $true) {
    $strRegionName = 'East US'
    $strURI = 'https://s8eastus.blob.core.windows.net/public/latency-test.json'
    $hashtableRegionNamesToURIs.Add($strRegionName, $strURI)
    if ($versionPS -ge ([version]'6.0')) {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.Generic.List[System.Double]))
    } else {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.ArrayList))
    }
}

# East US 2
if ($boolEastUS2 -eq $true) {
    $strRegionName = 'East US 2'
    $strURI = 'https://s8eastus2.blob.core.windows.net/public/latency-test.json'
    $hashtableRegionNamesToURIs.Add($strRegionName, $strURI)
    if ($versionPS -ge ([version]'6.0')) {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.Generic.List[System.Double]))
    } else {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.ArrayList))
    }
}

# North Central US
if ($boolNorthCentralUS -eq $true) {
    $strRegionName = 'North Central US'
    $strURI = 'https://s9northcentralus.blob.core.windows.net/public/latency-test.json'
    $hashtableRegionNamesToURIs.Add($strRegionName, $strURI)
    if ($versionPS -ge ([version]'6.0')) {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.Generic.List[System.Double]))
    } else {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.ArrayList))
    }
}

# South Central US
if ($boolSouthCentralUS -eq $true) {
    $strRegionName = 'South Central US'
    $strURI = 'https://s9southcentralus.blob.core.windows.net/public/latency-test.json'
    $hashtableRegionNamesToURIs.Add($strRegionName, $strURI)
    if ($versionPS -ge ([version]'6.0')) {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.Generic.List[System.Double]))
    } else {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.ArrayList))
    }
}

# West Central US
if ($boolWestCentralUS -eq $true) {
    $strRegionName = 'West Central US'
    $strURI = 'https://s8westcentralus.blob.core.windows.net/public/latency-test.json'
    $hashtableRegionNamesToURIs.Add($strRegionName, $strURI)
    if ($versionPS -ge ([version]'6.0')) {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.Generic.List[System.Double]))
    } else {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.ArrayList))
    }
}

# West US
if ($boolWestUS -eq $true) {
    $strRegionName = 'West US'
    $strURI = 'https://s9westus.blob.core.windows.net/public/latency-test.json'
    $hashtableRegionNamesToURIs.Add($strRegionName, $strURI)
    if ($versionPS -ge ([version]'6.0')) {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.Generic.List[System.Double]))
    } else {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.ArrayList))
    }
}

# West US 2
if ($boolWestUS2 -eq $true) {
    $strRegionName = 'West US 2'
    $strURI = 'https://h3westus2.blob.core.windows.net/public/latency-test.json'
    $hashtableRegionNamesToURIs.Add($strRegionName, $strURI)
    if ($versionPS -ge ([version]'6.0')) {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.Generic.List[System.Double]))
    } else {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.ArrayList))
    }
}

# West US 3
if ($boolWestUS3 -eq $true) {
    $strRegionName = 'West US 3'
    $strURI = 'https://s9westus3.blob.core.windows.net/public/latency-test.json'
    $hashtableRegionNamesToURIs.Add($strRegionName, $strURI)
    if ($versionPS -ge ([version]'6.0')) {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.Generic.List[System.Double]))
    } else {
        $hashtableURIsToTestResults.Add($strURI, (New-Object System.Collections.ArrayList))
    }
}

$arrURIs = @($hashtableURIsToTestResults.Keys)
$intURICount = $arrURIs.Count

# Dump the first two requests
for ($intTestCounter = 0; $intTestCounter -lt 2; $intTestCounter++) {
    $datetimeStart = Get-Date
    for ($intURICounter = 0; $intURICounter -lt $intURICount; $intURICounter++) {
        $strURI = $arrURIs[$intURICounter]
        # Invoke-WebRequest -Uri $strURI | Out-Null
        $doubleLatency = $latencyTester.PingUrl($strURI)
    }
    $datetimeEnd = Get-Date
    $timespanDuration = $datetimeEnd - $datetimeStart
    if (($doubleNumberOfSecondsBetweenTests - $timespanDuration.TotalSeconds) -gt 0) {
        Start-Sleep -Seconds ($doubleNumberOfSecondsBetweenTests - $timespanDuration.TotalSeconds)
    }
}

$datetimeOverallStart = Get-Date
$datetimeOverallEnd = $datetimeOverallStart.AddMinutes($doubleNumberOfMinutesOfTesting)
while ((Get-Date) -lt $datetimeOverallEnd) {
    $datetimeStart = Get-Date
    $doublePercentageComplete = ($datetimeStart - $datetimeOverallStart).TotalMinutes / $doubleNumberOfMinutesOfTesting
    Write-Progress -Activity 'Testing' -Status 'Measuring latency to Azure regions' -PercentComplete ($doublePercentageComplete * 100) -SecondsRemaining ($datetimeOverallEnd - $datetimeStart).TotalSeconds
    for ($intURICounter = 0; $intURICounter -lt $intURICount; $intURICounter++) {
        $strURI = $arrURIs[$intURICounter]
        # $datetimeURIBegin = Get-Date
        $doubleLatency = $latencyTester.PingUrl($strURI)
        if ($doubleLatency -ge 0) {
            if ($versionPS -ge ([version]'6.0')) {
                # $hashtableURIsToTestResults[$strURI].Add($timespanDuration.TotalMilliseconds)
                $hashtableURIsToTestResults[$strURI].Add($doubleLatency)
            } else {
                [void]($hashtableURIsToTestResults[$strURI].Add($doubleLatency))
            }
        }
        # $datetimeURIEnd = Get-Date
        # $timespanDuration = $datetimeURIEnd - $datetimeURIBegin
    }
    $datetimeEnd = Get-Date
    $timespanDuration = $datetimeEnd - $datetimeStart
    if (($doubleNumberOfSecondsBetweenTests - $timespanDuration.TotalSeconds) -gt 0) {
        Start-Sleep -Seconds ($doubleNumberOfSecondsBetweenTests - $timespanDuration.TotalSeconds)
    }
}
Write-Progress -Activity 'Testing' -Status 'Measuring latency to Azure regions' -Completed

# Calculate statistics
# Minimum, maximum, average, jitter
$hashtableURIsToStatistics = @{}
foreach ($strURI in $arrURIs) {
    $arrLatencies = $hashtableURIsToTestResults[$strURI]
    $doubleMinimum = $arrLatencies | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
    $doubleMaximum = $arrLatencies | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
    $doubleAverage = $arrLatencies | Measure-Object -Average | Select-Object -ExpandProperty Average

    # Jitter is the sum of the absolute difference between each sample divided by the number of samples minus 1
    # See: https://www.pingman.com/kb/article/what-is-jitter-57.html
    if ($arrLatencies.Count -le 1) {
        $doubleJitter = 0
    } else {
        $doubleJitter = 0
        for ($intJitterCounter = 1; $intJitterCounter -lt $arrLatencies.Count; $intJitterCounter++) {
            $doubleJitter += [Math]::Abs($arrLatencies[$intJitterCounter] - $arrLatencies[$intJitterCounter - 1])
        }
        $doubleJitter /= ($arrLatencies.Count - 1)
    }

    $psobjectStats = New-Object -TypeName PSObject
    $psobjectStats | Add-Member -MemberType NoteProperty -Name 'Minimum' -Value $doubleMinimum
    $psobjectStats | Add-Member -MemberType NoteProperty -Name 'Maximum' -Value $doubleMaximum
    $psobjectStats | Add-Member -MemberType NoteProperty -Name 'Average' -Value $doubleAverage
    $psobjectStats | Add-Member -MemberType NoteProperty -Name 'Jitter' -Value $doubleJitter

    $hashtableURIsToStatistics.Add($strURI, $psobjectStats)
}

# Generate final output
if ($versionPS -ge ([version]'6.0')) {
    $listOutput = New-Object System.Collections.Generic.List[PSObject]
} else {
    $listOutput = New-Object System.Collections.ArrayList
}
$arrRegions = @($hashtableRegionNamesToURIs.Keys)
foreach ($strRegionName in $arrRegions) {
    $strURI = $hashtableRegionNamesToURIs[$strRegionName]
    $psobjectStats = $hashtableURIsToStatistics[$strURI]

    $psobjectFinal = New-Object -TypeName PSObject
    $psobjectFinal | Add-Member -MemberType NoteProperty -Name 'Region' -Value $strRegionName
    # $psobjectFinal | Add-Member -MemberType NoteProperty -Name 'URI' -Value $strURI
    $psobjectFinal | Add-Member -MemberType NoteProperty -Name 'Minimum' -Value $psobjectStats.Minimum
    $psobjectFinal | Add-Member -MemberType NoteProperty -Name 'Maximum' -Value $psobjectStats.Maximum
    $psobjectFinal | Add-Member -MemberType NoteProperty -Name 'Average' -Value $psobjectStats.Average
    $psobjectFinal | Add-Member -MemberType NoteProperty -Name 'Jitter' -Value $psobjectStats.Jitter
    if ($versionPS -ge ([version]'6.0')) {
        $listOutput.Add($psobjectFinal)
    } else {
        [void]($listOutput.Add($psobjectFinal))
    }
}

$listOutput | Format-Table -AutoSize
