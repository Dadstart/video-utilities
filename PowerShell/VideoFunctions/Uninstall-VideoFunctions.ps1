#!/usr/bin/env pwsh

# Define enums for parameter validation
enum UninstallScope {
    CurrentUser
    AllUsers
    All
}

enum VerbosityLevel {
    Silent
    Error
    Warning
    Info
    Success
    All
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

# Global verbosity setting
$script:VerbosityLevel = $Verbosity

function Write-UninstallMessage {
    param(
        [string]$Message,
        [string]$Type = 'Info'
    )
    
    # Check if message should be displayed based on verbosity level
    $shouldDisplay = switch ($script:VerbosityLevel) {
        'Silent'   { $Type -eq 'Error' }
        'Error'    { $Type -in @('Error') }
        'Warning'  { $Type -in @('Error', 'Warning') }
        'Info'     { $Type -in @('Error', 'Warning', 'Info') }
        'Success'  { $Type -in @('Error', 'Warning', 'Info', 'Success') }
        'All'      { $true }
        default    { $true }
    }
    
    if (-not $shouldDisplay) {
        return
    }
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH-mm-ss'
    switch ($Type) {
        'Info'    { Write-Host ("[$timestamp] INFO: " + $Message) -ForegroundColor Cyan }
        'Success' { Write-Host ("[$timestamp] SUCCESS: " + $Message) -ForegroundColor Green }
        'Warning' { Write-Host ("[$timestamp] WARNING: " + $Message) -ForegroundColor Yellow }
        'Error'   { Write-Host ("[$timestamp] ERROR: " + $Message) -ForegroundColor Red }
    }
}

function Test-Administrator {
    <#
    .SYNOPSIS
        Tests if the current session is running with administrative privileges.
    #>
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-ModulePaths {
    <#
    .SYNOPSIS
        Gets all possible module paths for VideoFunctions.
    #>
    $paths = @()
    
    # Current User paths
    if ($Scope -in @('CurrentUser', 'All')) {
        if ($PSVersionTable.PSEdition -eq 'Core') {
            $paths += "$env:USERPROFILE\Documents\PowerShell\Modules\VideoFunctions"
        } else {
            $paths += "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\VideoFunctions"
        }
    }
    
    # All Users paths
    if ($Scope -in @('AllUsers', 'All')) {
        if ($PSVersionTable.PSEdition -eq 'Core') {
            $paths += "$env:ProgramFiles\PowerShell\Modules\VideoFunctions"
        } else {
            $paths += "$env:ProgramFiles\WindowsPowerShell\Modules\VideoFunctions"
        }
    }
    
    return $paths
}

function Test-ModuleInstalled {
    <#
    .SYNOPSIS
        Tests if the VideoFunctions module is installed and returns installation locations.
    #>
    $modulePaths = Get-ModulePaths
    $installedPaths = @()
    
    foreach ($path in $modulePaths) {
        if (Test-Path $path) {
            $installedPaths += $path
        }
    }
    
    return $installedPaths
}

function Get-ModuleInfo {
    param(
        [string]$ModulePath
    )
    
    try {
        $manifestPath = Join-Path $ModulePath 'VideoFunctions.psd1'
        if (Test-Path $manifestPath) {
            $manifest = Import-PowerShellDataFile -Path $manifestPath
            return @{
                Version = $manifest.ModuleVersion
                Author = $manifest.Author
                Description = $manifest.Description
            }
        }
    }
    catch {
        Write-UninstallMessage ("Failed to read module info from $ModulePath`:" + $_.Exception.Message) 'Warning'
    }
    
    return @{
        Version = 'Unknown'
        Author = 'Unknown'
        Description = 'Unknown'
    }
}

# Main uninstallation logic
try {
    Write-UninstallMessage "Starting VideoFunctions module uninstallation..." 'Info'
    Write-UninstallMessage "PowerShell Version: $($PSVersionTable.PSVersion)" 'Info'
    Write-UninstallMessage "PowerShell Edition: $($PSVersionTable.PSEdition)" 'Info'
    Write-UninstallMessage "Uninstallation Scope: $Scope" 'Info'
    
    # Check for administrative privileges if needed
    if ($Scope -eq 'AllUsers' -and -not (Test-Administrator)) {
        throw "Administrative privileges are required to uninstall from AllUsers scope. Please run PowerShell as Administrator or use -Scope CurrentUser."
    }
    
    # Find installed modules
    $installedPaths = Test-ModuleInstalled
    
    if ($installedPaths.Count -eq 0) {
        Write-UninstallMessage "VideoFunctions module is not installed in the specified scope(s)." 'Warning'
        return
    }
    
    Write-UninstallMessage "Found VideoFunctions module in $($installedPaths.Count) location(s):" 'Info'
    foreach ($path in $installedPaths) {
        $moduleInfo = Get-ModuleInfo -ModulePath $path
        Write-UninstallMessage "  - $path (Version: $($moduleInfo.Version))" 'Info'
    }
    
    # Check if module is currently loaded
    $loadedModule = Get-Module VideoFunctions -ErrorAction SilentlyContinue
    if ($loadedModule) {
        Write-UninstallMessage "Module is currently loaded. Attempting to remove..." 'Warning'
        try {
            Remove-Module VideoFunctions -Force -ErrorAction Stop
            Write-UninstallMessage "Module removed from memory successfully." 'Success'
        }
        catch {
            Write-UninstallMessage "Failed to remove module from memory: $($_.Exception.Message)" 'Warning'
            Write-UninstallMessage "Please close any PowerShell sessions using the module and try again." 'Info'
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
                Write-UninstallMessage "Removing module from: $path" 'Info'
                
                # Get module info before removal
                $moduleInfo = Get-ModuleInfo -ModulePath $path
                
                # Remove the module directory
                Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
                
                Write-UninstallMessage "Successfully removed VideoFunctions version $($moduleInfo.Version) from $path" 'Success'
            }
            catch {
                Write-UninstallMessage ("Failed to remove module from $path`:" + $_.Exception.Message) 'Error'
                throw
            }
        }
    }
    
    # Verify uninstallation
    $remainingPaths = Test-ModuleInstalled
    if ($remainingPaths.Count -eq 0) {
        Write-UninstallMessage "Uninstallation completed successfully!" 'Success'
        Write-UninstallMessage "VideoFunctions module has been completely removed from the system." 'Info'
    } else {
        Write-UninstallMessage "Uninstallation completed with warnings." 'Warning'
        Write-UninstallMessage "Remaining module locations:" 'Warning'
        foreach ($path in $remainingPaths) {
            Write-UninstallMessage "  - $path" 'Warning'
        }
    }
    
} catch {
    Write-UninstallMessage "Uninstallation failed: $($_.Exception.Message)" 'Error'
    exit 1
} 