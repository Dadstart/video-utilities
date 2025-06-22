#!/usr/bin/env pwsh

# Import shared installation helpers
$helpersPath = Join-Path $PSScriptRoot 'Private\InstallationHelpers.ps1'
if (Test-Path $helpersPath) {
    . $helpersPath
} else {
    throw "InstallationHelpers.ps1 not found at: $helpersPath"
}

<#
.SYNOPSIS
    Uninstalls the VideoFunctions PowerShell module.

.DESCRIPTION
    This script removes the VideoFunctions module from the PowerShell modules directory.
    It supports both Windows PowerShell and PowerShell Core, and can uninstall from
    current user or all users scope (requires elevation).

.PARAMETER Scope
    Specifies the uninstallation scope. Valid values are 'CurrentUser', 'AllUsers', and 'All'.
    Default is 'All' which checks both scopes. 'AllUsers' requires elevation.

.PARAMETER Force
    Forces the uninstallation without prompting for confirmation.
    When specified, this parameter bypasses all confirmation prompts.

.PARAMETER Verbosity
    Controls the level of messages displayed. Valid values are 'Silent', 'Error', 'Warning', 'Info', 'Success', and 'All'.
    Default is 'All'. 'Silent' suppresses all messages except errors, 'Error' shows only errors,
    'Warning' shows warnings and errors, 'Info' shows info, warnings, and errors, 'Success' shows all except debug,
    and 'All' shows all message types.

.PARAMETER WhatIf
    Shows what would happen if the script runs without actually performing the uninstallation.

.PARAMETER Confirm
    Prompts for confirmation before performing the uninstallation.
    Note: Due to the high impact nature of this operation, confirmation may still be required
    unless -Force is specified.

.EXAMPLE
    .\Uninstall-VideoFunctions.ps1

    Uninstalls the module from all locations where it's found.

.EXAMPLE
    .\Uninstall-VideoFunctions.ps1 -Scope CurrentUser

    Uninstalls the module only from the current user's modules directory.

.EXAMPLE
    .\Uninstall-VideoFunctions.ps1 -Scope AllUsers

    Uninstalls the module only from the all users modules directory (requires elevation).

.EXAMPLE
    .\Uninstall-VideoFunctions.ps1 -Force

    Forces uninstallation without prompting for confirmation.

.EXAMPLE
    .\Uninstall-VideoFunctions.ps1 -WhatIf

    Shows what would happen without actually uninstalling.

.EXAMPLE
    .\Uninstall-VideoFunctions.ps1 -Verbosity Silent

    Uninstalls the module with minimal output (errors only).

.EXAMPLE
    .\Uninstall-VideoFunctions.ps1 -Verbosity Warning

    Uninstalls the module showing only warnings and errors.

.NOTES
    This script can be run from any directory.
    For AllUsers uninstallation, the script must be run with administrative privileges.
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $false)]
    [UninstallScope]$Scope = [UninstallScope]::All,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [VerbosityLevel]$Verbosity = [VerbosityLevel]::All
)

# Set strict error handling
$ErrorActionPreference = 'Stop'

# Main uninstallation logic
try {
    Write-InstallationMessage "Starting VideoFunctions module uninstallation..." 'Info' $Verbosity
    Write-InstallationMessage "PowerShell Version: $($PSVersionTable.PSVersion)" 'Info' $Verbosity
    Write-InstallationMessage "PowerShell Edition: $($PSVersionTable.PSEdition)" 'Info' $Verbosity
    Write-InstallationMessage "Uninstallation Scope: $Scope" 'Info' $Verbosity
    
    # Check for administrative privileges if needed
    if ($Scope -eq 'AllUsers' -and -not (Test-Administrator)) {
        throw "Administrative privileges are required to uninstall from AllUsers scope. Please run PowerShell as Administrator or use -Scope CurrentUser."
    }
    
    # Find installed modules
    $installedPaths = Test-ModuleInstalled -Scope $Scope
    
    if ($installedPaths.Count -eq 0) {
        Write-InstallationMessage "VideoFunctions module is not installed in the specified scope(s)." 'Warning' $Verbosity
        return
    }
    
    Write-InstallationMessage "Found VideoFunctions module in $($installedPaths.Count) location(s):" 'Info' $Verbosity
    foreach ($path in $installedPaths) {
        $moduleInfo = Get-ModuleInfo -ModulePath $path -VerbosityLevel $Verbosity
        Write-InstallationMessage "  - $path (Version: $($moduleInfo.Version))" 'Info' $Verbosity
    }
    
    # Check if module is currently loaded
    $loadedModule = Get-Module VideoFunctions -ErrorAction SilentlyContinue
    if ($loadedModule) {
        Write-InstallationMessage "Module is currently loaded. Attempting to remove..." 'Warning' $Verbosity
        try {
            Remove-Module VideoFunctions -Force -ErrorAction Stop
            Write-InstallationMessage "Module removed from memory successfully." 'Success' $Verbosity
        }
        catch {
            Write-InstallationMessage "Failed to remove module from memory: $($_.Exception.Message)" 'Warning' $Verbosity
            Write-InstallationMessage "Please close any PowerShell sessions using the module and try again." 'Info' $Verbosity
        }
    }
    
    # Perform the uninstallation
    foreach ($path in $installedPaths) {
        $shouldProceed = $false
        
        if ($Force) {
            # When -Force is specified, bypass confirmation
            $shouldProceed = $true
        } else {
            # Use ShouldProcess for confirmation handling
            $shouldProceed = $PSCmdlet.ShouldProcess($path, "Remove VideoFunctions module")
        }
        
        if ($shouldProceed) {
            try {
                Write-InstallationMessage "Removing module from: $path" 'Info' $Verbosity
                
                # Get module info before removal
                $moduleInfo = Get-ModuleInfo -ModulePath $path -VerbosityLevel $Verbosity
                
                # Remove the module directory
                Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
                
                Write-InstallationMessage "Successfully removed VideoFunctions version $($moduleInfo.Version) from $path" 'Success' $Verbosity
            }
            catch {
                Write-InstallationMessage "Failed to remove module from $path`: $($_.Exception.Message)" 'Error' $Verbosity
                throw
            }
        }
    }
    
    # Verify uninstallation
    $remainingPaths = Test-ModuleInstalled -Scope $Scope
    if ($remainingPaths.Count -eq 0) {
        Write-InstallationMessage "Uninstallation completed successfully!" 'Success' $Verbosity
        Write-InstallationMessage "VideoFunctions module has been completely removed from the system." 'Info' $Verbosity
    } else {
        Write-InstallationMessage "Uninstallation completed with warnings." 'Warning' $Verbosity
        Write-InstallationMessage "Remaining module locations:" 'Warning' $Verbosity
        foreach ($path in $remainingPaths) {
            Write-InstallationMessage "  - $path" 'Warning' $Verbosity
        }
    }
    
} catch {
    Write-InstallationMessage "Uninstallation failed: $($_.Exception.Message)" 'Error' $Verbosity
    exit 1
} 