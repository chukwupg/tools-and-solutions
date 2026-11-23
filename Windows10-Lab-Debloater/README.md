# Windows 10 Lab Debloater

A conservative PowerShell utility for removing selected preinstalled Windows 10 applications and reducing unnecessary software overhead on virtual machines.

## Overview

Windows 10 comes with several preinstalled applications and consumer features that may not be necessary in dedicated lab environments. These applications can contribute to background activity and consume system resources.

This script provides a controlled way to identify and remove selected built-in applications, particularly on resource-constrained virtual machines used for cybersecurity training, networking exercises, and Windows administration.

The primary motivation for developing this tool was to optimise a Windows 10 VirtualBox VM running with limited resources (4 GB RAM), while retaining the Windows functionality required for practical cybersecurity labs.

This is not a Windows modification tool, security bypass, or aggressive system debloating script. It focuses on selected AppX applications and does not attempt to strip essential Windows components.

## Features

- **Preview mode:** Displays matching installed applications without making changes.
- **Batch removal:** Removes selected applications instead of requiring manual uninstallation.
- **Optional application removal:** Allows users to include additional consumer applications.
- **Provisioned package removal:** Optionally removes selected provisioned applications to prevent their automatic installation in newly created user profiles.
- **Activity logging:** Records removal attempts, successful operations, and errors.
- **Conservative approach:** Leaves essential Windows functionality and security components untouched.

## Applications targeted

### Default removal list

The default configuration targets selected applications, including:

| Application | Description |
|---|---|
| Xbox Game Bar | Gaming overlay and recording features |
| Xbox Game Overlay | Xbox gaming overlay components |
| Xbox TCUI | Xbox-related user interface component |
| Xbox App | Xbox application |
| Xbox Identity Provider | Xbox authentication component |
| Gaming App | Xbox gaming application |
| Bing News | News application |
| Get Help | Windows support application |
| Get Started | Windows tips and onboarding |
| Microsoft Solitaire Collection | Preinstalled game |
| Microsoft People | Contacts application |

### Optional removal list

These applications are only targeted when `-IncludeOptional` is specified:

- Bing Weather
- Windows Maps
- Phone Link
- Skype
- Groove Music (legacy)
- Movies & TV
- Microsoft 3D Viewer
- Mixed Reality Portal
- Windows Feedback Hub
- Microsoft Office Hub
- Clipchamp

> **Note:** Application availability varies across Windows editions and builds. The script only processes matching packages that are actually installed or provisioned.

## Requirements

- Windows 10.
- Windows PowerShell 5.1.
- Administrator privileges for removal operations.
- PowerShell AppX and DISM cmdlets available in the Windows installation.

## Installation

Clone this repository or download the PowerShell script directly.

```powershell
git clone <repository-url>
```

Navigate to the directory containing the script:

```powershell
cd <repository-directory>
```

If Windows blocks script execution, you can temporarily allow scripts in the current PowerShell session:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

This setting applies only to the current PowerShell process.

## Usage

Open PowerShell as Administrator.

### 1. Preview matching applications

Before making changes, run the script without any parameters:

```powershell
.\Windows10-Lab-Debloater.ps1
```

This displays the applications that match the configured removal list and records the preview in a log file.

No applications are removed in this mode.

### 2. Remove default applications

To remove the applications in the default list:

```powershell
.\Windows10-Lab-Debloater.ps1 -Remove
```

### 3. Include optional applications

To remove both default and optional applications:

```powershell
.\Windows10-Lab-Debloater.ps1 -Remove -IncludeOptional
```

### 4. Remove provisioned applications

To also remove matching provisioned packages from the Windows image:

```powershell
.\Windows10-Lab-Debloater.ps1 -Remove -IncludeOptional -RemoveProvisioned
```

This helps prevent selected applications from being provisioned for newly created user profiles.

It does not automatically remove applications from every existing Windows user profile.

## Parameters

| Parameter | Description |
|---|---|
| `-Remove` | Executes removal instead of previewing |
| `-IncludeOptional` | Includes additional consumer applications |
| `-RemoveProvisioned` | Removes matching provisioned AppX packages |

The script runs in preview mode by default. `-RemoveProvisioned` requires `-Remove`.

## Logging

For transparency and troubleshooting, the script creates a log directory on the current user's desktop:

```text
Desktop/
└── Lab-Debloat-Logs/
    └── Debloat-YYYYMMDD-HHMMSS.log
```

The log records:

- Execution mode.
- Selected removal categories.
- Matching applications.
- Successful removal operations.
- Failed removal attempts and associated error messages.
- Provisioned package removal attempts.

Review the log after execution to verify the operations performed.

## What this script does NOT modify

The script deliberately avoids disabling or removing essential Windows functionality.

The following components are outside its removal scope:

- Windows Defender Antivirus.
- Windows Defender Firewall.
- Windows Event Log.
- Windows Update.
- PowerShell and Command Prompt.
- Windows Management Instrumentation (WMI).
- Remote Procedure Call (RPC).
- DHCP and DNS client services.
- SMB networking components.
- Task Scheduler.
- User Account Control (UAC).

It also does not disable Windows services, modify firewall rules, change security policies, or execute network requests.

## Safety considerations

Before running the script:

1. Review the PowerShell source code.
2. Run the preview mode first.
3. Create a VirtualBox snapshot or restore point.
4. Confirm that the applications selected for removal are not required for your environment.
5. Review the generated log after execution.

> **Important:** Removing an application is not always reversible through this script. Some applications may need to be reinstalled through Microsoft Store or other supported Windows installation methods.

Removing provisioned packages also affects future user profiles, so use that option deliberately.

This utility is intended primarily for personal lab environments and test virtual machines. Avoid deploying it across production systems without first evaluating the impact.

## Limitations

- Package availability and names may differ between Windows builds.
- Some applications may have dependencies that prevent removal.
- Provisioned package removal requires an elevated PowerShell session and access to the Windows servicing components.
- The script does not guarantee a particular RAM or CPU performance improvement.
- It does not provide an automated rollback mechanism.

## Project Background

This tool was developed as part of my ongoing hands-on learning in Windows administration, system optimisation, and cybersecurity lab management.

The objective was to maintain a lightweight Windows environment for practical exercises without compromising the core functionality required for security testing, network administration, and endpoint monitoring.

## Disclaimer

This project is provided for educational and personal system-maintenance purposes.

Use it at your own discretion. Always inspect scripts before executing them, understand the changes they make, and maintain a backup of important data.

## Author

**CHUKWU PRAISEGOD**  

**Follow my journey: [X](https://x.com/chukwupg) | [LinkedIn](https://linkedin.com/in/chukwupg)**

## License

MIT

See the `LICENSE` file.