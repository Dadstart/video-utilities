<#
.SYNOPSIS
    Uninstall script for the VideoUtility PowerShell module.

.DESCRIPTION
    This script removes the VideoUtility PowerShell module from the user's PowerShell modules directory.

.EXAMPLE
    .\Uninstall.ps1
    
    Removes the VideoUtility module from the user's PowerShell modules directory.

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
$targetModulePath = Join-Path $modulesPath "VideoUtility"

# Check if module exists
if (-not (Test-Path $targetModulePath)) {
    Write-Warning "VideoUtility module not found at: $targetModulePath"
    return
}

try {
    # Remove the module if it's currently loaded
    if (Get-Module -Name VideoUtility -ErrorAction SilentlyContinue) {
        Write-Verbose "Removing loaded VideoUtility module"
        Remove-Module -Name VideoUtility -Force -ErrorAction SilentlyContinue
    }
    
    # Remove the module directory
    Write-Verbose "Removing VideoUtility module from: $targetModulePath"
    Remove-Item -Path $targetModulePath -Recurse -Force
    
    Write-Host "VideoUtility module uninstalled successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Failed to uninstall VideoUtility module: $($_.Exception.Message)"
    throw
} 