<#
.SYNOPSIS
    Uninstall script for the VideoUtility PowerShell module.

.DESCRIPTION
    This script removes the VideoUtility PowerShell module by unloading it from the current session.

.EXAMPLE
    .\Uninstall.ps1
    
    Removes the VideoUtility module from the current session.

.NOTES
    This script requires PowerShell 7.0 or higher.
#>

[CmdletBinding()]
param()

#Requires -Version 7.0

# Remove the module if it's currently loaded
if (Get-Module -Name VideoUtility -ErrorAction SilentlyContinue) {
    Write-Verbose 'Removing loaded VideoUtility module'
    Remove-Module -Name VideoUtility -Force -ErrorAction SilentlyContinue
    Write-Host 'VideoUtility module uninstalled successfully!' -ForegroundColor Green
    Write-Host 'The module is no longer available in this session.' -ForegroundColor Yellow
}
else {
    Write-Warning "VideoUtility module is not currently loaded"
} 