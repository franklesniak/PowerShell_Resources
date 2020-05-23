# PSScriptAnalyzerSettings.psd1
# Settings for PSScriptAnalyzer invocation
# Last updated for PSScriptAnalyzer v1.19.0
#
# Note that VS Code will use whichever version is newer between the PSScriptAnalyzer version
# bundled with the PowerShell extension and the module version installed in PowerShell.
# On Windows, if PSScriptAnalyzer is installed in PowerShell, the compatibility profiles used
# by PSUseCompatibleCommands / UseCompatibileCommands and PSUseCompatibileTypes /
# UseCompatibleTypes were located here:
# C:\Program Files\WindowsPowerShell\Modules\PSScriptAnalyzer\1.19.0\compatibility_profiles
# Additional compatibility profiles can be downloaded from here and placed in the above folder:
# https://github.com/PowerShell/PSScriptAnalyzer/tree/master/PSCompatibilityCollector/optional_profiles
#
# Likewise, on Windows, if PSScriptAnalyzer is installed in PowerShell, the compatibility
# profiles used by PSUseCompatibileCmdlets / UseCompatibileCmdlets are located here:
# C:\Program Files\WindowsPowerShell\Modules\PSScriptAnalyzer\1.19.0\Settings
# Additional compatibility profiles can be generated using the New-CommandDataFile.ps1 script
# located here:
# https://github.com/PowerShell/PSScriptAnalyzer/blob/development/Utils/New-CommandDataFile.ps1

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

@{
    Rules = @{
        PSUseCompatibleCmdlets = @{
            compatibility = @(
                'desktop-2.0-windows',
                'desktop-3.0-windows',
                'desktop-4.0-windows',
                'desktop-5.1.14393.206-windows',
                'core-6.1.0-windows',
                'core-6.1.0-linux',
                'core-6.1.0-linux-arm',
                'core-6.1.0-macos'
            )
        }
        PSUseCompatibleCommands = @{
            # Turn the rule on
            Enable = $true

            # List the PowerShell platforms with which we want to check compatibility
            TargetProfiles = @(
                'ubuntu_x64_18.04_6.2.4_x64_4.0.30319.42000_core',
                'ubuntu_x64_18.04_7.0.0_x64_3.1.2_core',
                'win-48_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework',
                'win-4_x64_10.0.18362.0_6.2.4_x64_4.0.30319.42000_core',
                'win-4_x64_10.0.18362.0_7.0.0_x64_3.1.2_core',
                'win-8_x64_10.0.14393.0_5.1.14393.2791_x64_4.0.30319.42000_framework',
                'win-8_x64_10.0.14393.0_6.2.4_x64_4.0.30319.42000_core',
                'win-8_x64_10.0.14393.0_7.0.0_x64_3.1.2_core',
                'win-8_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework',
                'win-8_x64_10.0.17763.0_6.2.4_x64_4.0.30319.42000_core',
                'win-8_x64_10.0.17763.0_7.0.0_x64_3.1.2_core',
                'win-8_x64_6.2.9200.0_3.0_x64_4.0.30319.42000_framework',
                'win-8_x64_6.3.9600.0_4.0_x64_4.0.30319.42000_framework'
            )
        }
        PSUseCompatibleSyntax = @{
            # Turn the rule on
            Enable = $true

            # List the targeted versions of PowerShell
            TargetVersions = @(
                '3.0',
                '4.0',
                '5.0',
                '6.0',
                '7.0'
            )
        }
        UseCompatibleTypes = @{
            # Turn the rule on
            Enable = $true

            # List the PowerShell platforms with which we want to check compatibility
            TargetProfiles = @(
                'ubuntu_x64_18.04_6.2.4_x64_4.0.30319.42000_core',
                'ubuntu_x64_18.04_7.0.0_x64_3.1.2_core',
                'win-48_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework',
                'win-4_x64_10.0.18362.0_6.2.4_x64_4.0.30319.42000_core',
                'win-4_x64_10.0.18362.0_7.0.0_x64_3.1.2_core',
                'win-8_x64_10.0.14393.0_5.1.14393.2791_x64_4.0.30319.42000_framework',
                'win-8_x64_10.0.14393.0_6.2.4_x64_4.0.30319.42000_core',
                'win-8_x64_10.0.14393.0_7.0.0_x64_3.1.2_core',
                'win-8_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework',
                'win-8_x64_10.0.17763.0_6.2.4_x64_4.0.30319.42000_core',
                'win-8_x64_10.0.17763.0_7.0.0_x64_3.1.2_core',
                'win-8_x64_6.2.9200.0_3.0_x64_4.0.30319.42000_framework',
                'win-8_x64_6.3.9600.0_4.0_x64_4.0.30319.42000_framework'
            )
        }
        PSPlaceOpenBrace = @{
            # Turn the rule on
            Enable = $true

            # Use K&R; historically I've used Allman, but Raspberry Pi will not tolerate Allman
            # PowerShell at all, so I'm forcing myself to change
            OnSameLine = $true
            NewLineAfter = $true

            # Allow small exceptions, e.g.,: if ($true) { "blah" } else { "blah blah" }
            IgnoreOneLineBlock = $true
        }
        PSPlaceCloseBrace = @{
            # Turn the rule on
            Enable = $true

            # Minimize whitespace
            NoEmptyLineBefore = $true

            # Allow small exceptions, e.g.,: if ($true) { "blah" } else { "blah blah" }
            IgnoreOneLineBlock = $true

            # Use K&R; historically I've used Allman, but Raspberry Pi will not tolerate Allman
            # PowerShell at all, so I'm forcing myself to change
            NewLineAfter = $false
        }
        PSUseConsistentIndentation = @{
            # Turn the rule on
            Enable = $true

            # Each indentation should be 4 spaces
            IndentationSize = 4
            Kind = 'space'

            # Multi-line pipeline statements should indent every line following the second only once
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
        }
        PSUseConsistentWhitespace  = @{
            # Turn the rule on
            Enable = $true

            # e.g.: enforce: if ($true) { foo } instead of: if ($true) {bar}
            CheckInnerBrace = $true

            # e.g.: enforce: foo { } instead of: foo{ }
            CheckOpenBrace = $true

            # e.g.: enforce: if (true) instead of: if(true)
            CheckOpenParen = $true

            # e.g.: enforce: $x = 1 instead of: $x=1
            CheckOperator = $true

            # e.g.: enforce: foo | bar instead of: foo|bar
            CheckPipe = $true

            # e.g.: enforce: @(1, 2, 3) or @{a = 1; b = 2} instead of: @(1,2,3) or @{a = 1;b = 2}
            CheckSeparator = $true
        }
    }
}