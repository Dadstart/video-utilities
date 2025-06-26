# VideoFunctions Module Installation Guide

This guide provides comprehensive documentation for the VideoFunctions PowerShell module installation system, including installation, uninstallation, reinstallation, and advanced configuration options.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation Scripts](#installation-scripts)
4. [Installation Scopes](#installation-scopes)
5. [Verbosity Control](#verbosity-control)
6. [Advanced Usage](#advanced-usage)
7. [Troubleshooting](#troubleshooting)
8. [Script Architecture](#script-architecture)

## Overview

The VideoFunctions module provides a complete installation system with three main scripts:

- **Install-VideoFunctions.ps1** - Installs the module to the system
- **Uninstall-VideoFunctions.ps1** - Removes the module from the system
- **Reinstall-VideoFunctions.ps1** - Performs a complete reinstallation

All scripts share common functionality through the `InstallationHelpers.ps1` module, providing consistent behavior, error handling, and verbosity control.

## Prerequisites

### System Requirements

- **PowerShell**: 5.1 or higher (Windows PowerShell) or PowerShell Core 6.0+
- **Operating System**: Windows 10/11, Windows Server 2016+
- **Permissions**: User-level access for CurrentUser scope, Administrator for AllUsers scope

### External Dependencies

- **FFmpeg**: Required for FFmpeg-related functions (Get-FFMpegVersion, Invoke-FFProbe)
- **MKVToolNix**: Required for MKV processing functions (Get-MkvTrack, Get-MkvTracks, Get-MkvTrackAll)

## Installation Scripts

### Install-VideoFunctions.ps1

Installs the VideoFunctions module to the specified PowerShell modules directory.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Scope` | `InstallScope` | `CurrentUser` | Installation scope: `CurrentUser` or `AllUsers` |
| `Force` | `switch` | `$false` | Overwrite existing installation |
| `Verbosity` | `VerbosityLevel` | `All` | Message verbosity level |
| `WhatIf` | `switch` | `$false` | Preview installation without executing |
| `Confirm` | `switch` | `$true` | Prompt for confirmation |

#### Examples

```powershell
# Basic installation for current user
.\Install-VideoFunctions.ps1

# Install for all users (requires elevation)
.\Install-VideoFunctions.ps1 -Scope AllUsers

# Force installation (overwrites existing)
.\Install-VideoFunctions.ps1 -Force

# Silent installation with minimal output
.\Install-VideoFunctions.ps1 -Verbosity Silent

# Preview installation without executing
.\Install-VideoFunctions.ps1 -WhatIf
```

### Uninstall-VideoFunctions.ps1

Removes the VideoFunctions module from the system.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Scope` | `UninstallScope` | `All` | Uninstallation scope: `CurrentUser`, `AllUsers`, or `All` |
| `Force` | `switch` | `$false` | Skip confirmation prompts |
| `Verbosity` | `VerbosityLevel` | `All` | Message verbosity level |
| `WhatIf` | `switch` | `$false` | Preview uninstallation without executing |
| `Confirm` | `switch` | `$true` | Prompt for confirmation |

#### Examples

```powershell
# Uninstall from all locations
.\Uninstall-VideoFunctions.ps1

# Uninstall from current user only
.\Uninstall-VideoFunctions.ps1 -Scope CurrentUser

# Force uninstallation without prompts
.\Uninstall-VideoFunctions.ps1 -Force

# Preview uninstallation
.\Uninstall-VideoFunctions.ps1 -WhatIf
```

### Reinstall-VideoFunctions.ps1

Performs a complete reinstallation by uninstalling and then installing the module.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Scope` | `ReinstallScope` | `All` | Reinstallation scope: `CurrentUser`, `AllUsers`, or `All` |
| `Force` | `switch` | `$false` | Skip confirmation prompts |
| `Verbosity` | `VerbosityLevel` | `All` | Message verbosity level |
| `ImportModule` | `switch` | `$false` | Import module after installation |
| `WhatIf` | `switch` | `$false` | Preview reinstallation without executing |
| `Confirm` | `switch` | `$true` | Prompt for confirmation |

#### Examples

```powershell
# Complete reinstallation
.\Reinstall-VideoFunctions.ps1

# Reinstall for all users with force
.\Reinstall-VideoFunctions.ps1 -Scope AllUsers -Force

# Reinstall and automatically import module
.\Reinstall-VideoFunctions.ps1 -ImportModule

# Silent reinstallation
.\Reinstall-VideoFunctions.ps1 -Verbosity Silent
```

## Installation Scopes

### Scope Enums

The installation system uses strongly-typed enums for scope validation:

```powershell
enum InstallScope {
    CurrentUser
    AllUsers
}

enum UninstallScope {
    CurrentUser
    AllUsers
    All
}

enum ReinstallScope {
    CurrentUser
    AllUsers
    All
}
```

### Scope Behavior

| Scope | Install | Uninstall | Reinstall | Requires Elevation |
|-------|---------|-----------|-----------|-------------------|
| `CurrentUser` | ✓ | ✓ | ✓ | No |
| `AllUsers` | ✓ | ✓ | ✓ | Yes |
| `All` | N/A | ✓ | ✓ | Yes (if AllUsers exists) |

### Installation Paths

The system automatically detects the correct installation paths based on PowerShell edition:

#### PowerShell Core (PSEdition = 'Core')
- **CurrentUser**: `$env:USERPROFILE\Documents\PowerShell\Modules\VideoFunctions`
- **AllUsers**: `$env:ProgramFiles\PowerShell\Modules\VideoFunctions`

#### Windows PowerShell (PSEdition = 'Desktop')
- **CurrentUser**: `$env:USERPROFILE\Documents\WindowsPowerShell\Modules\VideoFunctions`
- **AllUsers**: `$env:ProgramFiles\WindowsPowerShell\Modules\VideoFunctions`

## Verbosity Control

### VerbosityLevel Enum

```powershell
enum VerbosityLevel {
    Silent    # Only errors
    Error     # Errors only
    Warning   # Warnings and errors
    Info      # Info, warnings, and errors
    Success   # Success, info, warnings, and errors
    All       # All message types
}
```

### Verbosity Behavior

| Level | Error | Warning | Info | Success | Debug |
|-------|-------|---------|------|---------|-------|
| `Silent` | ✓ | | | | |
| `Error` | ✓ | | | | |
| `Warning` | ✓ | ✓ | | | |
| `Info` | ✓ | ✓ | ✓ | | |
| `Success` | ✓ | ✓ | ✓ | ✓ | |
| `All` | ✓ | ✓ | ✓ | ✓ | ✓ |

### Message Format

All installation messages follow a consistent format:

```
[2024-01-15 14:30:25] INFO: Starting VideoFunctions module installation...
[2024-01-15 14:30:25] SUCCESS: Installation completed successfully!
[2024-01-15 14:30:25] WARNING: Module already exists, will overwrite.
[2024-01-15 14:30:25] ERROR: Installation failed: Access denied.
```

## Advanced Usage

### Automated Installation

```powershell
# Silent installation for CI/CD
.\Install-VideoFunctions.ps1 -Verbosity Silent -Force

# Unattended reinstallation
.\Reinstall-VideoFunctions.ps1 -Force -Verbosity Warning
```

### Module Import After Installation

```powershell
# Install and import in one command
.\Reinstall-VideoFunctions.ps1 -ImportModule

# Verify installation
Get-Command -Module VideoFunctions
```

### WhatIf and Confirm

```powershell
# Preview all operations
.\Install-VideoFunctions.ps1 -WhatIf -Verbosity All

# Skip confirmation prompts
.\Uninstall-VideoFunctions.ps1 -Confirm:$false
```

### Error Handling

All scripts use strict error handling with `$ErrorActionPreference = 'Stop'`:

```powershell
try {
    # Installation logic
} catch {
    Write-InstallationMessage "Installation failed: $($_.Exception.Message)" 'Error' $Verbosity
    exit 1
}
```

## Troubleshooting

### Common Issues

#### Permission Denied
```
ERROR: Administrative privileges are required to install for all users.
```
**Solution**: Run PowerShell as Administrator or use `-Scope CurrentUser`

#### Module Already Exists
```
ERROR: Module already exists at 'C:\...\VideoFunctions'.
```
**Solution**: Use `-Force` parameter to overwrite existing installation

#### Module Not Found
```
ERROR: VideoFunctions module directory not found.
```
**Solution**: Ensure script is run from the VideoFunctions module directory

#### Import Failure
```
ERROR: Module import test failed: Could not load file or assembly.
```
**Solution**: Check PowerShell execution policy: `Get-ExecutionPolicy`

### Diagnostic Commands

```powershell
# Check PowerShell version and edition
$PSVersionTable

# Check execution policy
Get-ExecutionPolicy

# Check module paths
$env:PSModulePath -split ';'

# Test administrator privileges
[Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains "S-1-5-32-544"
```

### Verbosity for Debugging

```powershell
# Full verbose output for troubleshooting
.\Install-VideoFunctions.ps1 -Verbosity All

# Error-only output for production
.\Install-VideoFunctions.ps1 -Verbosity Error
```
