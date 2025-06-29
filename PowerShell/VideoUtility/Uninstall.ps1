<#
.SYNOPSIS
    Uninstall script for the VideoUtility PowerShell module.

.DESCRIPTION
    This script removes the VideoUtility PowerShell module by removing its path from PSModulePath
    and cleaning up the PowerShell profile configuration.

.EXAMPLE
    .\Uninstall.ps1
    
    Removes the VideoUtility module path from PSModulePath and cleans up profile configuration.

.NOTES
    This script requires PowerShell 7.0 or higher.
#>

[CmdletBinding()]
param()

#Requires -Version 7.0

# Get the script directory (module root)
$moduleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Get the parent directory (where the module folder is located)
$parentDir = Split-Path -Parent $moduleRoot

# Remove the module if it's currently loaded
if (Get-Module -Name VideoUtility -ErrorAction SilentlyContinue) {
    Write-Verbose 'Removing loaded VideoUtility module'
    Remove-Module -Name VideoUtility -Force -ErrorAction SilentlyContinue
}

# Remove from current session's PSModulePath
$currentModulePath = $env:PSModulePath -split ';'
$newModulePath = ($currentModulePath | Where-Object { $_ -ne $parentDir }) -join ';'
$env:PSModulePath = $newModulePath

Write-Verbose "Removed module path from current session: $parentDir"

# Clean up PowerShell profile
$profilePath = $PROFILE.CurrentUserAllHosts
if (Test-Path $profilePath) {
    try {
        $profileContent = Get-Content -Path $profilePath -Raw
        $lines = $profileContent -split "`n"
        
        # Remove lines that add this module path
        $filteredLines = $lines | Where-Object {
            $_ -notlike "*$parentDir*" -and 
            $_ -notlike "*VideoUtility module path*"
        }
        
        # Only update if there were changes
        if ($filteredLines.Count -ne $lines.Count) {
            $newContent = $filteredLines -join "`n"
            Set-Content -Path $profilePath -Value $newContent -Encoding UTF8
            Write-Verbose "Cleaned up profile configuration: $profilePath"
        }
    }
    catch {
        Write-Warning "Failed to clean up profile configuration: $($_.Exception.Message)"
    }
}

Write-Host 'VideoUtility module uninstalled successfully!' -ForegroundColor Green
Write-Host "Module path removed: $parentDir" -ForegroundColor Cyan
Write-Host 'The module will no longer be available in future PowerShell sessions.' -ForegroundColor Yellow 