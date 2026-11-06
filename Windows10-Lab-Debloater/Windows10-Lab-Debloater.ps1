# Windows 10 Lab Debloater
# Conservative AppX removal for a dedicated cybersecurity lab VM.
# Run in Windows PowerShell 5.1 as Administrator.
#
# Default: preview only.
# Apply default removals:
#   .\Windows10-Lab-Debloater.ps1 -Remove
# Include optional consumer apps:
#   .\Windows10-Lab-Debloater.ps1 -Remove -IncludeOptional
# Also remove matching provisioned packages for new profiles:
#   .\Windows10-Lab-Debloater.ps1 -Remove -IncludeOptional -RemoveProvisioned
#
# This script does NOT disable Windows services, Defender, Firewall,
# Windows Update, Event Log, SMB, PowerShell, or other lab components.

[CmdletBinding()]
param(
    [switch]$Remove,
    [switch]$IncludeOptional,
    [switch]$RemoveProvisioned
)

$ErrorActionPreference = 'Continue'

# Applications selected for removal by default.
$DefaultPatterns = @(
    '*Microsoft.XboxGamingOverlay*',       # Xbox Game Bar
    '*Microsoft.XboxGameOverlay*',
    '*Microsoft.Xbox.TCUI*',
    '*Microsoft.XboxApp*',
    '*Microsoft.XboxIdentityProvider*',
    '*Microsoft.GamingApp*',               # Xbox app (may be absent)
    '*Microsoft.BingNews*',
    '*Microsoft.GetHelp*',
    '*Microsoft.Getstarted*',
    '*Microsoft.MicrosoftSolitaireCollection*',
    '*Microsoft.People*'
)

# Review these before opting in. Some may be useful depending on your workflow.
$OptionalPatterns = @(
    '*Microsoft.BingWeather*',
    '*Microsoft.WindowsMaps*',
    '*Microsoft.YourPhone*',               # Phone Link
    '*Microsoft.SkypeApp*',
    '*Microsoft.ZuneMusic*',               # Legacy Groove Music
    '*Microsoft.ZuneVideo*',               # Movies & TV
    '*Microsoft.Microsoft3DViewer*',
    '*Microsoft.MixedReality.Portal*',
    '*Microsoft.WindowsFeedbackHub*',
    '*Microsoft.MicrosoftOfficeHub*',
    '*Clipchamp.Clipchamp*'
)

$Patterns = @($DefaultPatterns)
if ($IncludeOptional) {
    $Patterns += $OptionalPatterns
}

$LogDirectory = Join-Path $env:USERPROFILE 'Desktop\Lab-Debloat-Logs'
if (-not (Test-Path $LogDirectory)) {
    New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null
}
$LogPath = Join-Path $LogDirectory ("Debloat-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

function Write-Log {
    param([string]$Message)
    $Line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    $Line | Tee-Object -FilePath $LogPath -Append
}

# Require elevation before attempting changes.
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
$IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

Write-Log 'Windows 10 Lab Debloater started.'
Write-Log ("Mode: {0}" -f $(if ($Remove) { 'REMOVE' } else { 'PREVIEW ONLY' }))
Write-Log ("Optional applications included: {0}" -f [bool]$IncludeOptional)
Write-Log ("Provisioned package removal requested: {0}" -f [bool]$RemoveProvisioned)

if ($Remove -and -not $IsAdmin) {
    Write-Log 'ERROR: Open Windows PowerShell using Run as administrator, then rerun.'
    throw 'Administrator privileges are required for removal mode.'
}

if ($RemoveProvisioned -and -not $Remove) {
    Write-Log 'ERROR: -RemoveProvisioned requires -Remove.'
    throw 'Use -Remove together with -RemoveProvisioned.'
}

$FoundPackages = @()
foreach ($Pattern in $Patterns) {
    $Matches = @(Get-AppxPackage -Name $Pattern -ErrorAction SilentlyContinue)
    foreach ($Package in $Matches) {
        $FoundPackages += [PSCustomObject]@{
            Pattern = $Pattern
            Name = $Package.Name
            PackageFullName = $Package.PackageFullName
        }
    }
}

$FoundPackages = @($FoundPackages | Sort-Object PackageFullName -Unique)

Write-Log ("Installed matching packages found: {0}" -f $FoundPackages.Count)
if ($FoundPackages.Count -eq 0) {
    Write-Log 'No matching installed packages were found for the selected categories.'
}

foreach ($Item in $FoundPackages) {
    if (-not $Remove) {
        Write-Log ("PREVIEW: would remove current-user package: {0}" -f $Item.PackageFullName)
        continue
    }

    try {
        Write-Log ("Removing current-user package: {0}" -f $Item.PackageFullName)
        Remove-AppxPackage -Package $Item.PackageFullName -ErrorAction Stop
        Write-Log ("SUCCESS: removed {0}" -f $Item.PackageFullName)
    }
    catch {
        Write-Log ("FAILED: {0} | {1}" -f $Item.PackageFullName, $_.Exception.Message)
    }
}

if ($RemoveProvisioned) {
    Write-Log 'Checking provisioned packages (packages staged for newly created user profiles).'

    foreach ($Pattern in $Patterns) {
        # Match against DisplayName; strip surrounding wildcard characters.
        $DisplayPattern = $Pattern.Trim('*')
        $Provisioned = @(Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*$DisplayPattern*" })

        foreach ($Package in $Provisioned) {
            try {
                Write-Log ("Removing provisioned package: {0}" -f $Package.PackageName)
                Remove-AppxProvisionedPackage -Online -PackageName $Package.PackageName -ErrorAction Stop |
                    Out-Null
                Write-Log ("SUCCESS: removed provisioned package {0}" -f $Package.PackageName)
            }
            catch {
                Write-Log ("FAILED provisioned package: {0} | {1}" -f $Package.PackageName, $_.Exception.Message)
            }
        }
    }
}

Write-Log 'Finished. Review the log before proceeding with additional changes.'
Write-Log ("Log file: {0}" -f $LogPath)

Write-Host ''
Write-Host 'Finished. Log saved to:' -ForegroundColor Green
Write-Host $LogPath
if (-not $Remove) {
    Write-Host ''
    Write-Host 'This was preview-only. To apply the default removals, run:' -ForegroundColor Yellow
    Write-Host '.\Windows10-Lab-Debloater.ps1 -Remove'
    Write-Host 'To include optional apps, add -IncludeOptional.'
}
