<#
.SYNOPSIS
    Uninstall script for the Video PowerShell module.

.DESCRIPTION
    This script removes the Video PowerShell module from the user's PowerShell modules directory.

.EXAMPLE
    .\Uninstall.ps1
    
    Removes the Video module from the user's PowerShell modules directory.

.NOTES
    This script requires PowerShell 7.0 or higher.
#>

[CmdletBinding()]
param()

#Requires -Version 7.0

# Determine the modules directory
$modulesPath = if ($IsWindows) {
    Join-Path $env:USERPROFILE "Documents\PowerShell\Modules"
} else {
    Join-Path $HOME ".local/share/powershell/Modules"
}

# Define the target module directory
$targetModulePath = Join-Path $modulesPath "Video"

# Check if module exists
if (-not (Test-Path $targetModulePath)) {
    Write-Warning "Video module not found at: $targetModulePath"
    return
}

try {
    # Remove the module if it's currently loaded
    if (Get-Module -Name Video -ErrorAction SilentlyContinue) {
        Write-Verbose "Removing loaded Video module"
        Remove-Module -Name Video -Force -ErrorAction SilentlyContinue
    }
    
    # Remove the module directory
    Write-Verbose "Removing Video module from: $targetModulePath"
    Remove-Item -Path $targetModulePath -Recurse -Force
    
    Write-Host "Video module uninstalled successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Failed to uninstall Video module: $($_.Exception.Message)"
    throw
} 