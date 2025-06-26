<#
.SYNOPSIS
    Quick install script for the Video PowerShell module.

.DESCRIPTION
    This script performs a quick installation of the Video PowerShell module.
    It removes any existing installation and installs the current version.

.EXAMPLE
    .\QuickInstall.ps1
    
    Performs a quick installation of the Video module.

.NOTES
    This script requires PowerShell 7.0 or higher.
#>

[CmdletBinding()]
param()

#Requires -Version 7.0

Write-Host "Performing quick installation of Video module..." -ForegroundColor Yellow

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Run uninstall first to clean up any existing installation
$uninstallScript = Join-Path $scriptDir "Uninstall.ps1"
if (Test-Path $uninstallScript) {
    Write-Verbose "Running uninstall script to clean up existing installation"
    & $uninstallScript
}

# Run install script
$installScript = Join-Path $scriptDir "Install.ps1"
if (Test-Path $installScript) {
    Write-Verbose "Running install script"
    & $installScript -Force
} else {
    Write-Error "Install script not found: $installScript"
    throw "Install script not found"
}

Write-Host "Quick installation completed!" -ForegroundColor Green 